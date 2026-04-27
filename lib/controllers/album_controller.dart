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
  final photos = <AlbumPhotoModel>[].obs;

  /// 加载状态
  final isLoading = false.obs;

  /// 上传进度（0.0 - 1.0）
  final uploadProgress = 0.0.obs;

  /// 是否有更多数据
  final hasMore = true.obs;

  /// 当前页码
  int _currentPage = 1;

  /// 每页大小
  static const int _pageSize = 20;

  /// 当前筛选的年月（null表示全部）
  String? _currentYearMonth;

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

  /// 获取当前用户名称
  String get _currentUserName =>
      _userController.currentUser.value?.nickname ?? '';

  /// 加载照片列表
  Future<void> loadPhotos({String? yearMonth}) async {
    if (!mounted) return;
    isLoading.value = true;
    _currentYearMonth = yearMonth;
    _currentPage = 1;
    hasMore.value = true;

    try {
      final result = await _albumService.getAlbumPhotos(
        relationId: _relationId,
        page: _currentPage,
        pageSize: _pageSize,
        yearMonth: yearMonth,
      );

      if (!mounted) return;
      photos.value = result;
      hasMore.value = result.length >= _pageSize;
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
    if (!mounted || isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    _currentPage++;

    try {
      final result = await _albumService.getAlbumPhotos(
        relationId: _relationId,
        page: _currentPage,
        pageSize: _pageSize,
        yearMonth: _currentYearMonth,
      );

      if (!mounted) return;
      photos.addAll(result);
      hasMore.value = result.length >= _pageSize;
    } catch (e) {
      if (!mounted) return;
      _currentPage--;
      Get.snackbar('错误', '加载更多照片失败: $e');
    } finally {
      if (!mounted) return;
      isLoading.value = false;
    }
  }

  /// 上传照片
  Future<bool> uploadPhoto({
    required String localFilePath,
    String? caption,
    DateTime? shotAt,
    String? locationText,
    List<String> tags = const [],
    PhotoVisibility visibility = PhotoVisibility.both,
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
        uploaderName: _currentUserName,
        localFilePath: localFilePath,
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
      final success = await _albumService.deletePhoto(photoId);
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
      final updated = await _albumService.updatePhotoCaption(photoId, caption);
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
  Future<AlbumPhotoModel?> getPhotoDetail(String photoId) async {
    try {
      return await _albumService.getPhotoDetail(photoId);
    } catch (e) {
      if (!mounted) return null;
      Get.snackbar('错误', '获取照片详情失败: $e');
      return null;
    }
  }

  /// 获取可用年月列表
  Future<List<String>> getAvailableYearMonths() async {
    try {
      return await _albumService.getAvailableYearMonths(_relationId);
    } catch (e) {
      return [];
    }
  }

  /// 判断当前用户是否为照片上传者
  bool isUploader(AlbumPhotoModel photo) {
    return photo.uploaderId == _currentUserId;
  }

  /// 按年月分组照片
  Map<String, List<AlbumPhotoModel>> groupPhotosByYearMonth() {
    final grouped = <String, List<AlbumPhotoModel>>{};
    for (final photo in photos) {
      final time = photo.shotAt ?? photo.createdAt;
      final key = '${time.year}年${time.month}月';
      grouped.putIfAbsent(key, () => []).add(photo);
    }
    return grouped;
  }
}
