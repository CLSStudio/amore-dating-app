import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import 'data/datasources/values_questions_data.dart';
import 'domain/entities/values_assessment.dart';
import 'values_result_page.dart';

class CompleteValuesAssessmentPage extends ConsumerStatefulWidget {
  const CompleteValuesAssessmentPage({super.key});

  @override
  ConsumerState<CompleteValuesAssessmentPage> createState() => _CompleteValuesAssessmentPageState();
}

class _CompleteValuesAssessmentPageState extends ConsumerState<CompleteValuesAssessmentPage>
    with TickerProviderStateMixin {
  
  final PageController _pageController = PageController();
  late AnimationController _progressController;
  late AnimationController _slideController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentQuestionIndex = 0;
  Map<String, String> _answers = {};
  List<ValuesQuestion> _questions = [];
  
  // 人生階段問題
  Map<String, dynamic> _lifeStageAnswers = {};
  
  @override
  void initState() {
    super.initState();
    _questions = ValuesQuestionsData.getQuestions();
    _setupAnimations();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _progressController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double get _progress => (_currentQuestionIndex + 1) / (_questions.length + 5); // +5 for life stage questions

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      
      _slideController.reset();
      _slideController.forward();
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 進入人生階段問卷
      _navigateToLifeStageQuestions();
    }
  }

  void _previousQuestion() {
    HapticFeedback.lightImpact();
    
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectAnswer(String questionId, String answerId) {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _answers[questionId] = answerId;
    });
    
    // 自動進入下一題
    Future.delayed(const Duration(milliseconds: 500), () {
      _nextQuestion();
    });
  }

  void _navigateToLifeStageQuestions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LifeStageQuestionnairePage(
          valuesAnswers: _answers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(_questions[index]);
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    '${_currentQuestionIndex + 1} / ${_questions.length}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '🎯 價值觀深度測評',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '了解您的核心價值觀，為您匹配更合適的伴侶',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: AppSpacing.pagePadding,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '進度',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(ValuesQuestion question) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                
                // 問題類別標籤
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    question.category.displayName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // 問題標題
                Text(
                  question.question,
                  style: AppTextStyles.h3.copyWith(
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // 問題描述
                Text(
                  question.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // 選項
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isSelected = _answers[question.id] == option.id;
                      
                      return _buildOptionCard(question.id, option, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(String questionId, ValuesOption option, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppShadows.floating : AppShadows.card,
      ),
      child: AppCard(
        onTap: () => _selectAnswer(questionId, option.id),
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                option.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: AppSpacing.pagePadding,
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: AppButton(
                text: '上一題',
                onPressed: _previousQuestion,
                type: AppButtonType.outline,
                icon: Icons.arrow_back,
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AppButton(
              text: _currentQuestionIndex == _questions.length - 1 
                  ? '進入人生階段測評' 
                  : '下一題',
              onPressed: _answers.containsKey(_questions[_currentQuestionIndex].id) 
                  ? _nextQuestion 
                  : null,
              type: AppButtonType.primary,
              icon: Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}

// 人生階段問卷頁面
class LifeStageQuestionnairePage extends ConsumerStatefulWidget {
  final Map<String, String> valuesAnswers;

  const LifeStageQuestionnairePage({
    super.key,
    required this.valuesAnswers,
  });

  @override
  ConsumerState<LifeStageQuestionnairePage> createState() => _LifeStageQuestionnairePageState();
}

class _LifeStageQuestionnairePageState extends ConsumerState<LifeStageQuestionnairePage>
    with TickerProviderStateMixin {
  
  Map<String, dynamic> _lifeStageAnswers = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<LifeStageQuestion> _lifeStageQuestions = [
    LifeStageQuestion(
      id: 'current_life_stage',
      question: '您目前處於人生的哪個階段？',
      type: LifeStageQuestionType.singleChoice,
      options: [
        '剛踏入社會，探索職業方向',
        '職業穩定發展期',
        '事業上升期，追求更大發展',
        '尋求工作生活平衡',
        '考慮人生轉換，探索新可能',
      ],
    ),
    LifeStageQuestion(
      id: 'relationship_goals',
      question: '您對感情關係的期望是什麼？',
      type: LifeStageQuestionType.multipleChoice,
      maxSelections: 3,
      options: [
        '尋找生活伴侶，建立穩定關係',
        '希望在1-2年內結婚',
        '想要組建家庭，生育子女',
        '重視精神契合，尋找靈魂伴侶',
        '希望伴侶能支持我的事業發展',
        '想要一起探索世界，體驗人生',
        '尋找能共同成長的伴侶',
      ],
    ),
    LifeStageQuestion(
      id: 'family_planning',
      question: '您對組建家庭的想法是？',
      type: LifeStageQuestionType.singleChoice,
      options: [
        '非常渴望有自己的家庭和孩子',
        '希望結婚但暫時不考慮生育',
        '對組建家庭持開放態度',
        '更專注於事業，家庭不是優先考慮',
        '暫時不確定，需要更多時間思考',
      ],
    ),
    LifeStageQuestion(
      id: 'career_priorities',
      question: '未來5年，您的事業重點是什麼？',
      type: LifeStageQuestionType.multipleChoice,
      maxSelections: 3,
      options: [
        '在現有崗位上深入發展',
        '尋求晉升機會，承擔更多責任',
        '轉換行業或職業方向',
        '創業或成為自由職業者',
        '追求工作與生活的平衡',
        '提升專業技能和學歷',
        '擴展國際經驗',
      ],
    ),
    LifeStageQuestion(
      id: 'life_goals',
      question: '您最重要的人生目標是什麼？',
      type: LifeStageQuestionType.ranking,
      options: [
        '建立幸福美滿的家庭',
        '實現事業成功和財務自由',
        '保持身心健康',
        '追求個人興趣和愛好',
        '對社會產生正面影響',
        '環遊世界，體驗不同文化',
        '不斷學習和自我提升',
      ],
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _completeAssessment() async {
    // 合併價值觀和人生階段答案
    final allAnswers = Map<String, dynamic>.from(widget.valuesAnswers);
    allAnswers.addAll(_lifeStageAnswers);
    
    // 計算結果
    final assessment = ValuesQuestionsData.calculateResult(
      widget.valuesAnswers,
      'current_user_id', // 這裡應該從認證服務獲取
    );
    
    // 導航到結果頁面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ValuesResultPage(
          assessment: assessment,
          lifeStageAnswers: _lifeStageAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        ..._lifeStageQuestions.map((question) => 
                            _buildLifeStageQuestion(question)).toList(),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildCompleteButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.pagePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    '第二階段',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '🎯 人生階段深度分析',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '了解您的人生目標和期望，為您提供更精準的配對建議',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeStageQuestion(LifeStageQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: AppTextStyles.h4.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            if (question.type == LifeStageQuestionType.singleChoice)
              _buildSingleChoiceOptions(question)
            else if (question.type == LifeStageQuestionType.multipleChoice)
              _buildMultipleChoiceOptions(question)
            else if (question.type == LifeStageQuestionType.ranking)
              _buildRankingOptions(question),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleChoiceOptions(LifeStageQuestion question) {
    final selectedAnswer = _lifeStageAnswers[question.id] as String?;
    
    return Column(
      children: question.options.map((option) {
        final isSelected = selectedAnswer == option;
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            onTap: () {
              setState(() {
                _lifeStageAnswers[question.id] = option;
              });
            },
            leading: Radio<String>(
              value: option,
              groupValue: selectedAnswer,
              onChanged: (value) {
                setState(() {
                  _lifeStageAnswers[question.id] = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            title: Text(
              option,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            tileColor: isSelected ? AppColors.primary.withOpacity(0.05) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(LifeStageQuestion question) {
    final selectedAnswers = (_lifeStageAnswers[question.id] as List<String>?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.maxSelections != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              '最多選擇 ${question.maxSelections} 項',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        
        ...question.options.map((option) {
          final isSelected = selectedAnswers.contains(option);
          final canSelect = selectedAnswers.length < (question.maxSelections ?? question.options.length);
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (canSelect || isSelected) ? (value) {
                setState(() {
                  final answers = List<String>.from(selectedAnswers);
                  if (value == true) {
                    answers.add(option);
                  } else {
                    answers.remove(option);
                  }
                  _lifeStageAnswers[question.id] = answers;
                });
              } : null,
              title: Text(
                option,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              activeColor: AppColors.primary,
              tileColor: isSelected ? AppColors.primary.withOpacity(0.05) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRankingOptions(LifeStageQuestion question) {
    final rankings = (_lifeStageAnswers[question.id] as List<String>?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '請按重要程度排序（拖拽排列）',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              
              List<String> items = rankings.isEmpty 
                  ? List<String>.from(question.options) 
                  : List<String>.from(rankings);
              
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              _lifeStageAnswers[question.id] = items;
            });
          },
          children: (rankings.isEmpty ? question.options : rankings)
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final option = entry.value;
            
            return Container(
              key: ValueKey(option),
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  option,
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: const Icon(Icons.drag_handle),
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    final isComplete = _lifeStageQuestions.every((question) => 
        _lifeStageAnswers.containsKey(question.id));
    
    return AppButton(
      text: '完成測評',
      onPressed: isComplete ? _completeAssessment : null,
      type: AppButtonType.primary,
      icon: Icons.check_circle,
      isFullWidth: true,
    );
  }
}

// 人生階段問題模型
class LifeStageQuestion {
  final String id;
  final String question;
  final LifeStageQuestionType type;
  final List<String> options;
  final int? maxSelections;

  LifeStageQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.maxSelections,
  });
}

enum LifeStageQuestionType {
  singleChoice,
  multipleChoice,
  ranking,
} 