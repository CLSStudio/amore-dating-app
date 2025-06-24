import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// 高級匹配服務提供者
final advancedMatchingServiceProvider = Provider<AdvancedMatchingService>((ref) {
  return AdvancedMatchingService();
});

// 匹配結果模型
class MatchResult {
  final String userId;
  final String name;
  final int age;
  final String? profilePhoto;
  final String mbtiType;
  final List<String> interests;
  final double compatibilityScore;
  final double distance;
  final MatchReasons reasons;

  MatchResult({
    required this.userId,
    required this.name,
    required this.age,
    this.profilePhoto,
    required this.mbtiType,
    required this.interests,
    required this.compatibilityScore,
    required this.distance,
    required this.reasons,
  });
}

// 匹配原因分析
class MatchReasons {
  final double mbtiCompatibility;
  final double valueAlignment;
  final double interestOverlap;
  final double ageCompatibility;
  final List<String> sharedInterests;
  final String mbtiExplanation;

  MatchReasons({
    required this.mbtiCompatibility,
    required this.valueAlignment,
    required this.interestOverlap,
    required this.ageCompatibility,
    required this.sharedInterests,
    required this.mbtiExplanation,
  });
}

// 用戶偏好設置
class MatchingPreferences {
  final int minAge;
  final int maxAge;
  final double maxDistance;
  final List<String> dealBreakers;
  final List<String> mustHaves;
  final bool prioritizeMBTI;
  final bool prioritizeValues;

  MatchingPreferences({
    required this.minAge,
    required this.maxAge,
    required this.maxDistance,
    required this.dealBreakers,
    required this.mustHaves,
    this.prioritizeMBTI = true,
    this.prioritizeValues = true,
  });
}

class AdvancedMatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // MBTI 兼容性矩陣（基於心理學研究）
  static const Map<String, Map<String, double>> _mbtiCompatibility = {
    'INTJ': {'ENFP': 0.95, 'ENTP': 0.90, 'INFJ': 0.85, 'INFP': 0.80},
    'INTP': {'ENFJ': 0.95, 'ENTJ': 0.90, 'INFJ': 0.85, 'ENFP': 0.80},
    'ENTJ': {'INFP': 0.95, 'INTP': 0.90, 'ENFJ': 0.85, 'INTJ': 0.80},
    'ENTP': {'INFJ': 0.95, 'INTJ': 0.90, 'ENFJ': 0.85, 'INFP': 0.80},
    'INFJ': {'ENTP': 0.95, 'ENFP': 0.90, 'INTJ': 0.85, 'INTP': 0.80},
    'INFP': {'ENTJ': 0.95, 'ENFJ': 0.90, 'INTJ': 0.85, 'ENTP': 0.80},
    'ENFJ': {'INTP': 0.95, 'INFP': 0.90, 'ENTJ': 0.85, 'ENTP': 0.80},
    'ENFP': {'INTJ': 0.95, 'INFJ': 0.90, 'INTP': 0.85, 'ENTJ': 0.80},
    'ISTJ': {'ESFP': 0.90, 'ESTP': 0.85, 'ISFP': 0.80, 'ESFJ': 0.75},
    'ISFJ': {'ESTP': 0.90, 'ESFP': 0.85, 'ISTJ': 0.80, 'ESTJ': 0.75},
    'ESTJ': {'ISFP': 0.90, 'ISFJ': 0.85, 'ISTJ': 0.80, 'ESFJ': 0.75},
    'ESFJ': {'ISTP': 0.90, 'ISFP': 0.85, 'ISTJ': 0.80, 'ESTJ': 0.75},
    'ISTP': {'ESFJ': 0.90, 'ESTJ': 0.85, 'ISFJ': 0.80, 'ESFP': 0.75},
    'ISFP': {'ESTJ': 0.90, 'ESFJ': 0.85, 'ISTJ': 0.80, 'ESTP': 0.75},
    'ESTP': {'ISFJ': 0.90, 'ISTJ': 0.85, 'ISFP': 0.80, 'ESFJ': 0.75},
    'ESFP': {'ISTJ': 0.90, 'ISFJ': 0.85, 'ISTP': 0.80, 'ESTJ': 0.75},
  };

  /// 獲取智能匹配推薦
  static Future<List<MatchResult>> getSmartMatches({
    int limit = 20,
    MatchingPreferences? preferences,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('用戶未登入');

      // 獲取當前用戶資料
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (!userDoc.exists) throw Exception('用戶資料不存在');
      
      final userData = userDoc.data()!;
      final userMBTI = userData['mbtiType'] as String?;
      final userAge = userData['age'] as int?;
      final userGender = userData['gender'] as String?;
      final userInterests = List<String>.from(userData['interests'] ?? []);
      final userValues = List<String>.from(userData['values'] ?? []);
      final userLocation = userData['location'] as GeoPoint?;

      if (userMBTI == null) throw Exception('請先完成 MBTI 測試');

      // 設置默認偏好
      preferences ??= MatchingPreferences(
        minAge: (userAge ?? 25) - 5,
        maxAge: (userAge ?? 25) + 5,
        maxDistance: 50.0,
        dealBreakers: [],
        mustHaves: [],
      );

      // 獲取潛在匹配用戶
      final potentialMatches = await _getPotentialMatches(
        currentUserId: currentUser.uid,
        userGender: userGender,
        preferences: preferences,
      );

      // 計算兼容性分數
      final matches = <MatchResult>[];
      for (final match in potentialMatches) {
        final matchData = match.data() as Map<String, dynamic>;
        
        final compatibility = await _calculateCompatibility(
          userData: userData,
          matchData: matchData,
          userLocation: userLocation,
        );

        if (compatibility.compatibilityScore >= 0.6) { // 最低兼容性閾值
          matches.add(MatchResult(
            userId: match.id,
            name: matchData['name'] ?? '未知',
            age: matchData['age'] ?? 0,
            profilePhoto: _getMainPhoto(matchData['photos']),
            mbtiType: matchData['mbtiType'] ?? '',
            interests: List<String>.from(matchData['interests'] ?? []),
            compatibilityScore: compatibility.compatibilityScore,
            distance: compatibility.distance,
            reasons: compatibility.reasons,
          ));
        }
      }

      // 按兼容性分數排序
      matches.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
      
      return matches.take(limit).toList();
    } catch (e) {
      throw Exception('獲取匹配失敗: $e');
    }
  }

  /// 獲取潛在匹配用戶
  static Future<List<QueryDocumentSnapshot>> _getPotentialMatches({
    required String currentUserId,
    String? userGender,
    required MatchingPreferences preferences,
  }) async {
    Query query = _firestore.collection('users');

    // 排除自己
    query = query.where(FieldPath.documentId, isNotEqualTo: currentUserId);

    // 年齡篩選
    query = query
        .where('age', isGreaterThanOrEqualTo: preferences.minAge)
        .where('age', isLessThanOrEqualTo: preferences.maxAge);

    // 性別篩選（異性戀邏輯，可擴展）
    if (userGender != null) {
      final targetGender = userGender == 'male' ? 'female' : 'male';
      query = query.where('gender', isEqualTo: targetGender);
    }

    // 必須有 MBTI 類型
    query = query.where('mbtiType', isNotEqualTo: null);

    final snapshot = await query.limit(100).get();
    return snapshot.docs;
  }

  /// 計算兼容性分數
  static Future<_CompatibilityResult> _calculateCompatibility({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> matchData,
    GeoPoint? userLocation,
  }) async {
    final userMBTI = userData['mbtiType'] as String;
    final matchMBTI = matchData['mbtiType'] as String;
    final userAge = userData['age'] as int;
    final matchAge = matchData['age'] as int;
    final userInterests = List<String>.from(userData['interests'] ?? []);
    final matchInterests = List<String>.from(matchData['interests'] ?? []);
    final userValues = List<String>.from(userData['values'] ?? []);
    final matchValues = List<String>.from(matchData['values'] ?? []);
    final matchLocation = matchData['location'] as GeoPoint?;

    // 1. MBTI 兼容性 (40% 權重)
    final mbtiScore = _calculateMBTICompatibility(userMBTI, matchMBTI);

    // 2. 價值觀匹配 (25% 權重)
    final valueScore = _calculateValueAlignment(userValues, matchValues);

    // 3. 興趣重疊 (20% 權重)
    final interestScore = _calculateInterestOverlap(userInterests, matchInterests);

    // 4. 年齡兼容性 (10% 權重)
    final ageScore = _calculateAgeCompatibility(userAge, matchAge);

    // 5. 地理距離 (5% 權重)
    final distance = await _calculateDistance(userLocation, matchLocation);
    final distanceScore = _calculateDistanceScore(distance);

    // 計算總分
    final totalScore = (mbtiScore * 0.4) +
                      (valueScore * 0.25) +
                      (interestScore * 0.2) +
                      (ageScore * 0.1) +
                      (distanceScore * 0.05);

    // 共同興趣
    final sharedInterests = userInterests
        .where((interest) => matchInterests.contains(interest))
        .toList();

    // MBTI 解釋
    final mbtiExplanation = _getMBTIExplanation(userMBTI, matchMBTI);

    return _CompatibilityResult(
      compatibilityScore: totalScore,
      distance: distance,
      reasons: MatchReasons(
        mbtiCompatibility: mbtiScore,
        valueAlignment: valueScore,
        interestOverlap: interestScore,
        ageCompatibility: ageScore,
        sharedInterests: sharedInterests,
        mbtiExplanation: mbtiExplanation,
      ),
    );
  }

  /// 計算 MBTI 兼容性
  static double _calculateMBTICompatibility(String userMBTI, String matchMBTI) {
    if (userMBTI == matchMBTI) return 0.8; // 相同類型有一定兼容性但不是最高

    final compatibility = _mbtiCompatibility[userMBTI]?[matchMBTI] ?? 0.5;
    return compatibility;
  }

  /// 計算價值觀匹配度
  static double _calculateValueAlignment(List<String> userValues, List<String> matchValues) {
    if (userValues.isEmpty || matchValues.isEmpty) return 0.5;

    final commonValues = userValues
        .where((value) => matchValues.contains(value))
        .length;
    
    final totalValues = (userValues.length + matchValues.length) / 2;
    return (commonValues / totalValues).clamp(0.0, 1.0);
  }

  /// 計算興趣重疊度
  static double _calculateInterestOverlap(List<String> userInterests, List<String> matchInterests) {
    if (userInterests.isEmpty || matchInterests.isEmpty) return 0.3;

    final commonInterests = userInterests
        .where((interest) => matchInterests.contains(interest))
        .length;
    
    final totalInterests = (userInterests.length + matchInterests.length) / 2;
    return (commonInterests / totalInterests).clamp(0.0, 1.0);
  }

  /// 計算年齡兼容性
  static double _calculateAgeCompatibility(int userAge, int matchAge) {
    final ageDiff = (userAge - matchAge).abs();
    if (ageDiff <= 2) return 1.0;
    if (ageDiff <= 5) return 0.8;
    if (ageDiff <= 10) return 0.6;
    if (ageDiff <= 15) return 0.4;
    return 0.2;
  }

  /// 計算地理距離
  static Future<double> _calculateDistance(GeoPoint? location1, GeoPoint? location2) async {
    if (location1 == null || location2 == null) return 999.0;

    return Geolocator.distanceBetween(
      location1.latitude,
      location1.longitude,
      location2.latitude,
      location2.longitude,
    ) / 1000; // 轉換為公里
  }

  /// 計算距離分數
  static double _calculateDistanceScore(double distance) {
    if (distance <= 5) return 1.0;
    if (distance <= 15) return 0.8;
    if (distance <= 30) return 0.6;
    if (distance <= 50) return 0.4;
    return 0.2;
  }

  /// 獲取主要照片
  static String? _getMainPhoto(dynamic photos) {
    if (photos is List && photos.isNotEmpty) {
      return photos[0] as String?;
    }
    return null;
  }

  /// 獲取 MBTI 兼容性解釋
  static String _getMBTIExplanation(String userMBTI, String matchMBTI) {
    final explanations = {
      'INTJ-ENFP': '建築師與活動家：理性與感性的完美平衡，互補性極強',
      'INTP-ENFJ': '思想家與教育家：深度思考與人際關懷的理想組合',
      'ENTJ-INFP': '指揮官與調停者：領導力與創造力的動態平衡',
      'ENTP-INFJ': '辯論家與提倡者：創新思維與深度洞察的結合',
    };

    final key1 = '$userMBTI-$matchMBTI';
    final key2 = '$matchMBTI-$userMBTI';
    
    return explanations[key1] ?? explanations[key2] ?? '你們的性格類型具有良好的互補性';
  }

  /// 獲取每日推薦
  static Future<List<MatchResult>> getDailyRecommendations() async {
    return await getSmartMatches(limit: 10);
  }

  /// 獲取高兼容性匹配
  static Future<List<MatchResult>> getHighCompatibilityMatches() async {
    final matches = await getSmartMatches(limit: 50);
    return matches.where((match) => match.compatibilityScore >= 0.8).toList();
  }

  /// 保存匹配偏好
  static Future<void> saveMatchingPreferences(MatchingPreferences preferences) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('用戶未登入');

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .update({
      'matchingPreferences': {
        'minAge': preferences.minAge,
        'maxAge': preferences.maxAge,
        'maxDistance': preferences.maxDistance,
        'dealBreakers': preferences.dealBreakers,
        'mustHaves': preferences.mustHaves,
        'prioritizeMBTI': preferences.prioritizeMBTI,
        'prioritizeValues': preferences.prioritizeValues,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// 內部兼容性結果類
class _CompatibilityResult {
  final double compatibilityScore;
  final double distance;
  final MatchReasons reasons;

  _CompatibilityResult({
    required this.compatibilityScore,
    required this.distance,
    required this.reasons,
  });
} 