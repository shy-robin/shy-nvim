return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      -- 当打开大文件时，禁用 treesitter，防止卡顿
      disable = function(lang, buf)
        local max_filesize = 400 * 1024 -- 400 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
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
      "go",
      "latex",
      "norg",
      "typst",
    },
  },
}
