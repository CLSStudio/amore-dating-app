import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../payments/subscription_manager.dart';
import '../analytics/revenue_analytics.dart';
import '../compliance/user_verification.dart';

/// 市場就緒功能管理器
class MarketReadyFeaturesManager {
  static final MarketReadyFeaturesManager _instance = 
      MarketReadyFeaturesManager._internal();
  factory MarketReadyFeaturesManager() => _instance;
  MarketReadyFeaturesManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  final RevenueAnalytics _analytics = RevenueAnalytics();
  final UserVerificationManager _verificationManager = UserVerificationManager();

  /// 初始化市場就緒功能
  Future<void> initialize() async {
    try {
      await _subscriptionManager.initialize();
      debugPrint('✅ 市場就緒功能初始化完成');
    } catch (e) {
      debugPrint('❌ 市場就緒功能初始化失敗: $e');
    }
  }

  /// 檢查功能可用性
  Future<FeatureAvailability> checkFeatureAvailability(String featureName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return FeatureAvailability(
          isAvailable: false,
          reason: '用戶未登入',
          upgradeRequired: false,
        );
      }

      // 檢查訂閱狀態
      final subscription = _subscriptionManager.currentSubscription;
      final limits = _subscriptionManager.currentLimits;

      // 檢查合規狀態
      final complianceManager = ComplianceManager();
      final complianceResult = await complianceManager.checkUserCompliance(user.uid);

      if (!complianceResult.isCompliant) {
        return FeatureAvailability(
          isAvailable: false,
          reason: '需要完成身份驗證',
          upgradeRequired: false,
          requiredActions: complianceResult.requiredActions,
        );
      }

      // 檢查功能權限
      switch (featureName) {
        case 'unlimited_matches':
          return FeatureAvailability(
            isAvailable: limits.dailyMatches == -1,
            reason: limits.dailyMatches == -1 ? '' : '需要 Premium 訂閱',
            upgradeRequired: limits.dailyMatches != -1,
            requiredTier: SubscriptionTier.premium,
          );

        case 'ai_icebreakers':
          return FeatureAvailability(
            isAvailable: limits.hasAIIcebreakers,
            reason: limits.hasAIIcebreakers ? '' : '需要 Premium 訂閱',
            upgradeRequired: !limits.hasAIIcebreakers,
            requiredTier: SubscriptionTier.premium,
          );

        case 'ai_love_consultant':
          return FeatureAvailability(
            isAvailable: limits.hasAILoveConsultant,
            reason: limits.hasAILoveConsultant ? '' : '需要 VIP 訂閱',
            upgradeRequired: !limits.hasAILoveConsultant,
            requiredTier: SubscriptionTier.vip,
          );

        case 'date_planner':
          return FeatureAvailability(
            isAvailable: limits.hasDatePlanner,
            reason: limits.hasDatePlanner ? '' : '需要 VIP 訂閱',
            upgradeRequired: !limits.hasDatePlanner,
            requiredTier: SubscriptionTier.vip,
          );

        case 'ad_free_experience':
          return FeatureAvailability(
            isAvailable: limits.isAdFree,
            reason: limits.isAdFree ? '' : '需要 Premium 訂閱',
            upgradeRequired: !limits.isAdFree,
            requiredTier: SubscriptionTier.premium,
          );

        default:
          return FeatureAvailability(
            isAvailable: true,
            reason: '',
            upgradeRequired: false,
          );
      }
    } catch (e) {
      debugPrint('❌ 檢查功能可用性失敗: $e');
      return FeatureAvailability(
        isAvailable: false,
        reason: '檢查失敗',
        upgradeRequired: false,
      );
    }
  }

  /// 使用限制管理器
  Future<UsageResult> checkAndConsumeUsage(String feature) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return UsageResult(
          canUse: false,
          reason: '用戶未登入',
          remainingUsage: 0,
        );
      }

      final limits = _subscriptionManager.currentLimits;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 獲取今日使用記錄
      final usageDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_usage')
          .doc(today.toIso8601String().split('T')[0])
          .get();

      final currentUsage = usageDoc.exists 
          ? (usageDoc.data()?[feature] as int? ?? 0)
          : 0;

      int dailyLimit;
      switch (feature) {
        case 'matches':
          dailyLimit = limits.dailyMatches;
          break;
        case 'super_likes':
          dailyLimit = limits.superLikesPerMonth; // 按日計算
          break;
        default:
          dailyLimit = -1; // 無限制
      }

      if (dailyLimit != -1 && currentUsage >= dailyLimit) {
        return UsageResult(
          canUse: false,
          reason: '今日使用次數已達上限',
          remainingUsage: 0,
        );
      }

      // 消費使用次數
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_usage')
          .doc(today.toIso8601String().split('T')[0])
          .set({
        feature: currentUsage + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 記錄使用事件
      await _analytics.trackFeatureUsage(feature);

      final remaining = dailyLimit == -1 ? -1 : dailyLimit - currentUsage - 1;

      return UsageResult(
        canUse: true,
        reason: '',
        remainingUsage: remaining,
      );
    } catch (e) {
      debugPrint('❌ 檢查使用限制失敗: $e');
      return UsageResult(
        canUse: false,
        reason: '檢查失敗',
        remainingUsage: 0,
      );
    }
  }

  /// 升級提示管理器
  Widget buildUpgradePrompt({
    required BuildContext context,
    required String featureName,
    required SubscriptionTier requiredTier,
    VoidCallback? onUpgrade,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 48,
              color: requiredTier == SubscriptionTier.vip 
                  ? Colors.amber 
                  : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              '解鎖 ${_getFeatureDisplayName(featureName)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '升級到 ${requiredTier.displayName} 即可使用此功能',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onUpgrade ?? () {
                _showUpgradeDialog(context, requiredTier);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: requiredTier == SubscriptionTier.vip 
                    ? Colors.amber 
                    : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text('升級到 ${requiredTier.displayName}'),
            ),
          ],
        ),
      ),
    );
  }

  /// 顯示升級對話框
  void _showUpgradeDialog(BuildContext context, SubscriptionTier tier) {
    final pricing = _subscriptionManager.getPricingInfo();
    final tierInfo = pricing[tier]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('升級到 ${tier.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HK\$${tierInfo['price']}/月',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '功能包括：',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ...((tierInfo['features'] as List<String>).map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleUpgradePurchase(context, tier);
            },
            child: const Text('立即升級'),
          ),
        ],
      ),
    );
  }

  /// 處理升級購買
  Future<void> _handleUpgradePurchase(BuildContext context, SubscriptionTier tier) async {
    try {
      // 記錄付費漏斗事件
      await _analytics.trackPaymentFunnel(
        stage: 'initiated',
        tier: tier.displayName,
      );

      // 顯示支付方式選擇
      final paymentPlatform = await _showPaymentMethodDialog(context);
      
      if (paymentPlatform == null) {
        await _analytics.trackPaymentFunnel(
          stage: 'failed',
          tier: tier.displayName,
          dropOffReason: '用戶取消',
        );
        return;
      }

      // 顯示載入指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('處理付款中...'),
            ],
          ),
        ),
      );

      // 執行購買
      final success = await _subscriptionManager.purchaseSubscription(
        tier,
        paymentPlatform,
      );

      Navigator.of(context).pop(); // 關閉載入對話框

      if (success) {
        // 記錄成功事件
        await _analytics.trackPaymentFunnel(
          stage: 'completed',
          tier: tier.displayName,
        );

        await _analytics.trackSubscriptionConversion(
          fromTier: 'free',
          toTier: tier.displayName,
          amount: tier.priceHKD.toDouble(),
          conversionSource: 'upgrade_prompt',
        );

        // 顯示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('恭喜！您已成功升級到 ${tier.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 記錄失敗事件
        await _analytics.trackPaymentFunnel(
          stage: 'failed',
          tier: tier.displayName,
          dropOffReason: '付款失敗',
        );

        // 顯示錯誤消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('付款失敗，請稍後重試'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // 確保關閉載入對話框
      
      await _analytics.trackPaymentFunnel(
        stage: 'failed',
        tier: tier.displayName,
        dropOffReason: '系統錯誤',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('升級失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 顯示支付方式選擇對話框
  Future<PaymentPlatform?> _showPaymentMethodDialog(BuildContext context) async {
    return showDialog<PaymentPlatform>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇支付方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentMethodTile(
              context,
              PaymentPlatform.applePay,
              Icons.apple,
              'Apple Pay',
            ),
            _buildPaymentMethodTile(
              context,
              PaymentPlatform.googlePlay,
              Icons.android,
              'Google Pay',
            ),
            _buildPaymentMethodTile(
              context,
              PaymentPlatform.alipayHK,
              Icons.payment,
              '支付寶香港',
            ),
            _buildPaymentMethodTile(
              context,
              PaymentPlatform.wechatPayHK,
              Icons.chat,
              '微信支付香港',
            ),
            _buildPaymentMethodTile(
              context,
              PaymentPlatform.stripe,
              Icons.credit_card,
              '信用卡',
            ),
          ],
        ),
      ),
    );
  }

  /// 構建支付方式選項
  Widget _buildPaymentMethodTile(
    BuildContext context,
    PaymentPlatform platform,
    IconData icon,
    String title,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.of(context).pop(platform),
    );
  }

  /// 獲取功能顯示名稱
  String _getFeatureDisplayName(String featureName) {
    switch (featureName) {
      case 'unlimited_matches':
        return '無限配對';
      case 'ai_icebreakers':
        return 'AI 破冰話題';
      case 'ai_love_consultant':
        return 'AI 愛情顧問';
      case 'date_planner':
        return '約會規劃助手';
      case 'ad_free_experience':
        return '無廣告體驗';
      default:
        return '高級功能';
    }
  }

  /// 廣告管理器
  Future<bool> shouldShowAd() async {
    final limits = _subscriptionManager.currentLimits;
    return !limits.isAdFree;
  }

  /// 記錄廣告展示
  Future<void> recordAdImpression(String adType) async {
    await _analytics.trackUserBehavior(
      action: 'ad_impression',
      parameters: {
        'adType': adType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// A/B 測試管理器
  Future<String> getABTestVariant(String testName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'control';

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return 'control';

      final userData = userDoc.data()!;
      final abTests = userData['abTests'] as Map<String, dynamic>? ?? {};

      if (abTests.containsKey(testName)) {
        return abTests[testName] as String;
      }

      // 隨機分配測試組
      final variants = ['control', 'variant_a', 'variant_b'];
      final assignedVariant = variants[DateTime.now().millisecond % variants.length];

      // 保存分配結果
      await _firestore.collection('users').doc(user.uid).update({
        'abTests.$testName': assignedVariant,
      });

      return assignedVariant;
    } catch (e) {
      debugPrint('❌ A/B 測試分配失敗: $e');
      return 'control';
    }
  }

  /// 推送通知權限管理
  Future<void> requestNotificationPermission() async {
    // 在實際實現中，這裡會請求推送通知權限
    debugPrint('📱 請求推送通知權限');
  }

  /// 發送個性化推送
  Future<void> sendPersonalizedNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'data': data ?? {},
        'sent': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('📱 個性化通知已排隊發送');
    } catch (e) {
      debugPrint('❌ 發送個性化通知失敗: $e');
    }
  }
}

/// 功能可用性結果
class FeatureAvailability {
  final bool isAvailable;
  final String reason;
  final bool upgradeRequired;
  final SubscriptionTier? requiredTier;
  final List<String> requiredActions;

  FeatureAvailability({
    required this.isAvailable,
    required this.reason,
    required this.upgradeRequired,
    this.requiredTier,
    this.requiredActions = const [],
  });
}

/// 使用結果
class UsageResult {
  final bool canUse;
  final String reason;
  final int remainingUsage; // -1 表示無限制

  UsageResult({
    required this.canUse,
    required this.reason,
    required this.remainingUsage,
  });
}

/// 客服支援系統
class CustomerSupportManager {
  static final CustomerSupportManager _instance = CustomerSupportManager._internal();
  factory CustomerSupportManager() => _instance;
  CustomerSupportManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 創建支援工單
  Future<String> createSupportTicket({
    required String userId,
    required String subject,
    required String description,
    required String category,
    String priority = 'normal',
  }) async {
    try {
      final ticketRef = await _firestore.collection('support_tickets').add({
        'userId': userId,
        'subject': subject,
        'description': description,
        'category': category,
        'priority': priority,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 發送確認通知
      await _sendTicketConfirmation(userId, ticketRef.id);

      return ticketRef.id;
    } catch (e) {
      debugPrint('❌ 創建支援工單失敗: $e');
      rethrow;
    }
  }

  /// 發送工單確認
  Future<void> _sendTicketConfirmation(String userId, String ticketId) async {
    final marketReadyManager = MarketReadyFeaturesManager();
    await marketReadyManager.sendPersonalizedNotification(
      userId: userId,
      title: '支援工單已收到',
      message: '您的支援工單 #$ticketId 已收到，我們會盡快回覆',
      data: {'ticketId': ticketId},
    );
  }

  /// 獲取常見問題
  Future<List<FAQ>> getFAQs() async {
    try {
      final snapshot = await _firestore
          .collection('faqs')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => FAQ.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ 獲取常見問題失敗: $e');
      return [];
    }
  }
}

/// 常見問題類
class FAQ {
  final String question;
  final String answer;
  final String category;
  final int order;

  FAQ({
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
  });

  factory FAQ.fromMap(Map<String, dynamic> map) {
    return FAQ(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? '',
      order: map['order'] ?? 0,
    );
  }
} 