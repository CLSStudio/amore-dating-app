import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LifestyleQuestionnaire extends StatefulWidget {
  final Map<String, dynamic> answers;
  final Function(Map<String, dynamic>) onAnswersChanged;

  const LifestyleQuestionnaire({
    super.key,
    required this.answers,
    required this.onAnswersChanged,
  });

  @override
  State<LifestyleQuestionnaire> createState() => _LifestyleQuestionnaireState();
}

class _LifestyleQuestionnaireState extends State<LifestyleQuestionnaire>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<QuestionData> _questions = [
    QuestionData(
      id: 'relationship_goal',
      question: '你在尋找什麼類型的關係？',
      type: QuestionType.singleChoice,
      options: [
        '長期認真關係',
        '短期約會',
        '朋友關係',
        '還在探索中',
        '開放式關係',
      ],
      isRequired: true,
    ),
    QuestionData(
      id: 'lifestyle_pace',
      question: '你的生活節奏是怎樣的？',
      type: QuestionType.singleChoice,
      options: [
        '快節奏，充滿活力',
        '中等節奏，平衡工作生活',
        '慢節奏，享受當下',
        '不規律，隨心而行',
      ],
      isRequired: true,
    ),
    QuestionData(
      id: 'social_preference',
      question: '你更喜歡哪種社交方式？',
      type: QuestionType.singleChoice,
      options: [
        '大型聚會和派對',
        '小型聚會和朋友聚餐',
        '一對一的深度交流',
        '安靜的獨處時光',
        '線上社交和遊戲',
      ],
      isRequired: true,
    ),
    QuestionData(
      id: 'values',
      question: '以下哪些價值觀對你最重要？（可多選）',
      type: QuestionType.multipleChoice,
      options: [
        '誠實和信任',
        '家庭和親情',
        '事業和成就',
        '冒險和探索',
        '穩定和安全',
        '創意和自由',
        '健康和運動',
        '學習和成長',
      ],
      isRequired: true,
      maxSelections: 5,
    ),
    QuestionData(
      id: 'future_plans',
      question: '你對未來 5 年的計劃是什麼？（可多選）',
      type: QuestionType.multipleChoice,
      options: [
        '專注事業發展',
        '結婚成家',
        '生育子女',
        '環遊世界',
        '學習新技能',
        '創業或投資',
        '買房置業',
        '照顧家人',
      ],
      isRequired: true,
      maxSelections: 4,
    ),
    QuestionData(
      id: 'communication_style',
      question: '你的溝通風格是？',
      type: QuestionType.singleChoice,
      options: [
        '直接坦率，有話直說',
        '溫和委婉，考慮感受',
        '幽默風趣，輕鬆愉快',
        '深思熟慮，邏輯清晰',
        '情感豐富，表達細膩',
      ],
      isRequired: true,
    ),
    QuestionData(
      id: 'conflict_resolution',
      question: '面對衝突時，你通常會？',
      type: QuestionType.singleChoice,
      options: [
        '直接討論，解決問題',
        '冷靜思考，再做決定',
        '尋求妥協，雙方讓步',
        '暫時迴避，等情緒平復',
        '尋求他人建議和幫助',
      ],
      isRequired: true,
    ),
    QuestionData(
      id: 'weekend_activities',
      question: '理想的週末是怎樣的？（可多選）',
      type: QuestionType.multipleChoice,
      options: [
        '戶外運動和探險',
        '在家放鬆和休息',
        '和朋友聚會',
        '學習新事物',
        '藝術和文化活動',
        '美食和購物',
        '旅行和探索',
        '志願服務',
      ],
      isRequired: false,
      maxSelections: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  void _updateAnswer(String questionId, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(widget.answers);
    newAnswers[questionId] = answer;
    widget.onAnswersChanged(newAnswers);
  }

  bool _isQuestionAnswered(QuestionData question) {
    final answer = widget.answers[question.id];
    if (answer == null) return false;
    
    if (question.type == QuestionType.multipleChoice) {
      return (answer as List).isNotEmpty;
    } else {
      return answer.toString().isNotEmpty;
    }
  }

  int get _answeredRequiredQuestions {
    return _questions
        .where((q) => q.isRequired && _isQuestionAnswered(q))
        .length;
  }

  int get _totalRequiredQuestions {
    return _questions.where((q) => q.isRequired).length;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 進度指示器
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '問卷進度',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '已完成 $_answeredRequiredQuestions/$_totalRequiredQuestions 個必答問題',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: _answeredRequiredQuestions / _totalRequiredQuestions,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 問題列表
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              return _buildQuestionCard(_questions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionData question) {
    final isAnswered = _isQuestionAnswered(question);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnswered ? AppColors.primary : AppColors.border,
          width: isAnswered ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAnswered 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 問題標題
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question.isRequired)
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              Expanded(
                child: Text(
                  question.question,
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isAnswered)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
          
          if (question.type == QuestionType.multipleChoice && question.maxSelections != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '最多選擇 ${question.maxSelections} 項',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 選項
          if (question.type == QuestionType.singleChoice)
            _buildSingleChoiceOptions(question)
          else
            _buildMultipleChoiceOptions(question),
        ],
      ),
    );
  }

  Widget _buildSingleChoiceOptions(QuestionData question) {
    final selectedAnswer = widget.answers[question.id] as String?;
    
    return Column(
      children: question.options.map((option) {
        final isSelected = selectedAnswer == option;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _updateAnswer(question.id, option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        width: 2,
                      ),
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTextStyles.body1.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(QuestionData question) {
    final selectedAnswers = (widget.answers[question.id] as List<String>?) ?? [];
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: question.options.map((option) {
        final isSelected = selectedAnswers.contains(option);
        final canSelect = selectedAnswers.length < (question.maxSelections ?? question.options.length);
        
        return GestureDetector(
          onTap: () {
            if (isSelected) {
              // 取消選擇
              final newAnswers = List<String>.from(selectedAnswers);
              newAnswers.remove(option);
              _updateAnswer(question.id, newAnswers);
            } else if (canSelect) {
              // 添加選擇
              final newAnswers = List<String>.from(selectedAnswers);
              newAnswers.add(option);
              _updateAnswer(question.id, newAnswers);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.border,
                width: 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class QuestionData {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final bool isRequired;
  final int? maxSelections;

  QuestionData({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.isRequired = false,
    this.maxSelections,
  });
}

enum QuestionType {
  singleChoice,
  multipleChoice,
} 