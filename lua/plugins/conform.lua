return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      kulala = {
        -- 需要安装 kulala-fmt
        command = "kulala-fmt",
        args = { "format", "$FILENAME" },
        stdin = false,
      },
    },
    formatters_by_ft = {
      http = { "kulala" },
    },
  },
}
