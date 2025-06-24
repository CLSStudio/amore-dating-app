import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../complete_profile_setup.dart';

class ProfileSetupPage extends ConsumerWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 直接使用完整的個人檔案設置頁面
    return const CompleteProfileSetupPage();
  }
} 