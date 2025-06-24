import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/mbti_question.dart';

/// MBTI 測試結果頁面
class MBTIResultPage extends StatelessWidget {
  final String mbtiType;

  const MBTIResultPage({
    super.key,
    required this.mbtiType,
  });

  @override
  Widget build(BuildContext context) {
    final typeInfo = _getMBTITypeInfo(mbtiType);

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
          'MBTI 測試結果',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 結果卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE91E63),
                    Color(0xFFAD1457),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    mbtiType,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    typeInfo['title']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    typeInfo['subtitle']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 特質描述
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '性格特質',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    typeInfo['description']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A5568),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 優勢
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '你的優勢',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(typeInfo['strengths'] as List<String>).map((strength) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF48BB78),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strength,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 操作按鈕
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/main'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '開始尋找配對',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // 分享功能
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE91E63)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '分享結果',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMBTITypeInfo(String type) {
    final typeData = {
      'ENFP': {
        'title': '活動家',
        'subtitle': '熱情、創造性的自由精神',
        'description': '你是一個充滿熱情和創造力的人，總是能看到事物的可能性。你善於激勵他人，喜歡探索新的想法和體驗。在人際關係中，你溫暖、真誠，能夠深刻理解他人的感受。',
        'strengths': [
          '富有創造力和想像力',
          '善於激勵和鼓舞他人',
          '適應性強，靈活變通',
          '對人際關係投入真誠',
          '能看到事物的潛在可能性',
        ],
      },
      'INTJ': {
        'title': '建築師',
        'subtitle': '富有想像力和戰略性的思想家',
        'description': '你是一個獨立、有決心的人，總是追求知識和能力的提升。你善於制定長期計劃，並有能力將複雜的想法轉化為現實。在關係中，你重視深度和真誠。',
        'strengths': [
          '戰略思維和長遠規劃',
          '獨立自主，自我驅動',
          '追求知識和自我提升',
          '邏輯思維清晰',
          '對目標堅持不懈',
        ],
      },
      'ESFP': {
        'title': '娛樂家',
        'subtitle': '自發的、精力充沛的表演者',
        'description': '你是一個活潑、友善的人，喜歡與他人分享快樂。你活在當下，善於發現生活中的美好時刻。在人際關係中，你溫暖、體貼，總是能帶給他人歡樂。',
        'strengths': [
          '樂觀積極，充滿活力',
          '善於與人建立聯繫',
          '實用主義，注重當下',
          '富有同情心和理解力',
          '適應能力強',
        ],
      },
      'ISTJ': {
        'title': '物流師',
        'subtitle': '實用和注重事實的可靠者',
        'description': '你是一個可靠、負責任的人，重視傳統和穩定。你做事有條理，注重細節，總是能夠完成承諾的事情。在關係中，你忠誠、穩定，是值得信賴的伴侶。',
        'strengths': [
          '可靠和負責任',
          '注重細節和準確性',
          '有條理，善於規劃',
          '忠誠和穩定',
          '實用主義思維',
        ],
      },
    };

    return typeData[type] ?? typeData['ENFP']!;
  }
} 