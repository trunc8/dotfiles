#!/bin/bash
set -euo pipefail

# Usage: ./rollback.sh <backup_directory>
# Example: ./rollback.sh ~/dotfiles_backup/20260328_094500
#
# Restores config files from a backup created by setup_links.sh.
# Removes the symlinks and puts the original files back.

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <backup_directory>"
    echo ""
    # List available backups
    if [ -d "$HOME/dotfiles_backup" ]; then
        echo "Available backups:"
        for d in "$HOME/dotfiles_backup"/*/; do
            [ -d "$d" ] && echo "  $d"
        done
    else
        echo "No backups found in ~/dotfiles_backup/"
    fi
    exit 1
fi

BACKUP_DIR="$1"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo "=== Dotfiles Rollback ==="
echo "Restoring from: $BACKUP_DIR"
echo ""

# Restore a file from backup to its original location
# Takes a path relative to $HOME (e.g., ".bashrc", ".ssh/config")
restore_file() {
    local relpath="$1"

    if [ -f "$BACKUP_DIR/$relpath" ]; then
        mkdir -p "$(dirname "$HOME/$relpath")"
        rm -f "$HOME/$relpath"
        cp "$BACKUP_DIR/$relpath" "$HOME/$relpath"
        echo "  Restored: ~/$relpath"
    fi
}

# Restore a directory from backup to its original location
# Takes a path relative to $HOME (e.g., ".oh-my-zsh", ".config/ranger")
restore_dir() {
    local relpath="$1"

    if [ -d "$BACKUP_DIR/$relpath" ]; then
        mkdir -p "$(dirname "$HOME/$relpath")"
        rm -rf "$HOME/$relpath"
        cp -r "$BACKUP_DIR/$relpath" "$HOME/$relpath"
        echo "  Restored: ~/$relpath"
    fi
}

# Restore config files
restore_file ".bashrc"
restore_file ".bash_profile"
restore_file ".zshrc"
restore_file ".tmux.conf"
restore_file ".vimrc"
restore_file ".aliases"
restore_file ".gitconfig"
restore_file ".config/starship.toml"
restore_file ".config/yazi/yazi.toml"

# Restore sensitive files
restore_file ".secrets.env"

# Restore orphaned files that were cleaned up by setup_links.sh
restore_file ".tmux.conf.local"
restore_file ".fzf.zsh"

# Restore orphaned directories that were cleaned up by setup_links.sh
restore_dir ".oh-my-zsh"
restore_dir ".oh-my-bash"
restore_dir ".tmux"
restore_dir ".config/ranger"

# Restore .config directories that were symlinked
restore_dir ".config/alacritty"
restore_dir ".config/dunst"
restore_dir ".config/i3"

# Restore or remove bin scripts symlinked by setup_links.sh
DOTFILES="$HOME/dotfiles"
if [ -d "$DOTFILES/bin" ]; then
    for script in "$DOTFILES/bin"/*; do
        [ -f "$script" ] || continue
        name="$(basename "$script")"
        relpath=".local/bin/$name"
        if [ -f "$BACKUP_DIR/$relpath" ]; then
            restore_file "$relpath"
        elif [ -L "$HOME/$relpath" ]; then
            rm -f "$HOME/$relpath"
            echo "  Removed: ~/$relpath (no backup, was symlink)"
        fi
    done
fi

echo ""
echo "=== Rollback complete. ==="
echo ""
echo "Your shell configs are back to the state before setup_links.sh ran."
echo "Open a new shell to activate: exec \$SHELL -l"
echo ""
echo "Note: Installed binaries in ~/.local/bin/ (starship, zoxide, etc.) are NOT rolled back."
echo "Dotfiles bin/ scripts were restored/removed above."
echo "To remove installed binaries manually:"
echo "  rm -f ~/.local/bin/{starship,zoxide,fzf,eza,bat,rg,dust,yazi}"
echo "  rm -rf ~/.fzf"
echo ""
echo "The old frameworks (if still on disk) will work again:"
echo "  ~/.oh-my-zsh/    (loaded by restored .zshrc)"
