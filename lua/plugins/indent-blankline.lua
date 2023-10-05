return {
  "lukas-reineke/indent-blankline.nvim",
  opts = {
    indent = {
      highlight = {
        "CursorColumn",
        "Whitespace"
      },
      char = "",
      context_char = "",
    },
    whitespace = {
      highlight = {
        "CursorColumn",
        "Whitespace"
      },
      remove_blankline_trail = true
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
        "floaterm"
      },
    },
  },
}
