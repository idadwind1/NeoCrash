#!/usr/bin/env bash
# Simplified Chinese locale for NeoCrash

# core.sh
_NC_STRINGS[warn_tun_no_dev]="警告：找不到 /dev/net/tun，可能需要执行：sudo modprobe tun"
_NC_STRINGS[err_no_profile_file]="错误：找不到订阅 %s 的配置文件"
_NC_STRINGS[err_core_not_found]="错误：找不到核心二进制文件“%s”"
_NC_STRINGS[err_no_active_profile]="错误：未设置当前订阅。请使用：neocrash profile switch <名称>"
_NC_STRINGS[err_core_failed_start]="错误：%s 启动失败"
_NC_STRINGS[core_started]="%s 已启动"
_NC_STRINGS[core_started_tun]="%s 已启动（虚拟网卡：%s）"
_NC_STRINGS[core_running]="运行中（PID %s）"
_NC_STRINGS[core_stopped]="已停止"
_NC_STRINGS[warn_no_inbounds]="警告：sing-box 配置中找不到入站规则数组，虚拟网卡未注入"

# profile.sh
_NC_STRINGS[profile_active]="%s（当前）"
_NC_STRINGS[err_profile_import_usage]="用法：neocrash profile import <名称> <路径>"
_NC_STRINGS[err_file_not_found]="错误：找不到文件：%s"
_NC_STRINGS[profile_imported]="订阅“%s”已从 %s 导入"
_NC_STRINGS[err_profile_add_usage]="用法：neocrash profile add <名称> <url>"
_NC_STRINGS[err_download_url]="错误：从 URL 下载失败"
_NC_STRINGS[profile_added]="订阅“%s”已添加"
_NC_STRINGS[err_profile_remove_usage]="用法：neocrash profile remove <名称>"
_NC_STRINGS[err_profile_not_found]="错误：找不到订阅“%s”"
_NC_STRINGS[profile_removed]="订阅“%s”已移除"
_NC_STRINGS[err_profile_switch_usage]="用法：neocrash profile switch <名称>"
_NC_STRINGS[profile_switched]="已切换到订阅“%s”"
_NC_STRINGS[err_no_profile_specified]="错误：未指定要更新的订阅，也没有当前订阅"
_NC_STRINGS[err_no_url_stored]="错误：没有存储订阅“%s”的 URL"
_NC_STRINGS[err_local_file_gone]="错误：本地文件不再存在：%s"
_NC_STRINGS[err_profile_update_failed]="错误：更新订阅“%s”失败"
_NC_STRINGS[profile_updated]="订阅“%s”已更新"
_NC_STRINGS[no_profiles_found]="没有订阅"
_NC_STRINGS[profile_updating]="正在更新 %s……"

# geodata.sh
_NC_STRINGS[geodata_available_mihomo]="Mihomo (dat/mmdb):"
_NC_STRINGS[geodata_available_singbox]="Sing-box (db/srs):"
_NC_STRINGS[no_geodata_installed]="未安装 geodata"
_NC_STRINGS[err_geodata_update_usage]="用法：neocrash geodata update <名称>"
_NC_STRINGS[hint_geodata_available]="请执行“neocrash geodata available”以查看可选项"
_NC_STRINGS[err_geodata_unknown]="错误：未知的 geodata “%s”"
_NC_STRINGS[geodata_downloading]="正在下载 %s……"
_NC_STRINGS[err_download_failed]="错误：下载失败"
_NC_STRINGS[err_geodata_too_small]="错误：下载下来的文件过小（%s 字节），可能损坏"
_NC_STRINGS[geodata_installed]="%s 已安装（%s）"
_NC_STRINGS[err_geodata_remove_usage]="用法：neocrash geodata remove <文件名>"
_NC_STRINGS[geodata_removed]="已移除：%s"
_NC_STRINGS[err_geodata_not_found]="错误：“%s”在 %s 中找不到"
_NC_STRINGS[err_geodata_import_usage]="用法：neocrash geodata import <路径>"
_NC_STRINGS[geodata_imported]="已导入：%s（%s）"

# geodata available items
_NC_STRINGS[geodata_item_geoip_dat]="  geoip.dat            GeoIP 规则集（Loyalsoldier）"
_NC_STRINGS[geodata_item_geosite_dat]="  geosite.dat          GeoSite 规则集（Loyalsoldier）"
_NC_STRINGS[geodata_item_country_mmdb]="  country.mmdb         MaxMind GeoIP（Loyalsoldier）"
_NC_STRINGS[geodata_item_country_lite]="  country-lite.mmdb    GeoIP 仅中国大陆+内网（Loyalsoldier）"
_NC_STRINGS[geodata_item_geoip_db]="  geoip.db             GeoIP 数据库（SagerNet）"
_NC_STRINGS[geodata_item_geosite_db]="  geosite.db           GeoSite 数据库（SagerNet）"
_NC_STRINGS[geodata_item_geoip_cn]="  geoip-cn.srs         GeoIP 中国大陆规则集（SagerNet）"
_NC_STRINGS[geodata_item_geosite_cn]="  geosite-cn.srs       GeoSite 中国大陆规则集（SagerNet）"

# usage fallbacks
_NC_STRINGS[err_rule_subcmd_usage]="用法：neocrash rule <add|remove|list> [参数]"
_NC_STRINGS[err_geodata_subcmd_usage]="用法：neocrash geodata <list|available|update|update-all|remove|import> [参数]"
_NC_STRINGS[err_profile_subcmd_usage]="用法：neocrash profile <list|add|import|remove|switch|update|update-all> [参数]"
_NC_STRINGS[err_config_subcmd_usage]="用法：neocrash config show"
_NC_STRINGS[no_scheduled_updates]="未设置定时更新"

# bin/neocrash
_NC_STRINGS[stopped]="已停止"
_NC_STRINGS[no_custom_rules]="没有自定义规则"
_NC_STRINGS[auto_update_disabled]="自动更新已禁用"
_NC_STRINGS[err_set_usage]="用法：neocrash set <键> <值>"
_NC_STRINGS[hint_keys]="执行“neocrash --help”以查看可用的键"
_NC_STRINGS[err_set_cron_usage]="用法：neocrash set cron <schedule|off>"
_NC_STRINGS[err_set_value_usage]="用法：neocrash set %s <值>"
_NC_STRINGS[err_invalid_port]="错误：无效的端口号“%s”（必须在 1～65535 之间）"
_NC_STRINGS[err_core_type]="错误：core_type 必须是“mihomo”或“singbox”"
_NC_STRINGS[err_log_level]="错误：log_level 必须是 silent|error|warning|info|debug"
_NC_STRINGS[err_tun_mode]="错误：tun_mode 必须是“on”或“off”"
_NC_STRINGS[err_tun_stack]="错误：tun_stack 必须是“system”“gvisor”或“mixed”"
_NC_STRINGS[err_tun_bool]="错误：%s 必须是“true”或“false”"
_NC_STRINGS[err_tun_mtu]="错误：tun_mtu 必须在 576～65535 之间"
_NC_STRINGS[err_unknown_key]="错误：未知的键“%s”"
_NC_STRINGS[err_rule_add_usage]="用法：neocrash rule add <类型,值,策略>"
_NC_STRINGS[err_rule_add_example]="示例：neocrash rule add \"DOMAIN-SUFFIX,example.com,DIRECT\""
_NC_STRINGS[err_unknown_rule_type]="错误：未知的规则类型“%s”"
_NC_STRINGS[hint_rule_types]="合法的类型：DOMAIN、DOMAIN-SUFFIX、DOMAIN-KEYWORD、IP-CIDR、GEOIP、GEOSITE"
_NC_STRINGS[err_rule_value]="错误：规则值不能为空"
_NC_STRINGS[err_rule_action]="错误：规则策略不能为空（例如：DIRECT、REJECT、Proxy）"
_NC_STRINGS[rule_added]="规则已添加：%s"
_NC_STRINGS[err_rule_remove_usage]="用法：neocrash rule remove <行号>"
_NC_STRINGS[err_no_rules_file]="错误：没有规则文件"
_NC_STRINGS[err_line_out_of_range]="错误：行号 %s 超出范围（1～%s）"
_NC_STRINGS[rule_removed]="已移除：%s"
_NC_STRINGS[err_unknown_cmd]="未知的命令：%s"
_NC_STRINGS[hint_help]="执行“neocrash --help”查看用法"

# help
_NC_STRINGS[help_text]='neocrash —— mihomo / sing-box 代理核心管理工具

用法：neocrash <命令> [参数]

服务：
  start                         启动代理核心
  stop                          停止代理核心
  restart                       重启代理核心
  status                        显示核心状态

订阅：
  profile list                  列出所有订阅
  profile add <名称> <url>      从订阅链接添加订阅
  profile import <名称> <路径>  从本地导入订阅配置文件
  profile remove <名称>         移除订阅
  profile switch <名称>         切换到指定订阅
  profile update [名称]         重新下载订阅（默认：当前订阅）
  profile update-all            更新所有订阅

规则：
  rule add <规则>               添加自定义路由规则
  rule remove <行号>            按行号移除一条规则
  rule list                     列出所有自定义规则

  规则格式（mihomo 风格，用半角逗号分隔）：
    DOMAIN,example.com,DIRECT
    DOMAIN-SUFFIX,google.com,Proxy
    DOMAIN-KEYWORD,ads,REJECT
    IP-CIDR,192.168.0.0/16,DIRECT
    GEOIP,CN,DIRECT
    GEOSITE,category-ads,REJECT

Geodata:
  geodata list                  列出已安装的 geodata 文件
  geodata available             显示可下载的 geodata 文件
  geodata update <名称>         下载/更新 geodata 文件
  geodata update-all            下载当前核心的所有 geodata
  geodata remove <名称>         移除 geodata 文件
  geodata import <路径>         导入本地 geodata 文件

设置：
  set <键> <值>                 设置配置项（见下方的配置键）
  config show                   显示当前配置

  网络配置键：
    mix_port      混合端口（HTTP+SOCKS）          （默认：7890）
    socks_port    SOCKS5 端口                     （默认：7891）
    redir_port    透明代理端口                    （默认：7892）
    api_port      API/控制面板端口                （默认：9090）
    dns_port      DNS 监听端口                    （默认：1053）
    bind_address  监听地址                        （默认：127.0.0.1）

  核心配置键：
    core_type     mihomo | singbox                （默认：mihomo）
    log_level     silent|error|warning|info|debug （默认：info）

  虚拟网卡配置键：
    tun_mode      on | off                         （默认：off）
    tun_stack     system | gvisor | mixed          （默认：mixed）
    tun_device    虚拟网卡接口名称                 （默认：utun）
    tun_mtu       MTU 大小                         （默认：9000）
    tun_auto_route    true | false                 （默认：true）
    tun_auto_detect   true | false                 （默认：true）
    tun_dns_hijack    DNS 劫持目标                 （默认：any:53）
    tun_inet4     虚拟网卡 IPv4 CIDR               （默认：172.19.0.1/30）
    tun_inet6     虚拟网卡 IPv6 CIDR               （默认：fdfe:dcba:9876::1/126）

  定时任务：
    cron          Cron 表达式 | off              （默认：off）

  version                       显示版本
  -h, --help                    显示此帮助

示例：
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
