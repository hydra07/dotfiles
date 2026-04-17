#!/usr/bin/env python3
import sys
import stat
from pathlib import Path


def main() -> None:
    # Resolve absolute paths
    script_path = Path(__file__).resolve()
    tool_dir = script_path.parent.parent
    bin_dir = tool_dir.parent / "bin"
    bin_dir.mkdir(exist_ok=True)

    is_win = sys.platform == "win32"

    print(f"[[Info]] Auto-releasing scripts from [{tool_dir.name}]...")
    released_count = 0

    for py_file in tool_dir.glob("*.py"):
        if py_file.name == "release.py":
            continue

        cmd = py_file.stem
        # Get absolute path to the python file to avoid "file not found" errors
        abs_py_path = py_file.resolve()

        if is_win:
            # WINDOWS FINAL FIX:
            # Use 'mise exec' to load the environment, then 'uv run' to execute the absolute path
            wrapper = bin_dir / f"{cmd}.cmd"
            abs_py_path = py_file.resolve()
            venv_python = tool_dir / ".venv" / "Scripts" / "python.exe"
            content = f'@echo off\n"{venv_python}" "{abs_py_path}" %*\n'
            wrapper.write_text(content, encoding="utf-8")
        else:
            # UNIX FINAL FIX
            wrapper = bin_dir / f"{cmd}"
            content = f'#!/usr/bin/env bash\nexec mise exec -C "{tool_dir}" -- uv run python "{abs_py_path}" "$@"\n'
            wrapper.write_text(content, encoding="utf-8", newline="\n")
            wrapper.chmod(
                wrapper.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
            )

        print(f"  [[Success]] Exported: {wrapper.name}")
        released_count += 1

    if released_count == 0:
        print("  [[Warning]] No .py files found!")
    else:
        print(f"[[Success]] Successfully released {released_count} tool(s).")


if __name__ == "__main__":
    main()
