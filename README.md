# dotfiles

Personal dotfiles for Ubuntu 22/24 + i3 + zsh + kitty. Managed as a regular git repo with symlink deployment.

## Quick Start (fresh Ubuntu install)

```bash
# 1. Install system packages
sudo apt update && sudo apt install -y \
    git curl zsh tmux vim \
    i3 i3blocks i3lock xss-lock picom brightnessctl \
    kitty feh rofi dunst maim xclip playerctl redshift \
    imagemagick ffmpeg

# 2. Set zsh as default shell (takes effect on next login)
chsh -s $(which zsh)

# 3. Clone and set up dotfiles
git clone <remote> ~/dotfiles
cd ~/dotfiles
./install_linux.sh      # Install modern CLI tools to ~/.local/bin
./setup_links.sh        # Symlink configs into $HOME (backs up existing files first)

# 4. Log out, select "i3" at the login screen, log back in
```

## What's Included

### Shell Configs

| File | Description |
|------|-------------|
| `bashrc` | Bash config: ble.sh init, sources common.sh |
| `zshrc` | Zsh config: direct plugin sourcing (no oh-my-zsh) |
| `common.sh` | Shell-agnostic core: PATH, tool init, aliases, auto-pull |
| `aliases` | All aliases and functions for both shells |

### Tool Configs

| File | Description |
|------|-------------|
| `tmux.conf` | Tmux: C-a prefix, `\|`/`-` splits, mouse, status bar |
| `vimrc` | Vim: monokai, relative numbers, 2-space tabs |
| `gitconfig` | Git: personal email, perf tuning, diff3 merge style |
| `starship.toml` | Starship prompt: powerline style with git metrics |
| `yazi/yazi.toml` | Yazi file manager config |
| `vim/colors/monokai.vim` | Monokai colorscheme for vim |

### Desktop Environment (i3)

| Path | Description |
|------|-------------|
| `.config/i3/config` | i3 window manager config |
| `.config/i3/i3blocks.conf` | i3 status bar blocks |
| `.config/i3/scripts/` | Status bar scripts (battery, volume, etc.) |
| `.config/alacritty/alacritty.toml` | Alacritty terminal config |
| `.config/dunst/dunstrc` | Dunst notification daemon config |

### Scripts (`bin/`)

| Script | Description |
|--------|-------------|
| `toggle_alacritty_opacity` | Toggle terminal transparency |
| `toggle_dunst_pause` | Pause/unpause notifications |
| `toggle_touchpad` | Toggle touchpad on/off |
| `set_brightness` | Screen brightness control |
| `ocr` | OCR utility |
| `hrefy` | Header text to URL fragment |
| `rc` | Quick C++ compile and run |

### Setup Scripts

| Script | Description |
|--------|-------------|
| `install_linux.sh` | Install CLI tools (starship, zoxide, fzf, eza, bat, rg, dust, yazi, ble.sh) |
| `setup_links.sh` | Create symlinks, backup existing configs, clone zsh plugins |
| `rollback.sh` | Restore configs from a backup created by setup_links.sh |

## Rollback

If something goes wrong after running `setup_links.sh`:

```bash
# List available backups
./rollback.sh

# Restore a specific backup
./rollback.sh ~/dotfiles_backup/20260328_094500
```

## Machine-Specific Overrides

Create `~/.local.sh` for machine-specific settings (not tracked by this repo). It's sourced at the end of both bashrc and zshrc.

Create `~/.secrets.env` for tokens and API keys (chmod 600, not tracked).
