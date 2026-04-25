#!/usr/bin/env bash
# Geodata management for NeoCrash
# Downloads and manages GeoIP/GeoSite databases

GEODATA_DIR="$NEOCRASH_DIR/geodata"

# Known geodata sources — name:filename:url
# Mihomo uses .dat and .mmdb formats
# Sing-box uses .db and .srs formats
_geodata_sources() {
  cat <<'EOF'
geoip.dat|geoip.dat|https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
geosite.dat|geosite.dat|https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
country.mmdb|Country.mmdb|https://github.com/Loyalsoldier/geoip/releases/latest/download/Country.mmdb
country-lite.mmdb|Country-lite.mmdb|https://github.com/Loyalsoldier/geoip/releases/latest/download/Country-only-cn-private.mmdb
geoip.db|geoip.db|https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db
geosite.db|geosite.db|https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db
geoip-cn.srs|geoip-cn.srs|https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip-cn.srs
geosite-cn.srs|geosite-cn.srs|https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite-cn.srs
EOF
}

_ensure_geodata_dir() {
  mkdir -p "$GEODATA_DIR"
}

# List available geodata files that can be downloaded
geodata_available() {
  t geodata_available_mihomo
  t geodata_item_geoip_dat
  t geodata_item_geosite_dat
  t geodata_item_country_mmdb
  t geodata_item_country_lite
  echo ""
  t geodata_available_singbox
  t geodata_item_geoip_db
  t geodata_item_geosite_db
  t geodata_item_geoip_cn
  t geodata_item_geosite_cn
}

# List installed geodata files with sizes
geodata_list() {
  _ensure_geodata_dir
  local found=0
  for f in "$GEODATA_DIR"/*; do
    [ -f "$f" ] || continue
    local name size date
    name="$(basename "$f")"
    size="$(du -h "$f" | cut -f1)"
    date="$(date -r "$f" +"%Y-%m-%d" 2>/dev/null || echo "unknown")"
    printf "  %-25s %6s  %s\n" "$name" "$size" "$date"
    found=1
  done
  [ "$found" -eq 0 ] && t no_geodata_installed
}

# Download a geodata file by name
# $1=name (e.g. "geoip.dat", "country.mmdb")
geodata_update() {
  _ensure_geodata_dir
  local name="${1:-}"

  if [ -z "$name" ]; then
    t err_geodata_update_usage >&2
    t hint_geodata_available >&2
    return 1
  fi

  local entry
  entry="$(_geodata_sources | grep "^${name}|")"

  if [ -z "$entry" ]; then
    tf err_geodata_unknown "$name" >&2
    t hint_geodata_available >&2
    return 1
  fi

  local filename url
  filename="$(echo "$entry" | cut -d'|' -f2)"
  url="$(echo "$entry" | cut -d'|' -f3)"

  tf geodata_downloading "$name"
  if ! curl -fSL --connect-timeout 15 --progress-bar -o "$GEODATA_DIR/${filename}.tmp" "$url"; then
    rm -f "$GEODATA_DIR/${filename}.tmp"
    t err_download_failed >&2
    return 1
  fi

  # Verify file is non-trivial (>1KB)
  local fsize
  fsize="$(wc -c <"$GEODATA_DIR/${filename}.tmp")"
  if [ "$fsize" -lt 1024 ]; then
    rm -f "$GEODATA_DIR/${filename}.tmp"
    tf err_geodata_too_small "$fsize" >&2
    return 1
  fi

  mv -f "$GEODATA_DIR/${filename}.tmp" "$GEODATA_DIR/$filename"
  local size
  size="$(du -h "$GEODATA_DIR/$filename" | cut -f1)"
  tf geodata_installed "$name" "$size"
}

# Download all geodata appropriate for the current core type
geodata_update_all() {
  _ensure_geodata_dir
  local names
  case "$core_type" in
  singbox) names="geoip.db geosite.db" ;;
  *) names="geoip.dat geosite.dat country.mmdb" ;;
  esac

  for name in $names; do
    geodata_update "$name"
  done
}

# Remove a geodata file
# $1=filename
geodata_remove() {
  local name="${1:-}"
  if [ -z "$name" ]; then
    t err_geodata_remove_usage >&2
    return 1
  fi

  if [ -f "$GEODATA_DIR/$name" ]; then
    rm -f "$GEODATA_DIR/$name"
    tf geodata_removed "$name"
  else
    tf err_geodata_not_found "$name" "$GEODATA_DIR" >&2
    return 1
  fi
}

# Import a local geodata file
# $1=path to file
geodata_import() {
  _ensure_geodata_dir
  local filepath="${1:-}"

  if [ -z "$filepath" ]; then
    t err_geodata_import_usage >&2
    return 1
  fi

  if [ ! -f "$filepath" ]; then
    tf err_file_not_found "$filepath" >&2
    return 1
  fi

  local filename
  filename="$(basename "$filepath")"
  cp -f "$filepath" "$GEODATA_DIR/$filename"
  local size
  size="$(du -h "$GEODATA_DIR/$filename" | cut -f1)"
  tf geodata_imported "$filename" "$size"
}
