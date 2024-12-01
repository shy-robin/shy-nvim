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

        { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = { 2, 2 } },
        { icon = " ", title = "Projects", section = "projects", indent = 3, padding = 2 },
        { section = "startup", padding = 1 },
        {
          align = "center",
          text = "🚀 Sharp tools make good work.",
        },
      },
    },
    bigfile = {
      -- 超过最大限制，不使用任何渲染，防止卡顿
      setup = function()
        vim.b.minianimate_disable = true
      end,
    },
    scratch = {
      win = {
        -- 设置浮动窗口边框透明
        backdrop = 100,
      },
    },
  },
}
