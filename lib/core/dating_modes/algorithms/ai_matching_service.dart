import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mode_profile.dart';
import '../../models/user_model.dart';
import '../../../features/dating/modes/dating_mode_system.dart';
import 'matching_algorithms.dart';

/// 🤖 Amore AI配對服務
/// 提供智能匹配、機器學習推薦和實時優化
class AIMatchingService {
  static final AIMatchingService _instance = AIMatchingService._internal();
  factory AIMatchingService() => _instance;
  AIMatchingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<DatingMode, MatchingAlgorithm> _algorithms = {
    DatingMode.serious: SeriousMatchingAlgorithm(),
    DatingMode.explore: ExploreMatchingAlgorithm(),
    DatingMode.passion: PassionMatchingAlgorithm(),
  };

  /// 🎯 智能推薦用戶列表
  Future<List<UserModel>> getSmartRecommendations({
    required String userId,
    required DatingMode mode,
    int limit = 10,
    double minCompatibility = 0.6,
  }) async {
    try {
      // 獲取當前用戶資料
      final currentUser = await _getUserModel(userId);
      if (currentUser == null) return [];

      // 獲取候選用戶池
      final candidates = await _getCandidatePool(mode, userId);
      
      // 計算相容性分數並排序
      final scoredCandidates = <({UserModel user, double score})>[];
      
      for (final candidate in candidates) {
        final score = await _algorithms[mode]!.calculateCompatibility(currentUser, candidate);
        if (score >= minCompatibility) {
          scoredCandidates.add((user: candidate, score: score));
        }
      }

      // 按分數排序並返回top候選人
      scoredCandidates.sort((a, b) => b.score.compareTo(a.score));
      
      return scoredCandidates
          .take(limit)
          .map((candidate) => candidate.user)
          .toList();

    } catch (e) {
      debugPrint('AI推薦服務錯誤: $e');
      return [];
    }
  }

  /// 🧠 MBTI相容性深度分析
  Future<MBTICompatibilityAnalysis> analyzeMBTICompatibility(String mbti1, String mbti2) async {
    final analysis = MBTICompatibilityAnalysis(
      mbti1: mbti1,
      mbti2: mbti2,
      overallScore: 0.0,
      dimensionScores: {},
      strengths: [],
      challenges: [],
      advice: [],
    );

    try {
      // 分解MBTI類型
      final dimensions1 = _parseMBTI(mbti1);
      final dimensions2 = _parseMBTI(mbti2);

      if (dimensions1 == null || dimensions2 == null) {
        analysis.overallScore = 0.5;
        analysis.advice.add('無法解析MBTI類型，建議重新測試');
        return analysis;
      }

      // 分析各維度相容性
      analysis.dimensionScores = {
        'energy': _analyzeEnergyDimension(dimensions1[0], dimensions2[0]),      // E/I
        'information': _analyzeInformationDimension(dimensions1[1], dimensions2[1]), // S/N
        'decision': _analyzeDecisionDimension(dimensions1[2], dimensions2[2]),  // T/F
        'lifestyle': _analyzeLifestyleDimension(dimensions1[3], dimensions2[3]), // J/P
      };

      // 計算總體分數
      analysis.overallScore = analysis.dimensionScores.values.reduce((a, b) => a + b) / 4;

      // 生成優勢和挑戰
      analysis.strengths = _generateStrengths(mbti1, mbti2, analysis.dimensionScores);
      analysis.challenges = _generateChallenges(mbti1, mbti2, analysis.dimensionScores);
      analysis.advice = _generateAdvice(mbti1, mbti2, analysis.overallScore);

    } catch (e) {
      debugPrint('MBTI分析錯誤: $e');
      analysis.overallScore = 0.5;
    }

    return analysis;
  }

  /// 🎨 興趣匹配演算法
  Future<InterestMatchingResult> analyzeInterestCompatibility(
    List<String> interests1, 
    List<String> interests2,
  ) async {
    final result = InterestMatchingResult(
      overlapScore: 0.0,
      sharedInterests: [],
      complementaryInterests: [],
      suggestions: [],
    );

    try {
      if (interests1.isEmpty || interests2.isEmpty) {
        result.suggestions.add('建議完善個人興趣資料以獲得更好的匹配');
        return result;
      }

      // 計算直接重疊
      final overlap = interests1.toSet().intersection(interests2.toSet());
      final union = interests1.toSet().union(interests2.toSet());
      
      result.sharedInterests = overlap.toList();
      result.overlapScore = union.isEmpty ? 0.0 : overlap.length / union.length;

      // 分析互補興趣
      result.complementaryInterests = _findComplementaryInterests(interests1, interests2);

      // 計算加權分數（考慮互補性）
      final complementaryBonus = result.complementaryInterests.length * 0.05;
      result.overlapScore = (result.overlapScore + complementaryBonus).clamp(0.0, 1.0);

      // 生成活動建議
      result.suggestions = _generateInterestBasedSuggestions(result.sharedInterests, result.complementaryInterests);

    } catch (e) {
      debugPrint('興趣匹配分析錯誤: $e');
    }

    return result;
  }

  /// 💎 價值觀對齊評估
  Future<ValueAlignmentResult> analyzeValueAlignment(
    List<String> values1,
    List<String> values2,
  ) async {
    final result = ValueAlignmentResult(
      alignmentScore: 0.0,
      sharedValues: [],
      conflictingValues: [],
      recommendations: [],
    );

    try {
      if (values1.isEmpty || values2.isEmpty) {
        result.recommendations.add('建議完成價值觀評估問卷');
        return result;
      }

      // 核心價值觀權重
      final coreValueWeights = {
        '誠實守信': 1.5,
        '家庭第一': 1.4,
        '責任感': 1.3,
        '事業心': 1.2,
        '自由獨立': 1.1,
      };

      // 計算加權對齊分數
      double totalWeight = 0.0;
      double alignedWeight = 0.0;

      final overlap = values1.toSet().intersection(values2.toSet());
      result.sharedValues = overlap.toList();

      for (final value in values1.toSet().union(values2.toSet())) {
        final weight = coreValueWeights[value] ?? 1.0;
        totalWeight += weight;
        
        if (overlap.contains(value)) {
          alignedWeight += weight;
        }
      }

      result.alignmentScore = totalWeight > 0 ? alignedWeight / totalWeight : 0.0;

      // 識別潛在衝突
      result.conflictingValues = _identifyValueConflicts(values1, values2);

      // 生成建議
      result.recommendations = _generateValueAlignmentRecommendations(
        result.alignmentScore,
        result.sharedValues,
        result.conflictingValues,
      );

    } catch (e) {
      debugPrint('價值觀對齊分析錯誤: $e');
    }

    return result;
  }

  /// 📍 即時位置匹配
  Future<LocationMatchResult> findNearbyMatches({
    required String userId,
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    final result = LocationMatchResult(
      nearbyUsers: [],
      distanceMap: {},
      suggestions: [],
    );

    try {
      // 查詢附近的激情模式用戶
      final nearbyUsers = await _queryNearbyUsers(latitude, longitude, radiusKm);
      
      // 計算距離並排序（模擬實現）
      for (final user in nearbyUsers) {
        if (user.uid == userId) continue; // 排除自己
        
        // 由於location是String，使用模擬距離計算
        final distance = await _calculateDistanceFromString(
          latitude, longitude,
          user.location,
        );
        
        result.distanceMap[user.uid] = distance;
      }

      // 按距離排序
      result.nearbyUsers = nearbyUsers
          .where((user) => user.uid != userId)
          .toList()
        ..sort((a, b) {
          final distA = result.distanceMap[a.uid] ?? double.infinity;
          final distB = result.distanceMap[b.uid] ?? double.infinity;
          return distA.compareTo(distB);
        });

      result.nearbyUsers = result.nearbyUsers.take(limit).toList();

      // 生成位置建議
      result.suggestions = _generateLocationSuggestions(result.nearbyUsers.length, radiusKm);

    } catch (e) {
      debugPrint('位置匹配錯誤: $e');
    }

    return result;
  }

  /// 🔄 學習用戶偏好並優化推薦
  Future<void> learnUserPreferences({
    required String userId,
    required DatingMode mode,
    required List<String> likedUserIds,
    required List<String> passedUserIds,
  }) async {
    try {
      final userPrefs = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      Map<String, dynamic> preferences = userPrefs.exists ? userPrefs.data()! : {};
      
      // 更新偏好學習數據
      preferences['${mode.name}_liked'] = likedUserIds;
      preferences['${mode.name}_passed'] = passedUserIds;
      preferences['last_updated'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('user_preferences')
          .doc(userId)
          .set(preferences, SetOptions(merge: true));

      // 分析偏好模式
      await _analyzeUserPatterns(userId, mode, likedUserIds, passedUserIds);

    } catch (e) {
      debugPrint('學習用戶偏好錯誤: $e');
    }
  }

  // ===== 私有輔助方法 =====

  /// 獲取用戶模型
  Future<UserModel?> _getUserModel(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? UserModel.fromMap(doc.data()!) : null;
    } catch (e) {
      debugPrint('獲取用戶資料錯誤: $e');
      return null;
    }
  }

  /// 獲取候選用戶池
  Future<List<UserModel>> _getCandidatePool(DatingMode mode, String currentUserId) async {
    try {
      final poolName = '${mode.name}_pool';
      final snapshot = await _firestore
          .collection(poolName)
          .where('active', isEqualTo: true)
          .limit(100)
          .get();

      final candidates = <UserModel>[];
      for (final doc in snapshot.docs) {
        if (doc.id != currentUserId) {
          final userData = await _firestore.collection('users').doc(doc.id).get();
          if (userData.exists) {
            candidates.add(UserModel.fromMap(userData.data()!));
          }
        }
      }

      return candidates;
    } catch (e) {
      debugPrint('獲取候選用戶池錯誤: $e');
      return [];
    }
  }

  /// 解析MBTI類型
  List<String>? _parseMBTI(String mbti) {
    if (mbti.length != 4) return null;
    
    final chars = mbti.toUpperCase().split('');
    if (!RegExp(r'^[EI][SN][TF][JP]$').hasMatch(mbti.toUpperCase())) return null;
    
    return chars;
  }

  /// 分析能量維度 (E/I)
  double _analyzeEnergyDimension(String dim1, String dim2) {
    if (dim1 == dim2) return 0.8; // 相同能量類型高度兼容
    return 0.6; // 不同能量類型中等兼容
  }

  /// 分析信息維度 (S/N)
  double _analyzeInformationDimension(String dim1, String dim2) {
    if (dim1 == dim2) return 0.9; // 相同信息處理方式非常兼容
    return 0.4; // 不同信息處理方式較低兼容
  }

  /// 分析決策維度 (T/F)
  double _analyzeDecisionDimension(String dim1, String dim2) {
    if (dim1 == dim2) return 0.7; // 相同決策方式良好兼容
    return 0.8; // 不同決策方式反而可能互補
  }

  /// 分析生活方式維度 (J/P)
  double _analyzeLifestyleDimension(String dim1, String dim2) {
    if (dim1 == dim2) return 0.8; // 相同生活方式高度兼容
    return 0.5; // 不同生活方式中等兼容
  }

  /// 生成MBTI優勢
  List<String> _generateStrengths(String mbti1, String mbti2, Map<String, double> scores) {
    final strengths = <String>[];
    
    if (scores['energy']! > 0.7) {
      strengths.add('能量互補良好，能夠平衡彼此的社交需求');
    }
    if (scores['information']! > 0.8) {
      strengths.add('思維方式相似，容易理解彼此的觀點');
    }
    if (scores['decision']! > 0.7) {
      strengths.add('決策方式兼容，能夠有效溝通和協作');
    }
    if (scores['lifestyle']! > 0.7) {
      strengths.add('生活節奏相配，能夠和諧共處');
    }

    return strengths;
  }

  /// 生成MBTI挑戰
  List<String> _generateChallenges(String mbti1, String mbti2, Map<String, double> scores) {
    final challenges = <String>[];
    
    if (scores['information']! < 0.5) {
      challenges.add('思維方式差異較大，需要耐心理解對方的觀點');
    }
    if (scores['decision']! < 0.5) {
      challenges.add('決策偏好不同，需要學會包容和妥協');
    }
    if (scores['lifestyle']! < 0.6) {
      challenges.add('生活節奏不同，需要找到平衡點');
    }

    return challenges;
  }

  /// 生成MBTI建議
  List<String> _generateAdvice(String mbti1, String mbti2, double overallScore) {
    final advice = <String>[];
    
    if (overallScore > 0.8) {
      advice.add('你們的MBTI匹配度很高，是很好的配對！');
      advice.add('保持開放溝通，發揮各自的優勢');
    } else if (overallScore > 0.6) {
      advice.add('你們有不錯的兼容性，多花時間了解彼此');
      advice.add('尊重差異，將不同視為學習機會');
    } else {
      advice.add('你們的性格差異較大，需要更多理解和包容');
      advice.add('專注於共同興趣和價值觀，而非性格差異');
    }

    return advice;
  }

  /// 查找互補興趣
  List<String> _findComplementaryInterests(List<String> interests1, List<String> interests2) {
    final complementaryPairs = {
      '運動健身': ['瑜伽冥想', '健康飲食'],
      '音樂': ['舞蹈', '演唱會'],
      '閱讀': ['寫作', '哲學討論'],
      '旅行': ['攝影', '美食探索'],
      '電影': ['戲劇', '藝術展覽'],
    };

    final complementary = <String>[];
    for (final interest1 in interests1) {
      final complements = complementaryPairs[interest1] ?? [];
      for (final complement in complements) {
        if (interests2.contains(complement) && !complementary.contains(complement)) {
          complementary.add(complement);
        }
      }
    }

    return complementary;
  }

  /// 生成基於興趣的建議
  List<String> _generateInterestBasedSuggestions(List<String> shared, List<String> complementary) {
    final suggestions = <String>[];
    
    if (shared.isNotEmpty) {
      suggestions.add('你們有${shared.length}個共同興趣，可以計劃相關活動');
      
      if (shared.contains('美食')) {
        suggestions.add('推薦一起探索香港不同區域的特色餐廳');
      }
      if (shared.contains('電影')) {
        suggestions.add('可以一起去電影院或在家觀看經典電影');
      }
      if (shared.contains('旅行')) {
        suggestions.add('計劃週末短途旅行或探索香港隱藏景點');
      }
    }

    if (complementary.isNotEmpty) {
      suggestions.add('你們的興趣互補性很好，可以互相學習新事物');
    }

    return suggestions;
  }

  /// 識別價值觀衝突
  List<String> _identifyValueConflicts(List<String> values1, List<String> values2) {
    final conflictPairs = {
      '自由獨立': ['家庭第一'],
      '事業心': ['工作生活平衡'],
      '冒險精神': ['安全穩定'],
      '社交活躍': ['內向安靜'],
    };

    final conflicts = <String>[];
    for (final value1 in values1) {
      final conflictsWith = conflictPairs[value1] ?? [];
      for (final conflict in conflictsWith) {
        if (values2.contains(conflict)) {
          conflicts.add('$value1 vs $conflict');
        }
      }
    }

    return conflicts;
  }

  /// 生成價值觀對齊建議
  List<String> _generateValueAlignmentRecommendations(
    double score,
    List<String> shared,
    List<String> conflicts,
  ) {
    final recommendations = <String>[];
    
    if (score > 0.8) {
      recommendations.add('你們的價值觀高度一致，是建立深度關係的好基礎');
    } else if (score > 0.6) {
      recommendations.add('你們有不錯的價值觀契合度，多溝通深層想法');
    } else {
      recommendations.add('你們的價值觀差異較大，需要開放心態理解對方');
    }

    if (shared.isNotEmpty) {
      recommendations.add('專注於你們共同的價值觀：${shared.join('、')}');
    }

    if (conflicts.isNotEmpty) {
      recommendations.add('討論價值觀差異時保持尊重和理解');
    }

    return recommendations;
  }

  /// 查詢附近用戶
  Future<List<UserModel>> _queryNearbyUsers(double lat, double lng, double radiusKm) async {
    // 簡化的地理查詢實現
    // 實際應用中應該使用地理空間查詢
    try {
      final snapshot = await _firestore
          .collection('passion_pool')
          .where('active', isEqualTo: true)
          .limit(50)
          .get();

      final nearbyUsers = <UserModel>[];
      for (final doc in snapshot.docs) {
        final userData = await _firestore.collection('users').doc(doc.id).get();
        if (userData.exists) {
          final user = UserModel.fromMap(userData.data()!);
          // 由於location是String，模擬距離檢查
          final distance = await _calculateDistanceFromString(lat, lng, user.location);

          if (distance <= radiusKm) {
            nearbyUsers.add(user);
          }
        }
      }

      return nearbyUsers;
    } catch (e) {
      debugPrint('查詢附近用戶錯誤: $e');
      return [];
    }
  }

  /// 計算距離（模擬實現，因為location是String）
  Future<double> _calculateDistanceFromString(double lat, double lng, String? locationString) async {
    // 香港區域距離模擬
    if (locationString == null || locationString.isEmpty) return 999.0;
    
    // 根據區域名稱模擬距離
    final regionDistances = {
      '港島': 2.0,
      '中環': 1.5,
      '銅鑼灣': 3.0,
      '九龍': 5.0,
      '尖沙咀': 4.5,
      '旺角': 6.0,
      '新界': 15.0,
      '沙田': 12.0,
      '荃灣': 18.0,
    };

    // 尋找匹配的區域
    for (final region in regionDistances.keys) {
      if (locationString.contains(region)) {
        return regionDistances[region]!;
      }
    }

    // 預設距離
    return 8.0;
  }

  /// 生成位置建議
  List<String> _generateLocationSuggestions(int nearbyCount, double radius) {
    final suggestions = <String>[];
    
    if (nearbyCount == 0) {
      suggestions.add('附近沒有找到其他用戶，試試擴大搜索範圍');
    } else if (nearbyCount < 5) {
      suggestions.add('附近用戶較少，考慮前往熱門區域如中環、銅鑼灣');
    } else {
      suggestions.add('附近有$nearbyCount位用戶，是很好的社交機會');
    }

    return suggestions;
  }

  /// 分析用戶模式
  Future<void> _analyzeUserPatterns(
    String userId,
    DatingMode mode,
    List<String> liked,
    List<String> passed,
  ) async {
    // 分析用戶偏好模式，用於優化future推薦
    // 這裡可以實現機器學習邏輯
    try {
      final patterns = {
        'like_rate': liked.length / (liked.length + passed.length),
        'mode': mode.name,
        'analyzed_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('user_patterns')
          .doc(userId)
          .set(patterns, SetOptions(merge: true));
    } catch (e) {
      debugPrint('分析用戶模式錯誤: $e');
    }
  }
}

/// 🧠 MBTI相容性分析結果
class MBTICompatibilityAnalysis {
  final String mbti1;
  final String mbti2;
  double overallScore;
  Map<String, double> dimensionScores;
  List<String> strengths;
  List<String> challenges;
  List<String> advice;

  MBTICompatibilityAnalysis({
    required this.mbti1,
    required this.mbti2,
    required this.overallScore,
    required this.dimensionScores,
    required this.strengths,
    required this.challenges,
    required this.advice,
  });
}

/// 🎨 興趣匹配結果
class InterestMatchingResult {
  double overlapScore;
  List<String> sharedInterests;
  List<String> complementaryInterests;
  List<String> suggestions;

  InterestMatchingResult({
    required this.overlapScore,
    required this.sharedInterests,
    required this.complementaryInterests,
    required this.suggestions,
  });
}

/// 💎 價值觀對齊結果
class ValueAlignmentResult {
  double alignmentScore;
  List<String> sharedValues;
  List<String> conflictingValues;
  List<String> recommendations;

  ValueAlignmentResult({
    required this.alignmentScore,
    required this.sharedValues,
    required this.conflictingValues,
    required this.recommendations,
  });
}

/// 📍 位置匹配結果
class LocationMatchResult {
  List<UserModel> nearbyUsers;
  Map<String, double> distanceMap;
  List<String> suggestions;

  LocationMatchResult({
    required this.nearbyUsers,
    required this.distanceMap,
    required this.suggestions,
  });
} 