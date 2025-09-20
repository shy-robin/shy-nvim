return {
  "mistweaverco/kulala.nvim",
  keys = {
    {
      "<leader>Ra",
      function()
        vim.ui.input({ prompt = "Send all requests? (y/n)" }, function(input)
          if input == "y" then
            require("kulala").run_all()
          end
        end)
      end,
      desc = "Send all requests",
      ft = "http",
      mode = { "n", "v" },
    },
  },
  opts = {
    global_keymaps = true,
    ui = {
      pickers = {
        snacks = {
          layout = function()
            local has_snacks, snacks_picker = pcall(require, "snacks.picker")
            return not has_snacks and {} or vim.tbl_deep_extend("force", snacks_picker.config.layout("default"), {})
          end,
        },
      },
    },
  },
}
