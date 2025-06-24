import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleUITestApp());
}

class SimpleUITestApp extends StatelessWidget {
  const SimpleUITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore UI 測試 (簡化版)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UITestHomePage(),
      routes: {
        '/discovery': (context) => const SimpleDiscoveryPage(),
        '/profile-setup': (context) => const SimpleProfileSetupPage(),
        '/mbti-test': (context) => const SimpleMBTITestPage(),
      },
    );
  }
}

class UITestHomePage extends StatelessWidget {
  const UITestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Amore UI 測試 (簡化版)',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎨 新的 UI 組件測試',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '測試我們為 Amore 應用開發的新界面組件 (無 Firebase 版本)',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 32),
            
            // 測試按鈕列表
            Expanded(
              child: ListView(
                children: [
                  _buildTestCard(
                    context,
                    title: '滑動配對界面',
                    description: '測試新的滑動配對功能，包含流暢動畫和美觀卡片',
                    icon: Icons.favorite,
                    color: const Color(0xFFE91E63),
                    route: '/discovery',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTestCard(
                    context,
                    title: '個人檔案設置',
                    description: '測試引導式的個人檔案設置流程',
                    icon: Icons.person_add,
                    color: const Color(0xFF2196F3),
                    route: '/profile-setup',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTestCard(
                    context,
                    title: 'MBTI 人格測試',
                    description: '測試 MBTI 測試界面和結果展示',
                    icon: Icons.psychology,
                    color: const Color(0xFF9C27B0),
                    route: '/mbti-test',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 狀態信息
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF0284C7),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '開發狀態',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStatusItem('✅ 滑動配對界面', '已完成'),
                        _buildStatusItem('✅ 個人檔案設置', '已完成'),
                        _buildStatusItem('✅ MBTI 測試系統', '已完成'),
                        _buildStatusItem('🔄 Android Studio 設置', '進行中'),
                        _buildStatusItem('⏳ Firebase 整合', '待完成'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 下一步指引
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.build,
                              color: Color(0xFFDC2626),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '下一步',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '1. 完成 Android Studio SDK 設置\n'
                          '2. 創建 Android 模擬器\n'
                          '3. 測試移動端 UI 組件\n'
                          '4. 整合 Firebase 服務',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB91C1C),
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF718096),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String feature, String status) {
    Color statusColor;
    switch (status) {
      case '已完成':
        statusColor = const Color(0xFF059669);
        break;
      case '進行中':
        statusColor = const Color(0xFFD97706);
        break;
      case '待完成':
        statusColor = const Color(0xFF6B7280);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            feature,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0369A1),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 簡化版的滑動配對頁面
class SimpleDiscoveryPage extends StatefulWidget {
  const SimpleDiscoveryPage({super.key});

  @override
  State<SimpleDiscoveryPage> createState() => _SimpleDiscoveryPageState();
}

class _SimpleDiscoveryPageState extends State<SimpleDiscoveryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _currentIndex = 0;
  
  final List<Map<String, dynamic>> _users = [
    {
      'name': '小雅',
      'age': 25,
      'mbti': 'ENFP',
      'compatibility': 92,
      'bio': '喜歡旅行和攝影，尋找有趣的靈魂 ✈️📸',
      'interests': ['旅行', '攝影', '咖啡', '音樂'],
    },
    {
      'name': '志明',
      'age': 28,
      'mbti': 'INTJ',
      'compatibility': 88,
      'bio': '軟體工程師，熱愛科技和閱讀 💻📚',
      'interests': ['科技', '閱讀', '電影', '健身'],
    },
    {
      'name': '美琪',
      'age': 26,
      'mbti': 'ESFJ',
      'compatibility': 95,
      'bio': '瑜伽教練，喜歡健康生活 🧘‍♀️🍃',
      'interests': ['瑜伽', '美食', '健康', '自然'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSwipe(bool isLike) async {
    await _animationController.forward();
    
    if (isLike) {
      _showMatchDialog();
    }
    
    setState(() {
      _currentIndex = (_currentIndex + 1) % _users.length;
    });
    
    _animationController.reset();
  }

  void _showMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配對成功！'),
        content: Text('你和 ${_users[_currentIndex]['name']} 互相喜歡！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('繼續探索'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('開始聊天'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('探索'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildUserCard(_users[_currentIndex]),
                  );
                },
              ),
            ),
          ),
          
          // 操作按鈕
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () => _onSwipe(false),
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
                FloatingActionButton(
                  onPressed: () => _onSwipe(true),
                  backgroundColor: const Color(0xFFE91E63),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 兼容性指標
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${user['compatibility']}% 匹配',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 用戶信息
            Row(
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${user['age']}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF718096),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['mbti'],
                    style: const TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              user['bio'],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '興趣',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 興趣標籤
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user['interests'] as List<String>).map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      color: Color(0xFF2D3748),
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// 簡化版的個人檔案設置頁面
class SimpleProfileSetupPage extends StatefulWidget {
  const SimpleProfileSetupPage({super.key});

  @override
  State<SimpleProfileSetupPage> createState() => _SimpleProfileSetupPageState();
}

class _SimpleProfileSetupPageState extends State<SimpleProfileSetupPage> {
  int _currentStep = 0;
  final int _totalSteps = 3;
  
  final _nameController = TextEditingController();
  int _selectedAge = 25;
  String _selectedGender = '';
  final List<String> _selectedInterests = [];

  final List<String> _interestOptions = [
    '旅行', '攝影', '音樂', '電影', '閱讀', '健身',
    '美食', '藝術', '科技', '瑜伽', '游泳', '登山',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('設置個人檔案'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 進度指示器
          Container(
            padding: const EdgeInsets.all(24),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
          ),
          
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildBasicInfoStep(),
                _buildInterestsStep(),
                _buildCompletionStep(),
              ],
            ),
          ),
          
          // 底部按鈕
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('上一步'),
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
                    ),
                    child: Text(_currentStep == _totalSteps - 1 ? '完成' : '下一步'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty && _selectedGender.isNotEmpty;
      case 1:
        return _selectedInterests.length >= 3;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '你的名字',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
          ),
          
          const SizedBox(height: 24),
          
          Text('年齡: $_selectedAge'),
          Slider(
            value: _selectedAge.toDouble(),
            min: 18,
            max: 80,
            divisions: 62,
            onChanged: (value) => setState(() => _selectedAge = value.round()),
          ),
          
          const SizedBox(height: 24),
          
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
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '選擇興趣 (${_selectedInterests.length}/12)',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text('至少選擇 3 個興趣'),
          const SizedBox(height: 32),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: _interestOptions.length,
              itemBuilder: (context, index) {
                final interest = _interestOptions[index];
                final isSelected = _selectedInterests.contains(interest);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE91E63) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 100,
            color: Color(0xFF059669),
          ),
          SizedBox(height: 24),
          Text(
            '設置完成！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '你的個人檔案已經設置完成，現在可以開始探索了！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}

// 簡化版的 MBTI 測試頁面
class SimpleMBTITestPage extends StatefulWidget {
  const SimpleMBTITestPage({super.key});

  @override
  State<SimpleMBTITestPage> createState() => _SimpleMBTITestPageState();
}

class _SimpleMBTITestPageState extends State<SimpleMBTITestPage> {
  int _currentQuestion = 0;
  final List<int> _answers = [];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': '在聚會中，你更傾向於：',
      'options': ['與很多人交談', '與少數幾個人深入交談'],
    },
    {
      'question': '你更喜歡：',
      'options': ['關注細節和事實', '關注整體和可能性'],
    },
    {
      'question': '做決定時，你更依賴：',
      'options': ['邏輯分析', '個人價值觀和感受'],
    },
    {
      'question': '你更喜歡：',
      'options': ['有計劃和結構', '保持靈活和開放'],
    },
  ];

  void _answerQuestion(int answer) {
    setState(() {
      if (_answers.length > _currentQuestion) {
        _answers[_currentQuestion] = answer;
      } else {
        _answers.add(answer);
      }
      
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _completeTest();
      }
    });
  }

  void _completeTest() {
    String mbtiType = '';
    mbtiType += _answers[0] == 0 ? 'E' : 'I';
    mbtiType += _answers[1] == 0 ? 'S' : 'N';
    mbtiType += _answers[2] == 0 ? 'T' : 'F';
    mbtiType += _answers[3] == 0 ? 'J' : 'P';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('測試完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '你的 MBTI 類型是：',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              mbtiType,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MBTI 人格測試'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '問題 ${_currentQuestion + 1} / ${_questions.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
            
            const SizedBox(height: 40),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _questions[_currentQuestion]['question'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    ...(_questions[_currentQuestion]['options'] as List<String>)
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      String option = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _answerQuestion(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 