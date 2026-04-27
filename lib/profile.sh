#!/usr/bin/env bash
# Profile management for NeoCrash

PROFILE_DIR="$NEOCRASH_DIR/profiles"

_ensure_profile_dir() {
  mkdir -p "$PROFILE_DIR"
}

# List profile names (without extensions)
profile_list() {
  _ensure_profile_dir
  local found=0
  for f in "$PROFILE_DIR"/*.url; do
    [ -f "$f" ] || continue
    local name
    name="$(basename "$f" .url)"
    if [ "$name" = "$active_profile" ]; then
      tf profile_active "$name"
    else
      echo "$name"
    fi
    found=1
  done
  [ "$found" -eq 0 ] && return 1
  return 0
}

# List raw names only (no markers)
_profile_names() {
  _ensure_profile_dir
  for f in "$PROFILE_DIR"/*.url; do
    [ -f "$f" ] || continue
    basename "$f" .url
  done
}

# Import a local config file as a profile
# $1=name $2=path to local file
profile_import() {
  _ensure_profile_dir
  local name="$1" filepath="$2"

  if [ -z "$name" ] || [ -z "$filepath" ]; then
    t err_profile_import_usage >&2
    return 1
  fi

  if [ ! -f "$filepath" ]; then
    tf err_file_not_found "$filepath" >&2
    return 1
  fi

  local ext="yaml"
  if head -c1 "$filepath" | grep -q '{'; then
    ext="json"
  fi

  cp -f "$filepath" "$PROFILE_DIR/${name}.${ext}"
  # Mark as local (no URL)
  echo "local:$filepath" >"$PROFILE_DIR/${name}.url"
  tf profile_imported "$name" "$filepath"
}

# Download a URL and detect config type by content
# $1=name $2=url
profile_add() {
  _ensure_profile_dir
  local name="$1" url="$2"

  if [ -z "$name" ] || [ -z "$url" ]; then
    t err_profile_add_usage >&2
    return 1
  fi

  local tmpfile="$PROFILE_DIR/${name}.tmp"
  if ! curl -fsSL --connect-timeout 10 -o "$tmpfile" "$url"; then
    rm -f "$tmpfile"
    t err_download_url >&2
    return 1
  fi

  local ext="yaml"
  if head -c1 "$tmpfile" | grep -q '{'; then
    ext="json"
  fi

  mv -f "$tmpfile" "$PROFILE_DIR/${name}.${ext}"
  echo "$url" >"$PROFILE_DIR/${name}.url"
  tf profile_added "$name"
}

# $1=name
profile_remove() {
  local name="$1"
  if [ -z "$name" ]; then
    t err_profile_remove_usage >&2
    return 1
  fi
  if [ ! -f "$PROFILE_DIR/${name}.url" ]; then
    tf err_profile_not_found "$name" >&2
    return 1
  fi

  rm -f "$PROFILE_DIR/${name}".*

  if [ "$active_profile" = "$name" ]; then
    setconfig active_profile ""
    active_profile=""
  fi
  tf profile_removed "$name"
}

# $1=name
profile_switch() {
  local name="$1"
  if [ -z "$name" ]; then
    t err_profile_switch_usage >&2
    return 1
  fi

  if [ ! -f "$PROFILE_DIR/${name}.url" ]; then
    tf err_profile_not_found "$name" >&2
    return 1
  fi

  local was_running=0
  if core_status >/dev/null 2>&1; then
    was_running=1
    core_stop
  fi

  setconfig active_profile "$name"
  active_profile="$name"

  if [ "$was_running" -eq 1 ]; then
    core_start
  else
    tf profile_switched "$name"
  fi
}

# Re-download profile from stored URL
# $1=name (optional, defaults to active_profile)
profile_update() {
  local name="${1:-$active_profile}"
  if [ -z "$name" ]; then
    t err_no_profile_specified >&2
    return 1
  fi

  local urlfile="$PROFILE_DIR/${name}.url"
  if [ ! -f "$urlfile" ]; then
    tf err_no_url_stored "$name" >&2
    return 1
  fi

  local url
  url="$(cat "$urlfile")"
  local was_running=0
  if [ "$name" = "$active_profile" ] && core_status >/dev/null 2>&1; then
    was_running=1
    core_stop
  fi

  rm -f "$PROFILE_DIR/${name}".yaml "$PROFILE_DIR/${name}".json

  # Handle local imports vs remote URLs
  if [[ "$url" == local:* ]]; then
    local localpath="${url#local:}"
    if [ ! -f "$localpath" ]; then
      tf err_local_file_gone "$localpath" >&2
      [ "$was_running" -eq 1 ] && core_start
      return 1
    fi
    local ext="yaml"
    if head -c1 "$localpath" | grep -q '{'; then
      ext="json"
    fi
    cp -f "$localpath" "$PROFILE_DIR/${name}.${ext}"
  else
    local tmpfile="$PROFILE_DIR/${name}.tmp"
    if ! curl -fsSL --connect-timeout 10 -o "$tmpfile" "$url"; then
      rm -f "$tmpfile"
      tf err_profile_update_failed "$name" >&2
      [ "$was_running" -eq 1 ] && core_start
      return 1
    fi

    local ext="yaml"
    if head -c1 "$tmpfile" | grep -q '{'; then
      ext="json"
    fi
    mv -f "$tmpfile" "$PROFILE_DIR/${name}.${ext}"
  fi

  if [ "$was_running" -eq 1 ]; then
    core_start
  else
    tf profile_updated "$name"
  fi
}

profile_update_all() {
  local names
  names="$(_profile_names)" || {
    t no_profiles_found >&2
    return 1
  }

  local name
  while IFS= read -r name; do
    tf profile_updating "$name"
    profile_update "$name"
  done <<<"$names"
}
