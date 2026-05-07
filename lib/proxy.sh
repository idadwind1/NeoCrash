#!/usr/bin/env bash
# Proxy group management for NeoCrash

# List all proxy groups
proxy_group_list() {
  local profile_file
  profile_file="$(_get_active_profile_file)" || return 1

  case "$core_type" in
  singbox)
    # Extract outbound groups from sing-box JSON
    grep -oP '"tag"\s*:\s*"\K[^"]+' "$profile_file" | grep -v '^direct$\|^block$\|^dns-out$'
    ;;
  *)
    # Extract proxy groups from mihomo YAML
    sed -n '/^proxy-groups:/,/^[^ ]/p' "$profile_file" | grep '  - name:' | sed 's/.*name: //'
    ;;
  esac
}

# List proxies in a group
# $1=group name
proxy_group_show() {
  local group="${1:-}"
  if [ -z "$group" ]; then
    t err_group_show_usage >&2
    return 1
  fi

  local profile_file
  profile_file="$(_get_active_profile_file)" || return 1

  case "$core_type" in
  singbox)
    # Extract outbounds for this tag
    grep -A 20 "\"tag\"[[:space:]]*:[[:space:]]*\"$group\"" "$profile_file" | grep -oP '"outbounds"\s*:\s*\[\K[^\]]+' | tr ',' '\n' | tr -d '"' | sed 's/^[[:space:]]*//'
    ;;
  *)
    # Extract proxies from mihomo group (multi-line YAML format)
    # Use yq if available, otherwise fall back to awk
    if command -v yq >/dev/null 2>&1; then
      yq eval ".proxy-groups[] | select(.name == \"$group\") | .proxies[]" "$profile_file" 2>/dev/null
    else
      # Awk fallback: extract proxy list items (8 spaces + dash)
      awk -v group="$group" '
        /^    - name: / { if ($3 == group) found=1; else found=0 }
        found && /^      proxies:/ { in_proxies=1; next }
        in_proxies && /^        - / { print substr($0, 11); next }
        in_proxies && /^      [a-z]/ { exit }
      ' "$profile_file"
    fi
    ;;
  esac
}

# Select active proxy in a group (via API)
# $1=group name  $2=proxy name
proxy_group_select() {
  local group="${1:-}" proxy="${2:-}"
  if [ -z "$group" ] || [ -z "$proxy" ]; then
    t err_group_select_usage >&2
    return 1
  fi

  if ! core_status >/dev/null 2>&1; then
    t err_core_not_running >&2
    return 1
  fi

  # Use mihomo API to switch proxy
  curl -fsSL -X PUT "http://${bind_address}:${api_port}/proxies/${group}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${proxy}\"}" >/dev/null

  tf group_selected "$proxy" "$group"
}

# Get active profile file path
_get_active_profile_file() {
  if [ -z "$active_profile" ]; then
    t err_no_active_profile >&2
    return 1
  fi

  local f
  for ext in yaml json; do
    f="$NEOCRASH_DIR/profiles/${active_profile}.${ext}"
    [ -f "$f" ] && echo "$f" && return 0
  done

  tf err_no_profile_file "$active_profile" >&2
  return 1
}
