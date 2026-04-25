#!/usr/bin/env bash
set -euo pipefail
# NeoCrash installer
# Install path selection adapted from ShellCrash by Juewuy

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── i18n ─────────────────────────────────────────
declare -A _S
_S[title]="  NeoCrash Installer"
_S[select_dir]="Select install directory:"
_S[opt_etc]="  1) /etc/NeoCrash              (requires root)"
_S[opt_usr]="  2) /usr/share/NeoCrash        (requires root)"
_S[opt_home]="  3) ~/.local/share/NeoCrash    (current user)"
_S[opt_custom]="  4) Custom path"
_S[opt_cancel]="  0) Cancel"
_S[available_mounts]="Available mount points:"
_S[cancelled]="Cancelled."
_S[invalid_option]="Invalid option."
_S[err_no_write]="Error: Cannot write to %s"
_S[err_try_sudo]="Try running with sudo or pick a different path."
_S[installing_to]="Installing to: %s"
_S[download_core]="Download proxy core? (optional — skip if already in PATH)"
_S[opt_mihomo]="  1) mihomo  (MetaCubeX/mihomo)"
_S[opt_singbox]="  2) sing-box (SagerNet/sing-box)"
_S[opt_skip]="  3) Skip"
_S[fetching_mihomo]="Fetching latest mihomo release..."
_S[err_fetch_mihomo]="Error: could not fetch mihomo version"
_S[latest_mihomo]="Latest: mihomo %s"
_S[downloading_mihomo]="Downloading mihomo-linux-%s..."
_S[err_download]="Error: download failed"
_S[err_url]="URL: %s"
_S[installed_mihomo]="Installed: mihomo %s → %s/bin/mihomo"
_S[fetching_singbox]="Fetching latest sing-box release..."
_S[err_fetch_singbox]="Error: could not fetch sing-box version"
_S[latest_singbox]="Latest: sing-box %s"
_S[downloading_singbox]="Downloading sing-box-linux-%s..."
_S[installed_singbox]="Installed: sing-box %s → %s/bin/sing-box"
_S[skip_core]="Skipping core download."
_S[invalid_core_option]="Invalid option, skipping core download."
_S[done_title]="  NeoCrash installed successfully!"
_S[done_run]="  Run:  source %s"
_S[done_then]="  Then: neocrash"

t()  { echo "${_S[$1]}"; }
tf() { local k="$1"; shift; printf "${_S[$k]}\n" "$@"; }
SEP="=================================================="

echo "$SEP"
t title
echo "$SEP"
echo ""

# ── Select install path ─────────────────────────

t select_dir
echo ""
t opt_etc
t opt_usr
t opt_home
t opt_custom
t opt_cancel
echo ""
read -r -p "> " choice

case "$choice" in
    1) dir="/etc/NeoCrash" ;;
    2) dir="/usr/share/NeoCrash" ;;
    3) dir="$HOME/.local/share/NeoCrash" ;;
    4)
        echo ""
        t available_mounts
        df -h --output=target,avail | tail -n +2
        echo ""
        read -r -p "Enter full path: " dir
        case "$dir" in
            */NeoCrash) ;;
            *) dir="${dir%/}/NeoCrash" ;;
        esac
        ;;
    0) t cancelled; exit 0 ;;
    *) t invalid_option; exit 1 ;;
esac

# ── Validate path ────────────────────────────────

parent="$(dirname "$dir")"
if [ ! -w "$parent" ] && ! mkdir -p "$dir" 2>/dev/null; then
    tf err_no_write "$parent"
    t err_try_sudo
    exit 1
fi

echo ""
tf installing_to "$dir"

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
t download_core
echo ""
t opt_mihomo
t opt_singbox
t opt_skip
echo ""
read -r -p "> " core_choice

case "$core_choice" in
    1)
        echo ""
        t fetching_mihomo
        MIHOMO_VER="$(curl -fsSL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" \
            | grep '"tag_name"' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"

        if [ -z "$MIHOMO_VER" ]; then
            t err_fetch_mihomo >&2
            exit 1
        fi

        tf latest_mihomo "$MIHOMO_VER"
        MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VER}/mihomo-linux-${ARCH}-${MIHOMO_VER}.gz"

        tf downloading_mihomo "$ARCH"
        if ! curl -fSL --progress-bar -o "$dir/bin/mihomo.gz" "$MIHOMO_URL"; then
            t err_download >&2
            tf err_url "$MIHOMO_URL" >&2
            exit 1
        fi

        gzip -df "$dir/bin/mihomo.gz"
        chmod +x "$dir/bin/mihomo"
        tf installed_mihomo "$MIHOMO_VER" "$dir"

        # Set core_type in config
        grep -q '^core_type=' "$dir/neocrash.conf" \
            && sed -i 's/^core_type=.*/core_type=mihomo/' "$dir/neocrash.conf" \
            || echo "core_type=mihomo" >>"$dir/neocrash.conf"
        ;;

    2)
        echo ""
        t fetching_singbox
        SB_VER="$(curl -fsSL "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
            | grep '"tag_name"' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"

        if [ -z "$SB_VER" ]; then
            t err_fetch_singbox >&2
            exit 1
        fi

        SB_VER_NUM="${SB_VER#v}"
        tf latest_singbox "$SB_VER"
        SB_URL="https://github.com/SagerNet/sing-box/releases/download/${SB_VER}/sing-box-${SB_VER_NUM}-linux-${ARCH}.tar.gz"

        tf downloading_singbox "$ARCH"
        if ! curl -fSL --progress-bar -o "$dir/bin/sing-box.tar.gz" "$SB_URL"; then
            t err_download >&2
            tf err_url "$SB_URL" >&2
            exit 1
        fi

        tar -xzf "$dir/bin/sing-box.tar.gz" -C "$dir/bin/" \
            --strip-components=1 \
            "sing-box-${SB_VER_NUM}-linux-${ARCH}/sing-box"
        rm -f "$dir/bin/sing-box.tar.gz"
        chmod +x "$dir/bin/sing-box"
        tf installed_singbox "$SB_VER" "$dir"

        grep -q '^core_type=' "$dir/neocrash.conf" \
            && sed -i 's/^core_type=.*/core_type=singbox/' "$dir/neocrash.conf" \
            || echo "core_type=singbox" >>"$dir/neocrash.conf"
        ;;

    3)
        t skip_core
        ;;

    *)
        t invalid_core_option
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
echo "$SEP"
t done_title
echo "$SEP"
echo ""
tf done_run "$shellprofile"
t done_then
echo ""
