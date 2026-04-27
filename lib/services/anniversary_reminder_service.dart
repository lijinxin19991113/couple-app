import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/anniversary_model.dart';

/// 纪念日提醒服务
/// 使用 flutter_local_notifications 包进行本地通知（模拟实现）
class AnniversaryReminderService {
  AnniversaryReminderService._();

  static final AnniversaryReminderService _instance = AnniversaryReminderService._();
  static AnniversaryReminderService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 存储已调度的提醒 {anniversaryId: notificationId}
  final Map<String, int> _scheduledNotifications = {};

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// 通知点击回调
  void _onNotificationTapped(NotificationResponse response) {
    // 模拟处理通知点击
    // 可以在这里导航到对应的纪念日详情页
  }

  /// 调度提醒
  /// [anniversary] 纪念日
  /// [reminderTime] 提醒时间（DateTime 包含日期和时间）
  /// [advanceDays] 提前天数（0 表示当天）
  Future<bool> scheduleReminder(
    Anniversary anniversary,
    DateTime reminderTime, {
    int advanceDays = 0,
  }) async {
    try {
      await initialize();

      // 取消已有的提醒
      await cancelReminder(anniversary.objectId);

      // 计算提醒日期
      final targetDate = anniversary.date;
      final scheduledDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // 计算提前提醒的日期
      final actualDate = scheduledDate.subtract(Duration(days: advanceDays));

      // 如果已经过了提醒时间，返回 false
      if (actualDate.isBefore(DateTime.now())) {
        return false;
      }

      // 生成通知 ID
      final notificationId = _generateNotificationId(anniversary.objectId);

      // 构建通知详情
      final androidDetails = AndroidNotificationDetails(
        'anniversary_reminders',
        '纪念日提醒',
        channelDescription: '纪念日提醒通知',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // 构建通知内容
      String title;
      String body;

      if (advanceDays == 0) {
        title = '🎉 今天是好日子！';
        body = '${anniversary.title}就是今天啦！';
      } else {
        title = '⏰ 纪念日提醒';
        body = '${anniversary.title}还有 $advanceDays 天（${_formatDate(targetDate)}）';
      }

      // 调度通知
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(actualDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );

      // 记录已调度的通知
      _scheduledNotifications[anniversary.objectId] = notificationId;

      return true;
    } catch (e) {
      // 模拟实现，忽略错误
      return false;
    }
  }

  /// 取消提醒
  Future<bool> cancelReminder(String anniversaryId) async {
    try {
      final notificationId = _scheduledNotifications[anniversaryId];
      if (notificationId != null) {
        await _notifications.cancel(notificationId);
        _scheduledNotifications.remove(anniversaryId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 取消所有提醒
  Future<bool> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      _scheduledNotifications.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取即将到来的提醒列表
  Future<List<Map<String, dynamic>>> getUpcomingReminders(
    String relationId,
    int days,
  ) async {
    // 模拟实现，返回即将到来的提醒
    // 实际应该从 AnniversaryService 获取数据并计算
    final upcoming = <Map<String, dynamic>>[];

    for (final entry in _scheduledNotifications.entries) {
      upcoming.add({
        'anniversaryId': entry.key,
        'notificationId': entry.value,
      });
    }

    return upcoming;
  }

  /// 检查并发送推送通知（主动检查）
  /// 返回是否发送了通知
  Future<bool> checkAndSendPushNotification(Anniversary anniversary) async {
    try {
      // 检查是否是今天
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(
        anniversary.date.year,
        anniversary.date.month,
        anniversary.date.day,
      );

      if (targetDate == today && anniversary.reminderEnabled) {
        // 今天是好日子，发送通知
        await _showNotification(
          id: _generateNotificationId(anniversary.objectId),
          title: '🎉 今天是好日子！',
          body: '${anniversary.title}就是今天啦！',
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// 显示即时通知
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'anniversary_reminders',
      '纪念日提醒',
      channelDescription: '纪念日提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  /// 生成通知 ID
  int _generateNotificationId(String anniversaryId) {
    return anniversaryId.hashCode.abs() % 2147483647;
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  /// 测试通知
  Future<bool> testNotification() async {
    try {
      await _showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        title: '🧪 测试通知',
        body: '这是一条测试通知，确认提醒功能正常工作！',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 请求通知权限（iOS）
  Future<bool> requestPermissions() async {
    try {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final result = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result ?? false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否有待处理的提醒
  bool hasScheduledReminder(String anniversaryId) {
    return _scheduledNotifications.containsKey(anniversaryId);
  }

  /// 获取所有已调度的提醒数量
  int get scheduledCount => _scheduledNotifications.length;
}
