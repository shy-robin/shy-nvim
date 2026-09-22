local M = {}

local function rgb(color)
  return { math.floor(color / 65536), math.floor(color / 256) % 256, color % 256 }
end

local function blend(a, b, amount)
  local left, right = rgb(a), rgb(b)
  local color = 0
  for i = 1, 3 do
    color = color * 256 + math.floor(left[i] * (1 - amount) + right[i] * amount + 0.5)
  end
  return color
end

local function luminance(color)
  local channels = rgb(color)
  for i, channel in ipairs(channels) do
    local value = channel / 255
    channels[i] = value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
  end
  return channels[1] * 0.2126 + channels[2] * 0.7152 + channels[3] * 0.0722
end

local function contrast(a, b)
  local x, y = luminance(a), luminance(b)
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
end

local function highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local change_bg
  for _, name in ipairs({ "Add", "Delete", "Change", "Text" }) do
    local source = "Diff" .. name
    local hl = vim.api.nvim_get_hl(0, { name = source, link = false })
    -- 透明主题没有可靠的底色：沿用原始高亮，不猜测终端背景。
    if not normal.bg or not normal.fg then
      vim.api.nvim_set_hl(0, "Diffview" .. source, { link = source })
    else
      local reference = name == "Text" and (change_bg or normal.bg) or normal.bg
      local background = hl.bg or blend(normal.bg, hl.fg or normal.fg, 0.15)
      local minimum = name == "Text" and 1.8 or 1.4
      -- 保留主题色相，只在底色区分不足时逐步提高亮度差。
      local original = background
      for step = 1, 12 do
        if contrast(background, reference) >= minimum then
          break
        end
        background = blend(original, normal.fg, step * 0.05)
      end
      hl.bg = background
      hl.reverse = nil
      hl.blend = nil
      if name == "Text" then
        hl.bold = true
      end
      local foreground = hl.fg or normal.fg
      if contrast(foreground, background) < 4.5 then
        -- 优先使用主题前景；极端配色才退回对比更高的黑/白文字。
        foreground = normal.fg
        if contrast(foreground, background) < 4.5 then
          foreground = contrast(0, background) > contrast(0xffffff, background) and 0 or 0xffffff
        end
        hl.fg = foreground
      end
      vim.api.nvim_set_hl(0, "Diffview" .. source, hl)
      if name == "Change" then
        change_bg = background
      end
    end
  end
end

function M.setup()
  highlights()
  local group = vim.api.nvim_create_augroup("diffview_review", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = highlights })

  -- Snacks 当前没有按窗口禁用文档图片的配置。过滤查找结果，让它正常清理
  -- 已有 placement；离开 diff 后恢复原来的图片查找流程。
  local ok, doc = pcall(require, "snacks.image.doc")
  if ok and not M.image_filter_installed then
    M.image_filter_installed = true
    local find = doc.find
    doc.find = function(buf, callback, opts)
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.wo[win].diff then
          return callback({})
        end
      end
      return find(buf, callback, opts)
    end
  end
end

function M.enter(_, winid)
  local view = require("diffview.lib").get_current_view()
  for _, win in ipairs(view and view.cur_layout and view.cur_layout.windows or {}) do
    if win.id == winid then
      -- 通过 Diffview 保存/恢复选项，避免工作树 buffer 回到普通编辑时遗留设置。
      win:use_winopts({
        wrap = false,
        number = true,
        relativenumber = false,
        conceallevel = 0,
        spell = false,
      })
      break
    end
  end
end

return M
