import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ModernButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  gradient,
  icon,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}

class ModernButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ModernButtonVariant variant;
  final ModernButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final LinearGradient? customGradient;
  final Widget? child;

  const ModernButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.variant = ModernButtonVariant.primary,
    this.size = ModernButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.customGradient,
    this.child,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _onTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed != null && !widget.isLoading
                ? widget.onPressed
                : null,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              height: _getButtonHeight(),
              padding: _getButtonPadding(),
              decoration: _getButtonDecoration(),
              child: _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 40;
      case ModernButtonSize.medium:
        return 48;
      case ModernButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16);
      case ModernButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20);
      case ModernButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  BoxDecoration _getButtonDecoration() {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    switch (widget.variant) {
      case ModernButtonVariant.primary:
        return BoxDecoration(
          color: widget.customColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: (widget.customColor ?? AppColors.primary).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      
      case ModernButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      
      case ModernButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: widget.customColor ?? AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      
      case ModernButtonVariant.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      
      case ModernButtonVariant.gradient:
        return BoxDecoration(
          gradient: widget.customGradient ?? AppColors.modernPinkGradient,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      
      case ModernButtonVariant.icon:
        return BoxDecoration(
          color: widget.customColor ?? AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 20;
      case ModernButtonSize.medium:
        return 24;
      case ModernButtonSize.large:
        return 28;
    }
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getContentColor(),
            ),
          ),
        ),
      );
    }

    if (widget.child != null) {
      return Center(child: widget.child!);
    }

    final hasIcon = widget.icon != null;
    final hasText = widget.text != null && widget.text!.isNotEmpty;

    if (widget.variant == ModernButtonVariant.icon && hasIcon) {
      return Center(
        child: Icon(
          widget.icon,
          color: _getContentColor(),
          size: _getIconSize(),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon) ...[
            Icon(
              widget.icon,
              color: _getContentColor(),
              size: _getIconSize(),
            ),
            if (hasText) const SizedBox(width: 8),
          ],
          if (hasText)
            Text(
              widget.text!,
              style: _getTextStyle(),
            ),
        ],
      ),
    );
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 20;
      case ModernButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 20;
      case ModernButtonSize.large:
        return 24;
    }
  }

  Color _getContentColor() {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    if (!isEnabled) {
      return AppColors.textDisabled;
    }

    switch (widget.variant) {
      case ModernButtonVariant.primary:
      case ModernButtonVariant.secondary:
      case ModernButtonVariant.gradient:
        return Colors.white;
      
      case ModernButtonVariant.outlined:
      case ModernButtonVariant.text:
        return widget.customColor ?? AppColors.primary;
      
      case ModernButtonVariant.icon:
        return widget.customColor ?? AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.size == ModernButtonSize.small
        ? AppTextStyles.button.copyWith(fontSize: 14)
        : AppTextStyles.button;
    
    return baseStyle.copyWith(
      color: _getContentColor(),
      fontWeight: FontWeight.w600,
    );
  }
} 