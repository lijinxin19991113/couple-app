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

  @override
  void onInit() {
    super.onInit();
    // 尝试从 UserController 获取 relationId
    _loadRelationId();
  }

  /// 加载关系 ID
  Future<void> _loadRelationId() async {
    // TODO: 从 UserController 获取当前关系 ID
    // final userController = Get.find<UserController>();
    // _relationId = userController.currentRelation.value?.id;
    // if (_relationId != null) {
    //   await loadAnniversaries();
    // }
  }

  /// 设置关系 ID 并加载数据
  Future<void> setRelationId(String relationId) async {
    _relationId = relationId;
    await loadAnniversaries();
  }

  /// 加载纪念日列表
  Future<void> loadAnniversaries() async {
    if (_relationId == null) return;
    if (!isMounted) return;

    isLoading.value = true;
    try {
      final list = await _service.getAnniversaryList(_relationId!);
      if (isMounted) {
        anniversaries.value = list;
      }
    } catch (e) {
      if (isMounted) {
        Get.snackbar('提示', '加载纪念日失败');
      }
    } finally {
      if (isMounted) {
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
    if (_relationId == null) return false;
    if (!isMounted) return false;

    try {
      final anniversary = await _service.createAnniversary(
        relationId: _relationId!,
        title: title,
        date: date,
        type: type,
        repeatType: repeatType,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
        note: note,
      );

      if (anniversary != null && isMounted) {
        anniversaries.add(anniversary);
        anniversaries.sort((a, b) => a.date.compareTo(b.date));
        Get.snackbar('成功', '纪念日已创建');
        return true;
      }
      return false;
    } catch (e) {
      if (isMounted) {
        Get.snackbar('提示', '创建失败，请稍后重试');
      }
      return false;
    }
  }

  /// 更新纪念日
  Future<bool> updateAnniversary(String id, Map<String, dynamic> updates) async {
    if (!isMounted) return false;

    try {
      final success = await _service.updateAnniversary(id, updates);
      if (success && isMounted) {
        await loadAnniversaries();
        Get.snackbar('成功', '纪念日已更新');
        return true;
      }
      return false;
    } catch (e) {
      if (isMounted) {
        Get.snackbar('提示', '更新失败，请稍后重试');
      }
      return false;
    }
  }

  /// 删除纪念日
  Future<bool> deleteAnniversary(String id) async {
    if (_relationId == null) return false;
    if (!isMounted) return false;

    try {
      final success = await _service.deleteAnniversary(id, _relationId!);
      if (success && isMounted) {
        anniversaries.removeWhere((a) => a.id == id);
        Get.snackbar('成功', '纪念日已删除');
        return true;
      }
      return false;
    } catch (e) {
      if (isMounted) {
        Get.snackbar('提示', '删除失败，请稍后重试');
      }
      return false;
    }
  }
}
