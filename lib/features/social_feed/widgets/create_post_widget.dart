import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/feed_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_border_radius.dart';

class CreatePostWidget extends ConsumerStatefulWidget {
  final VoidCallback onPostCreated;

  const CreatePostWidget({
    Key? key,
    required this.onPostCreated,
  }) : super(key: key);

  @override
  ConsumerState<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends ConsumerState<CreatePostWidget> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<File> _selectedMedia = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _locationController.dispose();
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
            _buildTextInput(),
            const SizedBox(height: 16),
            _buildLocationInput(),
            const SizedBox(height: 16),
            _buildTagsInput(),
            const SizedBox(height: 16),
            _buildMediaSection(),
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
          '發布動態',
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

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: '分享你的想法...',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildLocationInput() {
    return TextField(
      controller: _locationController,
      decoration: const InputDecoration(
        hintText: '添加位置（可選）',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
        prefixIcon: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildTagsInput() {
    return TextField(
      controller: _tagsController,
      decoration: const InputDecoration(
        hintText: '添加標籤，用空格分隔（可選）',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12),
        prefixIcon: Icon(Icons.tag),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '媒體內容',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showMediaPicker,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('添加'),
            ),
          ],
        ),
        if (_selectedMedia.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildMediaPreview(),
        ],
      ],
    );
  }

  Widget _buildMediaPreview() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedMedia.length,
        itemBuilder: (context, index) {
          final file = _selectedMedia[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  child: Image.file(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
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
        },
      ),
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
            onPressed: _isLoading ? null : _publishPost,
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
                : const Text('發布'),
          ),
        ),
      ],
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('從相冊選擇'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('錄製視頻'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('從相冊選擇視頻'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickMedia(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedMedia.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('選擇圖片失敗: $e');
    }
  }

  void _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: source);
      if (video != null) {
        setState(() {
          _selectedMedia.add(File(video.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('選擇視頻失敗: $e');
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  void _publishPost() async {
    final textContent = _textController.text.trim();
    final location = _locationController.text.trim();
    final tagsText = _tagsController.text.trim();

    if (textContent.isEmpty && _selectedMedia.isEmpty) {
      _showErrorSnackBar('請輸入內容或選擇媒體');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = tagsText.isNotEmpty 
          ? tagsText.split(' ').where((tag) => tag.isNotEmpty).toList()
          : <String>[];

      await ref.read(feedServiceProvider).createPost(
        textContent: textContent.isNotEmpty ? textContent : null,
        mediaFiles: _selectedMedia.isNotEmpty ? _selectedMedia : null,
        tags: tags.isNotEmpty ? tags : null,
        location: location.isNotEmpty ? location : null,
      );

      Navigator.pop(context);
      widget.onPostCreated();
    } catch (e) {
      _showErrorSnackBar('發布失敗: $e');
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