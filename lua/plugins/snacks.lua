return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      width = 93,
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      autokeys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", -- autokey sequence
      sections = {
        { section = "header" },
        {
          text = { { os.date("%Y-%m-%d %H:%M:%S"), hl = "@property" } },
          align = "center",
          padding = 1,
        },
        -- 自定义文本，使其放在一行
        {
          align = "center",
          padding = 1,
          text = {
            { " File [f] ", hl = "@property" },
            { " New [n] ", hl = "@property" },
            { " Text [g] ", hl = "@property" },
            { " Recent [r] ", hl = "@property" },
            { " Config [c] ", hl = "@property" },
            { " Session [s] ", hl = "@property" },
            { "󰒲 Lazy [l] ", hl = "@property" },
            { " Quit [q]", hl = "@property" },
          },
        },
        -- 隐藏快捷键
        { key = "f", action = ":lua Snacks.dashboard.pick('files')", hidden = true },
        { key = "n", action = ":ene | startinsert", hidden = true },
        { key = "g", action = ":lua Snacks.dashboard.pick('live_grep')", hidden = true },
        { key = "r", action = ":lua Snacks.dashboard.pick('oldfiles')", hidden = true },
        {
          key = "c",
          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          hidden = true,
        },
        { key = "s", section = "session", hidden = true },
        { key = "l", action = ":Lazy", enabled = package.loaded.lazy ~= nil, hidden = true },
        { key = "q", action = ":qa", hidden = true },

        { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = 2 },
        { icon = " ", title = "Projects", section = "projects", indent = 3, padding = 2 },
        { section = "startup", padding = 1 },
        {
          align = "center",
          text = "🚀 Sharp tools make good work.",
        },
      },
    },
    bigfile = {
      enabled = true,
      notify = true,
      size = 0.4 * 1024 * 1024, -- 0.4MB
      -- 超过最大限制，不使用任何渲染，防止卡顿
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        -- 停止 Supermaven 插件
        vim.cmd("SupermavenStop")
        -- 增加缓冲区变量，标识大文件类型
        vim.b.bigfile = true
        -- 禁用 Treesitter
        -- DisableSyntaxTreesitter()

        if vim.fn.exists(":NoMatchParen") ~= 0 then
          vim.cmd([[NoMatchParen]])
        end
        Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
        vim.b.minianimate_disable = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)
      end,
    },
    scroll = {
      enabled = false,
    },
    win = {
      -- 设置所有浮动窗口边框透明
      backdrop = 100,
    },
    image = {
      enabled = true,
    },
    lazygit = {
      -- 专门针对 lazygit 浮窗的配置
      win = {
        border = "rounded", -- 给 lazygit 加上圆角边框
      },
    },
  },
  keys = {
    {
      "<leader>N",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
  },
  init = function()
    -- 注册快捷调试打印命令 dd，例如：`: lua dd(vim.fn.getcwd())`
    -- 参考：https://github.com/folke/snacks.nvim/blob/main/docs/debug.md
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command
      end,
    })
  end,
}
