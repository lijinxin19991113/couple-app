import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import 'album_page.dart';

/// 主页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _ChatTab(),
          _AlbumTab(),
          _DiaryTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: '相册',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: '日记',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 首页 Tab
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userController.loadUserInfo();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 问候卡片
              Obx(() {
                final user = userController.currentUser.value;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '早上好，${user?.nickname ?? "亲爱的"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '今天也要幸福哦~',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              Obx(() {
                final isCoupled = userController.isCoupled.value;
                if (!isCoupled) {
                  // 未绑定情侣，显示引导卡片
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          '绑定你的另一半',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '一起记录美好时光',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.coupleBind),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.pink,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          ),
                          child: const Text('立即绑定'),
                        ),
                      ],
                    ),
                  );
                }
                // 已绑定：在一起天数卡片
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.coupleProfile),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '在一起',
                                style: TextStyle(fontSize: 14, color: AppColors.gray3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '第 ${userController.daysTogether} 天',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.gray3, size: 16),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 快捷入口
              const Text(
                '快捷入口',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickEntryCard(
                      icon: Icons.calendar_today,
                      title: '纪念日',
                      color: AppColors.orange,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickEntryCard(
                      icon: Icons.mood,
                      title: '心情打卡',
                      color: AppColors.green,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickEntryCard(
                      icon: Icons.location_on,
                      title: '位置共享',
                      color: AppColors.blue,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ta 的状态
              const Text(
                'Ta 的动态',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.favorite_border, color: AppColors.gray3, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      '还没有动态',
                      style: TextStyle(color: AppColors.gray3),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '快去和 Ta 互动吧',
                      style: TextStyle(color: AppColors.gray3, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 快捷入口卡片
class _QuickEntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickEntryCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 聊天 Tab
class _ChatTab extends StatelessWidget {
  const _ChatTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('聊天')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.gray3),
            SizedBox(height: 16),
            Text('聊天功能开发中...', style: TextStyle(color: AppColors.gray3)),
          ],
        ),
      ),
    );
  }
}

/// 相册 Tab
class _AlbumTab extends StatelessWidget {
  const _AlbumTab();

  @override
  Widget build(BuildContext context) {
    return const AlbumPage();
  }
}

/// 日记 Tab
class _DiaryTab extends StatelessWidget {
  const _DiaryTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日记')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_outlined, size: 64, color: AppColors.gray3),
            SizedBox(height: 16),
            Text('日记功能开发中...', style: TextStyle(color: AppColors.gray3)),
          ],
        ),
      ),
    );
  }
}

/// 我的 Tab
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          // 用户信息
          Obx(() {
            final user = userController.currentUser.value;
            return Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.nickname.isNotEmpty == true) ? user!.nickname.substring(0, 1) : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nickname ?? '未登录',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.signature ?? '编辑个性签名',
                          style: const TextStyle(color: AppColors.gray3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),

          // 设置项
          _SettingsItem(
            icon: Icons.person_outline,
            title: '个人资料',
            onTap: () => Get.toNamed(AppRoutes.profileEdit),
          ),
          _SettingsItem(
            icon: Icons.favorite_outline,
            title: '情侣档案',
            onTap: () => Get.toNamed(AppRoutes.coupleProfile),
          ),
          _SettingsItem(
            icon: Icons.notifications_outlined,
            title: '通知设置',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.lock_outline,
            title: '隐私设置',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.location_on_outlined,
            title: '位置共享设置',
            onTap: () {},
          ),
          const Divider(),
          _SettingsItem(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.info_outline,
            title: '关于我们',
            onTap: () {},
          ),
          const Divider(),

          // 退出登录
          _SettingsItem(
            icon: Icons.logout,
            title: '退出登录',
            textColor: AppColors.red,
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
}

/// 设置项组件
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.gray2),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AppColors.gray1),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.gray3,
      ),
      onTap: onTap,
    );
  }
}
