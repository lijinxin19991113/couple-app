import 'package:flutter/material.dart';

/// 应用颜色常量 - 粉色浪漫风格
class AppColors {
  AppColors._();

  // ===== 主题色 =====
  /// 主题粉 - 主色
  static const Color primary = Color(0xFFEC4899);

  /// 主题粉 - 浅色
  static const Color primaryLight = Color(0xFFF9A8D4);

  /// 主题粉 - 深色
  static const Color primaryDark = Color(0xFFDB2777);

  // ===== 辅助色 =====
  /// 紫色（用于心情、愿望等模块）
  static const Color purple = Color(0xFF8B5CF6);

  /// 蓝色（用于位置、消息等模块）
  static const Color blue = Color(0xFF4A9EED);

  /// 绿色（成功、心情好）
  static const Color green = Color(0xFF22C55E);

  /// 橙色（警告、纪念日）
  static const Color orange = Color(0xFFF59E0B);

  /// 红色（错误、取消）
  static const Color red = Color(0xFFEF4444);

  // ===== 中性色 =====
  /// 纯黑
  static const Color black = Color(0xFF000000);

  /// 深灰
  static const Color gray1 = Color(0xFF1F2937);

  /// 中灰
  static const Color gray2 = Color(0xFF4B5563);

  /// 浅灰
  static const Color gray3 = Color(0xFF9CA3AF);

  /// 背景灰
  static const Color gray4 = Color(0xFFF3F4F6);

  /// 分割线灰
  static const Color gray5 = Color(0xFFE5E7EB);

  /// 纯白
  static const Color white = Color(0xFFFFFFFF);

  // ===== 背景色 =====
  /// 页面背景
  static const Color background = Color(0xFFFAFBFF);

  /// 卡片背景
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// 弹窗遮罩
  static const Color overlay = Color(0x80000000);

  // ===== 心情色 =====
  /// 超开心
  static const Color moodHappy = Color(0xFF22C55E);

  /// 开心
  static const Color moodGood = Color(0xFF4A9EED);

  /// 一般
  static const Color moodNormal = Color(0xFFF59E0B);

  /// 有点丧
  static const Color moodSad = Color(0xFFF97316);

  /// 难过
  static const Color moodBad = Color(0xFFEF4444);

  // ===== 渐变色 =====
  /// 主题渐变（登录页等使用）
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF9A8D4), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 心情渐变
  static const LinearGradient moodGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
