-- markdown-preview.nvim 预览管理器
-- 职责：按 buffer 维护预览注册表、自定义 toggle（服务常驻）、fzf-lua 选择窗口。
-- 注意：放在 lua/util/ 而非 lua/plugins/，避免被 lazy.nvim 当作插件 spec 加载。
local M = {}

-- bufnr -> { name = <buffer 全名>, url = <预览 url 或 nil> }
M.registry = {}

-- 从 http://host:port/page/<bufnr> 解析出 bufnr
function M.bufnr_from_url(url)
  if type(url) ~= "string" then
    return nil
  end
  local n = url:match("/page/(%d+)$")
  return n and tonumber(n) or nil
end

-- g:mkdp_browserfunc 经 vimscript MkdpBrowserFunc 转发到这里：
-- 记录该 buffer 的精确预览 url，然后实际打开浏览器。
function M.browserfunc(url)
  local bufnr = M.bufnr_from_url(url)
  if bufnr then
    M.registry[bufnr] = {
      name = vim.api.nvim_buf_get_name(bufnr),
      url = url,
    }
  end
  vim.ui.open(url)
end

function M.is_active(bufnr)
  return M.registry[bufnr] ~= nil
end

-- gom：按当前 buffer 开关预览，node 服务进程常驻供其它文件继续使用。
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.is_active(bufnr) then
    -- 只关当前 buffer 的页面，不停服务
    vim.fn["mkdp#rpc#preview_close"]()
    M.registry[bufnr] = nil
  else
    -- 乐观登记；url 由 browserfunc 异步回填
    M.registry[bufnr] = { name = vim.api.nvim_buf_get_name(bufnr), url = nil }
    vim.fn["mkdp#util#open_preview_page"]()
  end
end

-- 停止单个 buffer 的预览（服务保留）。
-- 用 nvim_buf_call 让 mkdp#rpc#preview_close 内部的 bufnr('%') 命中目标 buffer。
function M.stop_one(bufnr)
  if not bufnr then
    return
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_call(bufnr, function()
      vim.fn["mkdp#rpc#preview_close"]()
    end)
  end
  -- buffer 已失效时仅清理注册表；node 侧页面将自然孤立（设计已接受此权衡）。
  M.registry[bufnr] = nil
end

-- 停止全部并关掉整个服务。
function M.stop_all()
  vim.fn["mkdp#util#stop_preview"]()
  M.registry = {}
end

-- 收集有效的活动预览条目（顺手清理失效 bufnr）。
function M.active_entries()
  local items = {}
  for bufnr, info in pairs(M.registry) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      table.insert(items, { bufnr = bufnr, name = info.name, url = info.url })
    else
      M.registry[bufnr] = nil
    end
  end
  table.sort(items, function(a, b)
    return a.bufnr < b.bufnr
  end)
  return items
end

return M
