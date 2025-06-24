import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../auth/models/user_model.dart';
import '../../mbti/models/mbti_models.dart';
import '../../../core/services/database_service.dart';
import '../models/matching_models.dart';

final matchingServiceProvider = Provider<MatchingService>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  return MatchingService(databaseService);
});

class MatchingService {
  final DatabaseService _databaseService;

  MatchingService(this._databaseService);

  /// 為用戶生成匹配建議
  Future<List<MatchSuggestion>> generateMatches(String userId, {int limit = 10}) async {
    try {
      // 獲取當前用戶信息
      final currentUser = await _databaseService.getUserProfile(userId);
      if (currentUser == null) {
        throw MatchingException('找不到用戶檔案');
      }

      // 獲取用戶的 MBTI 結果
      final mbtiResult = await _databaseService.getMBTIResult(userId);

      // 獲取候選用戶
      final candidates = await _getCandidateUsers(userId, currentUser);

      // 計算匹配分數
      final suggestions = <MatchSuggestion>[];
      for (final candidate in candidates) {
        final candidateMbti = await _databaseService.getMBTIResult(candidate.id);
        final score = await _calculateMatchScore(
          currentUser,
          candidate,
          mbtiResult,
          candidateMbti,
        );

        if (score.totalScore >= 0.3) { // 最低匹配閾值
          suggestions.add(MatchSuggestion(
            userId: candidate.id,
            user: candidate,
            matchScore: score,
            reasons: _generateMatchReasons(currentUser, candidate, score),
            createdAt: DateTime.now(),
          ));
        }
      }

      // 按分數排序並限制數量
      suggestions.sort((a, b) => b.matchScore.totalScore.compareTo(a.matchScore.totalScore));
      return suggestions.take(limit).toList();

    } catch (e) {
      throw MatchingException('生成匹配建議失敗: $e');
    }
  }

  /// 獲取候選用戶
  Future<List<UserModel>> _getCandidateUsers(String userId, UserModel currentUser) async {
    // 獲取推薦用戶（基於 MBTI 兼容性）
    final recommendedUsers = await _databaseService.getRecommendedUsers(userId, limit: 50);
    
    // 如果推薦用戶不足，搜索更多用戶
    if (recommendedUsers.length < 20) {
      final additionalUsers = await _databaseService.searchUsers(
        minAge: _calculateMinAge(currentUser),
        maxAge: _calculateMaxAge(currentUser),
        location: currentUser.profile?.location,
        limit: 30,
      );
      
      // 合併並去重
      final allUsers = <String, UserModel>{};
      for (final user in recommendedUsers) {
        allUsers[user.id] = user;
      }
      for (final user in additionalUsers) {
        if (!allUsers.containsKey(user.id) && user.id != userId) {
          allUsers[user.id] = user;
        }
      }
      
      return allUsers.values.toList();
    }
    
    return recommendedUsers;
  }

  /// 計算匹配分數
  Future<MatchScore> _calculateMatchScore(
    UserModel user1,
    UserModel user2,
    MBTIResult? mbti1,
    MBTIResult? mbti2,
  ) async {
    // MBTI 兼容性分數 (40%)
    final mbtiScore = _calculateMBTICompatibility(mbti1, mbti2);
    
    // 興趣相似度分數 (25%)
    final interestScore = _calculateInterestSimilarity(user1, user2);
    
    // 生活方式兼容性分數 (20%)
    final lifestyleScore = _calculateLifestyleCompatibility(user1, user2);
    
    // 基本信息匹配分數 (10%)
    final basicScore = _calculateBasicCompatibility(user1, user2);
    
    // 地理位置分數 (5%)
    final locationScore = _calculateLocationCompatibility(user1, user2);

    // 加權總分
    final totalScore = (mbtiScore * 0.4) +
                      (interestScore * 0.25) +
                      (lifestyleScore * 0.2) +
                      (basicScore * 0.1) +
                      (locationScore * 0.05);

    return MatchScore(
      totalScore: totalScore,
      mbtiCompatibility: mbtiScore,
      interestSimilarity: interestScore,
      lifestyleCompatibility: lifestyleScore,
      basicCompatibility: basicScore,
      locationCompatibility: locationScore,
    );
  }

  /// 計算 MBTI 兼容性
  double _calculateMBTICompatibility(MBTIResult? mbti1, MBTIResult? mbti2) {
    if (mbti1 == null || mbti2 == null) return 0.5; // 默認中等兼容性

    // 計算四個維度的相似度
    final eScore = _calculateDimensionSimilarity(
      mbti1.extraversionScore, mbti2.extraversionScore);
    final nScore = _calculateDimensionSimilarity(
      mbti1.intuitionScore, mbti2.intuitionScore);
    final tScore = _calculateDimensionSimilarity(
      mbti1.thinkingScore, mbti2.thinkingScore);
    final jScore = _calculateDimensionSimilarity(
      mbti1.judgingScore, mbti2.judgingScore);

    // 某些維度的互補性比相似性更重要
    final complementaryScore = _calculateComplementaryScore(mbti1, mbti2);

    return (eScore + nScore + tScore + jScore + complementaryScore) / 5;
  }

  /// 計算維度相似度
  double _calculateDimensionSimilarity(double score1, double score2) {
    final difference = (score1 - score2).abs();
    return math.max(0, 1 - (difference / 100));
  }

  /// 計算互補性分數
  double _calculateComplementaryScore(MBTIResult mbti1, MBTIResult mbti2) {
    // 某些人格類型組合具有天然的互補性
    final type1 = mbti1.personalityType;
    final type2 = mbti2.personalityType;

    final complementaryPairs = {
      'INTJ': ['ENFP', 'ENTP'],
      'INFJ': ['ENFP', 'ENTP'],
      'ISTJ': ['ESFP', 'ESTP'],
      'ISFJ': ['ESFP', 'ESTP'],
      'ENTJ': ['INFP', 'ISFP'],
      'ENFJ': ['INFP', 'ISFP'],
      'ESTJ': ['INFP', 'ISFP'],
      'ESFJ': ['INFP', 'ISFP'],
      'INTP': ['ENFJ', 'ESFJ'],
      'INFP': ['ENTJ', 'ESTJ'],
      'ISTP': ['ENFJ', 'ESFJ'],
      'ISFP': ['ENTJ', 'ESTJ'],
      'ENTP': ['INFJ', 'ISFJ'],
      'ENFP': ['INTJ', 'ISTJ'],
      'ESTP': ['INFJ', 'ISFJ'],
      'ESFP': ['INTJ', 'ISTJ'],
    };

    if (complementaryPairs[type1]?.contains(type2) == true ||
        complementaryPairs[type2]?.contains(type1) == true) {
      return 0.9; // 高互補性
    }

    return 0.5; // 中等互補性
  }

  /// 計算興趣相似度
  double _calculateInterestSimilarity(UserModel user1, UserModel user2) {
    final interests1 = user1.profile?.interests ?? [];
    final interests2 = user2.profile?.interests ?? [];

    if (interests1.isEmpty || interests2.isEmpty) return 0.3;

    final commonInterests = interests1.where((interest) => 
        interests2.contains(interest)).length;
    final totalInterests = (interests1.length + interests2.length) / 2;

    return math.min(1.0, commonInterests / totalInterests * 2);
  }

  /// 計算生活方式兼容性
  double _calculateLifestyleCompatibility(UserModel user1, UserModel user2) {
    final lifestyle1 = user1.profile?.lifestyleAnswers ?? {};
    final lifestyle2 = user2.profile?.lifestyleAnswers ?? {};

    if (lifestyle1.isEmpty || lifestyle2.isEmpty) return 0.5;

    double totalScore = 0;
    int comparedQuestions = 0;

    // 比較重要的生活方式問題
    final importantQuestions = [
      'relationship_goal',
      'lifestyle_pace',
      'values',
      'future_plans',
      'communication_style',
    ];

    for (final question in importantQuestions) {
      final answer1 = lifestyle1[question];
      final answer2 = lifestyle2[question];

      if (answer1 != null && answer2 != null) {
        totalScore += _compareLifestyleAnswers(question, answer1, answer2);
        comparedQuestions++;
      }
    }

    return comparedQuestions > 0 ? totalScore / comparedQuestions : 0.5;
  }

  /// 比較生活方式答案
  double _compareLifestyleAnswers(String question, dynamic answer1, dynamic answer2) {
    switch (question) {
      case 'relationship_goal':
        // 關係目標必須匹配
        return answer1 == answer2 ? 1.0 : 0.2;
      
      case 'values':
        // 價值觀比較（列表）
        if (answer1 is List && answer2 is List) {
          final common = answer1.where((v) => answer2.contains(v)).length;
          final total = (answer1.length + answer2.length) / 2;
          return math.min(1.0, common / total * 1.5);
        }
        return answer1 == answer2 ? 1.0 : 0.0;
      
      case 'future_plans':
        // 未來計劃比較（列表）
        if (answer1 is List && answer2 is List) {
          final common = answer1.where((p) => answer2.contains(p)).length;
          return common > 0 ? 0.8 : 0.3;
        }
        return answer1 == answer2 ? 1.0 : 0.0;
      
      default:
        // 其他問題的簡單比較
        return answer1 == answer2 ? 1.0 : 0.3;
    }
  }

  /// 計算基本信息兼容性
  double _calculateBasicCompatibility(UserModel user1, UserModel user2) {
    double score = 0;
    int factors = 0;

    // 年齡兼容性
    final age1 = _calculateAge(user1.profile?.birthDate);
    final age2 = _calculateAge(user2.profile?.birthDate);
    if (age1 != null && age2 != null) {
      final ageDiff = (age1 - age2).abs();
      score += ageDiff <= 5 ? 1.0 : math.max(0, 1 - (ageDiff - 5) / 10);
      factors++;
    }

    // 教育背景兼容性
    final education1 = user1.profile?.education;
    final education2 = user2.profile?.education;
    if (education1 != null && education2 != null) {
      score += _compareEducationLevels(education1, education2);
      factors++;
    }

    return factors > 0 ? score / factors : 0.5;
  }

  /// 計算地理位置兼容性
  double _calculateLocationCompatibility(UserModel user1, UserModel user2) {
    final location1 = user1.profile?.location;
    final location2 = user2.profile?.location;

    if (location1 == null || location2 == null) return 0.5;

    // 簡化的位置比較（實際應用中應使用地理坐標）
    if (location1 == location2) return 1.0;
    
    // 如果是香港的不同區域，給予較高分數
    if (location1.contains('香港') && location2.contains('香港')) return 0.8;
    
    return 0.3;
  }

  /// 生成匹配原因
  List<String> _generateMatchReasons(UserModel user1, UserModel user2, MatchScore score) {
    final reasons = <String>[];

    if (score.mbtiCompatibility >= 0.7) {
      reasons.add('你們的人格類型非常匹配');
    } else if (score.mbtiCompatibility >= 0.5) {
      reasons.add('你們的人格特質互補');
    }

    if (score.interestSimilarity >= 0.6) {
      final commonInterests = user1.profile?.interests
          .where((interest) => user2.profile?.interests.contains(interest) ?? false)
          .take(3)
          .toList() ?? [];
      if (commonInterests.isNotEmpty) {
        reasons.add('你們都喜歡${commonInterests.join('、')}');
      }
    }

    if (score.lifestyleCompatibility >= 0.7) {
      reasons.add('你們的生活方式很相似');
    }

    if (score.locationCompatibility >= 0.8) {
      reasons.add('你們住得很近');
    }

    final age1 = _calculateAge(user1.profile?.birthDate);
    final age2 = _calculateAge(user2.profile?.birthDate);
    if (age1 != null && age2 != null && (age1 - age2).abs() <= 3) {
      reasons.add('你們年齡相近');
    }

    if (reasons.isEmpty) {
      reasons.add('這是一個有潛力的匹配');
    }

    return reasons;
  }

  /// 輔助方法
  int? _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int _calculateMinAge(UserModel user) {
    final userAge = _calculateAge(user.profile?.birthDate) ?? 25;
    return math.max(18, userAge - 10);
  }

  int _calculateMaxAge(UserModel user) {
    final userAge = _calculateAge(user.profile?.birthDate) ?? 35;
    return math.min(80, userAge + 10);
  }

  double _compareEducationLevels(String education1, String education2) {
    final levels = {
      '高中': 1,
      '專科': 2,
      '學士': 3,
      '碩士': 4,
      '博士': 5,
    };

    final level1 = levels[education1] ?? 3;
    final level2 = levels[education2] ?? 3;
    final diff = (level1 - level2).abs();

    return diff <= 1 ? 1.0 : math.max(0, 1 - (diff - 1) * 0.3);
  }

  /// 處理用戶喜歡/不喜歡操作
  Future<void> handleUserAction(String userId, String targetUserId, bool isLike) async {
    try {
      // 檢查是否已經有匹配記錄
      final existingMatches = await _databaseService.getUserMatches(userId);
      final existingMatch = existingMatches.firstWhere(
        (match) => match.participants.contains(targetUserId),
        orElse: () => throw StateError('No match found'),
      );

      // 更新現有匹配
      if (isLike) {
        await _databaseService.updateMatchStatus(existingMatch.id, MatchStatus.liked);
        
        // 檢查對方是否也喜歡
        final targetMatches = await _databaseService.getUserMatches(targetUserId);
        final mutualMatch = targetMatches.firstWhere(
          (match) => match.participants.contains(userId) && match.status == MatchStatus.liked,
          orElse: () => throw StateError('No mutual match'),
        );

        if (mutualMatch != null) {
          // 創建相互匹配
          await _createMutualMatch(userId, targetUserId);
        }
      } else {
        await _databaseService.updateMatchStatus(existingMatch.id, MatchStatus.passed);
      }
        } catch (e) {
      throw MatchingException('處理用戶操作失敗: $e');
    }
  }

  /// 創建相互匹配
  Future<void> _createMutualMatch(String userId1, String userId2) async {
    try {
      // 創建匹配記錄
      final match = Match(
        id: 'mutual_${userId1}_${userId2}_${DateTime.now().millisecondsSinceEpoch}',
        participants: [userId1, userId2],
        status: MatchStatus.matched,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createMatch(match);

      // 創建聊天室
      final chatRoom = ChatRoom(
        id: 'chat_${userId1}_${userId2}_${DateTime.now().millisecondsSinceEpoch}',
        participants: [userId1, userId2],
        type: ChatRoomType.match,
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
      );

      await _databaseService.createChatRoom(chatRoom);

      // TODO: 發送匹配通知
    } catch (e) {
      throw MatchingException('創建相互匹配失敗: $e');
    }
  }

  /// 獲取匹配統計
  Future<MatchingStats> getMatchingStats(String userId) async {
    try {
      final matches = await _databaseService.getUserMatches(userId);
      
      final totalMatches = matches.length;
      final mutualMatches = matches.where((m) => m.status == MatchStatus.matched).length;
      final likes = matches.where((m) => m.status == MatchStatus.liked).length;
      final passes = matches.where((m) => m.status == MatchStatus.passed).length;

      return MatchingStats(
        totalMatches: totalMatches,
        mutualMatches: mutualMatches,
        likes: likes,
        passes: passes,
        successRate: totalMatches > 0 ? mutualMatches / totalMatches : 0.0,
      );
    } catch (e) {
      throw MatchingException('獲取匹配統計失敗: $e');
    }
  }
}

/// 匹配異常類
class MatchingException implements Exception {
  final String message;
  
  MatchingException(this.message);
  
  @override
  String toString() => 'MatchingException: $message';
} 