import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dating_mode_strategy.dart';
import '../../features/dating/modes/dating_mode_system.dart';
import '../models/user_model.dart';

/// 🎯 Amore 交友模式管理器
/// 負責模式切換、狀態管理和用戶池隔離
class DatingModeManager extends ChangeNotifier {
  static final DatingModeManager _instance = DatingModeManager._internal();
  factory DatingModeManager() => _instance;
  DatingModeManager._internal();

  DatingMode _currentMode = DatingMode.explore; // 預設為探索模式
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 策略實例映射
  final Map<DatingMode, DatingModeStrategy> _strategies = {
    DatingMode.serious: SeriousDatingStrategy(),
    DatingMode.explore: ExploreStrategy(),
    DatingMode.passion: PassionStrategy(),
  };

  // Getters
  DatingMode get currentMode => _currentMode;
  DatingModeStrategy get currentStrategy => _strategies[_currentMode]!;
  DatingModeConfig get currentConfig => currentStrategy.config;
  ThemeData get currentTheme => currentStrategy.getModeTheme();

  /// 🔄 切換交友模式
  Future<bool> switchMode(DatingMode newMode, {String? reason}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // 檢查用戶是否可以加入新模式
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return false;

      final user = UserModel.fromMap(userDoc.data()!);
      final newStrategy = _strategies[newMode]!;
      
      final canJoin = await newStrategy.canUserJoinMode(user);
      if (!canJoin) {
        throw Exception('用戶不符合 ${newStrategy.config.name} 模式的要求');
      }

      final oldMode = _currentMode;
      
      // 記錄模式切換
      await _recordModeSwitch(currentUser.uid, oldMode, newMode, reason ?? '用戶主動切換');
      
      // 更新用戶當前模式
      await _updateUserCurrentMode(currentUser.uid, newMode);
      
      // 移出舊用戶池，加入新用戶池
      await _updateUserPools(currentUser.uid, oldMode, newMode, user);
      
      // 更新本地狀態
      _currentMode = newMode;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('模式切換失敗: $e');
      return false;
    }
  }

  /// 📊 初始化用戶模式
  Future<void> initializeUserMode(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final savedMode = userData['currentMode'];
      
      if (savedMode != null) {
        _currentMode = DatingMode.values.firstWhere(
          (mode) => mode.toString() == 'DatingMode.$savedMode',
          orElse: () => DatingMode.explore,
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('初始化用戶模式失敗: $e');
    }
  }

  /// 🎯 AI 推薦最佳模式
  Future<DatingMode?> recommendOptimalMode(String userId) async {
    try {
      final datingModeService = DatingModeService();
      return await datingModeService.recommendOptimalMode(userId);
    } catch (e) {
      debugPrint('AI 模式推薦失敗: $e');
      return null;
    }
  }

  /// 📈 獲取模式使用統計
  Future<Map<String, dynamic>> getModeUsageStats(String userId) async {
    try {
      final analyticsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('analytics')
          .doc('mode_usage')
          .get();

      if (analyticsDoc.exists) {
        return analyticsDoc.data() ?? {};
      }
      return {};
    } catch (e) {
      debugPrint('獲取模式統計失敗: $e');
      return {};
    }
  }

  /// 🔍 獲取當前模式推薦用戶
  Future<List<UserModel>> getRecommendedUsers({int limit = 10}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      return await currentStrategy.getRecommendedUsers(currentUser.uid, limit: limit);
    } catch (e) {
      debugPrint('獲取推薦用戶失敗: $e');
      return [];
    }
  }

  /// 💡 獲取破冰話題建議
  Future<List<String>> getIcebreakerSuggestions(UserModel otherUser) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return [];

      final user = UserModel.fromMap(userDoc.data()!);
      return await currentStrategy.getIcebreakerSuggestions(user, otherUser);
    } catch (e) {
      debugPrint('獲取破冰話題失敗: $e');
      return [];
    }
  }

  /// 💕 獲取約會建議
  Future<List<String>> getDateSuggestions(UserModel otherUser) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return [];

      final user = UserModel.fromMap(userDoc.data()!);
      return await currentStrategy.getDateSuggestions(user, otherUser);
    } catch (e) {
      debugPrint('獲取約會建議失敗: $e');
      return [];
    }
  }

  // 私有輔助方法

  /// 記錄模式切換
  Future<void> _recordModeSwitch(String userId, DatingMode fromMode, DatingMode toMode, String reason) async {
    await _firestore.collection('mode_switches').add({
      'userId': userId,
      'fromMode': fromMode.toString().split('.').last,
      'toMode': toMode.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
      'reason': reason,
      'aiSuggested': false,
    });
  }

  /// 更新用戶當前模式
  Future<void> _updateUserCurrentMode(String userId, DatingMode newMode) async {
    await _firestore.collection('users').doc(userId).update({
      'currentMode': newMode.toString().split('.').last,
      'lastModeSwitch': FieldValue.serverTimestamp(),
    });
  }

  /// 更新用戶池
  Future<void> _updateUserPools(String userId, DatingMode oldMode, DatingMode newMode, UserModel user) async {
    final batch = _firestore.batch();

    // 從舊用戶池移除
    final oldPoolRef = _firestore.collection('${_getModePoolName(oldMode)}_pool').doc(userId);
    batch.update(oldPoolRef, {'active': false, 'leftAt': FieldValue.serverTimestamp()});

    // 加入新用戶池
    final newPoolRef = _firestore.collection('${_getModePoolName(newMode)}_pool').doc(userId);
    batch.set(newPoolRef, {
      'active': true,
      'joinedAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'profileData': _getModeSpecificProfileData(newMode, user),
    });

    await batch.commit();
  }

  /// 獲取模式池名稱
  String _getModePoolName(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return 'serious_dating';
      case DatingMode.explore:
        return 'explore';
      case DatingMode.passion:
        return 'passion';
    }
  }

  /// 獲取模式專屬檔案數據
  Map<String, dynamic> _getModeSpecificProfileData(DatingMode mode, UserModel user) {
    switch (mode) {
      case DatingMode.serious:
        return {
          'occupation': user.profession,
          'education': user.education,
          'relationshipGoals': '長期關係',
          'coreValues': user.valuesAssessment,
          'mbtiType': user.mbtiType,
          'familyPlanning': null, // 需要額外收集
        };
      case DatingMode.explore:
        return {
          'hobbies': user.interests,
          'socialActivities': [],
          'currentMood': 'open_to_explore',
          'preferredActivities': [],
        };
      case DatingMode.passion:
        return {
          'availableUntil': DateTime.now().add(const Duration(hours: 12)),
          'currentActivity': 'looking_for_connection',
          'preferences': {},
          'boundaries': {},
        };
    }
  }
}

/// 🎯 Riverpod Provider for DatingModeManager
final datingModeManagerProvider = ChangeNotifierProvider<DatingModeManager>((ref) {
  return DatingModeManager();
});

/// 📊 當前模式 Provider
final currentModeProvider = Provider<DatingMode>((ref) {
  return ref.watch(datingModeManagerProvider).currentMode;
});

/// 🎨 當前主題 Provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(datingModeManagerProvider).currentTheme;
});

/// ⚙️ 當前策略 Provider
final currentStrategyProvider = Provider<DatingModeStrategy>((ref) {
  return ref.watch(datingModeManagerProvider).currentStrategy;
}); 