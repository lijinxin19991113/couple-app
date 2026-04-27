import '../models/album_photo_model.dart';

/// 相册服务（当前为 Mock）
class AlbumService {
  final List<AlbumPhoto> _photoStore = <AlbumPhoto>[
    AlbumPhoto(
      objectId: 'photo_1',
      relationId: 'relation_001',
      uploaderId: 'mock_user_001',
      photoUrl:
          'https://images.unsplash.com/photo-1496843916299-590492c751f4?auto=format&fit=crop&w=1200&q=80',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1496843916299-590492c751f4?auto=format&fit=crop&w=400&q=80',
      caption: '周末去海边拍到的夕阳',
      shotAt: DateTime(2026, 4, 13, 17, 48),
      locationText: '青岛 · 石老人海水浴场',
      tags: <String>['旅行', '海边'],
      visibility: AlbumVisibility.both,
      createdAt: DateTime(2026, 4, 13, 18, 10),
    ),
    AlbumPhoto(
      objectId: 'photo_2',
      relationId: 'relation_001',
      uploaderId: 'user_partner',
      photoUrl:
          'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=1200&q=80',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=400&q=80',
      caption: '第一次做蛋糕居然成功了',
      shotAt: DateTime(2026, 3, 22, 14, 9),
      locationText: '家里厨房',
      tags: <String>['日常', '美食'],
      visibility: AlbumVisibility.both,
      createdAt: DateTime(2026, 3, 22, 14, 30),
    ),
  ];

  Future<List<AlbumPhoto>> getAlbumPhotos({required String relationId}) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final list = _photoStore.where((item) => item.relationId == relationId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<AlbumPhoto> uploadPhoto({
    required String relationId,
    required String uploaderId,
    required String localPath,
    String? caption,
    List<String> tags = const <String>[],
    AlbumVisibility visibility = AlbumVisibility.both,
    DateTime? shotAt,
    String? locationText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();

    final photo = AlbumPhoto(
      objectId: 'photo_${now.millisecondsSinceEpoch}',
      relationId: relationId,
      uploaderId: uploaderId,
      photoUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=1200&q=80',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=400&q=80',
      caption: caption,
      shotAt: shotAt ?? now,
      locationText: locationText,
      tags: tags,
      visibility: visibility,
      createdAt: now,
    );

    _photoStore.insert(0, photo);
    return photo;
  }

  Future<AlbumPhoto?> getPhotoDetail({required String photoId}) async {
    await Future.delayed(const Duration(milliseconds: 180));
    try {
      return _photoStore.firstWhere((item) => item.objectId == photoId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deletePhoto({required String photoId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _photoStore.indexWhere((item) => item.objectId == photoId);
    if (index < 0) {
      return false;
    }
    _photoStore.removeAt(index);
    return true;
  }

  Future<AlbumPhoto?> updatePhotoCaption({
    required String photoId,
    required String caption,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final index = _photoStore.indexWhere((item) => item.objectId == photoId);
    if (index < 0) {
      return null;
    }
    final updated = _photoStore[index].copyWith(caption: caption);
    _photoStore[index] = updated;
    return updated;
  }
}
