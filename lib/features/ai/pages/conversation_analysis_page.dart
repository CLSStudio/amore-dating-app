import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/conversation_analysis_service.dart';

class ConversationAnalysisPage extends ConsumerStatefulWidget {
  const ConversationAnalysisPage({super.key});

  @override
  ConsumerState<ConversationAnalysisPage> createState() => _ConversationAnalysisPageState();
}

class _ConversationAnalysisPageState extends ConsumerState<ConversationAnalysisPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // 模擬數據 - 實際應用中會從 Firebase 獲取
  final List<Map<String, dynamic>> _chatPartners = [
    {
      'id': 'partner1',
      'name': 'Sarah',
      'age': 25,
      'mbti': 'ENFP',
      'avatar': 'https://picsum.photos/100/100?random=1',
      'chatId': 'chat_current_partner1',
      'messageCount': 45,
    },
    {
      'id': 'partner2', 
      'name': 'Emma',
      'age': 28,
      'mbti': 'INFJ',
      'avatar': 'https://picsum.photos/100/100?random=2',
      'chatId': 'chat_current_partner2',
      'messageCount': 32,
    },
    {
      'id': 'partner3',
      'name': 'Lily',
      'age': 26,
      'mbti': 'ISFP', 
      'avatar': 'https://picsum.photos/100/100?random=3',
      'chatId': 'chat_current_partner3',
      'messageCount': 28,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'AI 對話分析',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE91E63),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE91E63),
          tabs: const [
            Tab(text: '真心度分析'),
            Tab(text: '對象比較'),
            Tab(text: '對話模式'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSincerityAnalysisTab(),
          _buildPartnerComparisonTab(),
          _buildConversationPatternTab(),
        ],
      ),
    );
  }

  Widget _buildSincerityAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '選擇要分析的聊天對象',
            '分析對方的真心度和誠意程度',
            Icons.psychology,
          ),
          const SizedBox(height: 16),
          
          // 聊天對象列表
          ...(_chatPartners.map((partner) => _buildPartnerCard(
            partner: partner,
            onTap: () => _analyzeSincerity(partner),
            trailing: const Icon(
              Icons.analytics,
              color: Color(0xFFE91E63),
            ),
          ))),
          
          const SizedBox(height: 24),
          
          // 分析歷史
          _buildAnalysisHistory(),
        ],
      ),
    );
  }

  Widget _buildPartnerComparisonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '比較聊天對象',
            '找出最適合你的聊天對象',
            Icons.compare,
          ),
          const SizedBox(height: 16),
          
          // 比較按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _compareAllPartners,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.compare_arrows),
              label: Text(_isLoading ? '分析中...' : '開始比較分析'),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 選擇對象
          _buildSectionHeader(
            '選擇比較對象',
            '選擇要比較的聊天對象（至少2個）',
            Icons.people,
          ),
          const SizedBox(height: 16),
          
          ...(_chatPartners.map((partner) => _buildSelectablePartnerCard(partner))),
          
          const SizedBox(height: 24),
          
          // 比較結果示例
          _buildComparisonResults(),
        ],
      ),
    );
  }

  Widget _buildConversationPatternTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '對話模式分析',
            '深入了解你們的溝通風格和模式',
            Icons.chat_bubble_outline,
          ),
          const SizedBox(height: 16),
          
          // 聊天對象列表
          ...(_chatPartners.map((partner) => _buildPartnerCard(
            partner: partner,
            onTap: () => _analyzeConversationPattern(partner),
            trailing: const Icon(
              Icons.insights,
              color: Color(0xFFE91E63),
            ),
          ))),
          
          const SizedBox(height: 24),
          
          // 模式分析示例
          _buildPatternAnalysisExample(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE91E63),
              size: 24,
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
                    color: Colors.black87,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildPartnerCard({
    required Map<String, dynamic> partner,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(partner['avatar']),
            onBackgroundImageError: (_, __) {},
            child: partner['avatar'] == null 
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            '${partner['name']}, ${partner['age']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      partner['mbti'],
                      style: const TextStyle(
                        color: Color(0xFFE91E63),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${partner['messageCount']} 條消息',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSelectablePartnerCard(Map<String, dynamic> partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.all(16),
          secondary: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(partner['avatar']),
            onBackgroundImageError: (_, __) {},
            child: partner['avatar'] == null 
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(
            '${partner['name']}, ${partner['age']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${partner['mbti']} • ${partner['messageCount']} 條消息',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          value: false, // 實際應用中會管理選中狀態
          onChanged: (value) {
            // 處理選中狀態變化
          },
          activeColor: const Color(0xFFE91E63),
        ),
      ),
    );
  }

  Widget _buildAnalysisHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近分析',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // 示例分析結果
        _buildAnalysisResultCard(
          partnerName: 'Sarah',
          analysisType: '真心度分析',
          score: 85,
          date: '2 小時前',
          insights: ['回應積極主動', '情感表達真實', '對未來有規劃'],
        ),
        
        _buildAnalysisResultCard(
          partnerName: 'Emma',
          analysisType: '真心度分析',
          score: 72,
          date: '1 天前',
          insights: ['溝通較為保守', '需要更多時間了解', '表現出興趣'],
        ),
      ],
    );
  }

  Widget _buildAnalysisResultCard({
    required String partnerName,
    required String analysisType,
    required int score,
    required String date,
    required List<String> insights,
  }) {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$partnerName - $analysisType',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 分數顯示
              Row(
                children: [
                  Text(
                    '分數：',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$score/100',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 洞察
              Text(
                '主要洞察：',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '比較結果示例',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏆 最佳匹配：Sarah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildScoreBar('整體兼容性', 88, Colors.green),
                _buildScoreBar('溝通品質', 92, Colors.blue),
                _buildScoreBar('性格匹配', 85, Colors.orange),
                _buildScoreBar('價值觀一致', 90, Colors.purple),
                
                const SizedBox(height: 16),
                
                const Text(
                  '主要優勢：',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                const Text(
                  '• 溝通頻率平衡，回應及時\n• 話題多樣化，深度交流\n• MBTI 類型高度兼容\n• 對未來有共同規劃',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternAnalysisExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '對話模式示例',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sarah 的對話模式分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildPatternItem('對話流暢度', '非常流暢', Icons.trending_up, Colors.green),
                _buildPatternItem('主導模式', '平衡互動', Icons.balance, Colors.blue),
                _buildPatternItem('話題多樣性', '豐富多元', Icons.diversity_3, Colors.orange),
                _buildPatternItem('情感基調', '積極正面', Icons.sentiment_very_satisfied, Colors.pink),
                
                const SizedBox(height: 16),
                
                const Text(
                  '建議：',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                const Text(
                  '• 保持現有的溝通節奏\n• 可以嘗試更深入的話題\n• 適時分享個人經歷',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 分析方法
  Future<void> _analyzeSincerity(Map<String, dynamic> partner) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analysis = await ConversationAnalysisService.analyzeSincerity(
        chatId: partner['chatId'],
        partnerId: partner['id'],
        messageLimit: 50,
      );

      if (mounted) {
        _showSincerityResults(partner, analysis);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _compareAllPartners() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final partnerIds = _chatPartners.map((p) => p['id'] as String).toList();
      final comparison = await ConversationAnalysisService.comparePartners(
        partnerIds: partnerIds,
        messageLimit: 30,
      );

      if (mounted) {
        _showComparisonResults(comparison);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('比較失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeConversationPattern(Map<String, dynamic> partner) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pattern = await ConversationAnalysisService.analyzeConversationPattern(
        chatId: partner['chatId'],
        partnerId: partner['id'],
        messageLimit: 100,
      );

      if (mounted) {
        _showPatternResults(partner, pattern);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分析失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSincerityResults(Map<String, dynamic> partner, SincerityAnalysis analysis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 標題
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(partner['avatar']),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${partner['name']} 的真心度分析',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 分數顯示
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getScoreColor(analysis.sincerityScore).withOpacity(0.1),
                          border: Border.all(
                            color: _getScoreColor(analysis.sincerityScore),
                            width: 4,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${analysis.sincerityScore}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: _getScoreColor(analysis.sincerityScore),
                                ),
                              ),
                              Text(
                                '真心度',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getScoreColor(analysis.sincerityScore),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getScoreDescription(analysis.sincerityScore),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 詳細分析
                _buildAnalysisSection('總體評估', analysis.overallAssessment),
                _buildAnalysisSection('回應質量', analysis.responseQuality),
                _buildAnalysisSection('情感深度', analysis.emotionalDepth),
                _buildAnalysisSection('一致性', analysis.consistency),
                
                if (analysis.positiveSignals.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSignalsList('積極信號', analysis.positiveSignals, Colors.green),
                ],
                
                if (analysis.redFlags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSignalsList('注意事項', analysis.redFlags, Colors.red),
                ],
                
                if (analysis.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSignalsList('建議', analysis.recommendations, Colors.blue),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComparisonResults(PartnerComparison comparison) {
    // 顯示比較結果的詳細界面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerComparisonResultPage(comparison: comparison),
      ),
    );
  }

  void _showPatternResults(Map<String, dynamic> partner, ConversationPattern pattern) {
    // 顯示對話模式分析結果
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${partner['name']} 的對話模式',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildAnalysisSection('對話流暢度', pattern.conversationFlow),
                _buildAnalysisSection('主導模式', pattern.dominancePattern),
                _buildAnalysisSection('話題多樣性', pattern.topicDiversity),
                _buildAnalysisSection('情感基調', pattern.emotionalTone),
                _buildAnalysisSection('溝通風格', pattern.communicationStyle),
                
                if (pattern.patterns.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSignalsList('發現的模式', pattern.patterns, Colors.purple),
                ],
                
                if (pattern.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSignalsList('改進建議', pattern.suggestions, Colors.blue),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsList(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return '高度真心';
    if (score >= 60) return '中等真心';
    return '需要觀察';
  }
}

// 伴侶比較結果頁面
class PartnerComparisonResultPage extends StatelessWidget {
  final PartnerComparison comparison;

  const PartnerComparisonResultPage({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('對象比較結果'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 最佳推薦
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏆 最佳匹配',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      comparison.topRecommendation.partnerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${comparison.topRecommendation.partnerAge} 歲 • ${comparison.topRecommendation.partnerMBTI}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '整體兼容性：${comparison.topRecommendation.overallScore.round()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 洞察
            if (comparison.insights.isNotEmpty) ...[
              const Text(
                '主要洞察',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...comparison.insights.map((insight) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.lightbulb,
                    color: Color(0xFFE91E63),
                  ),
                  title: Text(insight),
                ),
              )),
              const SizedBox(height: 24),
            ],
            
            // 詳細比較
            const Text(
              '詳細比較',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...comparison.partners.map((partner) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.partnerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildScoreRow('整體兼容性', partner.overallScore),
                    _buildScoreRow('溝通品質', partner.communicationScore),
                    _buildScoreRow('性格匹配', partner.personalityMatch),
                    _buildScoreRow('價值觀一致', partner.valueAlignment),
                    _buildScoreRow('未來兼容性', partner.futureCompatibility),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '${score.round()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 