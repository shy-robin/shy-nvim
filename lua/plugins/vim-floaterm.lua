return {
  "voldikss/vim-floaterm",
  event = "VeryLazy",
  keys = {
    {
      "<C-o>",
      "<cmd>FloatermToggle<cr>",
      desc = "Toggle Floaterm",
    },
    {
      "<C-o>",
      "<cmd>FloatermToggle<cr>",
      desc = "Toggle Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-n>",
      "<cmd>FloatermNew<cr>",
      desc = "New Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-h>",
      "<cmd>FloatermPrev<cr>",
      desc = "Prev Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-l>",
      "<cmd>FloatermNext<cr>",
      desc = "Next Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-f>",
      "<cmd>FloatermFirst<cr>",
      desc = "First Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-e>",
      "<cmd>FloatermLast<cr>",
      desc = "Last Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    -- use <esc><esc> of LazyVim instead
    -- NOTE: 13 版本 LazyVim 去掉了，需要手动加上
    {
      "<esc><esc>",
      "<C-\\><C-n>",
      desc = "Enter Normal Mode",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-j>",
      function()
        local w = vim.g.floaterm_width
        if w == 0.95 then
          vim.api.nvim_command("FloatermUpdate --height=0.6 --width=0.6")
          vim.g.floaterm_width = 0.6
          vim.g.floaterm_height = 0.6
        else
          vim.api.nvim_command("FloatermUpdate --height=0.95 --width=0.95")
          vim.g.floaterm_width = 0.95
          vim.g.floaterm_height = 0.95
        end
      end,
      desc = "Toggle Floaterm Size",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<C-q>",
      "<cmd>FloatermKill<cr>",
      desc = "Quit Floaterm",
      ft = "floaterm",
      mode = "t",
    },
    {
      "<leader>tb",
      "<cmd>FloatermNew --wintype=split --height=20<cr>",
      desc = "Toggle Bottom Terminal",
    },
    {
      "<leader>tr",
      "<cmd>FloatermNew --wintype=vsplit --width=80<cr>",
      desc = "Toggle Right Terminal",
    },
    {
      "<leader>tob",
      "<cmd>FloatermNew --cwd=<buffer><cr>",
      desc = "Open Floaterm in Current Buffer",
    },
    {
      "<leader>tor",
      "<cmd>FloatermNew ranger<cr>",
      desc = "Open Ranger Floaterm",
    },
    {
      "<leader>top",
      "<cmd>FloatermNew python3<cr>",
      desc = "Open Python3 Floaterm",
    },
    {
      "<leader>ton",
      "<cmd>FloatermNew node<cr>",
      desc = "Open Nodejs Floaterm",
    },
    {
      "<leader>tol",
      "<cmd>FloatermNew lua<cr>",
      desc = "Open Lua Floaterm",
    },
    {
      "<leader>gg",
      "<cmd>FloatermNew --cwd=<buffer> lazygit<cr>", -- 选择距离当前 buffer 最近的仓库
      desc = "Lazygit (root dir)",
    },
    {
      "<leader>gG",
      "<cmd>FloatermNew lazygit<cr>", -- 选择进入 vim 时路径的仓库
      desc = "Lazygit (cwd)",
    },
    -- 覆盖 LazyVim 默认的快捷键，防止样式被默认的覆盖
    {
      "<leader>gl",
      "<cmd>FloatermNew --cwd=<buffer> lazygit log<cr>",
      desc = "Lazygit Log",
    },
    {
      "<leader>gL",
      "<cmd>FloatermNew lazygit log<cr>",
      desc = "Lazygit Log (cwd)",
    },
    {
      "<leader>gf",
      function()
        local file = vim.trim(vim.api.nvim_buf_get_name(0))
        vim.api.nvim_command("FloatermNew lazygit log -f " .. file)
      end,
      desc = "Lazygit Current File History",
    },
    {
      "<leader>y",
      "<cmd>FloatermNew yazi<cr>",
      desc = "Open Yazi",
    },
  },
  config = function()
    vim.g.floaterm_borderchars = "─│─│╭╮╯╰"
    -- 设置从 floaterm 打开文件的状态
    vim.g.floaterm_opener = "edit"

    local hl = vim.api.nvim_set_hl
    -- 设置 floaterm 失去焦点后的前景色
    hl(0, "FloatermNC", { fg = "gray" })
  end,
}
