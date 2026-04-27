import 'package:get/get.dart';

import '../models/mood_record_model.dart';
import '../services/mood_service.dart';

/// 心情控制器
class MoodController extends GetxController {
  final MoodService _moodService = Get.find<MoodService>();

  /// 心情记录列表
  final RxList<MoodRecord> moodRecords = <MoodRecord>[].obs;

  /// 今日心情
  final Rxn<MoodRecord> todayMood = Rxn<MoodRecord>();

  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 当前关系 ID
  String? _relationId;

  /// 当前用户 ID
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    // 从 UserController 获取用户信息
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userController = Get.find<AuthController>();
      _userId = userController.currentUser.value?.id;
      // TODO: 从 CoupleController 获取 relationId
      _relationId = 'relation_001'; // 模拟
    } catch (e) {
      // 忽略
    }
  }

  /// 加载时间线
  Future<void> loadTimeline() async {
    if (!mounted) return;

    isLoading.value = true;
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));

      final records = await _moodService.getMoodTimeline(
        relationId: _relationId ?? '',
        startDate: startDate,
        endDate: now,
        page: 1,
        pageSize: 20,
      );

      if (mounted) {
        moodRecords.value = records;
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('错误', '加载心情记录失败');
      }
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  /// 检查今日打卡
  Future<void> checkTodayMood() async {
    if (!mounted || _relationId == null) return;

    try {
      final today = DateTime.now();
      final record = await _moodService.getMoodByDate(
        relationId: _relationId!,
        date: today,
      );

      if (mounted) {
        todayMood.value = record;
      }
    } catch (e) {
      // 忽略
    }
  }

  /// 打卡
  Future<void> checkin({
    required MoodType moodType,
    required int moodScore,
    String? content,
    List<String> imageUrls = const [],
    bool visibleToPartner = true,
  }) async {
    if (!mounted || _relationId == null || _userId == null) return;

    isLoading.value = true;
    try {
      final record = await _moodService.createMoodRecord(
        relationId: _relationId!,
        userId: _userId!,
        moodType: moodType,
        moodScore: moodScore,
        content: content,
        imageUrls: imageUrls,
        visibleToPartner: visibleToPartner,
      );

      if (mounted) {
        todayMood.value = record;
        moodRecords.insert(0, record);
        Get.snackbar('成功', '心情打卡完成');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('错误', '打卡失败，请重试');
      }
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  /// 更新心情记录
  Future<void> updateMood({
    required String id,
    MoodType? moodType,
    int? moodScore,
    String? content,
    List<String>? imageUrls,
    bool? visibleToPartner,
  }) async {
    if (!mounted) return;

    isLoading.value = true;
    try {
      final updated = await _moodService.updateMoodRecord(
        id: id,
        moodType: moodType,
        moodScore: moodScore,
        content: content,
        imageUrls: imageUrls,
        visibleToPartner: visibleToPartner,
      );

      if (mounted) {
        // 更新列表中的记录
        final index = moodRecords.indexWhere((r) => r.objectId == id);
        if (index != -1) {
          moodRecords[index] = updated;
        }
        // 更新今日心情
        if (todayMood.value?.objectId == id) {
          todayMood.value = updated;
        }
        Get.snackbar('成功', '更新成功');
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('错误', '更新失败');
      }
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  /// 加载趋势
  Future<Map<String, dynamic>?> loadTrend({int days = 7}) async {
    if (_relationId == null) return null;

    try {
      return await _moodService.getMoodTrend(
        relationId: _relationId!,
        days: days,
      );
    } catch (e) {
      return null;
    }
  }

  /// 加载统计
  Future<Map<String, dynamic>?> loadStatistics() async {
    if (_relationId == null) return null;

    try {
      return await _moodService.getMoodStatistics(
        relationId: _relationId!,
      );
    } catch (e) {
      return null;
    }
  }

  /// 按日期分组的心情记录
  Map<String, List<MoodRecord>> get groupedRecords {
    final grouped = <String, List<MoodRecord>>{};

    for (final record in moodRecords) {
      final key =
          '${record.recordDate.year}-${record.recordDate.month.toString().padLeft(2, '0')}-${record.recordDate.day.toString().padLeft(2, '0')}';

      if (grouped.containsKey(key)) {
        grouped[key]!.add(record);
      } else {
        grouped[key] = [record];
      }
    }

    return grouped;
  }

  /// 获取格式化日期标签
  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return '今天';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}

// 导入 AuthController（避免循环引用，通过 Get.find 获取）
class AuthController extends GetxController {
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
}

class UserModel extends GetxController {
  final String id;
  UserModel({required this.id});
}
