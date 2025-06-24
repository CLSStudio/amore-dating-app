import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/admin_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  
  // 管理員快捷鍵狀態
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};
  bool _showAdminHint = false;
  late FocusNode _focusNode;
  
  // Escape 鍵序列檢測
  final List<DateTime> _escapeKeyPresses = [];
  static const int _escapeSequenceCount = 3;
  static const Duration _escapeSequenceTimeout = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    
    // 延遲請求焦點，確保 widget 已經構建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 處理鍵盤事件
  void _handleKeyEvent(KeyEvent event) {
    print('🔑 鍵盤事件: ${event.runtimeType} - ${event.logicalKey}');
    
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      print('🔑 當前按下的鍵: $_pressedKeys');
      
      // 簡化的快捷鍵檢測
      // 檢查 A 鍵 + 修飾鍵
      if (event.logicalKey == LogicalKeyboardKey.keyA) {
        final hasCtrl = _pressedKeys.contains(LogicalKeyboardKey.controlLeft) || 
                        _pressedKeys.contains(LogicalKeyboardKey.controlRight);
        final hasAlt = _pressedKeys.contains(LogicalKeyboardKey.altLeft) || 
                       _pressedKeys.contains(LogicalKeyboardKey.altRight);
        
        if (hasCtrl && hasAlt) {
          print('🔑 觸發管理員登入快捷鍵！');
          _adminQuickLogin();
          return;
        }
      }
      
      // 檢查 H 鍵 + 修飾鍵
      if (event.logicalKey == LogicalKeyboardKey.keyH) {
        final hasCtrl = _pressedKeys.contains(LogicalKeyboardKey.controlLeft) || 
                        _pressedKeys.contains(LogicalKeyboardKey.controlRight);
        final hasAlt = _pressedKeys.contains(LogicalKeyboardKey.altLeft) || 
                       _pressedKeys.contains(LogicalKeyboardKey.altRight);
        
        if (hasCtrl && hasAlt) {
          print('🔑 觸發顯示提示快捷鍵！');
          setState(() {
            _showAdminHint = !_showAdminHint;
          });
          return;
        }
      }
      
      // 備用快捷鍵：連續按三次 Escape 鍵顯示管理員登入
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        print('🔑 檢測到 Escape 鍵');
        _handleEscapeSequence();
      }
      
      // 超級簡單的測試：按 F12 鍵直接觸發管理員登入
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        print('🔑 F12 鍵觸發管理員登入！');
        _adminQuickLogin();
      }
      
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
      print('🔑 釋放鍵: ${event.logicalKey}');
    }
  }

  // 處理 Escape 鍵序列
  void _handleEscapeSequence() {
    final now = DateTime.now();
    
    // 清理過期的按鍵記錄
    _escapeKeyPresses.removeWhere((time) => 
        now.difference(time) > _escapeSequenceTimeout);
    
    // 添加當前按鍵時間
    _escapeKeyPresses.add(now);
    print('🔑 Escape 序列: ${_escapeKeyPresses.length}/$_escapeSequenceCount');
    
    // 檢查是否達到序列要求
    if (_escapeKeyPresses.length >= _escapeSequenceCount) {
      // 檢查是否在時間窗口內
      final firstPress = _escapeKeyPresses[_escapeKeyPresses.length - _escapeSequenceCount];
      if (now.difference(firstPress) <= _escapeSequenceTimeout) {
        print('🔑 Escape 序列觸發管理員登入！');
        // 觸發管理員登入
        _adminQuickLogin();
        _escapeKeyPresses.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE91E63).withOpacity(0.8),
              const Color(0xFFAD1457),
              const Color(0xFF880E4F),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo 和標題
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Amore',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '尋找真愛，從深度了解開始',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // 登入按鈕
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Google 登入按鈕
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE91E63),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 24,
                                  height: 24,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.login,
                                      color: Color(0xFFE91E63),
                                    );
                                  },
                                ),
                          label: Text(
                            _isLoading ? '登入中...' : '使用 Google 登入',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 電話號碼登入按鈕
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithPhone,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(Icons.phone),
                          label: const Text(
                            '使用電話號碼登入',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 臨時管理員登入按鈕（用於測試）
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _adminQuickLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text(
                            '🔑 管理員登入（測試）',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 條款和隱私
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    '登入即表示您同意我們的服務條款和隱私政策',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // 管理員提示（僅在顯示時出現）
                if (_showAdminHint)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🔑 管理員快捷鍵',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ctrl + Alt + A: 管理員登入\nCtrl + Alt + H: 顯示/隱藏此提示\nEsc × 3: 快速管理員登入',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // 測試按鈕
                        ElevatedButton(
                          onPressed: _adminQuickLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            '🔑 測試管理員登入',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 隱藏的管理員按鈕（用於測試）
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAdminHint = !_showAdminHint;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 50,
                    height: 20,
                    color: Colors.transparent,
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // 登入成功後會自動導航到主頁面（通過 AuthWrapper）
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登入失敗: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signInWithPhone() async {
    // 暫時顯示提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('電話號碼登入功能即將推出'),
        backgroundColor: Color(0xFFE91E63),
      ),
    );
  }

  // 管理員快速登入
  Future<void> _adminQuickLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AdminService.adminQuickLogin();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔑 管理員登入成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // 登入成功後會自動導航到主頁面（通過 AuthWrapper）
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ 管理員登入失敗'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 登入錯誤: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 