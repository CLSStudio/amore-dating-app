import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mbti/mbti_test_page.dart';

import '../main_navigation/main_navigation.dart';

class CompleteOnboardingFlow extends ConsumerStatefulWidget {
  const CompleteOnboardingFlow({super.key});

  @override
  ConsumerState<CompleteOnboardingFlow> createState() => _CompleteOnboardingFlowState();
}

class _CompleteOnboardingFlowState extends ConsumerState<CompleteOnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // 用戶數據
  final Map<String, dynamic> _userData = {};
  
  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: '歡迎來到 Amore',
      subtitle: '讓我們開始建立您的個人檔案',
      icon: Icons.favorite,
      color: const Color(0xFFE91E63),
    ),
    OnboardingStep(
      title: '基本資料',
      subtitle: '告訴我們一些關於您的基本信息',
      icon: Icons.person,
      color: const Color(0xFF2196F3),
    ),
    OnboardingStep(
      title: 'MBTI 性格測試',
      subtitle: '了解您的性格類型，找到更匹配的伴侶',
      icon: Icons.psychology,
      color: const Color(0xFF9C27B0),
    ),
    OnboardingStep(
      title: '價值觀與生活目標',
      subtitle: '分享您的價值觀和對未來的期望',
      icon: Icons.star,
      color: const Color(0xFFFF9800),
    ),
    OnboardingStep(
      title: '連結意圖',
      subtitle: '告訴我們您在尋找什麼樣的關係',
      icon: Icons.connect_without_contact,
      color: const Color(0xFF4CAF50),
    ),
    OnboardingStep(
      title: '完成設置',
      subtitle: '您已準備好開始尋找真愛！',
      icon: Icons.check_circle,
      color: const Color(0xFF00BCD4),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 進度指示器
            _buildProgressIndicator(),
            
            // 主要內容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildWelcomeStep(),
                  _buildBasicInfoStep(),
                  _buildMBTIStep(),
                  _buildValuesStep(),
                  _buildConnectionIntentStep(),
                  _buildCompletionStep(),
                ],
              ),
            ),
            
            // 導航按鈕
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? _steps[index].color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            '步驟 ${_currentStep + 1} / ${_steps.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _steps[0].color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              _steps[0].icon,
              size: 60,
              color: _steps[0].color,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _steps[0].title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _steps[0].subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Text(
            '我們將通過幾個簡單的步驟，幫助您：\n\n• 完成個人檔案設置\n• 了解您的性格類型\n• 設定您的價值觀和目標\n• 明確您的連結意圖\n\n這將幫助我們為您找到最匹配的伴侶！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(1),
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: '姓名',
                    hint: '請輸入您的姓名',
                    onChanged: (value) => _userData['name'] = value,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildAgeSelector(),
                  const SizedBox(height: 20),
                  
                  _buildGenderSelector(),
                  const SizedBox(height: 20),
                  
                  _buildLocationSelector(),
                  const SizedBox(height: 20),
                  
                  _buildTextField(
                    label: '簡介',
                    hint: '用幾句話介紹一下自己...',
                    maxLines: 3,
                    onChanged: (value) => _userData['bio'] = value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMBTIStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(2),
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _steps[2].color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _steps[2].color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 48,
                          color: _steps[2].color,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'MBTI 性格測試',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '通過科學的性格測試，我們將了解您的：\n\n• 性格傾向和特質\n• 溝通風格\n• 價值觀偏好\n• 理想的伴侶類型',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  if (_userData['mbtiType'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '您的 MBTI 類型：${_userData['mbtiType']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // 測試版本選擇
                  const Text(
                    '選擇測試版本：',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 專業版測試
                  _buildTestVersionCard(
                    title: '專業版測試',
                    subtitle: '深度分析，適合約會匹配',
                    description: '• 60+ 專業問題\n• 詳細性格分析\n• 戀愛傾向評估\n• 約 15-20 分鐘',
                    icon: Icons.psychology_alt,
                    color: const Color(0xFF9C27B0),
                    onTap: () => _startMBTITest(isProfessional: true),
                    isRecommended: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 簡易版測試
                  _buildTestVersionCard(
                    title: '簡易版測試',
                    subtitle: '快速了解基本性格類型',
                    description: '• 20+ 核心問題\n• 基本性格分析\n• 快速結果\n• 約 5-8 分鐘',
                    icon: Icons.psychology,
                    color: const Color(0xFF2196F3),
                    onTap: () => _startMBTITest(isProfessional: false),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 提示信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '建議選擇專業版測試以獲得更準確的匹配結果',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestVersionCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? color : Colors.grey.shade300,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isRecommended ? color : Colors.black87,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '推薦',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
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
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuesStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(3),
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '選擇對您最重要的價值觀（最多選擇 5 個）：',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildValuesGrid(),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    '您的生活目標：',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLifeGoalsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIntentStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(4),
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '您在尋找什麼樣的關係？',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildConnectionIntentOptions(),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    '您希望多快發展關係？',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildRelationshipPaceOptions(),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    '理想的約會頻率：',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDatingFrequencyOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _steps[5].color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              _steps[5].icon,
              size: 60,
              color: _steps[5].color,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _steps[5].title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _steps[5].subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          _buildProfileSummary(),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: _steps[5].color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                '開始尋找真愛 💕',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(int stepIndex) {
    final step = _steps[stepIndex];
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: step.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            step.icon,
            color: step.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                step.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE91E63)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '年齡',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _userData['age'],
              hint: const Text('選擇年齡'),
              items: List.generate(63, (index) => index + 18)
                  .map((age) => DropdownMenuItem(
                        value: age,
                        child: Text('$age 歲'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _userData['age'] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    final genders = [
      {'value': 'male', 'label': '男性', 'icon': Icons.male},
      {'value': 'female', 'label': '女性', 'icon': Icons.female},
      {'value': 'other', 'label': '其他', 'icon': Icons.person},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性別',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: genders.map((gender) {
            final isSelected = _userData['gender'] == gender['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _userData['gender'] = gender['value'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        gender['icon'] as IconData,
                        color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gender['label'] as String,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '所在地區',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _userData['location'],
              hint: const Text('選擇地區'),
              items: [
                '香港島', '九龍', '新界', '離島'
              ].map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _userData['location'] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValuesGrid() {
    final values = [
      '誠實', '忠誠', '幽默', '冒險', '穩定', '創意',
      '家庭', '事業', '健康', '學習', '旅行', '藝術',
      '運動', '美食', '音樂', '讀書', '環保', '慈善',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = (_userData['values'] as List<String>? ?? []).contains(value);
        return GestureDetector(
          onTap: () {
            setState(() {
              final currentValues = (_userData['values'] as List<String>? ?? []);
              if (isSelected) {
                currentValues.remove(value);
              } else if (currentValues.length < 5) {
                currentValues.add(value);
              }
              _userData['values'] = currentValues;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLifeGoalsSection() {
    final goals = [
      {'title': '建立家庭', 'icon': Icons.home},
      {'title': '事業發展', 'icon': Icons.work},
      {'title': '環遊世界', 'icon': Icons.travel_explore},
      {'title': '學習成長', 'icon': Icons.school},
      {'title': '健康生活', 'icon': Icons.fitness_center},
      {'title': '創意表達', 'icon': Icons.palette},
    ];

    return Column(
      children: goals.map((goal) {
        final isSelected = (_userData['lifeGoals'] as List<String>? ?? []).contains(goal['title']);
        return GestureDetector(
          onTap: () {
            setState(() {
              final currentGoals = (_userData['lifeGoals'] as List<String>? ?? []);
              if (isSelected) {
                currentGoals.remove(goal['title']);
              } else {
                currentGoals.add(goal['title'] as String);
              }
              _userData['lifeGoals'] = currentGoals;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  goal['icon'] as IconData,
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                ),
                const SizedBox(width: 16),
                Text(
                  goal['title'] as String,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: Color(0xFFE91E63),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConnectionIntentOptions() {
    final intents = [
      {
        'value': 'serious_relationship',
        'title': '認真的長期關係',
        'subtitle': '尋找結婚對象或長期伴侶',
        'icon': Icons.favorite,
      },
      {
        'value': 'dating',
        'title': '約會交往',
        'subtitle': '開放的約會，看看會發展成什麼',
        'icon': Icons.date_range,
      },
      {
        'value': 'friendship',
        'title': '友誼為先',
        'subtitle': '先建立友誼，再看是否發展',
        'icon': Icons.people,
      },
      {
        'value': 'networking',
        'title': '社交擴展',
        'subtitle': '擴展社交圈，認識新朋友',
        'icon': Icons.group_add,
      },
    ];

    return Column(
      children: intents.map((intent) {
        final isSelected = _userData['connectionIntent'] == intent['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _userData['connectionIntent'] = intent['value'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  intent['icon'] as IconData,
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intent['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFFE91E63) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intent['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFE91E63),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRelationshipPaceOptions() {
    final paces = ['慢慢來', '正常節奏', '比較快'];
    
    return Row(
      children: paces.map((pace) {
        final isSelected = _userData['relationshipPace'] == pace;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _userData['relationshipPace'] = pace;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
                border: Border.all(
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                pace,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatingFrequencyOptions() {
    final frequencies = ['每週一次', '每兩週一次', '每月一次', '隨緣'];
    
    return Column(
      children: frequencies.map((frequency) {
        final isSelected = _userData['datingFrequency'] == frequency;
        return GestureDetector(
          onTap: () {
            setState(() {
              _userData['datingFrequency'] = frequency;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  frequency,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: Color(0xFFE91E63),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '您的檔案摘要',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_userData['name'] != null)
            _buildSummaryItem('姓名', _userData['name']),
          if (_userData['age'] != null)
            _buildSummaryItem('年齡', '${_userData['age']} 歲'),
          if (_userData['mbtiType'] != null)
            _buildSummaryItem('MBTI 類型', _userData['mbtiType']),
          if (_userData['connectionIntent'] != null)
            _buildSummaryItem('連結意圖', _getConnectionIntentLabel(_userData['connectionIntent'])),
          if (_userData['values'] != null && (_userData['values'] as List).isNotEmpty)
            _buildSummaryItem('核心價值觀', (_userData['values'] as List).join(', ')),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('上一步'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentStep == _steps.length - 1 ? '完成' : '下一步'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _userData['name'] != null && 
               _userData['age'] != null && 
               _userData['gender'] != null;
      case 2:
        return _userData['mbtiType'] != null;
      case 3:
        return (_userData['values'] as List<String>? ?? []).isNotEmpty;
      case 4:
        return _userData['connectionIntent'] != null;
      case 5:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startMBTITest({bool isProfessional = true}) async {
    // 顯示測試類型選擇確認
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isProfessional ? '專業版 MBTI 測試' : '簡易版 MBTI 測試'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isProfessional 
                  ? '您選擇了專業版測試，這將提供：'
                  : '您選擇了簡易版測試，這將提供：',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (isProfessional) ...[
              const Text('• 60+ 專業問題'),
              const Text('• 詳細性格分析'),
              const Text('• 戀愛傾向評估'),
              const Text('• 約 15-20 分鐘'),
            ] else ...[
              const Text('• 20+ 核心問題'),
              const Text('• 基本性格分析'),
              const Text('• 快速結果'),
              const Text('• 約 5-8 分鐘'),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isProfessional 
                          ? '專業版測試結果更準確，建議用於約會匹配'
                          : '簡易版適合快速了解基本性格類型',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isProfessional ? const Color(0xFF9C27B0) : const Color(0xFF2196F3),
            ),
            child: const Text('開始測試'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // 根據選擇的版本導航到相應的測試頁面
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MBTITestPage(isProfessional: isProfessional),
      ),
    );
    
    if (result != null) {
      setState(() {
        _userData['mbtiType'] = result;
        _userData['mbtiTestType'] = isProfessional ? 'professional' : 'simple';
      });
      
      // 即時保存 MBTI 結果到 Firestore（以防用戶沒有完成整個入門流程）
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'mbtiType': result,
            'mbtiTestType': isProfessional ? 'professional' : 'simple',
            'mbtiTestDate': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          print('✅ MBTI 結果已即時保存: $result (${isProfessional ? "專業版" : "簡易版"})');
        }
      } catch (e) {
        print('⚠️ MBTI 結果即時保存失敗: $e');
        // 不顯示錯誤給用戶，因為會在完成入門流程時再次保存
      }
      
      // 顯示完成提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isProfessional 
                  ? '🎉 專業版 MBTI 測試完成！您的類型：$result'
                  : '🎉 簡易版 MBTI 測試完成！您的類型：$result',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '繼續',
              textColor: Colors.white,
              onPressed: () {
                // 自動進入下一步
                _nextStep();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 保存用戶數據到 Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        ..._userData,
        'profileComplete': true,
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 導航到主應用
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getConnectionIntentLabel(String value) {
    switch (value) {
      case 'serious_relationship':
        return '認真的長期關係';
      case 'dating':
        return '約會交往';
      case 'friendship':
        return '友誼為先';
      case 'networking':
        return '社交擴展';
      default:
        return value;
    }
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
} 