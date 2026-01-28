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

-- 检查所有必需的 API 密钥
function M.check_api_keys()
  local required_keys = {
    "openrouter",
    "moonshot", 
    "qianwen",
    "gemini"
  }
  
  local missing_keys = {}
  
  for _, service in ipairs(required_keys) do
    local env_var = string.upper(service .. "_API_KEY")
    if not os.getenv(env_var) then
      table.insert(missing_keys, env_var)
    end
  end
  
  if #missing_keys > 0 then
    vim.notify(
      "Missing API keys: " .. table.concat(missing_keys, ", "),
      vim.log.levels.WARN
    )
  else
    vim.notify("All API keys are configured", vim.log.levels.INFO)
  end
  
  return #missing_keys == 0
end

-- 获取当前用户信息（用于 AI 聊天个性化）
function M.get_user_info()
  return {
    name = os.getenv("USER") or os.getenv("USERNAME") or "User",
    email = "shy_robin@163.com",
  }
end

return M