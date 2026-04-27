# 情侣日常 App Phase 3 技术设计文档

## 1. 文档目标

本文档定义情侣日常 App **Phase 3 业务功能**的技术实现方案，覆盖聊天、共享相册、纪念日、心情打卡四大核心模块，作为开发、测试与接口联调的基础参考。

## 2. 技术背景

### 2.1 技术栈

| 类别 | 方案 | 版本 |
|------|------|------|
| 客户端框架 | Flutter | 3.24.5 |
| 状态管理 | GetX | ^4.6.6 |
| 后端服务 | LeanCloud BaaS | SDK latest |
| 实时通信 | LeanCloud IM / WebSocket | - |
| 文件存储 | LeanCloud File | - |
| 推送通知 | LeanCloud Push | - |
| 图片处理 | image_picker / flutter_image_compress | - |

### 2.2 架构约束

- **分层架构**：`Presentation(Page/Controller) + Domain(Service/Repository) + Data(Model/API)`
- **服务封装**：所有数据访问通过 Service 层，不允许页面直接调用 SDK
- **情侣隔离**：共享数据必须校验 `relationId`，确保只有情侣双方可访问
- **弱网兜底**：所有提交类操作需具备本地缓存、重试机制与失败提示

## 3. 模块一：聊天（Chat）

### 3.1 功能范围

| 功能点 | 优先级 | 说明 |
|--------|--------|------|
| 会话列表 | P0 | 展示聊天对象、最后消息、时间和未读数 |
| 单聊页面 | P0 | 文字消息发送与接收 |
| 图片消息 | P0 | 相册选择/拍照发送图片 |
| 消息状态 | P0 | 发送中/发送成功/发送失败/已读 |
| 历史消息分页 | P1 | 上拉加载更多历史记录 |
| 表情消息 | P1 | 快捷表情发送 |
| 未读数清零 | P1 | 进入聊天页自动清除未读 |

### 3.2 数据模型

#### ChatMessage（聊天消息）

```dart
class ChatMessage {
  String objectId;           // 主键
  String clientMsgId;        // 客户端消息 ID（幂等）
  String relationId;         // 情侣关系 ID
  String senderId;           // 发送者用户 ID
  String receiverId;         // 接收者用户 ID
  String messageType;        // text / image / emoji / system / location
  String content;            // 文本内容或媒体摘要
  String? mediaUrl;          // 图片/媒体文件 URL
  String? mediaThumbnailUrl; // 缩略图 URL
  int? mediaWidth;           // 图片宽度
  int? mediaHeight;          // 图片高度
  String? locationAddress;   // 位置卡片地址
  double? locationLat;       // 位置纬度
  double? locationLng;       // 位置经度
  String sendStatus;         // sending / sent / failed / read
  DateTime? readAt;          // 已读时间
  DateTime createdAt;        // 创建时间
}
```

### 3.3 服务层设计

#### ChatService

```dart
class ChatService {
  // 获取聊天消息列表（分页）
  Future<List<ChatMessage>> getChatMessages({
    required String relationId,
    DateTime? beforeTime,
    int limit = 20,
  });

  // 发送文本消息
  Future<ChatMessage> sendTextMessage({
    required String relationId,
    required String content,
  });

  // 发送图片消息
  Future<ChatMessage> sendImageMessage({
    required String relationId,
    required String localFilePath,
    String? caption,
  });

  // 标记消息已读
  Future<void> markMessagesAsRead({
    required String relationId,
    String? lastReadMsgId,
  });

  // 获取未读消息数
  Future<int> getUnreadCount(String relationId);

  // 实时监听新消息（WebSocket / LeanCloud IM）
  Stream<ChatMessage> observeNewMessages(String relationId);
}
```

### 3.4 界面设计

#### 会话列表页（ChatListPage）

- 顶部：标题栏"聊天"
- 列表项：对方头像 + 昵称 + 最后消息预览 + 时间 + 未读气泡
- 空态：引导绑定情侣关系的插画与文案
- 底部：输入框，点击跳转单聊页

#### 单聊页（ChatPage）

- 顶部：对方昵称、在线状态
- 中部：消息气泡列表（自己右对齐/对方左对齐）
  - 文字消息：文字气泡
  - 图片消息：缩略图 + 点击查看大图
  - 发送中：旋转loading
  - 发送失败：红色感叹号 + 重试按钮
  - 已读状态：底部小字"已读"
- 底部：输入栏（文本框 + 发送按钮 + 图片按钮 + 表情按钮）
- 键盘展开时消息列表自动跟随

### 3.5 交互流程

```
1. 用户打开聊天页
2. 调用 getChatMessages 加载最近消息
3. 调用 markMessagesAsRead 清除未读数
4. 订阅 observeNewMessages 监听新消息
5. 用户发送消息 -> 本地先展示 sending 状态
6. 调用 sendTextMessage / sendImageMessage
7. 服务端返回后更新消息状态为 sent/failed
8. 对方收到消息后调用 markMessagesAsRead
9. 发送方收到已读状态更新
```

### 3.6 边界情况处理

| 场景 | 处理方案 |
|------|----------|
| 弱网发送失败 | 消息展示 failed 状态，点击重试 |
| 图片上传超时 | 压缩图片后重试，超时中断并提示 |
| 消息列表为空 | 展示空态插画 |
| 未绑定情侣 | 禁止进入聊天页，跳转绑定引导 |
| Token 失效 | 拦截跳转登录页 |

## 4. 模块二：共享相册（Shared Album）

### 4.1 功能范围

| 功能点 | 优先级 | 说明 |
|--------|--------|------|
| 相册列表 | P0 | 按时间/月份分组展示照片 |
| 上传照片 | P0 | 相册选择/拍照上传 |
| 照片预览 | P0 | 查看大图、缩放 |
| 照片详情 | P1 | 展示文案、地点、时间、上传者 |
| 删除照片 | P1 | 仅上传者可删除 |
| 照片筛选 | P2 | 按年份/标签筛选 |

### 4.2 数据模型

#### AlbumPhoto（相册照片）

```dart
class AlbumPhoto {
  String objectId;           // 主键
  String relationId;         // 情侣关系 ID
  String uploaderId;         // 上传者用户 ID
  String photoUrl;           // 原始图片 URL
  String thumbnailUrl;       // 缩略图 URL
  String? caption;          // 照片文案
  DateTime? shotAt;         // 拍摄时间
  String? locationText;     // 拍摄地点文本
  List<String> tags;        // 标签列表
  String visibility;        // both / private
  DateTime createdAt;       // 创建时间
}
```

### 4.3 服务层设计

#### AlbumService

```dart
class AlbumService {
  // 获取相册列表（分页）
  Future<List<AlbumPhoto>> getAlbumPhotos({
    required String relationId,
    int page = 1,
    int pageSize = 20,
    String? yearMonth,
  });

  // 上传照片
  Future<AlbumPhoto> uploadPhoto({
    required String relationId,
    required String localFilePath,
    String? caption,
    DateTime? shotAt,
    String? locationText,
    List<String>? tags,
    String visibility = 'both',
  });

  // 获取照片详情
  Future<AlbumPhoto> getPhotoDetail(String photoId);

  // 删除照片
  Future<void> deletePhoto(String photoId);

  // 更新照片文案
  Future<AlbumPhoto> updatePhotoCaption(String photoId, String caption);
}
```

### 4.4 界面设计

#### 相册列表页（AlbumPage）

- 顶部：标题栏"相册"、筛选入口
- 网格视图：每行2-3张照片，缩略图展示
- 按月分组：月份标签 + 该月照片网格
- 空态：引导上传第一张照片的插画
- 底部：悬浮上传按钮

#### 照片预览页（PhotoViewPage）

- 全屏展示图片，支持双指缩放
- 底部：文案、时间、地点、上传者信息
- 右上角：删除按钮（仅上传者可见）

#### 上传页（UploadPhotoPage）

- 图片预览 + 裁剪/压缩
- 文案输入框
- 标签选择
- 可见性开关（共享/仅自己）
- 上传进度条

### 4.5 交互流程

```
1. 用户点击上传按钮
2. 选择图片来源（相册/拍照）
3. 图片压缩处理
4. 填写文案、标签、可见性
5. 调用 uploadPhoto
6. 展示上传进度
7. 上传成功后刷新相册列表
8. 失败时展示错误提示与重试按钮
```

### 4.6 边界情况处理

| 场景 | 处理方案 |
|------|----------|
| 上传中断 | 本地缓存任务状态，支持断点续传 |
| 图片格式不支持 | 上传前检测并提示支持的格式 |
| 单次上传过多张 | 限制单次最多9张，超出提示 |
| 存储空间不足 | 检测并提示清理空间 |
| 照片加载慢 | 优先加载缩略图，原图懒加载 |

## 5. 模块三：纪念日（Anniversary）

### 5.1 功能范围

| 功能点 | 优先级 | 说明 |
|--------|--------|------|
| 纪念日列表 | P0 | 展示所有纪念日及倒计时 |
| 新增纪念日 | P0 | 创建自定义纪念日 |
| 编辑纪念日 | P0 | 修改纪念日信息 |
| 删除纪念日 | P0 | 删除纪念日确认 |
| 纪念日倒计时 | P0 | 计算并展示剩余天数 |
| 纪念日提醒 | P1 | 推送通知提醒 |

### 5.2 数据模型

#### Anniversary（纪念日）

```dart
class Anniversary {
  String objectId;           // 主键
  String relationId;         // 情侣关系 ID
  String title;              // 纪念日名称
  DateTime date;             // 纪念日日期
  String type;               // love / birthday / first_met / custom
  String repeatType;         // none / yearly / monthly / weekly
  bool reminderEnabled;      // 是否开启提醒
  String? reminderTime;      // 提醒时间（HH:mm）
  String? note;              // 备注
  String createdBy;          // 创建者用户 ID
  DateTime createdAt;        // 创建时间
  DateTime updatedAt;        // 更新时间
}
```

### 5.3 服务层设计

#### AnniversaryService

```dart
class AnniversaryService {
  // 获取纪念日列表
  Future<List<Anniversary>> getAnniversaryList(String relationId);

  // 创建纪念日
  Future<Anniversary> createAnniversary({
    required String relationId,
    required String title,
    required DateTime date,
    String type = 'custom',
    String repeatType = 'none',
    bool reminderEnabled = false,
    String? reminderTime,
    String? note,
  });

  // 更新纪念日
  Future<Anniversary> updateAnniversary(String id, Map<String, dynamic> updates);

  // 删除纪念日
  Future<void> deleteAnniversary(String id);

  // 获取即将到来的纪念日（首页用）
  Future<List<Anniversary>> getUpcomingAnniversaries(String relationId, {int limit = 3});

  // 计算倒计时天数
  int calculateCountdown(DateTime anniversaryDate);
}
```

### 5.4 界面设计

#### 纪念日列表页（AnniversaryPage）

- 顶部：标题栏"纪念日"、新增按钮
- 列表：纪念日卡片
  - 类型图标 + 标题 + 日期 + 倒计时天数
  - 重复类型标签
  - 提醒开关
- 空态：引导创建第一个纪念日

#### 新增/编辑纪念日页（AnniversaryFormPage）

- 标题输入框
- 日期选择器
- 类型选择（恋爱纪念日/生日/初次见面/自定义）
- 重复规则选择
- 提醒开关 + 提醒时间选择
- 备注输入框
- 保存/删除按钮

### 5.5 倒计时计算规则

```
1. 获取纪念日日期 date 和重复类型 repeatType
2. 计算距离今天的天数 diff = date - today
3. 如果 diff < 0 且 repeatType != none：
   - yearly: 计算下一个周年纪念日（年+1）
   - monthly: 计算下一个月份纪念日（月+1）
4. 倒计时天数 = diff 的绝对值
5. 恋爱天数：从 anniversaryDate 到今天的总天数
```

### 5.6 边界情况处理

| 场景 | 处理方案 |
|------|----------|
| 日期为空 | 禁止保存 |
| 跨年倒计时 | 正确计算下一个周年日期 |
| 提醒权限关闭 | 提示前往系统设置开启 |
| 重复纪念日 | 明确展示重复规则 |

## 6. 模块四：心情打卡（Mood Check-in）

### 6.1 功能范围

| 功能点 | 优先级 | 说明 |
|--------|--------|------|
| 心情打卡 | P0 | 记录当日心情类型与分值 |
| 心情时间线 | P0 | 展示历史心情记录 |
| 心情编辑 | P1 | 修改已发布心情 |
| 心情趋势 | P2 | 简单趋势图表 |
| 伴侣可见控制 | P0 | 控制心情对伴侣可见性 |

### 6.2 数据模型

#### MoodRecord（心情记录）

```dart
class MoodRecord {
  String objectId;           // 主键
  String relationId;         // 情侣关系 ID
  String userId;             // 发布用户 ID
  String moodType;           // happy / excited / calm / worried / sad / angry
  int moodScore;             // 心情分值 1-5
  String? content;           // 心情文案
  List<String> imageUrls;    // 配图列表
  bool visibleToPartner;     // 伴侣是否可见
  DateTime recordDate;       // 记录日期
  DateTime createdAt;        // 创建时间
  DateTime updatedAt;        // 更新时间
}
```

### 6.3 服务层设计

#### MoodService

```dart
class MoodService {
  // 获取心情时间线
  Future<List<MoodRecord>> getMoodTimeline({
    required String relationId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  });

  // 获取单日心情
  Future<MoodRecord?> getMoodByDate(String relationId, DateTime date);

  // 发布心情
  Future<MoodRecord> createMoodRecord({
    required String relationId,
    required String moodType,
    required int moodScore,
    String? content,
    List<String>? imageUrls,
    bool visibleToPartner = true,
  });

  // 更新心情
  Future<MoodRecord> updateMoodRecord(String id, Map<String, dynamic> updates);

  // 获取心情趋势（近7天/30天）
  Future<List<MoodRecord>> getMoodTrend(String relationId, {int days = 7});

  // 获取心情统计
  Future<Map<String, dynamic>> getMoodStatistics(String relationId);
}
```

### 6.4 界面设计

#### 心情首页（MoodPage）

- 顶部：标题栏"心情"
- 今日心情卡片
  - 心情表情大图标
  - 心情分值
  - 文案预览
  - 编辑按钮
- 历史心情时间线
  - 日期分组
  - 心情卡片列表（双方心情）
  - 可见性标识

#### 心情打卡页（MoodCheckinPage）

- 心情选择区：6个表情图标 + 分值滑块
- 文案输入区：placeholder "今天心情怎么样？"
- 配图区：最多3张图片
- 可见性开关："仅自己可见 / 伴侣可见"
- 发布按钮

### 6.5 心情类型映射

| 类型 | 图标 | 分值范围 |
|------|------|----------|
| happy | 😊 | 5 |
| excited | 🤩 | 5 |
| calm | 😌 | 4 |
| worried | 😟 | 3 |
| sad | 😢 | 2 |
| angry | 😠 | 1 |

### 6.6 边界情况处理

| 场景 | 处理方案 |
|------|----------|
| 未填写文案 | 允许仅提交心情类型与分值 |
| 当天重复记录 | 允许多条，列表按时间排序 |
| 图片上传失败 | 降级为纯文字心情 |
| 隐私内容 | 推送摘要不泄露文案内容 |

## 7. 依赖与初始化

### 7.1 pubspec.yaml 依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  dio: ^5.7.0
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2
  flutter_image_compress: ^2.3.0
  table_calendar: ^3.1.2
  photo_view: ^0.15.0
  intl: ^0.19.0
  logger: ^2.4.0
```

### 7.2 模块初始化顺序

```
1. LeanCloud SDK 初始化
2. 全局路由注册
3. 全局状态控制器初始化（UserController, CoupleController）
4. 各业务 Service 实例化
5. 推送服务注册
```

## 8. 路由设计

| 页面 | 路由名称 | 参数 |
|------|----------|------|
| 会话列表 | /chat/list | - |
| 单聊页 | /chat/:relationId | relationId |
| 相册列表 | /album | - |
| 照片预览 | /album/photo/:photoId | photoId |
| 上传照片 | /album/upload | - |
| 纪念日列表 | /anniversary | - |
| 纪念日表单 | /anniversary/form | anniversaryId? |
| 心情首页 | /mood | - |
| 心情打卡 | /mood/checkin | - |

## 9. 数据流与状态管理

### 9.1 全局状态（GetX）

| Controller | 职责 |
|------------|------|
| UserController | 当前用户信息、登录状态 |
| CoupleController | 情侣关系状态、伴侣信息 |
| ChatController | 当前聊天消息、未读数、发送状态 |
| AlbumController | 相册列表、上传进度 |
| AnniversaryController | 纪念日列表、倒计时计算 |
| MoodController | 心情记录、趋势数据 |

### 9.2 页面级状态

- 聊天页：消息列表、输入框内容、发送状态
- 相册页：照片网格、分页状态、筛选条件
- 纪念日：纪念日列表、表单数据
- 心情：心情选择、文案内容、配图列表

## 10. 错误处理

### 10.1 统一错误码

| 错误码 | 说明 | 处理方式 |
|--------|------|----------|
| 1001 | 网络不可用 | 提示并启用本地缓存 |
| 1002 | 请求超时 | 自动重试1次，失败提示 |
| 2001 | Token失效 | 跳转登录页 |
| 2002 | 无情侣关系 | 跳转绑定引导页 |
| 3001 | 上传失败 | 展示重试按钮 |
| 3002 | 消息发送失败 | 展示失败状态与重试 |

### 10.2 全局异常拦截

```dart
// Dio 拦截器统一处理
onError: (error) {
  if (error.response?.statusCode == 401) {
    // Token 失效，跳转登录
    Get.offAllNamed('/login');
  }
  return error;
}
```

## 11. 性能优化建议

| 场景 | 优化方案 |
|------|----------|
| 相册大图加载 | 缩略图 + 懒加载 + 内存缓存 |
| 聊天消息列表 | 分页加载、列表回收 |
| 心情趋势图 | 数据聚合后本地计算 |
| 纪念日倒计时 | 本地计算，不请求接口 |
| 图片压缩 | 上传前压缩，控制尺寸与质量 |

## 12. 测试要点

| 模块 | 测试场景 |
|------|----------|
| 聊天 | 文字发送/接收、图片发送/预览、发送失败重试、已读状态、未读数 |
| 相册 | 上传成功/失败、删除、相册列表加载、相片预览 |
| 纪念日 | 创建/编辑/删除、倒计时计算、重复规则、提醒开关 |
| 心情 | 发布/编辑、可见性控制、时间线展示、配图上传 |
| 全局 | 未登录跳转、情侣关系校验、网络异常处理 |

---

*文档版本：v0.3.0*  
*创建时间：2026-04-28*  
*Phase：Phase 3 - 业务功能*
