import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionSettingsPage extends ConsumerWidget {
  const SubscriptionSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '訂閱管理',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions,
              size: 64,
              color: Color(0xFFD69E2E),
            ),
            SizedBox(height: 16),
            Text(
              '訂閱管理',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '功能開發中...',
              style: TextStyle(
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 