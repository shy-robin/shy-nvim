<h1 align="center">ShyNvim</h1>

<p align="center">
这是我个人维护的一套 Neovim 配置（基于  <a href="https://github.com/LazyVim">💤 LazyNvim</a>），配置简单灵活，预设一套 <b>Web 前端</b> 的开发环境。
</p>

## 🌟 预览

![Preview Image](https://s2.loli.net/2024/12/05/sUzNPo2hX8CyeR7.png)

## ✨ 功能

- 包管理器 [lazy.nvim](https://github.com/folke/lazy.nvim)
- 文件浏览器 [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
- 代码补全、格式化、语法检查 [coc.nvim](https://github.com/neoclide/coc.nvim)
- 语法高亮 [treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Git 集成 [gitsigns](https://github.com/lewis6991/gitsigns.nvim) [lazygit](https://github.com/jesseduffield/lazygit)
- 状态栏 [bufferline](https://github.com/akinsho/bufferline.nvim) [lualine](https://github.com/nvim-lualine/lualine.nvim)
- 浮动终端 [vim-floaterm](https://github.com/voldikss/vim-floaterm)
- 模糊搜索 [telescope](https://github.com/nvim-telescope/telescope.nvim)
- 代码调试 [nvim-dap](https://github.com/mfussenegger/nvim-dap)

## ⚡️ 前置条件

- [LazyVim](https://www.lazyvim.org/) 前置依赖（具体参考：[LazyVim Requirements](https://www.lazyvim.org/#%EF%B8%8F-requirements)）
  - [neovim](https://neovim.io/) >= **0.9.0** （需要用 **LuaJIT** 构建）
  - [git](https://git-scm.com/) >= **2.19.0** （用于部分克隆支持）
  - 一个 [Nerd Font](https://www.nerdfonts.com/) 字体 **_（可选）_**
  - [lazygit](https://github.com/jesseduffield/lazygit) **_（可选）_**
  - 一个用于 `nvim-treesitter` 的 **C** 编译器。看 [这里](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 依赖 **_（可选）_**
    - [ripgrep](https://github.com/BurntSushi/ripgrep)（搜索字符 ）
    - [fd](https://github.com/sharkdp/fd)（搜索文件 ）
  - 终端（支持展示颜色和下划线样式的终端）
    - [kitty](https://github.com/kovidgoyal/kitty) (Linux & Macos)
    - [wezterm](https://github.com/wez/wezterm) (Linux, Macos & Windows)
    - [alacritty](https://github.com/alacritty/alacritty) (Linux, Macos & Windows)
    - [iterm2](https://iterm2.com/) (Macos)
- [coc.nvim](https://github.com/neoclide/coc.nvim) 前置依赖
  - [nodejs](https://nodejs.org/en/download/) >= 16.18.0
  - [watchman](https://facebook.github.io/watchman/)（volar 服务会用到，具体参考：[[RECOMMENDED] Additional installation of "watchman"](https://github.com/yaegassy/coc-volar?tab=readme-ov-file#recommended-additional-installation-of-watchman)）
- [ultisnips](https://github.com/SirVer/ultisnips) 前置依赖
  - ultisnips 需要依赖 python，因此需要提前安装 python，否则无法正常使用代码片段
    1. 安装 python：`brew install python`，检查是否安装成功：`python3 --version`
    2. 安装 pynvim：`pip3 install pynvim`，如果安装提示 ssl 的报错，需要断开 vpn 进行安装，检查是否安装成功：`python3` -> `import pynvim` -> `print(pynvim.__vesion__)`
    3. 检查 nvim 是否安装 python 环境：`:echo has('python3')`，若返回 1 则有，若为 0 则无

## 🚀 开始使用

1. 备份你的原有配置

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

2. 克隆我的配置

```shell
git clone --depth 1 https://github.com/shy-robin/shy-nvim ~/.config/nvim
```

3. 删除 `.git` 文件夹，以便稍后将其添加到您自己的仓库

```shell
rm -rf ~/.config/nvim/.git
```

4. 启动 Neovim!

```shell
nvim
```

## 🎓 入门教程

本配置基于 LazyVim，如果你不了解它的用法，可以参考以下入门教程：

- [@elijahmanor](https://github.com/elijahmanor) 制作了一个很棒的视频，可以带领你快速入门。[![查看这个视频](https://img.youtube.com/vi/N93cTbtLCIM/hqdefault.jpg)](https://www.youtube.com/watch?v=N93cTbtLCIM)
- [@dusty-phillips](https://github.com/dusty-phillips) 为 LazyVim 编写了一本全面的书籍
  [《LazyVim for Ambitious Developers》](https://lazyvim-ambitious-devs.phillips.codes)
  ，可在线上免费阅读。

---

如果你想寻找一些有用的插件，可以访问以下网站：

- [neovimcraft](https://neovimcraft.com/)
- [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)

## 📋 待办事项

### 功能

- [x] 折叠代码区域，vscode 里的 #region #endregion 范围内折叠
  - 暂时无法实现（参考：<https://github.com/kevinhwang91/nvim-ufo/issues/233>）
  - 代替方法：visual mode 选中多行代码，使用 `zf` 折叠
- [x] 自动上传剪切板图片到图库（[nvim-picgo](https://github.com/askfiy/nvim-picgo)）
- [x] 生成代码图片（[carbon-now.nvim](https://github.com/ellisonleao/carbon-now.nvim)）
- [ ] 生成随机的字符（人名、邮箱、诗句等）
- [ ] easy-commands <https://www.bilibili.com/video/BV1EV411G7UK/?spm_id_from=333.788.recommend_more_video.1&vd_source=4ef7b6657238565af69458e77de87682>
- [ ] 会话管理 <https://docs.astronvim.com/mappings#session-manager-mappings>
- [ ] api 请求（[rest.nvim](https://github.com/rest-nvim/rest.nvim) 或 [kulala.nvim](https://github.com/mistweaverco/kulala.nvim))
- [ ] 翻译（[translate.nvim](https://github.com/uga-rosa/translate.nvim)）
- [ ] 注释画图（[venn.nvim](https://github.com/jbyuki/venn.nvim)）

### 问题

- [ ] `<leader>e` 打开 nvim-tree，此时 `<C-o>` 打开 floaterm，使用 `<C-h>` 或 `<C-l>` 切换会报错
