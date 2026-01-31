return {
  "LazyVim/LazyVim",
  opts = {
    mason = {
      ensure_installed = {
        -- LSP servers
        "typescript-tools",
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
        "stylua",
        "black",
        "isort",
        "gofumpt",
        "rustfmt",
        "sqlfmt",
        "shfmt",
        
        -- Linters
        "eslint_d",
        "markdownlint-cli2",
        "shellcheck",
        "golangci-lint",
        "hadolint",
        
        -- Debuggers
        "debugpy",
        "delve",
        
        -- DAP adapters
        "codelldb",
      },
      ui = {
        border = "rounded",
      },
    },
  },
}