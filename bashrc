# ~/dotfiles/bashrc
# Managed by dotfiles repo. Machine-specific additions go in ~/.local.sh

# --- Non-interactive shells: bail early ---
case $- in
    *i*) ;;
      *) return ;;
esac

# --- ble.sh: must be first with --noattach ---
if [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    source "$HOME/.local/share/blesh/ble.sh" --noattach
fi

# --- Common config (env, tool init, aliases, secrets) ---
[ -f "$HOME/dotfiles/common.sh" ] && source "$HOME/dotfiles/common.sh"

# --- Bash-specific settings ---
shopt -s histappend
HISTSIZE=20000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth

# --- FZF via ble.sh contrib (avoids keybinding conflicts) ---
if [[ ${BLE_VERSION-} ]]; then
    ble-import -d contrib/fzf-completion
    ble-import -d contrib/fzf-key-bindings
fi

# --- Keybindings (unified with zsh) ---
bind '"\e[1;5C": forward-word'   # Ctrl+Right
bind '"\e[1;5D": backward-word'  # Ctrl+Left

# --- Machine-specific overrides (optional, not in dotfiles repo) ---
[ -f "$HOME/.local.sh" ] && source "$HOME/.local.sh"

# --- ble.sh: must be last ---
[[ ${BLE_VERSION-} ]] && ble-attach
