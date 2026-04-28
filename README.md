# NeoCrash

English | [简体中文](./README.zh_CN.md)

A minimal shell-based proxy manager for [mihomo](https://github.com/MetaCubeX/mihomo) and [sing-box](https://github.com/SagerNet/sing-box) forked from [ShellCrash](https://github.com/juewuy/ShellCrash) but with CLI.

## Install

Run
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/idadwind1/NeoCrash/main/install.sh)
source ~/.bashrc

neocrash -h # for help
```

or alternatively if you have cloned the repo
```sh
./install-local.sh
```

## TUN mode
TUN mode requires root to work.
Run `neocrash restart` **as root** to use TUN

## Credits

- [ShellCrash](https://github.com/juewuy/ShellCrash) by Juewuy — config management, cron, and install path patterns adapted from this project
- [mihomo](https://github.com/MetaCubeX/mihomo) — proxy core
- [sing-box](https://github.com/SagerNet/sing-box) — proxy core

## License

This project is licensed under the GNU General Public License v3.0.
