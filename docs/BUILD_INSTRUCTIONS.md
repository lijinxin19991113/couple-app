# iOS 构建说明 (BUILD_INSTRUCTIONS.md)

## 在 macOS 上构建 iOS 项目

### 环境要求

- macOS 10.15+ (Catalina 或更高版本)
- Xcode 14.0+
- CocoaPods 1.10+
- Flutter SDK 3.0+

### 前置检查

1. 检查 Flutter 环境
```bash
flutter doctor
```

2. 查看可用模拟器
```bash
xcrun simctl list devices available
```

3. 确保 iOS 相关组件已安装
```bash
flutter doctor -v
```

### 构建步骤

#### 方式一：使用 Flutter 命令（推荐）

```bash
# 1. 进入项目目录
cd /path/to/couple-app

# 2. 获取依赖
flutter pub get

# 3. 在模拟器上构建（不签名）
flutter build ios --simulator --no-codesign

# 4. 如果需要指定模拟器
flutter build ios --simulator --no-codesign --target=lib/main.dart
```

#### 方式二：使用 Xcode

```bash
# 1. 打开 Xcode 项目
open ios/Runner.xcworkspace

# 2. 在 Xcode 中：
#    - 选择目标模拟器或真机
#    - 选择 Product > Build
#    - 或使用快捷键 Cmd + B
```

#### 方式三：使用 xcodebuild

```bash
# 列出可用方案
xcodebuild -workspace ios/Runner.xcworkspace -list

# 构建 Debug 版本到模拟器
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

## 在模拟器中运行

### 启动模拟器

```bash
# 使用 Flutter
flutter devices
open -a Simulator

# 或直接用 xcrun
xcrun simctl boot "iPhone 15"
```

### 运行应用

```bash
# 方式一：Flutter run
flutter run -d "iPhone 15"

# 方式二：在 Xcode 中点击 Run 按钮
```

### 安装到模拟器（已构建的包）

```bash
# 从构建产物安装
xcrun simctl install booted build/ios/iphonesimulator/Runner.app

# 启动应用
xcrun simctl launch booted com.example.coupleApp
```

## 常见构建错误及解决方案

### 1. CocoaPods 安装失败

**错误信息：**
```
Error: CocoaPods's specs repository is too out-of-date to satisfy dependencies
```

**解决方案：**
```bash
# 更新 CocoaPods 仓库
pod repo update

# 或者重新安装
sudo gem install cocoapods
pod install --repo-update
```

### 2. Flutter 版本不兼容

**错误信息：**
```
Error: The Flutter SDK is too old or too new
```

**解决方案：**
```bash
# 升级 Flutter
flutter upgrade

# 或指定特定版本
flutter version 3.13.0
```

### 3. 权限配置错误

**错误信息：**
```
Permission denied or Permission error when accessing photo library
```

**解决方案：**
确保 `Info.plist` 中包含正确的权限描述：
- `NSPhotoLibraryUsageDescription`
- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSLocationWhenInUseUsageDescription`

### 4. 签名证书问题

**错误信息：**
```
Code Signing Error: No valid signing certificate
```

**解决方案：**
- 对于模拟器构建，使用 `--no-codesign` 标志
- 对于真机开发，在 Xcode 中配置签名证书
- 检查 Apple Developer 账号状态

### 5. 架构兼容问题

**错误信息：**
```
Building for iOS Simulator, but linking in object file built for macOS
```

**解决方案：**
```bash
# 清理构建缓存
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# 重新获取依赖
flutter pub get
cd ios && pod install && cd ..
```

### 6. Swift 版本不兼容

**错误信息：**
```
.swiftmodule does not support toolchain version X
```

**解决方案：**
在 `Podfile` 中指定 Swift 版本：
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
```

### 7. 内存不足

**错误信息：**
```
Build Failed: Virtual memory exhausted
```

**解决方案：**
```bash
# 增加 swap 空间或关闭其他应用
# 在 Xcode 中：Product > Scheme > Edit Scheme > Build > Parallelize Build 关闭
```

## 构建产物位置

| 类型 | 路径 |
|------|------|
| Debug (模拟器) | `build/ios/iphonesimulator/Runner.app` |
| Release | `build/ios/iphoneos/Runner.app` |
| Archive | `build/ios/archive/Runner.xcarchive` |

## 清理构建

```bash
# Flutter 清理
flutter clean

# 深度清理
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf build/

# 重新构建
flutter pub get
cd ios && pod install && cd ..
flutter build ios --simulator --no-codesign
```
