import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/services/wish_service.dart';
import 'package:couple_app/models/wish_item_model.dart';

void main() {
  late WishService wishService;

  setUp(() {
    wishService = WishService();
  });

  group('WishService', () {
    group('getWishList', () {
      test('should return wish items for given relationId', () async {
        final items = await wishService.getWishList('relation_001');

        expect(items, isNotEmpty);
        expect(items.every((item) => item.relationId == 'relation_001'), true);
      });

      test('should filter by status when provided', () async {
        final items = await wishService.getWishList(
          'relation_001',
          status: WishStatus.fulfilled,
        );

        for (final item in items) {
          expect(item.status, WishStatus.fulfilled);
        }
      });

      test('should return items sorted by createdAt descending', () async {
        final items = await wishService.getWishList('relation_001');

        for (var i = 1; i < items.length; i++) {
          expect(
            items[i].createdAt.isBefore(items[i - 1].createdAt) ||
            items[i].createdAt.isAtSameMomentAs(items[i - 1].createdAt),
            true,
          );
        }
      });
    });

    group('createWishItem', () {
      test('should create wish item successfully', () async {
        final item = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Test Wish',
          description: 'Test description',
          category: WishCategory.food,
          priority: WishPriority.high,
          createdBy: 'user_001',
        );

        expect(item.title, 'Test Wish');
        expect(item.description, 'Test description');
        expect(item.category, WishCategory.food);
        expect(item.priority, WishPriority.high);
        expect(item.status, WishStatus.pending);
        expect(item.createdBy, 'user_001');
      });

      test('should create item with target date', () async {
        final targetDate = DateTime.now().add(const Duration(days: 30));
        final item = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Wish with date',
          category: WishCategory.travel,
          priority: WishPriority.medium,
          targetDate: targetDate,
          createdBy: 'user_001',
        );

        expect(item.targetDate, isNotNull);
      });

      test('should set fulfilledAt to null when creating', () async {
        final item = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'New wish',
          category: WishCategory.other,
          priority: WishPriority.low,
          createdBy: 'user_001',
        );

        expect(item.fulfilledAt, isNull);
      });
    });

    group('updateWishItem', () {
      test('should update wish item successfully', () async {
        // Create first
        final created = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Original Title',
          category: WishCategory.travel,
          priority: WishPriority.low,
          createdBy: 'user_001',
        );

        // Update
        final updated = await wishService.updateWishItem(created.objectId, {
          'title': 'Updated Title',
          'priority': WishPriority.high,
        });

        expect(updated, isNotNull);
        expect(updated!.title, 'Updated Title');
        expect(updated.priority, WishPriority.high);
      });

      test('should return null for non-existent id', () async {
        final updated = await wishService.updateWishItem('non_existent_id', {
          'title': 'New Title',
        });

        expect(updated, isNull);
      });

      test('should update status to fulfilled with fulfilledAt', () async {
        final created = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Test wish',
          category: WishCategory.gift,
          priority: WishPriority.medium,
          createdBy: 'user_001',
        );

        final updated = await wishService.updateWishItem(created.objectId, {
          'status': WishStatus.fulfilled,
          'fulfilledAt': DateTime.now(),
        });

        expect(updated!.status, WishStatus.fulfilled);
        expect(updated.fulfilledAt, isNotNull);
      });

      test('should clear targetDate when clearTargetDate is true', () async {
        final created = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Test wish',
          category: WishCategory.travel,
          priority: WishPriority.medium,
          targetDate: DateTime.now().add(const Duration(days: 30)),
          createdBy: 'user_001',
        );

        final updated = await wishService.updateWishItem(created.objectId, {
          'clearTargetDate': true,
        });

        expect(updated!.targetDate, isNull);
      });
    });

    group('fulfillWishItem', () {
      test('should fulfill wish successfully', () async {
        final created = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Wish to fulfill',
          category: WishCategory.food,
          priority: WishPriority.high,
          createdBy: 'user_001',
        );

        final fulfilled = await wishService.fulfillWishItem(created.objectId);

        expect(fulfilled, isNotNull);
        expect(fulfilled!.status, WishStatus.fulfilled);
        expect(fulfilled.fulfilledAt, isNotNull);
      });

      test('should return null for non-existent id', () async {
        final result = await wishService.fulfillWishItem('non_existent_id');

        expect(result, isNull);
      });
    });

    group('abandonWishItem', () {
      test('should abandon wish successfully', () async {
        final created = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Wish to abandon',
          category: WishCategory.other,
          priority: WishPriority.low,
          createdBy: 'user_001',
        );

        final abandoned = await wishService.abandonWishItem(created.objectId);

        expect(abandoned, isNotNull);
        expect(abandoned!.status, WishStatus.abandoned);
      });

      test('should return null for non-existent id', () async {
        final result = await wishService.abandonWishItem('non_existent_id');

        expect(result, isNull);
      });
    });

    group('deleteWishItem', () {
      test('should delete wish item successfully', () async {
        final created = await wishService.createWishItem(
          relationId: 'relation_001',
          title: 'Wish to delete',
          category: WishCategory.gift,
          priority: WishPriority.medium,
          createdBy: 'user_001',
        );

        final result = await wishService.deleteWishItem(created.objectId);

        expect(result, true);
      });

      test('should return false for non-existent id', () async {
        final result = await wishService.deleteWishItem('non_existent_id');

        expect(result, false);
      });
    });

    group('getWishCategories', () {
      test('should return all categories with labels and icons', () {
        final categories = wishService.getWishCategories();

        expect(categories.length, WishCategory.values.length);
        for (final category in categories) {
          expect(category.containsKey('value'), true);
          expect(category.containsKey('label'), true);
          expect(category.containsKey('icon'), true);
        }
      });
    });

    group('getWishPriorities', () {
      test('should return all priorities with labels', () {
        final priorities = wishService.getWishPriorities();

        expect(priorities.length, WishPriority.values.length);
        for (final priority in priorities) {
          expect(priority.containsKey('value'), true);
          expect(priority.containsKey('label'), true);
        }
      });
    });
  });
}
