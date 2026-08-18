# ~/.config/fish/functions/pyscript.fish
function pyscript --description 'Create uv single-file script'
    argparse 'p/python=' 'b/bin' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: pyscript [-p VER] [-b] <name> [lib...]"
        echo "  -p/--python  requires-python (default 3.13)"
        echo "  -b/--bin     create in ~/.local/bin"
        echo "  name         script filename"
        echo "  lib...       deps to embed (space-separated)"
        echo ""
        echo "Example: pyscript fetch -p 3.13 requests rich"
        return 0
    end

    set -l name $argv[1]
    test -z "$name"; and set name "script.py"
    string match -q "*.py" $name; or set name "$name.py"

    set -l libs $argv[2..-1]

    set -l pyver 3.13
    set -q _flag_python; and set pyver $_flag_python

    set -q _flag_bin; and set name "$HOME/.local/bin/"(basename $name)

    if test -e $name
        echo "$name already exists"; return 1
    end

    set -l depline ""
    if test (count $libs) -gt 0
        set depline (printf '"%s", ' $libs | string trim -r -c ', ')
    end

    printf '%s\n' \
        '#!/usr/bin/env -S uv run --script' \
        '# /// script' \
        "# requires-python = \">=$pyver\"" \
        "# dependencies = [$depline]" \
        '# ///' \
        '' '' > $name
    chmod +x $name

    set_color green; echo "created $name"; set_color normal
    test (count $libs) -gt 0; and echo "deps: $libs"
    echo ""
    echo "Run:  uv run $name   |   ./$name"
    echo "Add more:  uv add --script $name <pkg>"

    test -n "$EDITOR"; and $EDITOR $name
end
