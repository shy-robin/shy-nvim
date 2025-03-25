-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options

local opt = vim.opt

-- 指定拼写检查的语言 (use coc-spell-checker instead)
--opt.spelllang = { 'en', 'cjk' }
-- 开启拼写检查
-- opt.spell = true

opt.spelllang = nil

-- 显示最大字数竖线
opt.colorcolumn = ""

-- 滚动边距，影响 zt zb
opt.scrolloff = 0 -- Lines of context
opt.sidescrolloff = 0 -- Columns of context

-- so that `` is visible in markdown files
opt.conceallevel = 0

-- 影响 html 标签换行
opt.formatoptions = "tcqj"

-- 取消 lualine 对 trouble.nvim 的依赖（https://www.lazyvim.org/plugins/ui#lualinenvim）
vim.g.trouble_lualine = false

-- 超过设置大小，只会开启 vim 本身的语法高亮，避免卡顿
vim.g.bigfile_size = 1024 * 1024 * 0.4 -- 0.4 MB

-- lazygit 不使用当前主题颜色
vim.g.lazygit_config = false
