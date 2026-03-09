return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      -- 显式绑定：每个键只触发特定的布局（加上 count=1, 2, 3 来隔离实例）

      -- <C-o> 始终是浮动终端 (实例 1)
      { "<C-o>", "<cmd>1ToggleTerm direction=float<cr>", mode = { "n", "t" }, desc = "Floating Terminal" },

      -- <C-/> 始终是水平终端 (实例 2)
      -- 同时映射 <C-_> 处理你的终端兼容性问题
      { "<C-/>", "<cmd>2ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Horizontal Terminal" },
      { "<C-_>", "<cmd>2ToggleTerm direction=horizontal<cr>", mode = { "n", "t" }, desc = "Horizontal Terminal" },

      -- <C-\> 始终是垂直终端 (实例 3)
      { [[<C-\>]], "<cmd>3ToggleTerm direction=vertical<cr>", mode = { "n", "t" }, desc = "Vertical Terminal" },
    },
    opts = {
      open_mapping = nil,
      direction = "float", -- 默认悬浮
      float_opts = {
        border = "rounded",
      },
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- 终端内部的快捷键优化
      function _G.set_terminal_keymaps()
        local map_opts = { buffer = 0 }
        -- 退出插入模式
        vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], map_opts)
        -- 窗口间快速跳转
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], map_opts)
        vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], map_opts)
      end

      -- 仅在进入终端时启用这些映射
      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },
}
