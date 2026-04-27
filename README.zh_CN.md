# NeoCrash

[English](./README.md) | 简体中文

一个极简的基于 shell 的代理管理工具，支持 [mihomo](https://github.com/MetaCubeX/mihomo) 和 [sing-box](https://github.com/SagerNet/sing-box)，fork 自 [ShellCrash](https://github.com/juewuy/ShellCrash)，但是提供了 CLI。

## 安装

运行
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/idadwind1/NeoCrash/main/install.sh)
source ~/.bashrc

neocrash -h # 查看帮助
```

## TUN模式

TUN模式需要root权限。如需使用请**使用root**运行`neocrash restart`

## 致谢

- [ShellCrash](https://github.com/juewuy/ShellCrash)（作者：Juewuy）：配置管理、定时任务，以及安装路径模式参考自该项目
- [mihomo](https://github.com/MetaCubeX/mihomo)：代理核心
- [sing-box](https://github.com/SagerNet/sing-box)：代理核心

## 许可证

本项目采用 GNU General Public License v3.0 进行许可。
