import 'package:get/get.dart';
import '../models/anniversary_model.dart';
import '../services/anniversary_reminder_service.dart';
import '../services/anniversary_service.dart';

/// 纪念日提醒控制器
class AnniversaryReminderController extends GetxController {
  AnniversaryReminderController._();

  static final AnniversaryReminderController _instance = AnniversaryReminderController._();
  static AnniversaryReminderController get instance => _instance;

  final AnniversaryReminderService _reminderService = AnniversaryReminderService.instance;

  // ===== 响应式状态 =====
  /// 即将到来的纪念日列表
  final upcomingAnniversaries = <Anniversary>[].obs;

  /// 今天的提醒（如果有的话）
  final todayReminder = Rxn<Anniversary>();

  /// 全局通知开关
  final isNotificationEnabled = true.obs;

  /// 提前提醒天数选择
  final advanceDays = 1.obs;

  /// 提醒时间（小时）
  final reminderHour = 9.obs;

  /// 提醒时间（分钟）
  final reminderMinute = 0.obs;

  /// 是否正在加载
  final isLoading = false.obs;

  // ===== 私有变量 =====
  bool _isAlive = true;

  // ===== 生命周期 =====
  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  @override
  void onClose() {
    _isAlive = false;
    super.onClose();
  }

  /// 初始化服务
  Future<void> _initService() async {
    try {
      await _reminderService.initialize();
      await loadUpcoming();
    } catch (e) {
      // 忽略初始化错误
    }
  }

  // ===== 公开方法 =====

  /// 加载即将到来的纪念日
  Future<void> loadUpcoming() async {
    if (!_isAlive) return;

    try {
      isLoading.value = true;

      // 获取关系 ID（这里使用模拟的 relationId）
      const relationId = 'relation_001';

      // 获取即将到来的纪念日
      final upcoming = await _reminderService.getUpcomingReminders(relationId, 30);

      // 如果 AnniversaryService 可用，获取完整的纪念日列表
      if (Get.isRegistered<AnniversaryService>()) {
        final service = Get.find<AnniversaryService>();
        final anniversaries = await service.getUpcomingAnniversaries(
          relationId: relationId,
          withinDays: 30,
        );

        if (_isAlive) {
          upcomingAnniversaries.value = anniversaries;

          // 检查今天是否有纪念日
          _checkTodayReminder(anniversaries);
        }
      }

      if (_isAlive) {
        isLoading.value = false;
      }
    } catch (e) {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 检查今天的纪念日
  void _checkTodayReminder(List<Anniversary> anniversaries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      for (final anniversary in anniversaries) {
        DateTime targetDate;

        switch (anniversary.repeatType) {
          case AnniversaryRepeatType.yearly:
            targetDate = DateTime(today.year, anniversary.date.month, anniversary.date.day);
            break;
          case AnniversaryRepeatType.monthly:
            targetDate = DateTime(today.year, today.month, anniversary.date.day);
            break;
          case AnniversaryRepeatType.weekly:
            // 计算本周的同一天
            final weekday = anniversary.date.weekday;
            targetDate = today.subtract(Duration(days: today.weekday - weekday));
            break;
          case AnniversaryRepeatType.none:
          default:
            targetDate = DateTime(
              anniversary.date.year,
              anniversary.date.month,
              anniversary.date.day,
            );
        }

        if (targetDate == today) {
          todayReminder.value = anniversary;
          break;
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 启用通知
  Future<void> enableNotification() async {
    try {
      final granted = await _reminderService.requestPermissions();
      if (granted && _isAlive) {
        isNotificationEnabled.value = true;
        await scheduleAllReminders();
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 禁用通知
  Future<void> disableNotification() async {
    try {
      await _reminderService.cancelAllReminders();
      if (_isAlive) {
        isNotificationEnabled.value = false;
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 切换通知开关
  Future<void> toggleNotification(bool enabled) async {
    if (enabled) {
      await enableNotification();
    } else {
      await disableNotification();
    }
  }

  /// 为单个纪念日安排提醒
  Future<bool> scheduleReminderFor(Anniversary anniversary) async {
    try {
      if (!isNotificationEnabled.value) return false;
      if (!anniversary.reminderEnabled) return false;

      final reminderTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        reminderHour.value,
        reminderMinute.value,
      );

      return await _reminderService.scheduleReminder(
        anniversary,
        reminderTime,
        advanceDays: advanceDays.value,
      );
    } catch (e) {
      return false;
    }
  }

  /// 安排所有纪念日的提醒
  Future<void> scheduleAllReminders() async {
    if (!_isAlive) return;

    try {
      if (!isNotificationEnabled.value) return;

      for (final anniversary in upcomingAnniversaries) {
        if (anniversary.reminderEnabled) {
          await scheduleReminderFor(anniversary);
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 更新提前提醒天数
  Future<void> updateAdvanceDays(int days) async {
    if (!_isAlive) return;

    try {
      advanceDays.value = days;
      await scheduleAllReminders();
    } catch (e) {
      // 忽略错误
    }
  }

  /// 更新提醒时间
  Future<void> updateReminderTime(int hour, int minute) async {
    if (!_isAlive) return;

    try {
      reminderHour.value = hour;
      reminderMinute.value = minute;
      await scheduleAllReminders();
    } catch (e) {
      // 忽略错误
    }
  }

  /// 测试通知
  Future<bool> testNotification() async {
    try {
      return await _reminderService.testNotification();
    } catch (e) {
      return false;
    }
  }

  /// 检查是否有已安排的提醒
  bool hasScheduledReminder(String anniversaryId) {
    return _reminderService.hasScheduledReminder(anniversaryId);
  }

  /// 取消单个纪念日的提醒
  Future<void> cancelReminder(String anniversaryId) async {
    try {
      await _reminderService.cancelReminder(anniversaryId);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取提醒时间字符串
  String get reminderTimeString {
    final hour = reminderHour.value.toString().padLeft(2, '0');
    final minute = reminderMinute.value.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
