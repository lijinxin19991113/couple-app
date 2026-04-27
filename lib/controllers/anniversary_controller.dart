import 'package:get/get.dart';

import '../models/anniversary_model.dart';
import '../services/anniversary_service.dart';

/// 纪念日控制器
class AnniversaryController extends GetxController {
  final AnniversaryService _service = Get.find<AnniversaryService>();

  /// 纪念日列表
  final RxList<AnniversaryModel> anniversaries = <AnniversaryModel>[].obs;

  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 当前关系 ID
  String? _relationId;

  bool get _isAlive => !isClosed;

  @override
  void onInit() {
    super.onInit();
    _loadRelationId();
  }

  /// 加载关系 ID
  Future<void> _loadRelationId() async {
    _relationId = 'relation_001';
    await loadAnniversaries();
  }

  /// 设置关系 ID 并加载数据
  Future<void> setRelationId(String relationId) async {
    _relationId = relationId;
    await loadAnniversaries();
  }

  /// 加载纪念日列表
  Future<void> loadAnniversaries() async {
    if (_relationId == null || !_isAlive) return;

    isLoading.value = true;
    try {
      final list = await _service.getAnniversaryList(relationId: _relationId!);
      if (_isAlive) {
        anniversaries.value = list;
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('提示', '加载纪念日失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 创建纪念日
  Future<bool> createAnniversary({
    required String title,
    required DateTime date,
    required AnniversaryType type,
    required RepeatType repeatType,
    required bool reminderEnabled,
    DateTime? reminderTime,
    String? note,
  }) async {
    if (_relationId == null || !_isAlive) return false;

    try {
      final now = DateTime.now();
      final draft = Anniversary(
        objectId: '',
        relationId: _relationId!,
        title: title,
        date: date,
        type: type,
        repeatType: repeatType,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
        note: note,
        createdBy: 'mock_user_001',
        createdAt: now,
        updatedAt: now,
      );
      final created = await _service.createAnniversary(anniversary: draft);

      if (_isAlive) {
        anniversaries.add(created);
        anniversaries.sort(
          (a, b) => _service.calculateCountdown(a).compareTo(_service.calculateCountdown(b)),
        );
        Get.snackbar('成功', '纪念日已创建');
      }
      return true;
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('提示', '创建失败，请稍后重试');
      }
      return false;
    }
  }

  /// 更新纪念日
  Future<bool> updateAnniversary(String id, Map<String, dynamic> updates) async {
    if (!_isAlive) return false;
    final index = anniversaries.indexWhere((item) => item.objectId == id);
    if (index < 0) return false;

    try {
      final current = anniversaries[index];
      final updatedDraft = current.copyWith(
        title: updates['title'] as String?,
        date: updates['date'] as DateTime?,
        type: updates['type'] as AnniversaryType?,
        repeatType: updates['repeatType'] as AnniversaryRepeatType?,
        reminderEnabled: updates['reminderEnabled'] as bool?,
        reminderTime: updates['reminderTime'] as DateTime?,
        note: updates['note'] as String?,
      );
      final updated = await _service.updateAnniversary(anniversary: updatedDraft);
      if (updated == null) return false;

      if (_isAlive) {
        anniversaries[index] = updated;
        anniversaries.sort(
          (a, b) => _service.calculateCountdown(a).compareTo(_service.calculateCountdown(b)),
        );
        Get.snackbar('成功', '纪念日已更新');
      }
      return true;
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('提示', '更新失败，请稍后重试');
      }
      return false;
    }
  }

  /// 删除纪念日
  Future<bool> deleteAnniversary(String id) async {
    if (!_isAlive) return false;

    try {
      final success = await _service.deleteAnniversary(objectId: id);
      if (success && _isAlive) {
        anniversaries.removeWhere((a) => a.objectId == id);
        Get.snackbar('成功', '纪念日已删除');
        return true;
      }
      return false;
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('提示', '删除失败，请稍后重试');
      }
      return false;
    }
  }
}
