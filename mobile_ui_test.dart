import 'package:flutter/material.dart';

void main() {
  runApp(const MobileUITestApp());
}

class MobileUITestApp extends StatelessWidget {
  const MobileUITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore 移動端 UI 測試',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const MobileHomePage(),
    );
  }
}

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Amore 移動端測試'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // 歡迎標題
              Text(
                '歡迎來到 Amore',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              Text(
                '測試移動端 UI 組件',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // 功能按鈕
              _buildFeatureButton(
                context,
                '滑動配對',
                Icons.favorite,
                Colors.pink,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SwipeTestPage()),
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureButton(
                context,
                '個人檔案設置',
                Icons.person,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileTestPage()),
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureButton(
                context,
                'MBTI 人格測試',
                Icons.psychology,
                Colors.indigo,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MBTITestPage()),
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildFeatureButton(
                context,
                '聊天界面',
                Icons.chat,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatTestPage()),
                ),
              ),
              
              const Spacer(),
              
              // 底部信息
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mobile_friendly,
                      color: Colors.pink.shade400,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '移動端優化完成',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '所有 UI 組件已針對觸控操作優化',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 滑動配對測試頁面
class SwipeTestPage extends StatefulWidget {
  const SwipeTestPage({super.key});

  @override
  State<SwipeTestPage> createState() => _SwipeTestPageState();
}

class _SwipeTestPageState extends State<SwipeTestPage> {
  int currentIndex = 0;
  
  final List<Map<String, dynamic>> users = [
    {
      'name': '小雅',
      'age': 25,
      'bio': '喜歡旅行和攝影，尋找有趣的靈魂',
      'image': '👩‍🦰',
      'interests': ['旅行', '攝影', '咖啡'],
    },
    {
      'name': '志明',
      'age': 28,
      'bio': '軟體工程師，熱愛音樂和電影',
      'image': '👨‍💻',
      'interests': ['音樂', '電影', '程式設計'],
    },
    {
      'name': '美玲',
      'age': 26,
      'bio': '瑜伽教練，追求健康生活',
      'image': '🧘‍♀️',
      'interests': ['瑜伽', '健身', '素食'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('滑動配對'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: currentIndex < users.length
            ? Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildUserCard(users[currentIndex]),
                    ),
                  ),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              )
            : _buildNoMoreCards(),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 用戶頭像區域
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  user['image'],
                  style: const TextStyle(fontSize: 120),
                ),
              ),
            ),
          ),
          
          // 用戶信息區域
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${user['age']}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    user['bio'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    children: (user['interests'] as List<String>)
                        .map((interest) => Chip(
                              label: Text(
                                interest,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.pink.shade100,
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 不喜歡按鈕
          GestureDetector(
            onTap: () => _swipeAction(false),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
          
          // 喜歡按鈕
          GestureDetector(
            onTap: () => _swipeAction(true),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.pink.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreCards() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.pink.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            '沒有更多用戶了',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '請稍後再來查看新的配對',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _swipeAction(bool liked) {
    setState(() {
      currentIndex++;
    });
    
    if (liked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('你喜歡了 ${users[currentIndex - 1]['name']}！'),
          backgroundColor: Colors.pink.shade400,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

// 個人檔案測試頁面
class ProfileTestPage extends StatefulWidget {
  const ProfileTestPage({super.key});

  @override
  State<ProfileTestPage> createState() => _ProfileTestPageState();
}

class _ProfileTestPageState extends State<ProfileTestPage> {
  final PageController _pageController = PageController();
  int currentStep = 0;
  final int totalSteps = 3;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  int selectedAge = 25;
  String selectedGender = '女性';
  List<String> selectedInterests = [];
  
  final List<String> interests = [
    '旅行', '攝影', '音樂', '電影', '運動', '閱讀',
    '烹飪', '瑜伽', '游泳', '登山', '咖啡', '藝術'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('個人檔案設置'),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 進度指示器
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(totalSteps, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? Colors.purple.shade400
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // 頁面內容
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildInterestsStep(),
                _buildBioStep(),
              ],
            ),
          ),
          
          // 底部按鈕
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('上一步'),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(currentStep < totalSteps - 1 ? '下一步' : '完成'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '基本信息',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '姓名',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '年齡: $selectedAge',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: selectedAge.toDouble(),
            min: 18,
            max: 60,
            divisions: 42,
            onChanged: (value) {
              setState(() {
                selectedAge = value.round();
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            '性別',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['男性', '女性', '其他'].map((gender) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(gender),
                  value: gender,
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '興趣愛好',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '選擇你的興趣（最多6個）',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final interest = interests[index];
                final isSelected = selectedInterests.contains(interest);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedInterests.remove(interest);
                      } else if (selectedInterests.length < 6) {
                        selectedInterests.add(interest);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple.shade400 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildBioStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '個人簡介',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _bioController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: '介紹一下你自己...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '預覽',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('姓名: ${_nameController.text.isEmpty ? "未填寫" : _nameController.text}'),
                Text('年齡: $selectedAge'),
                Text('性別: $selectedGender'),
                Text('興趣: ${selectedInterests.isEmpty ? "未選擇" : selectedInterests.join(", ")}'),
                Text('簡介: ${_bioController.text.isEmpty ? "未填寫" : _bioController.text}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (currentStep < totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 完成設置
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('個人檔案設置完成！'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

// MBTI 測試頁面
class MBTITestPage extends StatefulWidget {
  const MBTITestPage({super.key});

  @override
  State<MBTITestPage> createState() => _MBTITestPageState();
}

class _MBTITestPageState extends State<MBTITestPage> {
  int currentQuestion = 0;
  Map<String, int> scores = {'E': 0, 'I': 0, 'S': 0, 'N': 0, 'T': 0, 'F': 0, 'J': 0, 'P': 0};
  
  final List<Map<String, dynamic>> questions = [
    {
      'question': '在聚會中，你更傾向於：',
      'answers': [
        {'text': '主動與很多人交談', 'type': 'E'},
        {'text': '與少數幾個人深入交流', 'type': 'I'},
      ],
    },
    {
      'question': '做決定時，你更依賴：',
      'answers': [
        {'text': '邏輯分析', 'type': 'T'},
        {'text': '個人價值觀', 'type': 'F'},
      ],
    },
    {
      'question': '你更喜歡：',
      'answers': [
        {'text': '有明確的計劃和時間表', 'type': 'J'},
        {'text': '保持靈活性和開放性', 'type': 'P'},
      ],
    },
    {
      'question': '學習新事物時，你更關注：',
      'answers': [
        {'text': '具體的事實和細節', 'type': 'S'},
        {'text': '整體概念和可能性', 'type': 'N'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text('MBTI 人格測試'),
        backgroundColor: Colors.indigo.shade400,
        foregroundColor: Colors.white,
      ),
      body: currentQuestion < questions.length
          ? _buildQuestionPage()
          : _buildResultPage(),
    );
  }

  Widget _buildQuestionPage() {
    final question = questions[currentQuestion];
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 進度指示器
          LinearProgressIndicator(
            value: (currentQuestion + 1) / questions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '問題 ${currentQuestion + 1} / ${questions.length}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 問題
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              question['question'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 答案選項
          ...question['answers'].map<Widget>((answer) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () => _selectAnswer(answer['type']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade700,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.indigo.shade200),
                  ),
                ),
                child: Text(
                  answer['text'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultPage() {
    final mbtiType = _calculateMBTI();
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: Colors.indigo.shade400,
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  '你的 MBTI 類型是',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  mbtiType,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  _getMBTIDescription(mbtiType),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('完成測試'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String type) {
    setState(() {
      scores[type] = scores[type]! + 1;
      currentQuestion++;
    });
  }

  String _calculateMBTI() {
    String result = '';
    result += scores['E']! > scores['I']! ? 'E' : 'I';
    result += scores['S']! > scores['N']! ? 'S' : 'N';
    result += scores['T']! > scores['F']! ? 'T' : 'F';
    result += scores['J']! > scores['P']! ? 'J' : 'P';
    return result;
  }

  String _getMBTIDescription(String type) {
    final descriptions = {
      'ENFP': '熱情洋溢的激勵者',
      'ENFJ': '熱情的教育家',
      'INFP': '理想主義的治療者',
      'INFJ': '有洞察力的保護者',
      'ENTP': '有創意的發明家',
      'ENTJ': '果斷的指揮官',
      'INTP': '客觀的思想家',
      'INTJ': '獨立的思想家',
      'ESFP': '熱情的表演者',
      'ESFJ': '熱心的支持者',
      'ISFP': '溫和的藝術家',
      'ISFJ': '忠誠的守護者',
      'ESTP': '精力充沛的實踐者',
      'ESTJ': '高效的組織者',
      'ISTP': '務實的實踐者',
      'ISTJ': '可靠的現實主義者',
    };
    return descriptions[type] ?? '獨特的個性';
  }
}

// 聊天測試頁面
class ChatTestPage extends StatefulWidget {
  const ChatTestPage({super.key});

  @override
  State<ChatTestPage> createState() => _ChatTestPageState();
}

class _ChatTestPageState extends State<ChatTestPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {
      'text': '嗨！很高興認識你 😊',
      'isMe': false,
      'time': '14:30',
    },
    {
      'text': '你好！我也很高興認識你',
      'isMe': true,
      'time': '14:32',
    },
    {
      'text': '你平時喜歡做什麼呢？',
      'isMe': false,
      'time': '14:33',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              child: Text('👩‍🦰'),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小雅',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '在線',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 聊天記錄
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // 輸入框
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '輸入訊息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 16,
              child: Text('👩‍🦰', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.teal.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['time'],
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              child: Text('😊', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add({
          'text': _messageController.text.trim(),
          'isMe': true,
          'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
      });
      _messageController.clear();
    }
  }
} 