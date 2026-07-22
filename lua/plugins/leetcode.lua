return {
  "kawre/leetcode.nvim",
  cmd = { "Leet" },
  build = ":TSUpdate html",
  dependencies = {
    "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    picker = { provider = "fzf-lua" },
    lang = "javascript",
    cn = { -- leetcode.cn
      enabled = true,
    },
  },
}
