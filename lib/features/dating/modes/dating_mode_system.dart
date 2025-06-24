import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================== Amore 三大交友模式系統 ==================

/// 🎯 Amore 核心交友模式枚舉 - 三大核心模式
enum DatingMode {
  serious,        // 認真交往 - 尋找長期穩定關係
  explore,        // 探索模式 - 開放探索，發現可能性
  passion,        // 激情模式 - 直接的成人需求
}

/// 🔒 模式訪問等級
enum ModeAccessLevel {
  open,           // 開放 - 任何人都可以進入
  verified,       // 已驗證 - 需要身份驗證
  premium,        // 付費 - 需要高級會員
  restricted,     // 限制 - 需要滿足特定條件
}

/// 🏷️ 用戶標籤系統
enum UserTag {
  // 正面標籤
  verified,         // 已驗證
  serious,          // 認真用戶
  responsive,       // 回應積極
  authentic,        // 真實可靠
  
  // 行為標籤
  frequent_switcher,  // 頻繁切換模式
  passion_focused,    // 專注激情模式
  commitment_ready,   // 準備承諾
  explorer,          // 探索者
  
  // 交流標籤
  good_conversationalist,  // 善於對話
  direct_communicator,     // 直接溝通
  patient_texter,         // 耐心文字交流
  video_preferred,        // 偏好視頻交流
}

/// 📊 交友模式配置
class DatingModeConfig {
  final DatingMode mode;
  final String name;
  final String description;
  final String detailedDescription;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final ModeAccessLevel accessLevel;
  final List<DatingMode> compatibleModes;
  final List<String> features;
  final List<String> uniqueFeatures;
  final Map<String, dynamic> restrictions;
  final Map<String, dynamic> requirements;
  final Map<String, String> userGuidance;

  const DatingModeConfig({
    required this.mode,
    required this.name,
    required this.description,
    required this.detailedDescription,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accessLevel,
    required this.compatibleModes,
    required this.features,
    required this.uniqueFeatures,
    required this.restrictions,
    required this.requirements,
    required this.userGuidance,
  });
}

/// 🔄 模式切換記錄
class ModeSwitchRecord {
  final String userId;
  final DatingMode fromMode;
  final DatingMode toMode;
  final DateTime timestamp;
  final String reason;
  final bool aiSuggested;

  ModeSwitchRecord({
    required this.userId,
    required this.fromMode,
    required this.toMode,
    required this.timestamp,
    required this.reason,
    this.aiSuggested = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fromMode': fromMode.toString(),
      'toMode': toMode.toString(),
      'timestamp': timestamp,
      'reason': reason,
      'aiSuggested': aiSuggested,
    };
  }
}

/// 🎯 用戶模式檔案
class UserModeProfile {
  final String userId;
  final DatingMode currentMode;
  final List<UserTag> tags;
  final Map<DatingMode, DateTime> modeHistory;
  final Map<DatingMode, int> modeUsageCount;
  final double seriousnessScore;
  final double communicationScore;
  final double reliabilityScore;
  final List<ModeSwitchRecord> recentSwitches;
  final DateTime lastModeSwitch;
  final bool isRestricted;
  final List<String> restrictionReasons;

  UserModeProfile({
    required this.userId,
    required this.currentMode,
    required this.tags,
    required this.modeHistory,
    required this.modeUsageCount,
    required this.seriousnessScore,
    required this.communicationScore,
    required this.reliabilityScore,
    required this.recentSwitches,
    required this.lastModeSwitch,
    this.isRestricted = false,
    this.restrictionReasons = const [],
  });
}

/// 🎯 交友模式管理服務
class DatingModeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🎯 Amore 三大核心模式完整配置
  static const Map<DatingMode, DatingModeConfig> modeConfigs = {
    DatingMode.serious: DatingModeConfig(
      mode: DatingMode.serious,
      name: '認真交往',
      description: '尋找長期穩定的戀愛關係，願意投入時間和感情',
      detailedDescription: '專為尋找人生伴侶而設計。這裡的用戶都認真對待感情，希望建立深度連結和長期承諾。透過深度MBTI匹配和價值觀評估，幫助你找到真正適合的另一半。',
      icon: Icons.favorite,
      primaryColor: Colors.red,
      secondaryColor: Colors.pink,
      accessLevel: ModeAccessLevel.verified,
      compatibleModes: [DatingMode.serious, DatingMode.explore],
      features: [
        '深度MBTI匹配算法',
        '詳細價值觀評估',
        '長期關係規劃工具',
        '家庭目標討論平台',
        '專業愛情顧問服務',
        '關係里程碑追蹤',
        '深度對話引導',
        '承諾意向評估',
      ],
      uniqueFeatures: [
        '婚姻傾向分析',
        '家庭規劃匹配',
        '財務目標對齊',
        '生活方式兼容性',
      ],
      restrictions: {
        'minAge': 22,
        'verificationRequired': true,
        'profileCompleteness': 80,
        'mbtiRequired': true,
        'valuesAssessmentRequired': true,
      },
      requirements: {
        'photoVerification': true,
        'backgroundCheck': false,
        'personalityTest': true,
        'relationshipGoalsStatement': true,
      },
      userGuidance: {
        'onboarding': '請誠實填寫你的關係目標和價值觀，這有助於找到真正適合的人',
        'matching': '重質不重量，我們會推薦高度匹配的潛在伴侶',
        'communication': '建議開誠布公地討論未來規劃和人生目標',
        'progression': '感情發展需要時間，建議慢慢深入了解對方',
      },
    ),

    DatingMode.explore: DatingModeConfig(
      mode: DatingMode.explore,
      name: '探索模式',
      description: '開放探索各種可能性，發現最適合自己的交友方式',
      detailedDescription: '適合還不確定自己想要什麼樣關係的用戶。透過AI智能推薦和多樣化匹配，幫助你探索不同類型的連結，逐步發現自己的真實需求。',
      icon: Icons.explore,
      primaryColor: Colors.teal,
      secondaryColor: Colors.cyan,
      accessLevel: ModeAccessLevel.open,
      compatibleModes: [DatingMode.explore, DatingMode.serious, DatingMode.passion],
      features: [
        'AI智能模式推薦',
        '多樣化匹配算法',
        '興趣愛好探索',
        '性格測試指導',
        '模式體驗功能',
        '個人化成長建議',
        '靈活切換機制',
        '行為模式分析',
      ],
      uniqueFeatures: [
        '模式推薦引擎',
        '探索歷程追蹤',
        '個性發現工具',
        '適應性學習',
      ],
      restrictions: {
        'minAge': 18,
        'profileBasicsRequired': true,
      },
      requirements: {
        'basicProfileInfo': true,
        'interestSelection': true,
      },
      userGuidance: {
        'onboarding': '不用擔心選錯方向，我們會根據你的互動幫你找到最適合的交友模式',
        'matching': '嘗試與不同類型的人互動，發現你真正的偏好',
        'communication': '保持開放心態，每次對話都是了解自己的機會',
        'progression': '沒有壓力，按照自己的節奏慢慢探索',
      },
    ),

    DatingMode.passion: DatingModeConfig(
      mode: DatingMode.passion,
      name: '激情模式',
      description: '追求直接的親密關係和成人導向的連結',
      detailedDescription: '專為追求激情和親密體驗的成年用戶設計。注重即時化學反應和身體吸引力，提供安全私密的環境進行成人導向的交流。',
      icon: Icons.nightlife,
      primaryColor: Colors.purple,
      secondaryColor: Colors.deepPurple,
      accessLevel: ModeAccessLevel.verified,
      compatibleModes: [DatingMode.passion, DatingMode.explore],
      features: [
        '地理位置智能匹配',
        '即時約會安排',
        '私密聊天加密',
        '快速化學反應評估',
        '成人內容安全篩選',
        '隱私保護機制',
        '即時狀態更新',
        '安全約會指導',
      ],
      uniqueFeatures: [
        '化學反應測試',
        '即時可用狀態',
        '位置偏好設定',
        '隱私模式切換',
      ],
      restrictions: {
        'minAge': 21,
        'verificationRequired': true,
        'locationVerification': true,
        'ageVerificationRequired': true,
        'adultConsentRequired': true,
      },
      requirements: {
        'photoVerification': true,
        'ageVerification': true,
        'consentAgreement': true,
        'safetyGuidelines': true,
      },
      userGuidance: {
        'onboarding': '請明確表達你的需求和界限，尊重他人的選擇',
        'matching': '注重即時化學反應和相互吸引力',
        'communication': '直接但尊重地表達你的意圖和界限',
        'progression': '優先考慮安全和隱私，在舒適的環境中發展關係',
      },
    ),
  };

  /// 🎯 獲取用戶模式檔案
  Future<UserModeProfile> getUserModeProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_mode_profiles')
          .doc(userId)
          .get();

      if (!doc.exists) {
        // 創建新的用戶模式檔案
        return await _createInitialModeProfile(userId);
      }

      final data = doc.data()!;
      return UserModeProfile(
        userId: userId,
        currentMode: DatingMode.values.firstWhere(
          (mode) => mode.toString() == data['currentMode'],
          orElse: () => DatingMode.explore,
        ),
        tags: (data['tags'] as List<dynamic>?)
            ?.map((tag) => UserTag.values.firstWhere(
                  (t) => t.toString() == tag,
                  orElse: () => UserTag.good_conversationalist,
                ))
            .toList() ?? [],
        modeHistory: Map<DatingMode, DateTime>.from(
          (data['modeHistory'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              DatingMode.values.firstWhere((mode) => mode.toString() == key),
              (value as Timestamp).toDate(),
            ),
          ) ?? {},
        ),
        modeUsageCount: Map<DatingMode, int>.from(
          (data['modeUsageCount'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              DatingMode.values.firstWhere((mode) => mode.toString() == key),
              value as int,
            ),
          ) ?? {},
        ),
        seriousnessScore: (data['seriousnessScore'] as num?)?.toDouble() ?? 0.5,
        communicationScore: (data['communicationScore'] as num?)?.toDouble() ?? 0.5,
        reliabilityScore: (data['reliabilityScore'] as num?)?.toDouble() ?? 0.5,
        recentSwitches: [], // 簡化實現
        lastModeSwitch: (data['lastModeSwitch'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRestricted: data['isRestricted'] as bool? ?? false,
        restrictionReasons: List<String>.from(data['restrictionReasons'] ?? []),
      );
    } catch (e) {
      throw Exception('獲取用戶模式檔案失敗: $e');
    }
  }

  /// 🔄 切換交友模式
  Future<bool> switchDatingMode(String userId, DatingMode newMode, {String? reason}) async {
    try {
      final currentProfile = await getUserModeProfile(userId);
      
      // 檢查是否可以切換到新模式
      final canSwitch = await _canSwitchToMode(currentProfile, newMode);
      if (!canSwitch.isAllowed) {
        throw Exception(canSwitch.reason);
      }

      // 記錄模式切換
      final switchRecord = ModeSwitchRecord(
        userId: userId,
        fromMode: currentProfile.currentMode,
        toMode: newMode,
        timestamp: DateTime.now(),
        reason: reason ?? 'User requested',
      );

      await _recordModeSwitch(switchRecord);

      // 更新用戶模式檔案
      await _updateUserModeProfile(userId, newMode, currentProfile);

      // 分析用戶行為並更新標籤
      await _analyzeAndUpdateUserTags(userId, switchRecord);

      return true;
    } catch (e) {
      print('切換模式失敗: $e');
      return false;
    }
  }

  /// 🤖 AI推薦最適合的模式
  Future<DatingMode> recommendOptimalMode(String userId) async {
    try {
      final profile = await getUserModeProfile(userId);
      
      // 獲取用戶聊天習慣
      final chatAnalysis = await _analyzeChatHabits(userId);
      
      // 分析用戶行為模式
      final behaviorAnalysis = await _analyzeBehaviorPatterns(profile);
      
      // AI推薦邏輯
      if ((chatAnalysis['textingSkill'] ?? 0.5) < 0.3) {
        // 不善於文字交流 -> 建議從探索模式開始
        return DatingMode.explore;
      }
      
      if ((behaviorAnalysis['modeStability'] ?? 0.5) < 0.4) {
        // 頻繁切換模式 -> 建議探索模式
        return DatingMode.explore;
      }
      
      if (profile.seriousnessScore > 0.8) {
        // 高度認真 -> 認真交往模式
        return DatingMode.serious;
      }
      
      if (profile.tags.contains(UserTag.passion_focused)) {
        // 專注於激情模式 -> 激情模式（如果符合條件）
        return DatingMode.passion;
      }
      
      // 默認推薦探索模式
      return DatingMode.explore;
      
    } catch (e) {
      return DatingMode.explore; // 出錯時返回探索模式
    }
  }

  /// 🚫 檢查模式切換限制
  Future<SwitchAllowance> _canSwitchToMode(UserModeProfile profile, DatingMode newMode) async {
    final config = modeConfigs[newMode]!;
    
         // 檢查年齡限制
     final userAge = await _getUserAge(profile.userId);
     if (userAge < (config.restrictions['minAge'] as int? ?? 18)) {
       return SwitchAllowance(false, '年齡不符合要求');
     }
    
    // 檢查是否被限制
    if (profile.isRestricted && newMode == DatingMode.serious) {
      return SwitchAllowance(false, '由於行為問題，暫時無法進入認真交往模式');
    }
    
    // 檢查頻繁切換限制
    if (_isFrequentSwitcher(profile) && newMode == DatingMode.passion) {
      return SwitchAllowance(false, '頻繁切換模式的用戶無法進入激情模式');
    }
    
    // 檢查驗證要求
    if (config.accessLevel == ModeAccessLevel.verified) {
      final isVerified = await _isUserVerified(profile.userId);
      if (!isVerified) {
        return SwitchAllowance(false, '需要完成身份驗證才能進入此模式');
      }
    }
    
         // 檢查檔案完整度
     if (config.restrictions.containsKey('profileCompleteness')) {
       final completeness = await _getProfileCompleteness(profile.userId);
       final requiredCompleteness = config.restrictions['profileCompleteness'] as int? ?? 0;
       if (completeness < requiredCompleteness) {
         return SwitchAllowance(false, '請完善個人檔案後再切換模式');
       }
     }
    
    return SwitchAllowance(true, '');
  }

  /// 📊 分析聊天習慣
  Future<Map<String, double>> _analyzeChatHabits(String userId) async {
    // 這裡應該分析用戶的聊天記錄
    // 簡化實現
    return {
      'textingSkill': 0.7,      // 文字交流技巧
      'responseSpeed': 0.8,     // 回應速度
      'conversationDepth': 0.6, // 對話深度
      'emojiUsage': 0.5,        // 表情符號使用
    };
  }

  /// 📈 分析行為模式
  Future<Map<String, double>> _analyzeBehaviorPatterns(UserModeProfile profile) async {
    final modeStability = _calculateModeStability(profile);
    final seriousnessConsistency = _calculateSeriousnessConsistency(profile);
    
    return {
      'modeStability': modeStability,
      'seriousnessConsistency': seriousnessConsistency,
      'communicationConsistency': profile.communicationScore,
      'reliabilityScore': profile.reliabilityScore,
    };
  }

  /// 🏷️ 分析並更新用戶標籤
  Future<void> _analyzeAndUpdateUserTags(String userId, ModeSwitchRecord switchRecord) async {
    final profile = await getUserModeProfile(userId);
    final newTags = <UserTag>[...profile.tags];

    // 分析頻繁切換行為
    if (_isFrequentSwitcher(profile)) {
      if (!newTags.contains(UserTag.frequent_switcher)) {
        newTags.add(UserTag.frequent_switcher);
      }
    }

    // 分析激情偏好
    if (_isPassionFocused(profile)) {
      if (!newTags.contains(UserTag.passion_focused)) {
        newTags.add(UserTag.passion_focused);
      }
    }

    // 分析認真程度
    if (profile.seriousnessScore > 0.8) {
      if (!newTags.contains(UserTag.serious)) {
        newTags.add(UserTag.serious);
      }
    }

    // 更新標籤
    await _firestore.collection('user_mode_profiles').doc(userId).update({
      'tags': newTags.map((tag) => tag.toString()).toList(),
    });
  }

  /// 🔄 創建初始模式檔案
  Future<UserModeProfile> _createInitialModeProfile(String userId) async {
    final initialProfile = UserModeProfile(
      userId: userId,
      currentMode: DatingMode.explore,
      tags: [],
      modeHistory: {DatingMode.explore: DateTime.now()},
      modeUsageCount: {DatingMode.explore: 1},
      seriousnessScore: 0.5,
      communicationScore: 0.5,
      reliabilityScore: 0.5,
      recentSwitches: [],
      lastModeSwitch: DateTime.now(),
    );

    await _firestore.collection('user_mode_profiles').doc(userId).set({
      'currentMode': initialProfile.currentMode.toString(),
      'tags': [],
      'modeHistory': {
        DatingMode.explore.toString(): DateTime.now(),
      },
      'modeUsageCount': {
        DatingMode.explore.toString(): 1,
      },
      'seriousnessScore': 0.5,
      'communicationScore': 0.5,
      'reliabilityScore': 0.5,
      'lastModeSwitch': DateTime.now(),
      'isRestricted': false,
      'restrictionReasons': [],
    });

    return initialProfile;
  }

  /// 📝 記錄模式切換
  Future<void> _recordModeSwitch(ModeSwitchRecord record) async {
    await _firestore.collection('mode_switches').add(record.toMap());
  }

  /// 📊 更新用戶模式檔案
  Future<void> _updateUserModeProfile(String userId, DatingMode newMode, UserModeProfile currentProfile) async {
    final newModeHistory = Map<DatingMode, DateTime>.from(currentProfile.modeHistory);
    newModeHistory[newMode] = DateTime.now();

    final newModeUsageCount = Map<DatingMode, int>.from(currentProfile.modeUsageCount);
    newModeUsageCount[newMode] = (newModeUsageCount[newMode] ?? 0) + 1;

    await _firestore.collection('user_mode_profiles').doc(userId).update({
      'currentMode': newMode.toString(),
      'modeHistory': newModeHistory.map((key, value) => MapEntry(key.toString(), value)),
      'modeUsageCount': newModeUsageCount.map((key, value) => MapEntry(key.toString(), value)),
      'lastModeSwitch': DateTime.now(),
    });
  }

  /// 🎯 獲取兼容模式用戶
  Future<List<String>> getCompatibleUsers(String userId, DatingMode userMode) async {
    try {
      final config = modeConfigs[userMode]!;
      final compatibleModes = config.compatibleModes;

      final query = await _firestore
          .collection('user_mode_profiles')
          .where('currentMode', whereIn: compatibleModes.map((mode) => mode.toString()).toList())
          .where('isRestricted', isEqualTo: false)
          .get();

      return query.docs
          .map((doc) => doc.id)
          .where((id) => id != userId)
          .toList();
    } catch (e) {
      print('獲取兼容用戶失敗: $e');
      return [];
    }
  }

  // ================ 輔助方法 ================

  Future<int> _getUserAge(String userId) async {
    // 簡化實現
    return 25;
  }

  Future<bool> _isUserVerified(String userId) async {
    // 簡化實現
    return true;
  }

  Future<double> _getProfileCompleteness(String userId) async {
    // 簡化實現
    return 85.0;
  }

  bool _isFrequentSwitcher(UserModeProfile profile) {
    // 如果最近30天內切換超過3次
    return profile.recentSwitches.length > 3;
  }

  bool _isPassionFocused(UserModeProfile profile) {
    final passionUsage = profile.modeUsageCount[DatingMode.passion] ?? 0;
    final totalUsage = profile.modeUsageCount.values.fold(0, (sum, count) => sum + count);
    return passionUsage / totalUsage > 0.6;
  }

  double _calculateModeStability(UserModeProfile profile) {
    if (profile.modeUsageCount.length <= 1) return 1.0;
    
    final totalSwitches = profile.modeUsageCount.values.fold(0, (sum, count) => sum + count);
    final primaryModeUsage = profile.modeUsageCount.values.reduce((max, count) => count > max ? count : max);
    
    return primaryModeUsage / totalSwitches;
  }

  double _calculateSeriousnessConsistency(UserModeProfile profile) {
    // 簡化實現
    return profile.seriousnessScore;
  }
}

/// 🚦 模式切換允許狀態
class SwitchAllowance {
  final bool isAllowed;
  final String reason;

  SwitchAllowance(this.isAllowed, this.reason);
}

/// 🎯 模式推薦結果
class ModeRecommendation {
  final DatingMode recommendedMode;
  final double confidence;
  final String reasoning;
  final List<String> benefits;
  final List<String> suggestions;

  ModeRecommendation({
    required this.recommendedMode,
    required this.confidence,
    required this.reasoning,
    required this.benefits,
    required this.suggestions,
  });
}

// Provider
final datingModeServiceProvider = Provider<DatingModeService>((ref) {
  return DatingModeService();
});

final userModeProfileProvider = StreamProvider.family<UserModeProfile, String>((ref, userId) {
  return Stream.fromFuture(
    ref.read(datingModeServiceProvider).getUserModeProfile(userId)
  );
}); 