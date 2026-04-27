import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/models/wish_item_model.dart';

void main() {
  group('WishItem', () {
    final testJson = {
      'objectId': 'wish_123',
      'relationId': 'relation_001',
      'title': '去日本旅游',
      'description': '计划明年去日本看樱花',
      'category': 'travel',
      'priority': 'high',
      'status': 'pending',
      'targetDate': '2026-12-01T00:00:00.000Z',
      'fulfilledAt': null,
      'createdBy': 'user_001',
      'createdAt': '2026-04-28T10:00:00.000Z',
    };

    test('fromJson should correctly parse valid JSON', () {
      final item = WishItem.fromJson(testJson);

      expect(item.objectId, 'wish_123');
      expect(item.relationId, 'relation_001');
      expect(item.title, '去日本旅游');
      expect(item.description, '计划明年去日本看樱花');
      expect(item.category, WishCategory.travel);
      expect(item.priority, WishPriority.high);
      expect(item.status, WishStatus.pending);
    });

    test('fromJson should handle missing fields with defaults', () {
      final minimalJson = {
        'relationId': 'relation_001',
        'title': 'Test Wish',
        'createdBy': 'user_001',
      };

      final item = WishItem.fromJson(minimalJson);

      expect(item.objectId, '');
      expect(item.description, null);
      expect(item.category, WishCategory.other);
      expect(item.priority, WishPriority.medium);
      expect(item.status, WishStatus.pending);
      expect(item.targetDate, null);
    });

    test('fromJson should handle null targetDate and fulfilledAt', () {
      final item = WishItem.fromJson(testJson);

      expect(item.targetDate, isNull);
      expect(item.fulfilledAt, isNull);
    });

    test('fromJson should parse filled targetDate correctly', () {
      final jsonWithDate = {
        ...testJson,
        'targetDate': '2026-12-01T00:00:00.000Z',
        'fulfilledAt': '2026-05-01T10:00:00.000Z',
      };

      final item = WishItem.fromJson(jsonWithDate);

      expect(item.targetDate, isNotNull);
      expect(item.fulfilledAt, isNotNull);
    });

    test('toJson should correctly serialize item', () {
      final item = WishItem(
        objectId: 'wish_123',
        relationId: 'relation_001',
        title: '去日本旅游',
        description: '计划明年去日本看樱花',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: DateTime.parse('2026-12-01T00:00:00.000Z'),
        createdBy: 'user_001',
        createdAt: DateTime.parse('2026-04-28T10:00:00.000Z'),
      );

      final json = item.toJson();

      expect(json['objectId'], 'wish_123');
      expect(json['title'], '去日本旅游');
      expect(json['category'], 'travel');
      expect(json['priority'], 'high');
      expect(json['status'], 'pending');
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = WishItem(
        objectId: 'wish_123',
        relationId: 'relation_001',
        title: 'Original Title',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        status: WishStatus.fulfilled,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.status, WishStatus.fulfilled);
      expect(original.title, 'Original Title');
      expect(original.status, WishStatus.pending);
    });

    test('copyWith with clearTargetDate should set targetDate to null', () {
      final original = WishItem(
        objectId: 'wish_123',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(clearTargetDate: true);

      expect(updated.targetDate, isNull);
    });

    test('copyWith with clearFulfilledAt should set fulfilledAt to null', () {
      final original = WishItem(
        objectId: 'wish_123',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.fulfilled,
        fulfilledAt: DateTime.now(),
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        status: WishStatus.abandoned,
        clearFulfilledAt: true,
      );

      expect(updated.fulfilledAt, isNull);
    });
  });

  group('WishCategory', () {
    test('fromString should return correct enum values', () {
      expect(WishCategory.fromString('travel'), WishCategory.travel);
      expect(WishCategory.fromString('food'), WishCategory.food);
      expect(WishCategory.fromString('gift'), WishCategory.gift);
      expect(WishCategory.fromString('other'), WishCategory.other);
      expect(WishCategory.fromString('unknown'), WishCategory.other);
    });
  });

  group('WishPriority', () {
    test('fromString should return correct enum values', () {
      expect(WishPriority.fromString('high'), WishPriority.high);
      expect(WishPriority.fromString('medium'), WishPriority.medium);
      expect(WishPriority.fromString('low'), WishPriority.low);
      expect(WishPriority.fromString('unknown'), WishPriority.medium);
    });
  });

  group('WishStatus', () {
    test('fromString should return correct enum values', () {
      expect(WishStatus.fromString('pending'), WishStatus.pending);
      expect(WishStatus.fromString('fulfilled'), WishStatus.fulfilled);
      expect(WishStatus.fromString('abandoned'), WishStatus.abandoned);
      expect(WishStatus.fromString('unknown'), WishStatus.pending);
    });
  });

  group('WishCategoryX extension', () {
    test('label should return Chinese labels', () {
      expect(WishCategory.travel.label, '旅行');
      expect(WishCategory.food.label, '美食');
      expect(WishCategory.gift.label, '礼物');
      expect(WishCategory.other.label, '其他');
    });

    test('icon should return correct emojis', () {
      expect(WishCategory.travel.icon, '✈️');
      expect(WishCategory.food.icon, '🍜');
      expect(WishCategory.gift.icon, '🎁');
      expect(WishCategory.other.icon, '✨');
    });
  });

  group('WishPriorityX extension', () {
    test('label should return Chinese labels', () {
      expect(WishPriority.high.label, '高');
      expect(WishPriority.medium.label, '中');
      expect(WishPriority.low.label, '低');
    });

    test('colorValue should return correct color values', () {
      expect(WishPriority.high.colorValue, 0xFFE53935);
      expect(WishPriority.medium.colorValue, 0xFFFFA726);
      expect(WishPriority.low.colorValue, 0xFF66BB6A);
    });
  });

  group('WishStatusX extension', () {
    test('label should return Chinese labels', () {
      expect(WishStatus.pending.label, '进行中');
      expect(WishStatus.fulfilled.label, '已实现');
      expect(WishStatus.abandoned.label, '已放弃');
    });

    test('colorValue should return correct color values', () {
      expect(WishStatus.pending.colorValue, 0xFF42A5F5);
      expect(WishStatus.fulfilled.colorValue, 0xFF66BB6A);
      expect(WishStatus.abandoned.colorValue, 0xFF9E9E9E);
    });
  });

  group('WishItemX extension', () {
    test('categoryIcon should return category icon', () {
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.categoryIcon, '✈️');
    });

    test('priorityLabel should return priority label', () {
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.priorityLabel, '高');
    });

    test('statusLabel should return status label', () {
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.fulfilled,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.statusLabel, '已实现');
    });

    test('priorityColorValue should return priority color', () {
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.priorityColorValue, 0xFFE53935);
    });

    test('statusColorValue should return status color', () {
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.fulfilled,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.statusColorValue, 0xFF66BB6A);
    });

    test('daysRemaining should return null when targetDate is null', () {
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.daysRemaining, isNull);
    });

    test('daysRemaining should calculate correct days for future targetDate', () {
      final futureDate = DateTime.now().add(const Duration(days: 15));
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: futureDate,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.daysRemaining, 15);
    });

    test('daysRemaining should calculate correct days for past targetDate', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: pastDate,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.daysRemaining, -5);
    });

    test('isOverdue should return true when past targetDate and pending', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: pastDate,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.isOverdue, true);
    });

    test('isOverdue should return false when fulfilled even if past targetDate', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.fulfilled,
        targetDate: pastDate,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.isOverdue, false);
    });

    test('isOverdue should return false when future targetDate and pending', () {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final item = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: 'Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        targetDate: futureDate,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      expect(item.isOverdue, false);
    });
  });
}
