-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- 当开启 volar takeover 模式后，js 或 ts 文件会有两个 lsp 服务：volar + tsserver；
-- 这会导致一些问题，例如 ts 无法识别 import 的 vue 文件；
-- 解决办法是使用 autocmd，如果监测到 volar 和 tsserver 同时开启，则只使用 tsserver。
-- https://www.reddit.com/r/neovim/comments/117gopv/disable_tsserver_if_using_volar_takeover_mode/
local tsserverAttached = false
local volarAttached = false

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local name = client.name

    if name == "tsserver" then
      if volarAttached then
        client.stop()
      else
        tsserverAttached = client
      end
    elseif name == "volar" then
      volarAttached = client
      if tsserverAttached then
        tsserverAttached.stop()
        tsserverAttached = false
      end
    end

    require("lspconfig.ui.windows").default_options = {
      border = "rounded",
    }
  end,
})

-- 拼写检查支持驼峰
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    -- spell check (use coc-spell-checker instead)
    -- vim.cmd('set spelloptions=camel')

    -- vim.api.nvim_set_hl(0, 'SpellBad', { fg = '#F44336', underdashed = true })
    -- vim.api.nvim_set_hl(0, 'SpellCap', { fg = '#F44336', underdashed = true })
    -- vim.api.nvim_set_hl(0, 'SpellRare', { fg = '#F44336', underdashed = true })
    -- vim.api.nvim_set_hl(0, 'SpellLocal', { fg = '#F44336', underdashed = true })

    -- markdown.nvim
    vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#395b65" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#395b65" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#395b65" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#395b65" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#395b65" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#395b65" })

    -- vim-illuminate
    -- 高亮相同的单词，highlight 链接到 Visual
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
  end,
})

-- see: https://www.reddit.com/r/neovim/comments/v719ic/lorem_picsum_random_images_and_strings/
local function parseInt(str)
  return str:match("^%-?%d+$")
end

function appendLoremPicsumUrl()
  local width = parseInt(vim.fn.input("width: "))
  local height = parseInt(vim.fn.input("height: "))

  if width and height then
    local curl = require("plenary.curl")

    local res = curl.get("https://picsum.photos/" .. width .. "/" .. height, {})
    local url = res.headers[3]:sub(11)

    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local nline = line:sub(0, cursor[2] + 1) .. url .. line:sub(cursor[2] + 2)

    vim.api.nvim_set_current_line(nline)
    vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + url:len() })
  end
end

vim.cmd("command LoremPicsum silent lua appendLoremPicsumUrl()")

local charset = {}
do -- [0-9a-zA-Z]
  for c = 48, 57 do
    table.insert(charset, string.char(c))
  end
  for c = 65, 90 do
    table.insert(charset, string.char(c))
  end
  for c = 97, 122 do
    table.insert(charset, string.char(c))
  end
end

local function randomString(length)
  local res = ""

  for i = 1, length do
    -- math.randomseed(os.clock()^5)
    res = res .. charset[math.random(1, #charset)]
  end

  return res
end

function appendRandomString()
  local length = tonumber(vim.fn.input("length: "))

  if length and length > 0 then
    local str = randomString(length)

    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local nline = line:sub(0, cursor[2] + 1) .. str .. line:sub(cursor[2] + 2)

    vim.api.nvim_set_current_line(nline)
    vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + str:len() })
  end
end

vim.cmd("command RandomString silent lua appendRandomString()")

-- 当 ColorScheme 变化时自动触发
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- 设置高亮组 CocMenuSel 的背景颜色
    -- NOTE: 切换背景透明时，CocMenuSel 颜色会变化，需要重置（https://github.com/neoclide/coc.nvim/issues/4123）
    vim.cmd("hi CocMenuSel ctermbg=23 guibg=#3e4d52")

    local hl = vim.api.nvim_set_hl
    hl(0, "GitSignsAdd", { fg = "#0EAA00" })
    hl(0, "GitSignsChange", { fg = "#E5C07B" })
    hl(0, "GitSignsDelete", { fg = "#E06C75" })
    hl(0, "GitSignsTopdelete", { fg = "#E06C75" })
    hl(0, "GitSignsChangedelete", { fg = "#E5C07B" })
    hl(0, "GitSignsUntracked", { fg = "#E06C75" })
    hl(0, "GitsignsCurrentLineBlame", { fg = "#62686E" })

    -- 缓存选中的主题
    local cache_file = vim.fn.stdpath("data") .. "/shy-nvim_theme_cache"
    local colorscheme = vim.g.colors_name
    vim.fn.writefile({ tostring(colorscheme) }, cache_file)
  end,
})

-- markdown 和 txt 文件不检查拼写
-- 参考：<https://github.com/LazyVim/LazyVim/discussions/4021>
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "txt" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
