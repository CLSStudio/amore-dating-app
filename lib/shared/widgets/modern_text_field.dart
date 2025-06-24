import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ModernTextFieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
}

class ModernTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextEditingController? controller;
  final ModernTextFieldType type;
  final bool isRequired;
  final bool isEnabled;
  final int? maxLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final FocusNode? focusNode;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.type = ModernTextFieldType.text,
    this.isRequired = false,
    this.isEnabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;
  late FocusNode _focusNode;
  
  bool _isFocused = false;
  bool _hasText = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _borderColorAnimation = ColorTween(
      begin: AppColors.border,
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(_onFocusChange);
    
    if (widget.controller != null) {
      widget.controller!.addListener(_onTextChange);
      _hasText = widget.controller!.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused || _hasText) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (_hasText || _isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isFocused ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Stack(
                children: [
                  // 主要輸入框
                  TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.isEnabled,
                    obscureText: widget.type == ModernTextFieldType.password && !_isPasswordVisible,
                    keyboardType: _getKeyboardType(),
                    textInputAction: _getTextInputAction(),
                    maxLines: widget.type == ModernTextFieldType.multiline ? null : widget.maxLines,
                    maxLength: widget.maxLength,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    onTap: widget.onTap,
                    style: AppTextStyles.body1.copyWith(
                      color: widget.isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                    decoration: InputDecoration(
                      hintText: _shouldShowHint() ? widget.hint : null,
                      hintStyle: AppTextStyles.body1.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: widget.prefixIcon != null
                          ? Icon(
                              widget.prefixIcon,
                              color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                            )
                          : null,
                      suffixIcon: _buildSuffixIcon(),
                      filled: true,
                      fillColor: widget.isEnabled 
                          ? AppColors.inputBackground 
                          : AppColors.inputBackground.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.errorText != null 
                              ? AppColors.error 
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.errorText != null 
                              ? AppColors.error 
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.errorText != null 
                              ? AppColors.error 
                              : _borderColorAnimation.value ?? AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: widget.type == ModernTextFieldType.multiline ? 16 : 14,
                      ),
                      counterText: '',
                    ),
                  ),
                  
                  // 浮動標籤
                  if (widget.label != null)
                    Positioned(
                      left: widget.prefixIcon != null ? 48 : 16,
                      top: _getLabelTop(),
                      child: AnimatedBuilder(
                        animation: _labelAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 - (_labelAnimation.value * 0.2),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.label! + (widget.isRequired ? ' *' : ''),
                              style: AppTextStyles.body2.copyWith(
                                color: widget.errorText != null
                                    ? AppColors.error
                                    : _isFocused
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                fontSize: 14 - (_labelAnimation.value * 2),
                                fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        
        // 幫助文字或錯誤文字
        if (widget.helperText != null || widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: AppTextStyles.caption.copyWith(
                color: widget.errorText != null 
                    ? AppColors.error 
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  double _getLabelTop() {
    if (_isFocused || _hasText) {
      return -8;
    }
    return widget.type == ModernTextFieldType.multiline ? 16 : 14;
  }

  bool _shouldShowHint() {
    return !_isFocused && !_hasText && widget.label == null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == ModernTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: _isFocused ? AppColors.primary : AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _isFocused ? AppColors.primary : AppColors.textSecondary,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }
    
    return null;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case ModernTextFieldType.email:
        return TextInputType.emailAddress;
      case ModernTextFieldType.number:
        return TextInputType.number;
      case ModernTextFieldType.phone:
        return TextInputType.phone;
      case ModernTextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case ModernTextFieldType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }
} 