return {
  "lukas-reineke/indent-blankline.nvim",
  opts = {
    indent = {
      highlight = {
        "CursorColumn",
        "Whitespace",
      },
      char = "",
    },
    whitespace = {
      highlight = {
        "CursorColumn",
        "Whitespace",
      },
      remove_blankline_trail = false,
    },
    exclude = {
      filetypes = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
        "floaterm",
        "NvimTree",
      },
    },
  },
}
