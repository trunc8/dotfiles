# ~/dotfiles/common.sh
# Sourced by both bashrc and zshrc. Must be shell-agnostic.
# Aliases and functions live in ~/dotfiles/aliases (sourced at the end).

# --- Environment ---
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='vim'
export LESS='-R --mouse --wheel-lines=3'
DOTFILES_DIR="$HOME/dotfiles"

# If /tmp is not writable, use ~/.tmp
if ! [ -w /tmp ]; then
    export TMPDIR="$HOME/.tmp"
    mkdir -p "$HOME/.tmp"
fi

# --- Detect the running shell (not $SHELL, which is the login shell) ---
if [ -n "$BASH_VERSION" ]; then
    _current_shell="bash"
elif [ -n "$ZSH_VERSION" ]; then
    _current_shell="zsh"
fi

# --- Tool Initialization ---

# Starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init "$_current_shell")"
fi

# Zoxide: --cmd cd replaces cd with a zoxide-aware wrapper so it learns
# from regular cd usage. Unlike a raw alias, this preserves cd -, cd .., etc.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init "$_current_shell" --cmd cd)"
fi

# --- FZF ---
# In bash with ble.sh, fzf integration is handled via ble.sh contrib
# to avoid keybinding conflicts. This block only runs in zsh or
# bash without ble.sh.
if [ -z "${BLE_VERSION:-}" ]; then
    if [ -d "$HOME/.fzf" ]; then
        _fzf_base="$HOME/.fzf/shell"
    fi
    if [ -n "${_fzf_base:-}" ]; then
        [ -f "$_fzf_base/key-bindings.${_current_shell}" ] && source "$_fzf_base/key-bindings.${_current_shell}"
        [ -f "$_fzf_base/completion.${_current_shell}" ] && source "$_fzf_base/completion.${_current_shell}"
    fi
    unset _fzf_base
fi

# --- Aliases and functions ---
[ -f "$DOTFILES_DIR/aliases" ] && source "$DOTFILES_DIR/aliases"

# --- Secrets (tokens, keys — chmod 600 enforced by setup_links.sh) ---
[ -f "$HOME/.secrets.env" ] && source "$HOME/.secrets.env"

# NOTE: must stay after 'source aliases' — aliases expand _current_shell at source time
unset _current_shell

# --- Auto-pull dotfiles (background, every 4 hours) ---
_autopull() {
    local name="$1"
    local repo_dir="$2"
    local stamp="$HOME/.${name}_last_pull"
    local fail_marker="$HOME/.${name}_pull_failed"
    local now
    local last
    local age
    now=$(date +%s)
    if [ -f "$stamp" ]; then
        last=$(command cat "$stamp")
        age=$(( now - last ))
        [ "$age" -lt 14400 ] && return
    fi
    (
        if git -C "$repo_dir" pull --ff-only >/dev/null 2>&1; then
            echo "$now" > "$stamp"
            rm -f "$fail_marker"
        else
            echo "$now" > "$fail_marker"
        fi
    ) &
}
_autopull dotfiles "$DOTFILES_DIR"
unset -f _autopull

# --- Warn once per session if a previous auto-pull failed ---
if [ -f "$HOME/.dotfiles_pull_failed" ]; then
    echo "[warn] dotfiles auto-pull failed — run: git -C ~/dotfiles pull"
fi
