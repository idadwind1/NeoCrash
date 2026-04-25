#!/usr/bin/env bash
# Crontab management for NeoCrash
# Adapted from ShellCrash set_cron.sh by Juewuy

CRON_TAG="# neocrash-update"

cron_load() {
  crontab -l 2>/dev/null
}

# $1=keyword to match  $2=new cron line (empty to just remove)
cron_set() {
  local tmpfile
  tmpfile="$(mktemp)"
  cron_load | grep -vF "$1" >"$tmpfile"
  [ -n "$2" ] && echo "$2" >>"$tmpfile"
  crontab "$tmpfile"
  rm -f "$tmpfile"
}

cron_remove() {
  cron_set "$CRON_TAG" ""
}

# $1=cron schedule (e.g. "0 */6 * * *")
cron_set_update() {
  local schedule="$1"
  local neocrash_bin="$NEOCRASH_DIR/bin/neocrash"
  local entry="${schedule} NEOCRASH_DIR=\"$NEOCRASH_DIR\" \"$neocrash_bin\" update $CRON_TAG"
  cron_set "$CRON_TAG" "$entry"
  setconfig update_cron "$schedule"
  update_cron="$schedule"
}

cron_show() {
  local entry
  entry="$(cron_load | grep -F "$CRON_TAG")"
  if [ -n "$entry" ]; then
    echo "$entry"
  else
    t no_scheduled_updates
  fi
}
