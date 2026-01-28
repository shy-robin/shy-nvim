-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 检查 API 密钥配置
-- require("core.env").check_api_keys()

-- 设置健康检查命令
require("core.health").setup_health_commands()

-- 设置快捷键管理命令
require("core.keymaps").setup_keymap_commands()

-- 设置 API 密钥相关命令
require("core.env").setup_help_commands()

-- 延迟运行健康检查，避免影响启动速度
vim.defer_fn(function()
  require("core.health").run_health_check()

  -- 运行快捷键冲突检测
  require("core.keymaps").run_keymap_health_check()
end, 3000)
