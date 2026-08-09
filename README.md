# tmux Config

这套配置的 theme、status line layout 和整体视觉方案主要参考了 Catppuccin for tmux 社区中的以下配置：

- [Catppuccin/tmux Discussion #317 · discussioncomment-11064512](https://github.com/catppuccin/tmux/discussions/317#discussioncomment-11064512)

在此基础上增加并调整了 responsive status line、自定义 key tables、pane/window 管理、FloaX、session restore，以及与本地工具的 integrations。

## 安装

克隆仓库后运行安装脚本：

```sh
git clone https://github.com/archcst/tmux-config.git ~/tmux-config
cd ~/tmux-config
./install.sh
```

默认使用 symlink，方便通过 `git pull` 更新。也可以使用 copy-based installation：

```sh
./install.sh --copy
```

安装脚本会：

1. 检查 `tmux` 和 `git`；
2. 备份发生冲突的已有 config 文件；
3. symlink 或复制 config 文件到 `~/.config/tmux`；
4. 在隔离的 tmux server 中安装 TPM plugins。

如果设置了 `XDG_CONFIG_HOME`，配置会安装到 `$XDG_CONFIG_HOME/tmux`。

## 本地配置

共享配置不包含机器和用户相关选项。需要时复制示例：

```sh
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
cp "$config_dir/tmux.local.conf.example" "$config_dir/tmux.local.conf"
```

例如，将 `prefix` 改为 `C-a`：

```tmux
set -g @prefix 'C-a'
```

重新加载后，`prefix + prefix` 会向当前 pane 发送 prefix key。`cmatrix` 只是屏保效果，不是身份验证锁屏。

## Key tables 与 key bindings

默认 `prefix` 为 `C-b`，可以在 `tmux.local.conf` 中覆盖。下表中的按键均在进入对应 key table 后使用。

### `root` key table

`root` key table 没有额外的全局 key bindings。按下 `prefix` 进入 `prefix` key table，其余输入直接发送给当前 pane。

### `prefix` key table

| Key | Command / behavior |
| --- | --- |
| `prefix` | `send-prefix`，向当前 pane 发送 prefix key |
| `q` | `detach-client` |
| `Q` | 确认后执行 `kill-session` |
| `p` | 切换到 `pane` key table |
| `w` | 切换到 `window` key table |
| `o` | 切换到 `session` key table |
| `m` | 切换到 `move` key table |
| `r` | 切换到 `resize` key table |
| `s` | `copy-mode -H` |
| `/` | `copy-mode` |
| `h` / `j` / `k` / `l` | `select-pane`：左 / 下 / 上 / 右 |
| `x` | 关闭当前 pane；有运行中进程时先确认 |
| `f` | `resize-pane -Z`，toggle zoom |
| `=` / `-` | 向上 / 向下 resize pane 5 行，可重复 |
| `1..9` | `select-pane` by index |
| `C-1..9` | `select-window` by index |
| `Tab` | `last-pane` |
| `C-h` / `C-l` | previous / next window，可重复 |
| `Space` | `choose-tree -w` |
| `?` | `list-keys` |
| `:` | 打开 `command-prompt` |
| `O` | `refresh-client` |
| `K` | 向当前 pane 发送 `clear` 和 `Enter` |
| `C-r` | `source-file`，reload config |
| `C-s` | 使用 tmux-resurrect save session |
| `R` | 使用 tmux-resurrect restore session |
| `C-x` | `lock-server` |
| `C-w` | toggle FloaX scratch terminal |
| `P` | 打开 FloaX menu |
| `u` | 使用 tmux-fzf-url 选择 URL |
| `I` | TPM install plugins |
| `U` | TPM update plugins |
| `M-u` | TPM clean unused plugins |

### `pane` key table

通过 `prefix + p` 进入。

| Key | Command / behavior |
| --- | --- |
| `Escape` / `Enter` | 返回 `root` key table |
| `n` | `split-window -h`，在当前 path 创建左右分割的 pane |
| `N` | `split-window -v`，在当前 path 创建上下分割的 pane |
| `h` / `j` / `k` / `l` | `select-pane`：左 / 下 / 上 / 右 |
| `H` / `J` / `K` / `L` | 与左 / 下 / 上 / 右相邻 pane 执行 `swap-pane`，可重复 |
| `1..9` | `select-pane` by index |
| `p` | `last-pane` |
| `x` | 关闭当前 pane；有运行中进程时先确认 |
| `r` | 修改 pane title |
| `o` / `O` | next / previous layout |
| `w` | 使用 `break-pane` 将当前 pane 移到新 window 并命名 |
| `W` | 使用 `join-pane` 将当前 pane 移到指定 window |
| `e` | toggle FloaX scratch terminal |
| `f` | toggle `pane-border-status` |

### `window` key table

通过 `prefix + w` 进入。

| Key | Command / behavior |
| --- | --- |
| `Escape` / `Enter` | 返回 `root` key table |
| `h` / `l` | previous / next window |
| `H` / `L` | 使用 `swap-window` 向前 / 向后移动当前 window，可重复 |
| `N` | 在当前 path 创建未命名 window |
| `n` | 在当前 path 创建 window 并输入名称 |
| `x` | 关闭当前 window 后返回 `root`；有运行中进程时先确认 |
| `X` | 关闭当前 window 后留在 `window` key table；有运行中进程时先确认 |
| `r` | `rename-window` |
| `s` | toggle `synchronize-panes` |
| `t` | `last-window` |
| `1..9` | `select-window` by index |

### `session` key table

通过 `prefix + o` 进入。

| Key | Command / behavior |
| --- | --- |
| `Escape` | 返回 `root` key table |
| `x` | `kill-session` |
| `d` | `detach-client` |
| `r` | `rename-session` |
| `w` / `s` | `choose-session` |
| `l` | 打开 layout menu |
| `n` | 在当前 path 创建并命名 session |
| `o` | `switch-client -p`，切换到 previous session |

Layout menu 包含 `even-horizontal`、`even-vertical`、`main-horizontal`、`main-vertical` 和 `tiled`。

### `move` key table

通过 `prefix + m` 进入。

| Key | Command / behavior |
| --- | --- |
| `Escape` / `Enter` | 返回 `root` key table |
| `h` / `j` / `k` / `l` | 与左 / 下 / 上 / 右相邻 pane 执行 `swap-pane`，并留在 `move` key table |

### `resize` key table

通过 `prefix + r` 进入。

| Key | Command / behavior |
| --- | --- |
| `Escape` / `Enter` | 返回 `root` key table |
| `h` | `resize-pane -L 5` |
| `j` | `resize-pane -D 5` |
| `k` | `resize-pane -U 5` |
| `l` | `resize-pane -R 5` |
| `H` / `L` | 将当前 pane width 减少 5 |
| `J` / `K` | 将当前 pane height 减少 3 |

### `copy-mode-vi` key table

除 tmux 的默认 vi copy-mode key bindings 外，额外覆盖以下按键：

| Key | Command / behavior |
| --- | --- |
| `Escape` | 有 selection 时执行 `clear-selection`，否则退出 copy mode |
| `v` | `begin-selection` |
| `y` | `copy-pipe-and-cancel` |

完整定义见 [`tmux.keymap.conf`](tmux.keymap.conf)。

## 更新

Symlink installation：

```sh
cd ~/tmux-config
git pull
# 进入 tmux 后按 prefix + C-r，再按 prefix + U 更新 plugins
```

Copy-based installation 需要在更新仓库后重新执行：

```sh
./install.sh --copy
```

## 卸载

安装脚本只管理以下四项，不会删除 `plugins/` 和 `tmux.local.conf`：

```sh
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
rm -f "$config_dir/tmux.conf" \
      "$config_dir/tmux.keymap.conf" \
      "$config_dir/tmux.local.conf.example"
rm -rf "$config_dir/scripts"
```

备份文件名称类似 `tmux.conf.backup.20250809143000`，需要时可手动恢复。

## 仓库结构

```text
.
├── tmux.conf
├── tmux.keymap.conf
├── tmux.local.conf.example
├── scripts/
│   └── has-running-program
├── install.sh
├── README.md
└── LICENSE
```

运行时生成的 `plugins/` 和个人的 `tmux.local.conf` 位于用户 config 目录，不会写入仓库。

## Plugins

- TPM
- tmux-resurrect
- tmux-continuum
- Catppuccin for tmux
- tmux-battery
- tmux-online-status
- tmux-fzf-url
- tmux-floax

首次安装会从 GitHub 下载并执行这些 plugins。
