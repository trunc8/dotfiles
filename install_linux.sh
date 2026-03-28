#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
DATA_DIR="$HOME/.local/share"
mkdir -p "$INSTALL_DIR" "$DATA_DIR"
export PATH="$INSTALL_DIR:$PATH"

# Use ~/.tmp if /tmp is not writable (cluster machines)
if [ -w /tmp ]; then
    _TMPBASE="/tmp"
else
    _TMPBASE="$HOME/.tmp"
fi
mkdir -p "$_TMPBASE"

# --- Architecture detection ---
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)
        RUST_MUSL="x86_64-unknown-linux-musl"
        RUST_GNU="x86_64-unknown-linux-gnu"
        ;;
    aarch64)
        RUST_MUSL="aarch64-unknown-linux-musl"
        RUST_GNU="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# --- Helpers ---

# Fetch latest GitHub release tag
gh_latest() {
    local tag
    tag="$(curl -sf "https://api.github.com/repos/$1/releases/latest" \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
    if [ -z "$tag" ]; then
        echo "Warning: failed to fetch latest tag for $1 (rate limited?)" >&2
        return 1
    fi
    echo "$tag"
}

# Download a tarball, find a binary inside, install it
install_from_tarball() {
    local repo="$1" tarball_name="$2" binary_name="$3"
    local tag
    tag="$(gh_latest "$repo")" || return
    local url="https://github.com/$repo/releases/download/${tag}/${tarball_name}"
    local tmpdir
    tmpdir="$(mktemp -d "$_TMPBASE/qol.XXXXXX")"
    echo "  -> $binary_name ($tag) [$ARCH]"
    curl -sfL "$url" | tar xz -C "$tmpdir"
    local found
    found="$(find "$tmpdir" -name "$binary_name" -type f | head -1)"
    if [ -z "$found" ]; then
        echo "  ERROR: $binary_name not found in tarball" >&2
        rm -rf "$tmpdir"
        return 1
    fi
    mv "$found" "$INSTALL_DIR/$binary_name"
    chmod +x "$INSTALL_DIR/$binary_name"
    rm -rf "$tmpdir"
}

echo "=== Linux QoL Installer (arch: $ARCH) ==="
echo ""

# --- 1. Nerd Font (required for starship/eza icons) ---
echo "[1/10] Nerd Font (JetBrainsMono)"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd"; then
    echo "  Already installed."
else
    NERD_TAG="$(gh_latest ryanoasis/nerd-fonts)" || true
    if [ -n "$NERD_TAG" ]; then
        tmpdir="$(mktemp -d "$_TMPBASE/qol.XXXXXX")"
        curl -sfL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_TAG}/JetBrainsMono.tar.xz" \
            -o "$tmpdir/JetBrainsMono.tar.xz"
        tar xf "$tmpdir/JetBrainsMono.tar.xz" -C "$FONT_DIR"
        rm -rf "$tmpdir"
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f "$FONT_DIR"
        fi
        echo "  -> JetBrainsMono Nerd Font installed to $FONT_DIR"
        echo "  NOTE: Set your terminal font to 'JetBrainsMono Nerd Font' for icons to work."
    else
        echo "  WARNING: Could not fetch Nerd Font release. Install manually from:"
        echo "  https://github.com/ryanoasis/nerd-fonts/releases"
    fi
fi

# --- 2. Starship ---
echo "[2/10] Starship"
curl -sS https://starship.rs/install.sh | sh -s -- -b "$INSTALL_DIR" -y

# --- 3. Zoxide ---
echo "[3/10] Zoxide"
curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    | BIN_DIR="$INSTALL_DIR" bash

# --- 4. FZF ---
echo "[4/10] FZF"
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings
ln -sf "$HOME/.fzf/bin/fzf" "$INSTALL_DIR/fzf"

# --- 5. Eza ---
echo "[5/10] Eza"
EZA_TAG="$(gh_latest eza-community/eza)" || true
if [ -n "$EZA_TAG" ]; then
    tmpdir="$(mktemp -d "$_TMPBASE/qol.XXXXXX")"
    curl -sfL "https://github.com/eza-community/eza/releases/download/${EZA_TAG}/eza_${RUST_MUSL}.tar.gz" \
        | tar xz -C "$tmpdir"
    found="$(find "$tmpdir" -name "eza" -type f | head -1)"
    if [ -n "$found" ]; then
        mv "$found" "$INSTALL_DIR/eza"
        chmod +x "$INSTALL_DIR/eza"
    else
        echo "  ERROR: eza not found in tarball" >&2
    fi
    rm -rf "$tmpdir"
fi

# --- 6. Bat ---
echo "[6/10] Bat"
BAT_TAG="$(gh_latest sharkdp/bat)"
install_from_tarball "sharkdp/bat" "bat-${BAT_TAG}-${RUST_MUSL}.tar.gz" "bat"

# --- 7. Ripgrep ---
echo "[7/10] Ripgrep"
RG_TAG="$(gh_latest BurntSushi/ripgrep)"
install_from_tarball "BurntSushi/ripgrep" "ripgrep-${RG_TAG}-${RUST_MUSL}.tar.gz" "rg"

# --- 8. Dust ---
echo "[8/10] Dust"
DUST_TAG="$(gh_latest bootandy/dust)"
install_from_tarball "bootandy/dust" "dust-${DUST_TAG}-${RUST_MUSL}.tar.gz" "dust"

# --- 9. Yazi ---
echo "[9/10] Yazi"
YAZI_TAG="$(gh_latest sxyazi/yazi)" || true
if [ -n "$YAZI_TAG" ]; then
    tmpdir="$(mktemp -d "$_TMPBASE/qol.XXXXXX")"
    curl -sfL "https://github.com/sxyazi/yazi/releases/download/${YAZI_TAG}/yazi-${RUST_MUSL}.zip" \
        -o "$tmpdir/yazi.zip"
    # Try unzip first, fall back to python if unzip is not available
    if command -v unzip >/dev/null 2>&1; then
        unzip -q "$tmpdir/yazi.zip" -d "$tmpdir"
    else
        python3 -c "import zipfile; zipfile.ZipFile('$tmpdir/yazi.zip').extractall('$tmpdir')"
    fi
    found="$(find "$tmpdir" -name "yazi" -type f | head -1)"
    if [ -n "$found" ]; then
        mv "$found" "$INSTALL_DIR/yazi"
        chmod +x "$INSTALL_DIR/yazi"
    else
        echo "  ERROR: yazi not found in archive" >&2
    fi
    rm -rf "$tmpdir"
fi

# --- 10. ble.sh (Bash-only) ---
echo "[10/10] ble.sh"
rm -rf "$DATA_DIR/blesh"
tmpdir="$(mktemp -d "$_TMPBASE/qol.XXXXXX")"
curl -sfL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz \
    | tar xJ -C "$tmpdir"
mv "$tmpdir/ble-nightly" "$DATA_DIR/blesh"
rm -rf "$tmpdir"
# Nightly tarballs are pre-built. No make step needed.

echo ""
echo "=== Done. Run ~/dotfiles/setup_links.sh to wire up configs. ==="
