#!/usr/bin/env bash
set -euo pipefail
# NeoCrash local installer
# Install path selection adapted from ShellCrash by Juewuy

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify required directories exist
for d in bin lib locale; do
  if [ ! -d "$SRC/$d" ]; then
    echo "Error: '$d/' not found in $SRC — run from the repo root" >&2
    exit 1
  fi
done

# ── Select install path ──────────────────────────

echo "Select install directory:"
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
0)
  echo "Cancelled."
  exit 0
  ;;
*)
  echo "Invalid option."
  exit 1
  ;;
esac

# ── Validate path ────────────────────────────────

parent="$(dirname "$dir")"
if [ ! -w "$parent" ] && ! mkdir -p "$dir" 2>/dev/null; then
  echo "Error: Cannot write to $parent" >&2
  echo "Try running with sudo or pick a different path." >&2
  exit 1
fi

echo ""
echo "Installing to: $dir"

# ── Stamp version with git hash ──────────────────

_VER="$(grep '^VERSION=' "$SRC/bin/neocrash" | head -1 | cut -d'"' -f2)"
_HASH="$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo "local")"
_STAMPED_VER="${_VER}+${_HASH}"

# ── Copy files ───────────────────────────────────

mkdir -p "$dir"/{bin,lib,conf,profiles,geodata,locale}

cp -f "$SRC/bin/neocrash" "$dir/bin/neocrash"
sed -i "s/^VERSION=.*/VERSION=\"$_STAMPED_VER\"/" "$dir/bin/neocrash"
chmod +x "$dir/bin/neocrash"

cp -f "$SRC"/lib/*.sh "$dir/lib/"
cp -f "$SRC"/locale/*.sh "$dir/locale/"
[ -f "$SRC/conf/neocrash.conf" ] && cp -n "$SRC/conf/neocrash.conf" "$dir/neocrash.conf"
[ -f "$dir/neocrash.conf" ] || touch "$dir/neocrash.conf"

echo "Version: $_STAMPED_VER"

# ── Set shell profile ────────────────────────────
# Adapted from ShellCrash set_profile.sh by Juewuy

shellprofile=""
[ -f "$HOME/.zshrc" ] && shellprofile="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && shellprofile="$HOME/.bashrc"
[ -z "$shellprofile" ] && shellprofile="$HOME/.bashrc" && touch "$shellprofile"

sed -i '/neocrash/d' "$shellprofile" 2>/dev/null || true
sed -i '/NEOCRASH_DIR/d' "$shellprofile" 2>/dev/null || true

{
  echo "export NEOCRASH_DIR=\"$dir\""
  echo "alias neocrash=\"$dir/bin/neocrash\""
} >>"$shellprofile"

echo ""
echo "=================================================="
echo "  NeoCrash installed successfully!"
echo "=================================================="
echo ""
echo "  Run:  source $shellprofile"
echo "  Then: neocrash"
echo ""
