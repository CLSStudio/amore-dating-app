import 'dart:math';

import '../../domain/entities/match.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../mbti/domain/entities/mbti_question.dart';
import '../../../values/domain/entities/values_assessment.dart';

/// 匹配算法服務
class MatchingAlgorithmService {
  /// 計算兩個用戶的整體相容性評分
  static double calculateCompatibilityScore(
    Profile user1,
    Profile user2,
    MbtiResult? user1Mbti,
    MbtiResult? user2Mbti,
    ValuesAssessment? user1Values,
    ValuesAssessment? user2Values,
  ) {
    double totalScore = 0;
    int factors = 0;

    // 1. MBTI 相容性 (權重: 25%)
    if (user1Mbti != null && user2Mbti != null) {
      final mbtiScore = _calculateMbtiCompatibility(user1Mbti, user2Mbti);
      totalScore += mbtiScore * 0.25;
      factors++;
    }

    // 2. 價值觀相容性 (權重: 30%)
    if (user1Values != null && user2Values != null) {
      final valuesScore = user1Values.getCompatibilityScore(user2Values);
      totalScore += valuesScore * 0.30;
      factors++;
    }

    // 3. 興趣相容性 (權重: 20%)
    final interestsScore = _calculateInterestsCompatibility(user1, user2);
    totalScore += interestsScore * 0.20;
    factors++;

    // 4. 生活方式相容性 (權重: 15%)
    final lifestyleScore = _calculateLifestyleCompatibility(user1, user2);
    totalScore += lifestyleScore * 0.15;
    factors++;

    // 5. 年齡相容性 (權重: 10%)
    final ageScore = _calculateAgeCompatibility(user1, user2);
    totalScore += ageScore * 0.10;
    factors++;

    return factors > 0 ? totalScore : 0.0;
  }

  /// 計算 MBTI 相容性
  static double _calculateMbtiCompatibility(MbtiResult mbti1, MbtiResult mbti2) {
    if (mbti1.type == mbti2.type) {
      return 1.0; // 完全相同
    }

    // 使用預定義的 MBTI 相容性矩陣
    final compatibilityMatrix = _getMbtiCompatibilityMatrix();
    final score = compatibilityMatrix[mbti1.type]?[mbti2.type] ?? 0.5;
    
    return score;
  }

  /// 獲取 MBTI 相容性矩陣
  static Map<String, Map<String, double>> _getMbtiCompatibilityMatrix() {
    return {
      'ENFP': {
        'INTJ': 0.95, 'INFJ': 0.90, 'ENFJ': 0.85, 'ENTP': 0.80,
        'ENFP': 1.0, 'INFP': 0.85, 'INTP': 0.75, 'ENTJ': 0.70,
      },
      'ENFJ': {
        'INFP': 0.95, 'INTP': 0.90, 'ENFP': 0.85, 'ISFP': 0.80,
        'ENFJ': 1.0, 'INFJ': 0.85, 'ENTP': 0.75, 'INTJ': 0.70,
      },
      'ENTP': {
        'INTJ': 0.95, 'INFJ': 0.90, 'ENFP': 0.80, 'INTP': 0.85,
        'ENTP': 1.0, 'ENTJ': 0.75, 'ENFJ': 0.75, 'INFP': 0.70,
      },
      'ENTJ': {
        'INTP': 0.95, 'INFP': 0.90, 'ENTP': 0.75, 'INTJ': 0.85,
        'ENTJ': 1.0, 'ENFJ': 0.70, 'ENFP': 0.70, 'INFJ': 0.65,
      },
      'INFP': {
        'ENFJ': 0.95, 'ENTJ': 0.90, 'INFJ': 0.85, 'ENFP': 0.85,
        'INFP': 1.0, 'INTP': 0.75, 'ISFP': 0.80, 'ENTP': 0.70,
      },
      'INFJ': {
        'ENFP': 0.90, 'ENTP': 0.90, 'INFP': 0.85, 'INTJ': 0.80,
        'INFJ': 1.0, 'ENFJ': 0.85, 'ISFJ': 0.75, 'ENTJ': 0.65,
      },
      'INTP': {
        'ENTJ': 0.95, 'ENFJ': 0.90, 'ENTP': 0.85, 'INTJ': 0.80,
        'INTP': 1.0, 'INFP': 0.75, 'ISTP': 0.70, 'ENFP': 0.75,
      },
      'INTJ': {
        'ENFP': 0.95, 'ENTP': 0.95, 'INFJ': 0.80, 'INTP': 0.80,
        'INTJ': 1.0, 'ENTJ': 0.85, 'ISFJ': 0.60, 'INFP': 0.70,
      },
    };
  }

  /// 計算興趣相容性
  static double _calculateInterestsCompatibility(Profile user1, Profile user2) {
    if (user1.interests.isEmpty || user2.interests.isEmpty) {
      return 0.5; // 中性分數
    }

    final user1InterestIds = user1.interests.map((i) => i.id).toSet();
    final user2InterestIds = user2.interests.map((i) => i.id).toSet();
    
    final commonInterests = user1InterestIds.intersection(user2InterestIds);
    final totalInterests = user1InterestIds.union(user2InterestIds);
    
    if (totalInterests.isEmpty) return 0.5;
    
    // Jaccard 相似度
    final jaccardSimilarity = commonInterests.length / totalInterests.length;
    
    // 考慮興趣類別的相似性
    final categorySimilarity = _calculateCategorySimilarity(user1, user2);
    
    // 綜合評分
    return (jaccardSimilarity * 0.7 + categorySimilarity * 0.3).clamp(0.0, 1.0);
  }

  /// 計算興趣類別相似性
  static double _calculateCategorySimilarity(Profile user1, Profile user2) {
    final user1Categories = user1.interests.map((i) => i.category).toSet();
    final user2Categories = user2.interests.map((i) => i.category).toSet();
    
    final commonCategories = user1Categories.intersection(user2Categories);
    final totalCategories = user1Categories.union(user2Categories);
    
    if (totalCategories.isEmpty) return 0.5;
    
    return commonCategories.length / totalCategories.length;
  }

  /// 計算生活方式相容性
  static double _calculateLifestyleCompatibility(Profile user1, Profile user2) {
    double score = 0;
    int factors = 0;

    final lifestyle1 = user1.lifestylePreferences;
    final lifestyle2 = user2.lifestylePreferences;

    // 吸煙習慣
    if (_isLifestyleCompatible(lifestyle1.smoking.index, lifestyle2.smoking.index)) {
      score += 1;
    }
    factors++;

    // 飲酒習慣
    if (_isLifestyleCompatible(lifestyle1.drinking.index, lifestyle2.drinking.index)) {
      score += 1;
    }
    factors++;

    // 運動頻率
    if (_isLifestyleCompatible(lifestyle1.exercise.index, lifestyle2.exercise.index)) {
      score += 1;
    }
    factors++;

    // 寵物偏好
    if (_isPetCompatible(lifestyle1.pets, lifestyle2.pets)) {
      score += 1;
    }
    factors++;

    // 子女意願
    if (lifestyle1.wantsChildren == lifestyle2.wantsChildren) {
      score += 1;
    }
    factors++;

    return factors > 0 ? score / factors : 0.5;
  }

  /// 檢查生活方式是否相容
  static bool _isLifestyleCompatible(int value1, int value2) {
    // 允許1級差異
    return (value1 - value2).abs() <= 1;
  }

  /// 檢查寵物偏好是否相容
  static bool _isPetCompatible(PetPreference pet1, PetPreference pet2) {
    // 如果一方過敏，另一方必須不愛寵物
    if (pet1 == PetPreference.allergic) {
      return pet2 == PetPreference.dislikePets || pet2 == PetPreference.noPreference;
    }
    if (pet2 == PetPreference.allergic) {
      return pet1 == PetPreference.dislikePets || pet1 == PetPreference.noPreference;
    }
    
    // 其他情況相對寬鬆
    return true;
  }

  /// 計算年齡相容性
  static double _calculateAgeCompatibility(Profile user1, Profile user2) {
    final age1 = user1.age;
    final age2 = user2.age;
    
    final ageDifference = (age1 - age2).abs();
    
    // 年齡差異評分曲線
    if (ageDifference <= 2) return 1.0;
    if (ageDifference <= 5) return 0.9;
    if (ageDifference <= 8) return 0.7;
    if (ageDifference <= 12) return 0.5;
    if (ageDifference <= 15) return 0.3;
    return 0.1;
  }

  /// 生成匹配詳情
  static MatchDetails generateMatchDetails(
    Profile user1,
    Profile user2,
    MbtiResult? user1Mbti,
    MbtiResult? user2Mbti,
    ValuesAssessment? user1Values,
    ValuesAssessment? user2Values,
  ) {
    final mbtiCompatibility = user1Mbti != null && user2Mbti != null
        ? _calculateMbtiCompatibility(user1Mbti, user2Mbti)
        : 0.5;
    
    final valuesCompatibility = user1Values != null && user2Values != null
        ? user1Values.getCompatibilityScore(user2Values)
        : 0.5;
    
    final interestsCompatibility = _calculateInterestsCompatibility(user1, user2);
    final lifestyleCompatibility = _calculateLifestyleCompatibility(user1, user2);
    final locationCompatibility = _calculateLocationCompatibility(user1, user2);
    
    final commonInterests = _getCommonInterests(user1, user2);
    final compatibilityReasons = _generateCompatibilityReasons(
      user1, user2, user1Mbti, user2Mbti, user1Values, user2Values,
    );

    return MatchDetails(
      mbtiCompatibility: mbtiCompatibility,
      valuesCompatibility: valuesCompatibility,
      interestsCompatibility: interestsCompatibility,
      lifestyleCompatibility: lifestyleCompatibility,
      locationCompatibility: locationCompatibility,
      commonInterests: commonInterests,
      compatibilityReasons: compatibilityReasons,
    );
  }

  /// 計算地理位置相容性
  static double _calculateLocationCompatibility(Profile user1, Profile user2) {
    // 簡化實現 - 實際應該使用地理位置計算
    if (user1.location == user2.location) {
      return 1.0;
    }
    
    // 香港地區相容性
    final hkRegions = {
      '香港島': ['中環', '銅鑼灣', '灣仔', '北角', '太古', '西環'],
      '九龍': ['尖沙咀', '旺角', '油麻地', '佐敦', '紅磡', '九龍塘'],
      '新界': ['沙田', '大埔', '元朗', '屯門', '荃灣', '將軍澳'],
    };
    
    String? user1Region;
    String? user2Region;
    
    for (final region in hkRegions.entries) {
      if (region.value.any((area) => user1.location.contains(area))) {
        user1Region = region.key;
      }
      if (region.value.any((area) => user2.location.contains(area))) {
        user2Region = region.key;
      }
    }
    
    if (user1Region == user2Region) {
      return 0.8;
    }
    
    return 0.6; // 不同地區但仍在香港
  }

  /// 獲取共同興趣
  static List<String> _getCommonInterests(Profile user1, Profile user2) {
    final user1InterestIds = user1.interests.map((i) => i.id).toSet();
    final user2InterestIds = user2.interests.map((i) => i.id).toSet();
    
    final commonInterestIds = user1InterestIds.intersection(user2InterestIds);
    
    return user1.interests
        .where((interest) => commonInterestIds.contains(interest.id))
        .map((interest) => interest.name)
        .toList();
  }

  /// 生成相容性原因
  static List<String> _generateCompatibilityReasons(
    Profile user1,
    Profile user2,
    MbtiResult? user1Mbti,
    MbtiResult? user2Mbti,
    ValuesAssessment? user1Values,
    ValuesAssessment? user2Values,
  ) {
    final reasons = <String>[];

    // MBTI 相容性原因
    if (user1Mbti != null && user2Mbti != null) {
      if (user1Mbti.type == user2Mbti.type) {
        reasons.add('你們有相同的 MBTI 性格類型 (${user1Mbti.type})');
      } else {
        final compatibility = _calculateMbtiCompatibility(user1Mbti, user2Mbti);
        if (compatibility > 0.8) {
          reasons.add('你們的 MBTI 性格類型非常相配');
        }
      }
    }

    // 價值觀相容性原因
    if (user1Values != null && user2Values != null) {
      final topValues1 = user1Values.topValues;
      final topValues2 = user2Values.topValues;
      final commonValues = topValues1.toSet().intersection(topValues2.toSet());
      
      if (commonValues.isNotEmpty) {
        final valueNames = commonValues.map((v) => v.displayName).join('、');
        reasons.add('你們都重視：$valueNames');
      }
    }

    // 興趣相容性原因
    final commonInterests = _getCommonInterests(user1, user2);
    if (commonInterests.isNotEmpty) {
      if (commonInterests.length >= 3) {
        reasons.add('你們有 ${commonInterests.length} 個共同興趣');
      } else {
        reasons.add('你們都喜歡：${commonInterests.join('、')}');
      }
    }

    // 生活方式相容性原因
    final lifestyle1 = user1.lifestylePreferences;
    final lifestyle2 = user2.lifestylePreferences;
    
    if (lifestyle1.exercise == lifestyle2.exercise) {
      reasons.add('你們有相似的運動習慣');
    }
    
    if (lifestyle1.wantsChildren == lifestyle2.wantsChildren) {
      final wantsChildren = lifestyle1.wantsChildren ? '都想要' : '都不想要';
      reasons.add('你們對於孩子的想法一致（$wantsChildren孩子）');
    }

    // 年齡相容性原因
    final ageDifference = (user1.age - user2.age).abs();
    if (ageDifference <= 3) {
      reasons.add('你們年齡相近');
    }

    return reasons;
  }

  /// 檢查用戶是否符合匹配偏好
  static bool meetsMatchingCriteria(
    Profile candidate,
    Profile currentUser,
    MatchingPreferences preferences,
  ) {
    // 年齡檢查
    if (candidate.age < preferences.minAge || candidate.age > preferences.maxAge) {
      return false;
    }

    // 性別偏好檢查
    if (!preferences.preferredGenders.contains(candidate.gender.name)) {
      return false;
    }

    // Deal breakers 檢查
    for (final dealBreaker in preferences.dealBreakers) {
      if (_hasDealBreaker(candidate, dealBreaker)) {
        return false;
      }
    }

    // 驗證狀態檢查
    if (preferences.onlyShowVerified) {
      // 這裡應該檢查用戶的驗證狀態
      // if (!candidate.isVerified) return false;
    }

    return true;
  }

  /// 檢查是否有 deal breaker
  static bool _hasDealBreaker(Profile candidate, String dealBreaker) {
    switch (dealBreaker) {
      case 'smoking':
        return candidate.lifestylePreferences.smoking == SmokingHabit.regularly;
      case 'drinking':
        return candidate.lifestylePreferences.drinking == DrinkingHabit.regularly;
      case 'has_children':
        return candidate.lifestylePreferences.hasChildren;
      case 'wants_children':
        return candidate.lifestylePreferences.wantsChildren;
      default:
        return false;
    }
  }
} 