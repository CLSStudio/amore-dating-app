import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/widgets/modern_bottom_navigation.dart';

class UIShowcasePage extends StatefulWidget {
  const UIShowcasePage({super.key});

  @override
  State<UIShowcasePage> createState() => _UIShowcasePageState();
}

class _UIShowcasePageState extends State<UIShowcasePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  int _currentNavIndex = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'UI 組件展示',
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.modernPinkGradient,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 色彩展示
            _buildSection(
              title: '🎨 現代化色彩系統',
              child: _buildColorPalette(),
            ),
            
            const SizedBox(height: 32),
            
            // 按鈕展示
            _buildSection(
              title: '🎮 現代化按鈕',
              child: _buildButtonShowcase(),
            ),
            
            const SizedBox(height: 32),
            
            // 輸入框展示
            _buildSection(
              title: '📝 智能輸入框',
              child: _buildTextFieldShowcase(),
            ),
            
            const SizedBox(height: 32),
            
            // 漸變效果展示
            _buildSection(
              title: '🌈 漸變效果',
              child: _buildGradientShowcase(),
            ),
            
            const SizedBox(height: 100), // 為底部導航留空間
          ],
        ),
      ),
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          ModernBottomNavigationItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: '探索',
          ),
          ModernBottomNavigationItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            label: '喜歡',
          ),
          ModernBottomNavigationItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: '聊天',
          ),
          ModernBottomNavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: '個人',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headline5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildColorPalette() {
    return Column(
      children: [
        // 主要色彩
        Row(
          children: [
            _buildColorCard('主色調', AppColors.primary),
            const SizedBox(width: 12),
            _buildColorCard('霓虹粉', AppColors.neonPink),
            const SizedBox(width: 12),
            _buildColorCard('活力紅', AppColors.vibrantRed),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildColorCard('柔和桃', AppColors.softPeach),
            const SizedBox(width: 12),
            _buildColorCard('電光藍', AppColors.electricBlue),
            const SizedBox(width: 12),
            _buildColorCard('薄荷綠', AppColors.mintGreen),
          ],
        ),
      ],
    );
  }

  Widget _buildColorCard(String name, Color color) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonShowcase() {
    return Column(
      children: [
        // 第一行按鈕
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: '主要按鈕',
                variant: ModernButtonVariant.primary,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: '次要按鈕',
                variant: ModernButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 第二行按鈕
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: '邊框按鈕',
                variant: ModernButtonVariant.outlined,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: '漸變按鈕',
                variant: ModernButtonVariant.gradient,
                customGradient: AppColors.sunsetGradient,
                onPressed: () {},
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 第三行按鈕
        Row(
          children: [
            ModernButton(
              icon: Icons.favorite,
              variant: ModernButtonVariant.icon,
              customColor: AppColors.like,
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            ModernButton(
              text: '載入中',
              variant: ModernButtonVariant.primary,
              isLoading: _isLoading,
              onPressed: () {
                setState(() {
                  _isLoading = !_isLoading;
                });
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: '全寬按鈕',
                icon: Icons.arrow_forward,
                variant: ModernButtonVariant.gradient,
                size: ModernButtonSize.large,
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldShowcase() {
    return Column(
      children: [
        ModernTextField(
          label: '電子郵件',
          hint: '請輸入您的電子郵件',
          controller: _emailController,
          type: ModernTextFieldType.email,
          prefixIcon: Icons.email,
          isRequired: true,
        ),
        
        const SizedBox(height: 16),
        
        ModernTextField(
          label: '密碼',
          hint: '請輸入密碼',
          controller: _passwordController,
          type: ModernTextFieldType.password,
          prefixIcon: Icons.lock,
          isRequired: true,
          helperText: '密碼至少需要 8 個字符',
        ),
        
        const SizedBox(height: 16),
        
        ModernTextField(
          label: '個人簡介',
          hint: '告訴大家關於你的故事...',
          controller: _bioController,
          type: ModernTextFieldType.multiline,
          prefixIcon: Icons.person,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _buildGradientShowcase() {
    return Column(
      children: [
        Row(
          children: [
            _buildGradientCard('現代粉紅', AppColors.modernPinkGradient),
            const SizedBox(width: 12),
            _buildGradientCard('日落漸變', AppColors.sunsetGradient),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildGradientCard('海洋漸變', AppColors.oceanGradient),
            const SizedBox(width: 12),
            _buildGradientCard('桃子漸變', AppColors.peachGradient),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientCard(String name, LinearGradient gradient) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
} 