# ~/.config/fish/completions/pyscript.fish
complete -c pyscript -f
complete -c pyscript -s p -l python -x -a "3.11 3.12 3.13 3.14" -d "requires-python"
complete -c pyscript -s b -l bin  -d "create in ~/.local/bin"
complete -c pyscript -s h -l help -d "show help"

set -l __pyscript_libs \
    requests httpx rich typer click pydantic \
    pandas numpy polars matplotlib \
    beautifulsoup4 lxml pyyaml python-dotenv \
    sqlalchemy fastapi uvicorn pillow tqdm

complete -c pyscript -f \
    -n 'test (count (commandline -opc)) -ge 2' \
    -a "$__pyscript_libs" -d "lib"
