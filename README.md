# ShyRobin's Neovim configuration

## 切换不同配置文件

TODO
<https://www.reddit.com/r/neovim/comments/123mf4g/neovim_config_switcher/>

- [ ] 添加 markdown 快捷键
- [ ] git sign 位置，以及 图标重合问题
- [x] theme
- [ ] telescope 搜索全局，monorepo 项目子项目路径自动切换，如何搜根目录？
- [x] format eslint
  - [x] leader f n
  - [x] leader f s 自动格式化
  - [x] leader f e eslint autofix
- [ ] buffer 切换快捷键，多 tab
- [ ] tmux server error
- [ ] event = very lazy
- [x] linter
- [x] eslint autofix
- [x] color not work
- [x] code fold
- [x] current cursor not underline
- [x] multi cursor
- [ ] mark
- [x] eslint_d
- [x] ufo
- [x] statuscolumn
- [ ] eslint fix all bug 需要调出 lazygit 才能刷新buffer
- [x] spell check
- [ ] clipboard history
- [ ] line wrap
- [ ] vue template emmet div.region-recommend
- [ ] lua snip <div cl></div cl>
- [ ] import @ 
- [ ] tag new line
- [ ] format lose content
- [ ] remove notify use cmdline
- [ ] in vue import not cmp

## 插件

添加 lua 文件的位置：
nvim --cmd "set rtp+=xxx"

:lua require("xxx")

### lazy-nvim

### neo-tree

直接查看配置文档：
:h Neotree

### nvim-window-picker

## lua 教程

## 资源

<https://neovimcraft.com/>

<https://github.com/rockerBOO/awesome-neovim>

## 添加 lsp

在 mason.lua 里添加自动安装的 lsp 并保存，下次启动 nvim 时会自动安装；
使用 <leader>cm 查看安装进度；
在打开对应的文件，使用 <leader>cl 查看对应的 lsp 是否生效。

## lua-snip

教程：<https://www.ejmastnak.com/tutorials/vim-latex/luasnip/#tips>
