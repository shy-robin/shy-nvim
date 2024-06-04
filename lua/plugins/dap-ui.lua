return {
  "rcarriga/nvim-dap-ui",
  keys = {
    {
      "<leader>dR",
      function()
        require('dapui').open({ reset = true })
      end,
      expr = true,
      silent = true,
      desc = "Reset Dapui Layout",
      mode = "n",
    },
  },
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
