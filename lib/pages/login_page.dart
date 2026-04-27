import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../config/routes.dart';
import '../controllers/auth_controller.dart';

/// 登录页
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
      Get.snackbar('提示', '请输入正确的手机号');
      return;
    }

    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final success = await authController.sendCode(phone);

    setState(() => _isLoading = false);

    if (success) {
      _startCountdown();
      Get.snackbar('发送成功', '验证码已发送到您的手机');
    } else {
      Get.snackbar('发送失败', '验证码发送失败，请稍后重试');
    }
  }

  /// 倒计时
  void _startCountdown() {
    setState(() => _countdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _countdown--);
      }
      return _countdown > 0;
    });
  }

  /// 登录
  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty || phone.length != 11) {
      Get.snackbar('提示', '请输入正确的手机号');
      return;
    }
    if (code.isEmpty || code.length != 6) {
      Get.snackbar('提示', '请输入6位验证码');
      return;
    }

    setState(() => _isLoading = true);

    final authController = Get.find<AuthController>();
    final success = await authController.loginWithCode(phone, code);

    setState(() => _isLoading = false);

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar('登录失败', '验证码错误或已过期');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 标题
              const Center(
                child: Text(
                  '欢迎回来',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  '登录后开始你们的甜蜜时光',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray3,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 手机号输入
              const Text(
                '手机号',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '请输入手机号',
                  counterText: '',
                  prefixIcon: Icon(Icons.phone_android, color: AppColors.gray3),
                ),
              ),
              const SizedBox(height: 16),

              // 验证码输入
              const Text(
                '验证码',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray1,
                ),
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
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.gray3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 发送验证码按钮
                  SizedBox(
                    width: 110,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading || _countdown > 0 ? null : _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _countdown > 0 ? AppColors.gray4 : AppColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        _countdown > 0 ? '${_countdown}s' : '获取验证码',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 登录按钮
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          '登录',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 注册入口
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '还没有账号？',
                    style: TextStyle(color: AppColors.gray3),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: const Text('立即注册'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 用户协议
              const Center(
                child: Text(
                  '登录即表示同意《用户协议》和《隐私政策》',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
