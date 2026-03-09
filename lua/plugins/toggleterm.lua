return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      -- 显式绑定：每个键只触发特定的布局（加上 count=1, 2, 3 来隔离实例）

      -- <C-o> 始终是浮动终端 (实例 1)
      { "<C-o>", "<cmd>1ToggleTerm direction=float<cr>", mode = { "n" }, desc = "Floating Terminal" },

      -- <C-/> 始终是水平终端 (实例 2)
      -- 同时映射 <C-_> 处理你的终端兼容性问题
      { "<C-/>", "<cmd>2ToggleTerm direction=horizontal<cr>", mode = { "n" }, desc = "Horizontal Terminal" },
      { "<C-_>", "<cmd>2ToggleTerm direction=horizontal<cr>", mode = { "n" }, desc = "Horizontal Terminal" },

      -- <C-\> 始终是垂直终端 (实例 3)
      { [[<C-\>]], "<cmd>3ToggleTerm direction=vertical<cr>", mode = { "n" }, desc = "Vertical Terminal" },
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

      function _G.kill_curr_terminal()
        if vim.bo.buftype == "terminal" then
          vim.cmd("bd!")
        end
      end

      -- 终端内部的快捷键优化
      function _G.set_terminal_keymaps()
        local map_opts = { buffer = 0 }

        -- 动态新建终端：继承当前终端的布局方向
        vim.keymap.set("t", "<C-n>", function()
          -- 1. 获取当前终端实例的方向
          local term_map = require("toggleterm.terminal").get_all()
          local curr_buf = vim.api.nvim_get_current_buf()
          local curr_direction = "float" -- 默认值

          for _, term in pairs(term_map) do
            if term.bufnr == curr_buf then
              curr_direction = term.direction
              break
            end
          end

          -- 2. 使用相同的方向开启一个新的 TermNew 实例
          vim.cmd(string.format("TermNew direction=%s", curr_direction))

          -- 3. 强制进入插入模式
          vim.schedule(function()
            vim.cmd("startinsert")
          end)
        end, { buffer = 0, desc = "New Terminal (Inherit Direction)" })

        -- 销毁当前终端 (彻底杀掉)
        -- 这里先切回 Normal 模式再执行删除，确保稳定
        vim.keymap.set("t", "<C-q>", [[<C-\><C-n><cmd>lua _G.kill_curr_terminal()<CR>]], map_opts)

        -- 退出插入模式
        vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], map_opts)
        -- 窗口间快速跳转
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], map_opts)
        vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], map_opts)

        -- 解决关闭问题：不要用固定的 <Cmd>1ToggleTerm
        -- 在终端内部，按对应键应该执行“关闭当前这个终端”的操作
        -- 使用 <Cmd>close<CR> 只是隐藏窗口，进程还在；
        -- 如果你希望按 <C-o> 隐藏当前浮动终端：
        vim.keymap.set("t", "<C-o>", [[<Cmd>close<CR>]], map_opts)
        -- 针对水平和垂直终端，也可以在终端内直接用 close 隐藏自己
        vim.keymap.set("t", "<C-/>", [[<Cmd>close<CR>]], map_opts)
        vim.keymap.set("t", "<C-_>", [[<Cmd>close<CR>]], map_opts)
        vim.keymap.set("t", [[<C-\>]], [[<Cmd>close<CR>]], map_opts)
      end

      -- 仅在进入终端时启用这些映射
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
          set_terminal_keymaps()
        end,
      })
    end,
  },
}
