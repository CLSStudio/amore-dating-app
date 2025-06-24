import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/dating/modes/dating_mode_system.dart';
import '../models/mode_profile.dart';
import '../../models/user_model.dart';

/// 🎯 Amore 相容性計算服務
/// 為三大核心模式提供專屬的匹配算法
class CompatibilityService {
  static final CompatibilityService _instance = CompatibilityService._internal();
  factory CompatibilityService() => _instance;
  CompatibilityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🧮 計算兩個用戶的整體相容性分數 (0.0 - 1.0)
  Future<double> calculateCompatibility(
    UserModel user1, 
    UserModel user2, 
    DatingMode mode
  ) async {
    switch (mode) {
      case DatingMode.serious:
        return await _calculateSeriousCompatibility(user1, user2);
      case DatingMode.explore:
        return await _calculateExploreCompatibility(user1, user2);
      case DatingMode.passion:
        return await _calculatePassionCompatibility(user1, user2);
    }
  }

  /// 🎯 認真交往模式相容性計算
  Future<double> _calculateSeriousCompatibility(UserModel user1, UserModel user2) async {
    try {
      // 權重分配
      const weights = {
        'education': 0.30,    // 教育背景 30%
        'location': 0.25,     // 位置匹配 25%
        'interests': 0.25,    // 興趣愛好 25%
        'mbti': 0.20,        // MBTI匹配 20%
      };

      // 計算各項分數
      final educationScore = _calculateEducationMatch(user1, user2);
      final locationScore = _calculateLocationProximity(user1, user2);
      final interestsScore = _calculateInterestOverlap(user1, user2);
      final mbtiScore = _calculateMBTICompatibility(user1, user2);

      // 加權平均
      final totalScore = (educationScore * weights['education']!) +
                        (locationScore * weights['location']!) +
                        (interestsScore * weights['interests']!) +
                        (mbtiScore * weights['mbti']!);

      return totalScore.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5; // 出錯時返回中性分數
    }
  }

  /// 🌟 探索模式相容性計算
  Future<double> _calculateExploreCompatibility(UserModel user1, UserModel user2) async {
    try {
      // 權重分配
      const weights = {
        'interests': 0.60,     // 興趣重疊 60%
        'location': 0.40,      // 地理位置 40%
      };

      // 計算各項分數
      final interestsScore = _calculateInterestOverlap(user1, user2);
      final locationScore = _calculateLocationProximity(user1, user2);

      // 加權平均
      final totalScore = (interestsScore * weights['interests']!) +
                        (locationScore * weights['location']!);

      return totalScore.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  /// 🔥 激情模式相容性計算
  Future<double> _calculatePassionCompatibility(UserModel user1, UserModel user2) async {
    try {
      // 權重分配
      const weights = {
        'proximity': 0.60,    // 地理接近度 60%
        'availability': 0.40, // 在線狀態 40%
      };

      // 計算各項分數
      final proximityScore = _calculateLocationProximity(user1, user2);
      final availabilityScore = _calculateAvailabilityMatch(user1, user2);

      // 加權平均
      final totalScore = (proximityScore * weights['proximity']!) +
                        (availabilityScore * weights['availability']!);

      return totalScore.clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  // 核心匹配算法

  /// 計算教育背景匹配度
  double _calculateEducationMatch(UserModel user1, UserModel user2) {
    // 使用興趣作為教育背景的替代指標
    final interests1 = user1.interests;
    final interests2 = user2.interests;
    
    if (interests1.isEmpty || interests2.isEmpty) return 0.3;
    
    final commonInterests = interests1.where((interest) => 
        interests2.contains(interest)).length;
    final totalInterests = max(interests1.length, interests2.length);
    
    return totalInterests > 0 ? commonInterests / totalInterests : 0.3;
  }

  /// 計算興趣重疊度
  double _calculateInterestOverlap(UserModel user1, UserModel user2) {
    final interests1 = user1.interests;
    final interests2 = user2.interests;
    
    if (interests1.isEmpty || interests2.isEmpty) return 0.3;
    
    final commonInterests = interests1.where((interest) => 
        interests2.contains(interest)).length;
    final totalInterests = max(interests1.length, interests2.length);
    
    return totalInterests > 0 ? commonInterests / totalInterests : 0.3;
  }

  /// 計算地理位置接近度
  double _calculateLocationProximity(UserModel user1, UserModel user2) {
    // 使用location字符串進行匹配
    return _calculateLocationStringMatch(user1, user2);
  }

  /// 計算位置字符串匹配度
  double _calculateLocationStringMatch(UserModel user1, UserModel user2) {
    final location1 = user1.location?.toLowerCase() ?? '';
    final location2 = user2.location?.toLowerCase() ?? '';
    
    if (location1.isEmpty || location2.isEmpty) return 0.3;
    
    if (location1 == location2) return 1.0;
    
    // 檢查是否在同一區域
    if (location1.contains(location2) || location2.contains(location1)) {
      return 0.8;
    }
    
    return 0.4;
  }

  /// 計算MBTI相容性
  double _calculateMBTICompatibility(UserModel user1, UserModel user2) {
    final mbti1 = user1.mbtiType ?? '';
    final mbti2 = user2.mbtiType ?? '';
    
    if (mbti1.isEmpty || mbti2.isEmpty || mbti1.length != 4 || mbti2.length != 4) {
      return 0.5;
    }
    
    // MBTI相容性矩陣（簡化版）
    const compatibilityMatrix = {
      'INTJ': ['ENFP', 'ENTP', 'INFJ', 'INFP'],
      'INTP': ['ENFJ', 'ENTJ', 'INFJ', 'INTJ'],
      'ENTJ': ['INFP', 'INTP', 'ENFJ', 'ENTP'],
      'ENTP': ['INFJ', 'INTJ', 'ENFJ', 'ENTJ'],
      'INFJ': ['ENFP', 'ENTP', 'INFP', 'INTJ'],
      'INFP': ['ENFJ', 'ENTJ', 'INFJ', 'INTJ'],
      'ENFJ': ['INFP', 'INTP', 'ENFP', 'ENTJ'],
      'ENFP': ['INFJ', 'INTJ', 'ENFJ', 'ENTP'],
      'ISTJ': ['ESFP', 'ESTP', 'ISFJ', 'ISFP'],
      'ISFJ': ['ESFP', 'ESTP', 'ISTJ', 'ISFP'],
      'ESTJ': ['ISFP', 'ISTP', 'ESFJ', 'ESTP'],
      'ESFJ': ['ISFP', 'ISTP', 'ESTJ', 'ESFP'],
      'ISTP': ['ESFJ', 'ESTJ', 'ISFJ', 'ISTJ'],
      'ISFP': ['ESFJ', 'ESTJ', 'ISFJ', 'ISTJ'],
      'ESTP': ['ISFJ', 'ISTJ', 'ESFP', 'ESTJ'],
      'ESFP': ['ISFJ', 'ISTJ', 'ESTP', 'ESFJ'],
    };
    
    final compatible = compatibilityMatrix[mbti1] ?? [];
    if (compatible.contains(mbti2)) {
      return 0.9; // 高度相容
    }
    
    // 計算字母相似度
    int matches = 0;
    for (int i = 0; i < 4; i++) {
      if (mbti1[i] == mbti2[i]) matches++;
    }
    
    return 0.3 + (matches / 4) * 0.4; // 基礎分 + 相似度加分
  }

  /// 計算在線狀態匹配度
  double _calculateAvailabilityMatch(UserModel user1, UserModel user2) {
    // 簡化實現，基於用戶活躍度
    final user1Active = user1.isActive;
    final user2Active = user2.isActive;
    
    if (user1Active && user2Active) {
      return 1.0; // 都在線
    } else if (user1Active || user2Active) {
      return 0.6; // 一個在線
    } else {
      return 0.3; // 都不在線
    }
  }

  // 輔助方法

  /// 計算兩點間距離（公里）
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    
    final double lat1Rad = lat1 * pi / 180;
    final double lat2Rad = lat2 * pi / 180;
    final double deltaLatRad = (lat2 - lat1) * pi / 180;
    final double deltaLonRad = (lon2 - lon1) * pi / 180;
    
    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  /// 🔍 批量計算相容性分數
  Future<Map<String, double>> calculateBatchCompatibility(
    UserModel user,
    List<UserModel> candidates,
    DatingMode mode
  ) async {
    final Map<String, double> results = {};
    
    for (final candidate in candidates) {
      final score = await calculateCompatibility(user, candidate, mode);
      results[candidate.uid] = score;
    }
    
    return results;
  }

  /// 💡 獲取破冰話題建議
  Future<List<String>> getIcebreakerSuggestions(
    UserModel user1, 
    UserModel user2, 
    DatingMode mode
  ) async {
    switch (mode) {
      case DatingMode.serious:
        return _getSeriousIcebreakers(user1, user2);
      case DatingMode.explore:
        return _getExploreIcebreakers(user1, user2);
      case DatingMode.passion:
        return _getPassionIcebreakers(user1, user2);
    }
  }

  List<String> _getSeriousIcebreakers(UserModel user1, UserModel user2) {
    final commonInterests = user1.interests.where(
      (interest) => user2.interests.contains(interest)
    ).toList();
    
    final suggestions = <String>[
      '你對未來5年有什麼規劃嗎？',
      '你最重視的人生價值是什麼？',
      '你理想中的週末是怎樣度過的？',
    ];
    
    if (commonInterests.isNotEmpty) {
      suggestions.add('我看到我們都喜歡${commonInterests.first}，你是什麼時候開始接觸的？');
    }
    
    return suggestions;
  }

  List<String> _getExploreIcebreakers(UserModel user1, UserModel user2) {
    final commonInterests = user1.interests.where(
      (interest) => user2.interests.contains(interest)
    ).toList();
    
    final suggestions = <String>[
      '你最近發現了什麼有趣的事情嗎？',
      '如果可以立刻去任何地方旅行，你會選擇哪裡？',
      '你的週末通常都在做什麼？',
    ];
    
    if (commonInterests.isNotEmpty) {
      suggestions.add('我們都喜歡${commonInterests.first}！你有什麼推薦的嗎？');
    }
    
    return suggestions;
  }

  List<String> _getPassionIcebreakers(UserModel user1, UserModel user2) {
    return [
      '你好！看起來我們在附近，要不要找個地方聊聊？',
      '今天天氣不錯，有什麼推薦的附近好去處嗎？',
      '你也在這個區域嗎？我剛發現一家不錯的咖啡廳',
      'Hi！想找個人一起探索這個城市，你有興趣嗎？',
    ];
  }
} 