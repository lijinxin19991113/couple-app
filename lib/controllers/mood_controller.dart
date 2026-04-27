import 'package:get/get.dart';

import '../models/mood_record_model.dart';
import '../services/mood_service.dart';
import 'user_controller.dart';

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

  bool get _isAlive => !isClosed;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userController = Get.find<UserController>();
      _userId = userController.currentUser.value?.id ?? 'mock_user_001';
      _relationId = userController.coupleRelation.value?.id ?? 'relation_001';
    } catch (e) {
      _userId = 'mock_user_001';
      _relationId = 'relation_001';
    }
  }

  /// 加载时间线
  Future<void> loadTimeline() async {
    if (!_isAlive || _relationId == null) return;

    isLoading.value = true;
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));

      final records = await _moodService.getMoodTimeline(
        relationId: _relationId!,
        start: startDate,
        end: now,
      );

      if (_isAlive) {
        moodRecords.value = records;
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '加载心情记录失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 检查今日打卡
  Future<void> checkTodayMood() async {
    if (!_isAlive || _relationId == null) return;

    try {
      final today = DateTime.now();
      final record = await _moodService.getMoodByDate(
        relationId: _relationId!,
        date: today,
        userId: _userId,
      );

      if (_isAlive) {
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
    List<String> imageUrls = const <String>[],
    bool visibleToPartner = true,
  }) async {
    if (!_isAlive || _relationId == null || _userId == null) return;

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

      if (_isAlive) {
        todayMood.value = record;
        moodRecords.removeWhere((item) => item.objectId == record.objectId);
        moodRecords.insert(0, record);
        Get.snackbar('成功', '心情打卡完成');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '打卡失败，请重试');
      }
    } finally {
      if (_isAlive) {
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
    if (!_isAlive) return;
    final index = moodRecords.indexWhere((record) => record.objectId == id);
    if (index < 0) return;

    isLoading.value = true;
    try {
      final current = moodRecords[index];
      final updatedDraft = current.copyWith(
        moodType: moodType,
        moodScore: moodScore,
        content: content,
        imageUrls: imageUrls,
        visibleToPartner: visibleToPartner,
      );
      final updated = await _moodService.updateMoodRecord(record: updatedDraft);
      if (updated == null) {
        throw Exception('update failed');
      }

      if (_isAlive) {
        moodRecords[index] = updated;
        if (todayMood.value?.objectId == id) {
          todayMood.value = updated;
        }
        Get.snackbar('成功', '更新成功');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '更新失败');
      }
    } finally {
      if (_isAlive) {
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
      grouped.putIfAbsent(key, () => <MoodRecord>[]).add(record);
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
    }
    if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天';
    }
    return '${date.month}月${date.day}日';
  }
}
