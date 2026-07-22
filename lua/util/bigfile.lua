local M = {}

local window_option_names = {
  "foldmethod",
  "foldenable",
  "statuscolumn",
  "conceallevel",
  "cursorline",
  "list",
}

local disabled_window_options = {
  foldmethod = "manual",
  foldenable = false,
  statuscolumn = "",
  conceallevel = 0,
  cursorline = false,
  list = false,
}

local active_buffers = {}
local active_count = 0
local pending_windows = {}
local window_states = {}
local matchparen_disabled = false
local autocmds_created = false

local function get_window_options(win)
  local options = {}
  for _, name in ipairs(window_option_names) do
    options[name] = vim.api.nvim_get_option_value(name, { scope = "local", win = win })
  end
  return options
end

local function set_window_options(win, options)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  for name, value in pairs(options) do
    vim.api.nvim_set_option_value(name, value, { scope = "local", win = win })
  end
end

local function restore_window(win, buf)
  local state = window_states[win]
  if not state or (buf and state.buf ~= buf) then
    return
  end
  set_window_options(win, state.options)
  window_states[win] = nil
end

local function apply_window(buf, win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  local state = window_states[win]
  if state and state.buf ~= buf then
    restore_window(win)
    state = nil
  end

  if not state then
    local pending = pending_windows[buf]
    window_states[win] = {
      buf = buf,
      options = pending and pending[win] or get_window_options(win),
    }
    if pending then
      pending[win] = nil
      if vim.tbl_isempty(pending) then
        pending_windows[buf] = nil
      end
    end
  end

  set_window_options(win, disabled_window_options)
end

local function ensure_autocmds()
  if autocmds_created then
    return
  end
  autocmds_created = true

  local group = vim.api.nvim_create_augroup("bigfile_window_lifecycle", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
      if active_buffers[ev.buf] then
        apply_window(ev.buf, vim.api.nvim_get_current_win())
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = group,
    callback = function(ev)
      restore_window(vim.api.nvim_get_current_win(), ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      local win = tonumber(ev.match)
      if not win then
        return
      end
      window_states[win] = nil
      for buf, windows in pairs(pending_windows) do
        windows[win] = nil
        if vim.tbl_isempty(windows) then
          pending_windows[buf] = nil
        end
      end
    end,
  })
end

---Capture window-local values before BufReadPre changes folding for a huge file.
---@param buf number
function M.prepare(buf)
  ensure_autocmds()
  local windows = vim.fn.win_findbuf(buf)
  if #windows == 0 and vim.api.nvim_get_current_buf() == buf then
    windows = { vim.api.nvim_get_current_win() }
  end

  pending_windows[buf] = pending_windows[buf] or {}
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) and not pending_windows[buf][win] then
      pending_windows[buf][win] = get_window_options(win)
      set_window_options(win, { foldmethod = "manual", foldenable = false })
    end
  end
end

---Mark a buffer active and apply bigfile window options to every window showing it.
---@param buf number
---@return boolean new_buffer
function M.enter(buf)
  ensure_autocmds()
  local new_buffer = not active_buffers[buf]
  if new_buffer then
    if active_count == 0 and vim.g.loaded_matchparen ~= nil and vim.fn.exists(":NoMatchParen") ~= 0 then
      local ok = pcall(vim.cmd, "NoMatchParen")
      matchparen_disabled = ok and vim.g.loaded_matchparen == nil
    end
    active_buffers[buf] = true
    active_count = active_count + 1
  end

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    apply_window(buf, win)
  end
  return new_buffer
end

---Remove a bigfile buffer. Returns true only when it was the final active bigfile.
---@param buf number
---@return boolean last_buffer
function M.leave(buf)
  if not active_buffers[buf] then
    return false
  end

  active_buffers[buf] = nil
  active_count = active_count - 1
  pending_windows[buf] = nil
  for win, state in pairs(window_states) do
    if state.buf == buf then
      restore_window(win, buf)
    end
  end

  if active_count ~= 0 then
    return false
  end

  if matchparen_disabled and vim.fn.exists(":DoMatchParen") ~= 0 then
    pcall(vim.cmd, "DoMatchParen")
  end
  matchparen_disabled = false
  return true
end

---@return integer
function M.count()
  return active_count
end

return M
