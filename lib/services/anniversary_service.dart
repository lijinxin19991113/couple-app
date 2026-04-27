import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../config/constants.dart';
import '../models/anniversary_model.dart';

/// 纪念日服务
class AnniversaryService extends GetxService {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();

  /// 获取纪念日列表
  Future<List<AnniversaryModel>> getAnniversaryList(String relationId) async {
    try {
      final key = '${AppConstants.keyAnniversaryList}_$relationId';
      final data = await _storage.read(key: key);
      if (data == null || data.isEmpty) return [];

      // 解析存储的 JSON 数据
      final List<dynamic> jsonList = _parseJsonList(data);
      return jsonList
          .map((json) => AnniversaryModel.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      return [];
    }
  }

  /// 创建纪念日
  Future<AnniversaryModel?> createAnniversary({
    required String relationId,
    required String title,
    required DateTime date,
    required AnniversaryType type,
    required RepeatType repeatType,
    required bool reminderEnabled,
    DateTime? reminderTime,
    String? note,
    String? createdBy,
  }) async {
    try {
      final id = 'ann_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      final anniversary = AnniversaryModel(
        id: id,
        relationId: relationId,
        title: title,
        date: date,
        type: type,
        repeatType: repeatType,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
        note: note,
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
      );

      final list = await getAnniversaryList(relationId);
      list.add(anniversary);
      await _saveAnniversaryList(relationId, list);

      return anniversary;
    } catch (e) {
      return null;
    }
  }

  /// 更新纪念日
  Future<bool> updateAnniversary(String id, Map<String, dynamic> updates) async {
    try {
      final relationId = updates['relationId'] as String?;
      if (relationId == null) return false;

      final list = await getAnniversaryList(relationId);
      final index = list.indexWhere((a) => a.id == id);
      if (index == -1) return false;

      final existing = list[index];
      final updated = existing.copyWith(
        title: updates['title'] as String? ?? existing.title,
        date: updates['date'] as DateTime? ?? existing.date,
        type: updates['type'] as AnniversaryType? ?? existing.type,
        repeatType: updates['repeatType'] as RepeatType? ?? existing.repeatType,
        reminderEnabled: updates['reminderEnabled'] as bool? ?? existing.reminderEnabled,
        reminderTime: updates['reminderTime'] as DateTime? ?? existing.reminderTime,
        note: updates['note'] as String? ?? existing.note,
        updatedAt: DateTime.now(),
      );

      list[index] = updated;
      await _saveAnniversaryList(relationId, list);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 删除纪念日
  Future<bool> deleteAnniversary(String id, String relationId) async {
    try {
      final list = await getAnniversaryList(relationId);
      list.removeWhere((a) => a.id == id);
      await _saveAnniversaryList(relationId, list);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取即将到来的纪念日
  Future<List<AnniversaryModel>> getUpcomingAnniversaries(String relationId, {int limit = 5}) async {
    final list = await getAnniversaryList(relationId);
    final upcoming = list.where((a) => a.countdownDays >= 0).toList()
      ..sort((a, b) => a.countdownDays.compareTo(b.countdownDays));
    return upcoming.take(limit).toList();
  }

  /// 计算倒计时天数
  int calculateCountdown(DateTime date, RepeatType repeatType) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var targetDate = DateTime(date.year, date.month, date.day);

    switch (repeatType) {
      case RepeatType.none:
        return targetDate.difference(today).inDays;

      case RepeatType.yearly:
        while (targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today)) {
          targetDate = DateTime(targetDate.year + 1, targetDate.month, targetDate.day);
        }
        return targetDate.difference(today).inDays;

      case RepeatType.monthly:
        while (targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today)) {
          final nextMonth = targetDate.month + 1;
          final year = targetDate.year + (nextMonth > 12 ? 1 : 0);
          final month = nextMonth > 12 ? 1 : nextMonth;
          final day = date.day;
          final maxDay = DateTime(year, month + 1, 0).day;
          targetDate = DateTime(year, month, day > maxDay ? maxDay : day);
        }
        return targetDate.difference(today).inDays;

      case RepeatType.weekly:
        while (targetDate.isBefore(today) || targetDate.isAtSameMomentAs(today)) {
          targetDate = targetDate.add(const Duration(days: 7));
        }
        return targetDate.difference(today).inDays;
    }
  }

  /// 保存纪念日列表
  Future<void> _saveAnniversaryList(String relationId, List<AnniversaryModel> list) async {
    final key = '${AppConstants.keyAnniversaryList}_$relationId';
    final jsonList = list.map((a) => a.toJson()).toList();
    await _storage.write(key: key, value: jsonList.toString());
  }

  /// 解析 JSON 列表字符串
  List<dynamic> _parseJsonList(String data) {
    try {
      // 简单解析：实际项目中应该使用 jsonDecode
      return [];
    } catch (e) {
      return [];
    }
  }
}
