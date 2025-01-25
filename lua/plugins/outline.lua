return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>oo", "<cmd>Outline<CR>", desc = "Toggle Outline" },
  },
  opts = function()
    local defaults = require("outline.config").defaults
    local opts = {
      symbols = {
        icons = {},
        filter = LazyVim.config.kind_filter,
      },
      keymaps = {
        up_and_jump = "<up>",
        down_and_jump = "<down>",
      },
    }

    for kind, symbol in pairs(defaults.symbols.icons) do
      opts.symbols.icons[kind] = {
        icon = LazyVim.config.icons.kinds[kind] or symbol.icon,
        hl = symbol.hl,
      }
    end
    return opts
  end,
}
