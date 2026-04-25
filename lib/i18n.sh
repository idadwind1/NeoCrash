#!/usr/bin/env bash
# i18n support for NeoCrash
# Locale files live in $NEOCRASH_DIR/locale/<lang>.sh
# Each locale file defines associative array entries: _NC_STRINGS[key]="translated string"
# Falls back to the key itself if no tranlation is found.

declare -gA _NC_STRINGS 2>/dev/null || declare -A _NC_STRINGS

i18n_load() {
  # Priority: NEOCRASH_LANG env > lang config var > system LANG
  local resolved="${NEOCRASH_LANG:-${lang:-${LANG:-}}}"
  resolved="${resolved%%.*}"
  local locale_dir="$NEOCRASH_DIR/locale"

  local f
  for f in "$locale_dir/${resolved}.sh" "$locale_dir/${resolved%%_*}.sh"; do
    if [ -f "$f" ]; then
      # shellcheck source=/dev/null
      . "$f"
      return 0
    fi
  done
}

# t <key> [fallback]
# Prints the translated string for key, or fallback, or key itself.
t() {
  local key="$1"
  local fallback="${2:-$key}"
  echo "${_NC_STRINGS[$key]:-$fallback}"
}

# tf <key> [printf_args...]
# Like t() but passes result through printf for %s substitution.
tf() {
  local key="$1"
  shift
  # shellcheck disable=SC2059
  printf "$(t "$key")\n" "$@"
}
