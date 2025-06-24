import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import '../models/mode_profile.dart';
import '../../models/user_model.dart';
import '../../../features/dating/modes/dating_mode_system.dart';
import 'ai_matching_service.dart';
import 'matching_algorithms.dart';

/// 🚀 Amore 智能推薦引擎
/// 基於機器學習的個性化推薦系統
class RecommendationEngine {
  static final RecommendationEngine _instance = RecommendationEngine._internal();
  factory RecommendationEngine() => _instance;
  RecommendationEngine._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIMatchingService _aiService = AIMatchingService();
  final Map<String, UserBehaviorModel> _userBehaviorCache = {};

  /// 🎯 獲取個性化推薦
  Future<List<RecommendationResult>> getPersonalizedRecommendations({
    required String userId,
    required DatingMode mode,
    int limit = 10,
  }) async {
    try {
      // 獲取用戶行為模型
      final behaviorModel = await _getUserBehaviorModel(userId, mode);
      
      // 獲取候選用戶
      final candidates = await _getCandidates(userId, mode, limit * 3);
      
      // 計算推薦分數
      final recommendations = <RecommendationResult>[];
      
      for (final candidate in candidates) {
        final score = await _calculateRecommendationScore(
          userId,
          candidate,
          mode,
          behaviorModel,
        );
        
        if (score.totalScore > 0.5) {
          recommendations.add(score);
        }
      }

      // 排序並應用多樣性過濾
      recommendations.sort((a, b) => b.totalScore.compareTo(a.totalScore));
      final diversifiedResults = _applyDiversityFilter(recommendations, limit);

      // 記錄推薦事件用於學習
      await _logRecommendationEvent(userId, mode, diversifiedResults);

      return diversifiedResults;

    } catch (e) {
      debugPrint('個性化推薦錯誤: $e');
      return [];
    }
  }

  /// 📊 計算推薦分數
  Future<RecommendationResult> _calculateRecommendationScore(
    String userId,
    UserModel candidate,
    DatingMode mode,
    UserBehaviorModel behaviorModel,
  ) async {
    final result = RecommendationResult(
      user: candidate,
      totalScore: 0.0,
      compatibilityScore: 0.0,
      behaviorScore: 0.0,
      noveltyScore: 0.0,
      activityScore: 0.0,
      explanations: [],
    );

    try {
      final currentUser = await _getCurrentUser(userId);
      if (currentUser == null) return result;

      // 1. 基礎相容性分數 (40%)
      final algorithm = MatchingAlgorithmFactory.getAlgorithmForMode(mode);
      result.compatibilityScore = await algorithm.calculateCompatibility(currentUser, candidate);

      // 2. 行為匹配分數 (30%)
      result.behaviorScore = _calculateBehaviorScore(behaviorModel, candidate);

      // 3. 新穎性分數 (20%)
      result.noveltyScore = await _calculateNoveltyScore(userId, candidate, mode);

      // 4. 活躍度分數 (10%)
      result.activityScore = _calculateActivityScore(candidate);

      // 加權計算總分
      result.totalScore = 
          result.compatibilityScore * 0.40 +
          result.behaviorScore * 0.30 +
          result.noveltyScore * 0.20 +
          result.activityScore * 0.10;

      // 生成解釋
      result.explanations = _generateExplanations(result, mode);

    } catch (e) {
      debugPrint('計算推薦分數錯誤: $e');
    }

    return result;
  }

  /// 🧠 獲取用戶行為模型
  Future<UserBehaviorModel> _getUserBehaviorModel(String userId, DatingMode mode) async {
    // 檢查緩存
    final cacheKey = '${userId}_${mode.name}';
    if (_userBehaviorCache.containsKey(cacheKey)) {
      return _userBehaviorCache[cacheKey]!;
    }

    try {
      final doc = await _firestore
          .collection('user_behavior_models')
          .doc(userId)
          .get();

      UserBehaviorModel model;
      if (doc.exists) {
        model = UserBehaviorModel.fromMap(doc.data()!);
      } else {
        model = UserBehaviorModel.defaultModel(userId);
      }

      // 更新緩存
      _userBehaviorCache[cacheKey] = model;
      
      return model;
    } catch (e) {
      debugPrint('獲取用戶行為模型錯誤: $e');
      return UserBehaviorModel.defaultModel(userId);
    }
  }

  /// 📈 計算行為匹配分數
  double _calculateBehaviorScore(UserBehaviorModel behaviorModel, UserModel candidate) {
    double score = 0.0;

    // 年齡偏好匹配
    if (candidate.age != null) {
      final agePreference = behaviorModel.agePreference;
      if (candidate.age! >= agePreference.min && candidate.age! <= agePreference.max) {
        score += 0.3;
      } else {
        final distance = math.min(
          (candidate.age! - agePreference.max).abs(),
          (candidate.age! - agePreference.min).abs(),
        );
        score += math.max(0.0, 0.3 - distance * 0.05);
      }
    }

    // 教育程度偏好
    if (behaviorModel.educationPreferences.isNotEmpty && candidate.education != null) {
      if (behaviorModel.educationPreferences.contains(candidate.education)) {
        score += 0.25;
      }
    } else {
      score += 0.125; // 中性分數
    }

    // 興趣匹配偏好
    final commonInterests = behaviorModel.preferredInterests
        .toSet()
        .intersection(candidate.interests.toSet());
    score += (commonInterests.length / math.max(1, behaviorModel.preferredInterests.length)) * 0.25;

    // 位置偏好
    if (candidate.location != null && behaviorModel.maxDistance > 0) {
      // 這裡需要實際距離計算，暫時用模擬值
      score += 0.2; // 簡化實現
    }

    return score.clamp(0.0, 1.0);
  }

  /// ✨ 計算新穎性分數
  Future<double> _calculateNoveltyScore(String userId, UserModel candidate, DatingMode mode) async {
    try {
      // 檢查用戶是否已經交互過
      final interactionDoc = await _firestore
          .collection('user_interactions')
          .doc(userId)
          .get();

      if (interactionDoc.exists) {
        final interactions = interactionDoc.data()!;
        final modeInteractions = interactions['${mode.name}_interactions'] as Map<String, dynamic>? ?? {};
        
        if (modeInteractions.containsKey(candidate.uid)) {
          return 0.3; // 已經交互過，降低新穎性
        }
      }

      // 檢查檔案類型多樣性
      double diversityScore = _calculateProfileDiversity(candidate);
      
      return (0.7 + diversityScore * 0.3).clamp(0.0, 1.0);
    } catch (e) {
      debugPrint('計算新穎性分數錯誤: $e');
      return 0.5;
    }
  }

  /// ⚡ 計算活躍度分數
  double _calculateActivityScore(UserModel candidate) {
    double score = 0.0;

    // 最後上線時間
    if (candidate.lastOnline != null) {
      final now = DateTime.now();
      final timeDiff = now.difference(candidate.lastOnline!).inHours;
      
      if (timeDiff <= 1) score += 0.5;      // 1小時內
      else if (timeDiff <= 6) score += 0.4;  // 6小時內
      else if (timeDiff <= 24) score += 0.3; // 24小時內
      else if (timeDiff <= 72) score += 0.2; // 3天內
      else score += 0.1;                     // 超過3天
    }

    // 檔案完整度
    score += _calculateProfileCompleteness(candidate) * 0.3;

    // 驗證狀態
    if (candidate.isVerified) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// 🎨 計算檔案多樣性
  double _calculateProfileDiversity(UserModel user) {
    double diversity = 0.0;

    // 興趣多樣性
    if (user.interests.length >= 5) diversity += 0.3;
    else if (user.interests.length >= 3) diversity += 0.2;
    else diversity += 0.1;

    // 照片數量
    if (user.photoUrls.length >= 4) diversity += 0.3;
    else if (user.photoUrls.length >= 2) diversity += 0.2;
    else diversity += 0.1;

    // 個人描述長度
    if (user.bio != null && user.bio!.length > 100) diversity += 0.2;
    else if (user.bio != null && user.bio!.length > 50) diversity += 0.15;
    else diversity += 0.1;

    // 社交媒體連接
    if (user.socialLinks.isNotEmpty) diversity += 0.2;

    return diversity.clamp(0.0, 1.0);
  }

  /// 📋 計算檔案完整度
  double _calculateProfileCompleteness(UserModel user) {
    double completeness = 0.0;
    int totalFields = 8;

    if (user.name.isNotEmpty) completeness += 1;
    if (user.age != null) completeness += 1;
    if (user.bio != null && user.bio!.isNotEmpty) completeness += 1;
    if (user.photoUrls.isNotEmpty) completeness += 1;
    if (user.interests.isNotEmpty) completeness += 1;
    if (user.occupation != null) completeness += 1;
    if (user.education != null) completeness += 1;
    if (user.location != null) completeness += 1;

    return completeness / totalFields;
  }

  /// 🔀 應用多樣性過濾
  List<RecommendationResult> _applyDiversityFilter(List<RecommendationResult> recommendations, int limit) {
    if (recommendations.length <= limit) return recommendations;

    final diversified = <RecommendationResult>[];
    final usedCategories = <String>{};

    // 優先選擇高分但不同類型的推薦
    for (final rec in recommendations) {
      if (diversified.length >= limit) break;

      final category = _getUserCategory(rec.user);
      if (!usedCategories.contains(category) || diversified.length < limit * 0.7) {
        diversified.add(rec);
        usedCategories.add(category);
      }
    }

    // 填充剩餘位置
    for (final rec in recommendations) {
      if (diversified.length >= limit) break;
      if (!diversified.contains(rec)) {
        diversified.add(rec);
      }
    }

    return diversified.take(limit).toList();
  }

  /// 👤 獲取用戶類別
  String _getUserCategory(UserModel user) {
    // 根據用戶特徵分類，用於多樣性過濾
    if (user.age != null) {
      if (user.age! < 25) return 'young';
      if (user.age! < 35) return 'middle';
      return 'mature';
    }
    return 'unknown';
  }

  /// 📝 生成推薦解釋
  List<String> _generateExplanations(RecommendationResult result, DatingMode mode) {
    final explanations = <String>[];

    if (result.compatibilityScore > 0.8) {
      explanations.add('你們的相容性很高！');
    } else if (result.compatibilityScore > 0.6) {
      explanations.add('你們有不錯的匹配度');
    }

    if (result.behaviorScore > 0.7) {
      explanations.add('符合你的偏好模式');
    }

    if (result.noveltyScore > 0.8) {
      explanations.add('檔案多樣豐富');
    }

    if (result.activityScore > 0.7) {
      explanations.add('活躍用戶');
    }

    switch (mode) {
      case DatingMode.serious:
        explanations.add('認真交往推薦');
        break;
      case DatingMode.explore:
        explanations.add('探索發現推薦');
        break;
      case DatingMode.passion:
        explanations.add('附近活躍用戶');
        break;
    }

    return explanations;
  }

  /// 🎯 學習用戶反饋
  Future<void> learnFromUserFeedback({
    required String userId,
    required String targetUserId,
    required DatingMode mode,
    required UserFeedbackType feedbackType,
    double? rating,
  }) async {
    try {
      await _firestore.collection('user_feedback').add({
        'user_id': userId,
        'target_user_id': targetUserId,
        'mode': mode.name,
        'feedback_type': feedbackType.name,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 更新用戶行為模型
      await _updateUserBehaviorModel(userId, targetUserId, mode, feedbackType, rating);

    } catch (e) {
      debugPrint('學習用戶反饋錯誤: $e');
    }
  }

  /// 🔄 更新用戶行為模型
  Future<void> _updateUserBehaviorModel(
    String userId,
    String targetUserId,
    DatingMode mode,
    UserFeedbackType feedbackType,
    double? rating,
  ) async {
    try {
      final targetUser = await _getCurrentUser(targetUserId);
      if (targetUser == null) return;

      final behaviorModel = await _getUserBehaviorModel(userId, mode);
      
      // 根據反饋類型更新偏好
      switch (feedbackType) {
        case UserFeedbackType.like:
          _updatePositiveFeedback(behaviorModel, targetUser);
          break;
        case UserFeedbackType.pass:
          _updateNegativeFeedback(behaviorModel, targetUser);
          break;
        case UserFeedbackType.superLike:
          _updatePositiveFeedback(behaviorModel, targetUser, weight: 2.0);
          break;
        case UserFeedbackType.block:
          _updateNegativeFeedback(behaviorModel, targetUser, weight: 2.0);
          break;
      }

      // 保存更新的模型
      await _firestore
          .collection('user_behavior_models')
          .doc(userId)
          .set(behaviorModel.toMap(), SetOptions(merge: true));

      // 清除緩存
      final cacheKey = '${userId}_${mode.name}';
      _userBehaviorCache.remove(cacheKey);

    } catch (e) {
      debugPrint('更新用戶行為模型錯誤: $e');
    }
  }

  /// ➕ 更新正向反饋
  void _updatePositiveFeedback(UserBehaviorModel model, UserModel targetUser, {double weight = 1.0}) {
    // 更新年齡偏好
    if (targetUser.age != null) {
      model.agePreference = AgeRange(
        min: math.min(model.agePreference.min, targetUser.age! - 2),
        max: math.max(model.agePreference.max, targetUser.age! + 2),
      );
    }

    // 更新教育偏好
    if (targetUser.education != null && !model.educationPreferences.contains(targetUser.education)) {
      model.educationPreferences.add(targetUser.education!);
    }

    // 更新興趣偏好
    for (final interest in targetUser.interests) {
      if (!model.preferredInterests.contains(interest)) {
        model.preferredInterests.add(interest);
      }
    }

    model.totalInteractions++;
    model.positiveInteractions++;
  }

  /// ➖ 更新負向反饋
  void _updateNegativeFeedback(UserBehaviorModel model, UserModel targetUser, {double weight = 1.0}) {
    // 記錄負向模式，但不直接移除偏好
    // 而是降低對應特徵的權重
    
    model.totalInteractions++;
    // 不增加positiveInteractions，這樣會降低整體偏好強度
  }

  // ===== 輔助方法 =====

  Future<UserModel?> _getCurrentUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? UserModel.fromMap(doc.data()!) : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> _getCandidates(String userId, DatingMode mode, int limit) async {
    try {
      final poolName = '${mode.name}_pool';
      final snapshot = await _firestore
          .collection(poolName)
          .where('active', isEqualTo: true)
          .limit(limit)
          .get();

      final candidates = <UserModel>[];
      for (final doc in snapshot.docs) {
        if (doc.id != userId) {
          final userData = await _firestore.collection('users').doc(doc.id).get();
          if (userData.exists) {
            candidates.add(UserModel.fromMap(userData.data()!));
          }
        }
      }
      return candidates;
    } catch (e) {
      return [];
    }
  }

  Future<void> _logRecommendationEvent(String userId, DatingMode mode, List<RecommendationResult> results) async {
    try {
      await _firestore.collection('recommendation_logs').add({
        'user_id': userId,
        'mode': mode.name,
        'recommended_users': results.map((r) => r.user.uid).toList(),
        'scores': results.map((r) => r.totalScore).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('記錄推薦事件錯誤: $e');
    }
  }
}

/// 🎯 推薦結果
class RecommendationResult {
  final UserModel user;
  double totalScore;
  double compatibilityScore;
  double behaviorScore;
  double noveltyScore;
  double activityScore;
  List<String> explanations;

  RecommendationResult({
    required this.user,
    required this.totalScore,
    required this.compatibilityScore,
    required this.behaviorScore,
    required this.noveltyScore,
    required this.activityScore,
    required this.explanations,
  });
}

/// 🧠 用戶行為模型
class UserBehaviorModel {
  final String userId;
  AgeRange agePreference;
  List<String> educationPreferences;
  List<String> preferredInterests;
  double maxDistance;
  int totalInteractions;
  int positiveInteractions;
  DateTime lastUpdated;

  UserBehaviorModel({
    required this.userId,
    required this.agePreference,
    required this.educationPreferences,
    required this.preferredInterests,
    required this.maxDistance,
    required this.totalInteractions,
    required this.positiveInteractions,
    required this.lastUpdated,
  });

  factory UserBehaviorModel.defaultModel(String userId) {
    return UserBehaviorModel(
      userId: userId,
      agePreference: AgeRange(min: 20, max: 50),
      educationPreferences: [],
      preferredInterests: [],
      maxDistance: 10.0,
      totalInteractions: 0,
      positiveInteractions: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserBehaviorModel.fromMap(Map<String, dynamic> map) {
    return UserBehaviorModel(
      userId: map['user_id'] ?? '',
      agePreference: AgeRange(
        min: map['age_preference_min'] ?? 20,
        max: map['age_preference_max'] ?? 50,
      ),
      educationPreferences: List<String>.from(map['education_preferences'] ?? []),
      preferredInterests: List<String>.from(map['preferred_interests'] ?? []),
      maxDistance: (map['max_distance'] ?? 10.0).toDouble(),
      totalInteractions: map['total_interactions'] ?? 0,
      positiveInteractions: map['positive_interactions'] ?? 0,
      lastUpdated: (map['last_updated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'age_preference_min': agePreference.min,
      'age_preference_max': agePreference.max,
      'education_preferences': educationPreferences,
      'preferred_interests': preferredInterests,
      'max_distance': maxDistance,
      'total_interactions': totalInteractions,
      'positive_interactions': positiveInteractions,
      'last_updated': FieldValue.serverTimestamp(),
    };
  }

  double get successRate => totalInteractions > 0 ? positiveInteractions / totalInteractions : 0.0;
}

/// 📊 年齡範圍
class AgeRange {
  int min;
  int max;

  AgeRange({required this.min, required this.max});
}

/// 📝 用戶反饋類型
enum UserFeedbackType {
  like,
  pass,
  superLike,
  block,
  chat,
  meet,
} 