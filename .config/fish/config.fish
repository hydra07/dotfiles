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

    # PATH
    set -gx PATH bin $PATH
    set -gx PATH ~/bin $PATH
    set -gx PATH ~/.local/bin $PATH
    set -gx PATH ~/.bun/bin $PATH

    # CONFIG OS
    switch (uname)
        case Linux
            source (dirname (status --current-filename))/config-linux.fish
        case '*'
            source (dirname (status --current-filename))/config-windows.fish
    end

    # KEYBINDING
    test -f (dirname (status --current-filename))/keybinding.fish; and source (dirname (status --current-filename))/keybinding.fish

    # THEMES
    test -f (dirname (status --current-filename))/themes/catppuccin-fzf-mocha.fish; and source (dirname (status --current-filename))/themes/catppuccin-fzf-mocha.fish

    # ACTIVATE
    mise activate fish | source
    starship init fish | source
end

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not contains $PNPM_HOME $PATH
  set -gx PATH $PNPM_HOME $PATH
end
