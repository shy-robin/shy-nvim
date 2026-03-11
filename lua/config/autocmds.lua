-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- -- 拼写检查支持驼峰
-- vim.api.nvim_create_autocmd("BufReadPre", {
--   callback = function()
--     -- spell check (use coc-spell-checker instead)
--     -- vim.cmd('set spelloptions=camel')
--
--     -- vim.api.nvim_set_hl(0, 'SpellBad', { fg = '#F44336', underdashed = true })
--     -- vim.api.nvim_set_hl(0, 'SpellCap', { fg = '#F44336', underdashed = true })
--     -- vim.api.nvim_set_hl(0, 'SpellRare', { fg = '#F44336', underdashed = true })
--     -- vim.api.nvim_set_hl(0, 'SpellLocal', { fg = '#F44336', underdashed = true })
--
--     -- markdown.nvim
--     vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#395b65" })
--     vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#395b65" })
--     vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#395b65" })
--     vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#395b65" })
--     vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#395b65" })
--     vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#395b65" })
--
--     -- vim-illuminate
--     -- 高亮相同的单词，highlight 链接到 Visual
--     vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
--     vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
--     vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
--   end,
-- })
--
-- -- see: https://www.reddit.com/r/neovim/comments/v719ic/lorem_picsum_random_images_and_strings/
-- local function parseInt(str)
--   return str:match("^%-?%d+$")
-- end
--
-- function appendLoremPicsumUrl()
--   local width = parseInt(vim.fn.input("width: "))
--   local height = parseInt(vim.fn.input("height: "))
--
--   if width and height then
--     local curl = require("plenary.curl")
--
--     local res = curl.get("https://picsum.photos/" .. width .. "/" .. height, {})
--     local url = res.headers[3]:sub(11)
--
--     local cursor = vim.api.nvim_win_get_cursor(0)
--     local line = vim.api.nvim_get_current_line()
--     local nline = line:sub(0, cursor[2] + 1) .. url .. line:sub(cursor[2] + 2)
--
--     vim.api.nvim_set_current_line(nline)
--     vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + url:len() })
--   end
-- end
--
-- vim.cmd("command LoremPicsum silent lua appendLoremPicsumUrl()")
--
-- local charset = {}
-- do -- [0-9a-zA-Z]
--   for c = 48, 57 do
--     table.insert(charset, string.char(c))
--   end
--   for c = 65, 90 do
--     table.insert(charset, string.char(c))
--   end
--   for c = 97, 122 do
--     table.insert(charset, string.char(c))
--   end
-- end
--
-- local function randomString(length)
--   local res = ""
--
--   for i = 1, length do
--     -- math.randomseed(os.clock()^5)
--     res = res .. charset[math.random(1, #charset)]
--   end
--
--   return res
-- end
--
-- function appendRandomString()
--   local length = tonumber(vim.fn.input("length: "))
--
--   if length and length > 0 then
--     local str = randomString(length)
--
--     local cursor = vim.api.nvim_win_get_cursor(0)
--     local line = vim.api.nvim_get_current_line()
--     local nline = line:sub(0, cursor[2] + 1) .. str .. line:sub(cursor[2] + 2)
--
--     vim.api.nvim_set_current_line(nline)
--     vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + str:len() })
--   end
-- end
--
-- vim.cmd("command RandomString silent lua appendRandomString()")
--
-- -- markdown 和 txt 文件不检查拼写
-- -- 参考：<https://github.com/LazyVim/LazyVim/discussions/4021>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "markdown", "txt" },
--   callback = function()
--     vim.opt_local.spell = false
--   end,
-- })
--
-- -- 将当前 buffer 的文件转换成 http 格式
-- vim.api.nvim_create_user_command("KulalaConvert", function()
--   vim.cmd("!kulala-fmt convert %")
-- end, {
--   nargs = 0,
-- })

local function set_highlights()
  local set_hl = vim.api.nvim_set_hl
  -- 设置 blink.cmp 的高亮设置
  -- 基础标签：跟随注释颜色（淡灰色）
  set_hl(0, "BlinkCmpLabel", { link = "Comment", default = true })
  -- 匹配字符：跟随关键词颜色（亮色/主题色）
  set_hl(0, "BlinkCmpLabelMatch", { link = "Keyword", bold = true, default = true })
  -- 详情/参数：跟随 NonText（极淡色）
  set_hl(0, "BlinkCmpLabelDetail", { link = "NonText", default = true })
  -- 来源标签：[TSC] 等
  set_hl(0, "BlinkCmpSource", { link = "NonText", italic = true, default = true })
  -- 废弃标记：链接到特定的废弃样式
  set_hl(0, "BlinkCmpLabelDeprecated", { strikethrough = true, fg = "#808080" })
  -- 选中项的整体背景
  set_hl(0, "BlinkCmpMenuSelection", { link = "PmenuSel" })
  -- 如果你希望选中时匹配项依然闪亮，可以单独设置
  set_hl(0, "BlinkCmpLabelMatchSelection", { link = "Keyword", bold = true, italic = true })

  -- 设置浮窗的背景和文字颜色
  -- set_hl(0, "NormalFloat", { bg = "#1e2030" })

  -- 设置边框颜色，fg 设为明亮的颜色
  set_hl(0, "FloatBorder", { link = "Pmenu" })

  -- 设置 gitsigns 的高亮
  set_hl(0, "GitSignsAdd", { fg = "#0EAA00" })
  set_hl(0, "GitSignsChange", { fg = "#E5C07B" })
  set_hl(0, "GitSignsDelete", { fg = "#E06C75" })
  set_hl(0, "GitSignsTopdelete", { fg = "#E06C75" })
  set_hl(0, "GitSignsChangedelete", { fg = "#E5C07B" })
  set_hl(0, "GitSignsUntracked", { fg = "#E06C75" })
  set_hl(0, "GitsignsCurrentLineBlame", { fg = "#62686E" })
end

local function save_color_scheme()
  -- 缓存选中的主题
  local cache_file = vim.fn.stdpath("data") .. "/shy-nvim_theme_cache"
  local colorscheme = vim.g.colors_name
  vim.fn.writefile({ tostring(colorscheme) }, cache_file)
end

-- 立即执行一次（解决首次进入无效的问题）
set_highlights()

-- 每当切换或加载主题后自动触发
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    set_highlights()
    save_color_scheme()
  end,
})
