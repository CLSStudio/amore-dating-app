import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PhotoUploadWidget extends StatefulWidget {
  final List<String> photos;
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;

  const PhotoUploadWidget({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
    this.maxPhotos = 6,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (widget.photos.length >= widget.maxPhotos) {
      _showMaxPhotosDialog();
      return;
    }

    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final newPhotos = List<String>.from(widget.photos);
        newPhotos.add(image.path);
        widget.onPhotosChanged(newPhotos);
        
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    } catch (e) {
      _showErrorDialog('上傳照片失敗，請重試');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '選擇照片來源',
          style: AppTextStyles.heading4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('拍照', style: AppTextStyles.body1),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('從相冊選擇', style: AppTextStyles.body1),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _removePhoto(int index) {
    final newPhotos = List<String>.from(widget.photos);
    newPhotos.removeAt(index);
    widget.onPhotosChanged(newPhotos);
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    
    final newPhotos = List<String>.from(widget.photos);
    final item = newPhotos.removeAt(oldIndex);
    newPhotos.insert(newIndex, item);
    widget.onPhotosChanged(newPhotos);
  }

  void _showMaxPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '照片數量限制',
          style: AppTextStyles.heading4,
        ),
        content: Text(
          '最多只能上傳 ${widget.maxPhotos} 張照片',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '確定',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '錯誤',
          style: AppTextStyles.heading4.copyWith(color: AppColors.error),
        ),
        content: Text(message, style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '確定',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 照片網格
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildPhotoGrid(),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // 提示信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '第一張照片將作為你的主要照片顯示。長按照片可以重新排序。',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.maxPhotos,
      itemBuilder: (context, index) {
        if (index < widget.photos.length) {
          return _buildPhotoItem(index);
        } else if (index == widget.photos.length) {
          return _buildAddPhotoButton();
        } else {
          return _buildEmptySlot();
        }
      },
    );
  }

  Widget _buildPhotoItem(int index) {
    final isMainPhoto = index == 0;
    
    return GestureDetector(
      onLongPress: () => _showPhotoOptions(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMainPhoto ? AppColors.primary : AppColors.border,
            width: isMainPhoto ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // 照片
              Image.file(
                File(widget.photos[index]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
              
              // 主要照片標籤
              if (isMainPhoto)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '主要',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              
              // 刪除按鈕
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
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
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加照片',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textHint,
        size: 32,
      ),
    );
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '照片選項',
              style: AppTextStyles.heading4,
            ),
            
            const SizedBox(height: 20),
            
            if (index > 0)
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.primary),
                title: const Text('設為主要照片', style: AppTextStyles.body1),
                onTap: () {
                  Navigator.pop(context);
                  _setAsMainPhoto(index);
                },
              ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('刪除照片', style: AppTextStyles.body1),
              onTap: () {
                Navigator.pop(context);
                _removePhoto(index);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _setAsMainPhoto(int index) {
    final newPhotos = List<String>.from(widget.photos);
    final photo = newPhotos.removeAt(index);
    newPhotos.insert(0, photo);
    widget.onPhotosChanged(newPhotos);
  }
} 