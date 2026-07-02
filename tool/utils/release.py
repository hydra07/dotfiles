#!/usr/bin/env python3
"""Generate tool/bin launchers for every tool under tool/.

A "tool" is any direct subdirectory of tool/ that has a pyproject.toml
(a uv project), excluding utils/ and bin/. Each top-level *.py in a tool
(except private _*.py helpers) becomes a launcher in tool/bin.

Wrappers use paths relative to their own location (%~dp0 on Windows,
$BASH_SOURCE on Unix) so the repo stays portable — clone it anywhere, on
any drive, and the launchers still resolve.

Usage:
  python utils/release.py            # release every tool (rebuilds bin/)
  python utils/release.py markdown   # release only the named tool(s)
"""
import stat
import sys
from pathlib import Path

EXCLUDE = {"bin", "utils"}


def write_wrapper(bin_dir: Path, tool: str, py_file: Path, is_win: bool) -> str:
    cmd = py_file.stem
    if is_win:
        wrapper = bin_dir / f"{cmd}.cmd"
        wrapper.write_text(
            "@echo off\r\n"
            f'"%~dp0..\\{tool}\\.venv\\Scripts\\python.exe" '
            f'"%~dp0..\\{tool}\\{py_file.name}" %*\r\n',
            encoding="utf-8",
        )
    else:
        wrapper = bin_dir / cmd
        wrapper.write_text(
            "#!/usr/bin/env bash\n"
            'here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"\n'
            f'exec mise exec -C "$here/../{tool}" -- '
            f'uv run python "$here/../{tool}/{py_file.name}" "$@"\n',
            encoding="utf-8",
            newline="\n",
        )
        wrapper.chmod(
            wrapper.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
        )
    return wrapper.name


def iter_tools(tool_root: Path):
    for d in sorted(tool_root.iterdir()):
        if not d.is_dir() or d.name.startswith(".") or d.name in EXCLUDE:
            continue
        if (d / "pyproject.toml").exists():
            yield d


def main() -> None:
    tool_root = Path(__file__).resolve().parent.parent
    bin_dir = tool_root / "bin"
    bin_dir.mkdir(exist_ok=True)
    is_win = sys.platform == "win32"

    only = set(sys.argv[1:])

    # Full rebuild: wipe stale launchers first (bin/ is purely generated).
    if not only:
        for f in bin_dir.iterdir():
            if f.is_file():
                f.unlink()

    total = 0
    for tool_dir in iter_tools(tool_root):
        if only and tool_dir.name not in only:
            continue
        print(f"[[Info]] Releasing [{tool_dir.name}]...")
        for py in sorted(tool_dir.glob("*.py")):
            if py.name.startswith("_"):
                continue
            name = write_wrapper(bin_dir, tool_dir.name, py, is_win)
            print(f"  [[Success]] {name}")
            total += 1

    if total == 0:
        print("[[Warning]] No tools released — nothing matched.")
    else:
        print(f"[[Done]] Released {total} launcher(s) into {bin_dir.name}/.")


if __name__ == "__main__":
    main()
