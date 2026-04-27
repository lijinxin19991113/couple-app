import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/anniversary_controller.dart';
import '../models/anniversary_model.dart';

/// 纪念日表单页（新增/编辑）
class AnniversaryFormPage extends StatefulWidget {
  final AnniversaryModel? anniversary;

  const AnniversaryFormPage({super.key, this.anniversary});

  @override
  State<AnniversaryFormPage> createState() => _AnniversaryFormPageState();
}

class _AnniversaryFormPageState extends State<AnniversaryFormPage> {
  final _controller = Get.find<AnniversaryController>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  AnniversaryType _selectedType = AnniversaryType.love;
  RepeatType _selectedRepeatType = RepeatType.yearly;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  bool get _isEditing => widget.anniversary != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadData();
    }
  }

  void _loadData() {
    final a = widget.anniversary!;
    _titleController.text = a.title;
    _noteController.text = a.note ?? '';
    _selectedDate = a.date;
    _selectedType = a.type;
    _selectedRepeatType = a.repeatType;
    _reminderEnabled = a.reminderEnabled;
    if (a.reminderTime != null) {
      _reminderTime = TimeOfDay(hour: a.reminderTime!.hour, minute: a.reminderTime!.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑纪念日' : '新增纪念日'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            _buildSectionTitle('标题'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '给纪念日起个名字',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
            ),
            const SizedBox(height: 20),

            // 日期
            _buildSectionTitle('日期'),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.gray3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 类型
            _buildSectionTitle('类型'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AnniversaryType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        Text(type.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.gray2,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 重复规则
            _buildSectionTitle('重复规则'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: RepeatType.values.map((type) {
                final isSelected = _selectedRepeatType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRepeatType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.purple.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.purple : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected ? AppColors.purple : AppColors.gray2,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 提醒开关
            _buildSectionTitle('提醒'),
            SwitchListTile(
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
              title: const Text('启用提醒'),
              subtitle: _reminderEnabled
                  ? Text('提醒时间: ${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}')
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            if (_reminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('提醒时间'),
                trailing: TextButton(
                  onPressed: _selectReminderTime,
                  child: Text(
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // 备注
            _buildSectionTitle('备注'),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '添加备注...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isEditing ? '保存修改' : '创建纪念日',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 16),
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

  /// 选择日期
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  /// 选择提醒时间
  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  /// 保存
  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('提示', '请输入标题');
      return;
    }

    setState(() => _isLoading = true);

    try {
      DateTime? reminderDateTime;
      if (_reminderEnabled) {
        reminderDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      }

      bool success;
      if (_isEditing) {
        success = await _controller.updateAnniversary(
          widget.anniversary!.id,
          {
            'relationId': widget.anniversary!.relationId,
            'title': title,
            'date': _selectedDate,
            'type': _selectedType,
            'repeatType': _selectedRepeatType,
            'reminderEnabled': _reminderEnabled,
            'reminderTime': reminderDateTime,
            'note': _noteController.text.trim(),
          },
        );
      } else {
        success = await _controller.createAnniversary(
          title: title,
          date: _selectedDate,
          type: _selectedType,
          repeatType: _selectedRepeatType,
          reminderEnabled: _reminderEnabled,
          reminderTime: reminderDateTime,
          note: _noteController.text.trim(),
        );
      }

      if (!mounted) return;
      if (success) {
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('提示', '保存失败，请稍后重试');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 确认删除
  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个纪念日吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _delete();
            },
            child: const Text('删除', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  /// 删除
  Future<void> _delete() async {
    if (_isEditing) {
      setState(() => _isLoading = true);
      try {
        final success = await _controller.deleteAnniversary(widget.anniversary!.id);
        if (!mounted) return;
        if (success) {
          Get.back();
        }
      } catch (e) {
        if (mounted) {
          Get.snackbar('提示', '删除失败，请稍后重试');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
