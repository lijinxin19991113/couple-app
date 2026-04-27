import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../config/routes.dart';
import '../../controllers/user_controller.dart';

/// 情侣绑定页面
class CoupleBindPage extends StatefulWidget {
  const CoupleBindPage({super.key});

  @override
  State<CoupleBindPage> createState() => _CoupleBindPageState();
}

class _CoupleBindPageState extends State<CoupleBindPage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _generatedCode;
  bool _showInput = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 生成邀请码
  Future<void> _generateInviteCode() async {
    setState(() => _isLoading = true);
    try {
      final userController = Get.find<UserController>();
      final code = await userController.createCoupleInvite();

      if (!mounted) return;
      setState(() => _generatedCode = code);

      if (code == null) {
        Get.snackbar('生成失败', '邀请码生成失败，请稍后重试');
      }
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('生成失败', '邀请码生成失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 复制邀请码
  void _copyCode() {
    if (_generatedCode == null) return;
    Clipboard.setData(ClipboardData(text: _generatedCode!));
    Get.snackbar('已复制', '邀请码已复制到剪贴板');
  }

  /// 确认绑定
  Future<void> _confirmBind() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      Get.snackbar('提示', '请输入邀请码');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userController = Get.find<UserController>();
      final success = await userController.joinCouple(code);

      if (!mounted) return;
      if (success) {
        Get.snackbar('绑定成功', '你们现在是情侣啦 💕');
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar('绑定失败', '邀请码无效或已过期');
      }
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('绑定失败', '网络异常，请稍后重试');
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
        title: const Text('绑定情侣'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9A8D4), Color(0xFFEC4899)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // 头像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // 标题
                const Text(
                  '绑定你的另一半',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '生成邀请码发给对方，或输入对方的邀请码',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // 邀请码展示/输入区
                if (_showInput) ...[
                  // 输入模式
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _codeController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: '输入邀请码',
                            border: InputBorder.none,
                          ),
                          maxLength: 10,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _confirmBind,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('确认绑定'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _showInput = false),
                    child: const Text(
                      '返回生成邀请码',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ] else ...[
                  // 生成/展示模式
                  if (_generatedCode != null) ...[
                    // 已生成邀请码
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '你的邀请码',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _generatedCode!,
                                style: const TextStyle(
                                  fontSize: 32,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: _copyCode,
                                icon: const Icon(
                                  Icons.copy,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '复制发给对方，让TA输入',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showInput = true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('我有邀请码'),
                      ),
                    ),
                  ] else ...[
                    // 初始状态
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _generateInviteCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Text(
                                '生成邀请码',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _showInput = true),
                      child: const Text(
                        '我有邀请码',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
