set --universal fish_greeting

if status is-interactive
    atuin init fish | source
    zoxide init fish | source
    starship init fish | source

    # Shortcuts setup
    bind \cj zoxide_shortcut
    bind \cn yazi_interactive
    bind \cy copy_commandline_to_clipboard
    bind \ce quick_edit_scripts
end

source ~/.config/fish/abbreviations/common.fish
source ~/.config/fish/abbreviations/git.fish
