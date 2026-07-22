-- Run from the repository root without touching the user's XDG state:
-- bash -c 'tmp=$(mktemp -d); XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" \
-- XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache" \
-- NVIM_TEST_LAZY_ROOT="$HOME/.local/share/nvim/lazy" \
-- nvim --headless -u NORC +"luafile tests/bigfile_spec.lua" +qa; code=$?; rm -rf "$tmp"; exit $code'

local repo = vim.fn.getcwd()
local lazy_root = vim.env.NVIM_TEST_LAZY_ROOT
assert(lazy_root and lazy_root ~= "", "NVIM_TEST_LAZY_ROOT must point to the installed lazy plugin root")

vim.opt.runtimepath:prepend(repo)
vim.opt.runtimepath:prepend(lazy_root .. "/snacks.nvim")
package.path = repo .. "/lua/?.lua;" .. repo .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype on")

local tempdir = vim.fn.tempname()
vim.fn.mkdir(tempdir, "p")
tempdir = vim.uv.fs_realpath(tempdir) or tempdir

local function write_lines(path, count, width)
  local line = string.rep("x", width)
  local chunk = {}
  for _ = 1, 1000 do
    chunk[#chunk + 1] = line
  end
  vim.fn.writefile({}, path)
  local fd = assert(io.open(path, "ab"))
  for _ = 1, math.floor(count / #chunk) do
    fd:write(table.concat(chunk, "\n"), "\n")
  end
  for _ = 1, count % #chunk do
    fd:write(line, "\n")
  end
  fd:close()
end

local normal1 = tempdir .. "/normal-one.lua"
local normal2 = tempdir .. "/normal-two.lua"
local medium1 = tempdir .. "/medium-one.lua"
local medium2 = tempdir .. "/medium-two.lua"
local huge = tempdir .. "/huge.lua"
vim.fn.writefile({ "local one = 1", "return one" }, normal1)
vim.fn.writefile({ "local two = 2", "return two" }, normal2)
write_lines(medium1, 5000, 100)
write_lines(medium2, 5100, 100)
write_lines(huge, 105000, 100)
assert(vim.fn.getfsize(medium1) > 0.4 * 1024 * 1024, "medium fixture must cross Snacks threshold")
assert(vim.fn.getfsize(huge) > 10 * 1024 * 1024, "huge fixture must cross pre-read threshold")

local noice = {
  disable_calls = 0,
  enable_calls = 0,
  enabled = true,
  running = true,
  disable_mode = nil,
  fail_enable = false,
}
function noice.disable()
  noice.disable_calls = noice.disable_calls + 1
  if noice.disable_mode == "error" then
    error("Noice disable failed before changing state")
  end
  noice.enabled = false
  noice.running = false
  if noice.disable_mode == "stop_then_error" then
    error("Noice disable failed after stopping")
  end
end
function noice.enable()
  noice.enable_calls = noice.enable_calls + 1
  if noice.fail_enable then
    error("Noice enable failed")
  end
  noice.enabled = true
  noice.running = true
end
package.loaded.noice = noice
package.preload.noice = function()
  return noice
end
package.preload["noice.config"] = function()
  return {
    is_running = function()
      return noice.running
    end,
  }
end

local supermaven_stop_calls = 0
vim.api.nvim_create_user_command("SupermavenStop", function()
  supermaven_stop_calls = supermaven_stop_calls + 1
end, {})

vim.cmd("runtime plugin/matchparen.vim")
assert(vim.g.loaded_matchparen ~= nil, "the real MatchParen plugin must start enabled")

dofile(repo .. "/lua/config/options.lua")
local snacks_spec = dofile(repo .. "/lua/plugins/snacks.lua")
require("snacks").setup({ bigfile = snacks_spec.opts.bigfile })
local supermaven_condition = dofile(repo .. "/lua/plugins/supermaven.lua").opts.condition

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

local function set_window_options(win, values)
  for name, value in pairs(values) do
    vim.api.nvim_set_option_value(name, value, { scope = "local", win = win })
  end
end

local function get_window_options(win)
  local values = {}
  for _, name in ipairs(window_option_names) do
    values[name] = vim.api.nvim_get_option_value(name, { scope = "local", win = win })
  end
  return values
end

local function eq(actual, expected, message)
  assert(
    vim.deep_equal(actual, expected),
    string.format("%s\nexpected: %s\nactual:   %s", message, vim.inspect(expected), vim.inspect(actual))
  )
end

local function edit(path)
  vim.cmd("edit! " .. vim.fn.fnameescape(path))
  vim.wait(1000, function()
    return vim.bo.filetype ~= ""
  end)
  if vim.b.bigfile == true and vim.v.vim_did_enter == 0 then
    vim.cmd("doautocmd VimEnter")
    vim.wait(100, function()
      return vim.g._bigfile_noice_disabled == true
    end)
  end
  return vim.api.nvim_get_current_buf()
end

local function set_buffer(buf)
  vim.api.nvim_set_current_buf(buf)
  vim.wait(100, function()
    return vim.api.nvim_get_current_buf() == buf
  end)
end

local function delete_buffer(buf)
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

local failures = {}
local base_tab = vim.api.nvim_get_current_tabpage()

local function cleanup_test_state()
  if vim.api.nvim_tabpage_is_valid(base_tab) then
    pcall(vim.api.nvim_set_current_tabpage, base_tab)
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:sub(1, #tempdir) == tempdir then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  pcall(vim.cmd, "silent! tabonly!")
  vim.g._bigfile_noice_disabled = false
  noice.enabled = true
  noice.running = true
  noice.disable_calls = 0
  noice.enable_calls = 0
  noice.disable_mode = nil
  noice.fail_enable = false
  supermaven_stop_calls = 0
  vim.o.cmdheight = 0
  if vim.g.loaded_matchparen == nil and vim.fn.exists(":DoMatchParen") ~= 0 then
    pcall(vim.cmd, "DoMatchParen")
  end
end

local function test(name, fn)
  cleanup_test_state()
  vim.cmd("tabnew")
  local ok, err = xpcall(fn, debug.traceback)
  cleanup_test_state()
  if not ok then
    failures[#failures + 1] = name .. ":\n" .. err
  end
end

test("restores one window after normal to huge to normal and keeps memory undo", function()
  vim.o.swapfile = true
  vim.o.undofile = true
  vim.o.undolevels = 1000

  local normal_buf = edit(normal1)
  local win = vim.api.nvim_get_current_win()
  local original = {
    foldmethod = "marker",
    foldenable = true,
    statuscolumn = "%l ",
    conceallevel = 2,
    cursorline = true,
    list = true,
  }
  set_window_options(win, original)
  assert(supermaven_condition() == false, "Supermaven condition must allow an ordinary buffer")

  local huge_buf = edit(huge)
  assert(
    vim.b[huge_buf].bigfile == true,
    string.format(
      "huge buffer must be marked as bigfile (buf=%d normal_buf=%d name=%s ft=%s rematch=%s size=%d)",
      huge_buf,
      normal_buf,
      vim.api.nvim_buf_get_name(huge_buf),
      vim.bo[huge_buf].filetype,
      vim.inspect(vim.filetype.match({ filename = vim.api.nvim_buf_get_name(huge_buf), buf = huge_buf })),
      vim.fn.getfsize(vim.api.nvim_buf_get_name(huge_buf))
    )
  )
  eq(get_window_options(win), disabled_window_options, "huge buffer must disable expensive window options")
  assert(vim.bo[huge_buf].swapfile == false, "huge buffer must disable swapfile")
  assert(vim.bo[huge_buf].undofile == false, "huge buffer must disable persistent undo")
  assert(vim.bo[huge_buf].undolevels ~= -1, "huge buffer must keep in-memory undo enabled")
  assert(supermaven_condition() == true, "Supermaven condition must reject a bigfile buffer")
  assert(supermaven_stop_calls == 0, "bigfile setup must not stop Supermaven globally")

  local first = vim.api.nvim_buf_get_lines(huge_buf, 0, 1, false)[1]
  vim.api.nvim_buf_set_lines(huge_buf, 0, 1, false, { "changed" })
  vim.cmd("silent undo")
  assert(vim.api.nvim_buf_get_lines(huge_buf, 0, 1, false)[1] == first, "in-memory undo must restore edits")

  set_buffer(normal_buf)
  eq(get_window_options(win), original, "switching back to the ordinary buffer must restore exact window options")
  assert(noice.enabled == false, "Noice must stay disabled while the hidden bigfile still exists")
  assert(vim.o.cmdheight == 1, "cmdheight must stay at 1 while Noice is disabled")

  delete_buffer(huge_buf)
  assert(noice.enabled == true, "Noice must be restored after the last bigfile is deleted")
  assert(noice.enable_calls == 1, "Noice must be enabled exactly once")
  assert(vim.o.cmdheight == 0, "cmdheight must return to 0 after Noice is restored")
end)

test("restores distinct options in every window showing one bigfile", function()
  local normal_buf1 = edit(normal1)
  local win1 = vim.api.nvim_get_current_win()
  local original1 = {
    foldmethod = "marker",
    foldenable = true,
    statuscolumn = "%l ",
    conceallevel = 1,
    cursorline = true,
    list = false,
  }
  set_window_options(win1, original1)

  vim.cmd("vsplit " .. vim.fn.fnameescape(normal2))
  local normal_buf2 = vim.api.nvim_get_current_buf()
  local win2 = vim.api.nvim_get_current_win()
  local original2 = {
    foldmethod = "indent",
    foldenable = false,
    statuscolumn = "%=%l",
    conceallevel = 3,
    cursorline = false,
    list = true,
  }
  set_window_options(win2, original2)

  vim.api.nvim_set_current_win(win1)
  local big_buf = edit(medium1)
  vim.api.nvim_set_current_win(win2)
  set_buffer(big_buf)

  eq(get_window_options(win1), disabled_window_options, "first window must use bigfile options")
  eq(get_window_options(win2), disabled_window_options, "second window must use bigfile options")

  vim.api.nvim_set_current_win(win1)
  set_buffer(normal_buf1)
  eq(get_window_options(win1), original1, "first window must restore its own original values")
  eq(get_window_options(win2), disabled_window_options, "second window must remain optimized while showing bigfile")

  vim.api.nvim_set_current_win(win2)
  set_buffer(normal_buf2)
  eq(get_window_options(win2), original2, "second window must restore its own original values")
  delete_buffer(big_buf)
end)

test("restores MatchParen and Noice only after the final bigfile is deleted", function()
  assert(vim.g.loaded_matchparen ~= nil, "MatchParen must begin enabled")
  local big1 = edit(medium1)
  assert(vim.g.loaded_matchparen == nil, "first bigfile must disable MatchParen")
  assert(noice.disable_calls == 1 and noice.enabled == false, "first bigfile must disable Noice once")

  vim.cmd("vsplit " .. vim.fn.fnameescape(medium2))
  local big2 = vim.api.nvim_get_current_buf()
  assert(vim.b[big2].bigfile == true, "second fixture must be detected as bigfile")
  assert(noice.disable_calls == 1, "second bigfile must not disable Noice again")

  delete_buffer(big1)
  assert(vim.g.loaded_matchparen == nil, "MatchParen must remain disabled while another bigfile exists")
  assert(
    noice.enabled == false and noice.enable_calls == 0,
    "Noice must remain disabled after deleting only one bigfile"
  )
  assert(vim.o.cmdheight == 1, "cmdheight must remain 1 until the final bigfile is deleted")

  delete_buffer(big2)
  assert(vim.g.loaded_matchparen ~= nil, "MatchParen must be restored after the final bigfile is deleted")
  assert(noice.enabled == true and noice.enable_calls == 1, "Noice must be restored once after the final deletion")
  assert(vim.o.cmdheight == 0, "cmdheight must return to 0 after the final deletion")
end)

test("does not enable Noice when the user had disabled it", function()
  noice.enabled = false
  noice.running = false
  vim.o.cmdheight = 1

  local big = edit(medium1)
  assert(noice.disable_calls == 0, "bigfile must not claim an already-disabled Noice instance")
  assert(vim.g._bigfile_noice_disabled ~= true, "already-disabled Noice must not set the ownership flag")

  delete_buffer(big)
  assert(noice.enable_calls == 0, "deleting the bigfile must not enable user-disabled Noice")
  assert(noice.enabled == false, "user-disabled Noice must remain disabled")
end)

test("leaves a running Noice untouched when disable fails before changing state", function()
  noice.disable_mode = "error"
  local big = edit(medium1)

  assert(noice.disable_calls == 1, "test precondition: bigfile attempted to disable Noice")
  assert(
    noice.running == true and noice.enabled == true,
    "failed disable without a state change must keep Noice running"
  )
  assert(vim.g._bigfile_noice_disabled ~= true, "failed disable without a state change must not claim ownership")
  assert(vim.o.cmdheight == 0, "running Noice must keep cmdheight at 0")
  delete_buffer(big)
  assert(noice.enable_calls == 0, "unchanged Noice must not be enabled during cleanup")
end)

test("rolls back Noice after disable stops it then raises", function()
  noice.disable_mode = "stop_then_error"
  local big = edit(medium1)

  assert(noice.disable_calls == 1, "test precondition: bigfile attempted to disable Noice")
  assert(noice.enable_calls == 1, "partially stopped Noice must be immediately re-enabled")
  assert(noice.running == true and noice.enabled == true, "successful rollback must restore Noice")
  assert(vim.g._bigfile_noice_disabled ~= true, "successful rollback must not claim ownership")
  assert(vim.o.cmdheight == 0, "successful rollback must restore cmdheight")
  delete_buffer(big)
  assert(noice.enable_calls == 1, "rolled back Noice must not be enabled again during cleanup")
end)

test("retains ownership when Noice rollback after partial disable fails", function()
  noice.disable_mode = "stop_then_error"
  noice.fail_enable = true
  local big = edit(medium1)

  assert(noice.disable_calls == 1, "test precondition: bigfile attempted to disable Noice")
  assert(noice.enable_calls == 1, "partial disable must attempt immediate rollback")
  assert(noice.running == false and noice.enabled == false, "failed rollback must leave Noice stopped")
  assert(vim.g._bigfile_noice_disabled == true, "failed rollback must retain ownership for final cleanup")
  assert(vim.o.cmdheight == 1, "failed rollback must retain native-message protection")
  delete_buffer(big)
  assert(noice.enable_calls == 2, "final cleanup must retry Noice restoration")
  assert(vim.g._bigfile_noice_disabled == true, "failed final restoration must retain ownership")
  assert(vim.o.cmdheight == 1, "failed final restoration must retain native-message protection")
end)

test("keeps cmdheight protection when Noice restoration fails", function()
  local big = edit(medium1)
  assert(noice.enabled == false, "test precondition: bigfile disabled Noice")
  assert(vim.o.cmdheight == 1, "test precondition: bigfile protected native messages")

  noice.fail_enable = true
  delete_buffer(big)
  assert(vim.g._bigfile_noice_disabled == true, "failed restoration must keep ownership flag set")
  assert(noice.enabled == false, "failed restoration must leave Noice disabled")
  assert(vim.o.cmdheight == 1, "failed restoration must keep native-message cmdheight protection")
end)

test("does not enable MatchParen when the user had disabled it", function()
  vim.cmd("NoMatchParen")
  assert(vim.g.loaded_matchparen == nil, "test precondition: MatchParen is user-disabled")

  local big = edit(medium1)
  assert(vim.g.loaded_matchparen == nil, "bigfile must preserve the disabled MatchParen state")
  delete_buffer(big)
  assert(vim.g.loaded_matchparen == nil, "deleting the last bigfile must not enable user-disabled MatchParen")
end)

test("direct huge-file startup disables Noice after VimEnter without hit-enter regression", function()
  local child_root = tempdir .. "/child-xdg"
  local result_path = tempdir .. "/startup-result.txt"
  local init_path = tempdir .. "/startup-init.lua"
  vim.fn.mkdir(child_root, "p")
  local init = string.format(
    [[
vim.opt.runtimepath:prepend(%q)
vim.opt.runtimepath:prepend(%q)
package.path = %q .. "/lua/?.lua;" .. %q .. "/lua/?/init.lua;" .. package.path
local state = { enabled = false, disable_calls = 0, enable_calls = 0 }
local noice = {}
function noice.enable()
  state.enable_calls = state.enable_calls + 1
  state.enabled = true
  vim.o.cmdheight = 0
end
function noice.disable()
  state.disable_calls = state.disable_calls + 1
  state.enabled = false
end
package.loaded.noice = noice
package.preload.noice = function() return noice end
vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = noice.enable })
dofile(%q .. "/lua/config/options.lua")
local spec = dofile(%q .. "/lua/plugins/snacks.lua")
require("snacks").setup({ bigfile = spec.opts.bigfile })
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      vim.fn.writefile({
        "bigfile=" .. tostring(vim.b.bigfile),
        "noice_enabled=" .. tostring(state.enabled),
        "disable_calls=" .. tostring(state.disable_calls),
        "cmdheight=" .. tostring(vim.o.cmdheight),
      }, %q)
      vim.cmd("qa!")
    end, 100)
  end,
})
]],
    repo,
    lazy_root .. "/snacks.nvim",
    repo,
    repo,
    repo,
    repo,
    result_path
  )
  vim.fn.writefile(vim.split(init, "\n", { plain = true }), init_path)

  local proc = vim
    .system({ vim.v.progpath, "--headless", "-u", init_path, huge }, {
      clear_env = false,
      env = {
        XDG_CONFIG_HOME = child_root .. "/config",
        XDG_DATA_HOME = child_root .. "/data",
        XDG_STATE_HOME = child_root .. "/state",
        XDG_CACHE_HOME = child_root .. "/cache",
      },
      text = true,
    })
    :wait(15000)
  assert(
    proc.code == 0,
    string.format(
      "direct startup must exit cleanly instead of hanging at hit-enter: code=%s stderr=%s",
      vim.inspect(proc.code),
      proc.stderr or ""
    )
  )
  local result = table.concat(vim.fn.readfile(result_path), "\n")
  assert(result:find("bigfile=true", 1, true), "direct startup must detect the huge file")
  assert(result:find("noice_enabled=false", 1, true), "Noice must be disabled after its VimEnter enable")
  assert(result:find("disable_calls=1", 1, true), "Noice must be disabled exactly once during startup")
  assert(result:find("cmdheight=1", 1, true), "cmdheight must be 1 after startup Noice disable")
end)

test("startup deletion before scheduled Noice disable restores cmdheight for running Noice", function()
  local child_root = tempdir .. "/startup-delete-xdg"
  local result_path = tempdir .. "/startup-delete-result.txt"
  local init_path = tempdir .. "/startup-delete-init.lua"
  vim.fn.mkdir(child_root, "p")
  local init = string.format(
    [[
vim.opt.runtimepath:prepend(%q)
vim.opt.runtimepath:prepend(%q)
package.path = %q .. "/lua/?.lua;" .. %q .. "/lua/?/init.lua;" .. package.path
local state = { enabled = true, running = true, disable_calls = 0, enable_calls = 0 }
local noice = {}
function noice.enable()
  state.enable_calls = state.enable_calls + 1
  state.enabled = true
  state.running = true
  vim.o.cmdheight = 0
end
function noice.disable()
  state.disable_calls = state.disable_calls + 1
  state.enabled = false
  state.running = false
end
package.loaded.noice = noice
package.preload.noice = function() return noice end
package.preload["noice.config"] = function()
  return { is_running = function() return state.running end }
end
vim.api.nvim_create_autocmd("BufDelete", { callback = function() state.bufdelete = true end })
-- This FileType handler runs before Snacks' handler. It adds a VimEnter deletion callback;
-- Snacks then adds its schedule_wrap callback, so the real BufDelete cleanup wins the race.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "bigfile",
  once = true,
  callback = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.schedule(function()
          local current = vim.api.nvim_get_current_buf()
          state.before_name = vim.api.nvim_buf_get_name(current)
          state.before_bigfile = vim.b[current].bigfile
          state.delete_ok, state.delete_error = pcall(vim.cmd, "bdelete!")
          vim.defer_fn(function()
            vim.fn.writefile({
            "before_name=" .. state.before_name,
            "before_bigfile=" .. tostring(state.before_bigfile),
            "delete_ok=" .. tostring(state.delete_ok),
            "delete_error=" .. tostring(state.delete_error),
            "bufdelete=" .. tostring(state.bufdelete),
            "bigfile_count=" .. tostring(require("util.bigfile").count()),
            "noice_enabled=" .. tostring(state.enabled),
            "noice_running=" .. tostring(state.running),
            "disable_calls=" .. tostring(state.disable_calls),
              "cmdheight=" .. tostring(vim.o.cmdheight),
            }, %q)
            vim.cmd("qa!")
          end, 100)
        end)
      end,
    })
  end,
})
dofile(%q .. "/lua/config/options.lua")
local spec = dofile(%q .. "/lua/plugins/snacks.lua")
require("snacks").setup({ bigfile = spec.opts.bigfile })
]],
    repo,
    lazy_root .. "/snacks.nvim",
    repo,
    repo,
    result_path,
    repo,
    repo
  )
  vim.fn.writefile(vim.split(init, "\n", { plain = true }), init_path)

  local proc = vim
    .system({ vim.v.progpath, "--headless", "-u", init_path, huge }, {
      clear_env = false,
      env = {
        XDG_CONFIG_HOME = child_root .. "/config",
        XDG_DATA_HOME = child_root .. "/data",
        XDG_STATE_HOME = child_root .. "/state",
        XDG_CACHE_HOME = child_root .. "/cache",
      },
      text = true,
    })
    :wait(15000)
  assert(
    proc.code == 0,
    string.format("startup deletion child must exit cleanly: code=%s stderr=%s", proc.code, proc.stderr or "")
  )
  local result = table.concat(vim.fn.readfile(result_path), "\n")
  assert(
    result:find("noice_enabled=true", 1, true),
    "Noice must stay enabled when deletion wins the startup race: " .. result
  )
  assert(result:find("noice_running=true", 1, true), "Noice must stay running when deletion wins the startup race")
  assert(result:find("disable_calls=0", 1, true), "scheduled disable must observe that the final bigfile was deleted")
  assert(result:find("cmdheight=0", 1, true), "running Noice must restore cmdheight after startup deletion")
end)

vim.fn.delete(tempdir, "rf")

if #failures > 0 then
  error("bigfile lifecycle assertions failed:\n\n" .. table.concat(failures, "\n\n"))
end

print("OK bigfile lifecycle, window restoration, globals, startup, and undo")
