import 'package:get/get.dart';

import '../models/diary_entry_model.dart';
import '../services/diary_service.dart';
import 'user_controller.dart';

/// 日记控制器
class DiaryController extends GetxController {
  final DiaryService _diaryService = Get.find<DiaryService>();

  /// 日记列表
  final RxList<DiaryEntry> diaryEntries = <DiaryEntry>[].obs;

  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 选中日期
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  /// 当前月份（用于日历）
  final Rx<DateTime> currentMonth = DateTime.now().obs;

  /// 有日记的日期集合
  final RxSet<DateTime> diaryDates = <DateTime>{}.obs;

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
      final entries = await _diaryService.getDiaryTimeline(
        relationId: _relationId!,
        page: 1,
        pageSize: 50,
      );

      if (_isAlive) {
        diaryEntries.value = entries;
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '加载日记失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 加载指定月份的日记日期
  Future<void> loadDiaryDates() async {
    if (!_isAlive || _relationId == null) return;

    try {
      final dates = await _diaryService.getDiaryDates(
        relationId: _relationId!,
        year: currentMonth.value.year,
        month: currentMonth.value.month,
      );

      if (_isAlive) {
        diaryDates.value = dates;
      }
    } catch (e) {
      // 忽略
    }
  }

  /// 创建日记
  Future<void> createEntry({
    required String title,
    required String content,
    List<String> imageUrls = const <String>[],
    DiaryMoodType moodType = DiaryMoodType.calm,
    WeatherType weather = WeatherType.sunny,
    String? locationText,
    bool isPrivate = false,
    DateTime? recordDate,
  }) async {
    if (!_isAlive || _relationId == null || _userId == null) return;

    isLoading.value = true;
    try {
      final entry = await _diaryService.createDiaryEntry(
        relationId: _relationId!,
        authorId: _userId!,
        title: title,
        content: content,
        imageUrls: imageUrls,
        moodType: moodType,
        weather: weather,
        locationText: locationText,
        isPrivate: isPrivate,
        recordDate: recordDate ?? selectedDate.value,
      );

      if (_isAlive) {
        diaryEntries.insert(0, entry);
        diaryEntries.sort((a, b) => b.recordDate.compareTo(a.recordDate));
        await loadDiaryDates();
        Get.snackbar('成功', '日记已保存');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '保存失败，请重试');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 更新日记
  Future<void> updateEntry({
    required String id,
    String? title,
    String? content,
    List<String>? imageUrls,
    DiaryMoodType? moodType,
    WeatherType? weather,
    String? locationText,
    bool? isPrivate,
  }) async {
    if (!_isAlive) return;

    final index = diaryEntries.indexWhere((entry) => entry.objectId == id);
    if (index < 0) return;

    isLoading.value = true;
    try {
      final updated = await _diaryService.updateDiaryEntry(
        id: id,
        title: title,
        content: content,
        imageUrls: imageUrls,
        moodType: moodType,
        weather: weather,
        locationText: locationText,
        isPrivate: isPrivate,
      );

      if (updated != null && _isAlive) {
        diaryEntries[index] = updated;
        Get.snackbar('成功', '日记已更新');
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

  /// 删除日记
  Future<void> deleteEntry(String id) async {
    if (!_isAlive) return;

    isLoading.value = true;
    try {
      final success = await _diaryService.deleteDiaryEntry(id);
      if (success && _isAlive) {
        diaryEntries.removeWhere((entry) => entry.objectId == id);
        await loadDiaryDates();
        Get.snackbar('成功', '日记已删除');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '删除失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 根据日期获取日记
  Future<void> getByDate(DateTime date) async {
    if (!_isAlive || _relationId == null) return;

    selectedDate.value = date;
    isLoading.value = true;
    try {
      final entries = await _diaryService.getDiaryByDate(
        relationId: _relationId!,
        date: date,
      );

      if (_isAlive) {
        diaryEntries.value = entries;
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '加载日记失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 切换月份
  void changeMonth(int delta) {
    final current = currentMonth.value;
    currentMonth.value = DateTime(current.year, current.month + delta, 1);
    loadDiaryDates();
  }

  /// 选中日期
  void selectDate(DateTime date) {
    selectedDate.value = date;
    getByDate(date);
  }

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    final selected = selectedDate.value;
    return now.year == selected.year && now.month == selected.month && now.day == selected.day;
  }

  /// 是否选中日期有日记
  bool hasDiaryOnSelectedDate() {
    final selected = selectedDate.value;
    return diaryDates.contains(DateTime(selected.year, selected.month, selected.day));
  }

  /// 获取选中日期的日记
  List<DiaryEntry> get selectedDateEntries {
    final selected = selectedDate.value;
    return diaryEntries.where((entry) {
      final day = entry.recordDate;
      return day.year == selected.year && day.month == selected.month && day.day == selected.day;
    }).toList();
  }

  /// 按日期分组
  Map<String, List<DiaryEntry>> get groupedEntries {
    final grouped = <String, List<DiaryEntry>>{};
    for (final entry in diaryEntries) {
      grouped.putIfAbsent(entry.dateKey, () => <DiaryEntry>[]).add(entry);
    }
    return grouped;
  }
}
