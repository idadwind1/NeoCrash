#!/usr/bin/env bash
# i18n support for NeoCrash
# Locale files live in $NEOCRASH_DIR/locale/<lang>.sh
# Each locale file defines associative array entries: _NC_STRINGS[key]="translated string"
# Falls back to the key itself if no tranlation is found.

declare -gA _NC_STRINGS 2>/dev/null || declare -A _NC_STRINGS

i18n_load() {
  local lang="${NEOCRASH_LANG:-${LANG:-}}"
  # Normalize: "fr_FR.UTF-8" → "fr_FR", then "fr"
  lang="${lang%%.*}"
  local locale_dir="$NEOCRASH_DIR/locale"

  # Try full locale (e.g. fr_FR), then language only (e.g. fr)
  local f
  for f in "$locale_dir/${lang}.sh" "$locale_dir/${lang%%_*}.sh"; do
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
  local key="$1"; shift
  # shellcheck disable=SC2059
  printf "$(t "$key")\n" "$@"
}
