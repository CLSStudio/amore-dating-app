import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'photo_upload_service.dart';

class PhotoManagementPage extends ConsumerStatefulWidget {
  const PhotoManagementPage({super.key});

  @override
  ConsumerState<PhotoManagementPage> createState() => _PhotoManagementPageState();
}

class _PhotoManagementPageState extends ConsumerState<PhotoManagementPage>
    with TickerProviderStateMixin {
  List<String> _photos = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  int _uploadingIndex = -1;

  late AnimationController _addButtonController;
  late Animation<double> _addButtonAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserPhotos();
  }

  void _setupAnimations() {
    _addButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addButtonAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _addButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _addButtonController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await PhotoUploadService.getUserPhotos();
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('載入照片失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildPhotoGrid(),
      floatingActionButton: _buildAddPhotoButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        '管理照片',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_photos.isNotEmpty)
          TextButton(
            onPressed: _reorderPhotos,
            child: const Text(
              '重新排序',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFE91E63),
          ),
          SizedBox(height: 16),
          Text(
            '載入照片中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructions(),
          const SizedBox(height: 24),
          _buildPhotoGridView(),
          const SizedBox(height: 24),
          _buildPhotoTips(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFFE91E63),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '照片管理指南',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• 第一張照片將作為您的主要照片\n'
            '• 建議上傳 3-6 張不同角度的照片\n'
            '• 照片會自動壓縮和優化\n'
            '• 長按照片可以刪除或重新排序',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6, // 最多 6 張照片
      itemBuilder: (context, index) {
        return _buildPhotoSlot(index);
      },
    );
  }

  Widget _buildPhotoSlot(int index) {
    final hasPhoto = index < _photos.length && _photos[index].isNotEmpty;
    final isUploading = _isUploading && _uploadingIndex == index;

    return GestureDetector(
      onTap: hasPhoto ? null : () => _addPhoto(index),
      onLongPress: hasPhoto ? () => _showPhotoOptions(index) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto 
                ? Colors.transparent 
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: hasPhoto ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              if (hasPhoto) ...[
                // 顯示照片
                Positioned.fill(
                  child: Image.network(
                    _photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.error,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                // 主要照片標籤
                if (index == 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '主要',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                // 空照片槽
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        index == 0 ? '添加主要照片' : '添加照片',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // 上傳進度指示器
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _uploadProgress,
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '上傳中 ${(_uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTips() {
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
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '照片建議',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('選擇清晰、光線良好的照片'),
          _buildTipItem('展示不同的角度和表情'),
          _buildTipItem('包含全身照和半身照'),
          _buildTipItem('避免過度修圖或濾鏡'),
          _buildTipItem('展示您的興趣愛好'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return AnimatedBuilder(
      animation: _addButtonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _addButtonAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _photos.length < 6 ? () => _addPhoto(_photos.length) : null,
            backgroundColor: _photos.length < 6 
                ? const Color(0xFFE91E63) 
                : Colors.grey,
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            label: Text(
              _photos.length < 6 ? '添加照片' : '已滿',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void _addPhoto(int index) async {
    _addButtonController.forward().then((_) {
      _addButtonController.reverse();
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPhotoSourceSheet(index),
    );
  }

  Widget _buildPhotoSourceSheet(int index) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '選擇照片來源',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSourceOption(
            icon: Icons.photo_camera,
            title: '拍照',
            subtitle: '使用相機拍攝新照片',
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, index);
            },
          ),
          _buildSourceOption(
            icon: Icons.photo_library,
            title: '從相冊選擇',
            subtitle: '從手機相冊中選擇照片',
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, index);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFE91E63),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _pickImage(ImageSource source, int index) async {
    try {
      final XFile? image = source == ImageSource.camera
          ? await PhotoUploadService.takePhoto()
          : await PhotoUploadService.pickFromGallery();

      if (image != null) {
        // 驗證照片
        final verification = await PhotoUploadService.verifyPhoto(image);
        if (!verification.isValid) {
          _showErrorSnackBar(verification.reason);
          return;
        }

        // 上傳照片
        setState(() {
          _isUploading = true;
          _uploadingIndex = index;
          _uploadProgress = 0.0;
        });

        final photoUrl = await PhotoUploadService.uploadProfilePhoto(
          imageFile: image,
          photoIndex: index,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        setState(() {
          if (index < _photos.length) {
            _photos[index] = photoUrl;
          } else {
            _photos.add(photoUrl);
          }
          _isUploading = false;
          _uploadingIndex = -1;
        });

        _showSuccessSnackBar('照片上傳成功！');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadingIndex = -1;
      });
      _showErrorSnackBar('上傳照片失敗: $e');
    }
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPhotoOptionsSheet(index),
    );
  }

  Widget _buildPhotoOptionsSheet(int index) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '照片選項',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildOptionItem(
            icon: Icons.edit,
            title: '替換照片',
            onTap: () {
              Navigator.pop(context);
              _addPhoto(index);
            },
          ),
          if (index != 0)
            _buildOptionItem(
              icon: Icons.star,
              title: '設為主要照片',
              onTap: () {
                Navigator.pop(context);
                _setAsMainPhoto(index);
              },
            ),
          _buildOptionItem(
            icon: Icons.delete,
            title: '刪除照片',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _deletePhoto(index);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? Colors.black87;
    
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(
          color: itemColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _setAsMainPhoto(int index) async {
    try {
      final photoUrl = _photos[index];
      setState(() {
        _photos.removeAt(index);
        _photos.insert(0, photoUrl);
      });

      await PhotoUploadService.reorderPhotos(_photos);
      _showSuccessSnackBar('已設為主要照片');
    } catch (e) {
      _showErrorSnackBar('設置主要照片失敗: $e');
      _loadUserPhotos(); // 重新載入
    }
  }

  void _deletePhoto(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除照片'),
        content: const Text('確定要刪除這張照片嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PhotoUploadService.deletePhoto(
                  photoUrl: _photos[index],
                  photoIndex: index,
                );
                setState(() {
                  _photos.removeAt(index);
                });
                _showSuccessSnackBar('照片已刪除');
              } catch (e) {
                _showErrorSnackBar('刪除照片失敗: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _reorderPhotos() {
    // TODO: 實現拖拽重新排序功能
    _showInfoSnackBar('拖拽重新排序功能即將推出');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
} 