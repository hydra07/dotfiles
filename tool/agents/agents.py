#!/usr/bin/env python3
import sys
import time
from pathlib import Path
from ui.spinner import AgentUI

# Minimal config
IGNORE = {".git", ".venv", "node_modules", "bin", "__pycache__"}
EXTS = {".py", ".rs", ".lua", ".md", ".toml", ".yaml"}

ui = AgentUI()


def get_content(path: Path) -> str:
    """Efficiently grab text content."""
    try:
        if path.is_file() and path.suffix in EXTS:
            return f"\n### File: {path}\n```\n{path.read_text(encoding='utf-8')}\n```\n"
        if path.is_dir():
            return "".join(
                get_content(p)
                for p in path.rglob("*")
                if not any(i in p.parts for i in IGNORE)
                and p.is_file()
                and p.suffix in EXTS
            )
    except:
        pass
    return ""


def main():
    if len(sys.argv) < 2:
        ui.console.print("[dim]Usage: aa <msg> [path][/dim]")
        return

    # Phase 1: Context Gathering (Silent by default)
    args = sys.argv[1:]
    msg_parts, context = [], ""

    for arg in args:
        p = Path(arg)
        if p.exists():
            ui.notify_loading(arg)
            context += get_content(p)
        else:
            msg_parts.append(arg)

    query = " ".join(msg_parts)

    # Phase 2: Thinking (Single line spinner)
    with ui.start_thinking("Thinking") as status:
        # Simulate AI call
        time.sleep(2.5)
        # In production: response = call_llm(query, context)
        response = f"I've analyzed the context ({len(context)} chars). Here is your answer for: **{query}**"

    # Phase 3: Direct Output
    ui.display_response(response)


if __name__ == "__main__":
    main()
