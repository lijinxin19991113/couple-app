import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/album_controller.dart';

/// 相册列表页
class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final AlbumController _controller = Get.find<AlbumController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('相册'),
        centerTitle: true,
      ),
      body: Obx(() {
        // 加载状态
        if (_controller.isLoading.value && _controller.photos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 空态
        if (_controller.photos.isEmpty) {
          return _buildEmptyState();
        }

        // 照片列表（按月分组）
        return _buildPhotoGrid();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUpload,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_album_outlined,
            size: 80,
            color: AppColors.gray3,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有照片',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.gray2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮上传第一张照片',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray3,
            ),
          ),
        ],
      ),
    );
  }

  /// 照片网格视图（按月分组）
  Widget _buildPhotoGrid() {
    final grouped = _controller.groupPhotosByYearMonth();
    final yearMonths = grouped.keys.toList();

    return RefreshIndicator(
      onRefresh: () => _controller.loadPhotos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: yearMonths.length,
        itemBuilder: (context, index) {
          final yearMonth = yearMonths[index];
          final photos = grouped[yearMonth]!;
          return _buildMonthSection(yearMonth, photos);
        },
      ),
    );
  }

  /// 月份分组区块
  Widget _buildMonthSection(String yearMonth, List photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月份标题
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            yearMonth,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 照片网格（3列）
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return _buildPhotoThumbnail(photo);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 照片缩略图
  Widget _buildPhotoThumbnail(dynamic photo) {
    return GestureDetector(
      onTap: () => _navigateToPhotoView(photo.objectId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          photo.thumbnailUrl ?? photo.photoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.gray5,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.gray5,
              child: Icon(
                Icons.broken_image,
                color: AppColors.gray3,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 跳转到上传页
  void _navigateToUpload() {
    Get.toNamed(AppRoutes.uploadPhoto);
  }

  /// 跳转到照片预览页
  void _navigateToPhotoView(String photoId) {
    Get.toNamed(
      AppRoutes.photoView,
      arguments: {'photoId': photoId},
    );
  }
}
