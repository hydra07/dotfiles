if status is-interactive
    set fish_greeting ""
    set -gx TERM xterm-256color

    # THEME
    set -g theme_color_scheme terminal-dark
    set -g fish_prompt_pwd_dir_length 2
    set -g theme_display_user yes
    set -g theme_hide_hostname no
    set -g theme_hostname always

    set -gx EDITOR nvim

    # PATH (paths mise manages, e.g. pnpm/bun/node, go through `mise activate` below)
    fish_add_path -g ~/bin ~/.local/bin

    set -l cfg_dir (dirname (status --current-filename))

    # CONFIG OS
    switch (uname)
        case Linux
            source $cfg_dir/config-linux.fish
        case '*'
            source $cfg_dir/config-windows.fish
    end

    # KEYBINDING
    test -f $cfg_dir/keybinding.fish; and source $cfg_dir/keybinding.fish

    # THEMES
    test -f $cfg_dir/themes/catppuccin-fzf-mocha.fish; and source $cfg_dir/themes/catppuccin-fzf-mocha.fish

    # ACTIVATE
    # --shims: PATH only gets 1 static shims dir added, NOT hooked into every `cd`
    # (default mode re-execs `mise hook-env` on every directory change, ~40-60ms/time).
    # Still respects per-project .mise.toml — it just resolves the version when the tool runs.
    mise activate fish --shims | source

    # STARSHIP — cache the init script to a static file, avoid re-invoking the
    # binary + psub on every shell open (~14ms). Auto-regens when the starship binary is newer than the cache.
    set -l starship_bin (command -v starship)
    if test -n "$starship_bin"
        set -l cache_dir (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo ~/.cache)/fish
        set -l starship_cache $cache_dir/starship_init.fish
        if not test -f $starship_cache; or test $starship_bin -nt $starship_cache
            mkdir -p $cache_dir
            starship init fish --print-full-init >$starship_cache
        end
        source $starship_cache
    end
end
