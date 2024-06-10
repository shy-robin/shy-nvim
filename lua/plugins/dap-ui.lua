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
    {
      "<leader>dw",
      function()
        require('dapui').float_element(
          'watches',
          { enter = true }
        )
      end,
      desc = "Dap Watches"
    },
    {
      "<leader>ds",
      function()
        require('dapui').float_element(
          'scopes',
          { enter = true }
        )
      end,
      desc = "Dap Scopes"
    }
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
