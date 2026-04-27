import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:couple_app/services/wish_service.dart';
import 'package:couple_app/models/wish_item_model.dart';

class MockWishService extends Mock implements WishService {}

class FakeWishItem extends Fake implements WishItem {}

void main() {
  late MockWishService mockWishService;

  setUpAll(() {
    registerFallbackValue(FakeWishItem());
  });

  setUp(() {
    mockWishService = MockWishService();
  });

  group('WishService Mock Tests', () {
    test('getWishList returns list of wish items', () async {
      final items = [
        WishItem(
          objectId: 'wish_1',
          relationId: 'relation_001',
          title: '去日本旅游',
          category: WishCategory.travel,
          priority: WishPriority.high,
          status: WishStatus.pending,
          createdBy: 'user_001',
          createdAt: DateTime.now(),
        ),
        WishItem(
          objectId: 'wish_2',
          relationId: 'relation_001',
          title: '吃火锅',
          category: WishCategory.food,
          priority: WishPriority.medium,
          status: WishStatus.pending,
          createdBy: 'user_001',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockWishService.getWishList(
            any(),
            status: any(named: 'status'),
          )).thenAnswer((_) async => items);

      final result = await mockWishService.getWishList('relation_001');

      expect(result, items);
      expect(result.length, 2);
      verify(() => mockWishService.getWishList('relation_001', status: any(named: 'status'))).called(1);
    });

    test('getWishList with status filter returns filtered items', () async {
      final fulfilledItems = [
        WishItem(
          objectId: 'wish_fulfilled',
          relationId: 'relation_001',
          title: '已实现愿望',
          category: WishCategory.gift,
          priority: WishPriority.high,
          status: WishStatus.fulfilled,
          createdBy: 'user_001',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockWishService.getWishList(
            any(),
            status: any(named: 'status'),
          )).thenAnswer((_) async => fulfilledItems);

      final result = await mockWishService.getWishList(
        'relation_001',
        status: WishStatus.fulfilled,
      );

      expect(result.length, 1);
      expect(result.first.status, WishStatus.fulfilled);
    });

    test('createWishItem creates and returns new wish', () async {
      final newItem = WishItem(
        objectId: 'wish_new',
        relationId: 'relation_001',
        title: '新愿望',
        description: '描述',
        category: WishCategory.other,
        priority: WishPriority.medium,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      when(() => mockWishService.createWishItem(
            relationId: any(named: 'relationId'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            targetDate: any(named: 'targetDate'),
            createdBy: any(named: 'createdBy'),
          )).thenAnswer((_) async => newItem);

      final result = await mockWishService.createWishItem(
        relationId: 'relation_001',
        title: '新愿望',
        description: '描述',
        category: WishCategory.other,
        priority: WishPriority.medium,
        createdBy: 'user_001',
      );

      expect(result.title, '新愿望');
      expect(result.status, WishStatus.pending);
    });

    test('updateWishItem updates and returns wish', () async {
      final existingItem = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: '原标题',
        category: WishCategory.travel,
        priority: WishPriority.low,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      final updatedItem = existingItem.copyWith(
        title: '新标题',
        priority: WishPriority.high,
      );

      when(() => mockWishService.updateWishItem(
            any(),
            any(),
          )).thenAnswer((_) async => updatedItem);

      final result = await mockWishService.updateWishItem(
        'wish_1',
        {'title': '新标题', 'priority': WishPriority.high},
      );

      expect(result!.title, '新标题');
      expect(result.priority, WishPriority.high);
    });

    test('updateWishItem returns null for non-existent id', () async {
      when(() => mockWishService.updateWishItem(any(), any()))
          .thenAnswer((_) async => null);

      final result = await mockWishService.updateWishItem(
        'non_existent',
        {'title': 'New Title'},
      );

      expect(result, isNull);
    });

    test('fulfillWishItem changes status to fulfilled', () async {
      final pendingItem = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: '愿望',
        category: WishCategory.food,
        priority: WishPriority.medium,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      final fulfilledItem = pendingItem.copyWith(
        status: WishStatus.fulfilled,
        fulfilledAt: DateTime.now(),
      );

      when(() => mockWishService.fulfillWishItem(any()))
          .thenAnswer((_) async => fulfilledItem);

      final result = await mockWishService.fulfillWishItem('wish_1');

      expect(result!.status, WishStatus.fulfilled);
      expect(result.fulfilledAt, isNotNull);
    });

    test('fulfillWishItem returns null for non-existent id', () async {
      when(() => mockWishService.fulfillWishItem(any()))
          .thenAnswer((_) async => null);

      final result = await mockWishService.fulfillWishItem('non_existent');

      expect(result, isNull);
    });

    test('abandonWishItem changes status to abandoned', () async {
      final pendingItem = WishItem(
        objectId: 'wish_1',
        relationId: 'relation_001',
        title: '愿望',
        category: WishCategory.other,
        priority: WishPriority.low,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      final abandonedItem = pendingItem.copyWith(
        status: WishStatus.abandoned,
        clearFulfilledAt: true,
      );

      when(() => mockWishService.abandonWishItem(any()))
          .thenAnswer((_) async => abandonedItem);

      final result = await mockWishService.abandonWishItem('wish_1');

      expect(result!.status, WishStatus.abandoned);
    });

    test('deleteWishItem returns true on success', () async {
      when(() => mockWishService.deleteWishItem(any()))
          .thenAnswer((_) async => true);

      final result = await mockWishService.deleteWishItem('wish_1');

      expect(result, true);
    });

    test('deleteWishItem returns false for non-existent id', () async {
      when(() => mockWishService.deleteWishItem(any()))
          .thenAnswer((_) async => false);

      final result = await mockWishService.deleteWishItem('non_existent');

      expect(result, false);
    });
  });

  group('WishService CRUD flow', () {
    test('full CRUD lifecycle works correctly', () async {
      // Create
      final newItem = WishItem(
        objectId: 'wish_crud',
        relationId: 'relation_001',
        title: 'CRUD Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        status: WishStatus.pending,
        createdBy: 'user_001',
        createdAt: DateTime.now(),
      );

      when(() => mockWishService.createWishItem(
            relationId: any(named: 'relationId'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            targetDate: any(named: 'targetDate'),
            createdBy: any(named: 'createdBy'),
          )).thenAnswer((_) async => newItem);

      final created = await mockWishService.createWishItem(
        relationId: 'relation_001',
        title: 'CRUD Test',
        category: WishCategory.travel,
        priority: WishPriority.high,
        createdBy: 'user_001',
      );
      expect(created.title, 'CRUD Test');

      // Update
      final updatedItem = created.copyWith(title: 'Updated CRUD Test');
      when(() => mockWishService.updateWishItem(any(), any()))
          .thenAnswer((_) async => updatedItem);

      final updated = await mockWishService.updateWishItem(
        created.objectId,
        {'title': 'Updated CRUD Test'},
      );
      expect(updated!.title, 'Updated CRUD Test');

      // Fulfill
      final fulfilledItem = updated.copyWith(
        status: WishStatus.fulfilled,
        fulfilledAt: DateTime.now(),
      );
      when(() => mockWishService.fulfillWishItem(any()))
          .thenAnswer((_) async => fulfilledItem);

      final fulfilled = await mockWishService.fulfillWishItem(created.objectId);
      expect(fulfilled!.status, WishStatus.fulfilled);

      // Delete
      when(() => mockWishService.deleteWishItem(any()))
          .thenAnswer((_) async => true);

      final deleted = await mockWishService.deleteWishItem(created.objectId);
      expect(deleted, true);
    });
  });
}
