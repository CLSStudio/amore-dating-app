import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  gradient,
  icon,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final Color? iconColor;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconColor,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
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

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = !widget.isDisabled && !widget.isLoading && widget.onPressed != null;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: isEnabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: widget.height ?? _getButtonHeight(),
              padding: widget.padding ?? _getButtonPadding(),
              decoration: BoxDecoration(
                gradient: _getGradient(),
                color: _getBackgroundColor(),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(_getBorderRadius()),
                border: _getBorder(),
                boxShadow: widget.boxShadow ?? _getBoxShadow(),
              ),
              child: _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent() {
    if (widget.child != null) {
      return Center(child: widget.child!);
    }

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: widget.iconColor ?? _getTextColor(),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: _getTextStyle(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return 20;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 28;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Gradient? _getGradient() {
    if (widget.gradient != null) return widget.gradient;
    
    if (!_isEnabled()) return null;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
        return AppColors.buttonGradient;
      default:
        return null;
    }
  }

  Color? _getBackgroundColor() {
    if (widget.gradient != null || _getGradient() != null) return null;
    
    if (!_isEnabled()) {
      return AppColors.surfaceVariant;
    }
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.surfaceVariant;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return Colors.transparent;
      case ButtonVariant.icon:
        return _isPressed ? AppColors.surfaceVariant : Colors.transparent;
      case ButtonVariant.gradient:
        return null;
    }
  }

  Border? _getBorder() {
    switch (widget.variant) {
      case ButtonVariant.outlined:
        return Border.all(
          color: _isEnabled() ? AppColors.primary : AppColors.border,
          width: 1.5,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getBoxShadow() {
    if (!_isEnabled()) return null;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
        return [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      default:
        return null;
    }
  }

  Color _getTextColor() {
    if (!_isEnabled()) {
      return AppColors.textHint;
    }
    
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.gradient:
        return AppColors.textOnPrimary;
      case ButtonVariant.secondary:
        return AppColors.textPrimary;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
      case ButtonVariant.icon:
        return AppColors.primary;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.size == ButtonSize.small 
        ? AppTextStyles.buttonSmall 
        : AppTextStyles.button;
    
    return baseStyle.copyWith(color: _getTextColor());
  }

  bool _isEnabled() {
    return !widget.isDisabled && !widget.isLoading && widget.onPressed != null;
  }
} 