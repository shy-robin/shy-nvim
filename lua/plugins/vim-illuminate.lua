return {
  "RRethy/vim-illuminate",
  init = function()
    -- 高亮相同的单词，highlight 链接到 Visual
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
  end
}
