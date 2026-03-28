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

# --- 1. Starship ---
echo "[1/9] Starship"
curl -sS https://starship.rs/install.sh | sh -s -- -b "$INSTALL_DIR" -y

# --- 2. Zoxide ---
echo "[2/9] Zoxide"
curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    | BIN_DIR="$INSTALL_DIR" bash

# --- 3. FZF ---
echo "[3/9] FZF"
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --bin --no-update-rc --no-completion --no-key-bindings
ln -sf "$HOME/.fzf/bin/fzf" "$INSTALL_DIR/fzf"

# --- 4. Eza ---
echo "[4/9] Eza"
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

# --- 5. Bat ---
echo "[5/9] Bat"
BAT_TAG="$(gh_latest sharkdp/bat)"
install_from_tarball "sharkdp/bat" "bat-${BAT_TAG}-${RUST_MUSL}.tar.gz" "bat"

# --- 6. Ripgrep ---
echo "[6/9] Ripgrep"
RG_TAG="$(gh_latest BurntSushi/ripgrep)"
install_from_tarball "BurntSushi/ripgrep" "ripgrep-${RG_TAG}-${RUST_MUSL}.tar.gz" "rg"

# --- 7. Dust ---
echo "[7/9] Dust"
DUST_TAG="$(gh_latest bootandy/dust)"
install_from_tarball "bootandy/dust" "dust-${DUST_TAG}-${RUST_MUSL}.tar.gz" "dust"

# --- 8. Yazi ---
echo "[8/9] Yazi"
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

# --- 9. ble.sh (Bash-only) ---
echo "[9/9] ble.sh"
rm -rf "$DATA_DIR/blesh"
tmpdir="$(mktemp -d "$_TMPBASE/qol.XXXXXX")"
curl -sfL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz \
    | tar xJ -C "$tmpdir"
mv "$tmpdir/ble-nightly" "$DATA_DIR/blesh"
rm -rf "$tmpdir"
# Nightly tarballs are pre-built. No make step needed.

echo ""
echo "=== Done. Run ~/dotfiles/setup_links.sh to wire up configs. ==="
