import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mode_profile.dart';
import '../../models/user_model.dart';
import '../../../features/dating/modes/dating_mode_system.dart';

/// 🧮 Amore 配對演算法核心
/// 為三大交友模式提供專屬的匹配邏輯
abstract class MatchingAlgorithm {
  /// 計算兩個用戶的相容性分數 (0.0 - 1.0)
  Future<double> calculateCompatibility(UserModel user1, UserModel user2);
  
  /// 獲取權重配置
  Map<String, double> get weights;
  
  /// 獲取演算法名稱
  String get algorithmName;
}

/// 🎯 認真交往配對演算法
/// 專注於深度相容性分析：價值觀、生活目標、MBTI匹配
class SeriousMatchingAlgorithm extends MatchingAlgorithm {
  @override
  String get algorithmName => 'serious_dating_algorithm_v2.0';

  @override
  Map<String, double> get weights => {
    'valueAlignment': 0.35,      // 價值觀對齊 35%
    'lifestyleMatch': 0.25,      // 生活方式匹配 25%
    'mbtiCompatibility': 0.20,   // MBTI相容性 20%
    'goalAlignment': 0.20,       // 人生目標對齊 20%
  };

  @override
  Future<double> calculateCompatibility(UserModel user1, UserModel user2) async {
    try {
      // 獲取認真交往專屬檔案
      final profile1 = SeriousDatingProfile.fromUserModel(user1);
      final profile2 = SeriousDatingProfile.fromUserModel(user2);

      // 計算各項兼容性指標
      final valueAlignment = await _calculateValueAlignment(profile1, profile2);
      final lifestyleMatch = await _calculateLifestyleCompatibility(profile1, profile2);
      final mbtiCompatibility = await _calculateMBTIMatch(profile1, profile2);
      final goalAlignment = await _calculateLifeGoalAlignment(profile1, profile2);

      // 加權計算總分
      final totalScore = 
          valueAlignment * weights['valueAlignment']! +
          lifestyleMatch * weights['lifestyleMatch']! +
          mbtiCompatibility * weights['mbtiCompatibility']! +
          goalAlignment * weights['goalAlignment']!;

      return totalScore.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('認真交往配對演算法錯誤: $e');
      return 0.0;
    }
  }

  /// 🔍 計算價值觀對齊度
  Future<double> _calculateValueAlignment(SeriousDatingProfile profile1, SeriousDatingProfile profile2) async {
    if (profile1.coreValues.isEmpty || profile2.coreValues.isEmpty) return 0.5;

    // 計算核心價值觀重疊度
    final overlap = profile1.coreValues.toSet().intersection(profile2.coreValues.toSet());
    final union = profile1.coreValues.toSet().union(profile2.coreValues.toSet());
    
    double valueOverlap = union.isEmpty ? 0.0 : overlap.length / union.length;

    // 特殊價值觀加分機制
    if (overlap.contains('家庭第一') || overlap.contains('誠實守信')) {
      valueOverlap += 0.1;
    }
    if (overlap.contains('事業心') && overlap.contains('責任感')) {
      valueOverlap += 0.05;
    }

    return valueOverlap.clamp(0.0, 1.0);
  }

  /// 🏠 計算生活方式兼容性
  Future<double> _calculateLifestyleCompatibility(SeriousDatingProfile profile1, SeriousDatingProfile profile2) async {
    double score = 0.0;

    // 教育程度匹配 (40%)
    score += _calculateEducationMatch(profile1.education, profile2.education) * 0.4;

    // 職業相容性 (30%)
    score += _calculateOccupationCompatibility(profile1.occupation, profile2.occupation) * 0.3;

    // 地理位置便利性 (20%)
    if (profile1.location != null && profile2.location != null) {
      score += _calculateLocationCompatibility(profile1.location!, profile2.location!) * 0.2;
    } else {
      score += 0.1; // 缺少位置資訊時給予中等分數
    }

    // 生活習慣匹配 (10%)
    score += _calculateLifestyleHabitsMatch(profile1, profile2) * 0.1;

    return score.clamp(0.0, 1.0);
  }

  /// 🧠 計算MBTI匹配度
  Future<double> _calculateMBTIMatch(SeriousDatingProfile profile1, SeriousDatingProfile profile2) async {
    if (profile1.mbtiType == null || profile2.mbtiType == null) return 0.5;

    // MBTI相容性矩陣
    final compatibilityMatrix = _getMBTICompatibilityMatrix();
    final key1 = '${profile1.mbtiType}_${profile2.mbtiType}';
    final key2 = '${profile2.mbtiType}_${profile1.mbtiType}';

    return compatibilityMatrix[key1] ?? compatibilityMatrix[key2] ?? 0.5;
  }

  /// 🎯 計算人生目標對齊度
  Future<double> _calculateLifeGoalAlignment(SeriousDatingProfile profile1, SeriousDatingProfile profile2) async {
    double score = 0.0;

    // 關係目標匹配 (50%)
    if (profile1.relationshipGoals == profile2.relationshipGoals) {
      score += 0.5;
    } else if (_areRelationshipGoalsCompatible(profile1.relationshipGoals, profile2.relationshipGoals)) {
      score += 0.3;
    }

    // 家庭規劃匹配 (50%)
    if (profile1.familyPlanning == profile2.familyPlanning) {
      score += 0.5;
    } else if (_areFamilyPlansCompatible(profile1.familyPlanning, profile2.familyPlanning)) {
      score += 0.3;
    }

    return score.clamp(0.0, 1.0);
  }

  /// 📚 教育程度匹配
  double _calculateEducationMatch(String? edu1, String? edu2) {
    if (edu1 == null || edu2 == null) return 0.5;

    final educationLevels = ['高中', '專科', '大學', '碩士', '博士'];
    final level1 = educationLevels.indexOf(edu1);
    final level2 = educationLevels.indexOf(edu2);

    if (level1 == -1 || level2 == -1) return 0.5;

    // 相同教育程度最高分
    if (level1 == level2) return 1.0;

    // 相差一級次高分
    if ((level1 - level2).abs() == 1) return 0.8;

    // 相差越大分數越低
    final diff = (level1 - level2).abs();
    return (1.0 - diff * 0.2).clamp(0.0, 1.0);
  }

  /// 💼 職業相容性
  double _calculateOccupationCompatibility(String? occ1, String? occ2) {
    if (occ1 == null || occ2 == null) return 0.5;

    // 同類型職業群組
    final professionGroups = {
      '醫療健康': ['醫生', '護士', '藥師', '治療師'],
      '教育研究': ['教師', '教授', '研究員', '學者'],
      '商業金融': ['銀行家', '會計師', '顧問', '分析師'],
      '創意設計': ['設計師', '藝術家', '作家', '攝影師'],
      '科技工程': ['工程師', '程式設計師', '產品經理', '數據科學家'],
      '法律政府': ['律師', '法官', '公務員', '政策分析師'],
    };

    for (final group in professionGroups.values) {
      if (group.contains(occ1) && group.contains(occ2)) {
        return 0.9; // 同群組高相容性
      }
    }

    return 0.6; // 不同群組中等相容性
  }

  /// 📍 地理位置兼容性
  double _calculateLocationCompatibility(String loc1, String loc2) {
    // 香港區域親近度
    final distanceMatrix = {
      '港島_港島': 0.9, '港島_九龍': 0.7, '港島_新界': 0.5,
      '九龍_九龍': 0.9, '九龍_新界': 0.6,
      '新界_新界': 0.8,
    };

    final key = '${loc1}_${loc2}';
    return distanceMatrix[key] ?? distanceMatrix['${loc2}_${loc1}'] ?? 0.5;
  }

  /// 🏃‍♀️ 生活習慣匹配
  double _calculateLifestyleHabitsMatch(SeriousDatingProfile profile1, SeriousDatingProfile profile2) {
    // 這裡可以根據具體的生活習慣數據進行計算
    // 例如：運動習慣、作息時間、社交偏好等
    return 0.7; // 暫時返回中等匹配度
  }

  /// 🧬 MBTI相容性矩陣
  Map<String, double> _getMBTICompatibilityMatrix() {
    return {
      // 高度相容組合
      'INTJ_ENFP': 0.95, 'INTP_ENFJ': 0.95, 'INFJ_ENTP': 0.95, 'INFP_ENTJ': 0.95,
      'ISTJ_ESFP': 0.90, 'ISTP_ESFJ': 0.90, 'ISFJ_ESTP': 0.90, 'ISFP_ESTJ': 0.90,
      
      // 中等相容組合
      'INTJ_INTJ': 0.80, 'ENFP_ENFP': 0.80, 'INFJ_INFJ': 0.80, 'ENTP_ENTP': 0.80,
      
      // 基礎相容
      'INTJ_ISFJ': 0.70, 'ENFP_ISTJ': 0.70, 'INFJ_ESTP': 0.70, 'ENTP_ISFP': 0.70,
    };
  }

  /// 💕 關係目標兼容性
  bool _areRelationshipGoalsCompatible(String? goal1, String? goal2) {
    if (goal1 == null || goal2 == null) return false;
    
    final compatiblePairs = {
      '長期關係': ['結婚', '穩定交往'],
      '結婚': ['長期關係', '穩定交往'],
      '穩定交往': ['長期關係', '結婚'],
    };

    return compatiblePairs[goal1]?.contains(goal2) ?? false;
  }

  /// 👶 家庭規劃兼容性
  bool _areFamilyPlansCompatible(String? plan1, String? plan2) {
    if (plan1 == null || plan2 == null) return false;
    
    final compatiblePairs = {
      '想要孩子': ['開放討論', '未決定'],
      '不要孩子': ['未決定'],
      '開放討論': ['想要孩子', '不要孩子', '未決定'],
    };

    return compatiblePairs[plan1]?.contains(plan2) ?? false;
  }
}

/// 🌟 探索模式配對演算法
/// 專注於興趣匹配和社交相容性
class ExploreMatchingAlgorithm extends MatchingAlgorithm {
  @override
  String get algorithmName => 'explore_mode_algorithm_v2.0';

  @override
  Map<String, double> get weights => {
    'interestOverlap': 0.40,        // 興趣重疊 40%
    'activityCompatibility': 0.30,  // 活動相容性 30%
    'socialEnergyMatch': 0.20,      // 社交能量匹配 20%
    'availabilityAlignment': 0.10,  // 時間可用性 10%
  };

  @override
  Future<double> calculateCompatibility(UserModel user1, UserModel user2) async {
    try {
      final profile1 = ExploreProfile.fromUserModel(user1);
      final profile2 = ExploreProfile.fromUserModel(user2);

      final interestOverlap = await _calculateInterestOverlap(profile1, profile2);
      final activityCompatibility = await _calculateActivityMatch(profile1, profile2);
      final socialEnergyMatch = await _calculateEnergyLevelMatch(profile1, profile2);
      final availabilityAlignment = await _calculateAvailabilityMatch(profile1, profile2);

      final totalScore = 
          interestOverlap * weights['interestOverlap']! +
          activityCompatibility * weights['activityCompatibility']! +
          socialEnergyMatch * weights['socialEnergyMatch']! +
          availabilityAlignment * weights['availabilityAlignment']!;

      return totalScore.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('探索模式配對演算法錯誤: $e');
      return 0.0;
    }
  }

  /// 🎨 計算興趣重疊度
  Future<double> _calculateInterestOverlap(ExploreProfile profile1, ExploreProfile profile2) async {
    if (profile1.interests.isEmpty || profile2.interests.isEmpty) return 0.3;

    final overlap = profile1.interests.toSet().intersection(profile2.interests.toSet());
    final union = profile1.interests.toSet().union(profile2.interests.toSet());
    
    double baseOverlap = union.isEmpty ? 0.0 : overlap.length / union.length;

    // 加分機制：共同興趣的質量評估
    double qualityBonus = 0.0;
    final highValueInterests = ['旅行', '美食', '音樂', '電影', '運動', '閱讀'];
    
    for (final interest in overlap) {
      if (highValueInterests.contains(interest)) {
        qualityBonus += 0.05;
      }
    }

    return (baseOverlap + qualityBonus).clamp(0.0, 1.0);
  }

  /// 🏃‍♀️ 計算活動相容性
  Future<double> _calculateActivityMatch(ExploreProfile profile1, ExploreProfile profile2) async {
    // 活動風格匹配
    double styleMatch = _calculateActivityStyleMatch(profile1.activityLevel, profile2.activityLevel);
    
    // 語言相容性
    double languageMatch = _calculateLanguageCompatibility(profile1.languages, profile2.languages);
    
    // 社交活動偏好匹配
    double socialMatch = _calculateSocialActivityMatch(profile1, profile2);

    return (styleMatch * 0.4 + languageMatch * 0.3 + socialMatch * 0.3).clamp(0.0, 1.0);
  }

  /// ⚡ 計算社交能量匹配
  Future<double> _calculateEnergyLevelMatch(ExploreProfile profile1, ExploreProfile profile2) async {
    final energyLevels = ['低調內向', '平衡適中', '活躍外向'];
    
    final level1 = energyLevels.indexOf(profile1.activityLevel);
    final level2 = energyLevels.indexOf(profile2.activityLevel);

    if (level1 == -1 || level2 == -1) return 0.5;

    // 相同能量級別最高分
    if (level1 == level2) return 1.0;

    // 相鄰級別次高分
    if ((level1 - level2).abs() == 1) return 0.7;

    // 極端差異低分
    return 0.3;
  }

  /// ⏰ 計算時間可用性匹配
  Future<double> _calculateAvailabilityMatch(ExploreProfile profile1, ExploreProfile profile2) async {
    // 這裡可以根據用戶的活躍時間、空閒時段等進行計算
    // 暫時返回基礎匹配度
    return 0.7;
  }

  /// 輔助方法
  double _calculateActivityStyleMatch(String style1, String style2) {
    if (style1 == style2) return 1.0;
    
    final compatibleStyles = {
      '低調內向': ['平衡適中'],
      '平衡適中': ['低調內向', '活躍外向'],
      '活躍外向': ['平衡適中'],
    };

    return compatibleStyles[style1]?.contains(style2) == true ? 0.8 : 0.4;
  }

  double _calculateLanguageCompatibility(List<String> langs1, List<String> langs2) {
    if (langs1.isEmpty || langs2.isEmpty) return 0.5;

    final overlap = langs1.toSet().intersection(langs2.toSet());
    return overlap.isEmpty ? 0.3 : (overlap.length / langs1.length.clamp(1, 5)).clamp(0.0, 1.0);
  }

  double _calculateSocialActivityMatch(ExploreProfile profile1, ExploreProfile profile2) {
    // 根據用戶的社交活動偏好計算匹配度
    return 0.6; // 暫時返回中等匹配度
  }
}

/// 🔥 激情模式配對演算法  
/// 專注於地理位置和即時化學反應
class PassionMatchingAlgorithm extends MatchingAlgorithm {
  @override
  String get algorithmName => 'passion_mode_algorithm_v2.0';

  @override
  Map<String, double> get weights => {
    'proximityScore': 0.50,      // 地理接近度 50%
    'timeAvailability': 0.30,    // 時間可用性 30%  
    'intentAlignment': 0.20,     // 意圖對齊 20%
  };

  @override
  Future<double> calculateCompatibility(UserModel user1, UserModel user2) async {
    try {
      final profile1 = PassionProfile.fromUserModel(user1);
      final profile2 = PassionProfile.fromUserModel(user2);

      final proximityScore = await _calculateProximity(profile1, profile2);
      final timeAvailability = await _calculateTimeCompatibility(profile1, profile2);
      final intentAlignment = await _calculateIntentAlignment(profile1, profile2);

      final totalScore = 
          proximityScore * weights['proximityScore']! +
          timeAvailability * weights['timeAvailability']! +
          intentAlignment * weights['intentAlignment']!;

      return totalScore.clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('激情模式配對演算法錯誤: $e');
      return 0.0;
    }
  }

  /// 📍 計算地理接近度
  Future<double> _calculateProximity(PassionProfile profile1, PassionProfile profile2) async {
    if (profile1.currentLocation == null || profile2.currentLocation == null) {
      return 0.1; // 沒有位置資訊時給予很低分數
    }

    // 計算實際距離
    final distance = Geolocator.distanceBetween(
      profile1.currentLocation!.latitude,
      profile1.currentLocation!.longitude,
      profile2.currentLocation!.latitude,
      profile2.currentLocation!.longitude,
    );

    // 距離評分系統（以米為單位）
    if (distance <= 500) return 1.0;       // 500米內：完美
    if (distance <= 1000) return 0.9;      // 1公里內：優秀
    if (distance <= 2000) return 0.8;      // 2公里內：良好
    if (distance <= 5000) return 0.6;      // 5公里內：中等
    if (distance <= 10000) return 0.4;     // 10公里內：尚可
    if (distance <= 20000) return 0.2;     // 20公里內：較差
    
    return 0.1; // 超過20公里：極差
  }

  /// ⏰ 計算時間相容性
  Future<double> _calculateTimeCompatibility(PassionProfile profile1, PassionProfile profile2) async {
    // 檢查當前是否都在線上
    final currentTime = DateTime.now();
    
    bool user1Available = profile1.isOnline && 
        (profile1.availableUntil == null || profile1.availableUntil!.isAfter(currentTime));
    bool user2Available = profile2.isOnline && 
        (profile2.availableUntil == null || profile2.availableUntil!.isAfter(currentTime));

    if (user1Available && user2Available) {
      return 1.0; // 兩人都在線且可用
    } else if (user1Available || user2Available) {
      return 0.6; // 只有一人在線
    } else {
      return 0.2; // 都不在線
    }
  }

  /// 💫 計算意圖對齊度
  Future<double> _calculateIntentAlignment(PassionProfile profile1, PassionProfile profile2) async {
    // 根據用戶設定的尋找目標計算匹配度
    if (profile1.lookingFor == null || profile2.lookingFor == null) {
      return 0.5; // 缺少資訊時給予中等分數
    }

    // 完全匹配的組合
    final perfectMatches = {
      '即時約會': ['即時約會', '隨機相遇'],
      '隨機相遇': ['即時約會', '隨機相遇', '附近社交'],
      '附近社交': ['隨機相遇', '附近社交', '探索新人'],
      '探索新人': ['附近社交', '探索新人'],
    };

    if (profile1.lookingFor == profile2.lookingFor) {
      return 1.0; // 完全相同的意圖
    }

    if (perfectMatches[profile1.lookingFor]?.contains(profile2.lookingFor) == true) {
      return 0.8; // 兼容的意圖
    }

    return 0.3; // 不太兼容的意圖
  }
}

/// 🎯 配對演算法工廠
class MatchingAlgorithmFactory {
  static MatchingAlgorithm getAlgorithmForMode(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return SeriousMatchingAlgorithm();
      case DatingMode.explore:
        return ExploreMatchingAlgorithm();
      case DatingMode.passion:
        return PassionMatchingAlgorithm();
    }
  }
} 