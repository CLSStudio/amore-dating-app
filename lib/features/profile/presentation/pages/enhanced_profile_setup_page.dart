import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EnhancedProfileSetupPage extends ConsumerStatefulWidget {
  const EnhancedProfileSetupPage({super.key});

  @override
  ConsumerState<EnhancedProfileSetupPage> createState() => _EnhancedProfileSetupPageState();
}

class _EnhancedProfileSetupPageState extends ConsumerState<EnhancedProfileSetupPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  // 表單數據
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  int _selectedAge = 25;
  String _selectedGender = '';
  final List<File> _selectedImages = [];
  final List<String> _selectedInterests = [];
  String _selectedMBTI = '';

  // 興趣選項
  final List<Map<String, dynamic>> _interestOptions = [
    {'name': '旅行', 'icon': Icons.flight, 'color': const Color(0xFF4CAF50)},
    {'name': '攝影', 'icon': Icons.camera_alt, 'color': const Color(0xFF2196F3)},
    {'name': '音樂', 'icon': Icons.music_note, 'color': const Color(0xFF9C27B0)},
    {'name': '電影', 'icon': Icons.movie, 'color': const Color(0xFFFF5722)},
    {'name': '閱讀', 'icon': Icons.book, 'color': const Color(0xFF795548)},
    {'name': '健身', 'icon': Icons.fitness_center, 'color': const Color(0xFFE91E63)},
    {'name': '美食', 'icon': Icons.restaurant, 'color': const Color(0xFFFF9800)},
    {'name': '藝術', 'icon': Icons.palette, 'color': const Color(0xFF673AB7)},
    {'name': '科技', 'icon': Icons.computer, 'color': const Color(0xFF607D8B)},
    {'name': '瑜伽', 'icon': Icons.self_improvement, 'color': const Color(0xFF8BC34A)},
    {'name': '游泳', 'icon': Icons.pool, 'color': const Color(0xFF00BCD4)},
    {'name': '登山', 'icon': Icons.terrain, 'color': const Color(0xFF4CAF50)},
  ];

  // MBTI 選項
  final List<String> _mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup() {
    // 保存用戶資料
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
        ),
      ),
    );

    // 模擬保存過程
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 關閉載入對話框
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // 基本信息
        return _nameController.text.isNotEmpty && _selectedGender.isNotEmpty;
      case 1: // 照片
        return _selectedImages.isNotEmpty;
      case 2: // 興趣
        return _selectedInterests.length >= 3;
      case 3: // MBTI
        return _selectedMBTI.isNotEmpty;
      case 4: // 個人簡介
        return _bioController.text.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF2D3748),
                ),
              )
            : null,
        title: const Text(
          '設置個人檔案',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 進度指示器
          _buildProgressIndicator(),
          
          // 頁面內容
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildPhotosStep(),
                _buildInterestsStep(),
                _buildMBTIStep(),
                _buildBioStep(),
              ],
            ),
          ),
          
          // 底部按鈕
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? const Color(0xFFE91E63)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '步驟 ${_currentStep + 1} / $_totalSteps',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '告訴我們關於你的基本信息',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '這些信息將幫助我們為你找到更好的匹配',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 32),
            
            // 姓名輸入
            const Text(
              '你的名字',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: '輸入你的名字',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE91E63)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: 24),
            
            // 年齡選擇
            const Text(
              '你的年齡',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedAge 歲',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _selectedAge > 18
                            ? () => setState(() => _selectedAge--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: _selectedAge < 80
                            ? () => setState(() => _selectedAge++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 性別選擇
            const Text(
              '你的性別',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption('男性', Icons.male),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption('女性', Icons.female),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF718096),
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加你的照片',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '至少添加一張照片，讓其他人更好地認識你',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 32),
          
          // 照片網格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index < _selectedImages.length) {
                return _buildPhotoItem(_selectedImages[index], index);
              } else {
                return _buildAddPhotoButton(index);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(File image, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          if (index == 0)
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
                  '主要',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
              child: Container(
                width: 24,
                height: 24,
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
  }

  Widget _buildAddPhotoButton(int index) {
    return GestureDetector(
      onTap: () => _pickImage(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 32,
              color: Color(0xFF718096),
            ),
            SizedBox(height: 8),
            Text(
              '添加照片',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '選擇你的興趣',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '選擇至少 3 個興趣 (已選擇 ${_selectedInterests.length})',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 32),
          
          // 興趣網格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _interestOptions.length,
            itemBuilder: (context, index) {
              final interest = _interestOptions[index];
              final isSelected = _selectedInterests.contains(interest['name']);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest['name']);
                    } else {
                      _selectedInterests.add(interest['name']);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? interest['color'] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? interest['color'] : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        interest['icon'],
                        color: isSelected ? Colors.white : interest['color'],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          interest['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMBTIStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '你的 MBTI 人格類型',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '選擇你的 MBTI 類型，這將幫助我們找到更匹配的人',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 32),
          
          // MBTI 網格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _mbtiTypes.length,
            itemBuilder: (context, index) {
              final mbti = _mbtiTypes[index];
              final isSelected = _selectedMBTI == mbti;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedMBTI = mbti),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mbti,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 不知道 MBTI 的選項
          GestureDetector(
            onTap: () {
              // 導航到 MBTI 測試
              Navigator.of(context).pushNamed('/mbti-test');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Color(0xFF718096),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '不知道你的 MBTI 類型？點擊這裡進行測試',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '寫一段個人簡介',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '告訴其他人你是什麼樣的人，你在尋找什麼',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 32),
          
          // 簡介輸入
          TextField(
            controller: _bioController,
            maxLines: 6,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '例如：我是一個熱愛生活的人，喜歡旅行和攝影。希望能找到一個有趣的靈魂，一起探索世界的美好...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE91E63)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() {}),
          ),
          
          const SizedBox(height: 24),
          
          // 提示卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF0284C7),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '寫作提示',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• 分享你的興趣和愛好\n• 描述你的生活方式\n• 說明你在尋找什麼樣的關係\n• 保持真實和積極的態度',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0369A1),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: _previousStep,
                child: const Text(
                  '上一步',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? '完成設置' : '下一步',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 