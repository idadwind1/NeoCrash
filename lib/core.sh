#!/usr/bin/env bash
# Core (mihomo / sing-box) process management
# Launch pattern adapted from ShellCrash by Juewuy

PIDFILE="$NEOCRASH_DIR/neocrash.pid"
RUNDIR="$NEOCRASH_DIR/run"

# Locate the core binary
# Sets CORE_BIN to the found path, or returns 1
core_find() {
  CORE_BIN=""
  local name
  case "$core_type" in
  singbox) name="sing-box" ;;
  *) name="mihomo" ;;
  esac

  if [ -x "$NEOCRASH_DIR/bin/$name" ]; then
    CORE_BIN="$NEOCRASH_DIR/bin/$name"
  elif command -v "$name" >/dev/null 2>&1; then
    CORE_BIN="$(command -v "$name")"
  else
    return 1
  fi
}

# Prepare tun kernel module
_tun_prepare() {
  [ "$tun_mode" != "on" ] && return 0

  if [ ! -e /dev/net/tun ]; then
    if [ "$(id -u)" -eq 0 ]; then
      modprobe tun 2>/dev/null || true
    else
      t warn_tun_no_dev >&2
    fi
  fi
}

# Patch mihomo yaml: inject/override settings from neocrash config
# $1=source profile  $2=output file
_patch_mihomo() {
  local src="$1" dst="$2"
  cp -f "$src" "$dst"

  # Override network settings
  sed -i "s/^mixed-port:.*/mixed-port: $mix_port/" "$dst"
  sed -i "s/^socks-port:.*/socks-port: $socks_port/" "$dst"
  sed -i "s/^redir-port:.*/redir-port: $redir_port/" "$dst"
  sed -i "s/^external-controller:.*/external-controller: $bind_address:$api_port/" "$dst"
  grep -q '^mixed-port:' "$dst" || echo "mixed-port: $mix_port" >>"$dst"
  grep -q '^socks-port:' "$dst" || echo "socks-port: $socks_port" >>"$dst"
  grep -q '^external-controller:' "$dst" || echo "external-controller: $bind_address:$api_port" >>"$dst"
  grep -q '^bind-address:' "$dst" && sed -i "s/^bind-address:.*/bind-address: \"$bind_address\"/" "$dst"

  # Log level
  if grep -q '^log-level:' "$dst" 2>/dev/null; then
    sed -i "s/^log-level:.*/log-level: $log_level/" "$dst"
  else
    echo "log-level: $log_level" >>"$dst"
  fi

  # Custom rules — prepend to the rules: list
  local rulesfile="$NEOCRASH_DIR/rules.txt"
  if [ -f "$rulesfile" ] && [ -s "$rulesfile" ]; then
    local rules_yaml=""
    while IFS= read -r rule; do
      [ -z "$rule" ] && continue
      [[ "$rule" =~ ^# ]] && continue
      rules_yaml="${rules_yaml}  - ${rule}\n"
    done <"$rulesfile"
    if [ -n "$rules_yaml" ] && grep -q '^rules:' "$dst" 2>/dev/null; then
      sed -i "/^rules:/a\\$(printf '%b' "$rules_yaml")" "$dst"
    fi
  fi

  # TUN
  if [ "$tun_mode" = "on" ]; then
    # Remove existing tun block (everything indented under tun:)
    if grep -q '^tun:' "$dst" 2>/dev/null; then
      sed -i '/^tun:/,/^[^ ]/{/^tun:/d;/^  /d}' "$dst"
    fi
    cat >>"$dst" <<EOF

tun:
  enable: true
  stack: $tun_stack
  device: $tun_device
  mtu: $tun_mtu
  auto-route: $tun_auto_route
  auto-detect-interface: $tun_auto_detect
  dns-hijack:
    - "$tun_dns_hijack"
EOF
  fi
}

# Patch sing-box json: inject/override settings from neocrash config
# $1=source profile  $2=output file
_patch_singbox() {
  local src="$1" dst="$2"
  cp -f "$src" "$dst"

  # Override mixed inbound port if present
  sed -i "s/\"listen_port\"[[:space:]]*:[[:space:]]*[0-9]*/\"listen_port\": $mix_port/" "$dst"

  # Log level
  sed -i "s/\"level\"[[:space:]]*:[[:space:]]*\"[a-z]*\"/\"level\": \"$log_level\"/" "$dst"

  # Custom rules — inject into route.rules array
  local rulesfile="$NEOCRASH_DIR/rules.txt"
  if [ -f "$rulesfile" ] && [ -s "$rulesfile" ]; then
    local rule_entries=""
    while IFS=',' read -r rtype rvalue raction || [ -n "$rtype" ]; do
      [ -z "$rtype" ] && continue
      [[ "$rtype" =~ ^# ]] && continue
      rtype="$(echo "$rtype" | tr -d ' ')"
      rvalue="$(echo "$rvalue" | tr -d ' ')"
      raction="$(echo "$raction" | tr -d ' ')"
      # Map common mihomo rule types to sing-box
      local sb_type=""
      case "$rtype" in
      DOMAIN) sb_type="domain" ;;
      DOMAIN-SUFFIX) sb_type="domain_suffix" ;;
      DOMAIN-KEYWORD) sb_type="domain_keyword" ;;
      IP-CIDR) sb_type="ip_cidr" ;;
      GEOIP) sb_type="geoip" ;;
      GEOSITE) sb_type="geosite" ;;
      *) continue ;;
      esac
      local outbound="${raction:-direct}"
      if [ -n "$rule_entries" ]; then
        rule_entries="${rule_entries},"
      fi
      rule_entries="${rule_entries}{\"${sb_type}\":[\"${rvalue}\"],\"outbound\":\"${outbound}\"}"
    done <"$rulesfile"
    if [ -n "$rule_entries" ] && grep -q '"rules"' "$dst" 2>/dev/null; then
      sed -i "s/\"rules\"[[:space:]]*:[[:space:]]*\[/\"rules\": [$rule_entries,/" "$dst"
    fi
  fi

  # TUN
  if [ "$tun_mode" = "on" ]; then
    if grep -q '"type"[[:space:]]*:[[:space:]]*"tun"' "$dst" 2>/dev/null; then
      return 0
    fi

    local tun_inbound
    tun_inbound="{\"type\":\"tun\",\"tag\":\"tun-in\",\"interface_name\":\"$tun_device\",\"inet4_address\":\"$tun_inet4\",\"inet6_address\":\"$tun_inet6\",\"mtu\":$tun_mtu,\"stack\":\"$tun_stack\",\"auto_route\":$tun_auto_route,\"sniff\":true}"

    if grep -q '"inbounds"' "$dst" 2>/dev/null; then
      sed -i "s/\"inbounds\"[[:space:]]*:[[:space:]]*\[/\"inbounds\": [$tun_inbound,/" "$dst"
    else
      t warn_no_inbounds >&2
    fi
  fi
}

# Build the launch command based on core type and active profile
_core_command() {
  local profile_dir="$NEOCRASH_DIR/profiles"
  local profile_file

  profile_file="$(find "$profile_dir" -maxdepth 1 -name "${active_profile}.*" \
    ! -name "*.url" 2>/dev/null | head -n1)"

  if [ -z "$profile_file" ]; then
    tf err_no_profile_file "$active_profile" >&2
    return 1
  fi

  mkdir -p "$RUNDIR"

  # Symlink geodata files into run dir so the core can find them
  local geodir="$NEOCRASH_DIR/geodata"
  if [ -d "$geodir" ]; then
    for gf in "$geodir"/*; do
      [ -f "$gf" ] || continue
      ln -sf "$gf" "$RUNDIR/$(basename "$gf")"
    done
  fi

  case "$core_type" in
  singbox)
    _patch_singbox "$profile_file" "$RUNDIR/config.json"
    echo "$CORE_BIN run -D $NEOCRASH_DIR -C $RUNDIR"
    ;;
  *)
    _patch_mihomo "$profile_file" "$RUNDIR/config.yaml"
    echo "$CORE_BIN -d $NEOCRASH_DIR -f $RUNDIR/config.yaml"
    ;;
  esac
}

core_start() {
  if core_status >/dev/null 2>&1; then
    tf core_started "$core_type"
    return 0
  fi

  if ! core_find; then
    tf err_core_not_found "$core_type" >&2
    return 1
  fi

  if [ -z "$active_profile" ]; then
    t err_no_active_profile >&2
    return 1
  fi

  _tun_prepare

  local cmd
  cmd="$(_core_command)" || return 1

  LOGFILE="$NEOCRASH_DIR/neocrash.log"
  nohup $cmd >>"$LOGFILE" 2>&1 &
  echo $! >"$PIDFILE"

  sleep 1
  if core_status >/dev/null 2>&1; then
    if [ "$tun_mode" = "on" ]; then
      tf core_started_tun "$core_type" "$tun_stack"
    else
      tf core_started "$core_type"
    fi
  else
    rm -f "$PIDFILE"
    tf err_core_failed_start "$core_type" >&2
    return 1
  fi
}

core_stop() {
  if [ ! -f "$PIDFILE" ]; then
    tf core_stopped "$core_type"
    return 0
  fi

  local pid
  pid="$(cat "$PIDFILE")"
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null
    local i=0
    while kill -0 "$pid" 2>/dev/null && [ $i -lt 10 ]; do
      sleep 0.2
      i=$((i + 1))
    done
    kill -0 "$pid" 2>/dev/null && kill -9 "$pid" 2>/dev/null
  fi
  rm -f "$PIDFILE"
  tf core_stopped "$core_type"
}

core_restart() {
  core_stop
  core_start
}

core_show_status() {
  local state
  state="$(core_status)" || true
  tf status_core "$core_type"
  tf status_status "$state"
  if [ -f "$PIDFILE" ]; then
    local pid user
    pid="$(cat "$PIDFILE")"
    user="$(ps -o user= -p "$pid" 2>/dev/null || echo "unknown")"
    tf status_user "$user"
  fi
  tf status_profile "${active_profile:-none}"
  tf status_log_level "$log_level"
  tf status_bind "$bind_address"
  tf status_mix_port "$mix_port"
  if [ "$tun_mode" = "on" ]; then
    tf status_tun_on "$tun_stack" "$tun_device" "$tun_mtu"
  else
    t status_tun_off
  fi
  local rcount=0 rules_file="$NEOCRASH_DIR/rules.txt"
  [ -f "$rules_file" ] && rcount=$(grep -cv -e '^\s*$' -e '^#' "$rules_file" 2>/dev/null) || rcount=0
  tf status_rules "$rcount"
  local gcount=0
  [ -d "$GEODATA_DIR" ] && gcount=$(find "$GEODATA_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)
  tf status_geodata "$gcount"
}
core_status() {
  if [ -f "$PIDFILE" ]; then
    local pid
    pid="$(cat "$PIDFILE")"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      tf core_running "$pid"
      return 0
    fi
  fi
  t stopped
  return 1
}
