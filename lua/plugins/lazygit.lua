return {
  "kdheepak/lazygit.nvim",
  lazy = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    vim.keymap.set("t", "<C-c>", function()
      vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
      vim.api.nvim_command("LLMAppHandler CommitMsg")
    end, { desc = "AI Commit Msg" })
  end,
}
