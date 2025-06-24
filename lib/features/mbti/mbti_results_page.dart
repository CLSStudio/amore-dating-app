import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mbti_test_page.dart';
import 'compatibility_analysis_page.dart';

class MBTIResultsPage extends StatefulWidget {
  const MBTIResultsPage({super.key});

  @override
  State<MBTIResultsPage> createState() => _MBTIResultsPageState();
}

class _MBTIResultsPageState extends State<MBTIResultsPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('載入用戶數據失敗: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的 MBTI 結果'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9C27B0),
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_userData?['mbtiType'] == null) {
      return _buildNoResultsView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 當前 MBTI 結果卡片
          _buildCurrentResultCard(),
          
          const SizedBox(height: 24),
          
          // 功能按鈕
          _buildActionButtons(),
          
          const SizedBox(height: 24),
          
          // MBTI 類型詳細信息
          _buildMBTIDetails(),
          
          const SizedBox(height: 24),
          
          // 測試歷史（如果有的話）
          _buildTestHistory(),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '尚未完成 MBTI 測試',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '完成 MBTI 性格測試，了解您的性格類型，\n找到更匹配的伴侶！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _startMBTITest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '開始 MBTI 測試',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentResultCard() {
    final mbtiType = _userData!['mbtiType'];
    final testType = _userData!['mbtiTestType'] ?? 'unknown';
    final testDate = _userData!['mbtiTestDate'] as Timestamp?;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9C27B0),
            const Color(0xFF9C27B0).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_alt,
                size: 32,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Text(
                '您的 MBTI 類型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            mbtiType,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              testType == 'professional' ? '專業版測試結果' : '簡易版測試結果',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (testDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '測試日期：${_formatDate(testDate.toDate())}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _retakeMBTITest,
                icon: const Icon(Icons.refresh),
                label: const Text('重新測試'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _analyzeCompatibility,
                icon: const Icon(Icons.favorite_border),
                label: const Text('兼容性分析'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareResult,
            icon: const Icon(Icons.share),
            label: const Text('分享結果'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C27B0),
              side: const BorderSide(color: Color(0xFF9C27B0)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMBTIDetails() {
    final mbtiType = _userData!['mbtiType'];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF9C27B0),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '性格類型詳情',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDetailItem(
              '性格類型',
              mbtiType,
              Icons.psychology,
            ),
            
            _buildDetailItem(
              '測試版本',
              _userData!['mbtiTestType'] == 'professional' ? '專業版（推薦）' : '簡易版',
              Icons.verified,
            ),
            
            _buildDetailItem(
              '適用場景',
              '約會匹配、兼容性分析、個性化建議',
              Icons.favorite,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 如何使用您的結果：',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• 查看與其他類型的兼容性分析'),
                  Text('• 獲得個性化的約會建議'),
                  Text('• 了解理想的溝通方式'),
                  Text('• 尋找性格互補的伴侶'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF9C27B0),
          ),
          const SizedBox(width: 12),
          Text(
            '$label：',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildTestHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.history,
                  color: Color(0xFF9C27B0),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '測試歷史',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 當前測試記錄
            _buildHistoryItem(
              _userData!['mbtiType'],
              _userData!['mbtiTestType'] == 'professional' ? '專業版' : '簡易版',
              _userData!['mbtiTestDate'] as Timestamp?,
              isLatest: true,
            ),
            
            const SizedBox(height: 12),
            
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
                      '建議定期重新測試以確保結果的準確性',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
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

  Widget _buildHistoryItem(String mbtiType, String testType, Timestamp? date, {bool isLatest = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLatest ? const Color(0xFF9C27B0).withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest ? const Color(0xFF9C27B0).withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLatest ? const Color(0xFF9C27B0) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isLatest ? Icons.psychology_alt : Icons.psychology,
              color: Colors.white,
              size: 20,
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
                      mbtiType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLatest ? const Color(0xFF9C27B0) : Colors.black87,
                      ),
                    ),
                    if (isLatest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '最新',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$testType • ${date != null ? _formatDate(date.toDate()) : "未知日期"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _startMBTITest() {
    // 顯示測試版本選擇
    _showMBTITestOptions();
  }
  
  void _showMBTITestOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇 MBTI 測試版本'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('請選擇您想要進行的測試版本：'),
            const SizedBox(height: 20),
            
            // 專業版選項
            _buildTestOptionTile(
              title: '專業版測試',
              subtitle: '深度分析，適合約會匹配',
              description: '• 60+ 專業問題\n• 詳細性格分析\n• 戀愛傾向評估\n• 約 15-20 分鐘',
              onTap: () {
                Navigator.pop(context);
                _navigateToMBTITest(isProfessional: true);
              },
              isRecommended: true,
            ),
            
            const SizedBox(height: 12),
            
            // 簡易版選項
            _buildTestOptionTile(
              title: '簡易版測試',
              subtitle: '快速了解基本性格類型',
              description: '• 15+ 核心問題\n• 基本性格分析\n• 快速結果\n• 約 5-8 分鐘',
              onTap: () {
                Navigator.pop(context);
                _navigateToMBTITest(isProfessional: false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestOptionTile({
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRecommended 
              ? const Color(0xFF9C27B0).withOpacity(0.1)
              : const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecommended 
                ? const Color(0xFF9C27B0).withOpacity(0.3)
                : const Color(0xFF2196F3).withOpacity(0.3),
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isRecommended 
                        ? const Color(0xFF9C27B0)
                        : const Color(0xFF2196F3),
                  ),
                ),
                if (isRecommended) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '推薦',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToMBTITest({bool isProfessional = true}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MBTITestPage(isProfessional: isProfessional),
      ),
    ).then((result) {
      if (result != null) {
        // 保存結果到 Firestore
        _saveMBTIResult(result, isProfessional);
      }
      _loadUserData();
    });
  }
  
  Future<void> _saveMBTIResult(String result, bool isProfessional) async {
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
            ),
          );
        }
      }
    } catch (e) {
      print('保存 MBTI 結果失敗: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存結果失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _retakeMBTITest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新測試'),
        content: const Text('您確定要重新進行 MBTI 測試嗎？新的結果將覆蓋當前結果。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMBTITestOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _analyzeCompatibility() {
    final userMBTI = _userData!['mbtiType'];
    
    // 顯示選擇伴侶 MBTI 類型的對話框
    final mbtiTypes = [
      'INTJ', 'INTP', 'ENTJ', 'ENTP',
      'INFJ', 'INFP', 'ENFJ', 'ENFP',
      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
      'ISTP', 'ISFP', 'ESTP', 'ESFP',
    ];
    
    String? selectedType;
    String partnerName = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('兼容性分析'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('請選擇對方的 MBTI 類型：'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                hint: const Text('選擇 MBTI 類型'),
                items: mbtiTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => partnerName = value,
                decoration: InputDecoration(
                  labelText: '對方姓名（可選）',
                  hintText: '例如：小明',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: selectedType != null ? () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompatibilityAnalysisPage(
                      userType: userMBTI,
                      partnerType: selectedType!,
                      partnerName: partnerName.isEmpty ? '對方' : partnerName,
                    ),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
              child: const Text('分析'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult() {
    final mbtiType = _userData!['mbtiType'];
    final testType = _userData!['mbtiTestType'] == 'professional' ? '專業版' : '簡易版';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享 MBTI 結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '我的 MBTI 類型：$mbtiType',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '通過 Amore $testType 測試獲得',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('分享功能即將推出！'),
          ],
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
} 