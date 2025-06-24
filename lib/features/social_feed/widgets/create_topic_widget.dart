import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feed_models.dart';
import '../services/topic_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_border_radius.dart';

class CreateTopicWidget extends ConsumerStatefulWidget {
  final VoidCallback onTopicCreated;

  const CreateTopicWidget({
    Key? key,
    required this.onTopicCreated,
  }) : super(key: key);

  @override
  ConsumerState<CreateTopicWidget> createState() => _CreateTopicWidgetState();
}

class _CreateTopicWidgetState extends ConsumerState<CreateTopicWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  TopicCategory _selectedCategory = TopicCategory.general;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.bottomSheet),
          topRight: Radius.circular(AppBorderRadius.bottomSheet),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildDescriptionInput(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildTagsInput(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          '創建話題',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '話題標題 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '輸入一個吸引人的話題標題...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLength: 50,
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '話題描述 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '詳細描述這個話題，讓大家了解討論的內容...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '話題分類 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TopicCategory>(
              value: _selectedCategory,
              isExpanded: true,
              onChanged: (TopicCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: TopicCategory.values.map((TopicCategory category) {
                return DropdownMenuItem<TopicCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '相關標籤',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '用空格分隔多個標籤（可選）',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tagsController,
          decoration: const InputDecoration(
            hintText: '例如：約會 香港 MBTI',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
            prefixIcon: Icon(Icons.tag),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createTopic,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('創建'),
          ),
        ),
      ],
    );
  }

  void _createTopic() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final tagsText = _tagsController.text.trim();

    if (title.isEmpty) {
      _showErrorSnackBar('請輸入話題標題');
      return;
    }

    if (description.isEmpty) {
      _showErrorSnackBar('請輸入話題描述');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = tagsText.isNotEmpty 
          ? tagsText.split(' ').where((tag) => tag.isNotEmpty).toList()
          : <String>[];

      await ref.read(topicServiceProvider).createTopic(
        title: title,
        description: description,
        category: _selectedCategory,
        tags: tags.isNotEmpty ? tags : null,
      );

      Navigator.pop(context);
      widget.onTopicCreated();
    } catch (e) {
      _showErrorSnackBar('創建話題失敗: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: AppSpacing.pagePadding,
      ),
    );
  }
} 