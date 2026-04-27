import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_record_model.dart';

/// 心情首页
class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final MoodController _controller = Get.put(MoodController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadTimeline();
    await _controller.checkTodayMood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // TODO: 跳转统计页面
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.moodRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // 今日心情卡片
              SliverToBoxAdapter(
                child: _TodayMoodCard(
                  mood: _controller.todayMood.value,
                  onCheckin: () => Get.toNamed(AppRoutes.moodCheckin),
                  onEdit: () {
                    if (_controller.todayMood.value != null) {
                      Get.toNamed(
                        AppRoutes.moodCheckin,
                        arguments: _controller.todayMood.value,
                      );
                    }
                  },
                ),
              ),

              // 历史时间线标题
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    '历史记录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray1,
                    ),
                  ),
                ),
              ),

              // 空态引导
              if (_controller.moodRecords.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                // 分组时间线
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entries = _controller.groupedRecords.entries.toList();
                      if (index >= entries.length) return null;

                      final entry = entries[index];
                      return _DateSection(
                        dateLabel: _controller.getDateLabel(
                          entry.value.first.recordDate,
                        ),
                        records: entry.value,
                      );
                    },
                    childCount: _controller.groupedRecords.length,
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        // 如果今日已打卡，不显示 FAB
        if (_controller.todayMood.value != null) return const SizedBox();
        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.moodCheckin),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: AppColors.white),
          label: const Text('打卡', style: TextStyle(color: AppColors.white)),
        );
      }),
    );
  }
}

/// 今日心情卡片
class _TodayMoodCard extends StatelessWidget {
  final MoodRecord? mood;
  final VoidCallback onCheckin;
  final VoidCallback onEdit;

  const _TodayMoodCard({
    required this.mood,
    required this.onCheckin,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: mood != null
            ? const LinearGradient(
                colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日心情',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (mood != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: AppColors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (mood != null) ...[
            // 心情表情和分值
            Row(
              children: [
                Text(
                  mood!.moodEmoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood!.moodType.label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < mood!.moodScore
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.white,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),

            // 文案预览
            if (mood!.contentPreview != null) ...[
              const SizedBox(height: 12),
              Text(
                mood!.contentPreview!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ] else ...[
            // 未打卡状态
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.mood,
                    color: AppColors.white,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '今天心情怎么样？',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '记录此刻的心情吧',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: onCheckin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('去打卡'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 日期分组区块
class _DateSection extends StatelessWidget {
  final String dateLabel;
  final List<MoodRecord> records;

  const _DateSection({
    required this.dateLabel,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...records.map((record) => _MoodCard(record: record)),
      ],
    );
  }
}

/// 心情卡片
class _MoodCard extends StatelessWidget {
  final MoodRecord record;

  const _MoodCard({required this.record});

  @override
  Widget build(BuildContext context) {
    // 根据是否是当前用户的记录决定样式
    final isMe = record.userId == 'user_001';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppColors.primary.withOpacity(0.3) : AppColors.gray5,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像/表情区
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isMe ? AppColors.primaryLight : AppColors.gray5,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                record.moodEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 内容区
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMe ? '我' : 'Ta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isMe ? AppColors.primary : AppColors.gray2,
                      ),
                    ),
                    Row(
                      children: [
                        // 可见性标识
                        Icon(
                          record.visibleToPartner
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 14,
                          color: AppColors.gray4,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.visibleToPartner ? '彼此可见' : '仅自己',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.gray4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 心情类型 + 分值
                Row(
                  children: [
                    Text(
                      record.moodType.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < record.moodScore
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.orange,
                        size: 12,
                      );
                    }),
                  ],
                ),

                // 文案
                if (record.content != null && record.content!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    record.content!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // 图片
                if (record.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: record.imageUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            record.imageUrls[index],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: AppColors.gray5,
                              child: const Icon(Icons.image, color: AppColors.gray4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 空态引导
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood_outlined,
            size: 80,
            color: AppColors.gray4,
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有心情记录',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '记录每天的心情变化',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.moodCheckin),
            icon: const Icon(Icons.add),
            label: const Text('记录第一条心情'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
