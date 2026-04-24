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
        # Append NeoCrash if user gave a base path
        case "$dir" in
            */NeoCrash) ;;
            *) dir="${dir%/}/NeoCrash" ;;
        esac
        ;;
    0) echo "Cancelled."; exit 0 ;;
    *) echo "Invalid option."; exit 1 ;;
esac

# ── Validate ─────────────────────────────────────

parent="$(dirname "$dir")"
if [ ! -w "$parent" ] && ! mkdir -p "$dir" 2>/dev/null; then
    echo "Error: Cannot write to $parent"
    echo "Try running with sudo or pick a different path."
    exit 1
fi

echo ""
echo "Installing to: $dir"

# ── Copy files ───────────────────────────────────

mkdir -p "$dir"/{bin,lib,conf,profiles}

cp -f "$SCRIPT_DIR"/bin/neocrash "$dir/bin/neocrash"
cp -f "$SCRIPT_DIR"/lib/*.sh "$dir/lib/"
[ -f "$SCRIPT_DIR/conf/neocrash.conf" ] && cp -n "$SCRIPT_DIR/conf/neocrash.conf" "$dir/conf/"

chmod +x "$dir/bin/neocrash"

# ── Create config if missing ────────────────────

[ -f "$dir/neocrash.conf" ] || touch "$dir/neocrash.conf"

# ── Set shell profile ───────────────────────────
# Adapted from ShellCrash set_profile.sh by Juewuy

profile=""
[ -f "$HOME/.zshrc" ] && profile="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && profile="$HOME/.bashrc"

if [ -z "$profile" ]; then
    # Fallback: create .bashrc
    profile="$HOME/.bashrc"
    touch "$profile"
fi

# Remove old entries, add new ones
sed -i '/neocrash/d' "$profile" 2>/dev/null || true
sed -i '/NEOCRASH_DIR/d' "$profile" 2>/dev/null || true

{
    echo "export NEOCRASH_DIR=\"$dir\""
    echo "alias neocrash=\"$dir/bin/neocrash\""
} >>"$profile"

# ── Done ─────────────────────────────────────────

echo ""
echo "=================================================="
echo "  NeoCrash installed successfully!"
echo "=================================================="
echo ""
echo "  Run:  source $profile"
echo "  Then: neocrash"
echo ""
