return {
  "kawre/leetcode.nvim",
  keys = { "<leader>lc" },
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- required by telescope
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lang = "javascript",
    cn = { -- leetcode.cn
      enabled = true,
    },
  },
}
