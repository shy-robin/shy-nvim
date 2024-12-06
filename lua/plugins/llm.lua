return {
  "Kurama622/llm.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  cmd = { "LLMSesionToggle", "LLMSelectedTextHandler" },
  config = function()
    -- 获取当前用户名称，兼容不同操作系统
    local username

    if package.config:sub(1, 1) == "\\" then
      -- Windows系统
      username = os.getenv("USERNAME")
    else
      -- Unix-like系统
      username = os.getenv("USER")
    end

    local robotName = "Assistant"

    local userTitle = "  " .. username .. "\n\n"
    local robotTitle = "󱙺  " .. robotName .. "\n\n"

    require("llm").setup({
      max_tokens = 512,
      url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
      model = "glm-4-flash",
      prefix = {
        user = { text = userTitle, hl = "Title" },
        assistant = { text = robotTitle, hl = "Added" },
      },

      save_session = true,
      max_history = 15,

        -- stylua: ignore
        keys = {
          -- The keyboard mapping for the input window.
          ["Input:Submit"]      = { mode = "n", key = "<cr>" },
          ["Input:Cancel"]      = { mode = "n", key = "<C-c>" },
          ["Input:Resend"]      = { mode = "n", key = "<C-r>" },

          -- only works when "save_session = true"
          ["Input:HistoryNext"] = { mode = "n", key = "<C-j>" },
          ["Input:HistoryPrev"] = { mode = "n", key = "<C-k>" },

          -- The keyboard mapping for the output window in "split" style.
          ["Output:Ask"]        = { mode = "n", key = "i" },
          ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
          ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

          -- The keyboard mapping for the output and input windows in "float" style.
          ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
          ["Session:Close"]     = { mode = "n", key = "<esc>" },
        },
    })
  end,
  keys = {
    { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>", desc = "Chat" },
    { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>", desc = "Explain" },
    {
      "<leader>at",
      mode = "x",
      "<cmd>LLMSelectedTextHandler 如果是英文则翻译成中文，如果是中文则翻译成英文<cr>",
      desc = "Translate",
    },
  },
}
