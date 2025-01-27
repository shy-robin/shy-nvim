return {
  "nvim-orgmode/orgmode",
  dependencies = {
    "nvim-orgmode/org-bullets.nvim",
    "chipsenkbeil/org-roam.nvim",
  },
  event = "VeryLazy",
  ft = { "org" },
  config = function()
    require("orgmode").setup({
      org_agenda_files = "~/org-files/**/*",
      org_default_notes_file = "~/org-files/refile.org",
      org_startup_folded = "showeverything",
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
