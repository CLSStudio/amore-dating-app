import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

class PhotoManagementWidget extends StatefulWidget {
  final List<String> photos;
  final bool isEditable;
  final Function(List<String>) onPhotosChanged;

  const PhotoManagementWidget({
    super.key,
    required this.photos,
    required this.isEditable,
    required this.onPhotosChanged,
  });

  @override
  State<PhotoManagementWidget> createState() => _PhotoManagementWidgetState();
}

class _PhotoManagementWidgetState extends State<PhotoManagementWidget>
    with TickerProviderStateMixin {
  
  late List<String> _photos;
  final ImagePicker _imagePicker = ImagePicker();
  
  late AnimationController _gridAnimationController;
  late AnimationController _addButtonAnimationController;
  
  late Animation<double> _gridScaleAnimation;
  late Animation<double> _addButtonRotationAnimation;
  
  int? _draggedIndex;
  bool _isUploading = false;
  
  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.photos);
    _setupAnimations();
  }

  void _setupAnimations() {
    _gridAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _addButtonAnimationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _gridScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _gridAnimationController, curve: Curves.elasticOut),
    );

    _addButtonRotationAnimation = Tween<double>(begin: 0, end: 0.25).animate(
      CurvedAnimation(parent: _addButtonAnimationController, curve: Curves.easeInOut),
    );

    _gridAnimationController.forward();
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _addButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildPhotoGrid(),
          if (widget.isEditable) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildPhotosActions(),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildPhotoTips(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: const Icon(
            Icons.photo_library,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的照片',
                style: AppTextStyles.h4,
              ),
              Text(
                '${_photos.length}/6 張照片',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.isEditable)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              '可編輯',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return AnimatedBuilder(
      animation: _gridAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _gridScaleAnimation.value,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              boxShadow: AppShadows.medium,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              child: _buildPhotoGridLayout(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoGridLayout() {
    if (_photos.isEmpty) {
      return _buildEmptyPhotoGrid();
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 6, // 最多6張照片
      itemBuilder: (context, index) {
        if (index < _photos.length) {
          return _buildPhotoItem(index);
        } else {
          return _buildAddPhotoSlot(index);
        }
      },
    );
  }

  Widget _buildEmptyPhotoGrid() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.textTertiary.withOpacity(0.1),
            AppColors.textTertiary.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '添加你的第一張照片',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '讓其他人更好地了解你',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            if (widget.isEditable) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: '添加照片',
                onPressed: _showPhotoSourceDialog,
                icon: Icons.add,
                type: AppButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    final isMainPhoto = index == 0;
    
    return GestureDetector(
      onTap: () => _viewPhoto(index),
      onLongPress: widget.isEditable ? () => _showPhotoOptions(index) : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: isMainPhoto
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 照片預覽
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            
            // 主要照片標記
            if (isMainPhoto)
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    '主要',
                    style: AppTextStyles.overline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            // 編輯模式操作按鈕
            if (widget.isEditable)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                        onPressed: () => _editPhoto(index),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                        onPressed: () => _deletePhoto(index),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            
            // 拖拽指示器
            if (widget.isEditable)
              Positioned(
                bottom: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: const Icon(
                    Icons.drag_handle,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoSlot(int index) {
    if (!widget.isEditable) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withOpacity(0.1),
        ),
      );
    }

    return GestureDetector(
      onTap: _showPhotoSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: AppColors.textTertiary.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _addButtonAnimationController,
            builder: (context, child) {
              return RotationTransition(
                turns: _addButtonRotationAnimation,
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '照片管理',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '添加照片',
                  onPressed: _isUploading ? null : _showPhotoSourceDialog,
                  icon: _isUploading ? null : Icons.add_photo_alternate,
                  type: AppButtonType.outline,
                  isLoading: _isUploading,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  text: '重新排序',
                  onPressed: _photos.length < 2 ? null : _enableReorderMode,
                  icon: Icons.swap_vert,
                  type: AppButtonType.ghost,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '第一張照片將作為主要照片顯示',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTips() {
    return AppCard(
      backgroundColor: AppColors.success.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '照片建議',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          ...[
            '至少上傳3張照片，增加配對機會',
            '包含一張清晰的面部照片',
            '展示你的興趣和生活方式',
            '避免過度修圖，保持真實',
            '定期更新照片保持新鮮感',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    tip,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showPhotoSourceDialog() {
    HapticFeedback.lightImpact();
    _addButtonAnimationController.forward().then((_) {
      _addButtonAnimationController.reverse();
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            const Text(
              '選擇照片來源',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    title: '拍照',
                    subtitle: '使用相機拍攝',
                    onTap: () => _pickPhoto(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    title: '相簿',
                    subtitle: '從相簿選擇',
                    onTap: () => _pickPhoto(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      setState(() => _isUploading = true);
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        // 模擬上傳過程
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _photos.add('new_photo_${DateTime.now().millisecondsSinceEpoch}');
        });
        
        widget.onPhotosChanged(_photos);
        
        _showSuccessMessage('照片添加成功！');
      }
    } catch (e) {
      _showErrorMessage('添加照片失敗，請重試');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _viewPhoto(int index) {
    // 查看照片大圖
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PhotoViewPage(
            photos: _photos,
            initialIndex: index,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showPhotoOptions(int index) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            const Text(
              '照片選項',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            if (index != 0)
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.primary),
                title: const Text('設為主要照片'),
                onTap: () => _setAsMainPhoto(index),
              ),
            
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.secondary),
              title: const Text('編輯照片'),
              onTap: () => _editPhoto(index),
            ),
            
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('刪除照片'),
              onTap: () => _confirmDeletePhoto(index),
            ),
          ],
        ),
      ),
    );
  }

  void _setAsMainPhoto(int index) {
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
    
    setState(() {
      final photo = _photos.removeAt(index);
      _photos.insert(0, photo);
    });
    
    widget.onPhotosChanged(_photos);
    _showSuccessMessage('已設為主要照片');
  }

  void _editPhoto(int index) {
    Navigator.pop(context);
    // 編輯照片邏輯
  }

  void _deletePhoto(int index) {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _photos.removeAt(index);
    });
    
    widget.onPhotosChanged(_photos);
    _showSuccessMessage('照片已刪除');
  }

  void _confirmDeletePhoto(int index) {
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('確定要刪除這張照片嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(index);
            },
            child: const Text(
              '刪除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _enableReorderMode() {
    // 啟用重新排序模式
    _showSuccessMessage('長按並拖拽照片來重新排序');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }
}

// 照片查看頁面
class PhotoViewPage extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const PhotoViewPage({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Center(
            child: Container(
              margin: AppSpacing.pagePadding,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 