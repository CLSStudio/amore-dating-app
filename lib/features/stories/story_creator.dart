import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';

// Story 創建狀態
enum StoryCreationStep {
  selectType,
  createContent,
  addEffects,
  preview,
}

enum StoryContentType {
  text,
  image,
  video,
  poll,
  question,
  music,
  location,
}

// Story 創建狀態管理
final storyCreatorProvider = StateNotifierProvider<StoryCreatorNotifier, StoryCreatorState>((ref) {
  return StoryCreatorNotifier();
});

class StoryCreatorState {
  final StoryCreationStep currentStep;
  final StoryContentType contentType;
  final String textContent;
  final String? imagePath;
  final String? videoPath;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final double fontSize;
  final TextAlign textAlign;
  final List<String> pollOptions;
  final String questionText;
  final bool isLoading;
  final String? errorMessage;

  StoryCreatorState({
    this.currentStep = StoryCreationStep.selectType,
    this.contentType = StoryContentType.text,
    this.textContent = '',
    this.imagePath,
    this.videoPath,
    this.backgroundColor = const Color(0xFFE91E63),
    this.textColor = Colors.white,
    this.fontFamily = 'Default',
    this.fontSize = 24.0,
    this.textAlign = TextAlign.center,
    this.pollOptions = const [],
    this.questionText = '',
    this.isLoading = false,
    this.errorMessage,
  });

  StoryCreatorState copyWith({
    StoryCreationStep? currentStep,
    StoryContentType? contentType,
    String? textContent,
    String? imagePath,
    String? videoPath,
    Color? backgroundColor,
    Color? textColor,
    String? fontFamily,
    double? fontSize,
    TextAlign? textAlign,
    List<String>? pollOptions,
    String? questionText,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StoryCreatorState(
      currentStep: currentStep ?? this.currentStep,
      contentType: contentType ?? this.contentType,
      textContent: textContent ?? this.textContent,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
      pollOptions: pollOptions ?? this.pollOptions,
      questionText: questionText ?? this.questionText,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StoryCreatorNotifier extends StateNotifier<StoryCreatorState> {
  StoryCreatorNotifier() : super(StoryCreatorState());

  void setStep(StoryCreationStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setContentType(StoryContentType type) {
    state = state.copyWith(contentType: type, currentStep: StoryCreationStep.createContent);
  }

  void setTextContent(String content) {
    state = state.copyWith(textContent: content);
  }

  void setBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }

  void setTextColor(Color color) {
    state = state.copyWith(textColor: color);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size);
  }

  void setTextAlign(TextAlign align) {
    state = state.copyWith(textAlign: align);
  }

  void setImagePath(String path) {
    state = state.copyWith(imagePath: path);
  }

  void setVideoPath(String path) {
    state = state.copyWith(videoPath: path);
  }

  void setPollOptions(List<String> options) {
    state = state.copyWith(pollOptions: options);
  }

  void setQuestionText(String question) {
    state = state.copyWith(questionText: question);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = StoryCreatorState();
  }
}

// Story 創建器主頁面
class StoryCreator extends ConsumerStatefulWidget {
  const StoryCreator({super.key});

  @override
  ConsumerState<StoryCreator> createState() => _StoryCreatorState();
}

class _StoryCreatorState extends ConsumerState<StoryCreator>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _pollControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    _questionController.dispose();
    for (var controller in _pollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyCreatorProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景預覽
          _buildBackgroundPreview(state),
          
          // 頂部工具欄
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildTopToolbar(state),
          ),
          
          // 主要內容區域
          Positioned.fill(
            child: _buildMainContent(state),
          ),
          
          // 底部工具欄
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomToolbar(state),
          ),
          
          // 載入指示器
          if (state.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPreview(StoryCreatorState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            state.backgroundColor,
            state.backgroundColor.withOpacity(0.8),
            state.backgroundColor.withOpacity(0.6),
          ],
        ),
      ),
    );
  }

  Widget _buildTopToolbar(StoryCreatorState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (state.currentStep != StoryCreationStep.selectType)
            IconButton(
              icon: const Icon(Icons.palette, color: Colors.white),
              onPressed: () => _showColorPicker(state),
            ),
          if (state.contentType == StoryContentType.text)
            IconButton(
              icon: const Icon(Icons.text_fields, color: Colors.white),
              onPressed: () => _showTextOptions(state),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(StoryCreatorState state) {
    switch (state.currentStep) {
      case StoryCreationStep.selectType:
        return _buildTypeSelector();
      case StoryCreationStep.createContent:
        return _buildContentCreator(state);
      case StoryCreationStep.addEffects:
        return _buildEffectsEditor(state);
      case StoryCreationStep.preview:
        return _buildPreview(state);
    }
  }

  Widget _buildTypeSelector() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '創建 Story',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    children: [
                      _buildTypeOption(
                        icon: Icons.text_fields,
                        title: '文字',
                        subtitle: '分享想法',
                        color: const Color(0xFFE91E63),
                        onTap: () => ref.read(storyCreatorProvider.notifier).setContentType(StoryContentType.text),
                      ),
                      _buildTypeOption(
                        icon: Icons.photo_camera,
                        title: '照片',
                        subtitle: '拍攝或選擇',
                        color: const Color(0xFF2196F3),
                        onTap: () => _selectImage(),
                      ),
                      _buildTypeOption(
                        icon: Icons.videocam,
                        title: '視頻',
                        subtitle: '錄製短片',
                        color: const Color(0xFF4CAF50),
                        onTap: () => _selectVideo(),
                      ),
                      _buildTypeOption(
                        icon: Icons.poll,
                        title: '投票',
                        subtitle: '創建投票',
                        color: const Color(0xFFFF9800),
                        onTap: () => ref.read(storyCreatorProvider.notifier).setContentType(StoryContentType.poll),
                      ),
                      _buildTypeOption(
                        icon: Icons.help_outline,
                        title: '問題',
                        subtitle: '提出問題',
                        color: const Color(0xFF9C27B0),
                        onTap: () => ref.read(storyCreatorProvider.notifier).setContentType(StoryContentType.question),
                      ),
                      _buildTypeOption(
                        icon: Icons.music_note,
                        title: '音樂',
                        subtitle: '分享音樂',
                        color: const Color(0xFFFF5722),
                        onTap: () => ref.read(storyCreatorProvider.notifier).setContentType(StoryContentType.music),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCreator(StoryCreatorState state) {
    switch (state.contentType) {
      case StoryContentType.text:
        return _buildTextCreator(state);
      case StoryContentType.image:
        return _buildImageCreator(state);
      case StoryContentType.video:
        return _buildVideoCreator(state);
      case StoryContentType.poll:
        return _buildPollCreator(state);
      case StoryContentType.question:
        return _buildQuestionCreator(state);
      default:
        return _buildTextCreator(state);
    }
  }

  Widget _buildTextCreator(StoryCreatorState state) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
              style: TextStyle(
                color: state.textColor,
                fontSize: state.fontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: state.textAlign,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '分享你的想法...',
                hintStyle: TextStyle(
                  color: state.textColor.withOpacity(0.7),
                  fontSize: state.fontSize,
                ),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                ref.read(storyCreatorProvider.notifier).setTextContent(text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCreator(StoryCreatorState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.imagePath != null)
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                boxShadow: AppShadows.floating,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '選擇照片',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // 照片選項
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageOption(
                icon: Icons.camera_alt,
                title: '拍照',
                onTap: () => _takePicture(),
              ),
              _buildImageOption(
                icon: Icons.photo_library,
                title: '相簿',
                onTap: () => _selectFromGallery(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCreator(StoryCreatorState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '錄製視頻',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          AppButton(
            text: '開始錄製',
            onPressed: _recordVideo,
            icon: Icons.fiber_manual_record,
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPollCreator(StoryCreatorState state) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '創建投票',
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            TextField(
              controller: _questionController,
              style: AppTextStyles.h5.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '輸入投票問題...',
                hintStyle: AppTextStyles.h5.copyWith(
                  color: Colors.white70,
                ),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                ref.read(storyCreatorProvider.notifier).setQuestionText(text);
              },
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // 投票選項
            ..._pollControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '選項 ${index + 1}',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              );
            }).toList(),
            
            const SizedBox(height: AppSpacing.lg),
            
            TextButton.icon(
              onPressed: _addPollOption,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                '添加選項',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCreator(StoryCreatorState state) {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            TextField(
              controller: _questionController,
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '提出一個問題...',
                hintStyle: AppTextStyles.h4.copyWith(
                  color: Colors.white70,
                ),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                ref.read(storyCreatorProvider.notifier).setQuestionText(text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectsEditor(StoryCreatorState state) {
    return const Center(
      child: Text(
        '特效編輯器',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildPreview(StoryCreatorState state) {
    return const Center(
      child: Text(
        '預覽',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildBottomToolbar(StoryCreatorState state) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          if (state.currentStep != StoryCreationStep.selectType)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => _goBack(state),
            ),
          
          const Spacer(),
          
          if (state.currentStep == StoryCreationStep.createContent)
            AppButton(
              text: '下一步',
              onPressed: _canProceed(state) ? () => _nextStep(state) : null,
              icon: Icons.arrow_forward,
              type: AppButtonType.primary,
            ),
          
          if (state.currentStep == StoryCreationStep.addEffects ||
              state.currentStep == StoryCreationStep.preview)
            AppButton(
              text: '發布',
              onPressed: () => _publishStory(state),
              icon: Icons.send,
              type: AppButtonType.primary,
            ),
        ],
      ),
    );
  }

  bool _canProceed(StoryCreatorState state) {
    switch (state.contentType) {
      case StoryContentType.text:
        return state.textContent.isNotEmpty;
      case StoryContentType.image:
        return state.imagePath != null;
      case StoryContentType.video:
        return state.videoPath != null;
      case StoryContentType.poll:
        return state.questionText.isNotEmpty && 
               _pollControllers.where((c) => c.text.isNotEmpty).length >= 2;
      case StoryContentType.question:
        return state.questionText.isNotEmpty;
      default:
        return false;
    }
  }

  void _goBack(StoryCreatorState state) {
    switch (state.currentStep) {
      case StoryCreationStep.createContent:
        ref.read(storyCreatorProvider.notifier).setStep(StoryCreationStep.selectType);
        break;
      case StoryCreationStep.addEffects:
        ref.read(storyCreatorProvider.notifier).setStep(StoryCreationStep.createContent);
        break;
      case StoryCreationStep.preview:
        ref.read(storyCreatorProvider.notifier).setStep(StoryCreationStep.addEffects);
        break;
      default:
        break;
    }
  }

  void _nextStep(StoryCreatorState state) {
    switch (state.currentStep) {
      case StoryCreationStep.createContent:
        ref.read(storyCreatorProvider.notifier).setStep(StoryCreationStep.addEffects);
        break;
      case StoryCreationStep.addEffects:
        ref.read(storyCreatorProvider.notifier).setStep(StoryCreationStep.preview);
        break;
      default:
        break;
    }
  }

  void _selectImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        ref.read(storyCreatorProvider.notifier).setContentType(StoryContentType.image);
        ref.read(storyCreatorProvider.notifier).setImagePath(image.path);
      }
    } catch (e) {
      ref.read(storyCreatorProvider.notifier).setError('選擇圖片失敗');
    }
  }

  void _selectVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      
      if (video != null) {
        ref.read(storyCreatorProvider.notifier).setContentType(StoryContentType.video);
        ref.read(storyCreatorProvider.notifier).setVideoPath(video.path);
      }
    } catch (e) {
      ref.read(storyCreatorProvider.notifier).setError('選擇視頻失敗');
    }
  }

  void _takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        ref.read(storyCreatorProvider.notifier).setImagePath(image.path);
      }
    } catch (e) {
      ref.read(storyCreatorProvider.notifier).setError('拍照失敗');
    }
  }

  void _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        ref.read(storyCreatorProvider.notifier).setImagePath(image.path);
      }
    } catch (e) {
      ref.read(storyCreatorProvider.notifier).setError('選擇照片失敗');
    }
  }

  void _recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      
      if (video != null) {
        ref.read(storyCreatorProvider.notifier).setVideoPath(video.path);
      }
    } catch (e) {
      ref.read(storyCreatorProvider.notifier).setError('錄製視頻失敗');
    }
  }

  void _addPollOption() {
    if (_pollControllers.length < 4) {
      setState(() {
        _pollControllers.add(TextEditingController());
      });
    }
  }

  void _showColorPicker(StoryCreatorState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              '選擇背景顏色',
              style: AppTextStyles.h6,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                const Color(0xFFE91E63),
                const Color(0xFF9C27B0),
                const Color(0xFF673AB7),
                const Color(0xFF3F51B5),
                const Color(0xFF2196F3),
                const Color(0xFF03DAC6),
                const Color(0xFF4CAF50),
                const Color(0xFF8BC34A),
                const Color(0xFFCDDC39),
                const Color(0xFFFFEB3B),
                const Color(0xFFFF9800),
                const Color(0xFFFF5722),
              ].map((color) => GestureDetector(
                onTap: () {
                  ref.read(storyCreatorProvider.notifier).setBackgroundColor(color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: state.backgroundColor == color 
                          ? Colors.black 
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showTextOptions(StoryCreatorState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              '文字選項',
              style: AppTextStyles.h6,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // 字體大小
            ListTile(
              leading: const Icon(Icons.format_size),
              title: const Text('字體大小'),
              trailing: Slider(
                value: state.fontSize,
                min: 16,
                max: 48,
                divisions: 8,
                onChanged: (value) {
                  ref.read(storyCreatorProvider.notifier).setFontSize(value);
                },
              ),
            ),
            
            // 文字對齊
            ListTile(
              leading: const Icon(Icons.format_align_center),
              title: const Text('文字對齊'),
              trailing: DropdownButton<TextAlign>(
                value: state.textAlign,
                items: const [
                  DropdownMenuItem(value: TextAlign.left, child: Text('左對齊')),
                  DropdownMenuItem(value: TextAlign.center, child: Text('居中')),
                  DropdownMenuItem(value: TextAlign.right, child: Text('右對齊')),
                ],
                onChanged: (align) {
                  if (align != null) {
                    ref.read(storyCreatorProvider.notifier).setTextAlign(align);
                  }
                },
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.xl),
            topRight: Radius.circular(AppBorderRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text('保存草稿'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('定時發布'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('隱私設置'),
              onTap: () => Navigator.pop(context),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _publishStory(StoryCreatorState state) async {
    ref.read(storyCreatorProvider.notifier).setLoading(true);
    
    // 模擬發布過程
    await Future.delayed(const Duration(seconds: 2));
    
    ref.read(storyCreatorProvider.notifier).setLoading(false);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Story 發布成功！'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 