local M = {}

-- 获取 API 密钥的统一函数
function M.get_api_key(service)
  local env_var = string.upper(service .. "_API_KEY")
  local key = os.getenv(env_var)
  
  if not key then
    vim.notify(
      "Missing API key for " .. service .. ". Please set " .. env_var .. " environment variable.",
      vim.log.levels.ERROR
    )
    return nil
  end
  
  return key
end

-- 设置 AI 配置的统一函数
function M.setup_ai_configs()
  local configs = {}
  
  -- OpenRouter 配置
  local openrouter_key = M.get_api_key("openrouter")
  if openrouter_key then
    configs.openrouter = {
      endpoint = "https://openrouter.ai/api/v1",
      api_key = openrouter_key,
      model = "deepseek/deepseek-r1",
    }
  end
  
  -- Moonshot 配置
  local moonshot_key = M.get_api_key("moonshot")
  if moonshot_key then
    configs.moonshot = {
      endpoint = "https://api.moonshot.cn/v1",
      api_key = moonshot_key,
      model = "kimi-k2-0711-preview",
      timeout = 30000,
      extra_request_body = {
        temperature = 0.75,
        max_tokens = 32768,
      },
    }
  end
  
  -- Qianwen 配置
  local qianwen_key = M.get_api_key("qianwen")
  if qianwen_key then
    configs.qianwen = {
      endpoint = "https://apis.iflow.cn/v1",
      api_key = qianwen_key,
      model = "qwen3-coder-plus",
    }
  end
  
  -- Gemini 配置
  local gemini_key = M.get_api_key("gemini")
  if gemini_key then
    configs.gemini = {
      model = "gemini-2.5-pro",
    }
  end
  
  return configs
end

-- 检查实际使用的 API 密钥
function M.check_api_keys()
  local available_configs = M.setup_ai_configs()
  local available_services = {}
  
  for service, _ in pairs(available_configs) do
    table.insert(available_services, service)
  end
  
  if #available_services == 0 then
    vim.notify(
      "💡 ShyNvim AI 准备就绪，如需使用 AI 功能请配置 API 密钥。" ..
      "运行 :help api-keys 查看配置指南",
      vim.log.levels.INFO
    )
    return false
  end
  
  vim.notify(
    "🤖 AI 服务已配置: " .. table.concat(available_services, " · "),
    vim.log.levels.INFO
  )
  
  return true
end

-- 获取当前用户信息（用于 AI 聊天个性化）
function M.get_user_info()
  return {
    name = os.getenv("USER") or os.getenv("USERNAME") or "User",
    email = "shy_robin@163.com",
  }
end

-- 设置 API 密钥相关的帮助命令
function M.setup_help_commands()
  vim.api.nvim_create_user_command("ApiKeys", function()
    local guide_path = vim.fn.stdpath("config") .. "/API_KEYS_GUIDE.md"
    if vim.fn.filereadable(guide_path) == 1 then
      vim.cmd("edit " .. guide_path)
    else
      vim.notify("API 密钥配置指南未找到", vim.log.levels.ERROR)
    end
  end, { desc = "打开 API 密钥配置指南" })
end

return M