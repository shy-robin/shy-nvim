return {
  "folke/noice.nvim",
  event = "UIEnter",
  opts = {
    presets = {
      bottom_search = false, -- use a classic bottom cmdline for search
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    lsp = {
      progress = {
        enabled = false,
      },
    },
    commands = {
      history = {
        -- options for the message history that you get with `:Noice`
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "echo", "echomsg", "echoerr" } },
            { event = "lsp", kind = "message" },
            { cmdline = true },
          },
        },
        filter_opts = { reverse = true },
      },
    },
  },
  keys = {
    -- 禁用滚动快捷键
    -- 使用 gh 或 K 聚焦到文档窗口，再通过 vim 移动文档
    -- 使用 q 退出文档窗口
    { "<C-f>", false, mode = { "i", "n", "s" } },
    { "<C-b>", false, mode = { "i", "n", "s" } },
    {
      "<leader>sne",
      function()
        require("noice").cmd("errors")
      end,
      desc = "Noice Errors",
    },
    -- TODO: conflict with coc
    -- {
    --   "<C-d>",
    --   function()
    --     if not require("noice.lsp").scroll(4) then return "<C-d>" end
    --   end,
    --   silent = true,
    --   expr = true,
    --   desc = "Scroll forward",
    --   mode = { "i", "n", "s" }
    -- },
    -- {
    --   "<C-u>",
    --   function()
    --     if not require("noice.lsp").scroll(-4) then return "<C-u>" end
    --   end,
    --   silent = true,
    --   expr = true,
    --   desc = "Scroll backward",
    --   mode = { "i", "n", "s" }
    -- },
  },
}

-- TODO: 
-- show all error
-- show all message
