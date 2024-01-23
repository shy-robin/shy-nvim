-- 每个 tab 只展示自己的 buffers
return {
  "tiagovla/scope.nvim",
  config = function()
    require("scope").setup({})
  end,
}
