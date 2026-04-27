import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/wish_controller.dart';
import '../models/wish_item_model.dart';
import '../config/colors.dart';
import 'wish_form_page.dart';

/// 愿望详情页
class WishDetailPage extends StatelessWidget {
  final WishItem item;

  const WishDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('愿望详情'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (item.status == WishStatus.pending)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.to(() => WishFormPage(wishItem: item)),
            ),
          if (item.status == WishStatus.pending)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(context, controller),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 大标题
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(item.categoryIcon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            if (item.description != null && item.description!.isNotEmpty)
              _buildSection(
                '描述',
                child: Text(item.description!, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5)),
              ),

            // 信息卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('分类', '${item.categoryIcon} ${item.category.label}'),
                  const Divider(height: 24),
                  _buildInfoRow('优先级', item.priority.label, valueColor: Color(item.priorityColorValue)),
                  const Divider(height: 24),
                  _buildInfoRow('状态', item.status.label, valueColor: Color(item.statusColorValue)),
                  if (item.targetDate != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      '目标日期',
                      DateFormat('yyyy-MM-dd').format(item.targetDate!),
                    ),
                  ],
                  if (item.fulfilledAt != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(
                      '实现时间',
                      DateFormat('yyyy-MM-dd HH:mm').format(item.fulfilledAt!),
                    ),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow(
                    '创建时间',
                    DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt),
                  ),
                ],
              ),
            ),

            // 倒计时
            if (item.targetDate != null && item.status == WishStatus.pending) ...[
              const SizedBox(height: 16),
              _buildCountdown(),
            ],

            const SizedBox(height: 24),

            // 操作按钮
            if (item.status == WishStatus.pending) ...[
              _buildActionButtons(controller),
            ] else ...[
              _buildStatusMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 15, color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCountdown() {
    final days = item.daysRemaining!;
    final isOverdue = days < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverdue
              ? [Colors.red.shade400, Colors.red.shade600]
              : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            isOverdue ? '已逾期' : '距离目标日期',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${isOverdue ? '' : ''}${days.abs()}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            isOverdue ? '天' : '天',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WishController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => controller.fulfillWish(item.objectId).then((_) => Get.back()),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('实现愿望', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => controller.abandonWish(item.objectId).then((_) => Get.back()),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('放弃愿望', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    final isFulfilled = item.status == WishStatus.fulfilled;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isFulfilled ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isFulfilled ? Colors.green : Colors.grey).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFulfilled ? Icons.celebration : Icons.cancel,
            color: isFulfilled ? Colors.green : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isFulfilled ? '🎉 这个愿望已经实现啦！' : '已放弃此愿望',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isFulfilled ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WishController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除愿望'),
        content: const Text('确定要删除这个愿望吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteWish(item.objectId);
              Get.back();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
