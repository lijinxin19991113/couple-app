import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/colors.dart';
import '../controllers/user_controller.dart';

/// 用户资料编辑页面
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nicknameController = TextEditingController();
  final _signatureController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthday;
  String? _avatarPath;
  bool _isLoading = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final userController = Get.find<UserController>();
    final user = userController.currentUser.value;
    if (user != null) {
      _nicknameController.text = user.nickname;
      _signatureController.text = user.signature ?? '';
      _selectedGender = user.gender;
      _selectedBirthday = user.birthday;
      _avatarPath = user.avatar;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  /// 选择头像
  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) return;

      setState(() => _avatarPath = image.path);
      _markDirty();
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('选择失败', '无法读取相册图片，请检查权限设置');
    }
  }

  /// 选择性别
  void _selectGender(String? gender) {
    setState(() => _selectedGender = gender);
    _markDirty();
  }

  /// 选择生日
  Future<void> _selectBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted || date == null) return;
    setState(() => _selectedBirthday = date);
    _markDirty();
  }

  /// 保存资料
  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      Get.snackbar('提示', '请输入昵称');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userController = Get.find<UserController>();
      final success = await userController.updateUserInfo(
        nickname: nickname,
        avatar: _avatarPath,
        gender: _selectedGender,
        birthday: _selectedBirthday,
        signature: _signatureController.text.trim(),
      );

      if (!mounted) return;
      if (success) {
        Get.snackbar('保存成功', '资料已更新');
        Get.back();
      } else {
        Get.snackbar('保存失败', '请稍后重试');
      }
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('保存失败', '网络异常，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
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
          children: [
            // 头像
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _avatarPath != null && _avatarPath!.startsWith('/')
                          ? FileImage(File(_avatarPath!)) as ImageProvider
                          : null,
                      child: _avatarPath == null || !_avatarPath!.startsWith('/')
                          ? const Icon(Icons.person, size: 50, color: AppColors.gray3)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击更换头像',
              style: TextStyle(fontSize: 12, color: AppColors.gray3),
            ),
            const SizedBox(height: 24),

            // 昵称
            _buildSectionTitle('昵称'),
            TextField(
              controller: _nicknameController,
              onChanged: (_) => _markDirty(),
              decoration: const InputDecoration(
                hintText: '请输入昵称',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16),

            // 性别
            _buildSectionTitle('性别'),
            Row(
              children: [
                _buildGenderChip('male', '男', Icons.male),
                const SizedBox(width: 12),
                _buildGenderChip('female', '女', Icons.female),
                const SizedBox(width: 12),
                _buildGenderChip('other', '其他', Icons.transgender),
              ],
            ),
            const SizedBox(height: 24),

            // 生日
            _buildSectionTitle('生日'),
            InkWell(
              onTap: _selectBirthday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedBirthday != null
                          ? '${_selectedBirthday!.year}-${_selectedBirthday!.month.toString().padLeft(2, '0')}-${_selectedBirthday!.day.toString().padLeft(2, '0')}'
                          : '请选择生日',
                      style: TextStyle(
                        color: _selectedBirthday != null ? Colors.black : AppColors.gray3,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.gray3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 个性签名
            _buildSectionTitle('个性签名'),
            TextField(
              controller: _signatureController,
              onChanged: (_) => _markDirty(),
              decoration: const InputDecoration(
                hintText: '这个人很懒，什么都没写',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.gray1,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => _selectGender(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.gray3,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.gray2,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
