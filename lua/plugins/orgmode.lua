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
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
      org_startup_folded = "showeverything",
    })
    require("org-bullets").setup()
    require("org-roam").setup({
      directory = "~/org-roam-files",
      org_files = {
        "~/orgfiles/**/*.org",
      },
    })
  end,
}
