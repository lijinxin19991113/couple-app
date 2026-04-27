/// 应用通用常量
class AppConstants {
  AppConstants._();

  // ===== 应用信息 =====
  static const String appName = '情侣日常';
  static const String appVersion = '1.0.0';

  // ===== 存储 Keys =====
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserInfo = 'user_info';
  static const String keyCoupleId = 'couple_id';
  static const String keyLastLoginTime = 'last_login_time';

  // ===== API 配置 =====
  /// LeanCloud App ID
  static const String leancloudAppId = 'YOUR_LEANCLOUD_APP_ID';
  /// LeanCloud App Key
  static const String leancloudAppKey = 'YOUR_LEANCLOUD_APP_KEY';
  /// LeanCloud Server URL
  static const String leancloudServerUrl = 'https://api.leancloud.cn';

  /// API 基础地址
  static const String apiBaseUrl = 'https://api.coupleapp.com/v1';

  /// API 超时时间（毫秒）
  static const int apiTimeout = 30000;

  // ===== 业务常量 =====
  /// 邀请码长度
  static const int inviteCodeLength = 6;

  /// 最大聊天消息长度
  static const int maxMessageLength = 2000;

  /// 最大心情文字长度
  static const int maxMoodContentLength = 500;

  /// 最大日记内容长度
  static const int maxDiaryContentLength = 5000;

  /// 图片压缩质量
  static const int imageQuality = 80;

  /// 最大图片尺寸（像素）
  static const int maxImageSize = 1920;

  // ===== 消息类型 =====
  static const String msgTypeText = 'text';
  static const String msgTypeImage = 'image';
  static const String msgTypeEmoji = 'emoji';
  static const String msgTypeLocation = 'location';
  static const String msgTypeSystem = 'system';

  // ===== 心情类型 =====
  static const String moodHappy = 'happy';
  static const String moodGood = 'good';
  static const String moodNormal = 'normal';
  static const String moodSad = 'sad';
  static const String moodBad = 'bad';

  // ===== 纪念日类型 =====
  static const String anniversaryLove = 'love';
  static const String anniversaryBirthday = 'birthday';
  static const String anniversaryCustom = 'custom';

  // ===== 纪念日重复类型 =====
  static const String repeatNone = 'none';
  static const String repeatYearly = 'yearly';
  static const String repeatMonthly = 'monthly';
}
