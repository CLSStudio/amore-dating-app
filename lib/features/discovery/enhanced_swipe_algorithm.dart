import 'dart:math' as math;

// 用戶偏好學習模型
class UserPreferenceModel {
  final Map<String, double> mbtiPreferences;
  final Map<String, double> interestWeights;
  final Map<String, double> agePreferences;
  final Map<String, double> locationPreferences;
  final Map<String, double> professionPreferences;
  final Map<String, double> valueWeights;
  final double averageSwipeTime;
  final int totalSwipes;
  final int totalMatches;

  UserPreferenceModel({
    this.mbtiPreferences = const {},
    this.interestWeights = const {},
    this.agePreferences = const {},
    this.locationPreferences = const {},
    this.professionPreferences = const {},
    this.valueWeights = const {},
    this.averageSwipeTime = 3.0,
    this.totalSwipes = 0,
    this.totalMatches = 0,
  });

  UserPreferenceModel copyWith({
    Map<String, double>? mbtiPreferences,
    Map<String, double>? interestWeights,
    Map<String, double>? agePreferences,
    Map<String, double>? locationPreferences,
    Map<String, double>? professionPreferences,
    Map<String, double>? valueWeights,
    double? averageSwipeTime,
    int? totalSwipes,
    int? totalMatches,
  }) {
    return UserPreferenceModel(
      mbtiPreferences: mbtiPreferences ?? this.mbtiPreferences,
      interestWeights: interestWeights ?? this.interestWeights,
      agePreferences: agePreferences ?? this.agePreferences,
      locationPreferences: locationPreferences ?? this.locationPreferences,
      professionPreferences: professionPreferences ?? this.professionPreferences,
      valueWeights: valueWeights ?? this.valueWeights,
      averageSwipeTime: averageSwipeTime ?? this.averageSwipeTime,
      totalSwipes: totalSwipes ?? this.totalSwipes,
      totalMatches: totalMatches ?? this.totalMatches,
    );
  }
}

// 滑動行為數據
class SwipeBehavior {
  final String userId;
  final String targetUserId;
  final bool isLike;
  final double swipeTime;
  final double swipeVelocity;
  final DateTime timestamp;
  final int photoViewCount;
  final bool profileExpanded;

  SwipeBehavior({
    required this.userId,
    required this.targetUserId,
    required this.isLike,
    required this.swipeTime,
    required this.swipeVelocity,
    required this.timestamp,
    this.photoViewCount = 1,
    this.profileExpanded = false,
  });
}

// 增強滑動算法
class EnhancedSwipeAlgorithm {
  static const double _mbtiWeight = 0.25;
  static const double _interestWeight = 0.20;
  static const double _valueWeight = 0.20;
  static const double _ageWeight = 0.15;
  static const double _locationWeight = 0.10;
  static const double _behaviorWeight = 0.10;

  // MBTI 兼容性矩陣
  static const Map<String, Map<String, double>> _mbtiCompatibility = {
    'INTJ': {'ENFP': 0.95, 'ENTP': 0.90, 'INFJ': 0.85, 'INFP': 0.80},
    'INTP': {'ENFJ': 0.95, 'ENTJ': 0.90, 'INFJ': 0.85, 'ENFP': 0.80},
    'ENTJ': {'INFP': 0.95, 'INTP': 0.90, 'ENFJ': 0.85, 'INTJ': 0.80},
    'ENTP': {'INFJ': 0.95, 'INTJ': 0.90, 'ENFJ': 0.85, 'ISFJ': 0.80},
    'INFJ': {'ENTP': 0.95, 'ENFP': 0.90, 'INTJ': 0.85, 'INTP': 0.80},
    'INFP': {'ENTJ': 0.95, 'ENFJ': 0.90, 'INTJ': 0.85, 'ENTP': 0.80},
    'ENFJ': {'INTP': 0.95, 'INFP': 0.90, 'ENTP': 0.85, 'INTJ': 0.80},
    'ENFP': {'INTJ': 0.95, 'INFJ': 0.90, 'INTP': 0.85, 'ENTJ': 0.80},
    'ISTJ': {'ESFP': 0.90, 'ESTP': 0.85, 'ISFP': 0.80, 'ENFP': 0.75},
    'ISFJ': {'ESFP': 0.90, 'ENTP': 0.85, 'ESTP': 0.80, 'ENFP': 0.75},
    'ESTJ': {'ISFP': 0.90, 'ISTP': 0.85, 'ESFP': 0.80, 'INTP': 0.75},
    'ESFJ': {'ISFP': 0.90, 'ISTP': 0.85, 'ESTP': 0.80, 'INFP': 0.75},
    'ISTP': {'ESFJ': 0.90, 'ESTJ': 0.85, 'ENFJ': 0.80, 'ESFP': 0.75},
    'ISFP': {'ESTJ': 0.90, 'ESFJ': 0.85, 'ENTJ': 0.80, 'ENFJ': 0.75},
    'ESTP': {'ISFJ': 0.90, 'ISTJ': 0.85, 'ESFJ': 0.80, 'INFJ': 0.75},
    'ESFP': {'ISTJ': 0.90, 'ISFJ': 0.85, 'ISTP': 0.80, 'INTJ': 0.75},
  };

  // 計算綜合匹配分數
  static double calculateMatchScore({
    required UserProfile currentUser,
    required UserProfile targetUser,
    UserPreferenceModel? preferences,
  }) {
    double mbtiScore = _calculateMBTICompatibility(currentUser.mbtiType, targetUser.mbtiType);
    double interestScore = _calculateInterestCompatibility(currentUser.interests, targetUser.interests);
    double valueScore = _calculateValueCompatibility(currentUser.values, targetUser.values);
    double ageScore = _calculateAgeCompatibility(currentUser.age, targetUser.age);
    double locationScore = _calculateLocationCompatibility(currentUser.location, targetUser.location);
    double behaviorScore = _calculateBehaviorScore(targetUser, preferences);

    // 應用用戶偏好權重
    if (preferences != null) {
      mbtiScore *= _getPreferenceWeight(preferences.mbtiPreferences, targetUser.mbtiType);
      interestScore *= _getAverageInterestWeight(preferences.interestWeights, targetUser.interests);
    }

    double totalScore = (mbtiScore * _mbtiWeight) +
                       (interestScore * _interestWeight) +
                       (valueScore * _valueWeight) +
                       (ageScore * _ageWeight) +
                       (locationScore * _locationWeight) +
                       (behaviorScore * _behaviorWeight);

    return math.min(totalScore * 100, 100.0);
  }

  // MBTI 兼容性計算
  static double _calculateMBTICompatibility(String userMBTI, String targetMBTI) {
    if (userMBTI == targetMBTI) return 0.85; // 相同類型有良好兼容性但不是最高

    final compatibility = _mbtiCompatibility[userMBTI];
    if (compatibility != null && compatibility.containsKey(targetMBTI)) {
      return compatibility[targetMBTI]!;
    }

    // 基於認知功能的基本兼容性
    return _calculateCognitiveFunctionCompatibility(userMBTI, targetMBTI);
  }

  // 認知功能兼容性
  static double _calculateCognitiveFunctionCompatibility(String userMBTI, String targetMBTI) {
    // 提取認知功能偏好
    bool userE = userMBTI.startsWith('E');
    bool userS = userMBTI[1] == 'S';
    bool userT = userMBTI[2] == 'T';
    bool userJ = userMBTI[3] == 'J';

    bool targetE = targetMBTI.startsWith('E');
    bool targetS = targetMBTI[1] == 'S';
    bool targetT = targetMBTI[2] == 'T';
    bool targetJ = targetMBTI[3] == 'J';

    double compatibility = 0.5; // 基礎分數

    // 內外向互補加分
    if (userE != targetE) compatibility += 0.15;

    // 感知功能互補
    if (userS != targetS) compatibility += 0.10;

    // 決策功能平衡
    if (userT == targetT) compatibility += 0.10;

    // 生活方式適配
    if (userJ != targetJ) compatibility += 0.10;

    return math.min(compatibility, 1.0);
  }

  // 興趣兼容性計算
  static double _calculateInterestCompatibility(List<String> userInterests, List<String> targetInterests) {
    if (userInterests.isEmpty || targetInterests.isEmpty) return 0.5;

    Set<String> commonInterests = userInterests.toSet().intersection(targetInterests.toSet());
    double commonRatio = commonInterests.length / math.max(userInterests.length, targetInterests.length);
    
    // 加權常見興趣
    double weightedScore = commonRatio * 0.7;
    
    // 互補興趣加分
    Set<String> complementaryInterests = _findComplementaryInterests(userInterests, targetInterests);
    double complementaryRatio = complementaryInterests.length / userInterests.length;
    weightedScore += complementaryRatio * 0.3;

    return math.min(weightedScore, 1.0);
  }

  // 尋找互補興趣
  static Set<String> _findComplementaryInterests(List<String> userInterests, List<String> targetInterests) {
    Map<String, List<String>> complementaryMap = {
      '音樂': ['舞蹈', '演唱會', '樂器'],
      '運動': ['健身', '瑜伽', '戶外活動'],
      '旅行': ['攝影', '文化', '語言學習'],
      '閱讀': ['寫作', '文學', '哲學'],
      '烹飪': ['美食', '品酒', '園藝'],
      '電影': ['戲劇', '藝術', '攝影'],
      '科技': ['遊戲', '程式設計', '創新'],
    };

    Set<String> complementary = {};
    for (String interest in userInterests) {
      if (complementaryMap.containsKey(interest)) {
        for (String comp in complementaryMap[interest]!) {
          if (targetInterests.contains(comp)) {
            complementary.add(comp);
          }
        }
      }
    }
    return complementary;
  }

  // 價值觀兼容性計算
  static double _calculateValueCompatibility(List<String> userValues, List<String> targetValues) {
    if (userValues.isEmpty || targetValues.isEmpty) return 0.5;

    Set<String> commonValues = userValues.toSet().intersection(targetValues.toSet());
    double commonRatio = commonValues.length / math.max(userValues.length, targetValues.length);
    
    // 核心價值觀權重更高
    List<String> coreValues = ['誠實', '忠誠', '家庭', '成長', '愛'];
    Set<String> commonCoreValues = commonValues.intersection(coreValues.toSet());
    double coreValueBonus = commonCoreValues.length * 0.2;

    return math.min(commonRatio + coreValueBonus, 1.0);
  }

  // 年齡兼容性計算
  static double _calculateAgeCompatibility(int userAge, int targetAge) {
    int ageDiff = (userAge - targetAge).abs();
    
    if (ageDiff <= 2) return 1.0;
    if (ageDiff <= 5) return 0.9;
    if (ageDiff <= 8) return 0.7;
    if (ageDiff <= 12) return 0.5;
    return 0.3;
  }

  // 地理位置兼容性計算
  static double _calculateLocationCompatibility(String userLocation, String targetLocation) {
    if (userLocation == targetLocation) return 1.0;
    
    // 香港地區距離評估
    Map<String, Map<String, double>> locationDistances = {
      '香港島': {'九龍': 0.8, '新界': 0.6},
      '九龍': {'香港島': 0.8, '新界': 0.7},
      '新界': {'香港島': 0.6, '九龍': 0.7},
    };

    return locationDistances[userLocation]?[targetLocation] ?? 0.5;
  }

  // 行為模式分數計算
  static double _calculateBehaviorScore(UserProfile targetUser, UserPreferenceModel? preferences) {
    if (preferences == null) return 0.7;

    double score = 0.7; // 基礎分數

    // 基於歷史匹配成功率調整
    if (preferences.totalSwipes > 0) {
      double matchRate = preferences.totalMatches / preferences.totalSwipes;
      if (matchRate > 0.1) score += 0.1; // 高匹配率用戶加分
    }

    return math.min(score, 1.0);
  }

  // 獲取偏好權重
  static double _getPreferenceWeight(Map<String, double> preferences, String key) {
    return preferences[key] ?? 1.0;
  }

  // 獲取平均興趣權重
  static double _getAverageInterestWeight(Map<String, double> weights, List<String> interests) {
    if (interests.isEmpty) return 1.0;
    
    double totalWeight = 0.0;
    for (String interest in interests) {
      totalWeight += weights[interest] ?? 1.0;
    }
    return totalWeight / interests.length;
  }

  // 更新用戶偏好模型
  static UserPreferenceModel updatePreferences({
    required UserPreferenceModel currentPreferences,
    required SwipeBehavior behavior,
    required UserProfile targetUser,
  }) {
    Map<String, double> newMBTIPreferences = Map.from(currentPreferences.mbtiPreferences);
    Map<String, double> newInterestWeights = Map.from(currentPreferences.interestWeights);
    Map<String, double> newValueWeights = Map.from(currentPreferences.valueWeights);

    // 學習 MBTI 偏好
    double currentWeight = newMBTIPreferences[targetUser.mbtiType] ?? 1.0;
    if (behavior.isLike) {
      newMBTIPreferences[targetUser.mbtiType] = math.min(currentWeight + 0.1, 2.0);
    } else {
      newMBTIPreferences[targetUser.mbtiType] = math.max(currentWeight - 0.05, 0.1);
    }

    // 學習興趣偏好
    for (String interest in targetUser.interests) {
      double currentWeight = newInterestWeights[interest] ?? 1.0;
      if (behavior.isLike) {
        newInterestWeights[interest] = math.min(currentWeight + 0.1, 2.0);
      } else {
        newInterestWeights[interest] = math.max(currentWeight - 0.05, 0.1);
      }
    }

    // 學習價值觀偏好
    for (String value in targetUser.values) {
      double currentWeight = newValueWeights[value] ?? 1.0;
      if (behavior.isLike) {
        newValueWeights[value] = math.min(currentWeight + 0.1, 2.0);
      } else {
        newValueWeights[value] = math.max(currentWeight - 0.05, 0.1);
      }
    }

    // 更新統計數據
    double newAverageSwipeTime = (currentPreferences.averageSwipeTime * currentPreferences.totalSwipes + behavior.swipeTime) / 
                                (currentPreferences.totalSwipes + 1);

    return currentPreferences.copyWith(
      mbtiPreferences: newMBTIPreferences,
      interestWeights: newInterestWeights,
      valueWeights: newValueWeights,
      averageSwipeTime: newAverageSwipeTime,
      totalSwipes: currentPreferences.totalSwipes + 1,
      totalMatches: behavior.isLike ? currentPreferences.totalMatches + 1 : currentPreferences.totalMatches,
    );
  }

  // 生成個性化推薦理由
  static List<String> generateMatchReasons({
    required UserProfile currentUser,
    required UserProfile targetUser,
    UserPreferenceModel? preferences,
  }) {
    List<String> reasons = [];

    // MBTI 兼容性理由
    double mbtiScore = _calculateMBTICompatibility(currentUser.mbtiType, targetUser.mbtiType);
    if (mbtiScore > 0.8) {
      reasons.add('你們的性格類型 ${currentUser.mbtiType} 和 ${targetUser.mbtiType} 非常互補');
    }

    // 共同興趣
    Set<String> commonInterests = currentUser.interests.toSet().intersection(targetUser.interests.toSet());
    if (commonInterests.isNotEmpty) {
      reasons.add('你們都喜歡 ${commonInterests.take(2).join('、')}');
    }

    // 共同價值觀
    Set<String> commonValues = currentUser.values.toSet().intersection(targetUser.values.toSet());
    if (commonValues.isNotEmpty) {
      reasons.add('你們都重視 ${commonValues.take(2).join('、')}');
    }

    // 年齡適配
    int ageDiff = (currentUser.age - targetUser.age).abs();
    if (ageDiff <= 3) {
      reasons.add('你們年齡相近，生活階段相似');
    }

    // 地理位置
    if (currentUser.location == targetUser.location) {
      reasons.add('你們都在 ${currentUser.location}，約會很方便');
    }

    return reasons.take(3).toList();
  }

  // 動態調整推薦池
  static List<UserProfile> optimizeRecommendations({
    required List<UserProfile> candidates,
    required UserProfile currentUser,
    UserPreferenceModel? preferences,
    int limit = 10,
  }) {
    // 計算每個候選人的匹配分數
    List<MapEntry<UserProfile, double>> scoredCandidates = candidates.map((candidate) {
      double score = calculateMatchScore(
        currentUser: currentUser,
        targetUser: candidate,
        preferences: preferences,
      );
      return MapEntry(candidate, score);
    }).toList();

    // 按分數排序
    scoredCandidates.sort((a, b) => b.value.compareTo(a.value));

    // 添加多樣性 - 確保不同類型的用戶都有機會出現
    List<UserProfile> optimizedList = [];
    Set<String> addedMBTITypes = {};
    Set<String> addedProfessions = {};

    // 首先添加高分用戶
    for (var entry in scoredCandidates.take(limit ~/ 2)) {
      optimizedList.add(entry.key);
      addedMBTITypes.add(entry.key.mbtiType);
      addedProfessions.add(entry.key.profession);
    }

    // 然後添加多樣性用戶
    for (var entry in scoredCandidates.skip(limit ~/ 2)) {
      if (optimizedList.length >= limit) break;
      
      bool addForDiversity = false;
      if (!addedMBTITypes.contains(entry.key.mbtiType) && addedMBTITypes.length < 8) {
        addForDiversity = true;
      } else if (!addedProfessions.contains(entry.key.profession) && addedProfessions.length < 6) {
        addForDiversity = true;
      }

      if (addForDiversity || entry.value > 70) {
        optimizedList.add(entry.key);
        addedMBTITypes.add(entry.key.mbtiType);
        addedProfessions.add(entry.key.profession);
      }
    }

    return optimizedList;
  }
}

// 用戶檔案模型（從其他文件導入的話可以移除）
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final String mbtiType;
  final int compatibilityScore;
  final String location;
  final String profession;
  final List<String> values;
  final bool isVerified;
  final String distance;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.mbtiType,
    required this.compatibilityScore,
    required this.location,
    required this.profession,
    required this.values,
    this.isVerified = false,
    this.distance = '2 公里',
  });
} 