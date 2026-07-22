local M = {}

function M.directory_argument(argv, fs_stat)
  if #argv ~= 1 then
    return nil
  end

  local path = argv[1]
  local stat = fs_stat(path)
  if stat and stat.type == "directory" then
    return path
  end

  return nil
end

function M.startup_action(vim_did_enter)
  return vim_did_enter == 1 and "schedule" or "VimEnter"
end

function M.open_nvim_tree_for_directory()
  if vim.fn.argc() ~= 1 then
    return false
  end

  local path = M.directory_argument({ vim.fn.argv(0) }, (vim.uv or vim.loop).fs_stat)
  if not path then
    return false
  end

  local open_tree = function()
    require("lazy").load({ plugins = { "nvim-tree.lua" } })
    vim.cmd("NvimTreeOpen " .. vim.fn.fnameescape(path))
  end

  if M.startup_action(vim.v.vim_did_enter) == "schedule" then
    vim.schedule(open_tree)
  else
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = open_tree })
  end

  return true
end

return M
