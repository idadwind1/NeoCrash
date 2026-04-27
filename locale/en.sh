#!/usr/bin/env bash
# English locale for NeoCrash

# core.sh
_NC_STRINGS[warn_tun_no_dev]="Warning: /dev/net/tun not found, may need: sudo modprobe tun"
_NC_STRINGS[err_no_profile_file]="Error: no config file found for profile: %s"
_NC_STRINGS[err_core_not_found]="Error: core binary '%s' not found"
_NC_STRINGS[err_no_active_profile]="Error: no active profile set. Use: neocrash profile switch <name>"
_NC_STRINGS[err_core_failed_start]="Error: %s failed to start"
_NC_STRINGS[core_started]="%s started"
_NC_STRINGS[core_started_tun]="%s started (TUN: %s)"
_NC_STRINGS[core_stopped]="%s stopped"
_NC_STRINGS[status_core]="core:      %s"
_NC_STRINGS[status_status]="status:    %s"
_NC_STRINGS[status_user]="user:      %s"
_NC_STRINGS[status_profile]="profile:   %s"
_NC_STRINGS[status_log_level]="log_level: %s"
_NC_STRINGS[status_bind]="bind:      %s"
_NC_STRINGS[status_mix_port]="mix_port:  %s"
_NC_STRINGS[status_tun_on]="tun:       on (stack: %s, device: %s, mtu: %s)"
_NC_STRINGS[status_tun_off]="tun:       off"
_NC_STRINGS[status_rules]="rules:     %s custom"
_NC_STRINGS[status_geodata]="geodata:   %s files"
_NC_STRINGS[core_running]="running (PID %s)"
_NC_STRINGS[stopped]="stopped"
_NC_STRINGS[warn_no_inbounds]="Warning: no inbounds array found in sing-box config, TUN not injected"

# profile.sh
_NC_STRINGS[profile_active]="%s (active)"
_NC_STRINGS[err_profile_import_usage]="Usage: neocrash profile import <name> <path>"
_NC_STRINGS[err_file_not_found]="Error: file not found: %s"
_NC_STRINGS[profile_imported]="Profile '%s' imported from %s"
_NC_STRINGS[err_profile_add_usage]="Usage: neocrash profile add <name> <url>"
_NC_STRINGS[err_download_url]="Error: failed to download from URL"
_NC_STRINGS[profile_added]="Profile '%s' added"
_NC_STRINGS[err_profile_remove_usage]="Usage: neocrash profile remove <name>"
_NC_STRINGS[err_profile_not_found]="Error: profile '%s' not found"
_NC_STRINGS[profile_removed]="Profile '%s' removed"
_NC_STRINGS[err_profile_switch_usage]="Usage: neocrash profile switch <name>"
_NC_STRINGS[profile_switched]="Switched to profile '%s'"
_NC_STRINGS[err_no_profile_specified]="Error: no profile specified and no active profile set"
_NC_STRINGS[err_no_url_stored]="Error: no URL stored for profile '%s'"
_NC_STRINGS[err_local_file_gone]="Error: local file no longer exists: %s"
_NC_STRINGS[err_profile_update_failed]="Error: failed to update profile '%s'"
_NC_STRINGS[profile_updated]="Profile '%s' updated"
_NC_STRINGS[no_profiles_found]="No profiles found"
_NC_STRINGS[profile_updating]="Updating %s..."

# geodata.sh
_NC_STRINGS[geodata_available_mihomo]="Mihomo (dat/mmdb):"
_NC_STRINGS[geodata_available_singbox]="Sing-box (db/srs):"
_NC_STRINGS[no_geodata_installed]="No geodata installed"
_NC_STRINGS[err_geodata_update_usage]="Usage: neocrash geodata update <name>"
_NC_STRINGS[hint_geodata_available]="Run 'neocrash geodata available' to see options"
_NC_STRINGS[err_geodata_unknown]="Error: unknown geodata '%s'"
_NC_STRINGS[geodata_downloading]="Downloading %s..."
_NC_STRINGS[err_download_failed]="Error: download failed"
_NC_STRINGS[err_geodata_too_small]="Error: downloaded file is too small (%s bytes), likely corrupted"
_NC_STRINGS[geodata_installed]="%s installed (%s)"
_NC_STRINGS[err_geodata_remove_usage]="Usage: neocrash geodata remove <filename>"
_NC_STRINGS[geodata_removed]="Removed: %s"
_NC_STRINGS[err_geodata_not_found]="Error: '%s' not found in %s"
_NC_STRINGS[err_geodata_import_usage]="Usage: neocrash geodata import <path>"
_NC_STRINGS[geodata_imported]="Imported: %s (%s)"

# geodata available items
_NC_STRINGS[geodata_item_geoip_dat]="  geoip.dat            GeoIP rules (Loyalsoldier)"
_NC_STRINGS[geodata_item_geosite_dat]="  geosite.dat          GeoSite rules (Loyalsoldier)"
_NC_STRINGS[geodata_item_country_mmdb]="  country.mmdb         MaxMind GeoIP (Loyalsoldier)"
_NC_STRINGS[geodata_item_country_lite]="  country-lite.mmdb    GeoIP CN+private only (Loyalsoldier)"
_NC_STRINGS[geodata_item_geoip_db]="  geoip.db             GeoIP database (SagerNet)"
_NC_STRINGS[geodata_item_geosite_db]="  geosite.db           GeoSite database (SagerNet)"
_NC_STRINGS[geodata_item_geoip_cn]="  geoip-cn.srs         GeoIP CN ruleset (SagerNet)"
_NC_STRINGS[geodata_item_geosite_cn]="  geosite-cn.srs       GeoSite CN ruleset (SagerNet)"

# usage fallbacks
_NC_STRINGS[err_rule_subcmd_usage]="Usage: neocrash rule <add|remove|list> [args]"
_NC_STRINGS[err_geodata_subcmd_usage]="Usage: neocrash geodata <list|available|update|update-all|remove|import> [args]"
_NC_STRINGS[err_profile_subcmd_usage]="Usage: neocrash profile <list|add|import|remove|switch|update|update-all> [args]"
_NC_STRINGS[err_config_subcmd_usage]="Usage: neocrash config show"
_NC_STRINGS[no_scheduled_updates]="No scheduled updates"

# bin/neocrash
_NC_STRINGS[no_custom_rules]="No custom rules"
_NC_STRINGS[auto_update_disabled]="Auto-update disabled"
_NC_STRINGS[err_set_usage]="Usage: neocrash set <key> <value>"
_NC_STRINGS[hint_keys]="Run 'neocrash --help' to see available keys"
_NC_STRINGS[err_set_cron_usage]="Usage: neocrash set cron <schedule|off>"
_NC_STRINGS[err_set_value_usage]="Usage: neocrash set %s <value>"
_NC_STRINGS[err_invalid_port]="Error: invalid port '%s' (must be 1-65535)"
_NC_STRINGS[err_core_type]="Error: core_type must be 'mihomo' or 'singbox'"
_NC_STRINGS[err_log_level]="Error: log_level must be silent|error|warning|info|debug"
_NC_STRINGS[err_tun_mode]="Error: tun_mode must be 'on' or 'off'"
_NC_STRINGS[err_tun_stack]="Error: tun_stack must be 'system', 'gvisor', or 'mixed'"
_NC_STRINGS[err_tun_bool]="Error: %s must be 'true' or 'false'"
_NC_STRINGS[err_tun_mtu]="Error: tun_mtu must be 576-65535"
_NC_STRINGS[err_unknown_key]="Error: unknown key '%s'"
_NC_STRINGS[err_rule_add_usage]="Usage: neocrash rule add <TYPE,value,action>"
_NC_STRINGS[err_rule_add_example]="Example: neocrash rule add \"DOMAIN-SUFFIX,example.com,DIRECT\""
_NC_STRINGS[err_unknown_rule_type]="Error: unknown rule type '%s'"
_NC_STRINGS[hint_rule_types]="Valid types: DOMAIN, DOMAIN-SUFFIX, DOMAIN-KEYWORD, IP-CIDR, GEOIP, GEOSITE"
_NC_STRINGS[err_rule_value]="Error: rule value is required"
_NC_STRINGS[err_rule_action]="Error: rule action is required (e.g. DIRECT, REJECT, Proxy)"
_NC_STRINGS[rule_added]="Rule added: %s"
_NC_STRINGS[err_rule_remove_usage]="Usage: neocrash rule remove <line_number>"
_NC_STRINGS[err_no_rules_file]="Error: no rules file"
_NC_STRINGS[err_line_out_of_range]="Error: line %s out of range (1-%s)"
_NC_STRINGS[rule_removed]="Removed: %s"
_NC_STRINGS[err_unknown_cmd]="Unknown command: %s"
_NC_STRINGS[hint_help]="Run 'neocrash --help' for usage"

# help
_NC_STRINGS[help_text]='neocrash — proxy core manager for mihomo / sing-box

Usage: neocrash <command> [args]

Service:
  start                         Start the proxy core
  stop                          Stop the proxy core
  restart                       Restart the proxy core
  status                        Show core status

Profiles:
  profile list                  List all profiles
  profile add <name> <url>      Add a profile from subscription URL
  profile import <name> <path>  Import a local config file
  profile remove <name>         Remove a profile
  profile switch <name>         Switch to a profile
  profile update [name]         Re-download profile (default: active)
  profile update-all            Update all profiles

Rules:
  rule add <rule>               Add a custom routing rule
  rule remove <number>          Remove a rule by line number
  rule list                     List all custom rules

  Rule format (mihomo-style, comma-separated):
    DOMAIN,example.com,DIRECT
    DOMAIN-SUFFIX,google.com,Proxy
    DOMAIN-KEYWORD,ads,REJECT
    IP-CIDR,192.168.0.0/16,DIRECT
    GEOIP,CN,DIRECT
    GEOSITE,category-ads,REJECT

Geodata:
  geodata list                  List installed geodata files
  geodata available             Show downloadable geodata files
  geodata update <name>         Download/update a geodata file
  geodata update-all            Download all geodata for current core
  geodata remove <name>         Remove a geodata file
  geodata import <path>         Import a local geodata file

Settings:
  set <key> <value>             Set a config value (see keys below)
  config show                   Show current config

  Network keys:
    mix_port      Mixed (HTTP+SOCKS) port        (default: 7890)
    socks_port    SOCKS5 port                     (default: 7891)
    redir_port    Transparent proxy port          (default: 7892)
    api_port      API/dashboard port              (default: 9090)
    dns_port      DNS listen port                 (default: 1053)
    bind_address  Listen address                  (default: 127.0.0.1)

  Core keys:
    core_type     mihomo | singbox                (default: mihomo)
    log_level     silent|error|warning|info|debug (default: info)

  TUN keys:
    tun_mode      on | off                        (default: off)
    tun_stack     system | gvisor | mixed          (default: mixed)
    tun_device    TUN interface name               (default: utun)
    tun_mtu       MTU size                         (default: 9000)
    tun_auto_route    true | false                 (default: true)
    tun_auto_detect   true | false                 (default: true)
    tun_dns_hijack    DNS hijack target             (default: any:53)
    tun_inet4     TUN IPv4 CIDR                    (default: 172.19.0.1/30)
    tun_inet6     TUN IPv6 CIDR                    (default: fdfe:dcba:9876::1/126)

  Cron:
    cron          Cron schedule | off              (default: off)

  version                       Show version
  -h, --help                    Show this help

Examples:
  neocrash profile add work https://example.com/sub
  neocrash profile import local /path/to/config.yaml
  neocrash profile switch work
  neocrash start
  neocrash set mix_port 7891
  neocrash set log_level debug
  neocrash set tun_mode on
  neocrash rule add "DOMAIN-SUFFIX,example.com,DIRECT"
  neocrash geodata update geoip.dat
  neocrash geodata update-all
  neocrash set cron "0 */6 * * *"'
