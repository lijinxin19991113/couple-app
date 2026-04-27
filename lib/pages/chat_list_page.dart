import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/user_controller.dart';

/// 聊天列表页
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
        centerTitle: true,
      ),
      body: Obx(() {
        // 检查是否绑定情侣关系
        if (!_userController.isCoupled.value) {
          return _buildUnboundGuide();
        }
        return _buildChatList();
      }),
    );
  }

  /// 未绑定情侣引导卡片
  Widget _buildUnboundGuide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '还没有绑定TA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.gray1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '绑定你的另一半，开始聊天吧',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray3,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.coupleBind),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '立即绑定',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 聊天列表
  Widget _buildChatList() {
    final couple = _userController.coupleRelation.value;
    final partner = couple?.partner;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // 情侣会话卡片
        _ChatSessionCard(
          avatar: partner?.avatar,
          name: partner?.nickname ?? 'TA',
          lastMessage: '暂无消息',
          lastTime: null,
          unreadCount: 0,
          onTap: () => Get.toNamed(AppRoutes.chat),
        ),
      ],
    );
  }
}

/// 聊天会话卡片
class _ChatSessionCard extends StatelessWidget {
  final String? avatar;
  final String name;
  final String lastMessage;
  final DateTime? lastTime;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatSessionCard({
    this.avatar,
    required this.name,
    required this.lastMessage,
    this.lastTime,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
                  child: avatar == null
                      ? const Icon(Icons.person, color: AppColors.white, size: 28)
                      : null,
                ),
                // 在线状态指示
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 聊天信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray1,
                        ),
                      ),
                      if (lastTime != null)
                        Text(
                          _formatTime(lastTime!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray3,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        _UnreadBadge(count: unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 未读消息气泡
class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
