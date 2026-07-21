return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      -- LSP servers
      "vtsls",
      "vue-language-server",
      "lua-language-server",
      "json-lsp",
      "yaml-language-server",
      "html-lsp",
      "css-lsp",
      "svelte-language-server",
      "pyright",
      "ruff",
      "gopls",
      "rust-analyzer",
      "tailwindcss-language-server",
      "emmet-language-server",

      -- Formatters
      "prettierd",
      "black",
      "isort",
      "sqlfmt",
      "kulala-fmt",

      -- Linters
      "eslint_d",
      "shellcheck",
      "hadolint",

      -- Debuggers and DAP adapters
      "debugpy",
      "codelldb",
    },
    ui = {
      border = "rounded",
      backdrop = 100,
    },
  },
}
