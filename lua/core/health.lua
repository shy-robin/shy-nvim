local M = {}

-- 检查系统依赖
function M.check_dependencies()
  local required = {
    { cmd = "node", purpose = "coc.nvim", critical = true },
    { cmd = "npm", purpose = "coc extensions", critical = true },
    { cmd = "python3", purpose = "pynvim/ultisnips", critical = true },
    { cmd = "rg", purpose = "search functionality", critical = false },
    { cmd = "fd", purpose = "file finder", critical = false },
    { cmd = "git", purpose = "version control", critical = true },
    { cmd = "lazygit", purpose = "git interface", critical = false },
    { cmd = "stylua", purpose = "lua formatting", critical = false },
  }
  
  local missing_critical = {}
  local missing_optional = {}
  
  for _, dep in ipairs(required) do
    if vim.fn.executable(dep.cmd) == 0 then
      local msg = string.format("Missing: %s for %s", dep.cmd, dep.purpose)
      if dep.critical then
        table.insert(missing_critical, msg)
      else
        table.insert(missing_optional, msg)
      end
    end
  end
  
  -- 报告结果
  if #missing_critical > 0 then
    vim.notify("Critical dependencies missing:\n" .. table.concat(missing_critical, "\n"), vim.log.levels.ERROR)
  end
  
  if #missing_optional > 0 then
    vim.notify("Optional dependencies missing:\n" .. table.concat(missing_optional, "\n"), vim.log.levels.WARN)
  end
  
  if #missing_critical == 0 and #missing_optional == 0 then
    vim.notify("All dependencies satisfied", vim.log.levels.INFO)
  end
  
  return #missing_critical == 0
end

-- 检查配置文件健康状态
function M.check_config_health()
  local config_files = {
    { path = vim.fn.stdpath("config") .. "/lua/core/env.lua", name = "API密钥管理" },
    { path = vim.fn.stdpath("config") .. "/coc-settings.json", name = "Coc设置" },
    { path = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", name = "Lazy配置" },
  }
  
  local missing_configs = {}
  
  for _, config in ipairs(config_files) do
    if vim.fn.filereadable(config.path) == 0 then
      table.insert(missing_configs, config.name)
    end
  end
  
  if #missing_configs > 0 then
    vim.notify("Missing config files: " .. table.concat(missing_configs, ", "), vim.log.levels.WARN)
  end
  
  return #missing_configs == 0
end

-- 检查插件加载状态
function M.check_plugin_status()
  local lazy = require("lazy")
  local plugins = lazy.plugins()
  
  local failed_plugins = {}
  local not_loaded_plugins = {}
  
  for _, plugin in ipairs(plugins) do
    if plugin._.failed then
      table.insert(failed_plugins, plugin.name)
    elseif not plugin._.loaded and not plugin._.cond then
      table.insert(not_loaded_plugins, plugin.name)
    end
  end
  
  if #failed_plugins > 0 then
    vim.notify("Failed plugins: " .. table.concat(failed_plugins, ", "), vim.log.levels.ERROR)
  end
  
  if #not_loaded_plugins > 0 then
    vim.notify("Not loaded plugins: " .. table.concat(not_loaded_plugins, ", "), vim.log.levels.WARN)
  end
  
  return #failed_plugins == 0
end

-- 检查内存使用情况
function M.check_memory_usage()
  local memory = vim.fn.system("ps -o pid,rss -p " .. vim.fn.getpid()):gsub("\n+$", "")
  local rss = tonumber(memory:match("(%d+)$"))
  
  if rss then
    local mb = math.floor(rss / 1024)
    
    if mb > 200 then
      vim.notify("High memory usage: " .. mb .. "MB", vim.log.levels.WARN)
    elseif mb > 150 then
      vim.notify("Moderate memory usage: " .. mb .. "MB", vim.log.levels.INFO)
    else
      vim.notify("Memory usage OK: " .. mb .. "MB", vim.log.levels.INFO)
    end
    
    return mb
  end
  
  return nil
end

-- 运行完整的健康检查
function M.run_health_check()
  vim.notify("Starting ShyNvim health check...", vim.log.levels.INFO)
  
  local results = {
    dependencies = M.check_dependencies(),
    config = M.check_config_health(),
    plugins = M.check_plugin_status(),
    memory = M.check_memory_usage() or 0,
  }
  
  local all_ok = results.dependencies and results.config and results.plugins
  
  if all_ok then
    vim.notify("✅ All health checks passed!", vim.log.levels.INFO)
  else
    vim.notify("❌ Some health checks failed. Check messages above.", vim.log.levels.ERROR)
  end
  
  return results, all_ok
end

-- 创建健康检查命令
function M.setup_health_commands()
  vim.api.nvim_create_user_command("ShyNvimHealth", function()
    M.run_health_check()
  end, { desc = "Run ShyNvim health check" })
  
  vim.api.nvim_create_user_command("ShyNvimDeps", function()
    M.check_dependencies()
  end, { desc = "Check ShyNvim dependencies" })
  
  vim.api.nvim_create_user_command("ShyNvimConfig", function()
    M.check_config_health()
  end, { desc = "Check ShyNvim config health" })
end

return M