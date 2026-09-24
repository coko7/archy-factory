# Only set these once, in the login shell; children inherit them
status is-login; or return

set --global --export EDITOR nvim
set --global --export VISUAL nvim
set --global --export PAGER less
set --global --export MANPAGER "nvim +Man!"

# XDG base dirs
set --global --export XDG_CONFIG_HOME $HOME/.config
set --global --export XDG_DATA_HOME $HOME/.local/share
set --global --export XDG_CACHE_HOME $HOME/.cache
set --global --export XDG_STATE_HOME $HOME/.local/state

# Tools that respect XDG via env vars
set --global --export CARGO_HOME $XDG_DATA_HOME/cargo
set --global --export RUSTUP_HOME $XDG_DATA_HOME/rustup

# PATH: use fish_add_path instead of manipulating $PATH by hand
fish_add_path --global $CARGO_HOME/bin $HOME/.local/bin
