return {
  "LazyVim/LazyVim",
  opts = {
    lint = {
      linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },
        markdown = { "markdownlint" },
        python = { "ruff" },
        go = { "golangci-lint" },
        sh = { "shellcheck" },
        dockerfile = { "hadolint" },
      },
      linters = {
        eslint_d = {
          condition = function(ctx)
            return vim.fs.find({
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.json",
              ".eslintrc.yml",
              ".eslintrc.yaml",
              "package.json",
            }, { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
  },
}