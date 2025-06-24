import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../features/dating/modes/dating_mode_system.dart';

/// 🎯 Amore 交友模式策略抽象基類
/// 實現策略模式，為三大核心模式提供統一介面
abstract class DatingModeStrategy {
  /// 當前策略對應的模式
  DatingMode get mode;
  
  /// 模式配置
  DatingModeConfig get config;
  
  /// 計算兩個用戶的匹配度 (0.0 - 1.0)
  Future<double> calculateCompatibility(UserModel user1, UserModel user2);
  
  /// 獲取推薦用戶列表
  Future<List<UserModel>> getRecommendedUsers(String userId, {int limit = 10});
  
  /// 過濾用戶池
  Future<List<String>> filterUserPool(List<String> userIds, String currentUserId);
  
  /// 驗證用戶是否可以加入此模式
  Future<bool> canUserJoinMode(UserModel user);
  
  /// 獲取模式專屬UI主題
  ThemeData getModeTheme();
  
  /// 獲取模式專屬匹配標準
  Map<String, dynamic> getMatchingCriteria();
  
  /// 分析用戶行為並建議模式切換
  Future<bool> shouldSuggestModeSwitch(String userId);
  
  /// 獲取破冰話題建議
  Future<List<String>> getIcebreakerSuggestions(UserModel user1, UserModel user2);
  
  /// 獲取模式特定的約會建議
  Future<List<String>> getDateSuggestions(UserModel user1, UserModel user2);
}

/// 🎯 認真交往模式策略
class SeriousDatingStrategy extends DatingModeStrategy {
  static final _instance = SeriousDatingStrategy._internal();
  SeriousDatingStrategy._internal();
  factory SeriousDatingStrategy() => _instance;

  @override
  DatingMode get mode => DatingMode.serious;

  @override
  DatingModeConfig get config => DatingModeService.modeConfigs[mode]!;

  @override
  Future<double> calculateCompatibility(UserModel user1, UserModel user2) async {
    // 認真交往模式匹配算法
    double valueAlignment = await _calculateValueAlignment(user1, user2) * 0.35;
    double lifestyleMatch = await _calculateLifestyleCompatibility(user1, user2) * 0.25;
    double mbtiCompatibility = await _calculateMBTIMatch(user1, user2) * 0.20;
    double goalAlignment = await _calculateLifeGoalAlignment(user1, user2) * 0.20;
    
    return (valueAlignment + lifestyleMatch + mbtiCompatibility + goalAlignment).clamp(0.0, 1.0);
  }

  @override
  Future<List<UserModel>> getRecommendedUsers(String userId, {int limit = 10}) async {
    // 實現認真交往模式的推薦算法
    final query = FirebaseFirestore.instance
        .collection('serious_dating_pool')
        .where('active', isEqualTo: true)
        .limit(limit);
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  @override
  Future<List<String>> filterUserPool(List<String> userIds, String currentUserId) async {
    // 過濾出符合認真交往標準的用戶
    return userIds.where((id) => id != currentUserId).toList();
  }

  @override
  Future<bool> canUserJoinMode(UserModel user) async {
    // 檢查用戶是否符合認真交往模式要求
    final restrictions = config.restrictions;
    
    // 年齡檢查
    if (user.age != null && user.age! < (restrictions['minAge'] ?? 22)) {
      return false;
    }
    
    // 驗證要求
    if (restrictions['verificationRequired'] == true && !user.isVerified) {
      return false;
    }
    
    // 檔案完整度
    if (user.profileCompleteness < (restrictions['profileCompleteness'] ?? 80)) {
      return false;
    }
    
    return true;
  }

  @override
  ThemeData getModeTheme() {
    return ThemeData(
      primaryColor: config.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: config.primaryColor,
        primary: config.primaryColor,
        secondary: config.secondaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: config.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Map<String, dynamic> getMatchingCriteria() {
    return {
      'ageRange': [25, 45],
      'educationLevel': ['大學', '碩士', '博士'],
      'relationshipGoals': ['長期關係', '結婚'],
      'mbtiImportance': 0.8,
      'valuesImportance': 0.9,
    };
  }

  @override
  Future<bool> shouldSuggestModeSwitch(String userId) async {
    // 分析用戶行為是否適合繼續認真交往模式
    return false; // 預設不建議切換
  }

  @override
  Future<List<String>> getIcebreakerSuggestions(UserModel user1, UserModel user2) async {
    return [
      '你對未來5年有什麼規劃嗎？',
      '你最重視的人生價值是什麼？',
      '你理想中的週末是怎樣度過的？',
      '你覺得什麼是維持長期關係的關鍵？',
    ];
  }

  @override
  Future<List<String>> getDateSuggestions(UserModel user1, UserModel user2) async {
    return [
      '在有意義的咖啡廳深度對話',
      '參觀博物館或藝術展覽',
      '一起做義工活動',
      '在公園散步並分享人生故事',
    ];
  }

  // 私有輔助方法
  Future<double> _calculateValueAlignment(UserModel user1, UserModel user2) async {
    // 實現價值觀對齊計算
    return 0.75; // 示例值
  }

  Future<double> _calculateLifestyleCompatibility(UserModel user1, UserModel user2) async {
    // 實現生活方式兼容性計算
    return 0.80; // 示例值
  }

  Future<double> _calculateMBTIMatch(UserModel user1, UserModel user2) async {
    // 實現MBTI匹配計算
    return 0.70; // 示例值
  }

  Future<double> _calculateLifeGoalAlignment(UserModel user1, UserModel user2) async {
    // 實現人生目標對齊計算
    return 0.85; // 示例值
  }
}

/// 🌟 探索模式策略
class ExploreStrategy extends DatingModeStrategy {
  static final _instance = ExploreStrategy._internal();
  ExploreStrategy._internal();
  factory ExploreStrategy() => _instance;

  @override
  DatingMode get mode => DatingMode.explore;

  @override
  DatingModeConfig get config => DatingModeService.modeConfigs[mode]!;

  @override
  Future<double> calculateCompatibility(UserModel user1, UserModel user2) async {
    // 探索模式匹配算法
    double interestOverlap = await _calculateInterestOverlap(user1, user2) * 0.40;
    double activityCompatibility = await _calculateActivityMatch(user1, user2) * 0.30;
    double socialEnergyMatch = await _calculateEnergyLevelMatch(user1, user2) * 0.20;
    double availabilityAlignment = await _calculateAvailabilityMatch(user1, user2) * 0.10;
    
    return (interestOverlap + activityCompatibility + socialEnergyMatch + availabilityAlignment).clamp(0.0, 1.0);
  }

  @override
  Future<List<UserModel>> getRecommendedUsers(String userId, {int limit = 10}) async {
    final query = FirebaseFirestore.instance
        .collection('explore_pool')
        .where('active', isEqualTo: true)
        .limit(limit);
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  @override
  Future<List<String>> filterUserPool(List<String> userIds, String currentUserId) async {
    return userIds.where((id) => id != currentUserId).toList();
  }

  @override
  Future<bool> canUserJoinMode(UserModel user) async {
    // 探索模式相對開放
    return user.age != null && user.age! >= 18;
  }

  @override
  ThemeData getModeTheme() {
    return ThemeData(
      primaryColor: Colors.orange,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        primary: Colors.orange,
        secondary: Colors.amber,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Map<String, dynamic> getMatchingCriteria() {
    return {
      'ageRange': [18, 50],
      'interestImportance': 0.8,
      'activityImportance': 0.7,
      'opennessLevel': 0.9,
    };
  }

  @override
  Future<bool> shouldSuggestModeSwitch(String userId) async {
    return false;
  }

  @override
  Future<List<String>> getIcebreakerSuggestions(UserModel user1, UserModel user2) async {
    return [
      '你最近有什麼有趣的新發現嗎？',
      '你最想嘗試的活動是什麼？',
      '如果可以去任何地方旅行，你會選哪裡？',
      '你的興趣愛好中最讓你著迷的是什麼？',
    ];
  }

  @override
  Future<List<String>> getDateSuggestions(UserModel user1, UserModel user2) async {
    return [
      '嘗試新的餐廳或美食',
      '參加有趣的工作坊或課程',
      '探索城市的新景點',
      '一起玩桌遊或運動',
    ];
  }

  // 私有輔助方法
  Future<double> _calculateInterestOverlap(UserModel user1, UserModel user2) async {
    return 0.75;
  }

  Future<double> _calculateActivityMatch(UserModel user1, UserModel user2) async {
    return 0.70;
  }

  Future<double> _calculateEnergyLevelMatch(UserModel user1, UserModel user2) async {
    return 0.80;
  }

  Future<double> _calculateAvailabilityMatch(UserModel user1, UserModel user2) async {
    return 0.65;
  }
}

/// 🔥 激情模式策略
class PassionStrategy extends DatingModeStrategy {
  static final _instance = PassionStrategy._internal();
  PassionStrategy._internal();
  factory PassionStrategy() => _instance;

  @override
  DatingMode get mode => DatingMode.passion;

  @override
  DatingModeConfig get config => DatingModeService.modeConfigs[mode]!;

  @override
  Future<double> calculateCompatibility(UserModel user1, UserModel user2) async {
    // 激情模式匹配算法
    double physicalAttraction = await _calculatePhysicalAttraction(user1, user2) * 0.40;
    double proximityScore = await _calculateProximity(user1, user2) * 0.30;
    double timeAvailability = await _calculateTimeCompatibility(user1, user2) * 0.20;
    double intentAlignment = await _calculateIntentAlignment(user1, user2) * 0.10;
    
    return (physicalAttraction + proximityScore + timeAvailability + intentAlignment).clamp(0.0, 1.0);
  }

  @override
  Future<List<UserModel>> getRecommendedUsers(String userId, {int limit = 10}) async {
    final query = FirebaseFirestore.instance
        .collection('passion_pool')
        .where('active', isEqualTo: true)
        .limit(limit);
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  @override
  Future<List<String>> filterUserPool(List<String> userIds, String currentUserId) async {
    return userIds.where((id) => id != currentUserId).toList();
  }

  @override
  Future<bool> canUserJoinMode(UserModel user) async {
    // 激情模式需要年齡驗證和同意條款
    return user.age != null && user.age! >= 21 && user.isVerified;
  }

  @override
  ThemeData getModeTheme() {
    return ThemeData(
      primaryColor: Colors.red,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        primary: Colors.red,
        secondary: Colors.pink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Map<String, dynamic> getMatchingCriteria() {
    return {
      'ageRange': [21, 55],
      'proximityImportance': 0.8,
      'availabilityImportance': 0.9,
      'directnessLevel': 0.8,
    };
  }

  @override
  Future<bool> shouldSuggestModeSwitch(String userId) async {
    return false;
  }

  @override
  Future<List<String>> getIcebreakerSuggestions(UserModel user1, UserModel user2) async {
    return [
      '你今晚有什麼計劃嗎？',
      '你喜歡什麼樣的夜生活？',
      '你最喜歡的放鬆方式是什麼？',
      '想要一起度過美好的時光嗎？',
    ];
  }

  @override
  Future<List<String>> getDateSuggestions(UserModel user1, UserModel user2) async {
    return [
      '在時尚的酒吧享受雞尾酒',
      '一起看日落或夜景',
      '私密的晚餐約會',
      '舞蹈或音樂活動',
    ];
  }

  // 私有輔助方法
  Future<double> _calculatePhysicalAttraction(UserModel user1, UserModel user2) async {
    return 0.80;
  }

  Future<double> _calculateProximity(UserModel user1, UserModel user2) async {
    return 0.75;
  }

  Future<double> _calculateTimeCompatibility(UserModel user1, UserModel user2) async {
    return 0.70;
  }

  Future<double> _calculateIntentAlignment(UserModel user1, UserModel user2) async {
    return 0.85;
  }
} 