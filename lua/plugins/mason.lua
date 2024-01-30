return {
  "williamboman/mason.nvim",
  opts = {
    -- 自动安装 lsp
    ensure_installed = {
      -- "stylua",
      -- "shfmt",
      -- "vue-language-server",
      -- "html-lsp",
      -- "css-lsp",
      -- "svelte-language-server",
      -- "prettierd",
      -- "eslint_d",
      -- emmet-ls 存在一些问题：
      -- https://github.com/aca/emmet-ls/issues/42
      -- "emmet-language-server"
    },
    ui = {
      border = "rounded"
    }
  },
}
