import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/mbti_models.dart';
import '../services/mbti_service.dart';
import '../widgets/mbti_question_card.dart';
import '../widgets/mbti_progress_indicator.dart';

class MBTITestPage extends ConsumerStatefulWidget {
  const MBTITestPage({super.key});

  @override
  ConsumerState<MBTITestPage> createState() => _MBTITestPageState();
}

class _MBTITestPageState extends ConsumerState<MBTITestPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<MBTIQuestion> _questions = [];
  MBTITestSession? _testSession;
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeIn,
    ));
    
    _initializeTest();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeTest() async {
    try {
      final mbtiService = ref.read(mbtiServiceProvider);
      
      // 獲取問題
      _questions = await mbtiService.getQuestions();
      
      // 創建測試會話
      _testSession = await mbtiService.startTestSession('current_user_id'); // TODO: 使用真實用戶ID
      
      setState(() => _isLoading = false);
      
      // 開始動畫
      _cardAnimationController.forward();
      _updateProgress();
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('初始化測試失敗，請重試');
    }
  }

  void _updateProgress() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    _progressAnimationController.animateTo(progress);
  }

  Future<void> _answerQuestion(MBTIAnswer answer) async {
    if (_testSession == null || _isSubmitting) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final mbtiService = ref.read(mbtiServiceProvider);
      final currentQuestion = _questions[_currentQuestionIndex];
      
      // 記錄答案
      _testSession = await mbtiService.answerQuestion(
        sessionId: _testSession!.id,
        questionId: currentQuestion.id,
        answerId: answer.id,
        answer: answer,
      );
      
      // 移動到下一題
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      } else {
        _completeTest();
      }
      
    } catch (e) {
      _showErrorDialog('提交答案失敗，請重試');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _nextQuestion() {
    setState(() => _currentQuestionIndex++);
    
    _cardAnimationController.reset();
    _cardAnimationController.forward();
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    _updateProgress();
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      _updateProgress();
    }
  }

  Future<void> _completeTest() async {
    if (_testSession == null) return;
    
    try {
      final mbtiService = ref.read(mbtiServiceProvider);
      final result = await mbtiService.completeTest(_testSession!.id);
      
      // 導航到結果頁面
      Navigator.pushReplacementNamed(
        context,
        '/mbti-result',
        arguments: result,
      );
      
    } catch (e) {
      _showErrorDialog('完成測試失敗，請重試');
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

    if (_questions.isEmpty) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導航和進度
            _buildHeader(),
            
            // 主要內容
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
            
            // 底部導航
            _buildBottomNavigation(),
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
              '準備 MBTI 測試',
              style: AppTextStyles.heading2,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '正在為你準備個性化測試...',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
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

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '載入失敗',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.error,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '無法載入測試問題，請檢查網絡連接',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            CustomButton(
              text: '重試',
              onPressed: () {
                setState(() => _isLoading = true);
                _initializeTest();
              },
              variant: ButtonVariant.outlined,
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
      child: Column(
        children: [
          // 導航欄
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _currentQuestionIndex > 0 
                    ? _previousQuestion 
                    : () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'MBTI 人格測試',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '${_currentQuestionIndex + 1}/${_questions.length}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 進度條
          MBTIProgressIndicator(
            animation: _progressAnimation,
            currentQuestion: _currentQuestionIndex + 1,
            totalQuestions: _questions.length,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(MBTIQuestion question) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 問題類別標籤
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCategoryName(question.category),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 問題卡片
              Expanded(
                child: MBTIQuestionCard(
                  question: question,
                  onAnswerSelected: _answerQuestion,
                  isSubmitting: _isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
          if (_currentQuestionIndex > 0)
            Expanded(
              child: CustomButton(
                text: '上一題',
                onPressed: _previousQuestion,
                variant: ButtonVariant.outlined,
              ),
            ),
          
          if (_currentQuestionIndex > 0) const SizedBox(width: 16),
          
          Expanded(
            flex: _currentQuestionIndex == 0 ? 1 : 2,
            child: Container(
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
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '選擇最符合你直覺的答案',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'EI':
        return '外向 vs 內向';
      case 'SN':
        return '感覺 vs 直覺';
      case 'TF':
        return '思考 vs 情感';
      case 'JP':
        return '判斷 vs 感知';
      default:
        return '人格測試';
    }
  }
} 