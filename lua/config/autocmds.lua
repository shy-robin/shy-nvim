-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- 当开启 volar takeover 模式后，js 或 ts 文件会有两个 lsp 服务：volar + tsserver；
-- 这会导致一些问题，例如 ts 无法识别 import 的 vue 文件；
-- 解决办法是使用 autocmd，如果监测到 volar 和 tsserver 同时开启，则只使用 tsserver。
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
  end,
})
