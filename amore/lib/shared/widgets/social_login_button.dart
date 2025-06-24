import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 100,
      height: height ?? 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? AppTheme.textPrimaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? AppTheme.textPrimaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 預定義的社交登錄按鈕

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFullWidth;

  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            Icons.g_mobiledata,
            color: Colors.red.shade600,
            size: 24,
          ),
          label: const Text(
            '使用 Google 繼續',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SocialLoginButton(
      icon: Icons.g_mobiledata,
      label: 'Google',
      onPressed: onPressed,
      iconColor: Colors.red.shade600,
    );
  }
}

class FacebookLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFullWidth;

  const FacebookLoginButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.facebook,
            size: 24,
          ),
          label: const Text(
            '使用 Facebook 繼續',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SocialLoginButton(
      icon: Icons.facebook,
      label: 'Facebook',
      onPressed: onPressed,
      backgroundColor: const Color(0xFF1877F2),
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }
}

class AppleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFullWidth;

  const AppleLoginButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.apple,
            size: 24,
          ),
          label: const Text(
            '使用 Apple 繼續',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SocialLoginButton(
      icon: Icons.apple,
      label: 'Apple',
      onPressed: onPressed,
      backgroundColor: Colors.black,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }
}

// 其他社交平台按鈕

class LineLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFullWidth;

  const LineLoginButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    const lineGreen = Color(0xFF00C300);
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: lineGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.message,
            size: 24,
          ),
          label: const Text(
            '使用 LINE 繼續',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SocialLoginButton(
      icon: Icons.message,
      label: 'LINE',
      onPressed: onPressed,
      backgroundColor: lineGreen,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }
}

class WeChatLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFullWidth;

  const WeChatLoginButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    const wechatGreen = Color(0xFF09BB07);
    
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: wechatGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.wechat,
            size: 24,
          ),
          label: const Text(
            '使用微信繼續',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return SocialLoginButton(
      icon: Icons.wechat,
      label: '微信',
      onPressed: onPressed,
      backgroundColor: wechatGreen,
      iconColor: Colors.white,
      textColor: Colors.white,
    );
  }
} 