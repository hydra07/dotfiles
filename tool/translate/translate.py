#!/usr/bin/env python3
"""
translate.py — Fast async Markdown/text translator
Backend: Google Translate (unofficial, no key needed)
Speed:   Async concurrent requests + smart batching

Install:
  pip install httpx deep-translator

Usage:
  translate.py 'text here' -o vi
  translate.py -f doc.md -o vi
  translate.py -f doc.md -o en -s ja -w 20 -v
  translate.py --list-langs
"""

from __future__ import annotations

import argparse
import asyncio
import re
import sys
import time
from collections import defaultdict
from pathlib import Path

# ── runtime imports ────────────────────────────────────────────────────────────
# Only httpx is needed to translate; deep-translator is imported lazily, solely
# for `--list-langs` (see main()), so a missing/heavy dep never blocks a run.
try:
    import httpx  # type: ignore[import-untyped]
except ImportError:
    sys.exit("❌  httpx not found: pip install httpx")


# ══════════════════════════════════════════════════════════════════════════════
# Language aliases  (vn→vi, jp→ja, ...)
# ══════════════════════════════════════════════════════════════════════════════
LANG_ALIASES: dict[str, str] = {
    "vn": "vi", "jp": "ja", "kr": "ko", "cn": "zh-CN",
    "tw": "zh-TW", "br": "pt", "cz": "cs", "gr": "el",
}

def resolve_lang(code: str) -> str:
    return LANG_ALIASES.get(code.lower(), code.lower())


# ══════════════════════════════════════════════════════════════════════════════
# Async Google Translate
# ══════════════════════════════════════════════════════════════════════════════
GOOGLE_URL = "https://translate.googleapis.com/translate_a/single"

async def _translate_one(
    client: httpx.AsyncClient,
    text: str,
    source: str,
    target: str,
    sem: asyncio.Semaphore,
    retries: int = 4,
) -> str:
    if not text.strip():
        return text
    params = {"client": "gtx", "sl": source, "tl": target, "dt": "t", "q": text}
    async with sem:
        for attempt in range(retries):
            try:
                r = await client.get(GOOGLE_URL, params=params, timeout=15)
                if r.status_code == 429:
                    await asyncio.sleep(2 ** attempt)
                    continue
                r.raise_for_status()
                data = r.json()
                return "".join(c[0] for c in data[0] if c[0]) or text
            except (httpx.TimeoutException, httpx.NetworkError):
                if attempt < retries - 1:
                    await asyncio.sleep(1.5 ** attempt)
            except Exception:
                if attempt < retries - 1:
                    await asyncio.sleep(1)
        return text


async def translate_batch_async(
    texts: list[str],
    source: str,
    target: str,
    workers: int = 15,
) -> list[str]:
    sem = asyncio.Semaphore(workers)
    limits = httpx.Limits(max_connections=workers + 5, max_keepalive_connections=workers)
    async with httpx.AsyncClient(
        http2=True,
        limits=limits,
        headers={"User-Agent": "Mozilla/5.0"},
    ) as client:
        return list(await asyncio.gather(
            *[_translate_one(client, t, source, target, sem) for t in texts]
        ))


# ══════════════════════════════════════════════════════════════════════════════
# Markdown segmenter
#
# Rules (in priority order):
#   KEEP  — YAML front matter block
#   KEEP  — fenced code blocks  (``` or ~~~)
#   KEEP  — table separator rows  (|---|:---:|)
#   KEEP  — horizontal rules  (---, ***, ___)  outside front matter
#   KEEP  — HTML blocks / comments  (<tag>, <!-- ... -->)
#   KEEP  — blank lines
#   XLATE — everything else (headings, paragraphs, lists, blockquotes, table cells)
# ══════════════════════════════════════════════════════════════════════════════

FENCE_RE    = re.compile(r"^(`{3,}|~{3,})")
FRONTMATTER = re.compile(r"^---\s*$")
HR_RE       = re.compile(r"^(\*{3,}|-{3,}|_{3,})\s*$")
HTML_RE     = re.compile(r"^\s*(<[a-zA-Z!/?]|<!--)")
PIPE_RE     = re.compile(r"(?<!\\)\|")
HEADING_RE  = re.compile(r"^(#{1,6}\s)(.*)")
LIST_RE     = re.compile(r"^(\s*(?:[*+\-]|\d+\.)\s)(.*)")  # captures marker + content


def _is_sep_row(s: str) -> bool:
    cells = [c.strip() for c in PIPE_RE.split(s) if c.strip()]
    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", c) for c in cells)


def split_segments(text: str) -> list[tuple[str, bool]]:
    """
    Returns [(raw_line, translatable), ...].
    translatable=False → output verbatim.
    """
    lines = text.splitlines(keepends=True)
    segs: list[tuple[str, bool]] = []
    in_fence   = False
    fence_mark = ""
    in_front   = False
    front_done = False

    for i, line in enumerate(lines):
        s = line.rstrip("\n\r")

        # ── YAML front matter ──────────────────────────────────────────────
        if i == 0 and FRONTMATTER.match(s):
            in_front = True
            segs.append((line, False))
            continue
        if in_front:
            segs.append((line, False))
            if FRONTMATTER.match(s) and not front_done:
                in_front = False
                front_done = True
            continue

        # ── Fenced code ────────────────────────────────────────────────────
        m = FENCE_RE.match(s)
        if m:
            if not in_fence:
                in_fence = True
                fence_mark = m.group(1)
            elif s.startswith(fence_mark):
                in_fence = False
                fence_mark = ""
            segs.append((line, False))
            continue
        if in_fence:
            segs.append((line, False))
            continue

        # ── Table separator ────────────────────────────────────────────────
        if _is_sep_row(s):
            segs.append((line, False))
            continue

        # ── Horizontal rule (--- / *** / ___) ─────────────────────────────
        if HR_RE.match(s):
            segs.append((line, False))
            continue

        # ── HTML blocks & comments ─────────────────────────────────────────
        if HTML_RE.match(s):
            segs.append((line, False))
            continue

        # ── Blank line ─────────────────────────────────────────────────────
        if not s.strip():
            segs.append((line, False))
            continue

        # ── Translatable ───────────────────────────────────────────────────
        segs.append((line, True))

    return segs


# ══════════════════════════════════════════════════════════════════════════════
# Job extraction
#
# For each translatable line we extract ONLY the text payload:
#   heading  →  strip "## " prefix, translate rest, restore prefix
#   list     →  strip "- " / "1. " marker, translate rest, restore marker
#   table    →  split cells, translate each non-empty cell individually
#   other    →  translate whole line (preserving inline markdown intact)
#
# Google Translate generally preserves **bold**, *italic*, `code`, [links]()
# because it treats them as markup tokens.  We do NOT strip inline syntax.
# ══════════════════════════════════════════════════════════════════════════════

# Job tuple: (seg_idx, prefix, content, eol, cell_part_idx | None)
Job = tuple[int, str, str, str, int | None]


def collect_jobs(segs: list[tuple[str, bool]]) -> list[Job]:
    jobs: list[Job] = []
    for idx, (line, translatable) in enumerate(segs):
        if not translatable:
            continue
        s   = line.rstrip("\n\r")
        eol = line[len(s):]

        # Table row (not a heading)
        if PIPE_RE.search(s) and not HEADING_RE.match(s):
            parts = PIPE_RE.split(s)
            for pi, p in enumerate(parts):
                cell = p.strip()
                if cell:
                    jobs.append((idx, "", cell, eol, pi))
            continue

        # Heading
        hm = HEADING_RE.match(s)
        if hm:
            content = hm.group(2).strip()
            if content:
                jobs.append((idx, hm.group(1), content, eol, None))
            continue

        # List item — strip marker so Google doesn't mangle "1." → "firstly"
        lm = LIST_RE.match(s)
        if lm:
            content = lm.group(2).strip()
            if content:
                jobs.append((idx, lm.group(1), content, eol, None))
            continue

        # Blockquote — keep "> " prefix
        if s.startswith(">"):
            # find where the actual text starts
            stripped = re.sub(r"^(>\s*)+", "", s)
            prefix   = s[:len(s) - len(stripped)]
            if stripped.strip():
                jobs.append((idx, prefix, stripped.strip(), eol, None))
            continue

        # Plain paragraph / everything else
        if s.strip():
            jobs.append((idx, "", s, eol, None))

    return jobs


# ══════════════════════════════════════════════════════════════════════════════
# Reassembly helpers
# ══════════════════════════════════════════════════════════════════════════════

def _rebuild_table_row(raw: str, cell_map: dict[int, str], eol: str) -> str:
    parts = PIPE_RE.split(raw.rstrip("\n\r"))
    rebuilt = []
    for i, p in enumerate(parts):
        if p.strip() and i in cell_map:
            lpad = len(p) - len(p.lstrip())
            rpad = len(p) - len(p.rstrip())
            rebuilt.append(" " * lpad + cell_map[i] + " " * rpad)
        else:
            rebuilt.append(p)
    return "|".join(rebuilt) + eol


# ══════════════════════════════════════════════════════════════════════════════
# Main translate pipeline
# ══════════════════════════════════════════════════════════════════════════════

async def translate_md_async(
    content: str,
    source: str,
    target: str,
    workers: int = 15,
    verbose: bool = False,
) -> str:
    segs = split_segments(content)
    jobs = collect_jobs(segs)

    if not jobs:
        return content

    texts = [j[2] for j in jobs]
    if verbose:
        print(f"  📦  {len(texts)} strings → translating (workers={workers})", file=sys.stderr)

    t0 = time.perf_counter()
    results = await translate_batch_async(texts, source, target, workers)
    elapsed = time.perf_counter() - t0
    if verbose:
        print(f"  ✅  {elapsed:.1f}s  ({len(texts)/max(elapsed,0.001):.0f} req/s)", file=sys.stderr)

    # build lookup tables
    seg_cells: dict[int, dict[int, str]] = defaultdict(dict)
    seg_line:  dict[int, tuple[str, str, str]] = {}

    for job, result in zip(jobs, results):
        idx, prefix, _content, eol, cell_pi = job
        if cell_pi is not None:
            seg_cells[idx][cell_pi] = result
        else:
            seg_line[idx] = (prefix, result, eol)

    # reassemble
    out: list[str] = []
    for idx, (line, translatable) in enumerate(segs):
        if not translatable:
            out.append(line)
            continue

        s   = line.rstrip("\n\r")
        eol = line[len(s):]

        if idx in seg_cells:
            out.append(_rebuild_table_row(s, seg_cells[idx], eol))
        elif idx in seg_line:
            prefix, translated, eol2 = seg_line[idx]
            out.append(prefix + translated + eol2)
        else:
            out.append(line)  # no content to translate (empty after strip)

    return "".join(out)


async def translate_plain_async(
    text: str,
    source: str,
    target: str,
    workers: int = 15,
    chunk: int = 4000,
    verbose: bool = False,
) -> str:
    # Split into paragraphs, keeping the exact blank-line separators between them.
    parts = re.split(r"(\n{2,})", text)
    paragraphs = parts[0::2]
    separators = parts[1::2]  # len == len(paragraphs) - 1

    # A long paragraph is broken into sentence-sized pieces for translation, but
    # those pieces belong to ONE paragraph — they get rejoined with a space, not
    # a blank line. Track how many pieces each paragraph owns so we can regroup.
    pieces_per_para: list[list[str]] = []
    flat: list[str] = []
    for para in paragraphs:
        if len(para) <= chunk:
            pieces = [para]
        else:
            pieces, buf = [], ""
            for s in re.split(r"(?<=[.!?。！？])\s+", para):
                if buf and len(buf) + len(s) + 1 > chunk:
                    pieces.append(buf)
                    buf = s
                else:
                    buf = f"{buf} {s}" if buf else s
            if buf:
                pieces.append(buf)
        pieces_per_para.append(pieces)
        flat.extend(pieces)

    if verbose:
        print(f"  📦  {len(paragraphs)} paragraphs / {len(flat)} chunks", file=sys.stderr)

    t0 = time.perf_counter()
    results = await translate_batch_async(flat, source, target, workers)
    if verbose:
        print(f"  ✅  {time.perf_counter()-t0:.1f}s", file=sys.stderr)

    # Regroup pieces into paragraphs, then restore the original separators.
    it = iter(results)
    translated = [" ".join(next(it) for _ in pieces) for pieces in pieces_per_para]

    out = translated[0] if translated else ""
    for sep, para in zip(separators, translated[1:]):
        out += sep + para
    return out


# ══════════════════════════════════════════════════════════════════════════════
# CLI
# ══════════════════════════════════════════════════════════════════════════════

def main() -> None:
    p = argparse.ArgumentParser(
        prog="translate",
        description="Fast async Markdown/text translator (Google, no key)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  translate 'hello world' -o vi
  translate -f README.md -o vi
  translate -f spec.md -o en -s ja -w 20 -v
  translate -f big.md -o vi --out big_vi.md -w 25
  translate --list-langs
""",
    )
    p.add_argument("text",          nargs="?",       help="Inline text to translate")
    p.add_argument("-f","--file",   metavar="FILE",  help="Input .md / .txt file")
    p.add_argument("-o","--target", metavar="LANG",  required=True, help="Target language (vi, en, ja ...)")
    p.add_argument("-s","--source", metavar="LANG",  default="auto", help="Source language (default: auto)")
    p.add_argument("--out",         metavar="FILE",  help="Output file (default: <name>_<lang>.md)")
    p.add_argument("-w","--workers",type=int, default=15, metavar="N",
                   help="Concurrent requests (default 15; max ~25 before rate-limit risk)")
    p.add_argument("--chunk",       type=int, default=4000, metavar="N",
                   help="Max chars per plain-text chunk (default 4000)")
    p.add_argument("--list-langs",  action="store_true", help="Print supported language codes")
    p.add_argument("-v","--verbose",action="store_true")
    args = p.parse_args()

    if args.list_langs:
        try:
            from deep_translator import GoogleTranslator  # type: ignore[import-untyped]
        except ImportError:
            sys.exit("❌  deep-translator not found (only needed for --list-langs): pip install deep-translator")
        for name, code in sorted(GoogleTranslator.get_supported_languages(as_dict=True).items()):
            print(f"  {code:<10} {name}")
        return

    if not args.text and not args.file:
        p.error("provide text or -f FILE")

    target = resolve_lang(args.target)
    source = resolve_lang(args.source) if args.source != "auto" else "auto"

    if args.text:
        results = asyncio.run(translate_batch_async([args.text], source, target, workers=1))
        print(results[0])
        return

    src = Path(args.file).expanduser()  # type: ignore[arg-type]
    if not src.exists():
        sys.exit(f"❌  Not found: {src}")

    content = src.read_text(encoding="utf-8")
    is_md   = src.suffix.lower() in (".md", ".mdx", ".markdown")

    if args.verbose:
        print(f"📄  {src}  ({len(content):,} chars, {'markdown' if is_md else 'plain'})", file=sys.stderr)

    t0 = time.perf_counter()
    if is_md:
        result = asyncio.run(translate_md_async(content, source, target, args.workers, args.verbose))
    else:
        result = asyncio.run(translate_plain_async(content, source, target, args.workers, args.chunk, args.verbose))

    out_path = Path(args.out) if args.out else src.with_name(f"{src.stem}_{target}{src.suffix}")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(result, encoding="utf-8")

    if args.verbose:
        print(f"⏱️   total {time.perf_counter()-t0:.1f}s → {out_path}", file=sys.stderr)
    else:
        print(out_path)


if __name__ == "__main__":
    main()
