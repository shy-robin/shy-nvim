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

return M
