# Tmux 配置

## 自适应状态栏

当终端窗口宽度不足时，状态栏自动收起低优先级内容并重排布局，避免左右两侧互相挤压或溢出。

### 两档布局

| 宽度       | status-left                  | 中央窗口列表           | status-right                                        |
| ---------- | ---------------------------- | ---------------------- | --------------------------------------------------- |
| **< 120**（窄） | session/copy 名 + 目录路径   | 空（隐藏，避免重复）   | 窗口列表（当前窗口高亮）                            |
| **≥ 120**（宽） | session/copy + 命令 + 目录 + zoom | 窗口列表（absolute-centre 居中） | 电量 + 网络状态 + 日期时间                           |

### 实现方式

所有自适应逻辑都通过 tmux 内置的 **format 条件表达式**实现，不依赖外部脚本。

#### 1. 每个 status 段包一层宽度条件

```tmux
# 宽度 ≥ 120 时显示「当前命令」段，否则整段为空（隐藏）
set -ga status-left "#{?#{e|>=:#{client_width},120},#{#[bg=default,fg=#{@thm_maroon}]  #{pane_current_command} }}"
```

- `#{?#{e|>=:#{client_width},120}, ON, OFF}` — 宽度条件
  - `#{e|>=:A,B}` 算术比较（`e` 表示 numeric）
  - `#{client_width}` 当前客户端宽度（列数）
- 省略 OFF 分支 → 条件为假时返回空字符串，整段不渲染

#### 2. 窄宽时把窗口列表从中央搬到右侧

`#{W:format}` 逐窗口迭代：`#{W:#{?window_active, 高亮格式 , 普通格式 }}`

```tmux
# 窄宽时 status-right 显示窗口列表，宽屏时为空
set -ga status-right "#{?#{e|>=:#{client_width},120},,#{#{W:#{?window_active, ... , ... }}}}"
```

配合把中央 `window-status-format` / `window-status-current-format` 在窄宽时置空，避免重复：

```tmux
set -g window-status-format "#{?#{e|>=:#{client_width},120}, #I... ,}"
set -g window-status-current-format "#{?#{e|>=:#{client_width},120}, #I... ,}"
```

#### 3. 用 `#{...}` 保护样式块里的逗号

**踩坑记录**：tmux 的 `#{?cond,TRUE,FALSE}` 解析器在找 `,` 分隔符和 `}` 结束符时 **只认 `#{}` 配对**，不认 `#[...]` 样式块里的逗号。

```tmux
# ❌ 错误：样式里的逗号被误判为分支分隔符
#{?cond,#[bg=default,fg=red,bold] HELLO}
# → 解析器认为 TRUE 分支只到 "#[bg=default"，fg=red 被当 FALSE

# ✅ 正确：用 #{} 包住整个 TRUE/FALSE 分支
#{?cond,#{#[bg=default,fg=red,bold] HELLO}}
```

### 调整阈值

所有段共用同一个宽度阈值（当前 120）。若需调整，在 `tmux.conf` 中全局替换 `120` 为目标值即可（注意避开电池的 `20` 百分比阈值）。

### 语法速查

| 语法                    | 含义                                        |
| ----------------------- | ------------------------------------------- |
| `#{?C,T}`              | 条件 C 为真输出 T，否则空                   |
| `#{?C,T,F}`            | 三元：真 T / 假 F                           |
| `#{e\|op:A,B}`          | 算术比较（op: `== != < <= > >=`）          |
| `#{client_width}`      | 终端宽度（列数）                            |
| `#{pane_current_command}` | 当前 pane 的进程命令名                   |
| `#\[attr,...\]`        | 样式块，逗号分隔属性                        |
| `#{@name}`             | 用户选项 `@name` 的值（变量）               |
| `#{W:format}`          | 逐窗口迭代格式化                            |
| `#{...}`               | 整体求值/分组，用于保护内层逗号             |
