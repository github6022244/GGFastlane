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
# 应用基础信息
GG_SCHEME_NAME=YourAppScheme
GG_BUNDLE_IDENTIFIER=com.yourcompany.yourapp

# 蒲公英配置
GG_PGYER_API_KEY=your_pgyer_api_key
GG_PGYER_USER_KEY=your_pgyer_user_key

# Bugly 配置
GG_BUGLY_APP_ID=your_bugly_app_id
GG_BUGLY_APP_KEY=your_bugly_app_key
GG_BUGLY_TOOL_PATH=/path/to/bugly/upload/tool.jar

# App Store Connect API 密钥
GG_APP_STORE_CONNECT_KEY_ID=your_key_id
GG_APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
GG_APP_STORE_CONNECT_KEY_FILENAME=your_key.p8
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
GG_PGYER_API_KEY=your_api_key             # 蒲公英 API Key
GG_PGYER_USER_KEY=your_user_key           # 蒲公英 User Key
GG_PGYER_PASSWORD=1234                    # 安装包密码
GG_PGYER_INSTALL_TYPE=2                   # 安装类型：1=公开，2=密码，3=邀请

# Bugly 配置（可选）
GG_BUGLY_APP_ID=your_bugly_app_id
GG_BUGLY_APP_KEY=your_bugly_app_key
GG_BUGLY_TOOL_PATH=~/Desktop/buglyqq-upload-symbol-v3.3.5/buglyqq-upload-symbol.jar

# Apple ID 配置（可选，推荐使用 API Key）
GG_APPLE_USERNAME=your_apple_id@qq.com
GG_APPLE_PASSWORD=your_password
GG_APPLE_SPECIFIC_PASSWORD=your_specific_password

# App Store Connect API Key（推荐）
GG_APP_STORE_CONNECT_KEY_ID=your_key_id
GG_APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
GG_APP_STORE_CONNECT_KEY_FILENAME=AuthKey_xxx.p8
获取蒲公英密钥
登录 蒲公英官网
进入 应用管理 → 选择你的应用
点击 App 概述 → API
复制 API Key 和 User Key 到 .env 文件
放置 Bugly 工具
将 Bugly 符号表上传工具放到指定目录：
bash
# 创建 Tools 目录
mkdir -p fastlane/Tools

# 将 buglyqq-upload-symbol-v3.3.5 文件夹放到 fastlane/Tools 目录下
放置 App Store Connect API 密钥（可选）
如果使用 API Key 方式上传到 App Store Connect：
bash
# 将 .p8 密钥文件放到 fastlane/auth 目录
mv AuthKey_7Q82A48Z26.p8 fastlane/auth/
🔧 常用命令
环境检查
bash
bundle exec fastlane ios setup
打包上传到蒲公英（Debug 版）
bash
bundle exec fastlane ios dev_pgyer
打包上传到蒲公英（Release 版）
bash
bundle exec fastlane ios public_pgyer
打包上传到 TestFlight
bash
bundle exec fastlane ios testflight_internal
打包 App Store 版本
bash
bundle exec fastlane ios ipa_appstore
上传到 App Store
bash
bundle exec fastlane ios upload_appstore
上传符号表到 Bugly
bash
bundle exec fastlane ios upload_bugly_symbols version:1.0.0
完整发布流程（蒲公英 + Bugly）
bash
bundle exec fastlane ios release
📁 生成的目录结构
plaintext
YourProject/
├── fastlane/
│   ├── auth/                      # App Store Connect API 密钥目录
│   │   └── AuthKey_xxx.p8
│   ├── Tools/                     # 第三方工具目录
│   │   └── buglyqq-upload-symbol-v3.3.5/
│   ├── .env                       # 环境变量配置（切勿提交）
│   ├── .env.example               # 环境变量模板
│   ├── Appfile                    # Fastlane Appfile
│   ├── Fastfile                   # Fastlane 核心配置
│   ├── Pluginfile                 # Fastlane 插件配置
│   └── README.md                  # Fastlane 说明文档
├── Gemfile                        # Ruby 依赖配置
├── .bundle/
│   └── config                     # Bundler 配置
├── vendor/
│   └── bundle/                    # Ruby 依赖安装目录
└── gg_init_fastlane.sh            # 初始化脚本（可删除）
⚠️ 注意事项
1. Git 忽略配置
脚本会自动更新 .gitignore，确保以下文件不被提交：
plaintext
fastlane/.env
.env
vendor/bundle
Gemfile.lock
gg_init_fastlane.sh
ggbuild.sh
2. 环境变量安全
⚠️ 切勿将 .env 文件提交到版本控制
✅ 使用 .env.example 作为模板分享给团队成员
✅ 每个开发者应该有自己的 .env 文件
3. 脚本权限
如果遇到权限问题：
bash
# 重新赋予脚本执行权限
chmod +x gg_init_fastlane.sh

# 如果 bundle 命令无法执行
chmod -R a+w vendor/bundle
4. 依赖安装
如果首次运行失败，尝试手动安装依赖：
bash
bundle install --verbose
bundle exec fastlane install_plugins
🛠️ 故障排查
问题 1：找不到 fastlane 命令
解决方案：
bash
# 使用 bundle exec 运行
bundle exec fastlane --version
问题 2：蒲公英上传失败
错误信息： Get token is failed 或 _api_key not found解决方案：
检查 .env 中的 GG_PGYER_API_KEY 和 GG_PGYER_USER_KEY 是否正确
确认 Bundle ID 与蒲公英上的应用一致
在蒲公英后台重新生成 API Key
问题 3：Build Number 更新失败
错误信息： undefined method 'increment_build_number'解决方案：
确保 Fastfile 中使用 Actions.increment_build_number 调用
问题 4：插件未找到
解决方案：
bash
# 手动安装插件
bundle exec fastlane add_plugin pgyer

# 或者重新安装所有依赖
bundle install
📦 依赖说明
Ruby Gems
fastlane (~> 2.232.0) - 自动化构建工具
dotenv (~> 2.8.1) - 环境变量加载
fastlane-plugin-pgyer (0.3.3) - 蒲公英插件
系统要求
macOS 10.15 或更高版本
Xcode 13.0 或更高版本
Ruby 2.7 或更高版本
Bundler 2.0 或更高版本
🔄 更新日志
v1.0.0
✅ 新增蒲公英双密钥配置（API Key + User Key）
✅ 优化 Build Number 更新逻辑
✅ 修复 increment_build_number 调用问题
✅ 改进环境变量管理
📞 技术支持
Gitee 仓库: https://gitee.com/6022463/GGFastlane
GitHub 仓库: https://github.com/github6022244/GGFastlane
问题反馈: 请在对应仓库提交 Issue
📄 许可证
本工具遵循 MIT 许可证，自由使用和修改。
