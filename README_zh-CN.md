# Mihomo User Kit

[English](README.md)

面向 **无 sudo、无可用用户级 systemd 的 Headless Linux 用户**，在用户目录中安装 Mihoro/Mihomo，并通过 tmux 保持代理运行。

## 需求

- Linux，且可写入自己的 `$HOME`；
- 必需命令：`bash`、`curl`、`tar`、`tmux` 和常见 coreutils；
- 不需要 `sudo`，但缺少依赖时需要管理员协助安装；
- 一个 Mihomo/Clash 订阅 URL。

## 一句话安装

```bash
curl -fsSL https://raw.githubusercontent.com/Zijian-Wu/mihomo-user-kit/main/install.sh | bash
```

然后初始化并启动：

```bash
mihoro init
mihomo-tmux start
```

也可以克隆后安装：

```bash
git clone https://github.com/Zijian-Wu/mihomo-user-kit.git
cd mihomo-user-kit
bash install.sh
```

## 默认行为

- 只写入 `~/.local/bin` 和 `~/.config/mihomo`；
- 不运行 `sudo`、系统包管理器、`systemctl`，也不配置开机自启；
- 缺少依赖时只提示，不自动提权安装；
- 已安装的 Mihoro 不会被覆盖；
- 默认只安装，不初始化、不启动代理；
- 将 `~/.config/mihoro.toml` 链接到 `~/.config/mihomo/mihoro.toml`，便于集中管理；
- 用 tmux 保持 Mihomo 在 SSH 断开后继续运行。

安装选项：

```bash
bash install.sh --help
bash install.sh --check
bash install.sh --enable-codex
bash install.sh --init
```

## 命令

| 命令 | 用途 |
|---|---|
| `mihomo-tmux --help` | 查看启动、状态、日志、重启和停止命令 |
| `with-mihomo --help` | 仅让一条命令临时使用代理 |
| `mihomo-update-geodata --help` | 更新并规范化 GeoSite/GeoIP 文件 |
| `mihomo-normalize-geodata --help` | 只修正 GeoData 文件名和软链接 |
| `mihoro --help` | 查看 Mihoro 原生命令 |

常用操作：

```bash
mihomo-tmux start
mihomo-tmux status
mihomo-tmux logs
mihomo-tmux attach
mihomo-tmux restart
mihomo-tmux stop

# 当前终端启用/取消代理
eval "$(mihoro proxy export)"
eval "$(mihoro proxy unset)"

# 仅代理一条命令
with-mihomo curl -I https://github.com
with-mihomo git clone https://github.com/owner/repository.git
with-mihomo codex
```

## GeoData

Mihoro 下载的是小写 `geosite.dat`/`geoip.dat`，而 Mihomo 使用规范文件名 `GeoSite.dat`/`GeoIP.dat`。本仓库会转换文件名并保留小写软链接，兼容后续更新。

要更新 DAT 文件，先在 `~/.config/mihomo/mihoro.toml` 的 `[mihomo_config]` 中设置：

```toml
geodata_mode = true
```

然后运行：

```bash
mihomo-update-geodata
```

文件是否“更全面”取决于 `geox_url` 的下载源，而不是文件名大小写。Mihoro 默认指向 MetaCubeX `meta-rules-dat` 的完整 `geosite.dat`。

## 文件位置

```text
~/.local/bin/                 # mihoro、mihomo 和本仓库命令
~/.config/mihomo/
├── mihoro.toml               # Mihoro 配置和订阅 URL
├── config.yaml               # Mihomo 配置
├── GeoSite.dat / GeoIP.dat
├── geosite.dat / geoip.dat   # 兼容软链接
├── country.mmdb
├── ui/
└── shell/codex-proxy.sh      # 可选

~/.config/mihoro.toml -> ~/.config/mihomo/mihoro.toml
```

> `mihoro.toml` 可能包含私密订阅 URL，请勿提交到 GitHub。

## 限制与排查

Mihoro 原生的 `start/status/stop/restart/apply` 以及部分 core 更新流程依赖用户级 systemd；本仓库用 `mihomo-tmux` 代替进程管理。服务器重启后需要再次执行 `mihomo-tmux start`。

若 `mihoro init` 最后在 systemd/DBus 阶段报错，但以下检查成功，可以直接使用 tmux 启动：

```bash
test -x ~/.local/bin/mihomo
test -f ~/.config/mihomo/config.yaml
mihomo-tmux start
```

前台检查配置：

```bash
~/.local/bin/mihomo -t -d ~/.config/mihomo
~/.local/bin/mihomo -d ~/.config/mihomo
```

## License

MIT
