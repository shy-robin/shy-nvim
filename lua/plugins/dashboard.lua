return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  opts = {
    theme = "hyper",
    config = {
      week_header = {
        enable = true,
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
      footer = {
        "",
        " 🚀 Sharp tools make good work.",
      },
    },
    hide = {
      statusline = true,
      tabline = true,
      winbar = true,
    },
  },
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
