return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false, -- 禁用行尾出现的虚拟文本
      },
      servers = {
        dartls = { enabled = false }, -- 禁用，由 flutter-tools 接管
      },
    },
  },
}
