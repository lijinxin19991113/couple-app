import 'package:get/get.dart';

import '../models/album_photo_model.dart';

/// 相册服务（模拟数据）
class AlbumService extends GetxService {
  /// 模拟照片数据
  final List<AlbumPhotoModel> _mockPhotos = [];

  /// 初始化服务
  Future<AlbumService> init() async {
    // 初始化一些模拟数据
    _initMockData();
    return this;
  }

  /// 初始化模拟数据
  void _initMockData() {
    final now = DateTime.now();
    final mockData = [
      AlbumPhotoModel(
        objectId: 'photo_001',
        relationId: 'relation_001',
        uploaderId: 'user_001',
        uploaderName: '小明',
        photoUrl: 'https://picsum.photos/800/600?random=1',
        thumbnailUrl: 'https://picsum.photos/400/300?random=1',
        caption: '第一次约会，好开心呀！',
        shotAt: now.subtract(const Duration(days: 30)),
        locationText: '上海市外滩',
        tags: ['约会', '外滩', '夜景'],
        visibility: PhotoVisibility.both,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      AlbumPhotoModel(
        objectId: 'photo_002',
        relationId: 'relation_001',
        uploaderId: 'user_002',
        uploaderName: '小红',
        photoUrl: 'https://picsum.photos/800/600?random=2',
        thumbnailUrl: 'https://picsum.photos/400/300?random=2',
        caption: '周末野餐',
        shotAt: now.subtract(const Duration(days: 25)),
        locationText: '世纪公园',
        tags: ['野餐', '周末'],
        visibility: PhotoVisibility.both,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      AlbumPhotoModel(
        objectId: 'photo_003',
        relationId: 'relation_001',
        uploaderId: 'user_001',
        uploaderName: '小明',
        photoUrl: 'https://picsum.photos/800/600?random=3',
        thumbnailUrl: 'https://picsum.photos/400/300?random=3',
        caption: '一起做的晚餐',
        shotAt: now.subtract(const Duration(days: 20)),
        locationText: '家里',
        tags: ['美食', '烹饪'],
        visibility: PhotoVisibility.both,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      AlbumPhotoModel(
        objectId: 'photo_004',
        relationId: 'relation_001',
        uploaderId: 'user_002',
        uploaderName: '小红',
        photoUrl: 'https://picsum.photos/800/600?random=4',
        thumbnailUrl: 'https://picsum.photos/400/300?random=4',
        caption: '纪念日快乐！',
        shotAt: now.subtract(const Duration(days: 15)),
        locationText: '餐厅',
        tags: ['纪念日', '庆祝'],
        visibility: PhotoVisibility.both,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      AlbumPhotoModel(
        objectId: 'photo_005',
        relationId: 'relation_001',
        uploaderId: 'user_001',
        uploaderName: '小明',
        photoUrl: 'https://picsum.photos/800/600?random=5',
        thumbnailUrl: 'https://picsum.photos/400/300?random=5',
        caption: '私人日记',
        shotAt: now.subtract(const Duration(days: 10)),
        locationText: null,
        tags: ['私密'],
        visibility: PhotoVisibility.private,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      AlbumPhotoModel(
        objectId: 'photo_006',
        relationId: 'relation_001',
        uploaderId: 'user_002',
        uploaderName: '小红',
        photoUrl: 'https://picsum.photos/800/600?random=6',
        thumbnailUrl: 'https://picsum.photos/400/300?random=6',
        caption: '一起去旅行',
        shotAt: now.subtract(const Duration(days: 5)),
        locationText: '杭州西湖',
        tags: ['旅行', '西湖'],
        visibility: PhotoVisibility.both,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
    _mockPhotos.addAll(mockData);
  }

  /// 获取相册照片列表（分页）
  Future<List<AlbumPhotoModel>> getAlbumPhotos({
    required String relationId,
    int page = 1,
    int pageSize = 20,
    String? yearMonth,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 过滤情侣关系下的照片
    var photos = _mockPhotos.where((p) => p.relationId == relationId).toList();

    // 按年月筛选
    if (yearMonth != null && yearMonth.isNotEmpty) {
      photos = photos.where((p) {
        if (p.shotAt == null) return false;
        final photoYearMonth =
            '${p.shotAt!.year}-${p.shotAt!.month.toString().padLeft(2, '0')}';
        return photoYearMonth == yearMonth;
      }).toList();
    }

    // 按时间倒序
    photos.sort((a, b) {
      final aTime = a.shotAt ?? a.createdAt;
      final bTime = b.shotAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    // 分页
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= photos.length) return [];
    final endIndex = (startIndex + pageSize).clamp(0, photos.length);

    return photos.sublist(startIndex, endIndex);
  }

  /// 上传照片
  Future<AlbumPhotoModel> uploadPhoto({
    required String relationId,
    required String uploaderId,
    required String uploaderName,
    required String localFilePath,
    String? caption,
    DateTime? shotAt,
    String? locationText,
    List<String> tags = const [],
    PhotoVisibility visibility = PhotoVisibility.both,
  }) async {
    // 模拟上传延迟
    await Future.delayed(const Duration(seconds: 2));

    // 生成模拟URL（实际应上传到云存储）
    final photoId = 'photo_${DateTime.now().millisecondsSinceEpoch}';
    final photoUrl = 'https://picsum.photos/800/600?random=$photoId';
    final thumbnailUrl = 'https://picsum.photos/400/300?random=$photoId';

    final photo = AlbumPhotoModel(
      objectId: photoId,
      relationId: relationId,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      photoUrl: photoUrl,
      thumbnailUrl: thumbnailUrl,
      caption: caption,
      shotAt: shotAt ?? DateTime.now(),
      locationText: locationText,
      tags: tags,
      visibility: visibility,
      createdAt: DateTime.now(),
    );

    _mockPhotos.insert(0, photo);
    return photo;
  }

  /// 获取照片详情
  Future<AlbumPhotoModel?> getPhotoDetail(String photoId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockPhotos.firstWhere((p) => p.objectId == photoId);
    } catch (_) {
      return null;
    }
  }

  /// 删除照片
  Future<bool> deletePhoto(String photoId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockPhotos.indexWhere((p) => p.objectId == photoId);
    if (index != -1) {
      _mockPhotos.removeAt(index);
      return true;
    }
    return false;
  }

  /// 更新照片文案
  Future<AlbumPhotoModel?> updatePhotoCaption(
    String photoId,
    String caption,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockPhotos.indexWhere((p) => p.objectId == photoId);
    if (index != -1) {
      final updated = _mockPhotos[index].copyWith(caption: caption);
      _mockPhotos[index] = updated;
      return updated;
    }
    return null;
  }

  /// 获取所有可用的年月列表（用于分组）
  Future<List<String>> getAvailableYearMonths(String relationId) async {
    final photos =
        _mockPhotos.where((p) => p.relationId == relationId).toList();
    final yearMonths = <String>{};
    for (final photo in photos) {
      final time = photo.shotAt ?? photo.createdAt;
      yearMonths.add('${time.year}-${time.month.toString().padLeft(2, '0')}');
    }
    final sorted = yearMonths.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }
}
