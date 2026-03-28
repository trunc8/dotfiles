# ~/dotfiles/zshrc
# Managed by dotfiles repo. No oh-my-zsh — plugins sourced directly.

# --- Completion system ---
autoload -Uz compinit
# Only regenerate .zcompdump once a day to avoid ~100ms penalty per launch
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# --- Plugins (sourced directly, no OMZ framework) ---
[ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

[ -f "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    && source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# --- Common config (env, tool init, aliases, secrets) ---
[ -f "$HOME/dotfiles/common.sh" ] && source "$HOME/dotfiles/common.sh"

# --- Zsh-specific settings ---
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INTERACTIVE_COMMENTS
HISTSIZE=20000
SAVEHIST=20000
HISTFILE=~/.zsh_history

# --- Keybindings (unified with bash) ---
bindkey '^[[1;5C' forward-word     # Ctrl+Right
bindkey '^[[1;5D' backward-word    # Ctrl+Left

# --- Machine-specific overrides (optional, not in dotfiles repo) ---
[ -f "$HOME/.local.sh" ] && source "$HOME/.local.sh"
