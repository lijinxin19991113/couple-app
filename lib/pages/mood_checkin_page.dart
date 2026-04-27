import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_record_model.dart';

/// 心情打卡页面
class MoodCheckinPage extends StatefulWidget {
  const MoodCheckinPage({super.key});

  @override
  State<MoodCheckinPage> createState() => _MoodCheckinPageState();
}

class _MoodCheckinPageState extends State<MoodCheckinPage> {
  final MoodController _controller = Get.find<MoodController>();

  // 编辑模式
  MoodRecord? _editingRecord;

  // 表单状态
  MoodType _selectedMood = MoodType.calm;
  double _moodScore = 3;
  final TextEditingController _contentController = TextEditingController();
  final List<String> _imageUrls = [];
  bool _visibleToPartner = true;

  @override
  void initState() {
    super.initState();
    // 检查是否是编辑模式
    if (Get.arguments is MoodRecord) {
      _editingRecord = Get.arguments as MoodRecord;
      _loadEditingRecord();
    }
  }

  void _loadEditingRecord() {
    if (_editingRecord != null) {
      _selectedMood = _editingRecord!.moodType;
      _moodScore = _editingRecord!.moodScore.toDouble();
      _contentController.text = _editingRecord!.content ?? '';
      _imageUrls.addAll(_editingRecord!.imageUrls);
      _visibleToPartner = _editingRecord!.visibleToPartner;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_editingRecord != null) {
      // 更新模式
      await _controller.updateMood(
        id: _editingRecord!.objectId,
        moodType: _selectedMood,
        moodScore: _moodScore.round(),
        content: _contentController.text.isEmpty ? null : _contentController.text,
        imageUrls: _imageUrls,
        visibleToPartner: _visibleToPartner,
      );
    } else {
      // 新建模式
      await _controller.checkin(
        moodType: _selectedMood,
        moodScore: _moodScore.round(),
        content: _contentController.text.isEmpty ? null : _contentController.text,
        imageUrls: _imageUrls,
        visibleToPartner: _visibleToPartner,
      );
    }

    if (_controller.isLoading.value == false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingRecord != null ? '编辑心情' : '记录心情'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 心情选择区
            const Text(
              '此刻心情',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray1,
              ),
            ),
            const SizedBox(height: 12),

            // 心情类型选择
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 表情选择网格
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: MoodType.values.map((mood) {
                      final isSelected = _selectedMood == mood;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.gray5,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getMoodEmoji(mood),
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.gray2,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // 分值滑块
                  Row(
                    children: [
                      const Text(
                        '心情分值',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_moodScore.round()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primaryLight,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _moodScore,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) => setState(() => _moodScore = value),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('1', style: TextStyle(fontSize: 12, color: AppColors.gray4)),
                      Text('2', style: TextStyle(fontSize: 12, color: AppColors.gray4)),
                      Text('3', style: TextStyle(fontSize: 12, color: AppColors.gray4)),
                      Text('4', style: TextStyle(fontSize: 12, color: AppColors.gray4)),
                      Text('5', style: TextStyle(fontSize: 12, color: AppColors.gray4)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 文案输入
            const Text(
              '记录此刻',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: '写下此刻的心情...',
                  hintStyle: TextStyle(color: AppColors.gray4),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  counterStyle: TextStyle(color: AppColors.gray4),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 图片配图
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '配图（可选）',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray1,
                  ),
                ),
                Text(
                  '最多3张',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_imageUrls.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _imageUrls.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                entry.value,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: AppColors.gray5,
                                  child: const Icon(Icons.image, color: AppColors.gray4),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _imageUrls.removeAt(entry.key));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  if (_imageUrls.length < 3) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _addImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.gray5,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gray4,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: AppColors.gray3),
                            SizedBox(height: 4),
                            Text(
                              '添加',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.gray3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 可见性开关
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _visibleToPartner ? Icons.visibility : Icons.visibility_off,
                        color: _visibleToPartner ? AppColors.primary : AppColors.gray4,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '对伴侣可见',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _visibleToPartner ? 'Ta 可以看到这条记录' : '仅自己可见',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _visibleToPartner,
                    onChanged: (value) => setState(() => _visibleToPartner = value),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 发布按钮
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.gray4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            _editingRecord != null ? '保存修改' : '发布',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.excited:
        return '🤩';
      case MoodType.calm:
        return '😌';
      case MoodType.worried:
        return '😟';
      case MoodType.sad:
        return '😢';
      case MoodType.angry:
        return '😠';
    }
  }

  void _addImage() {
    // TODO: 实现图片选择功能
    // 模拟添加一张图片
    if (_imageUrls.length < 3) {
      setState(() {
        _imageUrls.add('https://picsum.photos/200?random=${_imageUrls.length}');
      });
    }
  }
}
