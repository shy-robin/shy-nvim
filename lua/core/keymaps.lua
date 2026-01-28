local M = {}

-- 存储所有注册的快捷键
local registered_keys = {}

-- 记录快捷键
function M.register_key(lhs, modes, plugin_name)
  if type(modes) == "string" then
    modes = { modes }
  end
  
  for _, mode in ipairs(modes) do
    local key = mode .. ":" .. lhs
    
    if registered_keys[key] then
      local existing = registered_keys[key]
      vim.notify(
        string.format(
          "Key conflict detected!\n  Key: %s (%s)\n  Existing: %s\n  New: %s",
          lhs, mode, existing.plugin, plugin_name
        ),
        vim.log.levels.WARN
      )
    else
      registered_keys[key] = {
        plugin = plugin_name,
        mode = mode,
        key = lhs
      }
    end
  end
end

-- 扫描所有插件的快捷键定义
function M.scan_plugin_keys()
  local lazy = require("lazy")
  local plugins = lazy.plugins()
  
  registered_keys = {}
  
  for _, plugin in ipairs(plugins) do
    if plugin.config and type(plugin.config) == "function" then
      -- 尝试从插件配置中提取快捷键
      if plugin.keys then
        for _, key_spec in ipairs(plugin.keys) do
          if type(key_spec) == "table" then
            lhs = key_spec[1] or key_spec.lhs
            modes = key_spec.mode or "n"
            plugin_name = plugin.name
            
            if lhs then
              M.register_key(lhs, modes, plugin_name)
            end
          end
        end
      end
    end
  end
end

-- 扫描全局快捷键映射
function M.scan_global_mappings()
  local global_maps = vim.api.nvim_get_keymap("n")
  local global_vmaps = vim.api.nvim_get_keymap("v")
  local global_imaps = vim.api.nvim_get_keymap("i")
  
  -- 处理普通模式映射
  for _, map in ipairs(global_maps) do
    if map.lhs ~= "" and map.rhs ~= "" and not map.buffer then
      M.register_key(map.lhs, "n", "global")
    end
  end
  
  -- 处理可视模式映射
  for _, map in ipairs(global_vmaps) do
    if map.lhs ~= "" and map.rhs ~= "" and not map.buffer then
      M.register_key(map.lhs, "v", "global")
    end
  end
  
  -- 处理插入模式映射
  for _, map in ipairs(global_imaps) do
    if map.lhs ~= "" and map.rhs ~= "" and not map.buffer then
      M.register_key(map.lhs, "i", "global")
    end
  end
end

-- 检查特定快捷键是否被占用
function M.check_key_availability(key, mode)
  mode = mode or "n"
  local key_spec = mode .. ":" .. key
  
  if registered_keys[key_spec] then
    return false, registered_keys[key_spec]
  end
  
  return true, nil
end

-- 生成快捷键冲突报告
function M.generate_conflict_report()
  local conflicts = {}
  
  for key, spec in pairs(registered_keys) do
    if conflicts[spec.key] then
      table.insert(conflicts[spec.key], spec)
    else
      conflicts[spec.key] = { spec }
    end
  end
  
  local conflict_keys = {}
  for key, specs in pairs(conflicts) do
    if #specs > 1 then
      table.insert(conflict_keys, {
        key = specs[1].key,
        conflicts = specs
      })
    end
  end
  
  return conflict_keys
end

-- 显示快捷键统计信息
function M.show_keymap_stats()
  local mode_counts = {
    n = 0,
    v = 0,
    i = 0,
    c = 0,
    t = 0
  }
  
  local plugin_counts = {}
  
  for _, spec in pairs(registered_keys) do
    mode_counts[spec.mode] = (mode_counts[spec.mode] or 0) + 1
    
    plugin_counts[spec.plugin] = (plugin_counts[spec.plugin] or 0) + 1
  end
  
  print("=== Keymap Statistics ===")
  print("Total keys: " .. vim.tbl_count(registered_keys))
  print("By mode:")
  for mode, count in pairs(mode_counts) do
    if count > 0 then
      print(string.format("  %s: %d", mode, count))
    end
  end
  
  print("Top plugins by key count:")
  local sorted_plugins = {}
  for plugin, count in pairs(plugin_counts) do
    table.insert(sorted_plugins, { plugin = plugin, count = count })
  end
  
  table.sort(sorted_plugins, function(a, b) return a.count > b.count end)
  
  for i = 1, math.min(10, #sorted_plugins) do
    local item = sorted_plugins[i]
    print(string.format("  %s: %d", item.plugin, item.count))
  end
end

-- 完整的快捷键健康检查
function M.run_keymap_health_check()
  vim.notify("Scanning keymaps for conflicts...", vim.log.levels.INFO)
  
  M.scan_global_mappings()
  M.scan_plugin_keys()
  
  local conflicts = M.generate_conflict_report()
  
  if #conflicts > 0 then
    vim.notify("Found " .. #conflicts .. " key conflicts:", vim.log.levels.WARN)
    
    for _, conflict in ipairs(conflicts) do
      local conflict_str = string.format("Key: %s\n", conflict.key)
      for _, spec in ipairs(conflict.conflicts) do
        conflict_str = conflict_str .. string.format("  %s (%s): %s\n", spec.mode, spec.plugin, spec.plugin)
      end
      vim.notify(conflict_str, vim.log.levels.WARN)
    end
  else
    vim.notify("✅ No key conflicts detected!", vim.log.levels.INFO)
  end
  
  M.show_keymap_stats()
  
  return #conflicts
end

-- 创建快捷键管理命令
function M.setup_keymap_commands()
  vim.api.nvim_create_user_command("ShyNvimKeyCheck", function()
    M.run_keymap_health_check()
  end, { desc = "Run ShyNvim keymap conflict check" })
  
  vim.api.nvim_create_user_command("ShyNvimKeyStats", function()
    M.show_keymap_stats()
  end, { desc = "Show ShyNvim keymap statistics" })
  
  vim.api.nvim_create_user_command("ShyNvimKeyCheckKey", function(opts)
    local key = opts.args
    local mode = opts.bang and "v" or "n"
    
    local available, conflict = M.check_key_availability(key, mode)
    
    if available then
      vim.notify(string.format("✅ Key '%s' is available in mode '%s'", key, mode), vim.log.levels.INFO)
    else
      vim.notify(
        string.format("❌ Key '%s' in mode '%s' is used by: %s", key, mode, conflict.plugin),
        vim.log.levels.WARN
      )
    end
  end, {
    desc = "Check if a specific key is available",
    nargs = 1,
    bang = true,
  })
end

-- 检查常用快捷键冲突
function M.check_common_key_conflicts()
  local common_keys = {
    n = { "<leader>", "<C-", "<A-", "g", "z", "[", "]" },
    v = { "<leader>", "<C-", "<A-" },
    i = { "<C-", "<A-" }
  }
  
  local common_conflicts = {}
  
  for mode, prefixes in pairs(common_keys) do
    for _, prefix in ipairs(prefixes) do
      for key, spec in pairs(registered_keys) do
        if spec.mode == mode and string.sub(spec.key, 1, #prefix) == prefix then
          local full_key = mode .. ":" .. spec.key
          if not common_conflicts[full_key] then
            common_conflicts[full_key] = spec
          end
        end
      end
    end
  end
  
  local conflict_count = vim.tbl_count(common_conflicts)
  
  if conflict_count > 0 then
    vim.notify(string.format("Found %d common key mappings:", conflict_count), vim.log.levels.INFO)
    
    for full_key, spec in pairs(common_conflicts) do
      if spec.key:match("^<leader>") then
        vim.notify(string.format("  Leader: %s -> %s", spec.key, spec.plugin), vim.log.levels.INFO)
      end
    end
  end
end

return M