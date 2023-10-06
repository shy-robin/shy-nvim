-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options

local opt = vim.opt

-- 指定拼写检查的语言
opt.spelllang = { 'en', 'cjk' }
-- 开启拼写检查
opt.spell = true

-- 滚动边距，影响 zt zb
opt.scrolloff = 0 -- Lines of context
opt.sidescrolloff = 0 -- Columns of context
