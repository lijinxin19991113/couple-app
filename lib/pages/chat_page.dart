import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/chat_controller.dart';
import '../controllers/user_controller.dart';
import '../models/chat_message_model.dart';

/// 单聊页面
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _chatController;
  late final UserController _userController;

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isEmojiPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _chatController = Get.put(ChatController());
    _userController = Get.find<UserController>();

    // 加载消息并监听新消息
    _chatController.loadMessages();
    _chatController.listenNewMessages();
  }

  @override
  void dispose() {
    _chatController.stopListeningNewMessages();
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final content = _inputController.text.trim();
    if (content.isEmpty) return;

    _inputController.clear();
    try {
      await _chatController.sendTextMessage(content);
    } catch (e) {
      if (mounted) {
        Get.snackbar('提示', '发送失败，请重试');
      }
    }
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _scrollToBottom();
  }

  Future<void> _handleImagePick() async {
    // 模拟图片选择
    // 实际项目中需要使用 image_picker 包
    Get.snackbar('提示', '图片选择功能开发中');
  }

  void _toggleEmojiPanel() {
    setState(() {
      _isEmojiPanelVisible = !_isEmojiPanelVisible;
    });
    if (_isEmojiPanelVisible) {
      _inputFocusNode.unfocus();
    }
  }

  void _insertEmoji(String emoji) {
    _inputController.text += emoji;
  }

  @override
  Widget build(BuildContext context) {
    final partner = _userController.coupleRelation.value?.partner;

    return Scaffold(
      appBar: AppBar(
        title: Text(partner?.nickname ?? '聊天'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: Obx(() {
              if (_chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_chatController.messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: AppColors.gray3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '还没有消息',
                        style: TextStyle(color: AppColors.gray3),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '开始和TA聊天吧~',
                        style: TextStyle(color: AppColors.gray3, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              // 滚动到底部
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = _chatController.messages[index];
                  final isSelf = message.senderId == _userController.currentUser.value?.id;
                  return _MessageBubble(
                    message: message,
                    isSelf: isSelf,
                    onRetry: () => _chatController.retrySendMessage(message),
                  );
                },
              );
            }),
          ),

          // 底部输入区
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.gray5, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji 面板
          if (_isEmojiPanelVisible) _buildEmojiPanel(),

          // 输入框和按钮行
          Row(
            children: [
              // 图片按钮
              IconButton(
                icon: const Icon(Icons.image_outlined, color: AppColors.gray2),
                onPressed: _handleImagePick,
              ),
              // 表情按钮
              IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.gray2),
                onPressed: _toggleEmojiPanel,
              ),
              // 输入框
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  decoration: BoxDecoration(
                    color: AppColors.gray4,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: TextStyle(color: AppColors.gray3),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 发送按钮
              Obx(() {
                final isSending = _chatController.isSending.value;
                return Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: AppColors.white, size: 20),
                          onPressed: _handleSend,
                        ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPanel() {
    final emojis = ['😀', '😁', '😂', '🤣', '😃', '😄', '😅', '😆', '😊', '😋', '😘', '😍', '🤗', '🤩', '🤔', '👍', '❤️', '💕', '🎉', '✨'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _insertEmoji(emojis[index]),
            child: Center(
              child: Text(
                emojis[index],
                style: const TextStyle(fontSize: 28),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 消息气泡
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isSelf;
  final VoidCallback onRetry;

  const _MessageBubble({
    required this.message,
    required this.isSelf,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSelf) ...[
            // 对方头像
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 8),
          ],
          // 消息气泡
          Flexible(
            child: Column(
              crossAxisAlignment: isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 消息内容
                _buildBubbleContent(),
                const SizedBox(height: 2),
                // 时间戳和状态
                _buildMessageStatus(),
              ],
            ),
          ),
          if (isSelf) ...[
            const SizedBox(width: 8),
            // 自己头像
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 16, color: AppColors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBubbleContent() {
    if (message.messageType == ChatMessageType.image) {
      return _buildImageMessage();
    }
    return _buildTextMessage();
  }

  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelf ? AppColors.primary : AppColors.gray4,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isSelf ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight: isSelf ? const Radius.circular(4) : const Radius.circular(18),
        ),
      ),
      child: Text(
        message.content ?? '',
        style: TextStyle(
          color: isSelf ? AppColors.white : AppColors.gray1,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: message.mediaUrl != null && File(message.mediaUrl!).existsSync()
            ? Image.file(
                File(message.mediaUrl!),
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.gray4,
                child: const Center(
                  child: Icon(Icons.image, color: AppColors.gray3, size: 48),
                ),
              ),
      ),
    );
  }

  Widget _buildMessageStatus() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.gray3,
          ),
        ),
        if (isSelf) ...[
          const SizedBox(width: 4),
          _buildStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (message.sendStatus) {
      case ChatSendStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.gray3,
          ),
        );
      case ChatSendStatus.sent:
        return const Icon(Icons.done, size: 14, color: AppColors.gray3);
      case ChatSendStatus.failed:
        return GestureDetector(
          onTap: onRetry,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 14, color: AppColors.red),
              SizedBox(width: 2),
              Text(
                '重试',
                style: TextStyle(fontSize: 11, color: AppColors.red),
              ),
            ],
          ),
        );
      case ChatSendStatus.read:
        return const Icon(Icons.done_all, size: 14, color: AppColors.blue);
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
