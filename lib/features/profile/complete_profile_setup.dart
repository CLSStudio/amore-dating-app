import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// 個人檔案設置狀態管理
final profileSetupStepProvider = StateProvider<int>((ref) => 0);
final profileDataProvider = StateProvider<ProfileData>((ref) => ProfileData());

// 個人檔案數據模型
class ProfileData {
  String name = '';
  int age = 25;
  String gender = '';
  String bio = '';
  List<String> photos = [];
  List<String> interests = [];
  String profession = '';
  String education = '';
  String location = '';
  List<String> values = [];
  String relationshipGoal = '';
  bool hasCompletedMBTI = false;
  String mbtiType = '';

  ProfileData();

  bool get isBasicInfoComplete => 
      name.isNotEmpty && gender.isNotEmpty && profession.isNotEmpty;
  
  bool get hasPhotos => photos.isNotEmpty;
  
  bool get hasInterests => interests.length >= 3;
  
  bool get isComplete => 
      isBasicInfoComplete && hasPhotos && hasInterests && bio.isNotEmpty;
}

class CompleteProfileSetupPage extends ConsumerStatefulWidget {
  const CompleteProfileSetupPage({super.key});

  @override
  ConsumerState<CompleteProfileSetupPage> createState() => _CompleteProfileSetupPageState();
}

class _CompleteProfileSetupPageState extends ConsumerState<CompleteProfileSetupPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  
  late AnimationController _progressAnimationController;
  late AnimationController _stepAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<String> _availableInterests = [
    '旅行', '攝影', '音樂', '電影', '運動', '閱讀', '烹飪', '瑜伽', 
    '游泳', '登山', '咖啡', '藝術', '舞蹈', '寫作', '遊戲', '美食',
    '時尚', '科技', '投資', '創業', '志工', '寵物', '園藝', '手工藝'
  ];

  final List<String> _relationshipGoals = [
    '尋找長期關係',
    '開放約會',
    '尋找朋友',
    '還在探索',
  ];

  final List<String> _coreValues = [
    '誠實', '忠誠', '冒險', '創意', '家庭', '事業', '健康', '學習',
    '自由', '穩定', '樂觀', '同理心', '獨立', '傳統', '創新', '平衡'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _stepAnimationController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(profileSetupStepProvider);
    final profileData = ref.watch(profileDataProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF0F8FF),
              Color(0xFFFFF0F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部進度條
              _buildEnhancedProgressHeader(currentStep),
              
              // 頁面內容
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    ref.read(profileSetupStepProvider.notifier).state = index;
                    _updateProgressAnimation(index);
                    _stepAnimationController.reset();
                    _stepAnimationController.forward();
                  },
                  children: [
                    _buildEnhancedBasicInfoStep(profileData),
                    _buildEnhancedPhotosStep(profileData),
                    _buildEnhancedInterestsStep(profileData),
                    _buildEnhancedBioStep(profileData),
                    _buildEnhancedValuesStep(profileData),
                    _buildEnhancedMBTIPromptStep(profileData),
                    _buildEnhancedCompletionStep(profileData),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProgressAnimation(int step) {
    final progress = (step + 1) / 7;
    _progressAnimationController.animateTo(progress);
  }

  Widget _buildEnhancedProgressHeader(int currentStep) {
    const totalSteps = 7;
    final progress = (currentStep + 1) / totalSteps;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (currentStep > 0)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              else
                const SizedBox(width: 48),
              
              const Expanded(
                child: Text(
                  '設置個人檔案',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '跳過',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '步驟 ${currentStep + 1}/$totalSteps',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBasicInfoStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題區域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '基本資料',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '讓我們先了解一下你的基本信息',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 姓名輸入
                      _buildEnhancedInputField(
                        label: '姓名',
                        controller: _nameController,
                        hint: '輸入你的姓名',
                        icon: Icons.badge_outlined,
                        onChanged: (value) {
                          final updatedData = ProfileData()
                            ..name = value
                            ..age = profileData.age
                            ..gender = profileData.gender
                            ..profession = profileData.profession;
                          ref.read(profileDataProvider.notifier).state = updatedData;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 年齡選擇
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '年齡: ${profileData.age}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF667EEA),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: const Color(0xFF667EEA),
                                overlayColor: const Color(0xFF667EEA).withOpacity(0.2),
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                              ),
                              child: Slider(
                                value: profileData.age.toDouble(),
                                min: 18,
                                max: 60,
                                divisions: 42,
                                onChanged: (value) {
                                  final updatedData = ProfileData()
                                    ..name = profileData.name
                                    ..age = value.round()
                                    ..gender = profileData.gender
                                    ..profession = profileData.profession;
                                  ref.read(profileDataProvider.notifier).state = updatedData;
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('18', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('60', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 性別選擇
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            Row(
                              children: [
                                Icon(
                                  Icons.wc_outlined,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '性別',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: ['男性', '女性', '其他'].map((gender) {
                                final isSelected = profileData.gender == gender;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        final updatedData = ProfileData()
                                          ..name = profileData.name
                                          ..age = profileData.age
                                          ..gender = gender
                                          ..profession = profileData.profession;
                                        ref.read(profileDataProvider.notifier).state = updatedData;
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: isSelected ? const LinearGradient(
                                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                          ) : null,
                                          color: isSelected ? null : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          gender,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF2D3748),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 職業輸入
                      _buildEnhancedInputField(
                        label: '職業',
                        controller: _professionController,
                        hint: '你的職業是什麼？',
                        icon: Icons.work_outline,
                        onChanged: (value) {
                          final updatedData = ProfileData()
                            ..name = profileData.name
                            ..age = profileData.age
                            ..gender = profileData.gender
                            ..profession = value;
                          ref.read(profileDataProvider.notifier).state = updatedData;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 繼續按鈕
              _buildEnhancedContinueButton(
                isEnabled: profileData.isBasicInfoComplete,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedPhotosStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題區域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '上傳照片',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '添加一些展現真實自我的照片',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 照片網格
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    if (index < profileData.photos.length) {
                      return _buildEnhancedPhotoCard(profileData.photos[index], index);
                    } else {
                      return _buildEnhancedAddPhotoCard(index);
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 提示文字
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '至少上傳一張照片，建議上傳 3-6 張不同角度的照片',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 繼續按鈕
              _buildEnhancedContinueButton(
                isEnabled: profileData.hasPhotos,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedInterestsStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題區域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '興趣愛好',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '選擇你的興趣愛好（至少選擇 3 個）',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 興趣選擇網格
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _availableInterests.length,
                  itemBuilder: (context, index) {
                    final interest = _availableInterests[index];
                    final isSelected = profileData.interests.contains(interest);
                    
                    return GestureDetector(
                      onTap: () => _toggleInterest(interest, profileData),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected ? const LinearGradient(
                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                          ) : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: const Color(0xFF11998E).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF2D3748),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 已選擇數量提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: profileData.hasInterests ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: profileData.hasInterests 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      profileData.hasInterests ? Icons.check_circle : Icons.info_outline,
                      color: profileData.hasInterests ? Colors.green[600] : Colors.orange[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '已選擇 ${profileData.interests.length} 個興趣${profileData.hasInterests ? '，很棒！' : '，還需要 ${3 - profileData.interests.length} 個'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: profileData.hasInterests ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 繼續按鈕
              _buildEnhancedContinueButton(
                isEnabled: profileData.hasInterests,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBioStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題區域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '個人簡介',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '寫一段簡介來展現你的個性',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 簡介輸入框
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: null,
                    expands: true,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: '介紹一下你自己...\n\n例如：喜歡旅行和攝影，尋找有趣的靈魂。希望找到一個能和我一起探索世界的人。',
                      hintStyle: TextStyle(
                        color: Color(0xFF718096),
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(24),
                      counterStyle: TextStyle(
                        color: Color(0xFF718096),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF2D3748),
                    ),
                    onChanged: (value) {
                      final updatedData = profileData;
                      updatedData.bio = value;
                      ref.read(profileDataProvider.notifier).state = updatedData;
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 建議提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber[700],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '寫作建議',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 分享你的興趣和熱情  • 描述你在尋找什麼\n• 保持真實和積極      • 避免負面內容',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 繼續按鈕
              _buildEnhancedContinueButton(
                isEnabled: profileData.bio.isNotEmpty,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedValuesStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題區域
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '核心價值觀',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '選擇對你最重要的價值觀（最多選擇 5 個）',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 價值觀選擇
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _coreValues.length,
                  itemBuilder: (context, index) {
                    final value = _coreValues[index];
                    final isSelected = profileData.values.contains(value);
                    
                    return GestureDetector(
                      onTap: () => _toggleValue(value, profileData),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ) : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            value,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF2D3748),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 已選擇數量提示
              if (profileData.values.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '已選擇 ${profileData.values.length} 個價值觀',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 繼續按鈕
              _buildEnhancedContinueButton(
                isEnabled: true,
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMBTIPromptStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // MBTI 圖標
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  '🧠',
                  style: TextStyle(fontSize: 64),
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                '完成 MBTI 測試',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '完成性格測試可以幫助我們為你找到更合適的配對',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // 開始測試按鈕
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pushNamed('/mbti-test');
                    },
                    child: const Center(
                      child: Text(
                        '開始 MBTI 測試',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 稍後完成按鈕
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _nextStep,
                    child: Center(
                      child: Text(
                        '稍後完成',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildEnhancedCompletionStep(ProfileData profileData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              
              // 完成圖標
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11998E).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  '🎉',
                  style: TextStyle(fontSize: 64),
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                '檔案設置完成！',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '你的個人檔案已經準備就緒\n現在可以開始尋找你的理想伴侶了',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // 開始探索按鈕
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11998E).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: const Center(
                      child: Text(
                        '開始探索',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildEnhancedInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3748),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPhotoCard(String photo, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  photo,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
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
  }

  Widget _buildEnhancedAddPhotoCard(int index) {
    return GestureDetector(
      onTap: () => _addPhoto(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              index == 0 ? '主要照片' : '添加照片',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedContinueButton({
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isEnabled ? const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ) : null,
        color: isEnabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isEnabled ? onPressed : null,
          child: Center(
            child: Text(
              '繼續',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    final currentStep = ref.read(profileSetupStepProvider);
    if (currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleInterest(String interest, ProfileData profileData) {
    final updatedInterests = List<String>.from(profileData.interests);
    if (updatedInterests.contains(interest)) {
      updatedInterests.remove(interest);
    } else {
      updatedInterests.add(interest);
    }
    
    final updatedData = ProfileData()
      ..name = profileData.name
      ..age = profileData.age
      ..gender = profileData.gender
      ..profession = profileData.profession
      ..photos = profileData.photos
      ..interests = updatedInterests
      ..bio = profileData.bio
      ..values = profileData.values;
    
    ref.read(profileDataProvider.notifier).state = updatedData;
  }

  void _toggleValue(String value, ProfileData profileData) {
    final updatedValues = List<String>.from(profileData.values);
    if (updatedValues.contains(value)) {
      updatedValues.remove(value);
    } else if (updatedValues.length < 5) {
      updatedValues.add(value);
    }
    
    final updatedData = ProfileData()
      ..name = profileData.name
      ..age = profileData.age
      ..gender = profileData.gender
      ..profession = profileData.profession
      ..photos = profileData.photos
      ..interests = profileData.interests
      ..bio = profileData.bio
      ..values = updatedValues;
    
    ref.read(profileDataProvider.notifier).state = updatedData;
  }

  void _addPhoto(int index) {
    // TODO: 實現照片選擇功能
    final profileData = ref.read(profileDataProvider);
    final updatedPhotos = List<String>.from(profileData.photos);
    updatedPhotos.add('📷'); // 模擬添加照片
    
    final updatedData = ProfileData()
      ..name = profileData.name
      ..age = profileData.age
      ..gender = profileData.gender
      ..profession = profileData.profession
      ..photos = updatedPhotos
      ..interests = profileData.interests
      ..bio = profileData.bio
      ..values = profileData.values;
    
    ref.read(profileDataProvider.notifier).state = updatedData;
  }

  void _removePhoto(int index) {
    final profileData = ref.read(profileDataProvider);
    final updatedPhotos = List<String>.from(profileData.photos);
    updatedPhotos.removeAt(index);
    
    final updatedData = ProfileData()
      ..name = profileData.name
      ..age = profileData.age
      ..gender = profileData.gender
      ..profession = profileData.profession
      ..photos = updatedPhotos
      ..interests = profileData.interests
      ..bio = profileData.bio
      ..values = profileData.values;
    
    ref.read(profileDataProvider.notifier).state = updatedData;
  }
} 