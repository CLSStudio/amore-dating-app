import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 模擬登錄延遲
      await Future.delayed(const Duration(seconds: 2));
      
      // 這裡會實現實際的登錄邏輯
      if (mounted) {
        context.go(AppConstants.homeRoute);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('登錄失敗，請檢查您的憑證');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // 返回按鈕
              IconButton(
                onPressed: () => context.go(AppConstants.onboardingRoute),
                icon: const Icon(Icons.arrow_back_ios),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.all(12),
                ),
              ).animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.3, duration: 400.ms),
              
              const SizedBox(height: 32),
              
              // 歡迎文字
              Text(
                '歡迎回來',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms),
              
              const SizedBox(height: 8),
              
              Text(
                '登錄您的帳戶，繼續尋找您的完美配對',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms),
              
              const SizedBox(height: 48),
              
              // 標籤切換
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondaryColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(text: '電子郵件'),
                    Tab(text: '手機號碼'),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms, delay: 600.ms),
              
              const SizedBox(height: 32),
              
              // 登錄表單
              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmailLoginForm(),
                    _buildPhoneLoginForm(),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 社交登錄分隔線
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '或使用',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ).animate()
                .fadeIn(duration: 600.ms, delay: 1200.ms),
              
              const SizedBox(height: 24),
              
              // 社交登錄按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SocialLoginButton(
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    onPressed: () {
                      // 實現 Google 登錄
                    },
                  ),
                  SocialLoginButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    onPressed: () {
                      // 實現 Facebook 登錄
                    },
                  ),
                  SocialLoginButton(
                    icon: Icons.apple,
                    label: 'Apple',
                    onPressed: () {
                      // 實現 Apple 登錄
                    },
                  ),
                ],
              ).animate()
                .fadeIn(duration: 600.ms, delay: 1400.ms)
                .slideY(begin: 0.3, duration: 600.ms, delay: 1400.ms),
              
              const SizedBox(height: 32),
              
              // 註冊連結
              Center(
                child: TextButton(
                  onPressed: () => context.go('${AppConstants.authRoute}/register'),
                  child: RichText(
                    text: const TextSpan(
                      text: '還沒有帳戶？ ',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: '立即註冊',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 1600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
            .fadeIn(duration: 400.ms, delay: 800.ms)
            .slideX(begin: 0.3, duration: 400.ms, delay: 800.ms),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _passwordController,
            label: '密碼',
            hint: '請輸入您的密碼',
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
              if (value!.length < 6) {
                return '密碼至少需要 6 個字符';
              }
              return null;
            },
          ).animate()
            .fadeIn(duration: 400.ms, delay: 1000.ms)
            .slideX(begin: 0.3, duration: 400.ms, delay: 1000.ms),
          
          const SizedBox(height: 16),
          
          // 記住我和忘記密碼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const Text(
                    '記住我',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // 實現忘記密碼功能
                },
                child: const Text(
                  '忘記密碼？',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ).animate()
            .fadeIn(duration: 400.ms, delay: 1200.ms),
          
          const SizedBox(height: 32),
          
          // 登錄按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
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
                      '登錄',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 1400.ms)
            .slideY(begin: 0.3, duration: 400.ms, delay: 1400.ms),
        ],
      ),
    );
  }

  Widget _buildPhoneLoginForm() {
    return Column(
      children: [
        const CustomTextField(
          label: '手機號碼',
          hint: '+852 1234 5678',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
        ).animate()
          .fadeIn(duration: 400.ms, delay: 800.ms)
          .slideX(begin: 0.3, duration: 400.ms, delay: 800.ms),
        
        const SizedBox(height: 32),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // 實現手機驗證碼登錄
            },
            child: const Text(
              '發送驗證碼',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: 400.ms, delay: 1000.ms)
          .slideY(begin: 0.3, duration: 400.ms, delay: 1000.ms),
      ],
    );
  }
} 