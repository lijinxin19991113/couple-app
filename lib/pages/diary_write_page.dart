import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/colors.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry_model.dart';

/// 日记编辑页
class DiaryWritePage extends StatefulWidget {
  const DiaryWritePage({super.key});

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  final DiaryController _diaryController = Get.find<DiaryController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DiaryMoodType _selectedMood = DiaryMoodType.calm;
  WeatherType _selectedWeather = WeatherType.sunny;
  bool _isPrivate = false;
  List<String> _imageUrls = [];
  DiaryEntry? _editingEntry;

  bool get _isEditing => _editingEntry != null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['date'] != null) {
        _recordDate = args['date'] as DateTime;
      }
      if (args['entry'] != null) {
        _editingEntry = args['entry'] as DiaryEntry;
        _titleController.text = _editingEntry!.title;
        _contentController.text = _editingEntry!.content;
        _locationController.text = _editingEntry!.locationText ?? '';
        _selectedMood = _editingEntry!.moodType;
        _selectedWeather = _editingEntry!.weather;
        _isPrivate = _editingEntry!.isPrivate;
        _imageUrls = List.from(_editingEntry!.imageUrls);
        _recordDate = _editingEntry!.recordDate;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑日记' : '写日记'),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期选择
            _DateSelector(
              date: _recordDate,
              onChanged: (date) {
                setState(() {
                  _recordDate = date;
                });
              },
            ),

            const SizedBox(height: 20),

            // 标题输入
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '标题',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLength: 50,
            ),

            const SizedBox(height: 16),

            // 正文输入
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: '记录今天的点点滴滴...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 8,
              minLines: 5,
              maxLength: 2000,
            ),

            const SizedBox(height: 20),

            // 配图
            _ImageSelector(
              imageUrls: _imageUrls,
              maxImages: 9,
              onChanged: (urls) {
                setState(() {
                  _imageUrls = urls;
                });
              },
            ),

            const SizedBox(height: 20),

            // 心情选择
            _SectionTitle(title: '心情'),
            const SizedBox(height: 12),
            _MoodSelector(
              selectedMood: _selectedMood,
              onChanged: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),

            const SizedBox(height: 20),

            // 天气选择
            _SectionTitle(title: '天气'),
            const SizedBox(height: 12),
            _WeatherSelector(
              selectedWeather: _selectedWeather,
              onChanged: (weather) {
                setState(() {
                  _selectedWeather = weather;
                });
              },
            ),

            const SizedBox(height: 20),

            // 位置
            _SectionTitle(title: '位置'),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: '添加位置',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLength: 50,
            ),

            const SizedBox(height: 20),

            // 私密开关
            _PrivacyToggle(
              isPrivate: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDiary() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('提示', '请输入标题');
      return;
    }

    if (content.isEmpty) {
      Get.snackbar('提示', '请输入内容');
      return;
    }

    try {
      if (_isEditing) {
        await _diaryController.updateEntry(
          id: _editingEntry!.objectId,
          title: title,
          content: content,
          imageUrls: _imageUrls,
          moodType: _selectedMood,
          weather: _selectedWeather,
          locationText: location.isEmpty ? null : location,
          isPrivate: _isPrivate,
        );
      } else {
        await _diaryController.createEntry(
          title: title,
          content: content,
          imageUrls: _imageUrls,
          moodType: _selectedMood,
          weather: _selectedWeather,
          locationText: location.isEmpty ? null : location,
          isPrivate: _isPrivate,
          recordDate: _recordDate,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('错误', '保存日记失败，请稍后重试');
      }
      return;
    }

    if (!mounted) return;
    Get.back();
  }
}

/// 日期选择器
class _DateSelector extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DateSelector({
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (selected != null) {
          onChanged(selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.gray3, size: 20),
            const SizedBox(width: 12),
            Text(
              '${date.year}年${date.month}月${date.day}日',
              style: const TextStyle(fontSize: 16, color: AppColors.gray1),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.gray4),
          ],
        ),
      ),
    );
  }
}

/// 区块标题
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gray1,
      ),
    );
  }
}

/// 心情选择器
class _MoodSelector extends StatelessWidget {
  final DiaryMoodType selectedMood;
  final ValueChanged<DiaryMoodType> onChanged;

  const _MoodSelector({
    required this.selectedMood,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: DiaryMoodType.values.map((mood) {
        final isSelected = mood == selectedMood;
        return GestureDetector(
          onTap: () => onChanged(mood),
          child: Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.gray5,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : AppColors.gray2,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 天气选择器
class _WeatherSelector extends StatelessWidget {
  final WeatherType selectedWeather;
  final ValueChanged<WeatherType> onChanged;

  const _WeatherSelector({
    required this.selectedWeather,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: WeatherType.values.map((weather) {
        final isSelected = weather == selectedWeather;
        return GestureDetector(
          onTap: () => onChanged(weather),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.gray5,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(weather.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  weather.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? AppColors.primary : AppColors.gray2,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 配图选择器
class _ImageSelector extends StatelessWidget {
  final List<String> imageUrls;
  final int maxImages;
  final ValueChanged<List<String>> onChanged;

  const _ImageSelector({
    required this.imageUrls,
    required this.maxImages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle(title: '配图'),
            const SizedBox(width: 8),
            Text(
              '(${imageUrls.length}/$maxImages)',
              style: const TextStyle(fontSize: 14, color: AppColors.gray4),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (imageUrls.length < maxImages)
                GestureDetector(
                  onTap: () => _addImage(context),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gray5,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gray4, width: 1),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: AppColors.gray3, size: 32),
                        SizedBox(height: 4),
                        Text('添加', style: TextStyle(fontSize: 12, color: AppColors.gray3)),
                      ],
                    ),
                  ),
                ),
              ...imageUrls.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          entry.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: AppColors.gray5,
                            child: const Icon(Icons.image, color: AppColors.gray4),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            final newUrls = List<String>.from(imageUrls);
                            newUrls.removeAt(entry.key);
                            onChanged(newUrls);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _addImage(BuildContext context) {
    // Mock: 添加示例图片
    final mockImages = [
      'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=700&q=80',
      'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=700&q=80',
      'https://images.unsplash.com/photo-1532634922-8fe0b757fb13?auto=format&fit=crop&w=700&q=80',
      'https://images.unsplash.com/photo-1518199266791-5375a83190b7?auto=format&fit=crop&w=700&q=80',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '添加图片（Mock）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mockImages.map((url) {
                return GestureDetector(
                  onTap: () {
                    final newUrls = List<String>.from(imageUrls);
                    newUrls.add(url);
                    onChanged(newUrls);
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 私密开关
class _PrivacyToggle extends StatelessWidget {
  final bool isPrivate;
  final ValueChanged<bool> onChanged;

  const _PrivacyToggle({
    required this.isPrivate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPrivate ? Icons.lock : Icons.public,
            color: isPrivate ? AppColors.orange : AppColors.gray3,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPrivate ? '仅自己可见' : '公开',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray1,
                  ),
                ),
                Text(
                  isPrivate ? '只有你能看到这篇日记' : '伴侣可以看到这篇日记',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isPrivate,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
