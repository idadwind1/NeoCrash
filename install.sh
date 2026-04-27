#!/usr/bin/env bash
set -euo pipefail
# NeoCrash installer
# Install path selection adapted from ShellCrash by Juewuy

REPO_URL="https://github.com/idadwind1/NeoCrash"

# ── Inline translations ───────────────────────────
# Add a new language by copying an _S_xx block below.

declare -A _S_en
_S_en[title]="  NeoCrash Installer"
_S_en[select_lang]="Select language:"
_S_en[select_dir]="Select install directory:"
_S_en[opt_etc]="  1) /etc/NeoCrash              (requires root)"
_S_en[opt_usr]="  2) /usr/share/NeoCrash        (requires root)"
_S_en[opt_home]="  3) ~/.local/share/NeoCrash    (current user)"
_S_en[opt_custom]="  4) Custom path"
_S_en[opt_cancel]="  0) Cancel"
_S_en[available_mounts]="Available mount points:"
_S_en[select_custom_dir]="Enter full path: "
_S_en[cancelled]="Cancelled."
_S_en[invalid_option]="Invalid option."
_S_en[err_no_write]="Error: Cannot write to %s"
_S_en[err_try_sudo]="Try running with sudo or pick a different path."
_S_en[installing_to]="Installing to: %s"
_S_en[download_core]="Download proxy core? (optional — skip if already in PATH)"
_S_en[opt_mihomo]="  1) mihomo  (MetaCubeX/mihomo)"
_S_en[opt_singbox]="  2) sing-box (SagerNet/sing-box)"
_S_en[opt_skip]="  3) Skip"
_S_en[fetching_mihomo]="Fetching latest mihomo release..."
_S_en[err_fetch_mihomo]="Error: could not fetch mihomo version"
_S_en[latest_mihomo]="Latest: mihomo %s"
_S_en[downloading_mihomo]="Downloading mihomo-linux-%s..."
_S_en[err_download]="Error: download failed"
_S_en[err_url]="URL: %s"
_S_en[installed_mihomo]="Installed: mihomo %s → %s/bin/mihomo"
_S_en[fetching_singbox]="Fetching latest sing-box release..."
_S_en[err_fetch_singbox]="Error: could not fetch sing-box version"
_S_en[latest_singbox]="Latest: sing-box %s"
_S_en[downloading_singbox]="Downloading sing-box-linux-%s..."
_S_en[installed_singbox]="Installed: sing-box %s → %s/bin/sing-box"
_S_en[skip_core]="Skipping core download."
_S_en[invalid_core_option]="Invalid option, skipping core download."
_S_en[done_title]="  NeoCrash installed successfully!"
_S_en[done_run]="  Run:  source %s"
_S_en[done_then]="  Then: neocrash"

declare -A _S_zh_CN
_S_zh_CN[title]="  NeoCrash 安装程序"
_S_zh_CN[select_lang]="选择语言："
_S_zh_CN[select_dir]="选择安装目录："
_S_zh_CN[opt_etc]="  1) /etc/NeoCrash              （需要 root 权限）"
_S_zh_CN[opt_usr]="  2) /usr/share/NeoCrash        （需要 root 权限）"
_S_zh_CN[opt_home]="  3) ~/.local/share/NeoCrash    （当前用户）"
_S_zh_CN[opt_custom]="  4) 自定义路径"
_S_zh_CN[opt_cancel]="  0) 取消"
_S_zh_CN[available_mounts]="可用的挂载点："
_S_zh_CN[select_custom_dir]="输入完整路径："
_S_zh_CN[cancelled]="已取消。"
_S_zh_CN[invalid_option]="无效选项。"
_S_zh_CN[err_no_write]="错误：无法写入 %s"
_S_zh_CN[err_try_sudo]="请尝试使用 sudo 运行，或选择一个不同的路径。"
_S_zh_CN[installing_to]="正在安装到：%s"
_S_zh_CN[download_core]="下载代理核心？（可选——若 PATH 中已有，可跳过）"
_S_zh_CN[opt_mihomo]="  1) mihomo  (MetaCubeX/mihomo)"
_S_zh_CN[opt_singbox]="  2) sing-box (SagerNet/sing-box)"
_S_zh_CN[opt_skip]="  3) 跳过"
_S_zh_CN[fetching_mihomo]="正在获取 mihomo 最新版……"
_S_zh_CN[err_fetch_mihomo]="错误：无法获取 mihomo 版本"
_S_zh_CN[latest_mihomo]="最新版：mihomo %s"
_S_zh_CN[downloading_mihomo]="正在下载 mihomo-linux-%s……"
_S_zh_CN[err_download]="错误：下载失败"
_S_zh_CN[err_url]="URL：%s"
_S_zh_CN[installed_mihomo]="已安装：mihomo %s → %s/bin/mihomo"
_S_zh_CN[fetching_singbox]="正在获取 sing-box 最新版……"
_S_zh_CN[err_fetch_singbox]="错误：无法获取 sing-box 版本"
_S_zh_CN[latest_singbox]="最新版：sing-box %s"
_S_zh_CN[downloading_singbox]="正在下载 sing-box-linux-%s……"
_S_zh_CN[installed_singbox]="已安装：sing-box %s → %s/bin/sing-box"
_S_zh_CN[skip_core]="跳过核心的下载。"
_S_zh_CN[invalid_core_option]="无效选项，跳过核心的下载。"
_S_zh_CN[done_title]="  NeoCrash 安装成功！"
_S_zh_CN[done_run]="  请先执行：source %s"
_S_zh_CN[done_then]="  然后执行：neocrash"

# ── Language selection ───────────────────────────
# List available languages here (code:label).
_LANGS=(
  "en:English"
  "zh_CN:简体中文"
)

echo "Select language:"
echo "  0) English (default)"
_li=1
for _entry in "${_LANGS[@]:1}"; do
  echo "  $_li) ${_entry#*:}"
  _li=$((_li + 1))
done
echo ""
read -r -p "> " _lang_choice

_chosen_lang="en"
case "${_lang_choice:-0}" in
0 | "") _chosen_lang="en" ;;
*)
  _li=1
  for _entry in "${_LANGS[@]:1}"; do
    if [ "$_li" = "$_lang_choice" ]; then
      _chosen_lang="${_entry%%:*}"
      break
    fi
    _li=$((_li + 1))
  done
  ;;
esac

# Copy chosen language block into _S
declare -A _S
_src="_S_${_chosen_lang}"
eval "$(declare -p "$_src" | sed "s/${_src}/_S/g")"

t() { echo "${_S[$1]}"; }
tf() {
  local k="$1"
  shift
  printf "${_S[$k]}\n" "$@"
}
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
  read -r -p "$(t select_custom_dir)" dir
  case "$dir" in
  */NeoCrash) ;;
  *) dir="${dir%/}/NeoCrash" ;;
  esac
  ;;
0)
  t cancelled
  exit 0
  ;;
*)
  t invalid_option
  exit 1
  ;;
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

# ── Clone repo ───────────────────────────────────

_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$_TMPDIR"' EXIT

git clone --depth=1 "$REPO_URL" "$_TMPDIR/NeoCrash"
SRC="$_TMPDIR/NeoCrash"

# ── Copy files ───────────────────────────────────

mkdir -p "$dir"/{bin,lib,conf,profiles,geodata,locale}

cp -f "$SRC"/bin/neocrash "$dir/bin/neocrash"
cp -f "$SRC"/lib/*.sh "$dir/lib/"
cp -f "$SRC"/locale/*.sh "$dir/locale/" 2>/dev/null || true
[ -f "$SRC/conf/neocrash.conf" ] && cp -n "$SRC/conf/neocrash.conf" "$dir/neocrash.conf"

chmod +x "$dir/bin/neocrash"

[ -f "$dir/neocrash.conf" ] || touch "$dir/neocrash.conf"

# ── Detect architecture ──────────────────────────

_detect_arch() {
  local machine
  machine="$(uname -m)"
  case "$machine" in
  x86_64) echo "amd64" ;;
  aarch64) echo "arm64" ;;
  armv7*) echo "armv7" ;;
  armv6*) echo "armv6" ;;
  i386 | i686) echo "386" ;;
  *) echo "$machine" ;;
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
  MIHOMO_VER="$(curl -fsSL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" |
    grep '"tag_name"' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"

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
  grep -q '^core_type=' "$dir/neocrash.conf" &&
    sed -i 's/^core_type=.*/core_type=mihomo/' "$dir/neocrash.conf" ||
    echo "core_type=mihomo" >>"$dir/neocrash.conf"
  ;;

2)
  echo ""
  t fetching_singbox
  SB_VER="$(curl -fsSL "https://api.github.com/repos/SagerNet/sing-box/releases/latest" |
    grep '"tag_name"' | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"

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

  grep -q '^core_type=' "$dir/neocrash.conf" &&
    sed -i 's/^core_type=.*/core_type=singbox/' "$dir/neocrash.conf" ||
    echo "core_type=singbox" >>"$dir/neocrash.conf"
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

# Save chosen language to config
if [ -n "$_chosen_lang" ]; then
  grep -q '^lang=' "$dir/neocrash.conf" &&
    sed -i "s/^lang=.*/lang=$_chosen_lang/" "$dir/neocrash.conf" ||
    echo "lang=$_chosen_lang" >>"$dir/neocrash.conf"
fi

shellprofile=""
[ -f "$HOME/.bashrc" ] && shellprofile="$HOME/.bashrc"
[ -z "$shellprofile" ] && shellprofile="$HOME/.bashrc" && touch "$shellprofile"

sed -i '/neocrash/d' "$shellprofile" 2>/dev/null || true
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
