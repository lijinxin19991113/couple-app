import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry_model.dart';

/// 日记详情页
class DiaryDetailPage extends StatefulWidget {
  const DiaryDetailPage({super.key});

  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  final DiaryController _diaryController = Get.find<DiaryController>();
  late DiaryEntry _entry;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _entry = Get.arguments as DiaryEntry;
  }

  @override
  Widget build(BuildContext context) {
    final isMe = _entry.authorId == 'mock_user_001' || _entry.authorId == 'user_001';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部图片轮播
          if (_entry.imageUrls.isNotEmpty)
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _ImageCarousel(
                  imageUrls: _entry.imageUrls,
                  currentIndex: _currentImageIndex,
                  onIndexChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
              ),
            )
          else
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primaryLight,
              title: Text(_entry.title),
            ),

          // 内容区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    _entry.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 元信息
                  _MetaInfo(
                    entry: _entry,
                    isMe: isMe,
                  ),

                  const SizedBox(height: 20),

                  // 心情 + 天气
                  Row(
                    children: [
                      _TagChip(
                        emoji: _entry.moodEmoji,
                        label: _entry.moodType.label,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      _TagChip(
                        emoji: _entry.weatherIcon,
                        label: _entry.weather.label,
                        color: AppColors.gray5,
                      ),
                      if (_entry.isPrivate) ...[
                        const SizedBox(width: 8),
                        _TagChip(
                          emoji: '🔒',
                          label: '仅自己',
                          color: AppColors.orange.withOpacity(0.2),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 正文
                  Text(
                    _entry.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.gray1,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 操作按钮
                  if (isMe)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _editDiary,
                            icon: const Icon(Icons.edit),
                            label: const Text('编辑'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _deleteDiary,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('删除'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editDiary() {
    Get.toNamed(
      AppRoutes.diaryWrite,
      arguments: {'entry': _entry},
    )?.then((_) {
      // 刷新数据
      final updated = _diaryController.diaryEntries
          .firstWhereOrNull((e) => e.objectId == _entry.objectId);
      if (updated != null) {
        setState(() {
          _entry = updated;
        });
      }
    });
  }

  void _deleteDiary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这篇日记吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _doDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _doDelete() async {
    await _diaryController.deleteEntry(_entry.objectId);
    Get.back();
  }
}

/// 图片轮播
class _ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const _ImageCarousel({
    required this.imageUrls,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: onIndexChanged,
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.gray5,
                child: const Icon(Icons.image, size: 60, color: AppColors.gray4),
              ),
            );
          },
        ),
        // 指示器
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentIndex
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// 元信息
class _MetaInfo extends StatelessWidget {
  final DiaryEntry entry;
  final bool isMe;

  const _MetaInfo({
    required this.entry,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          isMe ? '我' : 'Ta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isMe ? AppColors.primary : AppColors.gray3,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.circle, size: 4, color: AppColors.gray4),
        const SizedBox(width: 8),
        Text(
          _formatDate(entry.recordDate),
          style: const TextStyle(fontSize: 14, color: AppColors.gray3),
        ),
        if (entry.locationText != null && entry.locationText!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(Icons.circle, size: 4, color: AppColors.gray4),
          const SizedBox(width: 8),
          Icon(Icons.location_on, size: 14, color: AppColors.gray4),
          const SizedBox(width: 2),
          Text(
            entry.locationText!,
            style: const TextStyle(fontSize: 14, color: AppColors.gray3),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    return '${date.year}年${months[date.month - 1]}${date.day}日';
  }
}

/// 标签芯片
class _TagChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _TagChip({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.gray2,
            ),
          ),
        ],
      ),
    );
  }
}
