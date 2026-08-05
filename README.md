<h1 align="center">ShyNvim</h1>

<p align="center">
这是我个人维护的一套 Neovim 配置（基于 <a href="https://github.com/LazyVim/LazyVim">💤 LazyVim</a>），配置简单灵活，预设一套 <b>Web 前端</b> 的开发环境。
</p>

## 🌟 预览

![Preview Image](https://s2.loli.net/2024/12/05/sUzNPo2hX8CyeR7.png)

## ✨ 功能

- 包管理器 [lazy.nvim](https://github.com/folke/lazy.nvim)
- 文件浏览器 [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- 代码补全、格式化、语法检查 [Native LSP](https://github.com/neovim/nvim-lspconfig) + [blink.cmp](https://github.com/Saghen/blink.cmp)
- 语法高亮 [treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Git 集成 [gitsigns](https://github.com/lewis6991/gitsigns.nvim) [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)
- 状态栏 [bufferline](https://github.com/akinsho/bufferline.nvim) [lualine](https://github.com/nvim-lualine/lualine.nvim)
- 浮动终端 [vim-floaterm](https://github.com/voldikss/vim-floaterm)
- 模糊搜索 [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- Markdown 预览 [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- AI 代码补全 [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim)
- 代码调试 [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## ⚡️ 前置条件

- [LazyVim](https://www.lazyvim.org/) 前置依赖（具体参考：[LazyVim Requirements](https://www.lazyvim.org/#%EF%B8%8F-requirements)）
  - [neovim](https://neovim.io/) >= **0.11.2** （需要用 **LuaJIT** 构建）
  - [git](https://git-scm.com/) >= **2.19.0** （用于部分克隆支持）
  - 一个 [Nerd Font](https://www.nerdfonts.com/) 字体 **_（可选）_**
  - [lazygit](https://github.com/jesseduffield/lazygit) **_（可选）_**
  - 一个用于 `nvim-treesitter` 的 **C** 编译器。看 [这里](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
  - [fzf-lua](https://github.com/ibhagwan/fzf-lua) 搜索依赖 **_（可选）_**
    - [ripgrep](https://github.com/BurntSushi/ripgrep)（文本搜索）
    - [fd](https://github.com/sharkdp/fd)（文件搜索）
  - 终端（支持展示颜色和下划线样式的终端）
    - [kitty](https://github.com/kovidgoyal/kitty) (Linux & macOS)
    - [wezterm](https://github.com/wez/wezterm) (Linux, macOS & Windows)
    - [alacritty](https://github.com/alacritty/alacritty) (Linux, macOS & Windows)
    - [iTerm2](https://iterm2.com/) (macOS)
- [Native LSP](https://github.com/neovim/nvim-lspconfig) 前置依赖
  - [curl](https://curl.se/) 用于 [blink.cmp](https://github.com/Saghen/blink.cmp) **(必需)**
  - [Node.js](https://nodejs.org/en/download/) >= 16.18.0 **(可选，用于某些语言服务器)**
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) 前置依赖
  - `sh`、Node.js、npm 和 npx（插件安装时执行 `npx --yes yarn install`，因此需要网络连接；不需要全局安装 Yarn）。缺少任一命令或安装失败时，安装会停止且不会应用本地 patch。
- 可选外部工具
  - nvim-tree 图片信息：macOS 使用 `sips` 读取尺寸；其它平台可安装 ImageMagick 以提供 `identify`。两者都不存在时只省略尺寸信息。
  - [nvim-scissors](https://github.com/chrisgrieser/nvim-scissors) 使用插件当前内置的 JSON 格式化；不需要 `jq`。
  - Floaterm：`<leader>tor` 需要 `ranger`，`<leader>y` 需要 `yazi`。缺少时会显示安装提示，而不会启动无效终端。
  - [pdfreader.nvim](https://github.com/r-pletnev/pdfreader.nvim) 阅读 PDF：需要 ImageMagick（`magick`）、Ghostscript（`gs`）和 poppler（`pdftotext`、`pdfinfo`）。终端需支持 kitty graphics protocol（kitty / Ghostty），否则自动降级为纯文本模式。未安装 telescope，因此书签、目录、最近阅读的选择器不可用，翻页与缩放不受影响。
- 其他依赖
  - `:checkhealth snacks`
  - `:checkhealth img-clip`

## 🚀 开始使用

1. 备份你的原有配置

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

2. 克隆当前维护分支 `nvim-0.11`

```shell
git clone --depth 1 --branch nvim-0.11 https://github.com/shy-robin/shy-nvim ~/.config/nvim
```

> 此命令不会改变 GitHub 默认分支；需要切换默认分支时请另行决定并在 GitHub 上操作。

3. 删除 `.git` 文件夹，以便稍后将其添加到您自己的仓库

```shell
rm -rf ~/.config/nvim/.git
```

4. 启动 Neovim!

```shell
nvim
```

## 📄 功能指南

### fzf-lua 搜索

| 功能 | 快捷键 | 描述 |
| --- | --- | --- |
| 搜索文件 | `:FzfLua files` | 在当前工作目录启动文件选择器 |
| 搜索文本 | `:FzfLua live_grep` | 在当前工作目录启动实时文本搜索 |
| 在 nvim-tree 内搜索文本 | <kbd>Ctrl</kbd> + <kbd>f</kbd> | 对当前树节点（文件时取其父目录）执行 fzf-lua live grep |
| 隐藏 fzf-lua | <kbd>Esc</kbd> | 隐藏当前 picker；用 `:FzfLua resume` 恢复 |
| 切换 hidden 文件 | <kbd>Ctrl</kbd> + <kbd>h</kbd> | 在 fzf-lua picker 内切换隐藏文件 |
| 切换 `.gitignore` 过滤 | <kbd>Ctrl</kbd> + <kbd>y</kbd> | 在 fzf-lua picker 内切换 ignore 过滤 |
| 切换符号链接跟随 | <kbd>Ctrl</kbd> + <kbd>f</kbd> | 在 fzf-lua picker 内切换 follow |
| 发送到 quickfix / location list | <kbd>Ctrl</kbd> + <kbd>q</kbd> / <kbd>Ctrl</kbd> + <kbd>l</kbd> | 将多选结果发送到相应列表 |
| 切换 grep / live_grep | <kbd>Ctrl</kbd> + <kbd>g</kbd> | 仅在 grep picker 内切换两种搜索方式 |
| 切换全屏 / 预览 | <kbd>Ctrl</kbd> + <kbd>o</kbd> / <kbd>Ctrl</kbd> + <kbd>a</kbd> | 在 fzf-lua picker 内切换显示 |

> `:FzfLua files` 和 `:FzfLua live_grep` 默认使用 Neovim 当前工作目录；nvim-tree 中的 `<C-f>` 则使用光标节点目录。该配置使用上述 fzf-lua 输入控制，而不是 Telescope 的 `<C-u>` / `<C-i>` 绑定。

### Markdown Preview

| 功能 | 快捷键或命令 | 描述 |
| --- | --- | --- |
| 切换当前 buffer 预览 | `gom` 或 `:MarkdownPreviewToggle` | 打开或关闭当前 Markdown buffer 的预览 |
| 预览列表 | `goM` | 打开当前预览列表 |
| 开始 / 停止预览 | `:MarkdownPreview` / `:MarkdownPreviewStop` | 管理 Markdown Preview 服务 |

### Floaterm 终端

| 功能 | 快捷键 | 描述 |
| --- | --- | --- |
| 切换浮动终端 | <kbd>Ctrl</kbd> + <kbd>o</kbd> | 执行 `:FloatermToggle` |
| 新建、前一个、后一个终端 | <kbd>Ctrl</kbd> + <kbd>n</kbd> / <kbd>h</kbd> / <kbd>l</kbd> | 仅 Floaterm 终端模式 |
| 退出 Floaterm | <kbd>Ctrl</kbd> + <kbd>q</kbd> | 仅 Floaterm 终端模式，执行 `:FloatermKill` |
| 底部 / 右侧终端 | `<leader>tb` / `<leader>tr` | 新建 split 或 vertical split Floaterm |
| 退出全部 | `<leader>qq` | 先执行 `:FloatermKill!`，再退出 Neovim |

### 个性化键位

以下普通编辑 buffer 的键位有意偏离标准 Vim，以避免删除或修改时覆盖默认寄存器：

| 按键 | 模式 | 行为 |
| --- | --- | --- |
| `d`、`dd`、`D` | Normal、Visual | 删除到黑洞寄存器 |
| `c`、`cc`、`C` | Normal、Visual | 修改到黑洞寄存器 |
| `s`、`S` | Normal、Visual | 替换/修改到黑洞寄存器 |
| `X` | Normal | `yydd`：复制当前行后删除，相当于剪切整行 |
| `f` | Normal、Visual、Operator-pending | Flash jump，而非标准字符查找 |
| `F` | Normal、Visual、Operator-pending | Flash Treesitter jump，而非标准反向字符查找 |

在 nvim-tree buffer 内，这些树专用键位有不同含义：`d` 删除节点、`s` 执行系统命令、`f` 开始实时过滤、`F` 清除实时过滤。

## 🤖 AI 助手

本配置只集成 Supermaven，用于 AI 代码自动补全：

| 功能 | 快捷键 | 描述 |
| --- | --- | --- |
| 接受建议 | `<C-y>` | 接受代码补全建议 |
| 清除建议 | `<C-]>` | 清除当前建议 |
| 接受单词 | `<C-w>` | 接受下一个单词 |
| 查看日志 | `<leader>asl` | 执行 `:SupermavenShowLog` |
| 重启服务 | `<leader>asr` | 执行 `:SupermavenRestart` |
| 开关服务 | `<leader>ast` | 通过 Snacks toggle 启动或停止 Supermaven |

## 🎓 入门教程

本配置基于 LazyVim，如果你不了解它的用法，可以参考以下入门教程：

- [@elijahmanor](https://github.com/elijahmanor) 制作了一个很棒的视频，可以带领你快速入门。[![查看这个视频](https://img.youtube.com/vi/N93cTbtLCIM/hqdefault.jpg)](https://www.youtube.com/watch?v=N93cTbtLCIM)
- [@dusty-phillips](https://github.com/dusty-phillips) 为 LazyVim 编写了一本全面的书籍 [《LazyVim for Ambitious Developers》](https://lazyvim-ambitious-devs.phillips.codes)，可在线上免费阅读。

---

如果你想寻找一些有用的插件，可以访问以下网站：

- [neovimcraft](https://neovimcraft.com/)
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)

## 💬 其他问题

- 如何使用某个 commit 版本的插件？

  使用 <kbd>leader</kbd> + <kbd>l</kbd> + <kbd>r</kbd> 或者 `:Lazy restore` 命令将插件版本恢复到 lock 文件指定版本。

## 🛠️ 其他工具

- [kitty](https://sw.kovidgoyal.net/kitty/)
  - 0.37 版本支持鼠标追随动画（参考：[Cursor trails](https://sw.kovidgoyal.net/kitty/changelog/#cursor-trails-0-37)）
- [neovide](https://neovide.dev/)
  - 基于 Rust 编写，提供丝滑流程的 GUI 动画
