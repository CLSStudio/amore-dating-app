import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';
import '../../profile/models/user_profile.dart';
import '../../mbti/services/mbti_service.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MBTIService _mbtiService = MBTIService();

  // 獲取潛在匹配用戶
  Future<List<UserProfile>> getPotentialMatches(String userId, {int limit = 10}) async {
    try {
      // 獲取當前用戶資料
      final currentUser = await _getUserProfile(userId);
      if (currentUser == null) return [];

      // 獲取已經互動過的用戶ID
      final interactedUserIds = await _getInteractedUserIds(userId);
      
      // 查詢潛在匹配用戶
      final query = _firestore
          .collection('users')
          .where('isProfileComplete', isEqualTo: true)
          .limit(limit * 3); // 獲取更多用戶以便篩選

      final snapshot = await query.get();
      final allUsers = snapshot.docs
          .map((doc) => UserProfile.fromJson(doc.data()))
          .where((user) => 
              user.userId != userId && 
              !interactedUserIds.contains(user.userId))
          .toList();

      // 計算兼容性分數並排序
      final scoredUsers = <MapEntry<UserProfile, double>>[];
      for (final user in allUsers) {
        final score = await calculateCompatibilityScore(currentUser, user);
        scoredUsers.add(MapEntry(user, score));
      }

      // 按分數排序並返回前N個
      scoredUsers.sort((a, b) => b.value.compareTo(a.value));
      return scoredUsers
          .take(limit)
          .map((entry) => entry.key)
          .toList();

    } catch (e) {
      throw Exception('獲取潛在匹配失敗: $e');
    }
  }

  // 計算兼容性分數
  Future<double> calculateCompatibilityScore(UserProfile user1, UserProfile user2) async {
    double mbtiScore = 0.0;
    double interestScore = 0.0;
    double ageScore = 0.0;
    double locationScore = 0.0;

    // 1. MBTI 兼容性 (權重: 40%)
    if (user1.mbtiType != null && user2.mbtiType != null) {
      mbtiScore = _mbtiService.calculateCompatibility(user1.mbtiType!, user2.mbtiType!);
    }

    // 2. 興趣兼容性 (權重: 30%)
    interestScore = _calculateInterestCompatibility(user1.interests, user2.interests);

    // 3. 年齡兼容性 (權重: 20%)
    ageScore = _calculateAgeCompatibility(user1.age, user2.age);

    // 4. 地理位置兼容性 (權重: 10%)
    locationScore = _calculateLocationCompatibility(user1.location, user2.location);

    // 加權平均
    final overallScore = (mbtiScore * 0.4) + 
                        (interestScore * 0.3) + 
                        (ageScore * 0.2) + 
                        (locationScore * 0.1);

    return overallScore;
  }

  // 計算詳細兼容性分析
  Future<CompatibilityAnalysis> getDetailedCompatibilityAnalysis(
      UserProfile user1, UserProfile user2) async {
    
    final mbtiScore = user1.mbtiType != null && user2.mbtiType != null
        ? _mbtiService.calculateCompatibility(user1.mbtiType!, user2.mbtiType!)
        : 0.5;
    
    final interestScore = _calculateInterestCompatibility(user1.interests, user2.interests);
    final ageScore = _calculateAgeCompatibility(user1.age, user2.age);
    final locationScore = _calculateLocationCompatibility(user1.location, user2.location);
    
    final overallScore = (mbtiScore * 0.4) + 
                        (interestScore * 0.3) + 
                        (ageScore * 0.2) + 
                        (locationScore * 0.1);

    // 生成優勢和考慮因素
    final strengths = <String>[];
    final considerations = <String>[];

    if (mbtiScore > 0.7) {
      strengths.add('性格類型高度匹配');
    } else if (mbtiScore < 0.4) {
      considerations.add('性格差異較大，需要更多理解');
    }

    if (interestScore > 0.6) {
      strengths.add('共同興趣豐富');
    } else if (interestScore < 0.3) {
      considerations.add('共同興趣較少，可以互相探索新領域');
    }

    if (ageScore > 0.8) {
      strengths.add('年齡相近，生活階段相似');
    } else if (ageScore < 0.5) {
      considerations.add('年齡差距較大，可能有不同的人生經歷');
    }

    if (locationScore > 0.7) {
      strengths.add('地理位置便於見面');
    }

    return CompatibilityAnalysis(
      mbtiScore: mbtiScore,
      interestScore: interestScore,
      ageScore: ageScore,
      locationScore: locationScore,
      overallScore: overallScore,
      strengths: strengths,
      considerations: considerations,
    );
  }

  // 記錄用戶行為
  Future<void> recordUserAction(UserAction action) async {
    try {
      await _firestore
          .collection('user_actions')
          .add(action.toJson());

      // 如果是喜歡，檢查是否形成匹配
      if (action.action == ActionType.like) {
        await _checkForMatch(action.userId, action.targetUserId);
      }
    } catch (e) {
      throw Exception('記錄用戶行為失敗: $e');
    }
  }

  // 檢查是否形成匹配
  Future<void> _checkForMatch(String userId1, String userId2) async {
    try {
      // 檢查對方是否也喜歡了當前用戶
      final reverseAction = await _firestore
          .collection('user_actions')
          .where('userId', isEqualTo: userId2)
          .where('targetUserId', isEqualTo: userId1)
          .where('action', isEqualTo: 'like')
          .get();

      if (reverseAction.docs.isNotEmpty) {
        // 創建匹配
        await _createMatch(userId1, userId2);
      }
    } catch (e) {
      throw Exception('檢查匹配失敗: $e');
    }
  }

  // 創建匹配
  Future<void> _createMatch(String userId1, String userId2) async {
    try {
      final user1 = await _getUserProfile(userId1);
      final user2 = await _getUserProfile(userId2);
      
      if (user1 == null || user2 == null) return;

      final compatibilityScore = await calculateCompatibilityScore(user1, user2);
      final analysis = await getDetailedCompatibilityAnalysis(user1, user2);

      final match = Match(
        id: '${userId1}_$userId2',
        userId1: userId1,
        userId2: userId2,
        compatibilityScore: compatibilityScore,
        scoreBreakdown: {
          'mbti': analysis.mbtiScore,
          'interests': analysis.interestScore,
          'age': analysis.ageScore,
          'location': analysis.locationScore,
        },
        createdAt: DateTime.now(),
        status: MatchStatus.matched,
      );

      await _firestore
          .collection('matches')
          .doc(match.id)
          .set(match.toJson());

    } catch (e) {
      throw Exception('創建匹配失敗: $e');
    }
  }

  // 獲取用戶的匹配列表
  Future<List<Match>> getUserMatches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('userId1', isEqualTo: userId)
          .where('status', isEqualTo: 'matched')
          .get();

      final snapshot2 = await _firestore
          .collection('matches')
          .where('userId2', isEqualTo: userId)
          .where('status', isEqualTo: 'matched')
          .get();

      final allDocs = [...snapshot.docs, ...snapshot2.docs];
      return allDocs.map((doc) => Match.fromJson(doc.data())).toList();

    } catch (e) {
      throw Exception('獲取匹配列表失敗: $e');
    }
  }

  // 計算興趣兼容性
  double _calculateInterestCompatibility(List<String> interests1, List<String> interests2) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.0;

    final commonInterests = interests1.where((interest) => interests2.contains(interest)).length;
    final totalUniqueInterests = {...interests1, ...interests2}.length;
    
    return commonInterests / totalUniqueInterests;
  }

  // 計算年齡兼容性
  double _calculateAgeCompatibility(int age1, int age2) {
    final ageDiff = (age1 - age2).abs();
    
    if (ageDiff <= 2) return 1.0;
    if (ageDiff <= 5) return 0.8;
    if (ageDiff <= 10) return 0.6;
    if (ageDiff <= 15) return 0.4;
    return 0.2;
  }

  // 計算地理位置兼容性
  double _calculateLocationCompatibility(String? location1, String? location2) {
    if (location1 == null || location2 == null) return 0.5;
    if (location1 == location2) return 1.0;
    
    // 簡化的地理位置匹配邏輯
    // 實際應用中可以使用更精確的地理位置計算
    return 0.3;
  }

  // 獲取用戶資料
  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 獲取已互動的用戶ID
  Future<Set<String>> _getInteractedUserIds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_actions')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['targetUserId'] as String)
          .toSet();
    } catch (e) {
      return {};
    }
  }
} 