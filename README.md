# GGFastlane 项目（仅适用于新项目）

<div align="center">
  <img src="https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Fastlane%20automation%20tool%20logo%20with%20rocket%20and%20code%20symbols%2C%20modern%20minimalist%20design%2C%20blue%20and%20green%20colors&image_size=square_hd" alt="GGFastlane Logo" width="200" height="200">

  <p align="center">
    <a href="https://github.com/github6022244/GGFastlane">
      <img src="https://img.shields.io/github/stars/github6022244/GGFastlane.svg?style=social" alt="GitHub stars">
    </a>
    <a href="https://gitee.com/6022463/GGFastlane">
      <img src="https://gitee.com/6022463/GGFastlane/badge/star.svg" alt="Gitee stars">
    </a>
  </p>
</div>

## 📋 目录

- [项目简介](#项目简介)
- [功能特点](#功能特点)
- [快速开始](#快速开始)
- [常用命令](#常用命令)
- [GGFastlane 快捷命令](#ggfastlane-快捷命令)
- [目录结构](#目录结构)
- [注意事项](#注意事项)
- [故障排除](#故障排除)
- [版本说明](#版本说明)
- [贡献](#贡献)
- [许可证](#许可证)

## 📖 项目简介

GGFastlane 是一个基于 Fastlane 的自动化构建、打包和分发工具，专为 iOS 项目设计。它提供了一套标准化的配置和流程，简化了应用的构建、测试和发布过程，让开发团队能够更专注于代码开发，而不是繁琐的打包发布流程。

## ✨ 功能特点

| 功能               | 描述                                                 |
| ---------------- | -------------------------------------------------- |
| **一键初始化**        | 通过 `gg_init_fastlane.sh` 脚本快速搭建 Fastlane 环境，减少配置时间 |
| **多环境构建**        | 支持 Debug、Release、App Store 和 TestFlight 环境的构建      |
| **分发渠道**         | 集成蒲公英分发平台，支持内测版本快速分发和测试反馈                          |
| **崩溃分析**         | 集成 Bugly 符号表上传，便于应用崩溃分析和问题定位                       |
| **App Store 发布** | 支持一键上传到 TestFlight 和 App Store，简化发布流程              |
| **环境变量管理**       | 通过 `.env` 文件管理敏感配置，避免硬编码和信息泄露                      |
| **标准化流程**        | 提供统一的构建和发布流程，确保团队协作一致性                             |

## 🚀 快速开始

### 1. 初始化环境

将gg\_init\_fastlane.sh放到项目根目录

在项目根目录执行以下命令：

```bash
bash gg_init_fastlane.sh
```

该脚本会自动完成以下操作：

- ✅ 创建 Gemfile 并配置 Ruby 依赖
- ✅ 执行 fastlane init（建议选择选项 4 - 手动设置）
- ✅ 创建环境变量配置文件（.env.example 和 .env）
- ✅ 更新 .gitignore 文件，添加必要的忽略规则
- ✅ 创建必要的目录结构（auth、Tools 等）
- ✅ 配置 Fastlane 插件（如蒲公英）
- ✅ 下载标准 Fastfile 配置

### 2. 配置环境变量

编辑 `fastlane/.env` 文件，填入实际配置信息：

```bash
# ==================== Fastlane 环境变量配置 ====================
#
# 使用说明：
# 1. 复制此文件为 .env
# 2. 根据实际情况修改以下配置
# 3. 切勿将 .env 文件提交到版本控制（包含敏感信息）
#
# ===============================================================


# ---------------------- 应用基础信息 ----------------------

# Xcode Scheme 名称（与 Xcode 中一致）
GG_SCHEME_NAME=YourAppScheme

# App Bundle ID（如 com.company.app）
GG_BUNDLE_IDENTIFIER=com.yourcompany.yourapp


# ---------------------- 输出路径配置 ----------------------

# Debug 包输出目录
GG_OUTPUT_DIR_DEBUG=~/Desktop/debug

# Release 包输出目录
GG_OUTPUT_DIR_RELEASE=~/Desktop/release

# App Store 包输出目录
GG_OUTPUT_DIR_APPSTORE=~/Desktop/app_store

# TestFlight 包输出目录
GG_OUTPUT_DIR_TESTFLIGHT=~/Desktop/test-flight


# ---------------------- 蒲公英配置（国内分发平台）----------------------

# 蒲公英 API Key（在蒲公英后台获取）
GG_PGYER_API_KEY=your_pgyer_api_key

# 蒲公英 User Key（在蒲公英后台获取，与 API Key 配合使用）
GG_PGYER_USER_KEY=your_pgyer_user_key

# 蒲公英安装包密码（可选）
GG_PGYER_PASSWORD=1234

# 安装类型：1=公开，2=密码邀请，3=仅限邀请
GG_PGYER_INSTALL_TYPE=2


# ---------------------- Bugly 配置（腾讯崩溃统计平台）----------------------

# Bugly App ID（在 Bugly 后台创建应用获取）
GG_BUGLY_APP_ID=your_bugly_app_id

# Bugly App Key（在 Bugly 后台获取）
GG_BUGLY_APP_KEY=your_bugly_app_key

# Bugly 符号表上传工具路径
GG_BUGLY_TOOL_PATH=/path/to/bugly/upload/tool.jar


# ---------------------- 构建配置 ----------------------

# Xcodebuild 超时时间（分钟）
GG_BUILD_TIMEOUT=480

# 构建失败重试次数
GG_BUILD_RETRIES=10


# ---------------------- Apple ID 认证（备用方案，推荐使用 API Key）----------------------

# Apple Developer 账号（用于登录开发者后台）
GG_APPLE_USERNAME=your_apple_id@example.com

# Apple ID 密码（建议使用应用专用密码）
GG_APPLE_PASSWORD=your_apple_password

# 应用专用密码（开启双重认证时需要）
GG_APPLE_SPECIFIC_PASSWORD=your_specific_password


# ---------------------- App Store Connect API 密钥（推荐方式）----------------------

# API Key ID（在 App Store Connect 创建）
GG_APP_STORE_CONNECT_KEY_ID=your_key_id

# Issuer ID（在 App Store Connect 查看）
GG_APP_STORE_CONNECT_ISSUER_ID=your_issuer_id

# 私钥文件名（放在 fastlane/auth 目录）
GG_APP_STORE_CONNECT_KEY_FILENAME=your_key.p8


# ---------------------- 通知配置（可选，选择一个平台配置即可）----------------------

# 企业微信机器人 Webhook Key
GG_WECHAT_WORK_WEBHOOK_KEY=

# 钉钉机器人 Webhook URL
GG_DINGTALK_WEBHOOK=

# 钉钉签名密钥（如果启用了安全设置）
GG_DINGTALK_SECRET=

# 飞书机器人 Webhook URL
GG_FEISHU_WEBHOOK=

# Slack Incoming Webhook URL
GG_SLACK_WEBHOOK=

# 通知平台选择：wechat_work / dingtalk / feishu / slack
GG_NOTIFICATION_PLATFORM=wechat_work


# ---------------------- CI/CD 配置（可选，持续集成环境使用）----------------------

# 是否为 CI 环境（true/false）
GG_CI_ENV=false

# CI 构建类型：debug / release / testflight
GG_CI_BUILD_TYPE=release

# CI 自动构建更新说明（为空则从 Git 提交获取）
GG_CI_CHANGELOG=

# CI 指定的版本号（为空则自动生成）
GG_CI_VERSION=
```

### 3. 准备必要文件

- 📁 将 Bugly 符号表上传工具放到 `fastlane/Tools` 目录
- 📁 将 App Store Connect API 密钥 (.p8 文件) 放到 `fastlane/auth` 目录

### 4. 检查环境

```bash
bundle exec fastlane setup
```

## 📱 常用命令

### 开发测试

| 命令                                  | 功能               |
| ----------------------------------- | ---------------- |
| `bundle exec fastlane dev_pgyer`    | 上传 Debug 包到蒲公英   |
| `bundle exec fastlane public_pgyer` | 上传 Release 包到蒲公英 |

### 应用发布

| 命令                                         | 功能                    |
| ------------------------------------------ | --------------------- |
| `bundle exec fastlane testflight_internal` | 上传到 TestFlight 进行内部测试 |
| `bundle exec fastlane ipa_appstore`        | 打包 App Store 版本       |
| `bundle exec fastlane upload_appstore`     | 上传到 App Store         |

### 其他功能

| 命令                                          | 功能                                |
| ------------------------------------------- | --------------------------------- |
| `bundle exec fastlane upload_bugly_symbols` | 上传符号表到 Bugly                      |
| `bundle exec fastlane release`              | 完整发布流程（蒲公英 Release + Bugly 符号表上传） |

## ⚡ GGFastlane 快捷命令

GGFastlane 还提供了一套简化的快捷命令，让操作更加便捷：

| 命令                                      | 功能             |
| --------------------------------------- | -------------- |
| `bundle exec fastlane gg_setup`         | 初始化环境          |
| `bundle exec fastlane gg_dev_pgyer`     | 上传测试包到蒲公英      |
| `bundle exec fastlane gg_public_pgyer`  | 上传正式包到蒲公英      |
| `bundle exec fastlane gg_testflight`    | 上传到 TestFlight |
| `bundle exec fastlane gg_appstore`      | 上传到 App Store  |
| `bundle exec fastlane gg_bugly_symbols` | 上传符号表到 Bugly   |
| `bundle exec fastlane gg_release`       | 完整发布流程         |
| `bundle exec fastlane gg_config`        | 显示配置信息         |

## 📁 目录结构

```
├── fastlane/                # Fastlane 配置目录
│   ├── auth/                # 存放 App Store Connect API 密钥
│   ├── Tools/               # 存放 Bugly 符号表上传工具
│   ├── .env                 # 环境变量配置
│   ├── .env.example         # 环境变量配置示例
│   ├── Fastfile             # Fastlane 配置文件
│   └── Pluginfile           # Fastlane 插件配置
├── .gitignore               # Git 忽略文件
├── Gemfile                  # Ruby 依赖配置
└── gg_init_fastlane.sh      # 初始化脚本
```

## ⚠️ 注意事项

1. **敏感信息保护**：
   - `.env` 文件包含敏感信息，切勿提交到版本控制
   - App Store Connect API 密钥文件也应避免提交
2. **环境依赖**：
   - 确保安装了 Xcode 命令行工具
   - 确保 Ruby 环境正常
   - 确保 Java 环境（用于 Bugly 符号表上传）
3. **配置验证**：
   - 在执行构建前，务必运行 `bundle exec fastlane setup` 检查环境
   - 确保所有必要的配置都已正确填写
4. **构建问题排查**：
   - 如果构建失败，检查 Xcode 配置和证书是否正确
   - 检查网络连接是否正常（特别是上传到蒲公英和 App Store 时）

## 🔧 故障排除

| 问题             | 解决方案                                                        |
| -------------- | ----------------------------------------------------------- |
| **依赖安装失败**     | 尝试运行 `bundle install --verbose` 查看详细错误信息                    |
| **构建超时**       | 可以在 `.env` 文件中调整 `GG_BUILD_TIMEOUT` 和 `GG_BUILD_RETRIES` 参数 |
| **证书问题**       | 确保 Xcode 中配置了正确的开发者证书和描述文件                                  |
| **蒲公英上传失败**    | 检查 API Key 是否正确，网络连接是否正常                                    |
| **Bugly 上传失败** | 检查 Bugly 工具路径和配置是否正确                                        |

## 📦 版本说明

- **Fastlane 版本**：\~> 2.232.0
- **Ruby 版本**：建议 2.7 或更高
- **支持 iOS 版本**：10.0 及以上

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！我们期待您的参与和反馈。

## 📄 许可证

MIT License

***

<div align="center">
  <p>Made with ❤️ by GGFastlane Team</p>
</div>
