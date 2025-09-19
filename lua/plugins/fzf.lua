local actions = require("fzf-lua").actions

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
        ["<C-f>"] = "toggle-help",
        -- 不能使用 <C-m> 因为它是 enter 的等效快捷键
        ["<C-o>"] = "toggle-fullscreen",
        ["<C-a>"] = "toggle-preview",
        ["<C-n>"] = "preview-page-down",
        ["<C-p>"] = "preview-page-up",
      },
      fzf = {
        true,
        ["ctrl-h"] = "prev-history",
        ["ctrl-l"] = "next-history",
      },
    },
    fzf_opts = {
      ["--cycle"] = true,
      ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
    },
    actions = {
      -- Below are the default actions, setting any value in these tables will override
      -- the defaults, to inherit from the defaults change [1] from `false` to `true`
      files = {
        true, -- uncomment to inherit all the below in your custom config
        -- 将所选文件添加到 quickfix 列表，使用 :copen 打开列表（使用 ctrl+i 多选文件）
        ["ctrl-t"] = actions.file_sel_to_qf,
        -- 将所选文件添加到 location 列表，使用 :lopen 打开列表（使用 ctrl+i 多选文件）
        ["ctrl-y"] = actions.file_sel_to_ll,
        ["ctrl-w"] = actions.toggle_hidden,
        ["ctrl-e"] = { fn = actions.toggle_ignore },
        ["ctrl-r"] = actions.toggle_follow,
      },
    },
  },
}
