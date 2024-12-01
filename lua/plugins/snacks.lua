return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      formats = {
        key = function(item)
          return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
        end,
      },
      autokeys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", -- autokey sequence
      sections = {
        { section = "header" },
        { section = "startup", padding = 1 },
        { section = "keys", gap = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 3, padding = { 2, 2 } },
        { icon = " ", title = "Projects", section = "projects", indent = 3, padding = 2 },
      },
    },
  },
}
