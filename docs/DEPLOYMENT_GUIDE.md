# App 发布指南 (DEPLOYMENT_GUIDE.md)

## App Store Connect 发布流程概述

### 1. 准备工作

#### 必备材料

| 材料 | 说明 | 要求 |
|------|------|------|
| Apple Developer 账号 | 个人或公司账号 | 需年费加入 ($99/year) |
| App Icon | 应用图标 | 1024x1024 PNG |
| 截图 | 不同尺寸的屏幕截图 | iPhone 6.7", 6.5", 5.5", iPad |
| App 描述 | 应用说明文字 | 170 字符以内（简短描述）|
| 隐私政策 URL | 隐私政策网页 | 必须托管在 HTTPS 网站 |
| 关键词 | Search Keywords | 100 字符以内 |
| 支持 URL | 用户支持页面 | HTTPS |
| 版权信息 | Copyright | 格式: Copyright © 年份 名称 |

#### App 界面截图尺寸要求

| 设备 | 尺寸 (像素) | 用途 |
|------|-------------|------|
| iPhone 6.7" (14 Pro Max) | 1290 x 2796 | App Store 显示 |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 | App Store 显示 |
| iPhone 5.5" (8 Plus) | 1242 x 2208 | App Store 显示 |
| iPad Pro 12.9" (6th) | 2048 x 2732 | App Store 显示 |
| iPad Pro 12.9" (2nd) | 2048 x 2732 | App Store 显示 |

### 2. 创建 App Store Connect 应用

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **My Apps** > **+** > **New App**
3. 填写信息：
   - **Platforms**: iOS
   - **Name**: 情侣日常
   - **Primary Language**: Simplified Chinese
   - **Bundle ID**: 选择你的 App Bundle ID
   - **SKU**: 自定义 SKU 编码

### 3. 构建版本上传

#### 使用 Xcode 上传

1. 在 Xcode 中选择 **Product** > **Archive**
2. 等待 Organizer 窗口打开
3. 选择对应版本，点击 **Distribute App**
4. 选择 **App Store Connect** > **Upload**
5. 按照向导完成签名和上传

#### 使用 Transporter 上传

1. 下载 [Transporter](https://apps.apple.com/app/transporter/id1450874784) App
2. 使用 Apple ID 登录
3. 拖拽 `.ipa` 文件到窗口
4. 点击 **Deliver**

#### 使用命令行上传

```bash
# 安装 altool
xcrun altool --upload-app -t ios -f /path/to/Runner.ipa -u "Apple ID" -p "App-Specific Password"
```

### 4. 填写 App Store 信息

在 App Store Connect 中完善以下信息：

- **App Information**
  - 类别 (Primary/Secondary)
  - 内容访问权限
  - 分级 (Age Rating)

- **App Privacy**
  - 收集的数据类型
  - 数据使用方式
  - 是否关联用户
  - 隐私政策链接

- **Pricing and Availability**
  - 定价 (免费/付费)
  - 可用地区

### 5. 提交审核

1. 完成所有必填信息
2. 点击 **Add for Review**
3. 等待审核结果 (通常 24-48 小时)

## TestFlight 外部测试步骤

### 概述

TestFlight 允许你邀请最多 10000 名外部测试者测试你的应用。

### 1. 启用 TestFlight 测试

1. 在 Xcode 中创建 **TestFlight** 类型的企业签名或开发签名
2. 上传到 App Store Connect
3. 等待构建处理完成 (约 10-30 分钟)

### 2. 创建测试组

1. 进入 App Store Connect > 你的 App > **TestFlight** 标签
2. 在 **External Testing** 下点击 **+**
3. 创建新的测试组 (如 "Beta Testers")

### 3. 添加外部测试员

#### 方式一：通过邮箱邀请

1. 点击测试组 > **Add Testers**
2. 输入测试者邮箱
3. 填写公开链接名称
4. 点击 **Add** 发送邀请

#### 方式二：通过公开链接

1. 开启 **Public Link**
2. 设置邀请数量限制
3. 分享公开链接给测试者

### 4. 测试者操作流程

测试者需要：
1. 在 iPhone/iPad 上安装 **TestFlight** App
2. 使用邀请邮箱登录 (或点击公开链接)
3. 接受邀请
4. 安装测试应用

### 5. 提交测试反馈

测试者可通过 TestFlight 内置功能提交：
- 截图
- 反馈描述
- 崩溃日志

开发者可在 App Store Connect 查看反馈。

### 6. Beta App 审核

外部测试需要 Apple 审核：
- 首次提交需要审核
- 后续更新通常在几小时内通过
- 审核被拒绝需要修改后重新提交

## 需要准备的材料清单

### 首次发布

- [ ] Apple Developer Program 会员资格
- [ ] App Icon (1024x1024)
- [ ] iPhone 截图 (至少 6.5" 和 5.5" 各一套)
- [ ] iPad 截图 (如支持)
- [ ] App 名称
- [ ] 简短描述 (170字符内)
- [ ] 详细描述
- [ ] 关键词 (100字符内)
- [ ] 隐私政策 URL (HTTPS 必需)
- [ ] 支持 URL
- [ ] 版权信息
- [ ] 分级信息
- [ ] 截图审核提示语 (可选)
- [ ] 营销图标 (可选)
- [ ] 预览视频 (可选)

### TestFlight 外部测试

- [ ] 测试组名称
- [ ] 测试者邮箱列表或公开链接
- [ ] 测试说明
- [ ] 联系信息

### 版本更新

- [ ] 更新日志
- [ ] 新截图 (如有 UI 变化)
- [ ] 新构建版本

## 隐私政策要求

### 必须包含的内容

1. **数据收集**
   - 收集哪些数据
   - 收集方式
   - 使用目的

2. **数据存储**
   - 存储位置
   - 存储期限
   - 安全措施

3. **数据共享**
   - 是否与第三方共享
   - 第三方类型
   - 共享目的

4. **用户权利**
   - 访问权限
   - 删除权限
   - 导出权限

5. **联系方式**
   - 开发者联系方式
   - 隐私问题联系邮箱

### 隐私政策模板结构

```
隐私政策

更新日期：[日期]
生效日期：[日期]

1. 引言
2. 我们收集的信息
3. 我们如何使用信息
4. 信息存储与安全
5. 信息共享与转让
6. 您的权利
7. 儿童隐私
8. 政策变更
9. 联系我们
```

## 审核被拒常见原因

| 原因 | 解决方案 |
|------|----------|
| 崩溃或闪退 | 彻底测试，确保稳定 |
| 权限未正确说明 | 检查 Info.plist 权限描述 |
| 隐私政策无效 | 确保 URL 可访问且为 HTTPS |
| 元数据问题 | 检查 App 名称、描述、截图 |
| 引导用户差评 | 不要诱导用户去 App Store 评分 |
| IPv6 兼容性 | 确保网络请求兼容 IPv6 |
| 第三方 SDK 问题 | 使用官方认证的 SDK |

## 相关链接

- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight 测试指南](https://developer.apple.com/testflight/)
- [Apple Developer Program](https://developer.apple.com/programs/)
