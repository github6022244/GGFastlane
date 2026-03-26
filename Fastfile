# frozen_string_literal: true

# ==================== 前置依赖加载 ====================
require 'fileutils'
require 'time'
require 'json'

# ==================== 配置管理模块 ====================
module FastlaneConfig
  class << self
    # 读取环境变量（带默认值）
    def env(key, default = nil)
      value = ENV[key.to_s]
      return value unless value.nil? || value.empty?
      default
    end

    # 验证必需的环境变量
    def require_env(*keys)
      keys.each do |key|
        value = ENV[key.to_s]
        UI.user_error!("❌ 缺少必需的环境变量：#{key}") if value.nil? || value.empty?
      end
    end

    # 路径展开辅助方法（支持 ~ 展开为绝对路径）
    def expand_path(path, base = nil)
      return nil if path.nil?
      expanded = File.expand_path(path.to_s, base)
      File.absolute_path(expanded)
    end
  end
end

# ==================== 加载环境变量 ====================
env_file_path = File.expand_path('.env', __dir__)
if File.exist?(env_file_path)
  require 'dotenv'
  Dotenv.load(env_file_path)
  UI.message("✅ 已加载 .env 配置文件：#{env_file_path}")
else
  UI.important("⚠️  未找到 .env 文件 (#{env_file_path})，将使用默认配置或提示输入")
end

# ==================== 应用基础配置 ====================
DEFAULT_CONFIG = {
  scheme_name: FastlaneConfig.env('GG_SCHEME_NAME', 'ChangXiangGrain'),
  bundle_identifier: FastlaneConfig.env('GG_BUNDLE_IDENTIFIER', 'com.changxianggu.studentProject'),
  
  # 输出目录
  output_dirs: {
    debug: FastlaneConfig.expand_path(FastlaneConfig.env('GG_OUTPUT_DIR_DEBUG')),
    release: FastlaneConfig.expand_path(FastlaneConfig.env('GG_OUTPUT_DIR_RELEASE')),
    appstore: FastlaneConfig.expand_path(FastlaneConfig.env('GG_OUTPUT_DIR_APPSTORE')),
    testflight: FastlaneConfig.expand_path(FastlaneConfig.env('GG_OUTPUT_DIR_TESTFLIGHT'))
  },
  
  # 蒲公英
  pgyer: {
    api_key: FastlaneConfig.env('GG_PGYER_API_KEY'),
    user_key: FastlaneConfig.env('GG_PGYER_USER_KEY'),
    password: FastlaneConfig.env('GG_PGYER_PASSWORD'),
    install_type: FastlaneConfig.env('GG_PGYER_INSTALL_TYPE', '2')
  },
  
  # Bugly - 使用绝对路径
  bugly: {
    app_id: FastlaneConfig.env('GG_BUGLY_APP_ID'),
    app_key: FastlaneConfig.env('GG_BUGLY_APP_KEY'),
    tool_path: begin
      path = FastlaneConfig.env('GG_BUGLY_TOOL_PATH')
      # 手动展开 ~ 符号
      path ? File.expand_path(path) : nil
    end
  },
  
  # 构建配置
  build: {
    timeout: FastlaneConfig.env('GG_BUILD_TIMEOUT', '480'),
    retries: FastlaneConfig.env('GG_BUILD_RETRIES', '10')
  },
  
  # Apple 账号
  apple: {
    username: FastlaneConfig.env('GG_APPLE_USERNAME'),
    password: FastlaneConfig.env('GG_APPLE_PASSWORD'),
    specific_password: FastlaneConfig.env('GG_APPLE_SPECIFIC_PASSWORD')
  },
  
  # App Store Connect API
  app_store_connect: {
    key_id: FastlaneConfig.env('GG_APP_STORE_CONNECT_KEY_ID'),
    issuer_id: FastlaneConfig.env('GG_APP_STORE_CONNECT_ISSUER_ID'),
    key_filename: FastlaneConfig.env('GG_APP_STORE_CONNECT_KEY_FILENAME'),
    key_path: nil
  }
}.freeze

# 初始化 App Store Connect API 密钥路径
if DEFAULT_CONFIG[:app_store_connect][:key_filename]
  key_path = File.expand_path(
    "auth/#{DEFAULT_CONFIG[:app_store_connect][:key_filename]}",
    __dir__
  )
  DEFAULT_CONFIG[:app_store_connect][:key_path] = key_path
end

# ==================== 全局环境变量设置 ====================
ENV['FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT'] = DEFAULT_CONFIG[:build][:timeout]
ENV['FASTLANE_XCODEBUILD_SETTINGS_RETRIES'] = DEFAULT_CONFIG[:build][:retries]
ENV['FASTLANE_DEFAULT_PLATFORM'] = 'ios'

if DEFAULT_CONFIG[:apple][:username]
  ENV['FASTLANE_USER'] = DEFAULT_CONFIG[:apple][:username]
end
if DEFAULT_CONFIG[:apple][:password]
  ENV['FASTLANE_PASSWORD'] = DEFAULT_CONFIG[:apple][:password]
end
if DEFAULT_CONFIG[:apple][:specific_password]
  ENV['FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD'] = DEFAULT_CONFIG[:apple][:specific_password]
end

# ==================== 平台定义 ====================
default_platform(:ios)

# ==================== 工具方法模块 ====================
module FastlaneUtils
  # 清理并重建目录
  def self.cleanup_directory(path)
    UI.message("🗑️ 清理目录：#{path}")
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p(path)
    UI.success("✅ 目录已就绪：#{path}")
  end

  # 查找 dSYM 文件
  def self.find_dsym_path(scheme:, possible_dirs:)
    pattern = "#{scheme}*.app.dSYM.zip"
    found_files = []

    possible_dirs.each do |dir|
      next unless dir && File.directory?(dir)
      matches = Dir.glob(File.join(dir, pattern))
      found_files.concat(matches)
    end

    if found_files.empty?
      UI.user_error!(<<~ERROR)
        ❌ 未在以下目录找到 dSYM 文件：
        #{possible_dirs.compact.join("\n")}
        
        请检查：
        1. 是否已执行过打包操作
        2. 输出目录配置是否正确
      ERROR
    end

    # 返回最新的文件
    found_files.max_by { |f| File.mtime(f) }
  end

  # 更新 Build 号（纯数字格式）
  def self.update_build_number
    current_date = Time.now.strftime('%Y%m%d')
    
    begin
      current_build = get_build_number.to_s
    rescue StandardError
      current_build = "#{current_date}00"
    end

    UI.message("🔍 当前 Build 号：#{current_build}")

    new_build = if current_build.start_with?(current_date) && current_build.match?(/^\d+$/)
                  seq = current_build[current_date.length..-1].to_i + 1
                  "#{current_date}#{seq.to_s.rjust(2, '0')}"
                else
                  "#{current_date}01"
                end

    # 苹果限制：最多 18 位
    new_build = new_build[0, 18] if new_build.length > 18

    UI.success("✅ Build 号更新：#{current_build} → #{new_build}")
    increment_build_number(build_number: new_build)
    new_build
  end

  # 增加 Build 号（模块内部方法）
  def self.increment_build_number(options)
    build_number = options[:build_number]
    
    # 更新 lane_context
    Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
    
    # 尝试修改 Info.plist
    require 'xcodeproj'
    
    # 查找项目文件
    project_path = nil
    if File.exist?('*.xcodeproj')
      project_path = Dir.glob('*.xcodeproj').first
    elsif File.exist?('*.xcworkspace')
      workspace_path = Dir.glob('*.xcworkspace').first
      project_path = workspace_path.gsub('.xcworkspace', '.xcodeproj')
    end
    
    if project_path && File.directory?(project_path)
      begin
        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configurations.each do |config|
            config.build_settings['CFBundleVersion'] = build_number
          end
        end
        project.save
        UI.success("✅ 已更新项目配置中的 CFBundleVersion: #{build_number}")
      rescue => e
        UI.important("⚠️  更新项目配置失败：#{e.message}，将继续执行")
      end
    else
      UI.important("⚠️  未找到 Xcode 项目文件，跳过配置更新")
    end
    
    build_number
  end

  # 临时解压 dSYM
  def self.temp_unzip_dsym(zip_path)
    temp_dir = File.join(Dir.tmpdir, "bugly_dsym_#{Time.now.to_i}_#{rand(1000)}")
    FileUtils.mkdir_p(temp_dir)

    UI.message("📦 解压 dSYM 到：#{temp_dir}")
    result = system("unzip -q '#{zip_path}' -d '#{temp_dir}'")
    
    unless result
      FileUtils.rm_rf(temp_dir)
      UI.user_error!("❌ dSYM 解压失败，请检查 zip 文件完整性")
    end

    dsym_dir = Dir.glob(File.join(temp_dir, '**/*.dSYM')).first
    
    unless dsym_dir && File.directory?(dsym_dir)
      FileUtils.rm_rf(temp_dir)
      UI.user_error!("❌ 解压后未找到 .dSYM 目录")
    end

    [dsym_dir, temp_dir]
  end

  # 获取 API 密钥配置
  def self.app_store_connect_api_key
    config = DEFAULT_CONFIG[:app_store_connect]
    
    return nil unless config[:key_id] && config[:issuer_id] && config[:key_path]
    return nil unless File.exist?(config[:key_path])

    {
      key_id: config[:key_id],
      issuer_id: config[:issuer_id],
      key_filepath: config[:key_path],
      duration: 1200,
      in_house: false
    }
  end

  # 构建 gym 通用参数
  def self.build_gym_options(output_dir:, configuration:, export_method:, additional_options: {})
    {
      destination: "generic/platform=iOS", 
      scheme: DEFAULT_CONFIG[:scheme_name],
      output_directory: output_dir,
      output_name: "#{DEFAULT_CONFIG[:scheme_name]}_#{Time.now.strftime('%Y%m%d%H%M%S')}.ipa",
      configuration: configuration,
      include_bitcode: false,
      include_symbols: configuration == 'Debug' || export_method == 'ad-hoc',
      export_method: export_method,
      export_xcargs: '-allowProvisioningUpdates',
      clean: true,
      verbose: false
    }.merge(additional_options)
  end

  # 验证环境
  def self.validate_environment
    errors = []

    # 检查必要配置
    errors << "缺少蒲公英 API Key" unless DEFAULT_CONFIG[:pgyer][:api_key]
    
    # 检查 Bugly 工具是否存在（绝对路径）
    bugly_path = DEFAULT_CONFIG[:bugly][:tool_path]
    if bugly_path.nil? || bugly_path.empty?
      errors << "未配置 Bugly 工具路径 (GG_BUGLY_TOOL_PATH)"
    elsif !File.exist?(bugly_path)
      errors << "Bugly 工具不存在：#{bugly_path}"
    end

    if errors.any?
      UI.error("❌ 环境验证失败:")
      errors.each { |e| UI.error("   - #{e}") }
      UI.user_error!("请修复以上环境问题后重试")
    end

    UI.success("✅ 环境验证通过")
  end
end

# ==================== Lane 定义 ====================
platform :ios do
  before_all do
    # 每次执行前验证环境
    FastlaneUtils.validate_environment
  end

  desc "初始化环境检查"
  lane :setup do
    UI.header("🔧 环境检查")

    # 检查 Ruby 环境
    if Gem.path.any? { |p| p.include?('vendor/bundle') }
      UI.success("✅ 使用项目内 Bundler: #{Gem.default_path}")
    else
      UI.important("⚠️  建议使用 bundle exec 运行 fastlane")
    end

    # 检查必需工具
    %w[xcodebuild xcrun git].each do |tool|
      if system("command -v #{tool} >/dev/null 2>&1")
        UI.success("✅ #{tool} 已安装")
      else
        UI.error("❌ #{tool} 未安装")
      end
    end

    # 检查 Java 环境（Bugly 符号表上传工具依赖）
    UI.message("")
    UI.message("☕ 检查 Java 环境...")
    java_version_output = `java -version 2>&1`
    if $?.success?
      java_version = java_version_output.lines.first&.strip || "未知版本"
      UI.success("✅ Java 已安装：#{java_version}")
    else
      UI.error("❌ Java 未安装或未配置到 PATH")
      UI.message("💡 Bugly 符号表上传工具需要 Java 环境")
      UI.message("📦 安装命令:")
      UI.message("   brew install openjdk@17")
      UI.message("   sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk")
      UI.message("   echo 'export PATH=\"/opt/homebrew/opt/openjdk@17/bin:$PATH\"' >> ~/.zshrc")
      UI.message("   source ~/.zshrc")
    end

    # 显示当前配置信息
    UI.header("📋 当前配置")
    UI.message("Scheme: #{DEFAULT_CONFIG[:scheme_name]}")
    UI.message("Bundle ID: #{DEFAULT_CONFIG[:bundle_identifier]}")
    UI.message("Bugly 工具：#{DEFAULT_CONFIG[:bugly][:tool_path] || '未配置'}")
    
    if DEFAULT_CONFIG[:bugly][:tool_path] && File.exist?(DEFAULT_CONFIG[:bugly][:tool_path])
      UI.success("✅ Bugly 工具存在")
    else
      UI.error("❌ Bugly 工具不存在或路径错误")
    end

    UI.success("\n🎉 环境检查完成！")
  end

  desc "测试包发蒲公英（Debug）"
  lane :dev_pgyer do |options|
    UI.header("📱 打包 Debug 版本并上传蒲公英")

    update_desc = if options[:update_description]
                    options[:update_description].to_s
                  else
                    begin
                      result = ask("请输入更新说明:")
                      desc_str = result.to_s.strip
                      desc_str.empty? ? "无更新说明" : desc_str
                    rescue
                      "无更新说明"
                    end
                  end

    output_dir = DEFAULT_CONFIG[:output_dirs][:debug]
    FastlaneUtils.cleanup_directory(output_dir)


    gym_options = FastlaneUtils.build_gym_options(
      output_dir: output_dir,
      configuration: 'Debug',
      export_method: 'development',
      additional_options: { 
        export_options: { 
          signingStyle: 'automatic'
        } 
      }
    )

    gym(gym_options)

    pgyer(
      api_key: DEFAULT_CONFIG[:pgyer][:api_key],
      password: DEFAULT_CONFIG[:pgyer][:password],
      install_type: DEFAULT_CONFIG[:pgyer][:install_type],
      update_description: update_desc
    )

    UI.success("✅ Debug 包已上传到蒲公英")
  end

  desc "正式包发蒲公英（Release）"
  lane :public_pgyer do |options|
    UI.header("📦 打包 Release 版本并上传蒲公英")

    update_desc = if options[:update_description]
                    options[:update_description].to_s
                  else
                    begin
                      result = ask("请输入本次更新说明 (直接回车则不填):")
                      desc_str = result.to_s.strip
                      desc_str.empty? ? "无更新说明" : desc_str
                    rescue
                      "无更新说明"
                    end
                  end

    output_dir = DEFAULT_CONFIG[:output_dirs][:release]
    FastlaneUtils.cleanup_directory(output_dir)

    gym_options = FastlaneUtils.build_gym_options(
      output_dir: output_dir,
      configuration: 'Release',
      export_method: 'ad-hoc',
      additional_options: {
        export_options: { signingStyle: 'automatic' } 
      }
    )

    gym(gym_options)

    pgyer(
      api_key: DEFAULT_CONFIG[:pgyer][:api_key],
      password: DEFAULT_CONFIG[:pgyer][:password],
      install_type: DEFAULT_CONFIG[:pgyer][:install_type],
      update_description: update_desc
    )

    UI.success("✅ Release 包已上传到蒲公英")
  end

  desc "打包并上传到 TestFlight（内部测试）"
  lane :testflight_internal do |options|
    UI.header("🚀 TestFlight 内部测试上传")

    update_desc = if options[:update_description]
                    options[:update_description].to_s
                  else
                    begin
                      result = ask("请输入更新说明:")
                      desc_str = result.to_s.strip
                      desc_str.empty? ? "无更新说明" : desc_str
                    rescue
                      "无更新说明"
                    end
                  end

    output_dir = DEFAULT_CONFIG[:output_dirs][:testflight]
    FastlaneUtils.cleanup_directory(output_dir)

    build_number = FastlaneUtils.update_build_number
    ipa_filename = "#{DEFAULT_CONFIG[:scheme_name]}_#{build_number}_testflight.ipa"

    UI.message("📄 IPA 文件名：#{ipa_filename}")

    gym_options = FastlaneUtils.build_gym_options(
      output_dir: output_dir,
      configuration: 'Release',
      export_method: 'app-store',
      additional_options: {
        output_name: ipa_filename,
        export_options: { signingStyle: 'automatic' }
      }
    )

    gym(gym_options)
    ipa_path = File.join(output_dir, ipa_filename)
    UI.success("✅ IPA 构建完成：#{ipa_path}")

    pilot_options = {
      ipa: ipa_path,
      skip_waiting_for_build_processing: true,
      distribute_external: false,
      changelog: update_desc,
      expire_previous_builds: true
    }

    api_key = FastlaneUtils.app_store_connect_api_key
    if api_key
      UI.message("🔑 使用 API 密钥认证")
      pilot_options[:api_key] = api_key
    else
      UI.message("🔑 使用账号密码认证")
      UI.user_error!("❌ 未配置 Apple ID") unless DEFAULT_CONFIG[:apple][:username]
      pilot_options[:username] = DEFAULT_CONFIG[:apple][:username]
    end

    pilot(pilot_options)

    UI.success("\n🎉 TestFlight 上传完成！")
    UI.success("📌 查看进度：https://appstoreconnect.apple.com")
  end

  desc "打包 App Store 版本"
  lane :ipa_appstore do
    UI.header("📀 打包 App Store 版本")

    output_dir = DEFAULT_CONFIG[:output_dirs][:appstore]
    FastlaneUtils.cleanup_directory(output_dir)

    build_number = FastlaneUtils.update_build_number
    ipa_filename = "#{DEFAULT_CONFIG[:scheme_name]}_#{build_number}.ipa"

    gym_options = FastlaneUtils.build_gym_options(
      output_dir: output_dir,
      configuration: 'Release',
      export_method: 'app-store',
      additional_options: {
        output_name: ipa_filename,
        include_symbols: false,
        export_options: { signingStyle: 'automatic' }
      }
    )

    gym(gym_options)

    ipa_path = File.join(output_dir, ipa_filename)
    UI.success("✅ App Store IPA 已生成：#{ipa_path}")
    ipa_path
  end

  desc "上传到 App Store"
  lane :upload_appstore do
    UI.header("☁️ 上传到 App Store")

    ipa_path = ipa_appstore

    api_key = FastlaneUtils.app_store_connect_api_key
    
    deliver_options = {
      ipa: ipa_path,
      skip_screenshots: true,
      skip_metadata: true,
      force: true
    }

    deliver_options[:api_key] = api_key if api_key
    deliver_options[:username] = DEFAULT_CONFIG[:apple][:username] unless api_key

    deliver(deliver_options)

    UI.success("✅ 已上传到 App Store Connect")
  end

  desc "上传符号表到 Bugly"
  lane :upload_bugly_symbols do |options|
    UI.header("🐛 上传 dSYM 到 Bugly")

    version = if options[:version]
                options[:version].to_s
              else
                begin
                  result = ask("请输入应用版本号 (如 1.0.0):")
                  ver_str = result.to_s.strip
                  ver_str.empty? ? "1.0.0" : ver_str
                rescue
                  "1.0.0"
                end
              end
    UI.user_error!("❌ 版本号不能为空") if version.strip.empty?

    possible_dirs = options[:output_dirs] || DEFAULT_CONFIG[:output_dirs].values.compact

    dsym_zip_path = options[:dsym_path] || FastlaneUtils.find_dsym_path(
      scheme: DEFAULT_CONFIG[:scheme_name],
      possible_dirs: possible_dirs
    )
    UI.message("📌 找到 dSYM: #{dsym_zip_path}")

    dsym_dir, temp_dir = FastlaneUtils.temp_unzip_dsym(dsym_zip_path)
    UI.message("✅ dSYM 解压完成：#{dsym_dir}")

    begin
      bugly_config = DEFAULT_CONFIG[:bugly]
      
      java_command = [
        "java",
        "-jar", bugly_config[:tool_path].shellescape,
        "-u",
        "-pk", bugly_config[:app_key].shellescape,
        "-pvid", bugly_config[:app_id].shellescape,
        "-i", dsym_dir.shellescape,
        "-vv"
      ].join(' ')

      UI.message("🔨 执行命令：#{java_command}")
      
      result = system(java_command)
      
      unless result
        UI.user_error!("❌ Bugly 上传失败")
      end

      UI.success("✅ dSYM 已成功上传到 Bugly")
    ensure
      if temp_dir && File.exist?(temp_dir)
        UI.message("🗑️ 清理临时文件：#{temp_dir}")
        FileUtils.rm_rf(temp_dir)
      end
    end
  end

  desc "完整发布流程（蒲公英 Release）"
  lane :release do
    UI.header("🎯 执行完整发布流程")
    
    begin
      public_pgyer
      version = begin
                  result = ask("请输入版本号用于上传 dSYM:")
                  ver_str = result.to_s.strip
                  ver_str.empty? ? "1.0.0" : ver_str
                rescue
                  "1.0.0"
                end
      upload_bugly_symbols(version: version)
      
      UI.success("\n🎉 发布流程全部完成！")
    rescue StandardError => e
      UI.error("\n❌ 发布失败：#{e.message}")
      UI.error(e.backtrace.first(5).join("\n"))
      raise
    end
  end

  after_all do |lane|
    UI.success("✅ Lane #{lane} 执行成功！")
  end

  error do |lane, exception|
    UI.error("❌ Lane #{lane} 执行失败！")
    UI.error("错误信息：#{exception.message}")
  end
end
# ==================== GGFastlane 配置 ====================

# GGFastlane 配置
GG_CONFIG = {
  scheme_name: ENV['GG_SCHEME_NAME'] || 'YourApp',
  bundle_identifier: ENV['GG_BUNDLE_IDENTIFIER'] || 'com.yourcompany.yourapp',
  
  output_dirs: {
    debug: ENV['GG_OUTPUT_DIR_DEBUG'] ? File.expand_path(ENV['GG_OUTPUT_DIR_DEBUG']) : File.join(Dir.home, 'Desktop', 'AppBuilds', 'Debug'),
    release: ENV['GG_OUTPUT_DIR_RELEASE'] ? File.expand_path(ENV['GG_OUTPUT_DIR_RELEASE']) : File.join(Dir.home, 'Desktop', 'AppBuilds', 'Release'),
    appstore: ENV['GG_OUTPUT_DIR_APPSTORE'] ? File.expand_path(ENV['GG_OUTPUT_DIR_APPSTORE']) : File.join(Dir.home, 'Desktop', 'AppBuilds', 'AppStore'),
    testflight: ENV['GG_OUTPUT_DIR_TESTFLIGHT'] ? File.expand_path(ENV['GG_OUTPUT_DIR_TESTFLIGHT']) : File.join(Dir.home, 'Desktop', 'AppBuilds', 'TestFlight')
  },
  
  pgyer: {
    api_key: ENV['GG_PGYER_API_KEY'],
    password: ENV['GG_PGYER_PASSWORD'],
    install_type: ENV['GG_PGYER_INSTALL_TYPE'] || '2'
  },
  
  bugly: {
    app_id: ENV['GG_BUGLY_APP_ID'],
    app_key: ENV['GG_BUGLY_APP_KEY'],
    tool_path: ENV['GG_BUGLY_TOOL_PATH'] ? File.expand_path(ENV['GG_BUGLY_TOOL_PATH']) : nil
  },
  
  apple: {
    username: ENV['GG_APPLE_USERNAME'],
    password: ENV['GG_APPLE_PASSWORD'],
    specific_password: ENV['GG_APPLE_SPECIFIC_PASSWORD']
  },
  
  app_store_connect: {
    key_id: ENV['GG_APP_STORE_CONNECT_KEY_ID'],
    issuer_id: ENV['GG_APP_STORE_CONNECT_ISSUER_ID'],
    key_filename: ENV['GG_APP_STORE_CONNECT_KEY_FILENAME'],
    key_path: nil
  }
}

# 初始化 App Store Connect API 密钥路径
if GG_CONFIG[:app_store_connect][:key_filename]
  GG_CONFIG[:app_store_connect][:key_path] = File.expand_path(
    "auth/#{GG_CONFIG[:app_store_connect][:key_filename]}",
    __dir__
  )
end

# GGFastlane 快捷命令
platform :ios do
  desc "GGFastlane: 初始化环境"
  lane :gg_setup do
    gg_fastlane.setup
  end

  desc "GGFastlane: 上传测试包到蒲公英"
  lane :gg_dev_pgyer do |options|
    gg_fastlane.upload_pgyer(
      configuration: 'Debug',
      export_method: 'development',
      update_description: options[:update_description]
    )
  end

  desc "GGFastlane: 上传正式包到蒲公英"
  lane :gg_public_pgyer do |options|
    gg_fastlane.upload_pgyer(
      configuration: 'Release',
      export_method: 'ad-hoc',
      update_description: options[:update_description]
    )
  end

  desc "GGFastlane: 上传到 TestFlight"
  lane :gg_testflight do |options|
    gg_fastlane.upload_testflight(
      update_description: options[:update_description]
    )
  end

  desc "GGFastlane: 上传到 App Store"
  lane :gg_appstore do
    gg_fastlane.upload_appstore
  end

  desc "GGFastlane: 上传符号表到 Bugly"
  lane :gg_bugly_symbols do |options|
    gg_fastlane.upload_bugly_symbols(
      version: options[:version]
    )
  end

  desc "GGFastlane: 完整发布流程"
  lane :gg_release do
    gg_fastlane.release
  end

  desc "GGFastlane: 显示配置信息"
  lane :gg_config do
    gg_fastlane.show_config
  end
end