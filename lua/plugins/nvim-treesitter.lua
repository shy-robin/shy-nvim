return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      -- 当打开大文件时，禁用 treesitter，防止卡顿
      disable = function(_, bufnr)
        local buf_name = vim.api.nvim_buf_get_name(bufnr)
        local file_size = vim.api.nvim_call_function("getfsize", { buf_name })
        return file_size > 256 * 1024
      end,
    },
    ensure_installed = {
      "bash",
      "c",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
      "vue",
      "svelte",
      "css",
      "scss",
      "http",
      "dart",
    },
  },
}
