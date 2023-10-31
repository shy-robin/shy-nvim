return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  opts = {
    default_mappings = false,
    force_write_shada = true,
    cyclic = true,
    -- 显示内置 marks
    -- builtin_marks = { ".", "<", ">", "^", "'" },
  },
  init = function()
    local hl = vim.api.nvim_set_hl
    hl(0, "MarkSignHL", { link = "CursorLineNr" })
  end,
  keys = {
    {
      "m,",
      "<Plug>(Marks-setnext)",
      silent = true,
      desc = "Marks Set Next",
    },
    {
      "m<space>",
      "<Plug>(Marks-toggle)",
      silent = true,
      desc = "Marks Toggle",
    },
    {
      "ma",
      "<Plug>(Marks-set)",
      silent = true,
      desc = "Marks Set",
    },
    {
      "gmj",
      "<Plug>(Marks-next)",
      silent = true,
      desc = "Marks Next",
    },
    {
      "gmk",
      "<Plug>(Marks-prev)",
      silent = true,
      desc = "Marks Prev",
    },
    {
      "<leader>md-",
      "<Plug>(Marks-deleteline)",
      silent = true,
      desc = "Marks Delete line",
    },
    {
      "<leader>md,",
      "<cmd>:delm!<cr>",
      silent = true,
      desc = "Marks Delete Buffer",
    },
    {
      "<leader>md",
      "<Plug>(Marks-delete)",
      silent = true,
      desc = "Marks Delete",
    },
    {
      "m:",
      "<Plug>(Marks-preview)",
      silent = true,
      desc = "Marks Preview",
    },
    {
      "<leader>ml",
      "<cmd>MarksListAll<cr>",
      silent = true,
      desc = "Marks List All",
    },
  },
}
