import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// 收入分析管理器
class RevenueAnalytics {
  static final RevenueAnalytics _instance = RevenueAnalytics._internal();
  factory RevenueAnalytics() => _instance;
  RevenueAnalytics._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 記錄收入事件
  Future<void> trackRevenueEvent({
    required String eventType,
    required double amount,
    required String currency,
    required String source,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      
      await _firestore.collection('revenue_events').add({
        'userId': user?.uid,
        'eventType': eventType,
        'amount': amount,
        'currency': currency,
        'source': source,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
        'additionalData': additionalData ?? {},
      });

      debugPrint('📊 收入事件已記錄: $eventType, $amount $currency');
    } catch (e) {
      debugPrint('❌ 記錄收入事件失敗: $e');
    }
  }

  /// 記錄訂閱轉換事件
  Future<void> trackSubscriptionConversion({
    required String fromTier,
    required String toTier,
    required double amount,
    required String conversionSource,
  }) async {
    await trackRevenueEvent(
      eventType: 'subscription_conversion',
      amount: amount,
      currency: 'HKD',
      source: conversionSource,
      additionalData: {
        'fromTier': fromTier,
        'toTier': toTier,
        'conversionSource': conversionSource,
      },
    );
  }

  /// 記錄虛擬商品購買
  Future<void> trackVirtualGoodsPurchase({
    required String itemId,
    required double amount,
    required String purchaseContext,
  }) async {
    await trackRevenueEvent(
      eventType: 'virtual_goods_purchase',
      amount: amount,
      currency: 'HKD',
      source: 'in_app_purchase',
      additionalData: {
        'itemId': itemId,
        'purchaseContext': purchaseContext,
      },
    );
  }

  /// 記錄用戶行為事件
  Future<void> trackUserBehavior({
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final user = _auth.currentUser;
      
      await _firestore.collection('user_behavior').add({
        'userId': user?.uid,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
        'parameters': parameters ?? {},
      });
    } catch (e) {
      debugPrint('❌ 記錄用戶行為失敗: $e');
    }
  }

  /// 記錄付費漏斗事件
  Future<void> trackPaymentFunnel({
    required String stage,
    required String tier,
    String? dropOffReason,
  }) async {
    await trackUserBehavior(
      action: 'payment_funnel',
      parameters: {
        'stage': stage, // 'viewed', 'clicked', 'initiated', 'completed', 'failed'
        'tier': tier,
        'dropOffReason': dropOffReason,
      },
    );
  }

  /// 獲取收入統計
  Future<RevenueStats> getRevenueStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final query = _firestore
          .collection('revenue_events')
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThanOrEqualTo: end);

      final snapshot = await query.get();
      
      double totalRevenue = 0;
      int subscriptionCount = 0;
      int virtualGoodsCount = 0;
      Map<String, double> revenueBySource = {};
      Map<String, int> transactionsByTier = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final eventType = data['eventType'] as String? ?? '';
        final source = data['source'] as String? ?? '';
        
        totalRevenue += amount;
        
        revenueBySource[source] = (revenueBySource[source] ?? 0) + amount;
        
        if (eventType == 'subscription_conversion') {
          subscriptionCount++;
          final toTier = data['additionalData']?['toTier'] as String? ?? '';
          transactionsByTier[toTier] = (transactionsByTier[toTier] ?? 0) + 1;
        } else if (eventType == 'virtual_goods_purchase') {
          virtualGoodsCount++;
        }
      }

      return RevenueStats(
        totalRevenue: totalRevenue,
        subscriptionTransactions: subscriptionCount,
        virtualGoodsTransactions: virtualGoodsCount,
        revenueBySource: revenueBySource,
        transactionsByTier: transactionsByTier,
        period: DateRange(start, end),
      );
    } catch (e) {
      debugPrint('❌ 獲取收入統計失敗: $e');
      return RevenueStats.empty();
    }
  }

  /// 獲取用戶留存數據
  Future<RetentionStats> getRetentionStats() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // 獲取新用戶數據
      final newUsersQuery = _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo);

      final newUsersSnapshot = await newUsersQuery.get();
      final newUsersCount = newUsersSnapshot.docs.length;

      // 獲取活躍用戶數據
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final activeBehaviorQuery = _firestore
          .collection('user_behavior')
          .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo);

      final activeBehaviorSnapshot = await activeBehaviorQuery.get();
      final activeUserIds = activeBehaviorSnapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null)
          .toSet();

      // 計算付費用戶轉換率
      final paidUsersQuery = _firestore
          .collection('revenue_events')
          .where('eventType', whereIn: ['subscription_conversion', 'virtual_goods_purchase'])
          .where('timestamp', isGreaterThanOrEqualTo: thirtyDaysAgo);

      final paidUsersSnapshot = await paidUsersQuery.get();
      final paidUserIds = paidUsersSnapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null)
          .toSet();

      final conversionRate = newUsersCount > 0 
          ? (paidUserIds.length / newUsersCount) * 100 
          : 0.0;

      return RetentionStats(
        newUsers: newUsersCount,
        activeUsers: activeUserIds.length,
        paidUsers: paidUserIds.length,
        conversionRate: conversionRate,
        period: DateRange(thirtyDaysAgo, now),
      );
    } catch (e) {
      debugPrint('❌ 獲取留存統計失敗: $e');
      return RetentionStats.empty();
    }
  }

  /// 獲取付費漏斗數據
  Future<PaymentFunnelStats> getPaymentFunnelStats() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final query = _firestore
          .collection('user_behavior')
          .where('action', isEqualTo: 'payment_funnel')
          .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo);

      final snapshot = await query.get();
      
      Map<String, int> stageCount = {
        'viewed': 0,
        'clicked': 0,
        'initiated': 0,
        'completed': 0,
        'failed': 0,
      };

      Map<String, List<String>> dropOffReasons = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final parameters = data['parameters'] as Map<String, dynamic>? ?? {};
        final stage = parameters['stage'] as String? ?? '';
        final dropOffReason = parameters['dropOffReason'] as String?;

        if (stageCount.containsKey(stage)) {
          stageCount[stage] = stageCount[stage]! + 1;
        }

        if (dropOffReason != null && stage == 'failed') {
          dropOffReasons[dropOffReason] = 
              (dropOffReasons[dropOffReason] ?? [])..add(stage);
        }
      }

      return PaymentFunnelStats(
        stageCount: stageCount,
        dropOffReasons: dropOffReasons,
        period: DateRange(sevenDaysAgo, DateTime.now()),
      );
    } catch (e) {
      debugPrint('❌ 獲取付費漏斗統計失敗: $e');
      return PaymentFunnelStats.empty();
    }
  }

  /// 記錄應用打開事件
  Future<void> trackAppOpen() async {
    await trackUserBehavior(action: 'app_open');
  }

  /// 記錄功能使用事件
  Future<void> trackFeatureUsage(String featureName, {
    Map<String, dynamic>? context,
  }) async {
    await trackUserBehavior(
      action: 'feature_usage',
      parameters: {
        'featureName': featureName,
        'context': context ?? {},
      },
    );
  }

  /// 記錄配對事件
  Future<void> trackMatchEvent(String eventType, {
    String? matchId,
    String? outcome,
  }) async {
    await trackUserBehavior(
      action: 'match_event',
      parameters: {
        'eventType': eventType, // 'viewed', 'liked', 'passed', 'matched', 'unmatched'
        'matchId': matchId,
        'outcome': outcome,
      },
    );
  }

  /// 記錄聊天事件
  Future<void> trackChatEvent(String eventType, {
    String? chatId,
    Map<String, dynamic>? metadata,
  }) async {
    await trackUserBehavior(
      action: 'chat_event',
      parameters: {
        'eventType': eventType, // 'started', 'message_sent', 'message_received', 'ended'
        'chatId': chatId,
        'metadata': metadata ?? {},
      },
    );
  }

  /// 記錄 AI 功能使用
  Future<void> trackAIFeatureUsage(String aiFeature, {
    String? tier,
    bool? wasSuccessful,
  }) async {
    await trackUserBehavior(
      action: 'ai_feature_usage',
      parameters: {
        'aiFeature': aiFeature, // 'icebreakers', 'love_consultant', 'date_planner'
        'tier': tier,
        'wasSuccessful': wasSuccessful,
      },
    );
  }

  /// 生成商業報告
  Future<BusinessReport> generateBusinessReport() async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final revenueStats = await getRevenueStats(
        startDate: thirtyDaysAgo,
        endDate: now,
      );

      final retentionStats = await getRetentionStats();
      final funnelStats = await getPaymentFunnelStats();

      // 計算關鍵指標
      final dailyRevenue = revenueStats.totalRevenue / 30;
      final arpu = retentionStats.activeUsers > 0 
          ? revenueStats.totalRevenue / retentionStats.activeUsers 
          : 0.0;

      final conversionRate = funnelStats.stageCount['viewed']! > 0
          ? (funnelStats.stageCount['completed']! / funnelStats.stageCount['viewed']!) * 100
          : 0.0;

      return BusinessReport(
        totalRevenue: revenueStats.totalRevenue,
        dailyAverageRevenue: dailyRevenue,
        arpu: arpu,
        newUsers: retentionStats.newUsers,
        activeUsers: retentionStats.activeUsers,
        paidUsers: retentionStats.paidUsers,
        userConversionRate: retentionStats.conversionRate,
        paymentConversionRate: conversionRate,
        subscriptionTransactions: revenueStats.subscriptionTransactions,
        virtualGoodsTransactions: revenueStats.virtualGoodsTransactions,
        generatedAt: now,
        period: DateRange(thirtyDaysAgo, now),
      );
    } catch (e) {
      debugPrint('❌ 生成商業報告失敗: $e');
      return BusinessReport.empty();
    }
  }
}

/// 收入統計數據類
class RevenueStats {
  final double totalRevenue;
  final int subscriptionTransactions;
  final int virtualGoodsTransactions;
  final Map<String, double> revenueBySource;
  final Map<String, int> transactionsByTier;
  final DateRange period;

  RevenueStats({
    required this.totalRevenue,
    required this.subscriptionTransactions,
    required this.virtualGoodsTransactions,
    required this.revenueBySource,
    required this.transactionsByTier,
    required this.period,
  });

  factory RevenueStats.empty() {
    final now = DateTime.now();
    return RevenueStats(
      totalRevenue: 0,
      subscriptionTransactions: 0,
      virtualGoodsTransactions: 0,
      revenueBySource: {},
      transactionsByTier: {},
      period: DateRange(now, now),
    );
  }
}

/// 留存統計數據類
class RetentionStats {
  final int newUsers;
  final int activeUsers;
  final int paidUsers;
  final double conversionRate;
  final DateRange period;

  RetentionStats({
    required this.newUsers,
    required this.activeUsers,
    required this.paidUsers,
    required this.conversionRate,
    required this.period,
  });

  factory RetentionStats.empty() {
    final now = DateTime.now();
    return RetentionStats(
      newUsers: 0,
      activeUsers: 0,
      paidUsers: 0,
      conversionRate: 0,
      period: DateRange(now, now),
    );
  }
}

/// 付費漏斗統計數據類
class PaymentFunnelStats {
  final Map<String, int> stageCount;
  final Map<String, List<String>> dropOffReasons;
  final DateRange period;

  PaymentFunnelStats({
    required this.stageCount,
    required this.dropOffReasons,
    required this.period,
  });

  factory PaymentFunnelStats.empty() {
    final now = DateTime.now();
    return PaymentFunnelStats(
      stageCount: {},
      dropOffReasons: {},
      period: DateRange(now, now),
    );
  }
}

/// 商業報告類
class BusinessReport {
  final double totalRevenue;
  final double dailyAverageRevenue;
  final double arpu; // Average Revenue Per User
  final int newUsers;
  final int activeUsers;
  final int paidUsers;
  final double userConversionRate;
  final double paymentConversionRate;
  final int subscriptionTransactions;
  final int virtualGoodsTransactions;
  final DateTime generatedAt;
  final DateRange period;

  BusinessReport({
    required this.totalRevenue,
    required this.dailyAverageRevenue,
    required this.arpu,
    required this.newUsers,
    required this.activeUsers,
    required this.paidUsers,
    required this.userConversionRate,
    required this.paymentConversionRate,
    required this.subscriptionTransactions,
    required this.virtualGoodsTransactions,
    required this.generatedAt,
    required this.period,
  });

  factory BusinessReport.empty() {
    final now = DateTime.now();
    return BusinessReport(
      totalRevenue: 0,
      dailyAverageRevenue: 0,
      arpu: 0,
      newUsers: 0,
      activeUsers: 0,
      paidUsers: 0,
      userConversionRate: 0,
      paymentConversionRate: 0,
      subscriptionTransactions: 0,
      virtualGoodsTransactions: 0,
      generatedAt: now,
      period: DateRange(now, now),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'dailyAverageRevenue': dailyAverageRevenue,
      'arpu': arpu,
      'newUsers': newUsers,
      'activeUsers': activeUsers,
      'paidUsers': paidUsers,
      'userConversionRate': userConversionRate,
      'paymentConversionRate': paymentConversionRate,
      'subscriptionTransactions': subscriptionTransactions,
      'virtualGoodsTransactions': virtualGoodsTransactions,
      'generatedAt': generatedAt.toIso8601String(),
      'period': {
        'start': period.start.toIso8601String(),
        'end': period.end.toIso8601String(),
      },
    };
  }
}

/// 日期範圍類
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  int get daysDifference => end.difference(start).inDays;
}

/// 實時監控管理器
class RealtimeMonitor {
  static final RealtimeMonitor _instance = RealtimeMonitor._internal();
  factory RealtimeMonitor() => _instance;
  RealtimeMonitor._internal();

  Timer? _monitoringTimer;
  final StreamController<Map<String, dynamic>> _metricsController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get metricsStream => _metricsController.stream;

  /// 開始實時監控
  void startMonitoring() {
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _collectRealTimeMetrics(),
    );
    debugPrint('📊 實時監控已啟動');
  }

  /// 收集實時指標
  Future<void> _collectRealTimeMetrics() async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));

      // 收集過去一小時的關鍵指標
      final metrics = <String, dynamic>{
        'timestamp': now.toIso8601String(),
        'activeUsers': await _getActiveUsersCount(oneHourAgo),
        'newRegistrations': await _getNewRegistrationsCount(oneHourAgo),
        'revenueLastHour': await _getRevenueLastHour(oneHourAgo),
        'paymentFailures': await _getPaymentFailuresCount(oneHourAgo),
        'appCrashes': await _getAppCrashesCount(oneHourAgo),
      };

      _metricsController.add(metrics);
    } catch (e) {
      debugPrint('❌ 收集實時指標失敗: $e');
    }
  }

  Future<int> _getActiveUsersCount(DateTime since) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_behavior')
          .where('timestamp', isGreaterThanOrEqualTo: since)
          .get();

      final uniqueUsers = snapshot.docs
          .map((doc) => doc.data()['userId'] as String?)
          .where((id) => id != null)
          .toSet();

      return uniqueUsers.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getNewRegistrationsCount(DateTime since) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: since)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _getRevenueLastHour(DateTime since) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('revenue_events')
          .where('timestamp', isGreaterThanOrEqualTo: since)
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0;
        total += amount;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getPaymentFailuresCount(DateTime since) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_behavior')
          .where('action', isEqualTo: 'payment_funnel')
          .where('timestamp', isGreaterThanOrEqualTo: since)
          .get();

      int failures = 0;
      for (final doc in snapshot.docs) {
        final parameters = doc.data()['parameters'] as Map<String, dynamic>? ?? {};
        if (parameters['stage'] == 'failed') {
          failures++;
        }
      }

      return failures;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getAppCrashesCount(DateTime since) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('app_errors')
          .where('timestamp', isGreaterThanOrEqualTo: since)
          .where('type', isEqualTo: 'crash')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// 停止監控
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    debugPrint('📊 實時監控已停止');
  }

  /// 釋放資源
  void dispose() {
    stopMonitoring();
    _metricsController.close();
  }
} 