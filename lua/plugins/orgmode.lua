return {
  "nvim-orgmode/orgmode",
  dependencies = {
    "nvim-orgmode/org-bullets.nvim",
    "chipsenkbeil/org-roam.nvim",
    "danilshvalov/org-modern.nvim"
  },
  event = "VeryLazy",
  ft = { "org" },
  config = function()
    local Menu = require("org-modern.menu")

    require("orgmode").setup({
      org_agenda_files = "~/org-files/**/*",
      org_default_notes_file = "~/org-files/refile.org",
      org_startup_folded = "showeverything",
      ui = {
        menu = {
          handler = function(data)
            Menu:new({
              window = {
                margin = { 1, 0, 1, 0 },
                padding = { 0, 1, 0, 1 },
                title_pos = "center",
                border = "rounded",
                zindex = 1000,
              },
              icons = {
                separator = "➜",
              },
            }):open(data)
          end,
        },
      },
    })
    require("org-bullets").setup({
      symbols = {
        checkboxes = {
          done = { "", "@org.keyword.done" },
        },
      },
    })
    require("org-roam").setup({
      directory = "~/org-files/roam",
    })
  end,
}
