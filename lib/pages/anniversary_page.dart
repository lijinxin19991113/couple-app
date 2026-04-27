import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/anniversary_controller.dart';
import '../models/anniversary_model.dart';
import '../services/anniversary_service.dart';
import 'anniversary_form_page.dart';

/// 纪念日列表页
class AnniversaryPage extends StatefulWidget {
  const AnniversaryPage({super.key});

  @override
  State<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends State<AnniversaryPage> {
  late final AnniversaryController _controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AnniversaryService>()) {
      Get.put(AnniversaryService(), permanent: true);
    }
    _controller = Get.put(AnniversaryController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念日'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToForm(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.anniversaries.isEmpty) {
          return _buildEmptyState();
        }

        return _buildList();
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 空状态引导
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: AppColors.gray3.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无纪念日',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.gray3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加你们的纪念日',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray3.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToForm,
            icon: const Icon(Icons.add),
            label: const Text('添加纪念日'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 列表
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.anniversaries.length,
      itemBuilder: (context, index) {
        final anniversary = _controller.anniversaries[index];
        return _buildCard(anniversary);
      },
    );
  }

  /// 卡片
  Widget _buildCard(AnniversaryModel anniversary) {
    final countdown = anniversary.countdownDays;
    final isToday = countdown == 0;
    final isPast = countdown < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToForm(anniversary: anniversary),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 类型图标
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor(anniversary.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    anniversary.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anniversary.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${anniversary.date.year}-${anniversary.date.month.toString().padLeft(2, '0')}-${anniversary.date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // 重复标签
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            anniversary.repeatType.displayName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 提醒图标
                        if (anniversary.reminderEnabled)
                          const Icon(
                            Icons.notifications_active,
                            size: 14,
                            color: AppColors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // 倒计时
              Column(
                children: [
                  Text(
                    isToday ? '今天' : (isPast ? '已过' : '$countdown'),
                    style: TextStyle(
                      fontSize: isToday ? 18 : 24,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? AppColors.primary
                          : (isPast ? AppColors.gray3 : AppColors.orange),
                    ),
                  ),
                  if (!isToday && !isPast)
                    const Text(
                      '天后',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray3,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取类型颜色
  Color _getTypeColor(AnniversaryType type) {
    switch (type) {
      case AnniversaryType.love:
        return AppColors.primary;
      case AnniversaryType.birthday:
        return AppColors.orange;
      case AnniversaryType.firstMet:
        return AppColors.purple;
      case AnniversaryType.custom:
        return AppColors.blue;
    }
  }

  /// 跳转到表单页
  void _navigateToForm({AnniversaryModel? anniversary}) {
    Get.to(
      () => AnniversaryFormPage(anniversary: anniversary),
      transition: Transition.rightToLeft,
    );
  }
}
