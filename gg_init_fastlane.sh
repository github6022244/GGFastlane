#!/bin/bash

# ==============================================================================
# 脚本名称：gg_init_fastlane.sh
# 脚本功能：一键初始化 Fastlane 配置为 GG 标准样式
# 使用说明：在项目根目录下运行 bash gg_init_fastlane.sh
# ==============================================================================

set -e

PROJECT_ROOT="$(pwd)"
FASTLANE_DIR="${PROJECT_ROOT}/fastlane"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 开始初始化 Fastlane 配置..."

# ==================== 第一步：Bundler 配置 ====================
echo ""
echo "📦 第一步：配置 Bundler 环境..."

# 创建 Gemfile（定义项目 Ruby 依赖）
cat > "${PROJECT_ROOT}/Gemfile" << 'EOF'
source "https://rubygems.org"

gem "fastlane", "~> 2.232.0"    # iOS/Android 自动化构建工具
gem "dotenv", "~> 2.8.1"        # 环境变量加载工具

# 加载 Fastlane 插件配置
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
EOF

# 配置 Bundler 路径（生成 .bundle/config，指定依赖安装到 vendor/bundle）
bundle config set --local path 'vendor/bundle'
echo "✅ 已生成 .bundle/config"

# 安装依赖（--verbose 显示详细安装日志）
echo "📥 正在安装 Ruby 依赖..."
bundle install --verbose

# ==================== 第二步：执行 fastlane init ====================
echo ""
echo "🚀 第二步：执行 fastlane init（请根据提示选择）..."

if [ -d "${FASTLANE_DIR}" ]; then
    echo "⚠️  检测到 fastlane 目录已存在"
    read -p "是否继续？这将覆盖现有配置 (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "❌ 初始化取消"
        exit 0
    fi
fi

# 执行 fastlane init（不使用 --silent，让用户看到交互过程）
echo "💡 提示：建议选择选项 4 (Manual setup) - 手动设置"
bundle exec fastlane init

# ==================== 第三步：创建 Fastlane 配置文件 ====================
echo ""
echo "📄 第三步：创建 Fastlane 配置文件..."

# 1. 创建 .env.example 和 .env（带分段注释）- 放在项目根目录和 fastlane 目录各一份
echo "📝 创建环境变量配置..."
cat > "${FASTLANE_DIR}/.env.example" << 'EOF'
# ==================== Fastlane 环境变量配置 ====================
#
# 使用说明：
# 1. 复制此文件为 .env
# 2. 根据实际情况修改以下配置
# 3. 切勿将 .env 文件提交到版本控制（包含敏感信息）
#
# ==============================================================================


# ---------------------- 应用基础信息 ----------------------

# Xcode Scheme 名称（与 Xcode 中一致）
GG_SCHEME_NAME=xxx

# App Bundle ID（如 com.company.app）
GG_BUNDLE_IDENTIFIER=com.test.project


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
GG_PGYER_API_KEY=xxx

# 蒲公英 User Key（在蒲公英后台获取，与 API Key 配合使用）
GG_PGYER_USER_KEY=xxx

# 蒲公英安装包密码（可选）
GG_PGYER_PASSWORD=1234

# 安装类型：1=公开，2=密码邀请，3=仅限邀请
GG_PGYER_INSTALL_TYPE=2


# ---------------------- Bugly 配置（腾讯崩溃统计平台）----------------------

# Bugly App ID（在 Bugly 后台创建应用获取）
GG_BUGLY_APP_ID=123

# Bugly App Key（在 Bugly 后台获取）
GG_BUGLY_APP_KEY=a-b-c-d

# Bugly 符号表上传工具路径
GG_BUGLY_TOOL_PATH=~/Desktop/buglyqq-upload-symbol-v3.3.5/buglyqq-upload-symbol.jar


# ---------------------- 构建配置 ----------------------

# Xcodebuild 超时时间（分钟）
GG_BUILD_TIMEOUT=480

# 构建失败重试次数
GG_BUILD_RETRIES=10


# ---------------------- Apple ID 认证（备用方案，推荐使用 API Key）----------------------

# Apple Developer 账号（用于登录开发者后台）
GG_APPLE_USERNAME=abc@qq.com

# Apple ID 密码（建议使用应用专用密码）
GG_APPLE_PASSWORD=abc

# 应用专用密码（开启双重认证时需要）
GG_APPLE_SPECIFIC_PASSWORD=abc


# ---------------------- App Store Connect API 密钥（推荐方式）----------------------

# API Key ID（在 App Store Connect 创建）
GG_APP_STORE_CONNECT_KEY_ID=abc

# Issuer ID（在 App Store Connect 查看）
GG_APP_STORE_CONNECT_ISSUER_ID=a-b-c-d

# 私钥文件名（放在 fastlane/auth 目录）
GG_APP_STORE_CONNECT_KEY_FILENAME=abc.p8


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
EOF

# 在 fastlane 目录和项目根目录都创建 .env 文件
cp "${FASTLANE_DIR}/.env.example" "${FASTLANE_DIR}/.env"
echo "✅ 已创建 .env 文件（fastlane/.env 和 .env）"

# 2. 配置 .gitignore（追加式更新）
echo "🔒 更新 .gitignore..."
cat >> "${PROJECT_ROOT}/.gitignore" << 'EOF'

# ==================== Fastlane & Ruby 配置 ====================
# Fastlane 敏感文件（切勿提交）
fastlane/.env
.env

# Ruby/Bundler 依赖目录
vendor/bundle
Gemfile.lock

# 脚本文件
gg_init_fastlane.sh
ggbuild.sh
EOF

# 3. 创建必要目录
echo "📁 创建目录结构..."
mkdir -p "${FASTLANE_DIR}/auth"      # 存放 App Store Connect API 密钥 (.p8 文件)
mkdir -p "${FASTLANE_DIR}/Tools"     # 存放 Bugly 符号表上传工具

# 4. 创建或更新 Pluginfile（蒲公英插件）
echo "🔌 配置 Pluginfile..."

PLUGINFILE_PATH="${FASTLANE_DIR}/Pluginfile"
NEED_INSTALL_PLUGINS=false

if [ -f "${PLUGINFILE_PATH}" ]; then
    echo "⚠️  检测到 Pluginfile 已存在"
    
    # 检查是否已包含 pgyer 插件
    if grep -q "fastlane-plugin-pgyer" "${PLUGINFILE_PATH}"; then
        echo "✅ Pluginfile 已包含 pgyer 插件，跳过"
    else
        echo "📝 追加 pgyer 插件配置..."
        cat >> "${PLUGINFILE_PATH}" << 'EOF'

# 蒲公英分发平台插件
gem 'fastlane-plugin-pgyer'
EOF
        echo "✅ 已追加 pgyer 插件到 Pluginfile"
        NEED_INSTALL_PLUGINS=true
    fi
else
    echo "📄 创建 Pluginfile..."
    cat > "${PLUGINFILE_PATH}" << 'EOF'
# Fastlane 插件配置
# 文档：https://docs.fastlane.tools/plugins/available-plugins/

gem 'fastlane-plugin-pgyer'    # 蒲公英分发平台插件
EOF
    echo "✅ 已创建 Pluginfile"
    NEED_INSTALL_PLUGINS=true
fi

# 5. 从网络下载 Fastfile（使用 CDN 加速）
echo "📋 下载 Fastfile..."

# 多个下载源（优先 Gitee，国内更快）
SOURCES=(
    "Gitee Raw:https://gitee.com/6022463/GGFastlane/raw/main/Fastfile"
    "GitHub Raw:https://raw.githubusercontent.com/github6022244/GGFastlane/main/Fastfile"
    "jsDelivr:https://cdn.jsdelivr.net/gh/github6022244/GGFastlane@main/Fastfile"
)

download_fastfile() {
    local url=$1
    local source_name=$2
    
    echo "🔄 尝试从 ${source_name} 下载..."
    
    # 使用 curl 下载（-L 跟随重定向，-f 失败时不输出文件，--connect-timeout 超时时间）
    if curl -L -f -s --connect-timeout 10 -o "${FASTLANE_DIR}/Fastfile" "${url}" 2>/dev/null; then
        # 验证文件是否有效
        if [ -s "${FASTLANE_DIR}/Fastfile" ]; then
            local first_line=$(head -1 "${FASTLANE_DIR}/Fastfile")
            if [[ "$first_line" =~ ^# ]] || [[ "$first_line" =~ ^[a-zA-Z] ]]; then
                echo "✅ 已从 ${source_name} 下载 Fastfile"
                return 0
            fi
        fi
    fi
    
    return 1
}

# 遍历所有源，直到成功
success=false
for source in "${SOURCES[@]}"; do
    source_name="${source%%:*}"
    source_url="${source#*:}"
    
    if download_fastfile "${source_url}" "${source_name}"; then
        success=true
        break
    fi
    
    sleep 1
done

if [ "$success" = false ]; then
    echo "❌ 无法从任何源下载 Fastfile"
    echo ""
    echo "💡 手动下载方法："
    echo "   curl -o ${FASTLANE_DIR}/Fastfile https://gitee.com/6022463/GGFastlane/raw/main/Fastfile"
    echo ""
    echo "📎 仓库地址："
    echo "   Gitee:  https://gitee.com/6022463/GGFastlane"
    echo "   GitHub: https://github.com/github6022244/GGFastlane"
fi

# ==================== 完成 ====================
echo ""
echo "✅ Fastlane 初始化完成！"
echo ""

# 如果需要安装插件，提示用户
if [ "$NEED_INSTALL_PLUGINS" = true ]; then
    echo "🔧 需要安装 Fastlane 插件..."
    echo ""
    read -p "是否现在安装插件？(y/n): " install_plugins
    if [ "$install_plugins" = "y" ]; then
        echo "📥 正在通过 bundle install 安装插件..."
        bundle install
        echo "✅ 插件安装完成"
    else
        echo "💡 稍后手动运行以下命令安装插件："
        echo "   bundle install --verbose   "
    fi
    echo ""
fi

echo "📝 后续步骤："
echo "1️⃣  编辑 .env 文件，填入你的实际配置信息"
echo "2️⃣  将 Bugly 符号表上传工具放到 fastlane/Tools 目录"
echo "3️⃣  将 App Store Connect API 密钥 (.p8) 放到 fastlane/auth 目录"
echo "4️⃣  运行 bundle exec fastlane setup 检查环境"
echo ""
echo "🎉 准备就绪！"
