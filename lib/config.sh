#!/usr/bin/env bash
# Config read/write for NeoCrash
# setconfig pattern adapted from ShellCrash by Juewuy

# Write a key=value pair to config file
# $1=key $2=value $3=file (optional, defaults to main config)
setconfig() {
  local file="${3:-$NEOCRASH_DIR/neocrash.conf}"
  sed -i "/^${1}=.*/d" "$file"
  printf '%s=%s\n' "$1" "$2" >>"$file"
}

# Source config and apply defaults for unset variables
getconfig() {
  local conf="$NEOCRASH_DIR/neocrash.conf"
  [ -f "$conf" ] && . "$conf"

  # Network
  : "${mix_port:=7890}"
  : "${socks_port:=7891}"
  : "${redir_port:=7892}"
  : "${api_port:=9090}"
  : "${dns_port:=1053}"
  : "${bind_address:=127.0.0.1}"

  # Core
  : "${core_type:=mihomo}"
  : "${log_level:=info}"

  # TUN
  : "${tun_mode:=off}"
  : "${tun_stack:=mixed}"
  : "${tun_device:=utun}"
  : "${tun_mtu:=9000}"
  : "${tun_auto_route:=true}"
  : "${tun_auto_detect:=true}"
  : "${tun_dns_hijack:=any:53}"
  : "${tun_inet4:=172.19.0.1/30}"
  : "${tun_inet6:=fdfe:dcba:9876::1/126}"

  # Profile
  : "${active_profile:=}"
  : "${update_cron:=}"
  : "${lang:=}"
}
