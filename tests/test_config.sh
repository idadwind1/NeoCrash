#!/usr/bin/env bash
set -euo pipefail
# Basic tests for NeoCrash config system

TMPDIR="$(mktemp -d)"
NEOCRASH_DIR="$TMPDIR"
mkdir -p "$NEOCRASH_DIR"
touch "$NEOCRASH_DIR/neocrash.conf"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$SCRIPT_DIR/lib/config.sh"

passed=0
failed=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $desc"
        passed=$((passed + 1))
    else
        echo "  FAIL: $desc (expected '$expected', got '$actual')"
        failed=$((failed + 1))
    fi
}

echo "Running config tests..."

# Test setconfig + getconfig round-trip
setconfig mix_port 8080
getconfig
assert_eq "setconfig/getconfig round-trip" "8080" "$mix_port"

# Test overwrite
setconfig mix_port 9999
getconfig
assert_eq "setconfig overwrite" "9999" "$mix_port"

# Test defaults for unset values
: >"$NEOCRASH_DIR/neocrash.conf"  # clear config
unset mix_port api_port dns_port core_type active_profile update_cron
getconfig
assert_eq "default mix_port" "7890" "$mix_port"
assert_eq "default api_port" "9090" "$api_port"
assert_eq "default dns_port" "1053" "$dns_port"
assert_eq "default core_type" "mihomo" "$core_type"

# Test custom config file path
local_conf="$TMPDIR/custom.conf"
touch "$local_conf"
setconfig foo bar "$local_conf"
. "$local_conf"
assert_eq "custom config file" "bar" "$foo"

# Cleanup
rm -rf "$TMPDIR"

echo ""
echo "Results: $passed passed, $failed failed"
[ "$failed" -eq 0 ] || exit 1
