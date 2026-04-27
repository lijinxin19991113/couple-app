import 'package:get/get.dart';

import '../models/album_photo_model.dart';
import '../services/album_service.dart';
import 'user_controller.dart';

/// 相册控制器
class AlbumController extends GetxController {
  /// 相册服务
  final AlbumService _albumService = Get.find<AlbumService>();

  /// 用户控制器
  UserController get _userController => Get.find<UserController>();

  /// 照片列表
  final photos = <AlbumPhoto>[].obs;

  /// 加载状态
  final isLoading = false.obs;

  /// 上传进度（0.0 - 1.0）
  final uploadProgress = 0.0.obs;

  /// 是否有更多数据
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载照片
    loadPhotos();
  }

  /// 获取当前用户ID
  String get _currentUserId => _userController.currentUser.value?.id ?? '';

  /// 获取当前情侣关系ID
  String get _relationId =>
      _userController.coupleRelation.value?.id ?? '';

  /// 加载照片列表
  Future<void> loadPhotos({String? yearMonth}) async {
    if (!mounted) return;
    isLoading.value = true;

    try {
      final result = await _albumService.getAlbumPhotos(
        relationId: _relationId,
      );

      if (!mounted) return;
      photos.value = result;
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('错误', '加载照片失败: $e');
    } finally {
      if (!mounted) return;
      isLoading.value = false;
    }
  }

  /// 加载更多照片
  Future<void> loadMore() async {
    // 当前为简单实现，暂不支持分页
  }

  /// 上传照片
  Future<bool> uploadPhoto({
    required String localFilePath,
    String? caption,
    DateTime? shotAt,
    String? locationText,
    List<String> tags = const [],
    AlbumVisibility visibility = AlbumVisibility.both,
  }) async {
    if (!mounted) return false;
    uploadProgress.value = 0.0;

    try {
      // 模拟上传进度
      for (int i = 1; i <= 10; i++) {
        if (!mounted) return false;
        await Future.delayed(const Duration(milliseconds: 200));
        uploadProgress.value = i / 10;
      }

      final photo = await _albumService.uploadPhoto(
        relationId: _relationId,
        uploaderId: _currentUserId,
        localPath: localFilePath,
        caption: caption,
        shotAt: shotAt,
        locationText: locationText,
        tags: tags,
        visibility: visibility,
      );

      if (!mounted) return false;
      photos.insert(0, photo);
      uploadProgress.value = 0.0;
      Get.snackbar('成功', '照片上传成功');
      return true;
    } catch (e) {
      if (!mounted) return false;
      uploadProgress.value = 0.0;
      Get.snackbar('错误', '上传失败: $e');
      return false;
    }
  }

  /// 删除照片
  Future<bool> deletePhoto(String photoId) async {
    try {
      final success = await _albumService.deletePhoto(photoId: photoId);
      if (!mounted) return false;

      if (success) {
        photos.removeWhere((p) => p.objectId == photoId);
        Get.snackbar('成功', '照片已删除');
        return true;
      } else {
        Get.snackbar('错误', '删除失败');
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      Get.snackbar('错误', '删除失败: $e');
      return false;
    }
  }

  /// 更新照片文案
  Future<bool> updateCaption(String photoId, String caption) async {
    try {
      final updated = await _albumService.updatePhotoCaption(
        photoId: photoId,
        caption: caption,
      );
      if (!mounted) return false;

      if (updated != null) {
        final index = photos.indexWhere((p) => p.objectId == photoId);
        if (index != -1) {
          photos[index] = updated;
        }
        Get.snackbar('成功', '文案已更新');
        return true;
      } else {
        Get.snackbar('错误', '更新失败');
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      Get.snackbar('错误', '更新失败: $e');
      return false;
    }
  }

  /// 获取照片详情
  Future<AlbumPhoto?> getPhotoDetail(String photoId) async {
    try {
      return await _albumService.getPhotoDetail(photoId: photoId);
    } catch (e) {
      if (!mounted) return null;
      Get.snackbar('错误', '获取照片详情失败: $e');
      return null;
    }
  }

  /// 判断当前用户是否为照片上传者
  bool isUploader(AlbumPhoto photo) {
    return photo.uploaderId == _currentUserId;
  }

  /// 按年月分组照片
  Map<String, List<AlbumPhoto>> groupPhotosByYearMonth() {
    final grouped = <String, List<AlbumPhoto>>{};
    for (final photo in photos) {
      final time = photo.shotAt ?? photo.createdAt;
      final key = '${time.year}年${time.month}月';
      grouped.putIfAbsent(key, () => []).add(photo);
    }
    return grouped;
  }
}
