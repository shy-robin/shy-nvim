return {
  'glepnir/dashboard-nvim',
  event = 'VimEnter',
  opts = {
    config = {
      week_header = {
        enable = true
      },
      shortcut = {
        {
          desc = "Files",
          icon = " ",
          action = "Telescope find_files",
          key = "f",
        },
        {
          desc = "Text",
          icon = " ",
          action = "Telescope live_grep",
          key = "t",
        },
        { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
        { action = "ene | startinsert", desc = "New", icon = " ", key = "n" },
        {
          desc = "Scheme",
          icon = " ",
          action = "Telescope colorscheme",
          key = "s",
        },
        { action = "e $MYVIMRC", desc = "Config", icon = " ", key = "c" },
        { action = 'lua require("persistence").load()', desc = "Restore", icon = "󰦛 ", key = "r" },
        { action = "qa", desc = "Quit", icon = " ", key = "q" },
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
