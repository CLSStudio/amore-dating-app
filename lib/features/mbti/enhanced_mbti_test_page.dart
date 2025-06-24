import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'mbti_data_models.dart';
import 'mbti_result_page.dart';

// MBTI 測試狀態管理
final currentQuestionProvider = StateProvider<int>((ref) => 0);
final answersProvider = StateProvider<Map<int, bool>>((ref) => {});
final testResultProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final testModeProvider = StateProvider<MBTITestMode>((ref) => MBTITestMode.interactive);
final animationControllerProvider = StateProvider<bool>((ref) => false);

enum MBTITestMode {
  interactive,    // 互動式
  professional,  // 專業版
  quick         // 快速版
}

class EnhancedMBTITestPage extends ConsumerStatefulWidget {
  final MBTITestMode mode;
  
  const EnhancedMBTITestPage({
    super.key,
    this.mode = MBTITestMode.interactive,
  });

  @override
  ConsumerState<EnhancedMBTITestPage> createState() => _EnhancedMBTITestPageState();
}

class _EnhancedMBTITestPageState extends ConsumerState<EnhancedMBTITestPage>
    with TickerProviderStateMixin {
  
  late AnimationController _progressAnimationController;
  late AnimationController _questionAnimationController;
  late AnimationController _optionAnimationController;
  
  late Animation<double> _progressAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _optionScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _questionAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _optionAnimationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );

    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeOutCubic),
    );

    _questionFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeIn),
    );

    _optionScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _optionAnimationController, curve: Curves.elasticOut),
    );

    _questionAnimationController.forward();
    _optionAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _questionAnimationController.dispose();
    _optionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = ref.watch(currentQuestionProvider);
    final answers = ref.watch(answersProvider);
    final testResult = ref.watch(testResultProvider);

    if (testResult != null) {
      return MBTIResultPage(result: testResult);
    }

    final questions = MBTIQuestions.getQuestions(widget.mode);
    
    if (currentQuestion >= questions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = _calculateMBTIResult(answers, questions);
        ref.read(testResultProvider.notifier).state = result;
      });
      return _buildCalculatingPage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(currentQuestion, questions.length),
            Expanded(
              child: _buildQuestionContent(questions[currentQuestion], currentQuestion),
            ),
            _buildNavigationButtons(currentQuestion, questions.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int currentQuestion, int totalQuestions) {
    final progress = (currentQuestion + 1) / totalQuestions;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MBTI 性格測試',
                      style: AppTextStyles.h5.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getModeDescription(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  '${currentQuestion + 1}/$totalQuestions',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProgressBar(progress),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進度',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimationController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _progressAnimation.value,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(MBTIQuestion question, int questionIndex) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          _buildQuestionCard(question),
          const SizedBox(height: AppSpacing.xl),
          _buildOptionsSection(question, questionIndex),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(MBTIQuestion question) {
    return SlideTransition(
      position: _questionSlideAnimation,
      child: FadeTransition(
        opacity: _questionFadeAnimation,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _getDimensionColor(question.dimension).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(
                  _getDimensionIcon(question.dimension),
                  size: 32,
                  color: _getDimensionColor(question.dimension),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                question.question,
                style: AppTextStyles.h4.copyWith(
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _getDimensionColor(question.dimension).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Text(
                  _getDimensionName(question.dimension),
                  style: AppTextStyles.caption.copyWith(
                    color: _getDimensionColor(question.dimension),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(MBTIQuestion question, int questionIndex) {
    return ScaleTransition(
      scale: _optionScaleAnimation,
      child: Column(
        children: [
          _buildOptionCard(
            question.trueAnswer,
            true,
            questionIndex,
            _getDimensionColor(question.dimension),
            Icons.trending_up,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildOptionCard(
            question.falseAnswer,
            false,
            questionIndex,
            _getDimensionColor(question.dimension).withOpacity(0.7),
            Icons.trending_down,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    String text,
    bool value,
    int questionIndex,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _answerQuestion(questionIndex, value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(int currentQuestion, int totalQuestions) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          if (currentQuestion > 0)
            Expanded(
              child: AppButton(
                text: '上一題',
                onPressed: () => _goToPreviousQuestion(currentQuestion),
                type: AppButtonType.outline,
                icon: Icons.arrow_back,
              ),
            ),
          if (currentQuestion > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AppButton(
              text: currentQuestion == totalQuestions - 1 ? '完成測試' : '跳過',
              onPressed: () => _skipQuestion(currentQuestion, totalQuestions),
              type: AppButtonType.ghost,
              icon: currentQuestion == totalQuestions - 1 ? Icons.check : Icons.skip_next,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatingPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppShadows.floating,
              ),
              child: const AppLoadingIndicator(
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '正在分析您的性格類型...',
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '這需要一點時間來精確計算',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _answerQuestion(int questionIndex, bool answer) {
    HapticFeedback.mediumImpact();
    
    final answers = ref.read(answersProvider);
    ref.read(answersProvider.notifier).state = {
      ...answers,
      questionIndex: answer,
    };
    
    _progressAnimationController.forward();
    
    Future.delayed(AppAnimations.fast, () {
      _questionAnimationController.reset();
      _optionAnimationController.reset();
      
      ref.read(currentQuestionProvider.notifier).state = questionIndex + 1;
      
      _questionAnimationController.forward();
      _optionAnimationController.forward();
    });
  }

  void _goToPreviousQuestion(int currentQuestion) {
    HapticFeedback.lightImpact();
    
    _questionAnimationController.reset();
    ref.read(currentQuestionProvider.notifier).state = currentQuestion - 1;
    _questionAnimationController.forward();
  }

  void _skipQuestion(int currentQuestion, int totalQuestions) {
    HapticFeedback.lightImpact();
    
    if (currentQuestion == totalQuestions - 1) {
      // 完成測試
      final answers = ref.read(answersProvider);
      final questions = MBTIQuestions.getQuestions(widget.mode);
      final result = _calculateMBTIResult(answers, questions);
      ref.read(testResultProvider.notifier).state = result;
    } else {
      // 跳過當前問題
      ref.read(currentQuestionProvider.notifier).state = currentQuestion + 1;
    }
  }

  String _getModeDescription() {
    switch (widget.mode) {
      case MBTITestMode.interactive:
        return '互動式測試 • 深度分析';
      case MBTITestMode.professional:
        return '專業版 • 60題完整版';
      case MBTITestMode.quick:
        return '快速版 • 16題精簡版';
    }
  }

  Color _getDimensionColor(String dimension) {
    switch (dimension) {
      case 'E/I':
        return Colors.blue;
      case 'S/N':
        return Colors.green;
      case 'T/F':
        return Colors.orange;
      case 'J/P':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getDimensionIcon(String dimension) {
    switch (dimension) {
      case 'E/I':
        return Icons.people;
      case 'S/N':
        return Icons.lightbulb;
      case 'T/F':
        return Icons.psychology;
      case 'J/P':
        return Icons.schedule;
      default:
        return Icons.quiz;
    }
  }

  String _getDimensionName(String dimension) {
    switch (dimension) {
      case 'E/I':
        return '外向性 vs 內向性';
      case 'S/N':
        return '感覺 vs 直覺';
      case 'T/F':
        return '思考 vs 情感';
      case 'J/P':
        return '判斷 vs 知覺';
      default:
        return '性格維度';
    }
  }

  Map<String, dynamic> _calculateMBTIResult(Map<int, bool> answers, List<MBTIQuestion> questions) {
    Map<String, int> scores = {
      'E': 0, 'I': 0,
      'S': 0, 'N': 0,
      'T': 0, 'F': 0,
      'J': 0, 'P': 0,
    };

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final answer = answers[i];
      
      if (answer == null) continue; // 跳過未回答的問題

      switch (question.dimension) {
        case 'E/I':
          answer ? scores['E'] = scores['E']! + 1 : scores['I'] = scores['I']! + 1;
          break;
        case 'S/N':
          answer ? scores['S'] = scores['S']! + 1 : scores['N'] = scores['N']! + 1;
          break;
        case 'T/F':
          answer ? scores['T'] = scores['T']! + 1 : scores['F'] = scores['F']! + 1;
          break;
        case 'J/P':
          answer ? scores['J'] = scores['J']! + 1 : scores['P'] = scores['P']! + 1;
          break;
      }
    }

    String type = '';
    type += scores['E']! > scores['I']! ? 'E' : 'I';
    type += scores['S']! > scores['N']! ? 'S' : 'N';
    type += scores['T']! > scores['F']! ? 'T' : 'F';
    type += scores['J']! > scores['P']! ? 'J' : 'P';

    return {
      'type': type,
      'description': _getMBTIDescription(type),
      'scores': scores,
    };
  }

  String _getMBTIDescription(String type) {
    switch (type) {
      case 'ENFP':
        return '外向、直覺、情感、感知型 - 充滿熱情的激勵者';
      case 'ENFJ':
        return '外向、直覺、情感、判斷型 - 熱情的教育家';
      case 'ENTP':
        return '外向、直覺、思考、感知型 - 充滿創意的思想家';
      case 'ENTJ':
        return '外向、直覺、思考、判斷型 - 天生的領導者';
      case 'ESFP':
        return '外向、感覺、情感、感知型 - 自由奔放的娛樂者';
      case 'ESFJ':
        return '外向、感覺、情感、判斷型 - 盡職盡責的主人';
      case 'ESTP':
        return '外向、感覺、思考、感知型 - 充滿活力的實踐者';
      case 'ESTJ':
        return '外向、感覺、思考、判斷型 - 嚴格的管理者';
      case 'INFP':
        return '內向、直覺、情感、感知型 - 理想主義的夢想家';
      case 'INFJ':
        return '內向、直覺、情感、判斷型 - 富有洞察力的倡導者';
      case 'INTP':
        return '內向、直覺、思考、感知型 - 邏輯性的思想家';
      case 'INTJ':
        return '內向、直覺、思考、判斷型 - 獨立的戰略家';
      case 'ISFP':
        return '內向、感覺、情感、感知型 - 靈活的藝術家';
      case 'ISFJ':
        return '內向、感覺、情感、判斷型 - 盡職的保護者';
      case 'ISTP':
        return '內向、感覺、思考、感知型 - 大膽的實驗家';
      case 'ISTJ':
        return '內向、感覺、思考、判斷型 - 務實的守護者';
      default:
        return '您的獨特性格類型';
    }
  }
} 