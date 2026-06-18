local get_colorscheme = function()
  local path = vim.fn.stdpath("data") .. "/shy-nvim_theme_cache"
  local exists, lines = pcall(vim.fn.readfile, path)
  if exists and lines[1] then
    return lines[1]
  end
  return "material"
end

-- 备选配色插件：默认懒加载（defaults.lazy = true），不挂 VeryLazy。
-- lazy.nvim 会在 `:colorscheme xxx` 被调用时按需自动加载对应插件，
-- 因此这些用不到的主题不会在启动/VeryLazy 时白白 source colors 文件。
return {
  { "sainnhe/everforest" },
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim" },
  { "sainnhe/sonokai" },
  { "mhartington/oceanic-next" },
  { "rockerBOO/boo-colorscheme-nvim" },
  { "marko-cerovac/material.nvim" },
  { "Mofiqul/vscode.nvim" },
  { "rmehri01/onenord.nvim" },
  { "projekt0n/github-nvim-theme" },
  {
    "olimorris/onedarkpro.nvim",
    opts = {
      transparency = false,
    },
  },
  { "shaunsingh/nord.nvim" },
  { "lunarvim/darkplus.nvim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "wuelnerdotexe/vim-enfocado" },
  { "cranberry-clockworks/coal.nvim" },
  {
    "LazyVim/LazyVim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      colorscheme = get_colorscheme(),
    },
  },
}
