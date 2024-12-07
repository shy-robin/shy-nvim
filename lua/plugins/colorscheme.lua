return {
  {
    "sainnhe/everforest",
    event = "VeryLazy",
  },
  {
    "folke/tokyonight.nvim",
    event = "VeryLazy",
    -- lazy = true,
    -- opts = { style = "night" },
  },
  {
    "navarasu/onedark.nvim",
    event = "VeryLazy",
    -- lazy = true,
    -- opts = { style = "cool" },
  },
  {
    "catppuccin/nvim",
    event = "VeryLazy",
  },
  {
    "sainnhe/sonokai",
    event = "VeryLazy",
  },
  {
    "mhartington/oceanic-next",
    event = "VeryLazy",
  },
  {
    "Th3Whit3Wolf/one-nvim",
    event = "VeryLazy",
  },
  {
    "rockerBOO/boo-colorscheme-nvim",
    event = "VeryLazy",
  },
  {
    "marko-cerovac/material.nvim",
    event = "VeryLazy",
  },
  {
    "RRethy/nvim-base16",
    event = "VeryLazy",
  },
  {
    "Mofiqul/vscode.nvim",
    event = "VeryLazy",
  },
  {
    "LazyVim/LazyVim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      colorscheme = "material-oceanic",
    },
  },
}
