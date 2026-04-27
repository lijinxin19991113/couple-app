# 情侣日常 App 技术方案设计文档

## 1. 文档目标

本文档用于明确情侣日常 App 的整体技术实现方案，作为后续产品研发、任务拆解、接口联调、测试验证和运维扩展的基础参考。项目目标是构建一个面向情侣用户的轻社交陪伴型移动应用，支持聊天、相册、纪念日、位置共享、心情记录、日记、愿望清单等核心能力。

## 2. 技术架构总览

### 2.1 架构原则

- 以 Flutter 作为统一客户端技术栈，覆盖 iOS 与 Android 双端
- 以 LeanCloud BaaS 作为后端核心能力承载，降低自建服务复杂度
- 以模块化设计组织前端代码，便于迭代和多人协作
- 以云函数 + 数据表 + 文件存储实现业务闭环
- 以 SDK 与第三方服务组合满足地图、推送等场景需求

### 2.2 整体架构图说明

```text
Flutter App
  |- 页面层 Pages
  |- 组件层 Widgets
  |- 业务服务层 Services
  |- 数据模型层 Models
  |- 工具层 Utils
        |
        v
LeanCloud BaaS
  |- 用户认证
  |- 数据存储
  |- 文件存储
  |- 云函数
  |- 实时通信/消息能力（可结合业务封装）
        |
        +-- 高德地图 SDK（定位、地图展示、逆地理编码）
        +-- 极光推送（系统通知、消息提醒、事件提醒）
```

## 3. 后端选型设计

## 3.1 选型结论

后端采用 **LeanCloud BaaS** 作为主要服务平台。

## 3.2 选型原因

### 3.2.1 适合项目初期快速落地

- 内置用户体系，减少注册登录与权限体系的重复建设
- 提供结构化数据存储，适合快速搭建业务表模型
- 支持文件存储，便于相册、聊天图片、头像等资源管理
- 支持云函数，可承载轻量业务逻辑与权限校验
- 运维成本较低，适合中小团队快速迭代

### 3.2.2 满足核心业务场景

- 情侣关系绑定、状态同步、消息记录适合结构化管理
- 聊天、纪念日、心情、愿望等功能均可基于表结构快速搭建
- 照片上传可直接走文件服务，减少对象存储接入成本
- 推送提醒、纪念日提醒、伴侣互动提醒可由云函数触发

### 3.2.3 扩展性可接受

- 前期通过 LeanCloud 表结构与云函数承载主要逻辑
- 中后期若高并发聊天、推荐、AI 陪伴等能力增强，可拆分独立服务
- 接口封装在 App 服务层，降低后端替换成本

## 3.3 LeanCloud 职责边界

### 3.3.1 承载内容

- 用户注册与登录
- 用户资料管理
- 情侣关系绑定与状态维护
- 聊天消息持久化
- 相册与文件资源存储
- 纪念日、日记、愿望、心情、位置等结构化数据管理
- 轻量业务校验与通知触发

### 3.3.2 不建议重度承载内容

- 大规模实时聊天分发
- 高复杂度推荐与行为分析
- 大规模地图轨迹计算
- 复杂搜索引擎能力

对于上述扩展场景，建议后续逐步引入独立网关服务、消息服务或检索服务。

## 4. 数据库设计

数据库采用 LeanCloud Class 结构设计。以下为建议的核心表设计。

## 4.1 用户表 `UserProfile`

### 功能定位

存储用户基础资料与应用内展示信息。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| userId | Pointer(_User) | 关联 LeanCloud 用户 |
| nickname | String | 昵称 |
| avatar | File/String | 头像 |
| gender | String | 性别，可选 |
| birthday | Date | 生日，可选 |
| signature | String | 个性签名 |
| deviceId | String | 当前设备标识 |
| jpushRegistrationId | String | 极光推送注册 ID |
| locationPermission | Boolean | 是否授权位置 |
| notificationEnabled | Boolean | 是否开启通知 |
| lastActiveAt | Date | 最近活跃时间 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

### 设计说明

- `_User` 用于认证，`UserProfile` 用于扩展业务资料
- 推送相关字段放在资料表，便于通知绑定与多端控制
- 涉及展示的数据应避免直接依赖 `_User` 原始结构，提升业务可控性

## 4.2 情侣关系表 `CoupleRelation`

### 功能定位

记录情侣绑定关系、状态及关系元信息。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationCode | String | 绑定邀请码/关系码 |
| userA | Pointer(_User) | 用户 A |
| userB | Pointer(_User) | 用户 B |
| anniversaryDate | Date | 恋爱纪念日 |
| status | String | pending/active/unbound |
| backgroundImage | File/String | 关系主页背景图 |
| themeConfig | Object | 主题配置 |
| lastInteractionAt | Date | 最近互动时间 |
| createdBy | Pointer(_User) | 发起人 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

### 设计说明

- 一对情侣只允许存在一个有效 `active` 关系
- 解除绑定建议采用状态变更，避免物理删除导致历史丢失
- 纪念日首页可优先读取该表中的恋爱起始时间

## 4.3 聊天表 `ChatMessage`

### 功能定位

存储情侣双方的聊天消息记录。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| sender | Pointer(_User) | 发送者 |
| receiver | Pointer(_User) | 接收者 |
| messageType | String | text/image/system/location |
| content | String | 文本内容或摘要 |
| mediaFile | File | 图片或附件 |
| extraData | Object | 扩展数据，如图片尺寸、位置卡片 |
| sendStatus | String | sending/sent/failed/read |
| readAt | Date | 已读时间 |
| clientMsgId | String | 客户端幂等 ID |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

### 设计说明

- `clientMsgId` 用于弱网重试去重
- 图片、位置卡片统一通过 `extraData` 扩展，减少频繁改表
- 若未来引入独立 IM，可保留此表作为消息归档

## 4.4 纪念日表 `Anniversary`

### 功能定位

存储情侣共同纪念日与提醒配置。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| title | String | 纪念日名称 |
| date | Date | 纪念日日期 |
| type | String | love/birthday/custom |
| repeatType | String | none/yearly/monthly |
| reminderEnabled | Boolean | 是否提醒 |
| reminderTime | String | 提醒时间 |
| note | String | 备注 |
| createdBy | Pointer(_User) | 创建人 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

## 4.5 相册表 `AlbumPhoto`

### 功能定位

存储情侣共享相册照片信息。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| uploader | Pointer(_User) | 上传者 |
| photoFile | File | 原始照片 |
| thumbnailUrl | String | 缩略图地址 |
| caption | String | 照片文案 |
| shotAt | Date | 拍摄时间 |
| locationText | String | 拍摄地点文本 |
| tags | Array<String> | 标签 |
| visibility | String | both/private |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

### 设计说明

- 缩略图可以在上传后通过云函数或客户端本地生成后上传
- `visibility` 支持个人可见与共享可见两种模式

## 4.6 心情表 `MoodRecord`

### 功能定位

记录用户每日心情状态与伴侣可见内容。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| userId | Pointer(_User) | 发布用户 |
| moodType | String | happy/sad/calm/angry/custom |
| moodScore | Number | 心情分值 1-5 |
| content | String | 心情文案 |
| images | Array<File/String> | 配图 |
| visibleToPartner | Boolean | 伴侣是否可见 |
| recordDate | Date | 记录日期 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

## 4.7 位置表 `LocationRecord`

### 功能定位

存储用户位置更新与共享状态。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| userId | Pointer(_User) | 上传用户 |
| latitude | Number | 纬度 |
| longitude | Number | 经度 |
| accuracy | Number | 精度 |
| address | String | 逆地理解析地址 |
| city | String | 城市 |
| shareStatus | String | on/off/temporary |
| reportedAt | Date | 上报时间 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

### 设计说明

- 默认只展示最新位置，历史轨迹按产品需要决定是否保留
- 若后期增加轨迹功能，建议单独拆分位置轨迹表

## 4.8 日记表 `DiaryEntry`

### 功能定位

记录用户或情侣共同日记。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| author | Pointer(_User) | 作者 |
| title | String | 标题 |
| content | String | 正文 |
| images | Array<File/String> | 插图 |
| weather | String | 天气 |
| moodTag | String | 心情标签 |
| isShared | Boolean | 是否对伴侣可见 |
| diaryDate | Date | 日记日期 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

## 4.9 愿望表 `Wishlist`

### 功能定位

记录情侣共同愿望与完成进度。

### 核心字段

| 字段名 | 类型 | 说明 |
| --- | --- | --- |
| objectId | String | 主键 |
| relationId | Pointer(CoupleRelation) | 归属情侣关系 |
| creator | Pointer(_User) | 创建人 |
| title | String | 愿望标题 |
| description | String | 愿望描述 |
| category | String | travel/date/life/gift/custom |
| targetDate | Date | 目标时间 |
| status | String | todo/doing/done/cancelled |
| priority | Number | 优先级 |
| completedAt | Date | 完成时间 |
| coverImage | File/String | 封面图 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

## 4.10 公共设计约束

- 所有业务表必须关联 `relationId` 或 `userId`，确保数据隔离明确
- 默认采用逻辑权限控制，只允许情侣双方访问共享数据
- 高频查询字段建议建立索引，如 `relationId`、`userId`、`recordDate`、`createdAt`
- 重要删除操作建议使用软删除字段 `isDeleted` 或状态字段替代

## 5. API 架构设计

客户端与 LeanCloud 之间通过 SDK + 云函数结合实现。原则上：

- 通用增删改查优先使用 LeanCloud SDK 封装
- 复杂校验、事务型逻辑、通知触发走云函数
- 客户端仅调用 `services` 层，不直接散落数据库访问逻辑

## 5.1 API 分层设计

### 5.1.1 客户端服务层

- `auth_service`：登录、登出、会话恢复
- `user_service`：资料读取、资料更新、情侣关系信息
- `chat_service`：消息发送、消息查询、已读更新
- `album_service`：照片上传、相册查询、删除管理
- `location_service`：位置上报、当前位置获取、共享状态切换
- `anniversary_service`：纪念日新增、编辑、提醒配置
- `mood_service`：心情发布、查询
- `diary_service`：日记创建、编辑、列表查询
- `wishlist_service`：愿望新增、状态流转

### 5.1.2 云函数层

- 情侣关系绑定校验
- 消息发送后通知触发
- 图片上传后的元数据处理
- 纪念日提醒任务调度
- 位置共享权限校验

## 5.2 核心接口设计

以下接口为逻辑接口定义，实际落地可映射到 LeanCloud SDK 调用与云函数名称。

## 5.2.1 登录相关

### 用户登录

- 接口名称：`login`
- 调用方式：SDK 登录 / 云函数辅助
- 输入参数：手机号/验证码或其他认证凭据、设备信息
- 输出结果：用户会话、用户资料、情侣关系状态、初始化配置

### 自动登录

- 接口名称：`restoreSession`
- 输入参数：本地缓存 session token
- 输出结果：会话有效性、用户资料、首页初始化数据

### 退出登录

- 接口名称：`logout`
- 输入参数：当前用户标识
- 输出结果：会话清理结果

## 5.2.2 情侣关系相关

### 创建绑定邀请码

- 接口名称：`createRelationCode`
- 输入参数：当前用户 ID
- 输出结果：邀请码、过期时间

### 绑定情侣关系

- 接口名称：`bindCoupleRelation`
- 输入参数：邀请码、纪念日起始信息
- 输出结果：关系对象、双方资料摘要

### 查询情侣主页信息

- 接口名称：`getCoupleHome`
- 输入参数：关系 ID
- 输出结果：纪念日倒计时、互动摘要、伴侣资料、最新心情等

## 5.2.3 消息相关

### 获取聊天列表

- 接口名称：`getChatMessages`
- 输入参数：relationId、分页参数、起始时间
- 输出结果：消息列表、分页游标

### 发送文本消息

- 接口名称：`sendTextMessage`
- 输入参数：relationId、clientMsgId、content
- 输出结果：消息对象、发送状态

### 发送图片消息

- 接口名称：`sendImageMessage`
- 输入参数：relationId、clientMsgId、fileId、caption
- 输出结果：消息对象、图片地址、缩略信息

### 更新消息已读状态

- 接口名称：`markMessageRead`
- 输入参数：messageId 或 relationId + lastReadMessageId
- 输出结果：已读更新时间

## 5.2.4 照片上传相关

### 上传照片文件

- 接口名称：`uploadPhoto`
- 输入参数：本地文件、压缩参数、拍摄时间、定位信息
- 输出结果：文件地址、缩略图地址、资源 ID

### 创建相册记录

- 接口名称：`createAlbumPhoto`
- 输入参数：relationId、photoFile、caption、tags、visibility
- 输出结果：相册记录对象

### 获取相册列表

- 接口名称：`getAlbumPhotos`
- 输入参数：relationId、月份筛选、分页参数
- 输出结果：照片列表、分页游标

## 5.2.5 位置更新相关

### 上报实时位置

- 接口名称：`updateLocation`
- 输入参数：relationId、经纬度、精度、地址、shareStatus
- 输出结果：上报结果、最新同步时间

### 获取伴侣最新位置

- 接口名称：`getPartnerLocation`
- 输入参数：relationId
- 输出结果：伴侣位置、更新时间、共享状态

### 切换位置共享状态

- 接口名称：`toggleLocationSharing`
- 输入参数：relationId、status
- 输出结果：更新后的共享状态

## 5.2.6 其他扩展接口

### 纪念日

- `createAnniversary`
- `updateAnniversary`
- `getAnniversaryList`

### 心情

- `createMoodRecord`
- `getMoodTimeline`

### 日记

- `createDiaryEntry`
- `updateDiaryEntry`
- `getDiaryList`

### 愿望

- `createWishlistItem`
- `updateWishlistStatus`
- `getWishlistBoard`

## 5.3 接口安全与权限策略

- 所有接口调用需基于当前登录用户身份执行
- 情侣共享数据必须校验当前用户是否属于对应 `relationId`
- 文件上传后需校验资源归属，防止越权引用
- 消息、位置、日记等敏感内容读取应增加关系校验
- 位置共享支持随时关闭，关闭后接口需返回不可见状态而非历史坐标

## 5.4 异常处理策略

- 统一错误码：参数错误、未登录、无权限、资源不存在、网络异常、服务异常
- 弱网场景下消息发送支持重试与状态回写
- 文件上传失败需返回可读错误，并允许重新上传
- 云函数异常要有兜底提示，避免页面无反馈

## 6. 第三方服务设计

## 6.1 高德地图 SDK

### 使用场景

- 获取当前位置
- 展示伴侣位置地图卡片
- 逆地理编码，将经纬度转换为可读地址
- 位置选择器与地点标注

### 接入建议

- Flutter 端通过高德地图相关插件封装地图页面能力
- 位置更新服务统一经 `location_service` 管理
- 权限申请、GPS 状态、后台定位策略单独封装

### 注意事项

- 位置权限需分级提示，避免首次强制授权影响转化
- 后台持续定位要严格控制频率，降低耗电与隐私风险
- 若用户关闭共享，仅保留状态，不继续上传精确坐标

## 6.2 极光推送

### 使用场景

- 新消息提醒
- 纪念日提醒
- 愿望目标到期提醒
- 伴侣互动提醒，如心情更新、日记分享

### 接入建议

- 登录成功后绑定用户唯一标识与设备注册 ID
- 情侣关系建立后可增加关系标签，便于定向推送
- 推送点击后支持深链跳转至对应页面

### 注意事项

- 推送内容避免暴露隐私全文，通知栏只显示摘要
- 同类通知支持折叠和去重，减少打扰
- 用户关闭通知后需同步服务端状态，避免无效推送

## 7. 非功能设计建议

## 7.1 性能

- 图片上传前本地压缩，减少流量与等待时间
- 相册、聊天、日记列表采用分页加载
- 首页聚合接口返回摘要数据，避免一次性拉全量表

## 7.2 安全与隐私

- 用户隐私数据最小化采集
- 位置数据仅在授权且开启共享时上传
- 聊天、日记、心情等内容展示需严格权限校验
- 账号注销需配套数据清理策略

## 7.3 可维护性

- 业务逻辑集中在服务层与云函数，避免页面层耦合数据细节
- 各表字段命名保持统一，时间字段统一使用 `At` 后缀
- 枚举状态集中维护，避免魔法字符串分散

## 8. 后续演进建议

- 第一阶段：完成登录、情侣绑定、聊天、纪念日、相册、位置基础闭环
- 第二阶段：增强心情、日记、愿望模块，补齐提醒与互动能力
- 第三阶段：评估引入独立 IM、数据分析、AI 陪伴与推荐能力

## 9. 结论

基于 LeanCloud BaaS 的方案适合情侣日常 App 当前阶段快速启动。通过 Flutter + LeanCloud + 高德地图 SDK + 极光推送的组合，可以较低成本搭建双端应用核心能力，并为后续功能扩展和架构演进预留清晰边界。
