import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MBTITestPage extends StatefulWidget {
  const MBTITestPage({super.key});

  @override
  State<MBTITestPage> createState() => _MBTITestPageState();
}

class _MBTITestPageState extends State<MBTITestPage> {
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
    // 簡單的 MBTI 計算邏輯
    String mbtiType = '';
    mbtiType += _answers[0] == 0 ? 'E' : 'I'; // 外向/內向
    mbtiType += _answers[1] == 0 ? 'S' : 'N'; // 感覺/直覺
    mbtiType += _answers[2] == 0 ? 'T' : 'F'; // 思考/情感
    mbtiType += _answers[3] == 0 ? 'J' : 'P'; // 判斷/感知

    context.go('/mbti-result', extra: mbtiType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2D3748),
          ),
        ),
        title: const Text(
          'MBTI 人格測試',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 進度條
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
            
            // 問題卡片
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
                    
                    // 選項按鈕
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
                              elevation: 2,
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
            
            const SizedBox(height: 24),
            
            // 返回按鈕
            if (_currentQuestion > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentQuestion--;
                  });
                },
                child: const Text(
                  '上一題',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 