return {
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    config = {
      week_header = {
        enable = true
      },
      shortcut = {
        { desc = " Plugins", group = "@property", action = "Lazy", key = "p" },
        {
          desc = " Files",
          group = "Label",
          action = "Telescope find_files",
          key = "f",
        },
        {
          desc = " Text",
          group = "DiagnosticHint",
          action = "Telescope live_grep",
          key = "t",
        },
        {
          desc = " Scheme",
          group = "Number",
          action = "Telescope colorscheme",
          key = "s",
        },
      },
    },
    hide = {
      statusline = false,
      tabline = false,
      winbar = false,
    },
  },
  dependencies = { { 'nvim-tree/nvim-web-devicons' } }
}
