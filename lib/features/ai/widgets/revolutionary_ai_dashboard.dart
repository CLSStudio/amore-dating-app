import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../revolutionary_ai_features.dart';
import '../ai_personalization_engine.dart';

/// 🚀 革命性 AI 功能儀表板
/// 這是我們的核心差異化產品，讓用戶願意付費的獨特體驗
class RevolutionaryAIDashboard extends ConsumerStatefulWidget {
  final String userId;
  final String? partnerId;

  const RevolutionaryAIDashboard({
    super.key,
    required this.userId,
    this.partnerId,
  });

  @override
  ConsumerState<RevolutionaryAIDashboard> createState() => _RevolutionaryAIDashboardState();
}

class _RevolutionaryAIDashboardState extends ConsumerState<RevolutionaryAIDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 AI 愛情顧問'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: '真心度分析'),
            Tab(icon: Icon(Icons.insights), text: '關係預測'),
            Tab(icon: Icon(Icons.chat_bubble_outline), text: '對話優化'),
            Tab(icon: Icon(Icons.trending_up), text: '個人成長'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSincerityAnalysisTab(),
          _buildRelationshipPredictionTab(),
          _buildConversationOptimizationTab(),
          _buildPersonalGrowthTab(),
        ],
      ),
    );
  }

  /// 🎯 真心度分析頁面
  Widget _buildSincerityAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumHeader(
            '💎 情感智能分析',
            '深度解析對話中的真心程度，讓你不再被欺騙',
          ),
          const SizedBox(height: 20),
          
          // 真心度儀表
          _buildSincerityMeter(),
          
          const SizedBox(height: 20),
          
          // 分析詳情
          _buildAnalysisCards([
            _buildInsightCard(
              '語言模式分析',
              '對方在對話中表現出85%的問題頻率，顯示高度的興趣和投入',
              Icons.psychology,
              Colors.blue,
            ),
            _buildInsightCard(
              '回應時間分析',
              '回應時間一致性高達92%，顯示真誠的關注和穩定的情感狀態',
              Icons.schedule,
              Colors.green,
            ),
            _buildInsightCard(
              '情感一致性',
              '情感表達保持78%的正面比例，情緒穩定且真實',
              Icons.favorite,
              Colors.pink,
            ),
          ]),
          
          const SizedBox(height: 20),
          
          // 警告信號和積極信號
          _buildFlagsSection(),
        ],
      ),
    );
  }

  /// 💝 關係預測頁面
  Widget _buildRelationshipPredictionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumHeader(
            '🔮 關係成功預測',
            '基於AI深度分析，預測你們關係的發展軌跡',
          ),
          const SizedBox(height: 20),
          
          // 成功率圓形圖
          _buildSuccessProbabilityCircle(),
          
          const SizedBox(height: 20),
          
          // MBTI 兼容性詳細分析
          _buildMBTICompatibilitySection(),
          
          const SizedBox(height: 20),
          
          // 關係里程碑預測
          _buildMilestonePrediction(),
          
          const SizedBox(height: 20),
          
          // 改善建議
          _buildImprovementSuggestions(),
        ],
      ),
    );
  }

  /// 🗣️ 對話優化頁面
  Widget _buildConversationOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumHeader(
            '💬 即時對話優化',
            '實時分析對話狀況，提供最佳回應建議',
          ),
          const SizedBox(height: 20),
          
          // 對話健康度
          _buildConversationHealthBar(),
          
          const SizedBox(height: 20),
          
          // 即時建議
          _buildConversationSuggestions(),
          
          const SizedBox(height: 20),
          
          // 最佳話題預測
          _buildOptimalTopics(),
        ],
      ),
    );
  }

  /// 📈 個人成長頁面
  Widget _buildPersonalGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumHeader(
            '🌱 個人成長追蹤',
            '追蹤你的戀愛技巧發展，持續提升魅力',
          ),
          const SizedBox(height: 20),
          
          // 成長軌跡圖表
          _buildGrowthChart(),
          
          const SizedBox(height: 20),
          
          // 技能發展
          _buildSkillDevelopment(),
          
          const SizedBox(height: 20),
          
          // 個人化建議
          _buildPersonalizedRecommendations(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSincerityMeter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '真心度指數',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: 0.87,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Column(
                children: [
                  const Text(
                    '87%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '高度真誠',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '這個人在對話中展現出很高的真誠度，值得進一步發展關係',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCards(List<Widget> cards) {
    return Column(children: cards);
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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

  Widget _buildFlagsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildFlagCard(
            '積極信號',
            ['💚 展現同理心', '🤔 提出深度問題', '🦋 願意展現脆弱面'],
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFlagCard(
            '注意信號',
            ['⚠️ 暫無發現'],
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildFlagCard(String title, List<String> flags, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
          ...flags.map((flag) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              flag,
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSuccessProbabilityCircle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '關係成功率',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 0.84,
                  strokeWidth: 15,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
              Column(
                children: [
                  const Text(
                    '84%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    '高度匹配',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '預計 45 天內確定關係',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMBTICompatibilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MBTI 深度兼容性分析',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCompatibilityBar('認知功能互補', 0.92, Colors.purple),
          _buildCompatibilityBar('溝通方式協調', 0.88, Colors.blue),
          _buildCompatibilityBar('價值觀對齊', 0.75, Colors.green),
          _buildCompatibilityBar('情感智商匹配', 0.91, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildCompatibilityBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              )),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonePrediction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '關係里程碑預測',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMilestoneItem('💬', '深度對話', '1-2 週', true),
          _buildMilestoneItem('🍽️', '第一次約會', '2-3 週', true),
          _buildMilestoneItem('💕', '確定關係', '1-2 個月', false),
          _buildMilestoneItem('🏠', '見家長', '3-4 個月', false),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(String emoji, String title, String time, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: completed ? Colors.green : Colors.black87,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 個人化改善建議',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSuggestionItem('增進溝通深度', '嘗試分享更多個人經歷和感受'),
          _buildSuggestionItem('平衡對話節奏', '給對方更多表達空間'),
          _buildSuggestionItem('建立共同活動', '規劃一些雙方都感興趣的活動'),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
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

  Widget _buildConversationHealthBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '對話健康度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHealthIndicator('能量水平', 0.85, Colors.orange, '活力十足'),
          _buildHealthIndicator('深度水平', 0.72, Colors.blue, '中等深度'),
          _buildHealthIndicator('和諧程度', 0.91, Colors.green, '非常和諧'),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String label, double value, Color color, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(status, style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              )),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 即時對話建議',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSuggestionCard(
            '嘗試深度話題',
            '可以詢問對方的童年回憶或未來夢想',
            Icons.psychology,
            Colors.purple,
          ),
          _buildSuggestionCard(
            '分享個人經歷',
            '適時分享你的一些有趣經歷，增進親密感',
            Icons.share,
            Colors.blue,
          ),
          _buildSuggestionCard(
            '表達真實感受',
            '對方剛才的分享讓你很感動，可以表達出來',
            Icons.favorite,
            Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalTopics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 最佳話題預測',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTopicChip('旅行經歷', 0.92),
              _buildTopicChip('童年回憶', 0.88),
              _buildTopicChip('未來規劃', 0.85),
              _buildTopicChip('興趣愛好', 0.82),
              _buildTopicChip('美食分享', 0.79),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String topic, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            topic,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.deepPurple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 成長軌跡',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                '過去30天你的溝通技巧提升了23%\n對話深度增加了18%\n情感表達能力增強了31%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillDevelopment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 技能發展',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSkillBar('溝通技巧', 0.78, Colors.blue),
          _buildSkillBar('情感表達', 0.82, Colors.pink),
          _buildSkillBar('衝突處理', 0.65, Colors.orange),
          _buildSkillBar('同理心', 0.89, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSkillBar(String skill, double level, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill, style: const TextStyle(fontSize: 14)),
              Text('${(level * 100).toInt()}%', style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              )),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: level,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 本週成長建議',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            '練習深度聆聽',
            '在對話中專注於理解對方的感受，而非急於給建議',
            Icons.hearing,
          ),
          _buildRecommendationItem(
            '增強情感詞彙',
            '學習更多精確描述情感的詞彙，提升表達能力',
            Icons.psychology,
          ),
          _buildRecommendationItem(
            '培養耐心',
            '在衝突時先暫停思考，給自己和對方冷靜的空間',
            Icons.self_improvement,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
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
} 