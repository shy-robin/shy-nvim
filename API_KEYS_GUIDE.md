# ShyNvim API 密钥配置指南

## 📋 可用的 AI 服务

ShyNvim 支持以下 AI 服务，您可以根据需要选择配置：

### 🔥 推荐服务

#### 1. Moonshot (Kimi)
**最适合中文用户，推荐首选**
```bash
export MOONSHOT_API_KEY="your_moonshot_api_key"
```
获取地址: https://platform.moonshot.cn/

#### 2. 通义千问 (Qianwen)
**阿里巴巴提供的中文 AI 服务**
```bash
export QIANWEN_API_KEY="your_qianwen_api_key"
```
获取地址: https://tongyi.aliyun.com/qianwen/

#### 3. OpenRouter
**支持多种 AI 模型的聚合服务**
```bash
export OPENROUTER_API_KEY="your_openrouter_api_key"
```
获取地址: https://openrouter.ai/

### 🌟 备用服务

#### 4. Google Gemini
```bash
export GEMINI_API_KEY="your_gemini_api_key"
```
获取地址: https://makersuite.google.com/app/apikey

## 🔧 配置步骤

### macOS / Linux

#### 方法 1: 临时设置 (仅当前会话)
```bash
export MOONSHOT_API_KEY="sk-your-key-here"
export QIANWEN_API_KEY="your-qianwen-key"

# 然后启动 nvim
nvim
```

#### 方法 2: 永久设置
将以下内容加到你 shell 配置文件 ( ~/.zshrc, ~/.bashrc, ~/.bash_profile ):

```bash
# AI API Keys for ShyNvim
export MOONSHOT_API_KEY="your_moonshot_api_key"
export QIANWEN_API_KEY="your_qianwen_api_key"
export OPENROUTER_API_KEY="your_openrouter_api_key"
export GEMINI_API_KEY="your_gemini_api_key"
```

然后重新加载配置:
```bash
source ~/.zshrc  # 或 ~/.bashrc
```

### Windows

在 PowerShell 中设置:
```powershell
$env:MOONSHOT_API_KEY="your_moonshot_api_key"
$env:QIANWEN_API_KEY="your_qianwen_api_key"
```

或在系统环境变量中永久设置。

## 🎯 使用建议

1. **初学者推荐**: 只配置 Moonshot，简单易用
2. **多模型用户**: 配置 OpenRouter，可切换多种模型
3. **中文优先**: 配置 Moonshot + Qianwen
4. **企业用户**: 根据公司政策选择合适的服务

## ✅ 验证配置

启动 nvim 后，运行以下命令检查配置:
```vim
:ShyNvimDeps
```

成功配置后会显示类似信息:
```
✅ AI 配置完成，可用服务: moonshot, qianwen
```

## 🚨 常见问题

### Q: 为什么会出现警告？
A: 这是正常的提示，提醒您当前配置了哪些 AI 服务。

### Q: 必须配置所有 API 密钥吗？
A: 不需要，只配置你打算使用的服务即可。

### Q: 如何切换 AI 服务？
A: 在 avante 插件中可以通过配置切换，或在对应的 AI 工具中设置。

### Q: API 密钥安全吗？
A: 密钥存储在本地环境变量中，不会被上传到任何远程服务。