import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/colors.dart';
import '../controllers/album_controller.dart';
import '../models/album_photo_model.dart';

/// 照片预览页
class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({super.key});

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  final AlbumController _controller = Get.find<AlbumController>();

  late String _photoId;
  AlbumPhoto? _photo;
  bool _isLoading = true;

  // 缩放控制器
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _photoId = (args['photoId'] ?? '').toString();
    } else {
      _photoId = '';
    }
    _loadPhoto();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// 加载照片详情
  Future<void> _loadPhoto() async {
    setState(() => _isLoading = true);
    try {
      final photo = await _controller.getPhotoDetail(_photoId);
      if (mounted) {
        setState(() {
          _photo = photo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Get.snackbar('错误', '加载照片失败');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        // 右上角删除按钮（仅上传者可见）
        actions: [
          if (_photo != null && _controller.isUploader(_photo!))
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _photo == null
              ? _buildNotFound()
              : _buildContent(),
    );
  }

  /// 内容区域
  Widget _buildContent() {
    return Column(
      children: [
        // 图片区域（可缩放）
        Expanded(
          child: GestureDetector(
            onDoubleTap: _resetZoom,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  _photo!.photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // 底部信息栏
        _buildInfoBar(),
      ],
    );
  }

  /// 底部信息栏
  Widget _buildInfoBar() {
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 文案
            if (_photo!.caption != null && _photo!.caption!.isNotEmpty) ...[
              Text(
                _photo!.caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // 时间
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Text(
                  _photo!.shotAt != null
                      ? dateFormat.format(_photo!.shotAt!)
                      : dateFormat.format(_photo!.createdAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
            // 地点
            if (_photo!.locationText != null &&
                _photo!.locationText!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _photo!.locationText!,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            // 标签
            if (_photo!.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _photo!.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 未找到照片
  Widget _buildNotFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_not_supported, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            '照片不存在',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 重置缩放
  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  /// 显示删除确认对话框
  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('删除照片'),
        content: const Text('确定要删除这张照片吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // 关闭对话框
              final success = await _controller.deletePhoto(_photoId);
              if (!mounted) return;
              if (success) {
                Get.back(); // 返回列表页
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
