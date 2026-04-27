# 情侣日常 App 项目目录结构规划

## 1. 文档目标

本文档定义情侣日常 App 基于 Flutter 的标准项目目录结构，用于指导项目初始化、模块划分、代码组织和多人协作。目录设计目标是清晰、可维护、易扩展，能够支撑登录、聊天、相册、纪念日、位置、心情、日记、愿望等核心业务模块开发。

## 2. 目录规划原则

- 按职责拆分目录，避免页面、业务、数据、工具混杂
- 优先模块化组织，保证公共能力可复用
- 页面与组件分层明确，便于维护 UI 与业务边界
- 服务层统一封装后端、缓存、定位、推送等调用逻辑
- 模型层统一管理实体对象与序列化逻辑

## 3. Flutter 标准目录结构

```text
couple_app/
├── android/                    # Android 原生工程
├── ios/                        # iOS 原生工程
├── assets/                     # 静态资源目录
│   ├── images/                 # 图片资源
│   ├── icons/                  # 图标资源
│   ├── animations/             # 动画资源，如 Lottie
│   └── fonts/                  # 字体资源
├── docs/                       # 项目文档
├── lib/                        # Flutter 核心代码目录
│   ├── app/                    # 应用级配置与启动相关代码
│   ├── config/                 # 环境配置、常量配置、主题配置
│   ├── routes/                 # 路由定义与页面跳转管理
│   ├── pages/                  # 页面目录，按业务模块拆分
│   ├── widgets/                # 全局通用组件
│   ├── services/               # 服务层，封装接口与系统能力
│   ├── models/                 # 数据模型层
│   ├── repositories/           # 数据仓库层，可选，用于组织数据来源
│   ├── state/                  # 状态管理层
│   ├── utils/                  # 工具类
│   ├── mixins/                 # 通用混入逻辑
│   ├── extensions/             # 扩展方法
│   ├── generated/              # 自动生成代码
│   └── main.dart               # 应用入口
├── test/                       # 单元测试与组件测试
├── integration_test/           # 集成测试
├── pubspec.yaml                # Flutter 依赖配置
├── analysis_options.yaml       # Dart 静态检查配置
└── README.md                   # 项目说明
```

## 4. 核心目录详细说明

## 4.1 `lib/app`

用于存放应用启动相关逻辑和全局装配代码。

建议内容：

- `app.dart`：根组件
- `bootstrap.dart`：应用初始化流程，如 LeanCloud、推送、日志、定位服务初始化
- `app_lifecycle.dart`：应用生命周期监听与处理
- `dependency_injection.dart`：依赖注入配置

作用说明：

- 将应用启动逻辑从 `main.dart` 中拆出，保持入口清晰
- 集中管理全局服务初始化顺序

## 4.2 `lib/config`

用于存放项目配置类和全局常量。

建议内容：

- `env_config.dart`：环境变量配置，如测试/生产环境
- `app_constants.dart`：业务常量、表名、缓存键名
- `theme_config.dart`：颜色、字体、间距、组件主题
- `api_constants.dart`：云函数名称、接口常量

作用说明：

- 避免硬编码散落在业务代码中
- 提升环境切换和统一维护能力

## 4.3 `lib/routes`

用于管理页面路由。

建议内容：

- `app_routes.dart`：路由名称常量
- `route_generator.dart`：统一路由分发
- `route_guards.dart`：登录拦截、绑定关系拦截

作用说明：

- 统一管理跳转路径
- 支持登录态检查、页面权限拦截

## 4.4 `lib/pages`

用于存放业务页面，建议按模块拆分子目录。

推荐结构：

```text
lib/pages/
├── auth/                       # 登录注册与资料补全
├── home/                       # 首页/情侣主页
├── chat/                       # 聊天模块
├── anniversary/                # 纪念日模块
├── album/                      # 相册模块
├── mood/                       # 心情模块
├── location/                   # 位置共享模块
├── diary/                      # 日记模块
├── wishlist/                   # 愿望清单模块
├── profile/                    # 我的/设置模块
└── common/                     # 通用业务页面，如 WebView、选择器页
```

每个模块下建议进一步拆分：

- 页面主文件：如 `chat_page.dart`
- 子页面：如 `chat_detail_page.dart`
- 局部组件：如 `widgets/`
- 页面控制器或状态：如 `controller/` 或 `view_model/`

作用说明：

- 页面按业务聚合，减少跨目录跳转成本
- 模块内部可独立演进，提高协作效率

## 4.5 `lib/widgets`

用于存放全局可复用 UI 组件。

建议内容：

- `common_app_bar.dart`
- `primary_button.dart`
- `empty_view.dart`
- `network_image_view.dart`
- `loading_overlay.dart`
- `confirm_dialog.dart`

作用说明：

- 将全局统一样式组件沉淀为标准组件
- 降低重复开发成本，统一交互风格

## 4.6 `lib/services`

用于封装所有外部服务调用与业务服务逻辑，是页面层调用数据能力的唯一入口。

推荐结构：

```text
lib/services/
├── auth/
│   └── auth_service.dart
├── user/
│   └── user_service.dart
├── couple/
│   └── couple_service.dart
├── chat/
│   └── chat_service.dart
├── anniversary/
│   └── anniversary_service.dart
├── album/
│   └── album_service.dart
├── mood/
│   └── mood_service.dart
├── location/
│   └── location_service.dart
├── diary/
│   └── diary_service.dart
├── wishlist/
│   └── wishlist_service.dart
├── push/
│   └── push_service.dart
├── storage/
│   └── local_storage_service.dart
└── network/
    └── leancloud_service.dart
```

作用说明：

- 封装 LeanCloud SDK、文件上传、推送绑定、地图定位等能力
- 将页面与具体第三方实现隔离，便于替换和测试

## 4.7 `lib/models`

用于定义数据实体对象、枚举、序列化映射。

推荐结构：

```text
lib/models/
├── user/
├── couple/
├── chat/
├── anniversary/
├── album/
├── mood/
├── location/
├── diary/
└── wishlist/
```

每个子目录建议包含：

- 实体类：如 `chat_message_model.dart`
- 枚举类：如 `message_type.dart`
- 转换器：如 `chat_message_mapper.dart`

作用说明：

- 明确页面层与后端数据结构之间的映射关系
- 降低动态数据处理出错概率

## 4.8 `lib/repositories`

该层为可选，但推荐保留，用于管理多数据源组合逻辑。

建议职责：

- 组合远程数据与本地缓存
- 向状态层输出统一数据结构
- 管理分页、缓存更新、离线回填逻辑

示例：

- `chat_repository.dart`
- `album_repository.dart`
- `location_repository.dart`

## 4.9 `lib/state`

用于存放状态管理相关代码，可根据团队选择 Provider、Riverpod、Bloc 等方案实现。

推荐结构：

```text
lib/state/
├── auth/
├── home/
├── chat/
├── anniversary/
├── album/
├── mood/
├── location/
├── diary/
└── wishlist/
```

作用说明：

- 将状态与页面解耦
- 统一管理加载、空态、错误态、表单态

## 4.10 `lib/utils`

用于存放项目级工具方法。

建议内容：

- `date_utils.dart`：日期格式化、倒计时计算
- `image_utils.dart`：图片压缩、尺寸处理
- `permission_utils.dart`：权限检查与请求
- `toast_utils.dart`：提示封装
- `validator_utils.dart`：表单校验
- `logger.dart`：日志工具

作用说明：

- 提升通用能力复用率
- 避免杂项逻辑进入页面与服务层

## 4.11 `lib/mixins`

用于管理可复用的页面行为逻辑。

建议内容：

- 页面生命周期处理
- 列表分页能力
- 表单保存防重复提交

## 4.12 `lib/extensions`

用于对基础类型和对象做扩展。

建议内容：

- `date_time_extension.dart`
- `string_extension.dart`
- `build_context_extension.dart`

## 4.13 `lib/generated`

用于放置自动生成的代码。

建议内容：

- JSON 序列化生成文件
- 国际化生成文件
- 路由或资源索引生成文件

注意事项：

- 不应手动修改该目录内容
- 应通过构建脚本统一生成

## 5. 资源目录规划

## 5.1 `assets/images`

用于放业务图片资源：

- 启动页插画
- 空状态插画
- 默认头像
- 模块背景图

## 5.2 `assets/icons`

用于存放功能图标与 tab 图标。

## 5.3 `assets/animations`

用于存放 Lottie 动画、加载动画等。

## 5.4 `assets/fonts`

用于管理项目自定义字体，建议通过 `pubspec.yaml` 统一声明。

## 6. 测试目录规划

## 6.1 `test`

用于单元测试、Widget 测试。

建议内容：

- 工具类测试
- 服务层测试
- 状态管理测试
- 页面组件测试

## 6.2 `integration_test`

用于关键链路集成测试。

建议优先覆盖：

- 登录流程
- 情侣绑定流程
- 聊天发送流程
- 相册上传流程
- 位置共享开关流程

## 7. 推荐模块映射关系

| 业务模块 | 页面目录 | 服务目录 | 模型目录 | 状态目录 |
| --- | --- | --- | --- | --- |
| 登录与资料 | `lib/pages/auth` | `lib/services/auth`、`lib/services/user` | `lib/models/user` | `lib/state/auth` |
| 情侣关系 | `lib/pages/home` | `lib/services/couple` | `lib/models/couple` | `lib/state/home` |
| 聊天 | `lib/pages/chat` | `lib/services/chat` | `lib/models/chat` | `lib/state/chat` |
| 纪念日 | `lib/pages/anniversary` | `lib/services/anniversary` | `lib/models/anniversary` | `lib/state/anniversary` |
| 相册 | `lib/pages/album` | `lib/services/album` | `lib/models/album` | `lib/state/album` |
| 心情 | `lib/pages/mood` | `lib/services/mood` | `lib/models/mood` | `lib/state/mood` |
| 位置 | `lib/pages/location` | `lib/services/location` | `lib/models/location` | `lib/state/location` |
| 日记 | `lib/pages/diary` | `lib/services/diary` | `lib/models/diary` | `lib/state/diary` |
| 愿望 | `lib/pages/wishlist` | `lib/services/wishlist` | `lib/models/wishlist` | `lib/state/wishlist` |

## 8. 初始化阶段建议落地结构

项目初期建议优先完成以下目录创建：

```text
lib/
├── app/
├── config/
├── routes/
├── pages/
├── widgets/
├── services/
├── models/
├── state/
└── utils/
```

原因如下：

- 足以支撑 MVP 开发
- 目录不宜在初期过度复杂化
- 后续再按实际需求补充 `repositories`、`mixins`、`extensions`、`generated`

## 9. 开发规范建议

- 页面文件命名使用 `xxx_page.dart`
- 组件文件命名使用 `xxx_widget.dart`
- 服务文件命名使用 `xxx_service.dart`
- 模型文件命名使用 `xxx_model.dart`
- 状态文件命名使用 `xxx_provider.dart`、`xxx_bloc.dart` 或 `xxx_controller.dart`
- 一个文件尽量聚焦单一职责，避免超大文件

## 10. 结论

该目录结构遵循 Flutter 常见工程实践，并针对情侣日常 App 的业务特性进行了模块化强化。按照该规划实施，可有效支持前期快速开发与后期持续扩展，也便于架构治理、测试覆盖和多人协作。
