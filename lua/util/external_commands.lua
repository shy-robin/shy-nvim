local M = {}

function M.executable(command)
  return vim.fn.executable(command) == 1
end

function M.first_missing(commands)
  for _, command in ipairs(commands) do
    if not M.executable(command) then
      return command
    end
  end
end

function M.du_command(path, sysname)
  if not M.executable("du") then
    return nil
  end

  sysname = sysname or (vim.uv or vim.loop).os_uname().sysname
  if sysname == "Darwin" then
    return { "du", "-A", "-s", "-k", path }
  end
  return { "du", "--apparent-size", "--summarize", "--block-size=1K", path }
end

function M.image_command(path, sysname)
  sysname = sysname or (vim.uv or vim.loop).os_uname().sysname
  if sysname == "Darwin" and M.executable("sips") then
    return { "sips", "-g", "pixelWidth", "-g", "pixelHeight", path }
  end
  if M.executable("identify") then
    return { "identify", "-format", "%w %h", path }
  end
end

function M.parse_du_result(result)
  if not result or result.code ~= 0 or not result.stdout then
    return nil
  end
  return tonumber(result.stdout:match("^(%d+)"))
end

function M.parse_image_result(command, result)
  if not result or result.code ~= 0 or not result.stdout then
    return nil
  end

  local width, height
  if command == "sips" then
    width = result.stdout:match("pixelWidth:%s*(%d+)")
    height = result.stdout:match("pixelHeight:%s*(%d+)")
  elseif command == "identify" then
    width, height = result.stdout:match("^(%d+)%s+(%d+)")
  end
  if width and height then
    return width .. "x" .. height
  end
end

function M.safe_system(command, options, callback)
  local ok, process_or_error = pcall(vim.system, command, options, callback)
  if not ok then
    callback(nil, process_or_error)
    return false
  end
  return true, process_or_error
end

return M
