local filetypes = {
  "css",
  "scss",
  "sass",
  "less",
  "html",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "vue",
  "svelte",
  "astro",
}

return {
  "catgoose/nvim-colorizer.lua",
  ft = filetypes,
  cmd = {
    "ColorizerAttachToBuffer",
    "ColorizerDetachFromBuffer",
    "ColorizerReloadAllBuffers",
    "ColorizerToggle",
  },
  opts = {
    filetypes = filetypes,
    user_default_options = {
      css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
    },
  },
}
