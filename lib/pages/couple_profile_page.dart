import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/user_controller.dart';

/// 情侣档案页面
class CoupleProfilePage extends StatefulWidget {
  const CoupleProfilePage({super.key});

  @override
  State<CoupleProfilePage> createState() => _CoupleProfilePageState();
}

class _CoupleProfilePageState extends State<CoupleProfilePage> {
  final _cpNameController = TextEditingController();
  DateTime? _anniversaryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCoupleData();
  }

  void _loadCoupleData() {
    final userController = Get.find<UserController>();
    final couple = userController.coupleRelation.value;
    if (couple != null) {
      _cpNameController.text = couple.coupleName ?? '';
      _anniversaryDate = couple.anniversaryDate;
    }
  }

  @override
  void dispose() {
    _cpNameController.dispose();
    super.dispose();
  }

  /// 选择纪念日
  Future<void> _selectAnniversary() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _anniversaryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (!mounted || date == null) return;
    setState(() => _anniversaryDate = date);
  }

  /// 保存
  Future<void> _save() async {
    setState(() => _isLoading = true);

    try {
      final userController = Get.find<UserController>();

      // 更新CP名称
      // TODO: 调用接口保存

      // 设置纪念日
      if (_anniversaryDate != null) {
        final success = await userController.setAnniversary(_anniversaryDate!);
        if (!success) {
          if (!mounted) return;
          Get.snackbar('保存失败', '纪念日保存失败，请稍后重试');
          return;
        }
      }

      if (!mounted) return;
      Get.snackbar('保存成功', '情侣档案已更新 💕');
      Get.back();
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('保存失败', '网络异常，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 解绑
  Future<void> _unbind() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认解绑'),
        content: const Text('确定要解除情侣关系吗？解绑后所有共同数据将被保留，但你们将不再显示为情侣。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认解绑'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      final userController = Get.find<UserController>();
      final success = await userController.unbindCouple();
      if (!mounted) return;
      if (success) {
        Get.snackbar('已解绑', '你们已不再是情侣关系');
        Get.back();
      } else {
        Get.snackbar('解绑失败', '请稍后重试');
      }
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('解绑失败', '网络异常，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final couple = userController.coupleRelation.value;
    final myUser = userController.currentUser.value;
    final partner = couple?.userA?.id == myUser?.id ? couple?.userB : couple?.userA;
    final myAvatar = myUser?.avatar;
    final partnerAvatar = partner?.avatar;
    final hasMyAvatar = myAvatar != null && myAvatar.isNotEmpty;
    final hasPartnerAvatar = partnerAvatar != null && partnerAvatar.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('情侣档案'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 双方头像
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 我的头像
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage:
                            hasMyAvatar ? NetworkImage(myAvatar!) as ImageProvider : null,
                        child: !hasMyAvatar
                            ? Text(
                                myUser?.nickname.isNotEmpty == true
                                    ? myUser!.nickname.substring(0, 1)
                                    : '我',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(myUser?.nickname ?? '我', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // 心形
                  const Icon(Icons.favorite, color: AppColors.primary, size: 32),
                  const SizedBox(width: 24),
                  // 对方头像
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.pink.withOpacity(0.1),
                        backgroundImage: hasPartnerAvatar
                            ? NetworkImage(partnerAvatar!) as ImageProvider
                            : null,
                        child: !hasPartnerAvatar
                            ? Text(
                                partner?.nickname.isNotEmpty == true
                                    ? partner!.nickname.substring(0, 1)
                                    : 'TA',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pink,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(partner?.nickname ?? 'TA', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // CP名称
            _buildSectionTitle('CP 昵称'),
            TextField(
              controller: _cpNameController,
              decoration: const InputDecoration(
                hintText: '给你们的关系起个昵称吧',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 24),

            // 纪念日
            _buildSectionTitle('纪念日'),
            InkWell(
              onTap: _selectAnniversary,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _anniversaryDate != null
                          ? '${_anniversaryDate!.year}年${_anniversaryDate!.month}月${_anniversaryDate!.day}日'
                          : '设置你们的纪念日',
                      style: TextStyle(
                        color: _anniversaryDate != null ? Colors.black : AppColors.gray3,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.gray3),
                  ],
                ),
              ),
            ),

            // 在一起天数
            if (_anniversaryDate != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      '在一起',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final days = userController.daysTogether;
                      return Text(
                        '$days 天',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),

            // 解绑按钮
            Center(
              child: TextButton(
                onPressed: _unbind,
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: const Text('解除情侣关系'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gray1,
        ),
      ),
    );
  }
}
