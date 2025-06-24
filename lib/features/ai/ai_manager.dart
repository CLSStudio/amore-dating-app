import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/google_ai_service.dart';
import 'services/ai_test_service.dart';
import 'config/ai_config.dart';

class AIManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 初始化 AI 服務
  static Future<void> initialize() async {
    try {
      if (AIConfig.enableLogging) {
        print('🤖 正在初始化 AI 服務...');
        print('📊 環境信息: ${AIConfig.getEnvironmentInfo()}');
      }

      // 檢查配置
      if (!AIConfig.isConfigured) {
        print('⚠️ AI API 密鑰未配置，將使用備用功能');
      } else {
        print('✅ AI 服務初始化完成');
      }

      // 初始化使用統計
      await _initializeUsageTracking();
      
      // 測試 API 連接
      if (AIConfig.isConfigured) {
        print('🧪 測試 AI API 連接...');
        final testResults = await AITestService.testAllConnections();
        if (testResults['overall']['success']) {
          print('🎉 AI API 連接測試成功！');
        } else {
          print('⚠️ AI API 連接測試失敗，但將繼續使用備用功能');
        }
      }
    } catch (e) {
      print('❌ AI 服務初始化失敗: $e');
    }
  }

  // 生成愛情建議
  static Future<String> generateLoveAdvice({
    required String situation,
    required String userMBTI,
    required String partnerMBTI,
    required String category,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // 檢查使用限制
      final canUse = await _checkUsageLimit('advice');
      if (!canUse) {
        return '今日愛情建議使用次數已達上限，請明天再試。';
      }

      // 調用 Google AI 服務
      final advice = await GoogleAIService.generateLoveAdviceWithGemini(
        situation: situation,
        userMBTI: userMBTI,
        partnerMBTI: partnerMBTI,
        category: category,
      );

      // 記錄使用統計
      await _recordUsage('advice', startTime);

      return advice;
    } catch (e) {
      print('生成愛情建議失敗: $e');
      return '抱歉，目前無法生成建議，請稍後再試。';
    }
  }

  // 生成破冰話題
  static Future<List<String>> generateIcebreakers({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    int count = 5,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // 檢查使用限制
      final canUse = await _checkUsageLimit('icebreakers');
      if (!canUse) {
        return ['今日破冰話題使用次數已達上限，請明天再試。'];
      }

      // 調用 Google AI 服務
      final topics = await GoogleAIService.generateIcebreakersWithGemini(
        userMBTI: userMBTI,
        partnerMBTI: partnerMBTI,
        commonInterests: commonInterests,
        count: count,
      );

      // 記錄使用統計
      await _recordUsage('icebreakers', startTime);

      return topics;
    } catch (e) {
      print('生成破冰話題失敗: $e');
      return ['你好！很高興認識你 😊'];
    }
  }

  // 生成約會建議
  static Future<Map<String, dynamic>> generateDateIdea({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required int budget,
    required String location,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // 檢查使用限制
      final canUse = await _checkUsageLimit('dateIdeas');
      if (!canUse) {
        return {
          'title': '使用限制',
          'description': '今日約會建議使用次數已達上限，請明天再試。',
          'location': location,
          'estimatedCost': 0,
          'duration': '0分鐘',
        };
      }

      // 調用 Google AI 服務
      final dateIdea = await GoogleAIService.generateDateIdeaWithGemini(
        userMBTI: userMBTI,
        partnerMBTI: partnerMBTI,
        commonInterests: commonInterests,
        budget: budget,
        location: location,
      );

      // 記錄使用統計
      await _recordUsage('dateIdeas', startTime);

      return dateIdea;
    } catch (e) {
      print('生成約會建議失敗: $e');
      return {
        'title': '錯誤',
        'description': '抱歉，目前無法生成約會建議，請稍後再試。',
        'location': location,
        'estimatedCost': 0,
        'duration': '0分鐘',
      };
    }
  }

  // 分析照片
  static Future<Map<String, dynamic>> analyzePhoto(String imageBase64) async {
    final startTime = DateTime.now();
    
    try {
      // 檢查使用限制
      final canUse = await _checkUsageLimit('photoAnalysis');
      if (!canUse) {
        return {
          'confidence': 0.0,
          'hasFace': false,
          'error': '今日照片分析使用次數已達上限，請明天再試。',
        };
      }

      // 調用 Google AI 服務
      final analysis = await GoogleAIService.analyzePhotoWithVision(imageBase64);

      // 記錄使用統計
      await _recordUsage('photoAnalysis', startTime);

      return analysis;
    } catch (e) {
      print('照片分析失敗: $e');
      return {
        'confidence': 0.0,
        'hasFace': false,
        'error': '照片分析失敗，請稍後再試。',
      };
    }
  }

  // 獲取 AI 使用統計
  static Future<Map<String, dynamic>> getUsageStats() async {
    try {
      return await GoogleAIService.getAIUsageStats();
    } catch (e) {
      print('獲取使用統計失敗: $e');
      return {};
    }
  }

  // 獲取愛情建議歷史
  static Future<List<Map<String, dynamic>>> getLoveAdviceHistory() async {
    try {
      return await GoogleAIService.getLoveAdviceHistory();
    } catch (e) {
      print('獲取愛情建議歷史失敗: $e');
      return [];
    }
  }

  // 獲取約會建議歷史
  static Future<List<Map<String, dynamic>>> getDateIdeasHistory() async {
    try {
      return await GoogleAIService.getDateIdeasHistory();
    } catch (e) {
      print('獲取約會建議歷史失敗: $e');
      return [];
    }
  }

  // 檢查使用限制
  static Future<bool> _checkUsageLimit(String type) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // 獲取今日使用次數
      final collection = _getCollectionForType(type);
      final querySnapshot = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: startOfDay)
          .get();

      final todayUsage = querySnapshot.docs.length;
      final limit = _getLimitForType(type);

      if (AIConfig.enableLogging) {
        print('📊 $type 今日使用: $todayUsage/$limit');
      }

      return todayUsage < limit;
    } catch (e) {
      print('檢查使用限制失敗: $e');
      return true; // 出錯時允許使用
    }
  }

  // 記錄使用統計
  static Future<void> _recordUsage(String type, DateTime startTime) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      await _firestore.collection('ai_usage_stats').add({
        'userId': userId,
        'type': type,
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration.inMilliseconds,
        'success': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 性能監控
      if (duration > AIConfig.performanceThreshold) {
        print('⚠️ AI 操作耗時過長: $type - ${duration.inSeconds}秒');
      }
    } catch (e) {
      print('記錄使用統計失敗: $e');
    }
  }

  // 初始化使用追蹤
  static Future<void> _initializeUsageTracking() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // 檢查今日是否已初始化
      final doc = await _firestore
          .collection('ai_daily_usage')
          .doc('${userId}_$todayStr')
          .get();

      if (!doc.exists) {
        // 初始化今日使用記錄
        await _firestore
            .collection('ai_daily_usage')
            .doc('${userId}_$todayStr')
            .set({
          'userId': userId,
          'date': todayStr,
          'advice': 0,
          'icebreakers': 0,
          'dateIdeas': 0,
          'photoAnalysis': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('初始化使用追蹤失敗: $e');
    }
  }

  // 獲取類型對應的集合名稱
  static String _getCollectionForType(String type) {
    switch (type) {
      case 'advice':
        return 'ai_love_advice';
      case 'icebreakers':
        return 'ai_icebreakers';
      case 'dateIdeas':
        return 'ai_date_ideas';
      case 'photoAnalysis':
        return 'ai_photo_analysis';
      default:
        return 'ai_usage_stats';
    }
  }

  // 獲取類型對應的限制
  static int _getLimitForType(String type) {
    switch (type) {
      case 'advice':
        return AIConfig.usageLimits['dailyAdviceLimit'] ?? 10;
      case 'icebreakers':
        return AIConfig.usageLimits['dailyIcebreakersLimit'] ?? 20;
      case 'dateIdeas':
        return AIConfig.usageLimits['dailyDateIdeasLimit'] ?? 5;
      case 'photoAnalysis':
        return AIConfig.usageLimits['dailyPhotoAnalysisLimit'] ?? 50;
      default:
        return 100;
    }
  }

  // 獲取 AI 服務狀態
  static Map<String, dynamic> getServiceStatus() {
    return {
      'configured': AIConfig.isConfigured,
      'configurationStatus': AIConfig.configurationStatus,
      'environment': AIConfig.getEnvironmentInfo(),
      'usageLimits': AIConfig.usageLimits,
      'performanceMonitoring': AIConfig.enablePerformanceMonitoring,
    };
  }

  // 清理過期數據
  static Future<void> cleanupExpiredData() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // 清理過期的使用統計
      final usageQuery = await _firestore
          .collection('ai_usage_stats')
          .where('createdAt', isLessThan: thirtyDaysAgo)
          .get();

      final batch = _firestore.batch();
      for (final doc in usageQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (AIConfig.enableLogging) {
        print('✅ 清理了 ${usageQuery.docs.length} 條過期數據');
      }
    } catch (e) {
      print('清理過期數據失敗: $e');
    }
  }

  // 導出用戶數據
  static Future<Map<String, dynamic>> exportUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final adviceHistory = await getLoveAdviceHistory();
      final dateIdeasHistory = await getDateIdeasHistory();
      final usageStats = await getUsageStats();

      return {
        'userId': userId,
        'exportedAt': DateTime.now().toIso8601String(),
        'loveAdviceHistory': adviceHistory,
        'dateIdeasHistory': dateIdeasHistory,
        'usageStats': usageStats,
        'serviceStatus': getServiceStatus(),
      };
    } catch (e) {
      print('導出用戶數據失敗: $e');
      return {};
    }
  }

  // 重置用戶數據
  static Future<void> resetUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final collections = [
        'ai_love_advice',
        'ai_icebreakers',
        'ai_date_ideas',
        'ai_photo_analysis',
        'ai_usage_stats',
        'ai_daily_usage',
      ];

      final batch = _firestore.batch();

      for (final collection in collections) {
        final query = await _firestore
            .collection(collection)
            .where('userId', isEqualTo: userId)
            .get();

        for (final doc in query.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();

      if (AIConfig.enableLogging) {
        print('✅ 用戶 AI 數據已重置');
      }
    } catch (e) {
      print('重置用戶數據失敗: $e');
    }
  }
} 