import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/anniversary_reminder_controller.dart';
import '../models/anniversary_model.dart';

/// 纪念日提醒设置页
class AnniversaryReminderSettingsPage extends StatefulWidget {
  const AnniversaryReminderSettingsPage({super.key});

  @override
  State<AnniversaryReminderSettingsPage> createState() =>
      _AnniversaryReminderSettingsPageState();
}

class _AnniversaryReminderSettingsPageState
    extends State<AnniversaryReminderSettingsPage> {
  late final AnniversaryReminderController _controller;

  @override
  void initState() {
    super.initState();
    // 注册控制器
    _controller = Get.put(AnniversaryReminderController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒设置'),
        elevation: 0,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 全局通知开关
            _buildGlobalSwitch(),
            const SizedBox(height: 24),

            // 提前提醒天数选择
            _buildAdvanceDaysSelector(),
            const SizedBox(height: 24),

            // 提醒时间选择
            _buildTimeSelector(),
            const SizedBox(height: 24),

            // 测试通知按钮
            _buildTestButton(),
            const SizedBox(height: 24),

            // 分隔线
            const Divider(height: 1),
            const SizedBox(height: 16),

            // 各纪念日独立提醒开关
            _buildAnniversaryListHeader(),
            const SizedBox(height: 8),

            // 纪念日列表
            _buildAnniversaryList(),
          ],
        );
      }),
    );
  }

  /// 全局通知开关
  Widget _buildGlobalSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '开启提醒',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '接收纪念日推送通知',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _controller.isNotificationEnabled.value,
            onChanged: (value) => _controller.toggleNotification(value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// 提前提醒天数选择
  Widget _buildAdvanceDaysSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '提前提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [1, 3, 7].map((days) {
              final isSelected = _controller.advanceDays.value == days;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _controller.updateAdvanceDays(days),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.gray4,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$days 天',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.gray2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 提醒时间选择
  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColors.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '提醒时间',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray1,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showTimePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    _controller.reminderTimeString,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示时间选择器
  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _controller.reminderHour.value,
        minute: _controller.reminderMinute.value,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _controller.updateReminderTime(picked.hour, picked.minute);
    }
  }

  /// 测试通知按钮
  Widget _buildTestButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.send,
                  color: AppColors.green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '测试通知',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '发送一条测试通知',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _onTestNotification,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  /// 测试通知点击
  Future<void> _onTestNotification() async {
    final success = await _controller.testNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '测试通知已发送' : '发送失败，请检查权限'),
          backgroundColor: success ? AppColors.green : AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// 纪念日列表标题
  Widget _buildAnniversaryListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '各纪念日提醒',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.gray1,
          ),
        ),
        Obx(() => Text(
              '${_controller.upcomingAnniversaries.length} 个纪念日',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray3,
              ),
            )),
      ],
    );
  }

  /// 纪念日列表
  Widget _buildAnniversaryList() {
    if (_controller.upcomingAnniversaries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.event_note,
                size: 48,
                color: AppColors.gray3,
              ),
              SizedBox(height: 8),
              Text(
                '暂无纪念日',
                style: TextStyle(
                  color: AppColors.gray3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _controller.upcomingAnniversaries
          .map((anniversary) => _buildAnniversaryItem(anniversary))
          .toList(),
    );
  }

  /// 单个纪念日提醒项
  Widget _buildAnniversaryItem(Anniversary anniversary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 类型图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor(anniversary.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                anniversary.type.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anniversary.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_controller.advanceDays.value} 天前提醒 · ${_controller.reminderTimeString}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray3,
                  ),
                ),
              ],
            ),
          ),
          // 开关
          Obx(() => Switch(
                value: anniversary.reminderEnabled,
                onChanged: (value) async {
                  final updated = anniversary.copyWith(reminderEnabled: value);
                  if (value) {
                    await _controller.scheduleReminderFor(updated);
                  } else {
                    await _controller.cancelReminder(anniversary.objectId);
                  }
                  await _controller.loadUpcoming();
                },
                activeColor: AppColors.primary,
              )),
        ],
      ),
    );
  }

  /// 获取类型颜色
  Color _getTypeColor(AnniversaryType type) {
    switch (type) {
      case AnniversaryType.love:
        return AppColors.primary;
      case AnniversaryType.birthday:
        return AppColors.orange;
      case AnniversaryType.firstMet:
        return AppColors.purple;
      case AnniversaryType.custom:
        return AppColors.blue;
    }
  }
}
