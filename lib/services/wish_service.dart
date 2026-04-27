import '../models/wish_item_model.dart';

/// 愿望服务
class WishService {
  /// 模拟数据
  final List<WishItem> _mockData = [];

  WishService() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();
    _mockData.addAll([
      WishItem(
        objectId: 'wish_001',
        relationId: 'relation_001',
        title: '去日本看樱花',
        description: '明年春天一起去日本看樱花，拍照留念',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: now.add(const Duration(days: 180)),
        fulfilledAt: null,
        createdBy: 'user_001',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      WishItem(
        objectId: 'wish_002',
        relationId: 'relation_001',
        title: '吃一顿正宗火锅',
        description: '去成都吃最正宗的麻辣火锅',
        category: WishCategory.food,
        priority: WishPriority.medium,
        status: WishStatus.pending,
        targetDate: now.add(const Duration(days: 60)),
        fulfilledAt: null,
        createdBy: 'user_001',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      WishItem(
        objectId: 'wish_003',
        relationId: 'relation_001',
        title: '送她一束玫瑰',
        description: '纪念日送她一束红玫瑰',
        category: WishCategory.gift,
        priority: WishPriority.high,
        status: WishStatus.fulfilled,
        targetDate: now.subtract(const Duration(days: 5)),
        fulfilledAt: now.subtract(const Duration(days: 5)),
        createdBy: 'user_001',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      WishItem(
        objectId: 'wish_004',
        relationId: 'relation_001',
        title: '一起看日出',
        description: '早起看日出，感受大自然的美好',
        category: WishCategory.travel,
        priority: WishPriority.low,
        status: WishStatus.abandoned,
        targetDate: now.subtract(const Duration(days: 10)),
        fulfilledAt: null,
        createdBy: 'user_002',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      WishItem(
        objectId: 'wish_005',
        relationId: 'relation_001',
        title: '学习制作蛋糕',
        description: '一起学习制作提拉米苏',
        category: WishCategory.other,
        priority: WishPriority.medium,
        status: WishStatus.pending,
        targetDate: null,
        fulfilledAt: null,
        createdBy: 'user_001',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  /// 获取愿望列表
  Future<List<WishItem>> getWishList(String relationId, {WishStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var items = _mockData.where((item) => item.relationId == relationId);
    if (status != null) {
      items = items.where((item) => item.status == status);
    }
    return items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 创建愿望
  Future<WishItem> createWishItem({
    required String relationId,
    required String title,
    String? description,
    required WishCategory category,
    required WishPriority priority,
    DateTime? targetDate,
    required String createdBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final item = WishItem(
      objectId: 'wish_${DateTime.now().millisecondsSinceEpoch}',
      relationId: relationId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: WishStatus.pending,
      targetDate: targetDate,
      fulfilledAt: null,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
    _mockData.insert(0, item);
    return item;
  }

  /// 更新愿望
  Future<WishItem?> updateWishItem(String id, Map<String, dynamic> updates) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockData.indexWhere((item) => item.objectId == id);
    if (index < 0) return null;
    final current = _mockData[index];
    final updated = current.copyWith(
      title: updates['title'] as String?,
      description: updates['description'] as String?,
      category: updates['category'] as WishCategory?,
      priority: updates['priority'] as WishPriority?,
      status: updates['status'] as WishStatus?,
      targetDate: updates['targetDate'] as DateTime?,
      clearTargetDate: updates['clearTargetDate'] as bool? ?? false,
    );
    _mockData[index] = updated;
    return updated;
  }

  /// 实现愿望
  Future<WishItem?> fulfillWishItem(String id) async {
    return updateWishItem(id, {
      'status': WishStatus.fulfilled,
      'fulfilledAt': DateTime.now(),
    });
  }

  /// 放弃愿望
  Future<WishItem?> abandonWishItem(String id) async {
    return updateWishItem(id, {
      'status': WishStatus.abandoned,
    });
  }

  /// 获取分类列表
  List<Map<String, String>> getWishCategories() {
    return WishCategory.values.map((c) => {
      'value': c.name,
      'label': c.label,
      'icon': c.icon,
    }).toList();
  }

  /// 获取优先级列表
  List<Map<String, String>> getWishPriorities() {
    return WishPriority.values.map((p) => {
      'value': p.name,
      'label': p.label,
    }).toList();
  }

  /// 删除愿望
  Future<bool> deleteWishItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockData.removeWhere((item) => item.objectId == id) != null;
  }
}
