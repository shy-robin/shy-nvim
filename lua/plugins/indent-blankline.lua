return {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
    local highlight = {
      "CursorColumn",
      "Whitespace"
    }

    require("ibl").setup {
      indent = {
        highlight = highlight,
        char = "",
        context_char = "",
      },
      whitespace = {
        highlight = highlight,
        remove_blankline_trail = true
      },
      scope = {
        enabled = false
      }
    }
  end
}
