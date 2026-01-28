local function get_colorscheme()
  local path = vim.fn.stdpath("data") .. "/shy-nvim_theme_cache"
  local exists, lines = pcall(vim.fn.readfile, path)
  if exists and lines[1] then
    return lines[1]
  end
  return "material"
end

local themes = {
  "sainnhe/everforest",
  "folke/tokyonight.nvim", 
  "catppuccin/nvim",
  "sainnhe/sonokai",
  "mhartington/oceanic-next",
  "rockerBOO/boo-colorscheme-nvim",
  "marko-cerovac/material.nvim",
  "Mofiqul/vscode.nvim",
  "rmehri01/onenord.nvim",
  "projekt0n/github-nvim-theme",
  "olimorris/onedarkpro.nvim",
  "shaunsingh/nord.nvim",
  "lunarvim/darkplus.nvim",
  "nyoom-engineering/oxocarbon.nvim",
  "wuelnerdotexe/vim-enfocado",
  "cranberry-clockworks/coal.nvim",
}

local theme_specs = {}
for _, theme in ipairs(themes) do
  local spec = { theme, event = "VeryLazy" }
  
  -- 特殊配置
  if theme == "olimorris/onedarkpro.nvim" then
    spec.opts = { transparency = false }
  end
  
  table.insert(theme_specs, spec)
end

table.insert(theme_specs, {
  "LazyVim/LazyVim",
  lazy = false,
  priority = 1000,
  opts = {
    colorscheme = get_colorscheme(),
  },
})

return theme_specs