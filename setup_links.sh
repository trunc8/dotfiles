#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
DID_BACKUP=false

echo "=== Dotfiles Setup ==="

# --- Prerequisite checks ---
echo "[0/7] Checking prerequisites..."
_prereq_warn=0

if ! command -v git &>/dev/null; then
    echo "  ERROR: git is not installed. Install it first: sudo apt install git"
    exit 1
fi

if ! command -v zsh &>/dev/null; then
    echo "  WARN: zsh not found. Install it: sudo apt install zsh"
    _prereq_warn=1
fi

if ! command -v starship &>/dev/null; then
    echo "  WARN: starship not found. Run ./install_linux.sh first."
    _prereq_warn=1
fi

if command -v fc-list &>/dev/null; then
    if ! fc-list 2>/dev/null | grep -qi "Nerd"; then
        echo "  WARN: No Nerd Font detected. Icons in starship/eza will be broken."
        echo "        Run ./install_linux.sh to install JetBrainsMono Nerd Font,"
        echo "        then set your terminal font to 'JetBrainsMono Nerd Font'."
        _prereq_warn=1
    fi
else
    echo "  WARN: fc-list not found, cannot check for Nerd Font."
    _prereq_warn=1
fi

if [ "$_prereq_warn" -eq 0 ]; then
    echo "  All prerequisites met."
fi
echo ""

# --- Backup existing configs ---
backup_if_exists() {
    local target="$1"
    # Only backup real files/dirs, not existing symlinks to our dotfiles
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local relpath="${target#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$relpath")"
        cp -r "$target" "$BACKUP_DIR/$relpath"
        DID_BACKUP=true
        echo "  Backed up: $target -> $BACKUP_DIR/$relpath"
    fi
}

echo "[1/7] Backing up existing configs..."
backup_if_exists "$HOME/.bashrc"
backup_if_exists "$HOME/.bash_profile"
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.aliases"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.config/yazi/yazi.toml"
backup_if_exists "$HOME/.config/alacritty"
backup_if_exists "$HOME/.config/dunst"
backup_if_exists "$HOME/.config/i3"

# Orphaned files: back up and remove (no longer sourced by new dotfiles)
ORPHAN_FILES=(
    "$HOME/.tmux.conf.local"
    "$HOME/.fzf.zsh"
)
for orphan in "${ORPHAN_FILES[@]}"; do
    if [ -e "$orphan" ] && [ ! -L "$orphan" ]; then
        relpath="${orphan#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$relpath")"
        cp -r "$orphan" "$BACKUP_DIR/$relpath"
        DID_BACKUP=true
        rm -f "$orphan"
        echo "  Cleaned up orphan: $orphan -> $BACKUP_DIR/$relpath (removed)"
    fi
done

# Orphaned directories: back up and remove
ORPHAN_DIRS=(
    "$HOME/.oh-my-zsh"
    "$HOME/.oh-my-bash"
    "$HOME/.tmux"
    "$HOME/.config/ranger"
)
for orphan in "${ORPHAN_DIRS[@]}"; do
    if [ -d "$orphan" ] && [ ! -L "$orphan" ]; then
        relpath="${orphan#$HOME/}"
        mkdir -p "$BACKUP_DIR/$(dirname "$relpath")"
        cp -r "$orphan" "$BACKUP_DIR/$relpath"
        DID_BACKUP=true
        rm -rf "$orphan"
        echo "  Cleaned up orphan dir: $orphan -> $BACKUP_DIR/$relpath (removed)"
    fi
done

if [ "$DID_BACKUP" = true ]; then
    echo ""
    echo "  To rollback later: ~/dotfiles/rollback.sh $BACKUP_DIR"
    echo ""
else
    echo "  Nothing to back up (first run or already symlinked)."
fi

# --- Dry-run summary of what will be overwritten ---
echo "[2/7] The following files will be replaced with symlinks:"
for f in .bashrc .zshrc .tmux.conf .vimrc .aliases .gitconfig .config/starship.toml .config/yazi/yazi.toml; do
    if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        echo "  OVERWRITE: ~/$f (original backed up)"
    elif [ -L "$HOME/$f" ]; then
        echo "  RE-LINK:   ~/$f (already a symlink)"
    else
        echo "  CREATE:    ~/$f (does not exist yet)"
    fi
done
# .config directories symlinked
for d in .config/alacritty .config/dunst .config/i3; do
    if [ -e "$HOME/$d" ] && [ ! -L "$HOME/$d" ]; then
        echo "  OVERWRITE: ~/$d (original backed up)"
    elif [ -L "$HOME/$d" ]; then
        echo "  RE-LINK:   ~/$d (already a symlink)"
    else
        echo "  CREATE:    ~/$d (does not exist yet)"
    fi
done
# bin/ scripts -> ~/.local/bin
for script in "$DOTFILES/bin"/*; do
    [ -f "$script" ] || continue
    name="$(basename "$script")"
    if [ -e "$HOME/.local/bin/$name" ] && [ ! -L "$HOME/.local/bin/$name" ]; then
        echo "  OVERWRITE: ~/.local/bin/$name (original backed up)"
    elif [ -L "$HOME/.local/bin/$name" ]; then
        echo "  RE-LINK:   ~/.local/bin/$name (already a symlink)"
    else
        echo "  CREATE:    ~/.local/bin/$name"
    fi
done
echo ""

# --- Create symlinks ---
echo "[3/7] Creating symlinks..."
ln -sf "$DOTFILES/bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES/aliases" "$HOME/.aliases"
ln -sf "$DOTFILES/gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"

# Vim colorscheme (create dir structure, symlink the file)
mkdir -p "$HOME/.vim/colors"
ln -sf "$DOTFILES/vim/colors/monokai.vim" "$HOME/.vim/colors/monokai.vim"

echo "  ~/.bashrc -> dotfiles/bashrc"
echo "  ~/.zshrc -> dotfiles/zshrc"
echo "  ~/.tmux.conf -> dotfiles/tmux.conf"
echo "  ~/.vimrc -> dotfiles/vimrc"
echo "  ~/.aliases -> dotfiles/aliases"
echo "  ~/.gitconfig -> dotfiles/gitconfig"
echo "  ~/.vim/colors/monokai.vim -> dotfiles/vim/colors/monokai.vim"
echo "  ~/.config/starship.toml -> dotfiles/starship.toml"

# Yazi config
mkdir -p "$HOME/.config/yazi"
ln -sf "$DOTFILES/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
echo "  ~/.config/yazi/yazi.toml -> dotfiles/yazi/yazi.toml"

# i3, dunst, alacritty config directories (symlink entire dirs)
ln -sfn "$DOTFILES/.config/alacritty" "$HOME/.config/alacritty"
ln -sfn "$DOTFILES/.config/dunst" "$HOME/.config/dunst"
ln -sfn "$DOTFILES/.config/i3" "$HOME/.config/i3"
echo "  ~/.config/alacritty -> dotfiles/.config/alacritty"
echo "  ~/.config/dunst -> dotfiles/.config/dunst"
echo "  ~/.config/i3 -> dotfiles/.config/i3"

# Scripts in bin/ (symlinked to ~/.local/bin)
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES/bin"/*; do
    [ -f "$script" ] || continue
    name="$(basename "$script")"
    backup_if_exists "$HOME/.local/bin/$name"
    ln -sf "$script" "$HOME/.local/bin/$name"
    chmod +x "$script"
    echo "  ~/.local/bin/$name -> dotfiles/bin/$name"
done

# --- Sensitive files (symlink + chmod 600 if they exist) ---
echo "[4/7] Setting up sensitive files..."
if [ -f "$DOTFILES/secrets.env" ]; then
    ln -sf "$DOTFILES/secrets.env" "$HOME/.secrets.env"
    chmod 600 "$DOTFILES/secrets.env"
    echo "  ~/.secrets.env -> dotfiles/secrets.env (chmod 600)"
else
    echo "  Skipping secrets.env (not found in dotfiles repo)"
fi

# --- Install zsh plugins if zsh is available ---
echo "[5/7] Checking zsh plugins..."
if command -v zsh &>/dev/null; then
    mkdir -p "$HOME/.zsh/plugins"
    if [ ! -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]; then
        echo "  Cloning zsh-autosuggestions..."
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.zsh/plugins/zsh-autosuggestions"
    else
        echo "  zsh-autosuggestions already installed."
    fi
    if [ ! -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]; then
        echo "  Cloning zsh-syntax-highlighting..."
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$HOME/.zsh/plugins/zsh-syntax-highlighting"
    else
        echo "  zsh-syntax-highlighting already installed."
    fi
else
    echo "  Zsh not found, skipping plugin install."
fi

# --- Ensure .bash_profile sources .bashrc ---
echo "[6/7] Ensuring .bash_profile sources .bashrc..."
if [ ! -f "$HOME/.bash_profile" ] || ! grep -q 'source.*\.bashrc' "$HOME/.bash_profile" 2>/dev/null; then
    echo '[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"' > "$HOME/.bash_profile"
    echo "  Created .bash_profile"
else
    echo "  .bash_profile already sources .bashrc."
fi

echo ""
echo "[7/7] Summary"
echo "=== Setup complete. ==="
echo ""
if [ "$DID_BACKUP" = true ]; then
    echo "Old configs backed up to: $BACKUP_DIR"
    echo "To undo everything:       ~/dotfiles/rollback.sh $BACKUP_DIR"
else
    echo "No files were backed up (already symlinked or first run)."
fi
echo ""
echo "Next steps:"
echo "  1. Open a new shell to activate, or run: exec \$SHELL -l"
echo ""
echo "Migration note:"
echo "  If you were using a bare git repo at ~/.dotfiles/, you can now remove it:"
echo "  rm -rf ~/.dotfiles"
