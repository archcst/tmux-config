# Tmux 配置

一套偏个人工作流、采用多级模式键表的 tmux 配置。默认前缀是 `C-a`，包含响应式状态栏、Catppuccin 主题、会话恢复、浮动终端和繁忙进程关闭确认。

> 这套配置会清空默认 prefix 键位，不是对 tmux 默认键位的轻量增强。

## 环境要求

- tmux：在 `3.7b` 上测试，建议使用 `3.7+`
- Git
- Nerd Font
- `fzf`：用于 URL 选择功能
- 可选：`cmatrix`、`pi-focus-bell`

已针对 Kitty、Ghostty 和 iTerm2 配置 True Color。`C-a C-1..9` 需要终端支持 CSI-u；Kitty 等终端可能还需要显式映射 Ctrl-数字。

## 安装

从当前 dotfiles 仓库安装：

```sh
git clone https://github.com/archcst/dotfiles.git ~/dotfiles
cd ~/dotfiles/tmux
./install.sh
```

安装脚本会：

1. 检查 `tmux` 和 `git`；
2. 备份现有的 `~/.config/tmux`；
3. 创建配置目录符号链接；
4. 在隔离的 tmux server 中安装 TPM 插件。

如果使用了 `XDG_CONFIG_HOME`，配置会安装到 `$XDG_CONFIG_HOME/tmux`。

## 本地配置

共享配置不会包含机器和用户相关选项。需要时复制示例：

```sh
cp ~/.config/tmux/tmux.local.conf.example \
   ~/.config/tmux/tmux.local.conf
```

`tmux.local.conf` 和 `plugins/` 均不会被 Git 追踪。这里适合配置：

- 网络检测地址；
- `cmatrix` 屏保命令；
- Neovim session 恢复策略；
- `pi-focus-bell`；
- 程序专属 pane 图标。

`cmatrix` 只是屏保效果，不是身份验证锁屏。

## 快捷键

所有组合均以 `C-a` 开始。

| 按键 | 功能 |
| --- | --- |
| `p` | 进入 pane 模式 |
| `w` | 进入 window 模式 |
| `o` | 进入 session 模式 |
| `m` | 进入 pane 移动模式 |
| `r` | 进入 pane 大小调整模式 |
| `s` | 滚动历史 |
| `/` | copy mode |
| `h/j/k/l` | 切换 pane |
| `1..9` | 选择 pane |
| `C-1..9` | 选择 window |
| `C-w` | 打开或关闭 FloaX 浮动终端 |
| `u` | 从当前内容中选择 URL |
| `Space` | window 选择器 |
| `C-s` / `R` | 保存/恢复 session |
| `C-r` | 重新加载配置 |
| `q` | detach |

子模式内按 `Escape` 返回。完整绑定见 [`tmux.keymap.conf`](.config/tmux/tmux.keymap.conf)。

### 插件管理

| 按键 | 功能 |
| --- | --- |
| `C-a I` | 安装插件 |
| `C-a U` | 更新插件 |
| `C-a M-u` | 清理未使用插件 |

## 更新与卸载

更新配置和插件：

```sh
cd ~/dotfiles
git pull
# 进入 tmux 后按 C-a U
```

卸载配置：

```sh
rm ~/.config/tmux
```

安装脚本创建的旧配置备份名称类似：

```text
~/.config/tmux.backup.20250809143000
```

可以将所需备份重新移动到 `~/.config/tmux`。

## 文件结构

```text
.config/tmux/
├── tmux.conf
├── tmux.keymap.conf
├── tmux.local.conf.example
└── scripts/
    └── has-running-program
```

## 插件

- TPM
- tmux-resurrect
- tmux-continuum
- Catppuccin for tmux
- tmux-battery
- tmux-online-status
- tmux-fzf-url
- tmux-floax

首次安装会从 GitHub 下载并执行这些插件。

## Status format 备注

响应式 status 段使用宽度条件：

```tmux
#{?#{e|>=:#{client_width},80},VISIBLE,HIDDEN}
```

在条件分支中包含带逗号的样式块时，需要用 `#{...}` 保护分支：

```tmux
#{?cond,#{#[bg=default,fg=red,bold] HELLO}}
```
