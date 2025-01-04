get_colorscheme = function()
  local path = vim.fn.stdpath("data") .. "/shy-nvim_theme_cache"
  local exists, lines = pcall(vim.fn.readfile, path)
  if exists and lines[1] then
    return lines[1]
  end
  return "material"
end

return {
  {
    "sainnhe/everforest",
    event = "VeryLazy",
  },
  {
    "folke/tokyonight.nvim",
    event = "VeryLazy",
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
    "rockerBOO/boo-colorscheme-nvim",
    event = "VeryLazy",
  },
  {
    "marko-cerovac/material.nvim",
    event = "VeryLazy",
  },
  {
    "Mofiqul/vscode.nvim",
    event = "VeryLazy",
  },
  {
    "rmehri01/onenord.nvim",
    event = "VeryLazy",
  },
  {
    "projekt0n/github-nvim-theme",
    event = "VeryLazy",
  },
  {
    "olimorris/onedarkpro.nvim",
    event = "VeryLazy",
    opts = {
      transparency = false,
    },
  },
  {
    "shaunsingh/nord.nvim",
    event = "VeryLazy",
  },
  {
    "lunarvim/darkplus.nvim",
    event = "VeryLazy",
  },
  {
    "LazyVim/LazyVim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      colorscheme = get_colorscheme(),
    },
  },
}
