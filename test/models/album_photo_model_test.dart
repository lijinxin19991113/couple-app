import 'package:flutter_test/flutter_test.dart';
import 'package:couple_app/models/album_photo_model.dart';

void main() {
  group('AlbumPhoto', () {
    final testJson = {
      'objectId': 'photo_123',
      'relationId': 'relation_001',
      'uploaderId': 'user_001',
      'photoUrl': 'https://example.com/photo.jpg',
      'thumbnailUrl': 'https://example.com/thumb.jpg',
      'caption': 'Beautiful sunset',
      'shotAt': '2026-04-28T10:00:00.000Z',
      'locationText': 'Paris, France',
      'tags': ['travel', 'romantic', 'sunset'],
      'visibility': 'both',
      'createdAt': '2026-04-28T12:00:00.000Z',
    };

    test('fromJson should correctly parse valid JSON', () {
      final photo = AlbumPhoto.fromJson(testJson);

      expect(photo.objectId, 'photo_123');
      expect(photo.relationId, 'relation_001');
      expect(photo.uploaderId, 'user_001');
      expect(photo.photoUrl, 'https://example.com/photo.jpg');
      expect(photo.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(photo.caption, 'Beautiful sunset');
      expect(photo.locationText, 'Paris, France');
      expect(photo.tags.length, 3);
      expect(photo.visibility, AlbumVisibility.both);
    });

    test('fromJson should handle missing fields with defaults', () {
      final minimalJson = {
        'relationId': 'relation_001',
        'uploaderId': 'user_001',
        'photoUrl': 'https://example.com/photo.jpg',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
      };

      final photo = AlbumPhoto.fromJson(minimalJson);

      expect(photo.objectId, '');
      expect(photo.caption, isNull);
      expect(photo.shotAt, isNull);
      expect(photo.locationText, isNull);
      expect(photo.tags, isEmpty);
      expect(photo.visibility, AlbumVisibility.both);
    });

    test('fromJson should handle id field as fallback for objectId', () {
      final jsonWithId = {
        'id': 'photo_456',
        'relationId': 'relation_001',
        'uploaderId': 'user_001',
        'photoUrl': 'https://example.com/photo.jpg',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
      };

      final photo = AlbumPhoto.fromJson(jsonWithId);

      expect(photo.objectId, 'photo_456');
    });

    test('fromJson should parse tags correctly', () {
      final photo = AlbumPhoto.fromJson(testJson);

      expect(photo.tags, hasLength(3));
      expect(photo.tags, contains('travel'));
      expect(photo.tags, contains('romantic'));
      expect(photo.tags, contains('sunset'));
    });

    test('fromJson should parse shotAt and createdAt correctly', () {
      final photo = AlbumPhoto.fromJson(testJson);

      expect(photo.shotAt?.year, 2026);
      expect(photo.shotAt?.month, 4);
      expect(photo.shotAt?.day, 28);
      expect(photo.createdAt.year, 2026);
    });

    test('toJson should correctly serialize photo', () {
      final photo = AlbumPhoto(
        objectId: 'photo_123',
        relationId: 'relation_001',
        uploaderId: 'user_001',
        photoUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        caption: 'Beautiful sunset',
        locationText: 'Paris, France',
        tags: ['travel', 'romantic'],
        visibility: AlbumVisibility.both,
        createdAt: DateTime.parse('2026-04-28T12:00:00.000Z'),
      );

      final json = photo.toJson();

      expect(json['objectId'], 'photo_123');
      expect(json['photoUrl'], 'https://example.com/photo.jpg');
      expect(json['caption'], 'Beautiful sunset');
      expect(json['tags'], ['travel', 'romantic']);
      expect(json['visibility'], 'both');
    });

    test('copyWith should create a new instance with updated fields', () {
      final original = AlbumPhoto(
        objectId: 'photo_123',
        relationId: 'relation_001',
        uploaderId: 'user_001',
        photoUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        caption: 'Original caption',
        visibility: AlbumVisibility.both,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        caption: 'Updated caption',
        visibility: AlbumVisibility.private,
      );

      expect(updated.caption, 'Updated caption');
      expect(updated.visibility, AlbumVisibility.private);
      expect(original.caption, 'Original caption');
      expect(original.visibility, AlbumVisibility.both);
    });

    test('copyWith should preserve unchanged fields', () {
      final original = AlbumPhoto(
        objectId: 'photo_123',
        relationId: 'relation_001',
        uploaderId: 'user_001',
        photoUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        caption: 'Caption',
        locationText: 'Paris',
        tags: ['travel'],
        visibility: AlbumVisibility.both,
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(caption: 'New caption');

      expect(updated.objectId, original.objectId);
      expect(updated.relationId, original.relationId);
      expect(updated.uploaderId, original.uploaderId);
      expect(updated.photoUrl, original.photoUrl);
      expect(updated.locationText, original.locationText);
      expect(updated.tags, original.tags);
    });
  });

  group('AlbumVisibility', () {
    test('fromString should return correct enum values', () {
      expect(AlbumVisibility.fromString('both'), AlbumVisibility.both);
      expect(AlbumVisibility.fromString('private'), AlbumVisibility.private);
      expect(AlbumVisibility.fromString('unknown'), AlbumVisibility.both);
      expect(AlbumVisibility.fromString(null), AlbumVisibility.both);
    });
  });
}
