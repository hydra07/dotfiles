#!/usr/bin/env python3
"""
md2pdf — Production-grade Markdown → PDF converter
Features:
  • Dual engine: WeasyPrint (default) / Playwright fallback
  • Syntax highlighting via Pygments (codehilite)
  • Jinja2 template system (cover page, header, footer)
  • Built-in themes: default, client-report, minimal, dark
  • Vietnamese / multilingual font support (Noto Sans)
  • Page numbers, TOC, custom CSS injection
  • Front-matter metadata parsing (YAML)
  • Watermark support
  • Auto page-break hints for headings / tables
"""

from __future__ import annotations

import argparse
import html as html_lib
import os
import re
import sys
import textwrap
from datetime import datetime
from pathlib import Path

import markdown
from jinja2 import Environment, FileSystemLoader, BaseLoader
from pygments.formatters import HtmlFormatter

# ─────────────────────────────────────────────────────────────
# MARKDOWN EXTENSIONS
# ─────────────────────────────────────────────────────────────
DEFAULT_EXTENSIONS = [
    "extra",  # tables, fenced_code, attr_list, def_list, footnotes, abbr, md_in_html
    "sane_lists",
    "toc",  # [TOC] macro + heading anchors
    "admonition",  # !!! note / warning / tip
    "codehilite",  # Pygments syntax highlight
]

EXTENSION_CONFIGS = {
    "codehilite": {
        "guess_lang": False,
        "linenums": False,
        "css_class": "highlight",
    },
    "toc": {
        "permalink": False,
        "toc_depth": "2-3",
    },
}

# ─────────────────────────────────────────────────────────────
# THEMES
# ─────────────────────────────────────────────────────────────
THEMES: dict[str, str] = {}

THEMES["default"] = """
/* ── Google Fonts – Noto Sans covers Latin + Vietnamese + CJK ── */
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans:ital,wght@0,400;0,600;1,400&family=Noto+Serif:ital,wght@0,400;0,600;1,400&family=Noto+Sans+Mono:wght@400;600&display=swap');

:root {
    --color-text:      #1a1a2e;
    --color-heading:   #0f0f23;
    --color-accent:    #2563eb;
    --color-border:    #d1d5db;
    --color-surface:   #f8fafc;
    --color-code-bg:   #f1f5f9;
    --color-code-border: #e2e8f0;
    --color-blockquote: #6b7280;
    --color-caption:   #9ca3af;
    --font-body:       'Noto Sans', 'Segoe UI', Helvetica, Arial, sans-serif;
    --font-heading:    'Noto Sans', 'Segoe UI', Helvetica, Arial, sans-serif;
    --font-mono:       'Noto Sans Mono', 'Fira Code', 'Cascadia Code', Consolas, monospace;
    --font-size-base:  11pt;
    --line-height:     1.75;
    --page-margin:     22mm;
}

/* ── Page layout ── */
@page {
    size: A4;
    margin: var(--page-margin);

    @top-center {
        content: string(doc-title);
        font-family: var(--font-body);
        font-size: 8pt;
        color: var(--color-caption);
        border-bottom: 0.5pt solid var(--color-border);
        padding-bottom: 4pt;
    }

    @bottom-right {
        content: counter(page) " / " counter(pages);
        font-family: var(--font-body);
        font-size: 8pt;
        color: var(--color-caption);
    }

    @bottom-left {
        content: string(section-title);
        font-family: var(--font-body);
        font-size: 8pt;
        color: var(--color-caption);
    }
}

@page :first {
    @top-center { content: none; }
    @bottom-left { content: none; }
    @bottom-right { content: none; }
}

/* ── Base ── */
body {
    font-family: var(--font-body);
    font-size: var(--font-size-base);
    line-height: var(--line-height);
    color: var(--color-text);
    -webkit-hyphens: auto;
    hyphens: auto;
    orphans: 3;
    widows: 3;
}

/* ── String sets for running headers ── */
h1 { string-set: doc-title content(), section-title content(); }
h2 { string-set: section-title content(); }

/* ── Headings ── */
h1, h2, h3, h4, h5, h6 {
    font-family: var(--font-heading);
    color: var(--color-heading);
    font-weight: 600;
    line-height: 1.3;
    page-break-after: avoid;
    break-after: avoid;
}

h1 { font-size: 22pt; margin: 0 0 12pt; border-bottom: 2pt solid var(--color-accent); padding-bottom: 6pt; }
h2 { font-size: 16pt; margin: 20pt 0 8pt; border-bottom: 0.5pt solid var(--color-border); padding-bottom: 4pt; }
h3 { font-size: 13pt; margin: 16pt 0 6pt; }
h4 { font-size: 11.5pt; margin: 12pt 0 4pt; }
h5, h6 { font-size: 11pt; margin: 10pt 0 3pt; }

/* ── Paragraphs ── */
p { margin: 0 0 9pt; }

/* ── Links ── */
a { color: var(--color-accent); text-decoration: none; }
a[href]::after { content: " (" attr(href) ")"; font-size: 8pt; color: var(--color-caption); }
a[href^="#"]::after, a[href^="mailto"]::after { content: ""; }

/* ── Lists ── */
ul, ol { margin: 6pt 0 9pt 20pt; padding: 0; }
li { margin-bottom: 3pt; }
li > ul, li > ol { margin-top: 3pt; margin-bottom: 3pt; }

/* ── Tables ── */
table {
    border-collapse: collapse;
    width: 100%;
    margin: 12pt 0;
    font-size: 10pt;
    page-break-inside: avoid;
}
thead { background-color: var(--color-accent); color: #fff; }
th {
    padding: 7pt 10pt;
    text-align: left;
    font-weight: 600;
    font-size: 9.5pt;
    letter-spacing: 0.02em;
}
td {
    padding: 6pt 10pt;
    border-bottom: 0.5pt solid var(--color-border);
    vertical-align: top;
}
tr:nth-child(even) td { background-color: var(--color-surface); }

/* ── Code ── */
code {
    font-family: var(--font-mono);
    font-size: 89%;
    background-color: var(--color-code-bg);
    border: 0.5pt solid var(--color-code-border);
    border-radius: 3pt;
    padding: 0.15em 0.4em;
}

pre {
    background-color: var(--color-code-bg);
    border: 0.5pt solid var(--color-code-border);
    border-left: 3pt solid var(--color-accent);
    border-radius: 4pt;
    padding: 10pt 12pt;
    margin: 10pt 0;
    overflow-x: auto;
    white-space: pre-wrap;
    word-wrap: break-word;
    page-break-inside: avoid;
    font-size: 9pt;
    line-height: 1.55;
}

pre code {
    background: none;
    border: none;
    padding: 0;
    font-size: inherit;
}

/* ── Syntax Highlight (Pygments friendly theme) ── */
.highlight { background: transparent !important; }
.highlight .hll { background-color: #fff3cd; display: block; margin: 0 -12pt; padding: 0 12pt; }
.highlight .c  { color: #6b7280; font-style: italic; }  /* Comment */
.highlight .err { color: #ef4444; }
.highlight .k  { color: #7c3aed; font-weight: 600; }    /* Keyword */
.highlight .o  { color: #374151; }                       /* Operator */
.highlight .n  { color: #1a1a2e; }                       /* Name */
.highlight .na { color: #0369a1; }                       /* Attr */
.highlight .nb { color: #0d9488; }                       /* Builtin */
.highlight .nc { color: #0369a1; font-weight: 600; }     /* Class */
.highlight .nd { color: #7c3aed; }
.highlight .nf { color: #0369a1; }                       /* Function */
.highlight .ni { color: #374151; }
.highlight .nn { color: #1a1a2e; font-weight: 600; }
.highlight .nt { color: #0369a1; font-weight: 600; }     /* Tag */
.highlight .nv { color: #1e40af; }
.highlight .s  { color: #15803d; }                       /* String */
.highlight .s1, .highlight .s2 { color: #15803d; }
.highlight .sa { color: #0369a1; }
.highlight .sb { color: #15803d; }
.highlight .m  { color: #b45309; }                       /* Number */
.highlight .mi, .highlight .mf { color: #b45309; }
.highlight .ow { color: #7c3aed; font-weight: 600; }
.highlight .p  { color: #374151; }
.highlight .si { color: #0d9488; }
.highlight .cm, .highlight .c1 { color: #6b7280; font-style: italic; }
.highlight .cs { color: #6b7280; font-weight: 600; font-style: italic; }
.highlight .cp { color: #7c3aed; }
.highlight .il { color: #b45309; }
.highlight .ge { font-style: italic; }
.highlight .gs { font-weight: 600; }

/* ── Blockquote ── */
blockquote {
    border-left: 3pt solid var(--color-accent);
    background-color: var(--color-surface);
    margin: 12pt 0;
    padding: 8pt 14pt;
    color: var(--color-blockquote);
    font-style: italic;
    border-radius: 0 4pt 4pt 0;
}
blockquote p { margin: 0; }
blockquote > p + p { margin-top: 6pt; }

/* ── Admonitions ── */
.admonition {
    border-radius: 4pt;
    padding: 10pt 14pt;
    margin: 12pt 0;
    border-left: 3pt solid;
    page-break-inside: avoid;
}
.admonition-title {
    font-weight: 600;
    font-size: 10pt;
    margin-bottom: 5pt;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
.admonition.note    { background: #eff6ff; border-color: #2563eb; }
.admonition.note .admonition-title { color: #1e40af; }
.admonition.warning { background: #fffbeb; border-color: #d97706; }
.admonition.warning .admonition-title { color: #92400e; }
.admonition.danger  { background: #fef2f2; border-color: #dc2626; }
.admonition.danger .admonition-title { color: #991b1b; }
.admonition.tip     { background: #f0fdf4; border-color: #16a34a; }
.admonition.tip .admonition-title { color: #14532d; }
.admonition.important { background: #faf5ff; border-color: #7c3aed; }
.admonition.important .admonition-title { color: #4c1d95; }

/* ── Images ── */
img {
    max-width: 100%;
    height: auto;
    page-break-inside: avoid;
    display: block;
    margin: 8pt auto;
}

/* ── Horizontal rule ── */
hr {
    border: none;
    border-top: 1pt solid var(--color-border);
    margin: 16pt 0;
}

/* ── TOC ── */
.toc {
    background: var(--color-surface);
    border: 0.5pt solid var(--color-border);
    border-radius: 4pt;
    padding: 12pt 16pt;
    margin: 12pt 0 20pt;
    font-size: 10pt;
}
.toc ul { margin: 4pt 0 0 16pt; }
.toc > ul { margin-left: 0; }
.toc li { margin-bottom: 2pt; }

/* ── Definition lists ── */
dt { font-weight: 600; margin-top: 8pt; }
dd { margin-left: 20pt; color: #374151; }

/* ── Footnotes ── */
.footnote { border-top: 0.5pt solid var(--color-border); margin-top: 20pt; padding-top: 8pt; font-size: 9pt; color: var(--color-blockquote); }

/* ── Page break utilities ── */
.page-break { page-break-before: always; break-before: page; }
h1 { page-break-before: auto; }
h1.no-break { page-break-before: avoid; }
"""

THEMES["client-report"] = THEMES["default"] + """
/* ── Client Report overrides ── */
:root {
    --color-accent:  #1e3a5f;
    --color-heading: #0c1f35;
}
@page {
    size: A4;
    margin: 25mm 20mm 28mm;
    @top-left {
        content: element(report-header);
    }
    @bottom-center {
        content: string(doc-title) "  ·  Confidential";
        font-size: 7.5pt;
        color: var(--color-caption);
    }
    @bottom-right {
        content: "Page " counter(page) " of " counter(pages);
        font-size: 7.5pt;
        color: var(--color-caption);
    }
}
h1 { color: var(--color-accent); border-bottom-color: var(--color-accent); font-size: 20pt; }
h2 { color: var(--color-accent); }
thead { background-color: var(--color-accent); }
"""

THEMES["minimal"] = """
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans:ital,wght@0,400;0,500;1,400&family=Noto+Sans+Mono:wght@400&display=swap');
:root {
    --color-text:    #111;
    --color-border:  #ccc;
    --color-surface: #fafafa;
    --font-body:     'Noto Sans', sans-serif;
    --font-mono:     'Noto Sans Mono', monospace;
}
@page { size: A4; margin: 24mm; @bottom-right { content: counter(page); font-size: 8pt; color: #999; } }
body { font-family: var(--font-body); font-size: 11pt; line-height: 1.7; color: var(--color-text); }
h1,h2,h3,h4,h5,h6 { font-weight: 500; color: #000; page-break-after: avoid; }
h1 { font-size: 20pt; border-bottom: 1pt solid #000; padding-bottom: 4pt; }
h2 { font-size: 14pt; }
h3 { font-size: 12pt; }
p { margin: 0 0 8pt; }
a { color: inherit; text-decoration: underline; }
a[href]::after { content: none; }
pre { background: var(--color-surface); border: 0.5pt solid var(--color-border); padding: 8pt 10pt; font-size: 9pt; page-break-inside: avoid; }
code { font-family: var(--font-mono); font-size: 90%; background: var(--color-surface); padding: 0.1em 0.3em; border: 0.5pt solid var(--color-border); }
pre code { background: none; border: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 10pt 0; font-size: 10pt; page-break-inside: avoid; }
th { border-bottom: 1pt solid #000; padding: 5pt 8pt; text-align: left; font-weight: 500; }
td { border-bottom: 0.5pt solid var(--color-border); padding: 5pt 8pt; vertical-align: top; }
blockquote { border-left: 2pt solid #000; padding-left: 12pt; margin: 10pt 0; color: #555; font-style: italic; }
.highlight { background: none !important; }
.admonition { border: 0.5pt solid var(--color-border); padding: 8pt 12pt; margin: 10pt 0; }
.admonition-title { font-weight: 500; }
img { max-width: 100%; height: auto; page-break-inside: avoid; }
"""

THEMES["dark"] = """
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans:ital,wght@0,400;0,600;1,400&family=Noto+Sans+Mono:wght@400;600&display=swap');
:root {
    --color-text:      #e2e8f0;
    --color-heading:   #f1f5f9;
    --color-accent:    #60a5fa;
    --color-border:    #334155;
    --color-surface:   #1e293b;
    --color-code-bg:   #0f172a;
    --color-bg:        #0f172a;
    --font-body:       'Noto Sans', sans-serif;
    --font-mono:       'Noto Sans Mono', monospace;
}
@page {
    size: A4;
    margin: 22mm;
    background: var(--color-bg);
    @bottom-right { content: counter(page) " / " counter(pages); font-size: 8pt; color: #475569; }
}
html { background: var(--color-bg); }
body { font-family: var(--font-body); font-size: 11pt; line-height: 1.75; color: var(--color-text); background: var(--color-bg); }
h1,h2,h3,h4,h5,h6 { color: var(--color-heading); font-weight: 600; page-break-after: avoid; }
h1 { font-size: 22pt; border-bottom: 1.5pt solid var(--color-accent); padding-bottom: 5pt; }
h2 { font-size: 15pt; border-bottom: 0.5pt solid var(--color-border); padding-bottom: 3pt; }
h3 { font-size: 13pt; }
p { margin: 0 0 9pt; }
a { color: var(--color-accent); }
a[href]::after { content: none; }
pre { background: var(--color-code-bg); border: 0.5pt solid var(--color-border); border-left: 3pt solid var(--color-accent); padding: 10pt 12pt; font-size: 9pt; line-height: 1.55; page-break-inside: avoid; }
code { font-family: var(--font-mono); background: var(--color-code-bg); border: 0.5pt solid var(--color-border); padding: 0.15em 0.4em; font-size: 89%; }
pre code { background: none; border: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 10pt 0; font-size: 10pt; page-break-inside: avoid; }
thead { background: #1e3a5f; }
th { color: #bfdbfe; padding: 6pt 10pt; font-weight: 600; font-size: 9.5pt; }
td { padding: 6pt 10pt; border-bottom: 0.5pt solid var(--color-border); vertical-align: top; }
tr:nth-child(even) td { background: var(--color-surface); }
blockquote { border-left: 3pt solid var(--color-accent); background: var(--color-surface); padding: 8pt 14pt; color: #94a3b8; font-style: italic; }
.admonition { border-left: 3pt solid #475569; background: var(--color-surface); padding: 10pt 14pt; margin: 10pt 0; }
.highlight .c  { color: #64748b; font-style: italic; }
.highlight .k  { color: #a78bfa; font-weight: 600; }
.highlight .s, .highlight .s1, .highlight .s2 { color: #4ade80; }
.highlight .m, .highlight .mi, .highlight .mf  { color: #fb923c; }
.highlight .nb { color: #22d3ee; }
.highlight .nf { color: #60a5fa; }
.highlight .nc { color: #60a5fa; font-weight: 600; }
.highlight .nd { color: #a78bfa; }
.highlight .nt { color: #60a5fa; font-weight: 600; }
img { max-width: 100%; height: auto; page-break-inside: avoid; }
"""

# ─────────────────────────────────────────────────────────────
# HTML TEMPLATE (Jinja2)
# ─────────────────────────────────────────────────────────────
HTML_TEMPLATE = """\
<!DOCTYPE html>
<html lang="{{ lang }}">
<head>
  <meta charset="UTF-8">
  <title>{{ title }}</title>
  <base href="{{ base_href }}">
  <style>
{{ theme_css }}
{% if extra_css %}
/* ── User custom CSS ── */
{{ extra_css }}
{% endif %}
{% if watermark %}
/* ── Watermark ── */
@page { @top-right { content: "{{ watermark }}"; color: rgba(180,180,180,0.6); font-size: 9pt; } }
body::after {
  content: "{{ watermark }}";
  position: fixed;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%) rotate(-35deg);
  font-size: 72pt;
  font-weight: 700;
  color: rgba(0,0,0,0.05);
  pointer-events: none;
  white-space: nowrap;
  z-index: 9999;
}
{% endif %}
  </style>
</head>
<body>
{% if cover %}
<div class="cover-page" style="
  display: flex; flex-direction: column; justify-content: center;
  min-height: calc(297mm - 44mm); page-break-after: always;
  text-align: center; padding: 0 30pt;
">
  {% if cover_logo %}
  <img src="{{ cover_logo }}" alt="logo" style="max-width: 120pt; max-height: 60pt; margin: 0 auto 30pt;">
  {% endif %}
  <div style="margin-bottom: 12pt; font-size: 8pt; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.5;">{{ cover_category or '' }}</div>
  <h1 class="no-break" style="font-size: 28pt; margin: 0 0 12pt; border: none;">{{ title }}</h1>
  {% if subtitle %}
  <div style="font-size: 14pt; opacity: 0.65; margin-bottom: 24pt;">{{ subtitle }}</div>
  {% endif %}
  <hr style="width: 60pt; border: 1pt solid currentColor; opacity: 0.25; margin: 0 auto 24pt;">
  {% if author %}
  <div style="font-size: 10.5pt; margin-bottom: 4pt;">{{ author }}</div>
  {% endif %}
  {% if date %}
  <div style="font-size: 9pt; opacity: 0.5;">{{ date }}</div>
  {% endif %}
</div>
{% endif %}

{% if toc_html %}
<div class="toc">
<strong style="font-size:10.5pt; display:block; margin-bottom:8pt;">Table of Contents</strong>
{{ toc_html }}
</div>
{% endif %}

{{ body }}
</body>
</html>
"""

# ─────────────────────────────────────────────────────────────
# FRONT MATTER PARSER
# ─────────────────────────────────────────────────────────────
FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
MERMAID_BLOCK_RE = re.compile(r"```mermaid[ \t]*\n(.*?)```", re.DOTALL | re.IGNORECASE)


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """Extract YAML-like front matter (Key: Value per line)."""
    meta: dict = {}
    m = FRONTMATTER_RE.match(text)
    if not m:
        return meta, text
    block = m.group(1)
    for line in block.splitlines():
        if ":" in line:
            key, _, val = line.partition(":")
            meta[key.strip().lower()] = val.strip()
    return meta, text[m.end() :]


def preprocess_mermaid_blocks(text: str) -> tuple[str, bool]:
    """
    Convert fenced Mermaid blocks into <div class="mermaid"> ... </div>
    so Playwright + MermaidJS can render diagrams before exporting PDF.
    """
    has_mermaid = False

    def _replace(match: re.Match[str]) -> str:
        nonlocal has_mermaid
        has_mermaid = True
        code = match.group(1).strip()
        code_escaped = html_lib.escape(code)
        code_attr = html_lib.escape(code, quote=True)
        # Escape HTML-sensitive chars but preserve diagram syntax text.
        return (
            '<div class="mermaid-block">'
            f'<div class="mermaid" data-mermaid-source="{code_attr}">{code_escaped}</div>'
            "</div>"
        )

    return MERMAID_BLOCK_RE.sub(_replace, text), has_mermaid


# ─────────────────────────────────────────────────────────────
# CORE CONVERTER
# ─────────────────────────────────────────────────────────────
def convert(
    input_file: str,
    output_file: str,
    *,
    title: str | None = None,
    subtitle: str | None = None,
    author: str | None = None,
    date: str | None = None,
    lang: str | None = None,
    theme: str | None = None,
    extra_css: str | None = None,
    cover: bool = False,
    cover_logo: str | None = None,
    cover_category: str | None = None,
    toc: bool = False,
    watermark: str | None = None,
    engine: str = "auto",
    no_link_url: bool = False,
    mermaid_theme: str = "default",
) -> None:
    src = Path(input_file)
    if not src.exists():
        print(f"[error] File not found: {input_file}", file=sys.stderr)
        sys.exit(1)

    raw = src.read_text(encoding="utf-8")

    # Front matter — CLI args win when given, else front matter, else default.
    fm, raw = parse_frontmatter(raw)
    title = title or fm.get("title") or src.stem
    subtitle = subtitle or fm.get("subtitle")
    author = author or fm.get("author")
    date = date or fm.get("date") or datetime.today().strftime("%B %d, %Y")
    lang = lang or fm.get("lang") or "vi"
    theme = theme or fm.get("theme") or "default"
    watermark = watermark or fm.get("watermark")
    cover_logo = cover_logo or fm.get("logo")
    cover_category = cover_category or fm.get("category")
    if fm.get("cover", "").lower() in ("true", "yes", "1"):
        cover = True
    if fm.get("toc", "").lower() in ("true", "yes", "1"):
        toc = True

    # Escape user-supplied metadata — template autoescape is off, and these land
    # in HTML text, an HTML attribute, or a CSS string.
    title = html_lib.escape(title)
    subtitle = html_lib.escape(subtitle) if subtitle else subtitle
    author = html_lib.escape(author) if author else author
    date = html_lib.escape(date) if date else date
    cover_category = html_lib.escape(cover_category) if cover_category else cover_category
    cover_logo = html_lib.escape(cover_logo, quote=True) if cover_logo else cover_logo
    if watermark:
        # CSS string context (and inside <style>): neutralise quotes/backslash and
        # any stray tag that could end the style element.
        watermark = re.sub(r"[<>]", "", watermark).replace("\\", "\\\\").replace('"', '\\"')

    # Mermaid preprocess (before Markdown conversion)
    raw, has_mermaid = preprocess_mermaid_blocks(raw)

    # Markdown → HTML
    md = markdown.Markdown(
        extensions=DEFAULT_EXTENSIONS,
        extension_configs=EXTENSION_CONFIGS,
        output_format="html5",
    )
    body = md.convert(raw)

    # TOC
    toc_html = ""
    if toc and hasattr(md, "toc"):
        toc_html = md.toc  # type: ignore[attr-defined]

    # Strip printed URLs if requested
    if no_link_url:
        extra_css = (extra_css or "") + "\na[href]::after { content: none !important; }"

    # Theme CSS
    if theme in THEMES:
        theme_css = THEMES[theme]
    else:
        theme_path = Path(theme)
        if theme_path.exists():
            theme_css = theme_path.read_text(encoding="utf-8")
        else:
            print(f"[warn] Theme '{theme}' not found, using default.", file=sys.stderr)
            theme_css = THEMES["default"]

    # Extra CSS
    extra_css_content = ""
    if extra_css:
        p = Path(extra_css)
        if p.exists():
            extra_css_content = p.read_text(encoding="utf-8")
        else:
            print(f"[warn] CSS file not found: {extra_css}", file=sys.stderr)

    # Mermaid layout polish (applied for all themes)
    mermaid_css = """
.mermaid-block {
    margin: 12pt 0;
    page-break-inside: avoid;
    break-inside: avoid;
    text-align: center;
    width: 100%;
    overflow: hidden;
}
.mermaid {
    display: block;
    width: 100%;
    margin: 0 auto;
    page-break-inside: avoid;
    break-inside: avoid;
}
.mermaid svg {
    display: block;
    width: auto !important;
    height: auto !important;
    max-width: 70% !important;
    max-height: 70vh !important;
    margin: 0 auto;
    page-break-inside: avoid;
    break-inside: avoid;
}
.mermaid-error {
    text-align: left;
    white-space: pre-wrap;
}
"""
    extra_css_content += "\n" + mermaid_css

    # Render HTML via Jinja2
    env = Environment(loader=BaseLoader())
    tmpl = env.from_string(HTML_TEMPLATE)
    html = tmpl.render(
        lang=lang,
        title=title,
        subtitle=subtitle,
        author=author,
        date=date,
        base_href=src.resolve().parent.as_uri().rstrip("/") + "/",
        theme_css=theme_css,
        extra_css=extra_css_content,
        watermark=watermark,
        cover=cover,
        cover_logo=cover_logo,
        cover_category=cover_category,
        toc_html=toc_html,
        body=body,
    )

    # Write PDF
    base_dir = str(src.resolve().parent)
    _write_pdf(html, base_dir, output_file, engine, has_mermaid, mermaid_theme)
    print(f"[ok] {input_file} -> {output_file}")


# ─────────────────────────────────────────────────────────────
# PDF ENGINES
# ─────────────────────────────────────────────────────────────
def _write_pdf_weasyprint(html: str, base_dir: str, out: str) -> None:
    from weasyprint import HTML as WP_HTML

    WP_HTML(string=html, base_url=base_dir).write_pdf(out)


def _write_pdf_playwright(
    html: str,
    base_dir: str,
    out: str,
    *,
    has_mermaid: bool = False,
    mermaid_theme: str = "default",
) -> None:
    try:
        from playwright.sync_api import sync_playwright
    except ImportError as e:
        raise RuntimeError(
            "Install playwright: pip install playwright && playwright install chromium"
        ) from e

    tmp = Path(base_dir) / f".md2pdf_tmp_{os.getpid()}.html"
    tmp.write_text(html, encoding="utf-8")
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page()
            page.goto(tmp.resolve().as_uri(), wait_until="networkidle")
            if has_mermaid:
                # Capture original Mermaid definitions before MermaidJS may auto-process nodes.
                page.evaluate(
                    """() => {
                        const nodes = Array.from(document.querySelectorAll(".mermaid"));
                        for (const el of nodes) {
                            if (!el.dataset.mermaidSource || !el.dataset.mermaidSource.trim()) {
                                el.dataset.mermaidSource = (el.textContent || "").trim();
                            }
                        }
                    }"""
                )
                page.add_script_tag(
                    url="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"
                )
                page.evaluate(
                    """async (theme) => {
                        if (!window.mermaid) return;
                        mermaid.initialize({
                            startOnLoad: false,
                            securityLevel: "loose",
                            theme: theme,
                            themeVariables: {
                                fontSize: "16px"
                            },
                            flowchart: { useMaxWidth: true, htmlLabels: true },
                            sequence: { useMaxWidth: true },
                            gantt: { useMaxWidth: true }
                        });
                        const nodes = Array.from(document.querySelectorAll(".mermaid"));
                        for (let i = 0; i < nodes.length; i += 1) {
                            const el = nodes[i];
                            const id = `mermaid-diagram-${i}-${Date.now()}`;
                            const graphDefinition = (el.dataset.mermaidSource || el.textContent || "").trim();
                            if (!graphDefinition) continue;
                            try {
                                const { svg, bindFunctions } = await mermaid.render(id, graphDefinition);
                                el.innerHTML = svg;
                                const svgEl = el.querySelector("svg");
                                if (svgEl) {
                                    const widthAttr = parseFloat((svgEl.getAttribute("width") || "").replace("px", ""));
                                    const heightAttr = parseFloat((svgEl.getAttribute("height") || "").replace("px", ""));
                                    if (!svgEl.getAttribute("viewBox") && Number.isFinite(widthAttr) && Number.isFinite(heightAttr) && widthAttr > 0 && heightAttr > 0) {
                                        svgEl.setAttribute("viewBox", `0 0 ${widthAttr} ${heightAttr}`);
                                    }
                                    svgEl.removeAttribute("width");
                                    svgEl.removeAttribute("height");
                                    svgEl.setAttribute("preserveAspectRatio", "xMidYMin meet");

                                    const viewBox = svgEl.viewBox && svgEl.viewBox.baseVal ? svgEl.viewBox.baseVal : null;
                                    const vbWidth = viewBox && viewBox.width ? viewBox.width : (Number.isFinite(widthAttr) ? widthAttr : 0);
                                    const vbHeight = viewBox && viewBox.height ? viewBox.height : (Number.isFinite(heightAttr) ? heightAttr : 0);
                                    const containerWidth = el.clientWidth || 900;
                                    const maxPrintableHeight = 900; // px in Chromium print context
                                    const maxWidth = containerWidth * 0.7;
                                    const maxHeight = maxPrintableHeight * 0.7;

                                    let targetWidth = maxWidth;
                                    if (vbWidth > 0 && vbHeight > 0) {
                                        const estimatedHeight = targetWidth * (vbHeight / vbWidth);
                                        if (estimatedHeight > maxHeight) {
                                            targetWidth = maxHeight * (vbWidth / vbHeight);
                                        }
                                    }

                                    targetWidth = Math.min(maxWidth, Math.max(220, targetWidth));
                                    svgEl.style.width = `${targetWidth}px`;
                                    svgEl.style.height = "auto";
                                    svgEl.style.maxWidth = "70%";
                                    svgEl.style.maxHeight = "70vh";
                                    svgEl.style.margin = "0 auto";
                                }
                                if (bindFunctions) bindFunctions(el);
                            } catch (err) {
                                el.innerHTML = `<pre class="mermaid-error">Mermaid render failed: ${String(err)}</pre>`;
                            }
                        }
                    }""",
                    mermaid_theme,
                )
                page.wait_for_timeout(450)

            page.emulate_media(media="print")
            # Margins come from the CSS @page rules (same as WeasyPrint). Passing a
            # margin here too would stack on top of those and double the page margin.
            page.pdf(
                path=out,
                format="A4",
                print_background=True,
                prefer_css_page_size=True,
                margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
            )
            browser.close()
    finally:
        try:
            tmp.unlink()
        except OSError:
            pass


def _write_pdf(
    html: str,
    base_dir: str,
    out: str,
    engine: str,
    has_mermaid: bool = False,
    mermaid_theme: str = "default",
) -> None:
    engine = engine.lower()

    if engine == "weasyprint":
        if has_mermaid:
            print(
                "[info] Mermaid detected. Using Playwright for Mermaid rendering.",
                file=sys.stderr,
            )
            _write_pdf_playwright(
                html,
                base_dir,
                out,
                has_mermaid=True,
                mermaid_theme=mermaid_theme,
            )
            return
        _write_pdf_weasyprint(html, base_dir, out)
        return

    if engine == "playwright":
        _write_pdf_playwright(
            html,
            base_dir,
            out,
            has_mermaid=has_mermaid,
            mermaid_theme=mermaid_theme,
        )
        return

    # auto: prefer playwright when Mermaid is present
    if has_mermaid:
        print(
            "[info] Mermaid detected. Auto engine selects Playwright.",
            file=sys.stderr,
        )
        _write_pdf_playwright(
            html,
            base_dir,
            out,
            has_mermaid=True,
            mermaid_theme=mermaid_theme,
        )
        return

    # auto: try weasyprint first, then fallback to playwright
    try:
        _write_pdf_weasyprint(html, base_dir, out)
    except Exception as we:
        print(f"[warn] WeasyPrint failed ({we}), trying Playwright…", file=sys.stderr)
        try:
            _write_pdf_playwright(
                html,
                base_dir,
                out,
                has_mermaid=False,
                mermaid_theme=mermaid_theme,
            )
        except Exception as pe:
            print("[error] Both engines failed.", file=sys.stderr)
            print(f"  WeasyPrint : {we}", file=sys.stderr)
            print(f"  Playwright : {pe}", file=sys.stderr)
            sys.exit(1)


# ─────────────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────────────
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="md2pdf",
        description="Convert Markdown to PDF — production-grade, template-aware.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
        Examples:
          md2pdf report.md
          md2pdf report.md -o out/report.pdf --theme client-report --cover
          md2pdf report.md --toc --watermark DRAFT --lang vi
          md2pdf report.md --theme dark --no-link-url
          md2pdf report.md --author "Nguyen Van A" --date "2025-01-01"

        Front matter (inside .md file):
          ---
          title: My Report
          author: Nguyen Van A
          date: 2025-01-15
          theme: client-report
          cover: true
          toc: true
          watermark: CONFIDENTIAL
          ---

        Available themes: default, client-report, minimal, dark, <path/to/custom.css>
        """),
    )

    p.add_argument("input", nargs="?", help="Input .md file")
    p.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output .pdf path (default: same name as input)",
    )

    grp_meta = p.add_argument_group("document metadata")
    grp_meta.add_argument("--title", default=None, help="Document title")
    grp_meta.add_argument("--subtitle", default=None, help="Subtitle (cover page)")
    grp_meta.add_argument("--author", default=None, help="Author name")
    grp_meta.add_argument("--date", default=None, help="Date string")
    grp_meta.add_argument(
        "--lang", default=None, help="HTML lang attribute (default: vi, or front-matter)"
    )

    grp_style = p.add_argument_group("styling")
    grp_style.add_argument(
        "--theme",
        default=None,
        metavar="NAME|PATH",
        help="Built-in theme (default, client-report, minimal, dark) or path to custom .css",
    )
    grp_style.add_argument(
        "--css",
        default=None,
        dest="extra_css",
        help="Additional CSS file (appended on top of theme)",
    )
    grp_style.add_argument(
        "--no-link-url", action="store_true", help="Don't print URLs after hyperlinks"
    )
    grp_style.add_argument(
        "--mermaid-theme",
        default="default",
        choices=["default", "neutral", "dark", "forest", "base"],
        help="Mermaid theme used when rendering diagrams (Playwright)",
    )

    grp_layout = p.add_argument_group("layout")
    grp_layout.add_argument("--cover", action="store_true", help="Generate cover page")
    grp_layout.add_argument(
        "--logo",
        default=None,
        dest="cover_logo",
        help="Logo image for cover page (path or URL)",
    )
    grp_layout.add_argument(
        "--category",
        default=None,
        dest="cover_category",
        help="Category/type label on cover page",
    )
    grp_layout.add_argument(
        "--toc", action="store_true", help="Insert Table of Contents"
    )
    grp_layout.add_argument(
        "--watermark", default=None, help="Watermark text (e.g. DRAFT, CONFIDENTIAL)"
    )

    grp_eng = p.add_argument_group("engine")
    grp_eng.add_argument(
        "--engine",
        default="auto",
        choices=["auto", "weasyprint", "playwright"],
        help="PDF render engine (default: auto → weasyprint then playwright)",
    )

    p.add_argument(
        "--list-themes", action="store_true", help="List available themes and exit"
    )

    return p


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.list_themes:
        print("Available themes:")
        for name in THEMES:
            print(f"  {name}")
        print("  <path/to/custom.css>   (any CSS file)")
        sys.exit(0)

    if not args.input:
        parser.print_usage()
        print("md2pdf: error: the following arguments are required: input")
        sys.exit(1)

    output = args.output or str(Path(args.input).with_suffix(".pdf"))

    convert(
        input_file=args.input,
        output_file=output,
        title=args.title,
        subtitle=args.subtitle,
        author=args.author,
        date=args.date,
        lang=args.lang,
        theme=args.theme,
        extra_css=args.extra_css,
        cover=args.cover,
        cover_logo=args.cover_logo,
        cover_category=args.cover_category,
        toc=args.toc,
        watermark=args.watermark,
        engine=args.engine,
        no_link_url=args.no_link_url,
        mermaid_theme=args.mermaid_theme,
    )


if __name__ == "__main__":
    main()
