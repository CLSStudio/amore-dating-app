import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/firebase_config.dart';

// MBTI 兼容性服務提供者
final mbtiCompatibilityServiceProvider = Provider<MBTICompatibilityService>((ref) {
  return MBTICompatibilityService();
});

// 用戶配對數據模型
class UserMatchData {
  final String userId;
  final String name;
  final int age;
  final String gender;
  final String mbtiType;
  final List<String> interests;
  final List<String> values;
  final String location;
  final List<String> photoUrls;
  final String bio;
  final DateTime lastActive;

  UserMatchData({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.mbtiType,
    required this.interests,
    required this.values,
    required this.location,
    required this.photoUrls,
    required this.bio,
    required this.lastActive,
  });

  factory UserMatchData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // 提取照片 URLs
    final photos = List<Map<String, dynamic>>.from(data['photos'] ?? []);
    final photoUrls = photos.map((photo) => photo['url'] as String).toList();
    
    return UserMatchData(
      userId: doc.id,
      name: data['displayName'] ?? '',
      age: data['age'] ?? 25,
      gender: data['gender'] ?? '',
      mbtiType: data['mbtiType'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      values: List<String>.from(data['values'] ?? []),
      location: data['location'] ?? '',
      photoUrls: photoUrls,
      bio: data['bio'] ?? '',
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// 配對結果模型
class MatchResult {
  final UserMatchData user;
  final double compatibilityScore;
  final Map<String, double> compatibilityBreakdown;
  final List<String> commonInterests;
  final List<String> commonValues;
  final String compatibilityReason;

  MatchResult({
    required this.user,
    required this.compatibilityScore,
    required this.compatibilityBreakdown,
    required this.commonInterests,
    required this.commonValues,
    required this.compatibilityReason,
  });
}

class MBTICompatibilityService {
  // MBTI 類型兼容性矩陣（基於心理學研究）
  static const Map<String, Map<String, double>> _mbtiCompatibilityMatrix = {
    'ENFP': {
      'INTJ': 0.95, 'INFJ': 0.90, 'ENFJ': 0.85, 'ENTP': 0.80,
      'ENFP': 0.75, 'INFP': 0.85, 'INTP': 0.80, 'ENTJ': 0.75,
      'ISFJ': 0.70, 'ESFJ': 0.65, 'ISFP': 0.75, 'ESFP': 0.70,
      'ISTJ': 0.60, 'ESTJ': 0.55, 'ISTP': 0.65, 'ESTP': 0.60,
    },
    'INTJ': {
      'ENFP': 0.95, 'ENTP': 0.90, 'INFP': 0.85, 'ENFJ': 0.80,
      'INTJ': 0.75, 'INFJ': 0.85, 'ENTJ': 0.80, 'INTP': 0.75,
      'ISFP': 0.70, 'ESFP': 0.65, 'ISFJ': 0.60, 'ESFJ': 0.55,
      'ISTP': 0.65, 'ESTP': 0.60, 'ISTJ': 0.70, 'ESTJ': 0.65,
    },
    'INFJ': {
      'ENFP': 0.90, 'ENTP': 0.85, 'INFP': 0.80, 'ENFJ': 0.75,
      'INTJ': 0.85, 'INFJ': 0.70, 'ENTJ': 0.75, 'INTP': 0.80,
      'ISFP': 0.75, 'ESFP': 0.70, 'ISFJ': 0.65, 'ESFJ': 0.60,
      'ISTP': 0.60, 'ESTP': 0.55, 'ISTJ': 0.65, 'ESTJ': 0.60,
    },
    'ENFJ': {
      'INFP': 0.90, 'ISFP': 0.85, 'ENFP': 0.85, 'INFJ': 0.75,
      'ENFJ': 0.70, 'INTJ': 0.80, 'ENTP': 0.75, 'INTP': 0.70,
      'ISFJ': 0.80, 'ESFJ': 0.75, 'ESFP': 0.75, 'ISTP': 0.65,
      'ESTP': 0.70, 'ISTJ': 0.60, 'ESTJ': 0.65, 'ENTJ': 0.65,
    },
    // 添加其他 MBTI 類型的兼容性數據...
    // 為了簡化，這裡只展示部分數據
  };

  // 計算兩個用戶的整體兼容性
  Future<MatchResult> calculateCompatibility(
    UserMatchData currentUser,
    UserMatchData potentialMatch,
  ) async {
    // 1. MBTI 兼容性 (40% 權重)
    final mbtiScore = _calculateMBTICompatibility(
      currentUser.mbtiType,
      potentialMatch.mbtiType,
    );

    // 2. 興趣相似度 (25% 權重)
    final interestScore = _calculateInterestCompatibility(
      currentUser.interests,
      potentialMatch.interests,
    );

    // 3. 價值觀匹配度 (25% 權重)
    final valueScore = _calculateValueCompatibility(
      currentUser.values,
      potentialMatch.values,
    );

    // 4. 年齡兼容性 (10% 權重)
    final ageScore = _calculateAgeCompatibility(
      currentUser.age,
      potentialMatch.age,
    );

    // 計算加權總分
    final totalScore = (mbtiScore * 0.4) +
                      (interestScore * 0.25) +
                      (valueScore * 0.25) +
                      (ageScore * 0.1);

    // 找出共同興趣和價值觀
    final commonInterests = _findCommonItems(
      currentUser.interests,
      potentialMatch.interests,
    );
    final commonValues = _findCommonItems(
      currentUser.values,
      potentialMatch.values,
    );

    // 生成兼容性說明
    final compatibilityReason = _generateCompatibilityReason(
      currentUser.mbtiType,
      potentialMatch.mbtiType,
      commonInterests,
      commonValues,
      totalScore,
    );

    return MatchResult(
      user: potentialMatch,
      compatibilityScore: totalScore,
      compatibilityBreakdown: {
        'mbti': mbtiScore,
        'interests': interestScore,
        'values': valueScore,
        'age': ageScore,
      },
      commonInterests: commonInterests,
      commonValues: commonValues,
      compatibilityReason: compatibilityReason,
    );
  }

  // 計算 MBTI 兼容性
  double _calculateMBTICompatibility(String type1, String type2) {
    if (type1.isEmpty || type2.isEmpty) return 0.5;

    // 從兼容性矩陣中獲取分數
    final score = _mbtiCompatibilityMatrix[type1]?[type2];
    if (score != null) return score;

    // 如果矩陣中沒有數據，使用基礎計算
    return _calculateBasicMBTICompatibility(type1, type2);
  }

  // 基礎 MBTI 兼容性計算
  double _calculateBasicMBTICompatibility(String type1, String type2) {
    if (type1.length != 4 || type2.length != 4) return 0.5;

    double score = 0.0;
    
    // E/I 維度：相同 +0.2，不同 +0.1
    if (type1[0] == type2[0]) {
      score += 0.2;
    } else {
      score += 0.1; // 互補性也有價值
    }

    // S/N 維度：相同 +0.3，不同 +0.1
    if (type1[1] == type2[1]) {
      score += 0.3;
    } else {
      score += 0.1;
    }

    // T/F 維度：相同 +0.2，不同 +0.15
    if (type1[2] == type2[2]) {
      score += 0.2;
    } else {
      score += 0.15;
    }

    // J/P 維度：相同 +0.2，不同 +0.1
    if (type1[3] == type2[3]) {
      score += 0.2;
    } else {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  // 計算興趣相似度
  double _calculateInterestCompatibility(
    List<String> interests1,
    List<String> interests2,
  ) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.3;

    final commonCount = _findCommonItems(interests1, interests2).length;
    final totalUnique = {...interests1, ...interests2}.length;
    
    // Jaccard 相似度係數
    final jaccardIndex = commonCount / totalUnique;
    
    // 調整分數，確保有共同興趣的用戶得到更高分數
    return (jaccardIndex * 0.7 + (commonCount / interests1.length) * 0.3)
        .clamp(0.0, 1.0);
  }

  // 計算價值觀匹配度
  double _calculateValueCompatibility(
    List<String> values1,
    List<String> values2,
  ) {
    if (values1.isEmpty || values2.isEmpty) return 0.3;

    final commonCount = _findCommonItems(values1, values2).length;
    final maxValues = values1.length > values2.length ? values1.length : values2.length;
    
    // 價值觀匹配比興趣更重要，所以權重更高
    return (commonCount / maxValues * 1.2).clamp(0.0, 1.0);
  }

  // 計算年齡兼容性
  double _calculateAgeCompatibility(int age1, int age2) {
    final ageDiff = (age1 - age2).abs();
    
    // 年齡差距越小，兼容性越高
    if (ageDiff <= 2) return 1.0;
    if (ageDiff <= 5) return 0.8;
    if (ageDiff <= 8) return 0.6;
    if (ageDiff <= 12) return 0.4;
    return 0.2;
  }

  // 找出共同項目
  List<String> _findCommonItems(List<String> list1, List<String> list2) {
    return list1.where((item) => list2.contains(item)).toList();
  }

  // 生成兼容性說明
  String _generateCompatibilityReason(
    String mbtiType1,
    String mbtiType2,
    List<String> commonInterests,
    List<String> commonValues,
    double totalScore,
  ) {
    final reasons = <String>[];

    // MBTI 兼容性說明
    if (mbtiType1.isNotEmpty && mbtiType2.isNotEmpty) {
      final mbtiReason = _getMBTICompatibilityReason(mbtiType1, mbtiType2);
      if (mbtiReason.isNotEmpty) {
        reasons.add(mbtiReason);
      }
    }

    // 共同興趣說明
    if (commonInterests.isNotEmpty) {
      if (commonInterests.length == 1) {
        reasons.add('你們都喜歡${commonInterests.first}');
      } else if (commonInterests.length <= 3) {
        reasons.add('你們都喜歡${commonInterests.join('、')}');
      } else {
        reasons.add('你們有${commonInterests.length}個共同興趣');
      }
    }

    // 共同價值觀說明
    if (commonValues.isNotEmpty) {
      if (commonValues.length == 1) {
        reasons.add('你們都重視${commonValues.first}');
      } else {
        reasons.add('你們有相似的價值觀');
      }
    }

    // 總體評價
    if (totalScore >= 0.8) {
      reasons.add('你們非常匹配！');
    } else if (totalScore >= 0.6) {
      reasons.add('你們很有潛力！');
    } else if (totalScore >= 0.4) {
      reasons.add('你們可以嘗試了解彼此');
    }

    return reasons.join('，');
  }

  // 獲取 MBTI 兼容性說明
  String _getMBTICompatibilityReason(String type1, String type2) {
    // 特殊的高兼容性組合
    final highCompatibilityPairs = {
      'ENFP-INTJ': '你們是經典的互補組合，創意與邏輯的完美結合',
      'INFJ-ENTP': '你們能激發彼此的潛能，深度與廣度的平衡',
      'ISFJ-ESTP': '你們互相補足，穩定與活力的和諧',
      'ENFJ-INFP': '你們都重視情感和價值觀，能深度理解彼此',
    };

    final pair1 = '$type1-$type2';
    final pair2 = '$type2-$type1';

    return highCompatibilityPairs[pair1] ?? 
           highCompatibilityPairs[pair2] ?? 
           '你們的性格類型很匹配';
  }

  // 獲取潛在配對列表
  Future<List<MatchResult>> findPotentialMatches({
    required String currentUserId,
    int limit = 20,
    double minCompatibilityScore = 0.3,
  }) async {
    try {
      // 獲取當前用戶數據
      final currentUserDoc = await FirebaseConfig.usersCollection
          .doc(currentUserId)
          .get();
      
      if (!currentUserDoc.exists) {
        throw Exception('用戶不存在');
      }

      final currentUser = UserMatchData.fromFirestore(currentUserDoc);

      // 獲取已經配對或拒絕的用戶 ID
      final excludedUserIds = await _getExcludedUserIds(currentUserId);
      excludedUserIds.add(currentUserId); // 排除自己

      // 查詢潛在配對用戶
      Query query = FirebaseConfig.usersCollection
          .where('profileCompleted', isEqualTo: true)
          .where('gender', isNotEqualTo: currentUser.gender) // 異性配對
          .limit(limit * 2); // 獲取更多用戶以便篩選

      final querySnapshot = await query.get();
      final potentialUsers = querySnapshot.docs
          .where((doc) => !excludedUserIds.contains(doc.id))
          .map((doc) => UserMatchData.fromFirestore(doc))
          .toList();

      // 計算兼容性並排序
      final matches = <MatchResult>[];
      for (final user in potentialUsers) {
        final matchResult = await calculateCompatibility(currentUser, user);
        if (matchResult.compatibilityScore >= minCompatibilityScore) {
          matches.add(matchResult);
        }
      }

      // 按兼容性分數排序
      matches.sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));

      return matches.take(limit).toList();
    } catch (e) {
      print('獲取潛在配對失敗: $e');
      return [];
    }
  }

  // 獲取已排除的用戶 ID（已配對、已拒絕等）
  Future<Set<String>> _getExcludedUserIds(String userId) async {
    try {
      final matchesQuery = await FirebaseConfig.matchesCollection
          .where('users', arrayContains: userId)
          .get();

      final excludedIds = <String>{};
      for (final doc in matchesQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final users = List<String>.from(data['users'] ?? []);
        excludedIds.addAll(users);
      }

      return excludedIds;
    } catch (e) {
      print('獲取已排除用戶失敗: $e');
      return <String>{};
    }
  }

  // 記錄配對動作（喜歡/不喜歡）
  Future<bool> recordMatchAction({
    required String currentUserId,
    required String targetUserId,
    required bool isLike,
  }) async {
    try {
      final matchId = _generateMatchId(currentUserId, targetUserId);
      
      // 檢查是否已經有配對記錄
      final existingMatch = await FirebaseConfig.matchesCollection
          .doc(matchId)
          .get();

      if (existingMatch.exists) {
        final data = existingMatch.data() as Map<String, dynamic>;
        final actions = Map<String, dynamic>.from(data['actions'] ?? {});
        
        // 記錄當前用戶的動作
        actions[currentUserId] = {
          'action': isLike ? 'like' : 'pass',
          'timestamp': DateTime.now(),
        };

        // 檢查是否雙方都喜歡
        final targetAction = actions[targetUserId];
        final isMatch = isLike && 
                       targetAction != null && 
                       targetAction['action'] == 'like';

        await FirebaseConfig.matchesCollection.doc(matchId).update({
          'actions': actions,
          'status': isMatch ? 'matched' : 'pending',
          'lastUpdated': DateTime.now(),
        });

        return isMatch;
      } else {
        // 創建新的配對記錄
        await FirebaseConfig.matchesCollection.doc(matchId).set({
          'users': [currentUserId, targetUserId],
          'actions': {
            currentUserId: {
              'action': isLike ? 'like' : 'pass',
              'timestamp': DateTime.now(),
            },
          },
          'status': 'pending',
          'createdAt': DateTime.now(),
          'lastUpdated': DateTime.now(),
        });

        return false; // 單方面動作不算配對
      }
    } catch (e) {
      print('記錄配對動作失敗: $e');
      return false;
    }
  }

  // 生成配對 ID
  String _generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // 獲取用戶的配對列表
  Future<List<UserMatchData>> getUserMatches(String userId) async {
    try {
      final matchesQuery = await FirebaseConfig.matchesCollection
          .where('users', arrayContains: userId)
          .where('status', isEqualTo: 'matched')
          .get();

      final matchedUserIds = <String>[];
      for (final doc in matchesQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final users = List<String>.from(data['users'] ?? []);
        final otherUserId = users.firstWhere((id) => id != userId);
        matchedUserIds.add(otherUserId);
      }

      // 獲取配對用戶的詳細信息
      final matches = <UserMatchData>[];
      for (final userId in matchedUserIds) {
        final userDoc = await FirebaseConfig.usersCollection.doc(userId).get();
        if (userDoc.exists) {
          matches.add(UserMatchData.fromFirestore(userDoc));
        }
      }

      return matches;
    } catch (e) {
      print('獲取配對列表失敗: $e');
      return [];
    }
  }
} 