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
      desc = "Set Next Available Mark",
    },
    {
      "m<space>",
      "<Plug>(Marks-toggle)",
      silent = true,
      desc = "Toggle Mark at Cursor",
    },
    {
      "ma",
      "<Plug>(Marks-set)",
      silent = true,
      desc = "Set Named Mark",
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
      desc = "Delete Marks on Current Line",
    },
    {
      "<leader>md,",
      "<cmd>:delm!<cr>",
      silent = true,
      desc = "Delete Local Marks in Buffer",
    },
    {
      "<leader>md",
      "<Plug>(Marks-delete)",
      silent = true,
      desc = "Delete Named Mark",
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
