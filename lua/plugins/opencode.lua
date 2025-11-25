return {
  "NickvanDyke/opencode.nvim",
  event = "VeryLazy",
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }
    -- Required for `opts.events.reload`.
    vim.o.autoread = true
  end,
  keys = {
    {
      "<leader>aoo",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      desc = "Ask opencode",
      mode = { "n", "x" },
    },
    {
      "<leader>aoe",
      function()
        require("opencode").select()
      end,
      desc = "Execute opencode action",
      mode = { "n", "x" },
    },
    {
      "<leader>aoa",
      function()
        require("opencode").prompt("@this")
      end,
      desc = "Add to opencode",
      mode = { "n", "x" },
    },
    {
      "<leader>aot",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle opencode",
      mode = { "n", "t" },
    },
    -- {
    --   "<leader>aoc",
    --   function()
    --     require("opencode").command()
    --   end,
    --   desc = "Open opencode command",
    --   mode = { "n", "t" },
    -- },
  },
}
