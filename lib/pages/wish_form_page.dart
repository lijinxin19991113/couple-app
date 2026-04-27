import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/wish_controller.dart';
import '../models/wish_item_model.dart';
import '../config/colors.dart';

/// 愿望编辑页
class WishFormPage extends StatefulWidget {
  final WishItem? wishItem;

  const WishFormPage({super.key, this.wishItem});

  @override
  State<WishFormPage> createState() => _WishFormPageState();
}

class _WishFormPageState extends State<WishFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final WishController _controller = Get.find<WishController>();

  late WishCategory _selectedCategory;
  late WishPriority _selectedPriority;
  DateTime? _targetDate;

  bool get isEditing => widget.wishItem != null;

  @override
  void initState() {
    super.initState();
    if (widget.wishItem != null) {
      _titleController.text = widget.wishItem!.title;
      _descController.text = widget.wishItem!.description ?? '';
      _selectedCategory = widget.wishItem!.category;
      _selectedPriority = widget.wishItem!.priority;
      _targetDate = widget.wishItem!.targetDate;
    } else {
      _selectedCategory = WishCategory.other;
      _selectedPriority = WishPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? '编辑愿望' : '添加愿望'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 标题
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '愿望标题',
                hintText: '例如：去日本看樱花',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入愿望标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 描述
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '描述（可选）',
                hintText: '详细描述一下这个愿望...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // 分类选择
            const Text('分类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: WishCategory.values.map((cat) => _buildCategoryChip(cat)).toList(),
            ),
            const SizedBox(height: 24),

            // 优先级选择
            const Text('优先级', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: WishPriority.values.map((pri) => Expanded(child: _buildPriorityChip(pri))).toList(),
            ),
            const SizedBox(height: 24),

            // 目标日期
            const Text('目标日期（可选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _targetDate != null
                          ? DateFormat('yyyy-MM-dd').format(_targetDate!)
                          : '选择目标日期',
                      style: TextStyle(
                        fontSize: 16,
                        color: _targetDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _targetDate = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 保存按钮
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isEditing ? '保存修改' : '添加愿望', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(WishCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(WishPriority priority) {
    final isSelected = _selectedPriority == priority;
    final color = Color(priority.colorValue);
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            priority.label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? color : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (isEditing) {
      _controller.updateWish(
        id: widget.wishItem!.objectId,
        title: title,
        description: description.isEmpty ? null : description,
        category: _selectedCategory,
        priority: _selectedPriority,
        targetDate: _targetDate,
        clearTargetDate: _targetDate == null && widget.wishItem!.targetDate != null,
      );
    } else {
      _controller.addWish(
        title: title,
        description: description.isEmpty ? null : description,
        category: _selectedCategory,
        priority: _selectedPriority,
        targetDate: _targetDate,
      );
    }

    Get.back();
  }
}
