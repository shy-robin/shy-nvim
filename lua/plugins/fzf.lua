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
        -- 不能使用 <C-m> 因为它是 enter 的等效快捷键
        ["<C-l>"] = "toggle-fullscreen",
        ["<C-p>"] = "toggle-preview",
      },
    },
    fzf_opts = {
      ["--cycle"] = true,
    },
  },
}
