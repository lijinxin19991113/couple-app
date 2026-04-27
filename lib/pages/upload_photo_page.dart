import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../config/colors.dart';
import '../controllers/album_controller.dart';
import '../models/album_photo_model.dart';

/// 上传照片页
class UploadPhotoPage extends StatefulWidget {
  const UploadPhotoPage({super.key});

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  final AlbumController _controller = Get.find<AlbumController>();
  final ImagePicker _imagePicker = ImagePicker();

  // 表单控制器
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();

  // 选中的图片
  XFile? _selectedImage;

  // 拍摄时间
  DateTime? _shotAt;

  // 标签列表
  final List<String> _tags = [];

  // 可见性
  AlbumVisibility _visibility = AlbumVisibility.both;

  // 上传中状态
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传照片'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _canUpload() ? _upload : null,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('上传'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片预览
            _buildImagePreview(),
            const SizedBox(height: 24),

            // 拍摄时间
            _buildShotAtPicker(),
            const SizedBox(height: 16),

            // 文案输入
            _buildCaptionInput(),
            const SizedBox(height: 16),

            // 地点输入
            _buildLocationInput(),
            const SizedBox(height: 16),

            // 标签输入
            _buildTagInput(),
            const SizedBox(height: 16),

            // 可见性开关
            _buildVisibilitySwitch(),
            const SizedBox(height: 24),

            // 上传进度条
            _buildUploadProgress(),
          ],
        ),
      ),
    );
  }

  /// 图片预览区域
  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.gray5,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray4),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate,
                    size: 48, color: AppColors.gray3),
                SizedBox(height: 8),
                Text('点击选择照片', style: TextStyle(color: AppColors.gray3)),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_selectedImage!.path),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: () => setState(() => _selectedImage = null),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            onPressed: _pickImage,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  /// 拍摄时间选择器
  Widget _buildShotAtPicker() {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('拍摄时间',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  _shotAt != null
                      ? dateFormat.format(_shotAt!)
                      : '选择日期（可选）',
                  style: TextStyle(
                    color: _shotAt != null ? Colors.black : AppColors.gray3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 文案输入
  Widget _buildCaptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('文案',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _captionController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: '说点什么...',
            hintStyle: const TextStyle(color: AppColors.gray3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  /// 地点输入
  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('地点',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: '添加地点...',
            hintStyle: const TextStyle(color: AppColors.gray3),
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  /// 标签输入
  Widget _buildTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('标签',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '添加标签',
                  hintStyle: const TextStyle(color: AppColors.gray3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addTag,
              icon: const Icon(Icons.add_circle),
              color: AppColors.primary,
            ),
          ],
        ),
        // 标签列表
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _tags.remove(tag)),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: AppColors.primary),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// 可见性开关
  Widget _buildVisibilitySwitch() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('可见性', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '关闭后仅自己可见',
                  style: TextStyle(fontSize: 12, color: AppColors.gray2),
                ),
              ],
            ),
          ),
          Obx(() => Switch(
                value: _visibility == AlbumVisibility.both,
                onChanged: _isUploading
                    ? null
                    : (value) {
                        setState(() {
                          _visibility = value
                              ? AlbumVisibility.both
                              : AlbumVisibility.private;
                        });
                      },
                activeColor: AppColors.primary,
              )),
        ],
      ),
    );
  }

  /// 上传进度条
  Widget _buildUploadProgress() {
    return Obx(() {
      final progress = _controller.uploadProgress.value;
      if (progress <= 0 || progress >= 1) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload, size: 20),
              const SizedBox(width: 8),
              Text('上传中... ${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.gray5,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      );
    });
  }

  /// 是否可以上传
  bool _canUpload() {
    return _selectedImage != null && !_isUploading;
  }

  /// 选择图片
  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (image != null) {
        if (!mounted) return;
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      Get.snackbar('错误', '选择图片失败: $e');
    }
  }

  /// 选择日期
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _shotAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      if (!mounted) return;
      setState(() => _shotAt = date);
    }
  }

  /// 添加标签
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) return;
    if (_tags.contains(tag)) {
      Get.snackbar('提示', '标签已存在');
      return;
    }
    if (_tags.length >= 10) {
      Get.snackbar('提示', '最多添加10个标签');
      return;
    }
    setState(() {
      _tags.add(tag);
      _tagController.clear();
    });
  }

  /// 上传照片
  Future<void> _upload() async {
    if (!_canUpload()) return;

    setState(() => _isUploading = true);

    try {
      final success = await _controller.uploadPhoto(
        localFilePath: _selectedImage!.path,
        caption: _captionController.text.trim(),
        shotAt: _shotAt,
        locationText: _locationController.text.trim(),
        tags: _tags,
        visibility: _visibility,
      );

      if (!mounted) return;

      if (success) {
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('错误', '上传失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
