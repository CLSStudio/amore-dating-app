import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/mbti_models.dart';
import '../services/mbti_service.dart';
import '../widgets/mbti_personality_card.dart';
import '../widgets/mbti_compatibility_chart.dart';
import '../widgets/mbti_traits_radar.dart';

class MBTIResultPage extends ConsumerStatefulWidget {
  final MBTIResult result;

  const MBTIResultPage({
    super.key,
    required this.result,
  });

  @override
  ConsumerState<MBTIResultPage> createState() => _MBTIResultPageState();
}

class _MBTIResultPageState extends ConsumerState<MBTIResultPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  MBTIPersonality? _personality;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _loadPersonalityData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalityData() async {
    try {
      final mbtiService = ref.read(mbtiServiceProvider);
      _personality = await mbtiService.getPersonalityDescription(widget.result.personalityType);
      
      setState(() => _isLoading = false);
      
      // 開始動畫
      _animationController.forward();
      await Future.delayed(const Duration(milliseconds: 400));
      _cardAnimationController.forward();
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('載入人格分析失敗');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '錯誤',
          style: AppTextStyles.heading4.copyWith(color: AppColors.error),
        ),
        content: Text(message, style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '確定',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導航
            _buildHeader(),
            
            // 主要內容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // 人格類型卡片
                        _buildPersonalityTypeCard(),
                        
                        const SizedBox(height: 24),
                        
                        // 人格描述
                        if (_personality != null) _buildPersonalityDescription(),
                        
                        const SizedBox(height: 24),
                        
                        // 特質雷達圖
                        _buildTraitsSection(),
                        
                        const SizedBox(height: 24),
                        
                        // 兼容性分析
                        _buildCompatibilitySection(),
                        
                        const SizedBox(height: 24),
                        
                        // 職業建議
                        if (_personality != null) _buildCareerSuggestions(),
                        
                        const SizedBox(height: 24),
                        
                        // 關係建議
                        if (_personality != null) _buildRelationshipAdvice(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // 底部按鈕
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '分析你的人格特質',
              style: AppTextStyles.heading2,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '正在為你生成詳細的人格分析報告...',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'MBTI 測試結果',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResult,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTypeCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // 人格類型圖標
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.psychology,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 人格類型
            Text(
              widget.result.personalityType,
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 人格標題
            if (_personality != null)
              Text(
                _personality!.title,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 16),
            
            // 簡短描述
            if (_personality != null)
              Text(
                _personality!.shortDescription,
                style: AppTextStyles.body1.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityDescription() {
    return MBTIPersonalityCard(
      personality: _personality!,
      result: widget.result,
    );
  }

  Widget _buildTraitsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.radar,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                '人格特質分析',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          MBTITraitsRadar(
            result: widget.result,
          ),
          
          const SizedBox(height: 20),
          
          _buildTraitsBars(),
        ],
      ),
    );
  }

  Widget _buildTraitsBars() {
    final traits = [
      ('外向性', widget.result.extraversionScore / 100),
      ('直覺性', widget.result.intuitionScore / 100),
      ('思考性', widget.result.thinkingScore / 100),
      ('判斷性', widget.result.judgingScore / 100),
    ];

    return Column(
      children: traits.map((trait) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trait.$1,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(trait.$2 * 100).round()}%',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: trait.$2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompatibilitySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                '兼容性分析',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          MBTICompatibilityChart(
            personalityType: widget.result.personalityType,
          ),
        ],
      ),
    );
  }

  Widget _buildCareerSuggestions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.work_outline,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                '職業建議',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            '根據你的人格特質，以下職業可能適合你：',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _personality!.careerSuggestions.map((career) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  career,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipAdvice() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.people_outline,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                '關係建議',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdviceItem('優點', _personality!.relationshipStrengths),
              const SizedBox(height: 16),
              _buildAdviceItem('注意事項', _personality!.relationshipChallenges),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.body1.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: '重新測試',
              onPressed: _retakeTest,
              variant: ButtonVariant.outlined,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            flex: 2,
            child: CustomButton(
              text: '開始匹配',
              onPressed: _startMatching,
            ),
          ),
        ],
      ),
    );
  }

  void _shareResult() {
    // TODO: 實現分享功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享結果', style: AppTextStyles.heading4),
        content: const Text('分享功能即將推出！', style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '確定',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _retakeTest() {
    Navigator.pushReplacementNamed(context, '/mbti-test');
  }

  void _startMatching() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }
} 