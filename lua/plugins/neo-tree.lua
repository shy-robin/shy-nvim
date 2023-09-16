return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, reveal = true, dir = require("lazyvim.util").get_root() })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
    {
      "<leader>fE",
      function()
        require("neo-tree.command").execute({ toggle = true, reveal = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
  },
  opts = {
    window = {
      mappings = {
        ["l"] = "open_with_window_picker",
        ["h"] = "close_node",
        ["s"] = "vsplit_with_window_picker",
        ["S"] = "split_with_window_picker",
        ["<cr>"] = "focus_preview",
      },
    },
    source_selector = {
      winbar = true,
      statusline = true,
    },
  },
}
