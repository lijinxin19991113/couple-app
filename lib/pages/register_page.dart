import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/auth_controller.dart';

/// 注册页
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  int _countdown = 0;
  Timer? _countdownTimer;
  String _selectedGender = 'male';

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _nicknameController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      Get.snackbar('提示', '请输入正确的手机号');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final success = await authController.sendCode(phone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _startCountdown();
      Get.snackbar('发送成功', '验证码已发送到您的手机');
    } else {
      Get.snackbar('发送失败', '验证码发送失败，请稍后重试');
    }
  }

  /// 倒计时（使用 Timer.periodic，dispose 时取消）
  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
      }
    });
  }

  /// 注册
  Future<void> _register() async {
    final phone = _phoneController.text.trim();
    final nickname = _nicknameController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (phone.isEmpty || phone.length != 11) {
      Get.snackbar('提示', '请输入正确的手机号');
      return;
    }
    if (nickname.isEmpty || nickname.length < 2) {
      Get.snackbar('提示', '请输入至少2个字符的昵称');
      return;
    }
    if (code.isEmpty || code.length != 6) {
      Get.snackbar('提示', '请输入6位验证码');
      return;
    }
    if (password.isEmpty || password.length < 6) {
      Get.snackbar('提示', '密码至少6位');
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar('提示', '两次密码输入不一致');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final success = await authController.register(
      phone: phone,
      nickname: nickname,
      code: code,
      password: password,
      gender: _selectedGender,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar('注册成功', '欢迎加入情侣日常');
    } else {
      Get.snackbar('注册失败', '注册失败，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('注册'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 手机号
              const Text(
                '手机号',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '请输入手机号',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),

              // 验证码
              const Text(
                '验证码',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: '请输入验证码',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading || _countdown > 0 ? null : _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _countdown > 0 ? AppColors.gray4 : AppColors.primary,
                      ),
                      child: Text(_countdown > 0 ? '${_countdown}s' : '获取验证码'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 昵称
              const Text(
                '昵称',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  hintText: '请输入昵称（2-20字符）',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),

              // 性别选择
              const Text(
                '性别',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderChip('male', '男', Icons.male),
                  const SizedBox(width: 16),
                  _buildGenderChip('female', '女', Icons.female),
                ],
              ),
              const SizedBox(height: 16),

              // 密码
              const Text(
                '密码',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '请输入密码（至少6位）',
                ),
              ),
              const SizedBox(height: 16),

              // 确认密码
              const Text(
                '确认密码',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '请再次输入密码',
                ),
              ),
              const SizedBox(height: 32),

              // 注册按钮
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('注册', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),

              // 登录入口
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('已有账号？', style: TextStyle(color: AppColors.gray3)),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('立即登录'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.gray4,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.gray3),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.gray2,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
