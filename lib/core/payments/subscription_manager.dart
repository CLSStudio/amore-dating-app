import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 訂閱級別枚舉
enum SubscriptionTier {
  free('free', 'Free', 0),
  premium('premium', 'Premium', 128),
  vip('vip', 'VIP', 258);

  const SubscriptionTier(this.id, this.displayName, this.priceHKD);
  
  final String id;
  final String displayName;
  final int priceHKD;
}

/// 訂閱狀態
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
  error,
}

/// 支付平台
enum PaymentPlatform {
  applePay,
  googlePlay,
  stripe,
  alipayHK,
  wechatPayHK,
}

/// 訂閱信息類
class SubscriptionInfo {
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentPlatform? paymentPlatform;
  final String? transactionId;
  final bool autoRenew;

  SubscriptionInfo({
    required this.tier,
    required this.status,
    this.startDate,
    this.endDate,
    this.paymentPlatform,
    this.transactionId,
    this.autoRenew = false,
  });

  factory SubscriptionInfo.fromMap(Map<String, dynamic> map) {
    return SubscriptionInfo(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.id == map['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => SubscriptionStatus.error,
      ),
      startDate: map['startDate']?.toDate(),
      endDate: map['endDate']?.toDate(),
      paymentPlatform: map['paymentPlatform'] != null
          ? PaymentPlatform.values.firstWhere(
              (p) => p.name == map['paymentPlatform'],
              orElse: () => PaymentPlatform.stripe,
            )
          : null,
      transactionId: map['transactionId'],
      autoRenew: map['autoRenew'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tier': tier.id,
      'status': status.name,
      'startDate': startDate,
      'endDate': endDate,
      'paymentPlatform': paymentPlatform?.name,
      'transactionId': transactionId,
      'autoRenew': autoRenew,
    };
  }

  bool get isActive => status == SubscriptionStatus.active && 
                     (endDate == null || endDate!.isAfter(DateTime.now()));

  bool get isPremiumOrHigher => tier == SubscriptionTier.premium || tier == SubscriptionTier.vip;
  bool get isVIP => tier == SubscriptionTier.vip;
}

/// 功能限制檢查器
class FeatureLimits {
  final SubscriptionTier tier;
  
  FeatureLimits(this.tier);

  // 每日配對限制
  int get dailyMatches {
    switch (tier) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.premium:
      case SubscriptionTier.vip:
        return -1; // 無限制
    }
  }

  // 超級喜歡限制
  int get superLikesPerMonth {
    switch (tier) {
      case SubscriptionTier.free:
        return 5;
      case SubscriptionTier.premium:
        return 50;
      case SubscriptionTier.vip:
        return 100;
    }
  }

  // AI 功能權限
  bool get hasAIIcebreakers => tier != SubscriptionTier.free;
  bool get hasAILoveConsultant => tier == SubscriptionTier.vip;
  bool get hasDatePlanner => tier == SubscriptionTier.vip;

  // 其他功能權限
  bool get isAdFree => tier != SubscriptionTier.free;
  bool get hasAdvancedFilters => tier != SubscriptionTier.free;
  bool get hasPrioritySupport => tier == SubscriptionTier.vip;
  bool get hasBoostFeature => tier != SubscriptionTier.free;

  // 檢查是否可以使用功能
  bool canUseFeature(String featureName) {
    switch (featureName) {
      case 'ai_icebreakers':
        return hasAIIcebreakers;
      case 'ai_love_consultant':
        return hasAILoveConsultant;
      case 'date_planner':
        return hasDatePlanner;
      case 'advanced_filters':
        return hasAdvancedFilters;
      case 'boost':
        return hasBoostFeature;
      case 'no_ads':
        return isAdFree;
      default:
        return true;
    }
  }
}

/// 訂閱管理器
class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  SubscriptionInfo? _currentSubscription;
  final StreamController<SubscriptionInfo> _subscriptionController = 
      StreamController<SubscriptionInfo>.broadcast();

  Stream<SubscriptionInfo> get subscriptionStream => _subscriptionController.stream;
  SubscriptionInfo? get currentSubscription => _currentSubscription;
  FeatureLimits get currentLimits => FeatureLimits(
    _currentSubscription?.tier ?? SubscriptionTier.free
  );

  /// 初始化訂閱管理器
  Future<void> initialize() async {
    try {
      await _loadUserSubscription();
      _startSubscriptionListener();
      debugPrint('✅ 訂閱管理器初始化完成');
    } catch (e) {
      debugPrint('❌ 訂閱管理器初始化失敗: $e');
    }
  }

  /// 載入用戶訂閱信息
  Future<void> _loadUserSubscription() async {
    final user = _auth.currentUser;
    if (user == null) {
      _currentSubscription = SubscriptionInfo(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
      );
      return;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscription')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        _currentSubscription = SubscriptionInfo.fromMap(doc.data()!);
      } else {
        _currentSubscription = SubscriptionInfo(
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
        );
      }
      
      _subscriptionController.add(_currentSubscription!);
    } catch (e) {
      debugPrint('❌ 載入訂閱信息失敗: $e');
      _currentSubscription = SubscriptionInfo(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
      );
    }
  }

  /// 開始監聽訂閱變更
  void _startSubscriptionListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('current')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _currentSubscription = SubscriptionInfo.fromMap(snapshot.data()!);
        _subscriptionController.add(_currentSubscription!);
      }
    });
  }

  /// 購買訂閱
  Future<bool> purchaseSubscription(
    SubscriptionTier tier, 
    PaymentPlatform platform,
  ) async {
    try {
      debugPrint('🛒 開始購買訂閱: ${tier.displayName}');

      // 調用相應的支付處理器
      final paymentResult = await _processPayment(tier, platform);
      
      if (paymentResult.success) {
        // 更新用戶訂閱狀態
        await _updateSubscriptionStatus(
          tier: tier,
          platform: platform,
          transactionId: paymentResult.transactionId,
        );
        
        // 記錄購買事件
        await _recordPurchaseEvent(tier, platform, paymentResult.transactionId);
        
        debugPrint('✅ 訂閱購買成功');
        return true;
      } else {
        debugPrint('❌ 訂閱購買失敗: ${paymentResult.error}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 購買訂閱異常: $e');
      return false;
    }
  }

  /// 處理支付
  Future<PaymentResult> _processPayment(
    SubscriptionTier tier,
    PaymentPlatform platform,
  ) async {
    switch (platform) {
      case PaymentPlatform.applePay:
        return await _processApplePayment(tier);
      case PaymentPlatform.googlePlay:
        return await _processGooglePlayment(tier);
      case PaymentPlatform.stripe:
        return await _processStripePayment(tier);
      case PaymentPlatform.alipayHK:
        return await _processAlipayPayment(tier);
      case PaymentPlatform.wechatPayHK:
        return await _processWechatPayment(tier);
    }
  }

  /// Apple Pay 處理
  Future<PaymentResult> _processApplePayment(SubscriptionTier tier) async {
    try {
      // 模擬 Apple In-App Purchase
      await Future.delayed(const Duration(seconds: 2));
      
      // 在實際實現中，這裡會調用 in_app_purchase 包
      final transactionId = 'apple_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        platform: PaymentPlatform.applePay,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        platform: PaymentPlatform.applePay,
      );
    }
  }

  /// Google Play 處理
  Future<PaymentResult> _processGooglePlayment(SubscriptionTier tier) async {
    try {
      // 模擬 Google Play Billing
      await Future.delayed(const Duration(seconds: 2));
      
      final transactionId = 'google_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        platform: PaymentPlatform.googlePlay,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        platform: PaymentPlatform.googlePlay,
      );
    }
  }

  /// Stripe 支付處理
  Future<PaymentResult> _processStripePayment(SubscriptionTier tier) async {
    try {
      // 模擬 Stripe 支付
      await Future.delayed(const Duration(seconds: 3));
      
      final transactionId = 'stripe_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        platform: PaymentPlatform.stripe,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        platform: PaymentPlatform.stripe,
      );
    }
  }

  /// 支付寶香港處理
  Future<PaymentResult> _processAlipayPayment(SubscriptionTier tier) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final transactionId = 'alipay_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        platform: PaymentPlatform.alipayHK,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        platform: PaymentPlatform.alipayHK,
      );
    }
  }

  /// 微信支付香港處理
  Future<PaymentResult> _processWechatPayment(SubscriptionTier tier) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final transactionId = 'wechat_${DateTime.now().millisecondsSinceEpoch}';
      
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        platform: PaymentPlatform.wechatPayHK,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: e.toString(),
        platform: PaymentPlatform.wechatPayHK,
      );
    }
  }

  /// 更新訂閱狀態
  Future<void> _updateSubscriptionStatus({
    required SubscriptionTier tier,
    required PaymentPlatform platform,
    required String transactionId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30)); // 月付訂閱

    final subscriptionInfo = SubscriptionInfo(
      tier: tier,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: endDate,
      paymentPlatform: platform,
      transactionId: transactionId,
      autoRenew: true,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('current')
        .set(subscriptionInfo.toMap());

    _currentSubscription = subscriptionInfo;
    _subscriptionController.add(subscriptionInfo);
  }

  /// 記錄購買事件
  Future<void> _recordPurchaseEvent(
    SubscriptionTier tier,
    PaymentPlatform platform,
    String transactionId,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('purchase_events').add({
        'userId': user.uid,
        'tier': tier.id,
        'platform': platform.name,
        'transactionId': transactionId,
        'amount': tier.priceHKD,
        'currency': 'HKD',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 同時記錄到用戶的購買歷史
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('purchase_history')
          .add({
        'tier': tier.id,
        'platform': platform.name,
        'transactionId': transactionId,
        'amount': tier.priceHKD,
        'currency': 'HKD',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
    } catch (e) {
      debugPrint('❌ 記錄購買事件失敗: $e');
    }
  }

  /// 取消訂閱
  Future<bool> cancelSubscription() async {
    final user = _auth.currentUser;
    if (user == null || _currentSubscription == null) return false;

    try {
      final updatedSubscription = SubscriptionInfo(
        tier: _currentSubscription!.tier,
        status: SubscriptionStatus.cancelled,
        startDate: _currentSubscription!.startDate,
        endDate: _currentSubscription!.endDate,
        paymentPlatform: _currentSubscription!.paymentPlatform,
        transactionId: _currentSubscription!.transactionId,
        autoRenew: false,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscription')
          .doc('current')
          .update(updatedSubscription.toMap());

      _currentSubscription = updatedSubscription;
      _subscriptionController.add(updatedSubscription);

      debugPrint('✅ 訂閱已取消');
      return true;
    } catch (e) {
      debugPrint('❌ 取消訂閱失敗: $e');
      return false;
    }
  }

  /// 恢復購買
  Future<bool> restorePurchases() async {
    try {
      // 在實際實現中，這裡會從各個平台恢復購買記錄
      debugPrint('🔄 恢復購買記錄...');
      
      // 模擬恢復過程
      await Future.delayed(const Duration(seconds: 2));
      
      // 重新載入訂閱信息
      await _loadUserSubscription();
      
      debugPrint('✅ 購買記錄恢復完成');
      return true;
    } catch (e) {
      debugPrint('❌ 恢復購買失敗: $e');
      return false;
    }
  }

  /// 檢查功能權限
  bool hasFeatureAccess(String featureName) {
    return currentLimits.canUseFeature(featureName);
  }

  /// 檢查使用限制
  Future<bool> checkUsageLimit(String feature, int currentUsage) async {
    switch (feature) {
      case 'daily_matches':
        final limit = currentLimits.dailyMatches;
        return limit == -1 || currentUsage < limit;
      case 'super_likes_monthly':
        final limit = currentLimits.superLikesPerMonth;
        return limit == -1 || currentUsage < limit;
      default:
        return true;
    }
  }

  /// 獲取訂閱價格信息
  Map<SubscriptionTier, Map<String, dynamic>> getPricingInfo() {
    return {
      SubscriptionTier.free: {
        'price': 0,
        'currency': 'HKD',
        'features': [
          '每日 10 次配對',
          '基礎聊天功能',
          '有廣告支援',
        ],
      },
      SubscriptionTier.premium: {
        'price': 128,
        'currency': 'HKD',
        'features': [
          '無限配對',
          'AI 破冰話題',
          '超級喜歡 (50/月)',
          '無廣告體驗',
          '進階篩選',
          'Boost 功能',
        ],
      },
      SubscriptionTier.vip: {
        'price': 258,
        'currency': 'HKD',
        'features': [
          '所有 Premium 功能',
          'AI 愛情顧問服務',
          '約會規劃助手',
          '優先客服支援',
          '專屬匹配算法',
          '特殊活動邀請',
          '超級喜歡 (100/月)',
        ],
      },
    };
  }

  /// 釋放資源
  void dispose() {
    _subscriptionController.close();
  }
}

/// 支付結果類
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? error;
  final PaymentPlatform platform;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.error,
    required this.platform,
  });
}

/// 虛擬商品管理器
class VirtualGoodsManager {
  static const Map<String, int> virtualGoodsPrices = {
    'super_likes_5': 12,  // HK$12 for 5 super likes
    'super_likes_25': 48, // HK$48 for 25 super likes
    'boost_1hr': 28,      // HK$28 for 1 hour boost
    'boost_6hr': 88,      // HK$88 for 6 hour boost
    'gift_rose': 8,       // HK$8 for virtual rose
    'gift_champagne': 28, // HK$28 for virtual champagne
    'gift_diamond': 58,   // HK$58 for virtual diamond ring
  };

  static Future<bool> purchaseVirtualGood(
    String itemId,
    PaymentPlatform platform,
  ) async {
    try {
      final price = virtualGoodsPrices[itemId];
      if (price == null) return false;

      debugPrint('🛒 購買虛擬商品: $itemId, 價格: HK\$$price');

      // 模擬支付過程
      await Future.delayed(const Duration(seconds: 2));

      // 在實際實現中，這裡會調用真實的支付 API
      final transactionId = 'vg_${DateTime.now().millisecondsSinceEpoch}';

      // 記錄購買
      await _recordVirtualGoodPurchase(itemId, price, transactionId);

      // 發放商品
      await _deliverVirtualGood(itemId);

      debugPrint('✅ 虛擬商品購買成功');
      return true;
    } catch (e) {
      debugPrint('❌ 虛擬商品購買失敗: $e');
      return false;
    }
  }

  static Future<void> _recordVirtualGoodPurchase(
    String itemId,
    int price,
    String transactionId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('virtual_goods_purchases')
        .add({
      'userId': user.uid,
      'itemId': itemId,
      'price': price,
      'currency': 'HKD',
      'transactionId': transactionId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _deliverVirtualGood(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    if (itemId.startsWith('super_likes')) {
      final count = itemId == 'super_likes_5' ? 5 : 25;
      await userRef.update({
        'superLikesBalance': FieldValue.increment(count),
      });
    } else if (itemId.startsWith('boost')) {
      final hours = itemId == 'boost_1hr' ? 1 : 6;
      await userRef.collection('boosts').add({
        'duration': hours,
        'activatedAt': null,
        'expiresAt': null,
        'status': 'available',
      });
    } else if (itemId.startsWith('gift')) {
      await userRef.collection('gifts').add({
        'type': itemId.split('_')[1],
        'available': true,
        'purchasedAt': FieldValue.serverTimestamp(),
      });
    }
  }
} 