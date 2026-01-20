local function get_deterministic_port()
  local cwd = vim.fn.getcwd()
  local hash = 5381
  for i = 1, #cwd do
    hash = ((hash * 33) + string.byte(cwd, i)) % 4294967296
  end
  return 49152 + (hash % (65535 - 49152 + 1))
end

return {
  "NickvanDyke/opencode.nvim",
  event = "VeryLazy",
  dependencies = {
    ---@module 'snacks'
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  init = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      port = get_deterministic_port(),
    }
  end,
  config = function()
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>ox", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })

    vim.keymap.set({ "n", "t" }, "<C-\\>", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { expr = true, desc = "Add range to opencode" })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { expr = true, desc = "Add line to opencode" })

    vim.keymap.set({ "n", "t" }, "<M-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "opencode half page up" })

    vim.keymap.set({ "n", "t" }, "<M-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "opencode half page down" })

    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    -- 把原生功能"挪"到 + 和 - 键上
    vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
    vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
  end,
}
