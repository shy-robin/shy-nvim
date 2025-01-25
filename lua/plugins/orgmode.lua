return {
  "nvim-orgmode/orgmode",
  dependencies = {
    "nvim-orgmode/org-bullets.nvim",
  },
  event = "VeryLazy",
  ft = { "org" },
  config = function()
    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
    })
    require("org-bullets").setup()
  end,
}
