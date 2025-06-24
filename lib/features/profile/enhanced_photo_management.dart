import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'file_manager_service.dart';

// 增強照片管理狀態
final enhancedPhotoProvider = StateNotifierProvider<EnhancedPhotoNotifier, EnhancedPhotoState>((ref) {
  return EnhancedPhotoNotifier(ref.read(fileManagerServiceProvider));
});

class EnhancedPhotoState {
  final List<ManagedFile> photos;
  final List<String> uploadingPhotos;
  final Map<String, double> uploadProgress;
  final String? error;
  final bool isLoading;
  final int maxPhotos;

  EnhancedPhotoState({
    this.photos = const [],
    this.uploadingPhotos = const [],
    this.uploadProgress = const {},
    this.error,
    this.isLoading = false,
    this.maxPhotos = 6,
  });

  EnhancedPhotoState copyWith({
    List<ManagedFile>? photos,
    List<String>? uploadingPhotos,
    Map<String, double>? uploadProgress,
    String? error,
    bool? isLoading,
    int? maxPhotos,
  }) {
    return EnhancedPhotoState(
      photos: photos ?? this.photos,
      uploadingPhotos: uploadingPhotos ?? this.uploadingPhotos,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      maxPhotos: maxPhotos ?? this.maxPhotos,
    );
  }
}

class EnhancedPhotoNotifier extends StateNotifier<EnhancedPhotoState> {
  final FileManagerService _fileManager;

  EnhancedPhotoNotifier(this._fileManager) : super(EnhancedPhotoState()) {
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _fileManager.initialize();
      final photos = _fileManager.getFiles(type: FileType.image)
          .where((file) => file.status != FileStatus.deleted)
          .toList();
      
      // 按創建時間排序
      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = state.copyWith(
        photos: photos,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '載入照片失敗: $e',
      );
    }
  }

  Future<void> addPhoto(XFile photo, {CompressionOptions? compressionOptions}) async {
    try {
      final file = File(photo.path);
      
      // 添加到檔案管理系統
      final managedFile = await _fileManager.addFile(
        file,
        customName: 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        metadata: {
          'source': 'profile_photo',
          'originalSize': await file.length(),
        },
      );

      // 更新狀態
      state = state.copyWith(
        photos: [managedFile, ...state.photos],
        uploadingPhotos: [...state.uploadingPhotos, managedFile.id],
      );

      // 開始上傳
      await _fileManager.uploadFile(
        managedFile.id,
        compressionOptions: compressionOptions ?? CompressionOptions(
          maxWidth: 1920,
          maxHeight: 1920,
          quality: 85,
        ),
        onProgress: (progress) {
          state = state.copyWith(
            uploadProgress: {
              ...state.uploadProgress,
              managedFile.id: progress.progress,
            },
          );
        },
      );

      // 上傳完成，更新狀態
      state = state.copyWith(
        uploadingPhotos: state.uploadingPhotos.where((id) => id != managedFile.id).toList(),
        uploadProgress: Map.from(state.uploadProgress)..remove(managedFile.id),
      );

      await _loadPhotos(); // 重新載入以獲取最新狀態
    } catch (e) {
      state = state.copyWith(error: '添加照片失敗: $e');
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      await _fileManager.deleteFile(photoId);
      await _loadPhotos();
    } catch (e) {
      state = state.copyWith(error: '刪除照片失敗: $e');
    }
  }

  Future<void> reorderPhotos(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex--;
    
    final photos = List<ManagedFile>.from(state.photos);
    final item = photos.removeAt(oldIndex);
    photos.insert(newIndex, item);
    
    state = state.copyWith(photos: photos);
    
    // TODO: 保存新的順序到後端
  }

  Future<void> setMainPhoto(String photoId) async {
    final photos = List<ManagedFile>.from(state.photos);
    final photoIndex = photos.indexWhere((p) => p.id == photoId);
    
    if (photoIndex > 0) {
      final photo = photos.removeAt(photoIndex);
      photos.insert(0, photo);
      state = state.copyWith(photos: photos);
    }
  }

  Future<void> retryUpload(String photoId) async {
    try {
      final photo = state.photos.firstWhere((p) => p.id == photoId);
      
      state = state.copyWith(
        uploadingPhotos: [...state.uploadingPhotos, photoId],
      );

      await _fileManager.uploadFile(
        photoId,
        onProgress: (progress) {
          state = state.copyWith(
            uploadProgress: {
              ...state.uploadProgress,
              photoId: progress.progress,
            },
          );
        },
      );

      state = state.copyWith(
        uploadingPhotos: state.uploadingPhotos.where((id) => id != photoId).toList(),
        uploadProgress: Map.from(state.uploadProgress)..remove(photoId),
      );

      await _loadPhotos();
    } catch (e) {
      state = state.copyWith(error: '重試上傳失敗: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class EnhancedPhotoManagementPage extends ConsumerStatefulWidget {
  const EnhancedPhotoManagementPage({super.key});

  @override
  ConsumerState<EnhancedPhotoManagementPage> createState() => _EnhancedPhotoManagementPageState();
}

class _EnhancedPhotoManagementPageState extends ConsumerState<EnhancedPhotoManagementPage>
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _addButtonController;
  late Animation<double> _addButtonAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  Widget build(BuildContext context) {
    final photoState = ref.watch(enhancedPhotoProvider);
    final photoNotifier = ref.read(enhancedPhotoProvider.notifier);

    // 顯示錯誤
    if (photoState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(photoState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '關閉',
              textColor: Colors.white,
              onPressed: () => photoNotifier.clearError(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '照片管理',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showPhotoSettings(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: photoState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPhotoManagement(context, photoState, photoNotifier),
    );
  }

  Widget _buildPhotoManagement(
    BuildContext context,
    EnhancedPhotoState state,
    EnhancedPhotoNotifier notifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructions(),
          const SizedBox(height: 24),
          _buildPhotoGrid(context, state, notifier),
          const SizedBox(height: 24),
          _buildPhotoStats(state),
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
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withOpacity(0.1),
            const Color(0xFFE91E63).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE91E63).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '智能照片管理',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 自動壓縮和優化照片品質\n'
            '• 智能去重，避免重複上傳\n'
            '• 雲端備份，永不丟失\n'
            '• 拖拽重新排序，第一張為主照片',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    EnhancedPhotoState state,
    EnhancedPhotoNotifier notifier,
  ) {
    return ReorderableGridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.8,
      itemCount: state.maxPhotos,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < state.photos.length && newIndex < state.photos.length) {
          notifier.reorderPhotos(oldIndex, newIndex);
        }
      },
      itemBuilder: (context, index) {
        return _buildPhotoSlot(context, index, state, notifier);
      },
    );
  }

  Widget _buildPhotoSlot(
    BuildContext context,
    int index,
    EnhancedPhotoState state,
    EnhancedPhotoNotifier notifier,
  ) {
    final hasPhoto = index < state.photos.length;
    final ManagedFile? photo = hasPhoto ? state.photos[index] : null;
    final isUploading = photo != null && state.uploadingPhotos.contains(photo.id);
    final uploadProgress = photo != null ? state.uploadProgress[photo.id] : null;

    return Card(
      key: ValueKey('photo_slot_$index'),
      elevation: hasPhoto ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 照片或空槽
            if (hasPhoto && photo != null)
              _buildPhotoContainer(photo, isUploading, uploadProgress, notifier)
            else
              _buildEmptySlot(index, notifier),

            // 主照片標記
            if (hasPhoto && index == 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '主照片',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // 操作按鈕
            if (hasPhoto && photo != null && !isUploading)
              Positioned(
                top: 8,
                right: 8,
                child: _buildPhotoActions(photo, index, notifier),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoContainer(
    ManagedFile photo,
    bool isUploading,
    double? uploadProgress,
    EnhancedPhotoNotifier notifier,
  ) {
    return GestureDetector(
      onTap: () => _viewPhoto(photo),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 照片
            Image.file(
              File(photo.localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        photo.status == FileStatus.failed
                            ? Icons.error_outline
                            : Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        photo.status == FileStatus.failed ? '上傳失敗' : '圖片錯誤',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (photo.status == FileStatus.failed)
                        TextButton(
                          onPressed: () => notifier.retryUpload(photo.id),
                          child: const Text('重試'),
                        ),
                    ],
                  ),
                );
              },
            ),

            // 上傳進度覆蓋層
            if (isUploading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: uploadProgress,
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      uploadProgress != null
                          ? '上傳中 ${(uploadProgress * 100).toInt()}%'
                          : '處理中...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // 狀態指示器
            if (!isUploading)
              Positioned(
                bottom: 8,
                right: 8,
                child: _buildStatusIndicator(photo.status),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(int index, EnhancedPhotoNotifier notifier) {
    return GestureDetector(
      onTap: () => _addPhoto(notifier),
      child: AnimatedBuilder(
        animation: _addButtonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _addButtonAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0 ? '添加主要照片' : '添加照片',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoActions(ManagedFile photo, int index, EnhancedPhotoNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index > 0)
            IconButton(
              onPressed: () => notifier.setMainPhoto(photo.id),
              icon: const Icon(Icons.star, color: Colors.white, size: 16),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          IconButton(
            onPressed: () => _showPhotoOptions(photo, notifier),
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 16),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(FileStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case FileStatus.uploaded:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case FileStatus.uploading:
        icon = Icons.cloud_upload;
        color = Colors.blue;
        break;
      case FileStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.cloud_off;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildPhotoStats(EnhancedPhotoState state) {
    final uploadedCount = state.photos.where((p) => p.status == FileStatus.uploaded).length;
    final totalSize = state.photos.fold<int>(0, (sum, photo) => sum + photo.size);

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
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.photo_library,
              label: '照片數量',
              value: '${state.photos.length}/${state.maxPhotos}',
              color: const Color(0xFFE91E63),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.cloud_done,
              label: '已上傳',
              value: '$uploadedCount',
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.storage,
              label: '總大小',
              value: _formatFileSize(totalSize),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                '照片小貼士',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 選擇清晰、光線良好的照片\n'
            '• 包含不同角度和場景的照片\n'
            '• 避免過度修圖或濾鏡\n'
            '• 確保照片真實反映你的外貌',
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

  Future<void> _addPhoto(EnhancedPhotoNotifier notifier) async {
    _addButtonController.forward().then((_) {
      _addButtonController.reverse();
    });

    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 95,
      );

      if (image != null) {
        await notifier.addPhoto(image);
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選擇照片失敗: $e')),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
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
                icon: Icons.camera_alt,
                title: '拍照',
                subtitle: '使用相機拍攝新照片',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              _buildSourceOption(
                icon: Icons.photo_library,
                title: '相冊',
                subtitle: '從手機相冊選擇照片',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPhoto(ManagedFile photo) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PhotoViewerPage(photo: photo);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showPhotoOptions(ManagedFile photo, EnhancedPhotoNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('查看照片'),
                onTap: () {
                  Navigator.pop(context);
                  _viewPhoto(photo);
                },
              ),
              if (photo.status == FileStatus.failed)
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('重新上傳'),
                  onTap: () {
                    Navigator.pop(context);
                    notifier.retryUpload(photo.id);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('刪除照片', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeletePhoto(photo, notifier);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePhoto(ManagedFile photo, EnhancedPhotoNotifier notifier) {
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
            onPressed: () {
              Navigator.pop(context);
              notifier.deletePhoto(photo.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('刪除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPhotoSettings(BuildContext context) {
    // TODO: 實現照片設置頁面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('照片設置功能即將推出')),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// 簡化的可重排序網格視圖
class ReorderableGridView extends StatelessWidget {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Function(int, int) onReorder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ReorderableGridView({
    super.key,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.childAspectRatio,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // 簡化實現，使用普通 GridView
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

// 照片查看器頁面
class PhotoViewerPage extends StatelessWidget {
  final ManagedFile photo;

  const PhotoViewerPage({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(photo.localPath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      '無法載入照片',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 