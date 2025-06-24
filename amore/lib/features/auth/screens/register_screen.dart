import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/social_login_button.dart';
import '../../mbti/romantic_mbti_test.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // 控制器
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthdateController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  
  String? _selectedGender;
  String? _selectedInterestedIn;
  DateTime? _selectedBirthdate;
  RomanticMBTIResult? _mbtiResult;

  final List<String> _genderOptions = ['男性', '女性', '其他'];
  final List<String> _interestedInOptions = ['男性', '女性', '任何人'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      if (_validateBasicInfo()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 2) {
      // MBTI測試完成後自動進入下一步
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateBasicInfo() {
    if (_selectedGender == null) {
      _showErrorSnackBar('請選擇您的性別');
      return false;
    }
    if (_selectedInterestedIn == null) {
      _showErrorSnackBar('請選擇您感興趣的對象');
      return false;
    }
    if (_selectedBirthdate == null) {
      _showErrorSnackBar('請選擇您的出生日期');
      return false;
    }
    
    // 檢查年齡
    final age = DateTime.now().difference(_selectedBirthdate!).inDays ~/ 365;
    if (age < AppConfig.minAgeLimit) {
      _showErrorSnackBar('您必須年滿 ${AppConfig.minAgeLimit} 歲才能註冊');
      return false;
    }
    
    return true;
  }

  Future<void> _register() async {
    if (!_agreeToTerms) {
      _showErrorSnackBar('請同意服務條款和隱私政策');
      return;
    }

    if (_mbtiResult == null) {
      _showErrorSnackBar('請完成戀愛性格測試');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模擬註冊延遲
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        context.go(AppConstants.homeRoute);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('註冊失敗，請稍後再試');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = 
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導航
            _buildTopNavigation(),
            
            // 進度指示器
            _buildProgressIndicator(),
            
            // 頁面內容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildAccountSetupPage(),
                  _buildBasicInfoPage(),
                  _buildMBTITestPage(),
                  _buildTermsAndFinishPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentStep > 0 ? _previousStep : () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.all(12),
            ),
          ),
          Text(
            '創建帳戶',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () => context.go(AppConstants.authRoute),
            child: const Text(
              '登錄',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: -0.3, duration: 400.ms);
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentStep 
                    ? AppTheme.primaryColor 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate()
              .scaleX(
                duration: 300.ms,
                curve: Curves.easeInOut,
              ),
          );
        }),
      ),
    );
  }

  Widget _buildAccountSetupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            
            Text(
              '建立您的帳戶',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: 8),
            
            Text(
              '請填寫基本資料來創建您的 Amore 帳戶',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),
            
            const SizedBox(height: 48),
            
            // 社交註冊按鈕
            Column(
              children: [
                GoogleLoginButton(
                  onPressed: () {
                    // 實現 Google 註冊
                  },
                  isFullWidth: true,
                ),
                const SizedBox(height: 12),
                FacebookLoginButton(
                  onPressed: () {
                    // 實現 Facebook 註冊
                  },
                  isFullWidth: true,
                ),
                const SizedBox(height: 12),
                AppleLoginButton(
                  onPressed: () {
                    // 實現 Apple 註冊
                  },
                  isFullWidth: true,
                ),
              ],
            ).animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.3, duration: 600.ms, delay: 600.ms),
            
            const SizedBox(height: 32),
            
            // 分隔線
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '或使用電子郵件',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 表單欄位
            CustomTextField(
              controller: _nameController,
              label: '姓名',
              hint: '請輸入您的全名',
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '請輸入您的姓名';
                }
                if (value!.length < 2) {
                  return '姓名至少需要 2 個字符';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideX(begin: 0.3, duration: 400.ms, delay: 800.ms),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _emailController,
              label: '電子郵件',
              hint: '請輸入您的電子郵件',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '請輸入電子郵件';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return '請輸入有效的電子郵件格式';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: 400.ms, delay: 1000.ms)
              .slideX(begin: 0.3, duration: 400.ms, delay: 1000.ms),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _passwordController,
              label: '密碼',
              hint: '至少 8 個字符',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '請輸入密碼';
                }
                if (value!.length < 8) {
                  return '密碼至少需要 8 個字符';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: 400.ms, delay: 1200.ms)
              .slideX(begin: 0.3, duration: 400.ms, delay: 1200.ms),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _confirmPasswordController,
              label: '確認密碼',
              hint: '請再次輸入密碼',
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return '請確認密碼';
                }
                if (value != _passwordController.text) {
                  return '密碼不一致';
                }
                return null;
              },
            ).animate()
              .fadeIn(duration: 400.ms, delay: 1400.ms)
              .slideX(begin: 0.3, duration: 400.ms, delay: 1400.ms),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                child: const Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: 1600.ms)
              .slideY(begin: 0.3, duration: 400.ms, delay: 1600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          Text(
            '關於您',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '讓我們更了解您，以提供更好的配對建議',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 性別選擇
          const Text(
            '性別',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            children: _genderOptions.map((gender) {
              final isSelected = _selectedGender == gender;
              return ChoiceChip(
                label: Text(gender),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedGender = selected ? gender : null;
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // 感興趣的對象
          const Text(
            '我感興趣的對象',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            children: _interestedInOptions.map((interest) {
              final isSelected = _selectedInterestedIn == interest;
              return ChoiceChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedInterestedIn = selected ? interest : null;
                  });
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // 出生日期
          GestureDetector(
            onTap: _selectBirthdate,
            child: AbsorbPointer(
              child: CustomTextField(
                controller: _birthdateController,
                label: '出生日期',
                hint: '選擇您的出生日期',
                prefixIcon: Icons.calendar_today_outlined,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: const Text(
                '下一步',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMBTITestPage() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          
          Text(
            '戀愛性格測試',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
          
          const SizedBox(height: 8),
          
          Text(
            '通過專業的戀愛性格測試，我們將為您匹配最合適的伴侶',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),
          
          const SizedBox(height: 40),
          
          // MBTI測試結果顯示
          if (_mbtiResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _mbtiResult!.themeColor,
                    _mbtiResult!.themeColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _mbtiResult!.themeColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _mbtiResult!.emoji,
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _mbtiResult!.type,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mbtiResult!.loveStyle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '測試已完成',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _mbtiResult = null;
                });
                _startMBTITest();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新測試'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
            // 測試介紹卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 60,
                    color: Colors.pink.shade400,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '專業戀愛性格分析',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 16種戀愛性格類型\n• 深度分析您的戀愛風格\n• 個性化配對建議\n• 約會技巧指導',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startMBTITest,
                icon: const Icon(Icons.favorite),
                label: const Text(
                  '開始測試',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          
          const Spacer(),
          
          // 下一步按鈕
          if (_mbtiResult != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                child: const Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _startMBTITest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RomanticMBTITestPage(
          isRegistration: true,
          onComplete: () {
            Navigator.pop(context);
            // 獲取測試結果
            final result = ref.read(romanticMBTIResultProvider);
            if (result != null) {
              setState(() {
                _mbtiResult = result;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTermsAndFinishPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          Text(
            '最後一步',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '請閱讀並同意我們的服務條款',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 條款同意
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '我已閱讀並同意 ',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: '服務條款',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' 和 '),
                        TextSpan(
                          text: '隱私政策',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '創建帳戶',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 