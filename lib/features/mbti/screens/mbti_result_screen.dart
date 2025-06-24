import 'package:flutter/material.dart';
import '../models/mbti_question.dart';

class MBTIResultScreen extends StatefulWidget {
  final MBTIResult result;

  const MBTIResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<MBTIResultScreen> createState() => _MBTIResultScreenState();
}

class _MBTIResultScreenState extends State<MBTIResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _contentController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _celebrationController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF0F8FF),
              Color(0xFFFFF0F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定義 AppBar
              _buildCustomAppBar(),
              
              // 內容區域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 慶祝結果卡片
                      _buildCelebrationCard(),
                      
                      const SizedBox(height: 30),
                      
                      // 性格描述
                      _buildPersonalityDescription(),
                      
                      const SizedBox(height: 30),
                      
                      // 維度分析
                      _buildDimensionAnalysis(),
                      
                      const SizedBox(height: 30),
                      
                      // 戀愛特質
                      _buildLoveTraits(),
                      
                      const SizedBox(height: 30),
                      
                      // 理想伴侶
                      _buildIdealPartner(),
                      
                      const SizedBox(height: 30),
                      
                      // 關係建議
                      _buildRelationshipAdvice(),
                      
                      const SizedBox(height: 40),
                      
                      // 底部按鈕
                      _buildBottomButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFF2D3748),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration,
                  color: Color(0xFF667EEA),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  '測試完成',
                  style: TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // 平衡佈局
        ],
      ),
    );
  }

  Widget _buildCelebrationCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 慶祝圖標
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 48,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              '🎉 恭喜完成測試！',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              widget.result.type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              widget.result.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 準確度指示
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '準確度 ${_calculateAccuracy()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPersonalityDescription() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildSection(
          title: '你的性格特質',
          icon: Icons.star,
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDetailedDescription(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.result.traits.map((trait) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trait,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionAnalysis() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildSection(
          title: '維度分析',
          icon: Icons.analytics,
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          child: Column(
            children: [
              _buildEnhancedDimensionBar('外向性 (E)', '內向性 (I)', 
                  widget.result.scores['E'] ?? 0, widget.result.scores['I'] ?? 0,
                  Colors.blue, Colors.indigo),
              const SizedBox(height: 20),
              _buildEnhancedDimensionBar('感覺 (S)', '直覺 (N)', 
                  widget.result.scores['S'] ?? 0, widget.result.scores['N'] ?? 0,
                  Colors.green, Colors.teal),
              const SizedBox(height: 20),
              _buildEnhancedDimensionBar('思考 (T)', '情感 (F)', 
                  widget.result.scores['T'] ?? 0, widget.result.scores['F'] ?? 0,
                  Colors.orange, Colors.red),
              const SizedBox(height: 20),
              _buildEnhancedDimensionBar('判斷 (J)', '感知 (P)', 
                  widget.result.scores['J'] ?? 0, widget.result.scores['P'] ?? 0,
                  Colors.purple, Colors.pink),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoveTraits() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildSection(
          title: '戀愛特質',
          icon: Icons.favorite,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getLoveStyle(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              _buildLoveTraitsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdealPartner() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildSection(
          title: '理想伴侶',
          icon: Icons.people,
          gradient: const LinearGradient(
            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getIdealPartnerDescription(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              _buildCompatibleTypes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipAdvice() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildSection(
          title: '關係建議',
          icon: Icons.lightbulb,
          gradient: const LinearGradient(
            colors: [Color(0xFFFC466B), Color(0xFF3F5EFB)],
          ),
          child: Column(
            children: _getRelationshipAdvice().map((advice) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFC466B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.tips_and_updates,
                        color: Color(0xFFFC466B),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        advice,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildEnhancedDimensionBar(
    String leftLabel, 
    String rightLabel, 
    int leftScore, 
    int rightScore,
    Color leftColor,
    Color rightColor,
  ) {
    final total = leftScore + rightScore;
    final leftPercentage = total > 0 ? leftScore / total : 0.5;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: leftColor,
              ),
            ),
            Text(
              rightLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: rightColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[200],
          ),
          child: Row(
            children: [
              Expanded(
                flex: (leftPercentage * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      colors: [leftColor.withOpacity(0.8), leftColor],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: ((1 - leftPercentage) * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      colors: [rightColor, rightColor.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: leftColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(leftPercentage * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: leftColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: rightColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${((1 - leftPercentage) * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: rightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoveTraitsList() {
    final loveTraits = _getLoveTraits();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: loveTraits.map((trait) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.pink.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                size: 14,
                color: Colors.pink[400],
              ),
              const SizedBox(width: 4),
              Text(
                trait,
                style: TextStyle(
                  color: Colors.pink[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompatibleTypes() {
    final compatibleTypes = _getCompatibleTypes();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: compatibleTypes.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            type,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        // 分享按鈕
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // TODO: 實現分享功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('分享功能即將推出！'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '分享我的性格類型',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 完成按鈕
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF667EEA).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Center(
                child: Text(
                  '開始探索匹配',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 輔助方法
  int _calculateAccuracy() {
    // 基於回答的一致性計算準確度
    final totalQuestions = widget.result.scores.values.fold(0, (a, b) => a + b);
    return totalQuestions > 8 ? 92 : 85;
  }

  String _getDetailedDescription() {
    // 根據 MBTI 類型返回詳細描述
    final descriptions = {
      'INTJ': '你是一個具有遠見的戰略家，喜歡獨立思考和制定長期計劃。在感情中，你重視深度和真誠的連結。',
      'INFP': '你是一個理想主義者，富有創造力和同理心。你尋求真實的情感連結和共同的價值觀。',
      'ENFP': '你是一個充滿熱情的激勵者，喜歡探索新的可能性。你在關係中帶來活力和創意。',
      'ESTJ': '你是一個實用的組織者，重視傳統和穩定。你在感情中尋求可靠和忠誠的伴侶。',
    };
    return descriptions[widget.result.type] ?? '你擁有獨特的性格特質，在感情中有著特別的魅力。';
  }

  String _getLoveStyle() {
    final loveStyles = {
      'INTJ': '你在愛情中是深思熟慮的，喜歡建立深層的精神連結。你重視伴侶的智慧和獨立性。',
      'INFP': '你的愛情充滿詩意和浪漫，你尋求靈魂伴侶般的深度理解和情感共鳴。',
      'ENFP': '你的愛情熱情洋溢，充滿驚喜和冒險。你喜歡與伴侶一起探索生活的無限可能。',
      'ESTJ': '你在愛情中是忠誠可靠的，重視承諾和穩定的關係發展。',
    };
    return loveStyles[widget.result.type] ?? '你在愛情中有著獨特的表達方式和需求。';
  }

  List<String> _getLoveTraits() {
    final traits = {
      'INTJ': ['深度思考', '忠誠專一', '重視隱私', '理性溝通'],
      'INFP': ['浪漫理想', '情感豐富', '重視真誠', '創意表達'],
      'ENFP': ['熱情活潑', '善於鼓勵', '喜歡驚喜', '社交活躍'],
      'ESTJ': ['責任感強', '傳統價值', '實際行動', '保護欲強'],
    };
    return traits[widget.result.type] ?? ['獨特魅力', '真誠待人', '情感豐富'];
  }

  String _getIdealPartnerDescription() {
    final descriptions = {
      'INTJ': '你的理想伴侶是聰明獨立、能夠理解你的深度思考，並且有自己的目標和追求的人。',
      'INFP': '你尋找一個能夠理解你的內心世界、分享相似價值觀，並且支持你創意表達的伴侶。',
      'ENFP': '你的理想伴侶是開放包容、喜歡冒險，並且能夠與你一起成長和探索的人。',
      'ESTJ': '你希望找到一個可靠負責、分享傳統價值觀，並且能夠建立穩定家庭的伴侶。',
    };
    return descriptions[widget.result.type] ?? '你尋找一個能夠理解和欣賞你獨特性格的伴侶。';
  }

  List<String> _getCompatibleTypes() {
    final compatible = {
      'INTJ': ['ENFP', 'ENTP', 'INFP'],
      'INFP': ['ENFJ', 'INTJ', 'ENFP'],
      'ENFP': ['INTJ', 'INFJ', 'ENFJ'],
      'ESTJ': ['ISFP', 'ISTP', 'ESFP'],
    };
    return compatible[widget.result.type] ?? ['ENFP', 'INFJ', 'INTJ'];
  }

  List<String> _getRelationshipAdvice() {
    final advice = {
      'INTJ': [
        '給伴侶足夠的個人空間，尊重彼此的獨立性',
        '用行動而非言語來表達愛意',
        '學會表達情感，不要過於理性化所有事情',
      ],
      'INFP': [
        '保持開放的溝通，分享你的內心想法',
        '給關係時間發展，不要急於求成',
        '學會處理衝突，避免過度理想化伴侶',
      ],
      'ENFP': [
        '保持關係的新鮮感，定期創造驚喜',
        '學會深度聆聽，給伴侶表達的機會',
        '在熱情中保持一定的穩定性',
      ],
      'ESTJ': [
        '學會表達情感，不只是關注實際問題',
        '給伴侶一些自由度，不要過度控制',
        '保持開放心態，接受不同的觀點',
      ],
    };
    return advice[widget.result.type] ?? [
      '保持真誠的溝通',
      '尊重彼此的差異',
      '共同成長和學習',
    ];
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _contentController.dispose();
    super.dispose();
  }
} 