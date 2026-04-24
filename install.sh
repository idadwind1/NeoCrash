#!/usr/bin/env bash
set -euo pipefail
# NeoCrash installer
# Install path selection adapted from ShellCrash by Juewuy

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "  NeoCrash Installer"
echo "=================================================="
echo ""

# ── Select install path ─────────────────────────

echo "Select install directory:"
echo ""
echo "  1) /etc/NeoCrash              (requires root)"
echo "  2) /usr/share/NeoCrash        (requires root)"
echo "  3) ~/.local/share/NeoCrash    (current user)"
echo "  4) Custom path"
echo "  0) Cancel"
echo ""
read -r -p "> " choice

case "$choice" in
    1) dir="/etc/NeoCrash" ;;
    2) dir="/usr/share/NeoCrash" ;;
    3) dir="$HOME/.local/share/NeoCrash" ;;
    4)
        echo ""
        echo "Available mount points:"
        df -h --output=target,avail | tail -n +2
        echo ""
        read -r -p "Enter full path: " dir
        case "$dir" in
            */NeoCrash) ;;
            *) dir="${dir%/}/NeoCrash" ;;
        esac
        ;;
    0) echo "Cancelled."; exit 0 ;;
    *) echo "Invalid option."; exit 1 ;;
esac

# ── Validate path ────────────────────────────────

parent="$(dirname "$dir")"
if [ ! -w "$parent" ] && ! mkdir -p "$dir" 2>/dev/null; then
    echo "Error: Cannot write to $parent"
    echo "Try running with sudo or pick a different path."
    exit 1
fi

echo ""
echo "Installing to: $dir"

# ── Copy files ───────────────────────────────────

mkdir -p "$dir"/{bin,lib,conf,profiles,geodata}

cp -f "$SCRIPT_DIR"/bin/neocrash "$dir/bin/neocrash"
cp -f "$SCRIPT_DIR"/lib/*.sh "$dir/lib/"
[ -f "$SCRIPT_DIR/conf/neocrash.conf" ] && cp -n "$SCRIPT_DIR/conf/neocrash.conf" "$dir/neocrash.conf"

chmod +x "$dir/bin/neocrash"

[ -f "$dir/neocrash.conf" ] || touch "$dir/neocrash.conf"

# ── Detect architecture ──────────────────────────

_detect_arch() {
    local machine
    machine="$(uname -m)"
    case "$machine" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        armv7*)  echo "armv7" ;;
        armv6*)  echo "armv6" ;;
        i386|i686) echo "386" ;;
        *)       echo "$machine" ;;
    esac
}

ARCH="$(_detect_arch)"

# ── Download proxy core ──────────────────────────

echo ""
echo "Download proxy core? (optional — skip if already in PATH)"
echo ""
echo "  1) mihomo  (MetaCubeX/mihomo)"
echo "  2) sing-box (SagerNet/sing-box)"
echo "  3) Skip"
echo ""
read -r -p "> " core_choice

case "$core_choice" in
    1)
        echo ""
        echo "Fetching latest mihomo release..."
        MIHOMO_VER="$(curl -fsSL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" \
            | grep '"tag_name"' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"

        if [ -z "$MIHOMO_VER" ]; then
            echo "Error: could not fetch mihomo version" >&2
            exit 1
        fi

        echo "Latest: mihomo $MIHOMO_VER"
        MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VER}/mihomo-linux-${ARCH}-${MIHOMO_VER}.gz"

        echo "Downloading mihomo-linux-${ARCH}..."
        if ! curl -fSL --progress-bar -o "$dir/bin/mihomo.gz" "$MIHOMO_URL"; then
            echo "Error: download failed" >&2
            echo "URL: $MIHOMO_URL" >&2
            exit 1
        fi

        gzip -df "$dir/bin/mihomo.gz"
        chmod +x "$dir/bin/mihomo"
        echo "Installed: mihomo $MIHOMO_VER → $dir/bin/mihomo"

        # Set core_type in config
        grep -q '^core_type=' "$dir/neocrash.conf" \
            && sed -i 's/^core_type=.*/core_type=mihomo/' "$dir/neocrash.conf" \
            || echo "core_type=mihomo" >>"$dir/neocrash.conf"
        ;;

    2)
        echo ""
        echo "Fetching latest sing-box release..."
        SB_VER="$(curl -fsSL "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
            | grep '"tag_name"' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"

        if [ -z "$SB_VER" ]; then
            echo "Error: could not fetch sing-box version" >&2
            exit 1
        fi

        # Strip leading 'v' for sing-box tarball naming
        SB_VER_NUM="${SB_VER#v}"
        echo "Latest: sing-box $SB_VER"
        SB_URL="https://github.com/SagerNet/sing-box/releases/download/${SB_VER}/sing-box-${SB_VER_NUM}-linux-${ARCH}.tar.gz"

        echo "Downloading sing-box-linux-${ARCH}..."
        if ! curl -fSL --progress-bar -o "$dir/bin/sing-box.tar.gz" "$SB_URL"; then
            echo "Error: download failed" >&2
            echo "URL: $SB_URL" >&2
            exit 1
        fi

        tar -xzf "$dir/bin/sing-box.tar.gz" -C "$dir/bin/" \
            --strip-components=1 \
            "sing-box-${SB_VER_NUM}-linux-${ARCH}/sing-box"
        rm -f "$dir/bin/sing-box.tar.gz"
        chmod +x "$dir/bin/sing-box"
        echo "Installed: sing-box $SB_VER → $dir/bin/sing-box"

        grep -q '^core_type=' "$dir/neocrash.conf" \
            && sed -i 's/^core_type=.*/core_type=singbox/' "$dir/neocrash.conf" \
            || echo "core_type=singbox" >>"$dir/neocrash.conf"
        ;;

    3)
        echo "Skipping core download."
        ;;

    *)
        echo "Invalid option, skipping core download."
        ;;
esac

# ── Set shell profile ────────────────────────────
# Adapted from ShellCrash set_profile.sh by Juewuy

shellprofile=""
[ -f "$HOME/.zshrc" ]  && shellprofile="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && shellprofile="$HOME/.bashrc"
[ -z "$shellprofile" ] && shellprofile="$HOME/.bashrc" && touch "$shellprofile"

sed -i '/neocrash/d'   "$shellprofile" 2>/dev/null || true
sed -i '/NEOCRASH_DIR/d' "$shellprofile" 2>/dev/null || true

{
    echo "export NEOCRASH_DIR=\"$dir\""
    echo "alias neocrash=\"$dir/bin/neocrash\""
} >>"$shellprofile"

# ── Done ─────────────────────────────────────────

echo ""
echo "=================================================="
echo "  NeoCrash installed successfully!"
echo "=================================================="
echo ""
echo "  Run:  source $shellprofile"
echo "  Then: neocrash"
echo ""
