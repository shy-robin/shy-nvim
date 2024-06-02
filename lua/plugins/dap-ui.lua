return {
  "rcarriga/nvim-dap-ui",
  opts = {
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = "",
    },
    mappings = {
      expand = { "<TAB>", "<CR>", "<2-LeftMouse>" },
    },
    floating = {
      max_height = 0.9,
      max_width = 0.5,
      border = "rounded",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
  },
}
