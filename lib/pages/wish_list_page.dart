import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wish_controller.dart';
import '../models/wish_item_model.dart';
import '../config/colors.dart';
import 'wish_form_page.dart';
import 'wish_detail_page.dart';

/// 愿望清单页
class WishListPage extends StatefulWidget {
  const WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WishController _controller = Get.find<WishController>();

  final List<_TabItem> _tabs = [
    _TabItem(label: '全部', category: null),
    _TabItem(label: '旅行', category: WishCategory.travel),
    _TabItem(label: '美食', category: WishCategory.food),
    _TabItem(label: '礼物', category: WishCategory.gift),
    _TabItem(label: '其他', category: WishCategory.other),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _controller.loadWishes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('愿望清单'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.wishItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) => _buildWishList(tab.category)).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const WishFormPage()),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWishList(WishCategory? category) {
    return Obx(() {
      final items = _controller.getItemsByCategory(category);

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('暂无愿望', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              Text('点击右下角添加第一个愿望', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 14)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildWishCard(items[index]),
      );
    });
  }

  Widget _buildWishCard(WishItem item) {
    final priorityColor = Color(item.priorityColorValue);
    final statusColor = Color(item.statusColorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => WishDetailPage(item: item)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(item.categoryIcon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        if (item.description != null && item.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTag('${item.priorityLabel}优先级', priorityColor.withOpacity(0.15), priorityColor),
                  const SizedBox(width: 8),
                  _buildTag(item.statusLabel, statusColor.withOpacity(0.15), statusColor),
                  const Spacer(),
                  if (item.daysRemaining != null && item.status == WishStatus.pending)
                    Text(
                      item.daysRemaining! >= 0
                          ? '剩余 ${item.daysRemaining} 天'
                          : '已逾期 ${-item.daysRemaining!} 天',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isOverdue ? Colors.red : AppColors.textSecondary,
                      ),
                    ),
                  if (item.status == WishStatus.pending)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                      onPressed: () => _controller.fulfillWish(item.objectId),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
    );
  }
}

class _TabItem {
  final String label;
  final WishCategory? category;

  _TabItem({required this.label, this.category});
}
