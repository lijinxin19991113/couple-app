import 'package:get/get.dart';

import '../models/wish_item_model.dart';
import '../services/wish_service.dart';
import 'user_controller.dart';

/// 愿望控制器
class WishController extends GetxController {
  final WishService _wishService = Get.find<WishService>();

  /// 愿望列表
  final RxList<WishItem> wishItems = <WishItem>[].obs;

  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 筛选状态
  final Rxn<WishStatus> filterStatus = Rxn<WishStatus>();

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
      _userId = userController.currentUser.value?.id ?? 'user_001';
      _relationId = userController.coupleRelation.value?.id ?? 'relation_001';
    } catch (e) {
      _userId = 'user_001';
      _relationId = 'relation_001';
    }
  }

  /// 加载愿望列表
  Future<void> loadWishes() async {
    if (!_isAlive || _relationId == null) return;

    isLoading.value = true;
    try {
      final items = await _wishService.getWishList(_relationId!);
      if (_isAlive) {
        wishItems.value = items;
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '加载愿望清单失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 添加愿望
  Future<void> addWish({
    required String title,
    String? description,
    required WishCategory category,
    required WishPriority priority,
    DateTime? targetDate,
  }) async {
    if (!_isAlive || _relationId == null || _userId == null) return;

    isLoading.value = true;
    try {
      final item = await _wishService.createWishItem(
        relationId: _relationId!,
        title: title,
        description: description,
        category: category,
        priority: priority,
        targetDate: targetDate,
        createdBy: _userId!,
      );
      if (_isAlive) {
        wishItems.insert(0, item);
        Get.snackbar('成功', '愿望已添加');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '添加愿望失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 更新愿望
  Future<void> updateWish({
    required String id,
    String? title,
    String? description,
    WishCategory? category,
    WishPriority? priority,
    DateTime? targetDate,
    bool clearTargetDate = false,
  }) async {
    if (!_isAlive) return;

    final index = wishItems.indexWhere((item) => item.objectId == id);
    if (index < 0) return;

    isLoading.value = true;
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;
      if (priority != null) updates['priority'] = priority;
      if (targetDate != null) updates['targetDate'] = targetDate;
      if (clearTargetDate) updates['clearTargetDate'] = true;

      final updated = await _wishService.updateWishItem(id, updates);
      if (updated != null && _isAlive) {
        wishItems[index] = updated;
        Get.snackbar('成功', '愿望已更新');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '更新愿望失败');
      }
    } finally {
      if (_isAlive) {
        isLoading.value = false;
      }
    }
  }

  /// 实现愿望
  Future<void> fulfillWish(String id) async {
    if (!_isAlive) return;

    final index = wishItems.indexWhere((item) => item.objectId == id);
    if (index < 0) return;

    try {
      final updated = await _wishService.fulfillWishItem(id);
      if (updated != null && _isAlive) {
        wishItems[index] = updated;
        Get.snackbar('恭喜', '愿望已实现！🎉');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '操作失败');
      }
    }
  }

  /// 放弃愿望
  Future<void> abandonWish(String id) async {
    if (!_isAlive) return;

    final index = wishItems.indexWhere((item) => item.objectId == id);
    if (index < 0) return;

    try {
      final updated = await _wishService.abandonWishItem(id);
      if (updated != null && _isAlive) {
        wishItems[index] = updated;
        Get.snackbar('提示', '已放弃该愿望');
      }
    } catch (e) {
      if (_isAlive) {
        Get.snackbar('错误', '操作失败');
      }
    }
  }

  /// 删除愿望
  Future<void> deleteWish(String id) async {
    if (!_isAlive) return;

    final index = wishItems.indexWhere((item) => item.objectId == id);
    if (index < 0) return;

    final removed = wishItems[index];
    wishItems.removeAt(index);

    try {
      await _wishService.deleteWishItem(id);
      if (_isAlive) {
        Get.snackbar('成功', '愿望已删除');
      }
    } catch (e) {
      if (_isAlive) {
        wishItems.insert(index, removed);
        Get.snackbar('错误', '删除失败');
      }
    }
  }

  /// 按分类筛选
  List<WishItem> getItemsByCategory(WishCategory? category) {
    if (category == null) return wishItems.toList();
    return wishItems.where((item) => item.category == category).toList();
  }

  /// 按状态筛选
  List<WishItem> getItemsByStatus(WishStatus? status) {
    if (status == null) return wishItems.toList();
    return wishItems.where((item) => item.status == status).toList();
  }

  /// 获取进行中的愿望
  List<WishItem> get pendingItems =>
      wishItems.where((item) => item.status == WishStatus.pending).toList();

  /// 获取已实现的愿望
  List<WishItem> get fulfilledItems =>
      wishItems.where((item) => item.status == WishStatus.fulfilled).toList();

  /// 获取已放弃的愿望
  List<WishItem> get abandonedItems =>
      wishItems.where((item) => item.status == WishStatus.abandoned).toList();
}
