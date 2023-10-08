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

    require('lspconfig.ui.windows').default_options = {
      border = "rounded"
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


    -- vim-illuminate
    -- 高亮相同的单词，highlight 链接到 Visual
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
  end,
})
