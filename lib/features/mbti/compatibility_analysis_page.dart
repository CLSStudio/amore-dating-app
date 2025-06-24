import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mbti_compatibility.dart';

class CompatibilityAnalysisPage extends ConsumerWidget {
  final String userType;
  final String partnerType;
  final String partnerName;

  const CompatibilityAnalysisPage({
    super.key,
    required this.userType,
    required this.partnerType,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = MBTICompatibility.getDetailedCompatibilityAnalysis(userType, partnerType);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('兼容性分析'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 配對頭部信息
            _buildPartnerHeader(),
            const SizedBox(height: 25),
            
            // 兼容性分數卡片
            _buildCompatibilityScoreCard(analysis),
            const SizedBox(height: 25),
            
            // 優勢分析
            _buildAnalysisSection(
              '💪 關係優勢',
              analysis['strengths'] as List<String>,
              Colors.green.shade50,
              Colors.green,
            ),
            const SizedBox(height: 20),
            
            // 挑戰分析
            _buildAnalysisSection(
              '⚠️ 潛在挑戰',
              analysis['challenges'] as List<String>,
              Colors.orange.shade50,
              Colors.orange,
            ),
            const SizedBox(height: 20),
            
            // 約會建議
            _buildDatingTipsSection(),
            const SizedBox(height: 20),
            
            // 關係建議
            _buildAnalysisSection(
              '💡 關係建議',
              analysis['tips'] as List<String>,
              Colors.blue.shade50,
              Colors.blue,
            ),
            const SizedBox(height: 30),
            
            // 操作按鈕
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 用戶 MBTI
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 35, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  userType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text('你', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          
          // 愛心圖標
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 24,
            ),
          ),
          
          // 伴侶 MBTI
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.shade100,
                  child: const Icon(Icons.person, size: 35, color: Colors.purple),
                ),
                const SizedBox(height: 8),
                Text(
                  partnerType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text(partnerName, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityScoreCard(Map<String, dynamic> analysis) {
    final score = analysis['score'] as int;
    final level = analysis['level'] as String;
    final color = analysis['color'] as Color;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 15),
          Text(
            '$score%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '兼容性指數',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(String title, List<String> items, Color bgColor, Color textColor) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 15),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDatingTipsSection() {
    final tips = MBTICompatibility.getDatingTips(userType, partnerType);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: Colors.pink.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                '💕 約會建議',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...tips.take(4).map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.pink.shade800,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 主要操作按鈕
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDetailedGuide(context);
                },
                icon: const Icon(Icons.book),
                label: const Text('詳細指南'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _saveAnalysis(context);
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('保存分析'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        
        // 返回按鈕
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('返回'),
          ),
        ),
      ],
    );
  }

  void _showDetailedGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📚 詳細關係指南'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideSection('溝通建議', [
                '保持誠實和開放的對話',
                '尊重彼此的溝通風格',
                '在衝突時暫停並冷靜思考',
                '定期檢查關係狀態',
              ]),
              const SizedBox(height: 15),
              _buildGuideSection('共同活動', [
                '參加彼此感興趣的活動',
                '嘗試新的體驗和冒險',
                '創造專屬的傳統和儀式',
                '平衡獨處和相處時間',
              ]),
              const SizedBox(height: 15),
              _buildGuideSection('成長目標', [
                '支持彼此的個人發展',
                '設定共同的未來目標',
                '慶祝小的進步和成就',
                '從挑戰中學習和成長',
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text('• $item'),
        )),
      ],
    );
  }

  void _saveAnalysis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('兼容性分析已保存！'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: '查看',
          textColor: Colors.white,
          onPressed: () {
            // 導航到保存的分析頁面
          },
        ),
      ),
    );
  }
} 