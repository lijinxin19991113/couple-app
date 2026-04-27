import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry_model.dart';

/// 日记首页
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DiaryController _controller = Get.put(DiaryController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadDiaryDates();
    await _controller.getByDate(_controller.selectedDate.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _showMonthPicker();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 日历视图
          Obx(() => _CalendarView(
                currentMonth: _controller.currentMonth.value,
                selectedDate: _controller.selectedDate.value,
                diaryDates: _controller.diaryDates.value,
                onDateSelected: (date) {
                  _controller.selectDate(date);
                },
                onMonthChanged: (delta) {
                  _controller.changeMonth(delta);
                },
              )),

          const Divider(height: 1),

          // 日记列表
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.diaryEntries.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = _controller.selectedDateEntries;

              if (entries.isEmpty) {
                return _EmptyState(
                  selectedDate: _controller.selectedDate.value,
                  onWrite: () => _goToWrite(),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _DiaryCard(
                      entry: entries[index],
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.diaryDetail,
                          arguments: entries[index],
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToWrite(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  void _goToWrite() {
    Get.toNamed(
      AppRoutes.diaryWrite,
      arguments: {'date': _controller.selectedDate.value},
    )?.then((_) => _loadData());
  }

  void _showMonthPicker() {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    _controller.changeMonth(-1);
                    Navigator.pop(context);
                    _showMonthPicker();
                  },
                ),
                Obx(() => Text(
                      '${_controller.currentMonth.value.year}年${_controller.currentMonth.value.month}月',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    _controller.changeMonth(1);
                    Navigator.pop(context);
                    _showMonthPicker();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _controller.diaryDates.map((date) {
                    final isSelected = date.year == _controller.selectedDate.value.year &&
                        date.month == _controller.selectedDate.value.month &&
                        date.day == _controller.selectedDate.value.day;
                    return GestureDetector(
                      onTap: () {
                        _controller.selectDate(date);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.gray5,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${date.day}日',
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.gray2,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 日历视图
class _CalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<DateTime> diaryDates;
  final Function(DateTime) onDateSelected;
  final Function(int) onMonthChanged;

  const _CalendarView({
    required this.currentMonth,
    required this.selectedDate,
    required this.diaryDates,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.white,
      child: Column(
        children: [
          // 月份导航
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(-1),
              ),
              Text(
                '${currentMonth.year}年${currentMonth.month}月',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray1,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onMonthChanged(1),
              ),
            ],
          ),

          // 星期标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['日', '一', '二', '三', '四', '五', '六']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 8),

          // 日期网格
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayOffset = index - startWeekday;
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox();
                }

                final day = dayOffset + 1;
                final date = DateTime(currentMonth.year, currentMonth.month, day);
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;
                final hasDiary = diaryDates.contains(date);

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: AppColors.primary, width: 1)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? AppColors.white : AppColors.gray1,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (hasDiary)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.white : AppColors.red,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 日记卡片
class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const _DiaryCard({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = entry.authorId == 'mock_user_001' || entry.authorId == 'user_001';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：表情 + 标题 + 私密标识
              Row(
                children: [
                  Text(entry.moodEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              isMe ? '我' : 'Ta',
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe ? AppColors.primary : AppColors.gray3,
                              ),
                            ),
                            if (entry.isPrivate) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: AppColors.gray4,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.gray4),
                ],
              ),

              // 内容预览
              if (entry.contentPreview != null) ...[
                const SizedBox(height: 12),
                Text(
                  entry.contentPreview!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray2,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // 图片预览
              if (entry.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imageUrls.length.clamp(0, 3),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          entry.imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.gray5,
                            child: const Icon(Icons.image, color: AppColors.gray4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // 底部：天气 + 位置 + 时间
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${entry.weatherIcon} ${entry.weather.label}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray4),
                  ),
                  if (entry.locationText != null && entry.locationText!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 12, color: AppColors.gray4),
                    const SizedBox(width: 2),
                    Text(
                      entry.locationText!,
                      style: const TextStyle(fontSize: 12, color: AppColors.gray4),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    _formatTime(entry.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.gray4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// 空状态
class _EmptyState extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onWrite;

  const _EmptyState({
    required this.selectedDate,
    required this.onWrite,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: AppColors.gray4,
          ),
          const SizedBox(height: 16),
          Text(
            isToday ? '今天还没有写日记' : '这天还没有日记',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.gray3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '记录今天的美好时刻吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onWrite,
            icon: const Icon(Icons.edit),
            label: const Text('写日记'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
