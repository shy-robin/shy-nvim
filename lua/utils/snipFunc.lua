local M = {}

-- 获取 visual mode 下使用 tab 存储到 LS_SELECT_RAW 的内容
-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
M.get_visual_stored = function(_, parent)
  local ls = require("luasnip")
  local sn = ls.snippet_node
  local i = ls.insert_node

  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

return M
