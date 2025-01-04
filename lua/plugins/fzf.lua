return {
  "ibhagwan/fzf-lua",
  opts = {
    winopts = {
      backdrop = 100,
    },
    keymap = {
      builtin = {
        true,
        ["<Esc>"] = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
        ["<C-h>"] = "toggle-help",
        ["<C-m>"] = "toggle-fullscreen",
        ["<C-p>"] = "toggle-preview",
      },
    },
    fzf_opts = {
      ["--cycle"] = true,
    },
  },
}
