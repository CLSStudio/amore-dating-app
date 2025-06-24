import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/mbti_models.dart';

class MBTIQuestionCard extends StatefulWidget {
  final MBTIQuestion question;
  final Function(MBTIAnswer) onAnswerSelected;
  final bool isSubmitting;

  const MBTIQuestionCard({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    this.isSubmitting = false,
  });

  @override
  State<MBTIQuestionCard> createState() => _MBTIQuestionCardState();
}

class _MBTIQuestionCardState extends State<MBTIQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  MBTIAnswer? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(MBTIAnswer answer) {
    if (widget.isSubmitting) return;
    
    setState(() => _selectedAnswer = answer);
    
    // 延遲一下再提交，讓用戶看到選擇效果
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onAnswerSelected(answer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // 問題區域
              _buildQuestionSection(),
              
              // 答案選項
              Expanded(
                child: _buildAnswerOptions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 問題圖標
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getQuestionIcon(widget.question.category),
              size: 40,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 問題文字
          Text(
            widget.question.text,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (widget.question.description != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.question.description!,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 提示文字
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.psychology_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '選擇最能代表你的選項',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 答案選項
          Expanded(
            child: ListView.separated(
              itemCount: widget.question.answers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final answer = widget.question.answers[index];
                return _buildAnswerOption(answer, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(MBTIAnswer answer, int index) {
    final isSelected = _selectedAnswer?.id == answer.id;
    final isSubmitting = widget.isSubmitting && isSelected;
    
    return GestureDetector(
      onTap: () => _selectAnswer(answer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // 選項標籤
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: AppTextStyles.button.copyWith(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 答案文字
            Expanded(
              child: Text(
                answer.text,
                style: AppTextStyles.body1.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
            
            // 載入指示器或選中圖標
            if (isSubmitting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getQuestionIcon(String category) {
    switch (category) {
      case 'EI':
        return Icons.people_outline;
      case 'SN':
        return Icons.lightbulb_outline;
      case 'TF':
        return Icons.favorite_outline;
      case 'JP':
        return Icons.schedule_outlined;
      default:
        return Icons.psychology_outlined;
    }
  }
} 