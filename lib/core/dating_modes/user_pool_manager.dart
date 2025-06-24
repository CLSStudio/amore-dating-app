import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/dating/modes/dating_mode_system.dart';
import '../models/user_model.dart';

/// 🎯 Amore 用戶池管理器
/// 實現三大模式的用戶隔離和專屬檔案管理
class UserPoolManager {
  static final UserPoolManager _instance = UserPoolManager._internal();
  factory UserPoolManager() => _instance;
  UserPoolManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 用戶池集合名稱映射
  static const Map<DatingMode, String> _poolCollections = {
    DatingMode.serious: 'serious_dating_pool',
    DatingMode.explore: 'explore_pool', 
    DatingMode.passion: 'passion_pool',
  };

  /// 🔄 將用戶加入指定模式用戶池
  Future<bool> addUserToPool(String userId, DatingMode mode, UserModel user) async {
    try {
      final poolCollection = _poolCollections[mode]!;
      final profileData = _buildModeSpecificProfile(mode, user);
      
      await _firestore.collection(poolCollection).doc(userId).set({
        'active': true,
        'joinedAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'profileData': profileData,
        'lastActiveAt': FieldValue.serverTimestamp(),
        'mode': mode.toString().split('.').last,
      });

      await _updatePoolStats(mode, 'join');
      return true;
    } catch (e) {
      debugPrint('加入用戶池失敗: $e');
      return false;
    }
  }

  /// ❌ 將用戶從指定模式用戶池移除
  Future<bool> removeUserFromPool(String userId, DatingMode mode) async {
    try {
      final poolCollection = _poolCollections[mode]!;
      
      await _firestore.collection(poolCollection).doc(userId).update({
        'active': false,
        'leftAt': FieldValue.serverTimestamp(),
      });

      // 更新用戶池統計
      await _updatePoolStats(mode, 'leave');
      
      return true;
    } catch (e) {
      debugPrint('離開用戶池失敗: $e');
      return false;
    }
  }

  /// 📊 獲取模式用戶池大小
  Future<int> getPoolSize(DatingMode mode) async {
    try {
      final poolCollection = _poolCollections[mode]!;
      final query = await _firestore
          .collection(poolCollection)
          .where('active', isEqualTo: true)
          .count()
          .get();
      
      return query.count ?? 0;
    } catch (e) {
      debugPrint('獲取用戶池大小失敗: $e');
      return 0;
    }
  }

  /// 🎯 獲取用戶在指定模式的檔案
  Future<Map<String, dynamic>?> getUserPoolProfile(String userId, DatingMode mode) async {
    try {
      final poolCollection = _poolCollections[mode]!;
      final doc = await _firestore.collection(poolCollection).doc(userId).get();
      
      if (doc.exists && doc.data()?['active'] == true) {
        return doc.data()?['profileData'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('獲取用戶池檔案失敗: $e');
      return null;
    }
  }

  /// ✏️ 更新用戶在指定模式的檔案
  Future<bool> updateUserPoolProfile(String userId, DatingMode mode, Map<String, dynamic> profileData) async {
    try {
      final poolCollection = _poolCollections[mode]!;
      
      await _firestore.collection(poolCollection).doc(userId).update({
        'profileData': profileData,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      debugPrint('更新用戶池檔案失敗: $e');
      return false;
    }
  }

  /// 🔍 搜索指定模式的活躍用戶
  Future<List<String>> getActiveUsersInPool(DatingMode mode, {
    int limit = 50,
    String? excludeUserId,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final poolCollection = _poolCollections[mode]!;
      var query = _firestore
          .collection(poolCollection)
          .where('active', isEqualTo: true)
          .orderBy('lastActiveAt', descending: true)
          .limit(limit);

      // 應用額外過濾條件
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.where('profileData.$key', isEqualTo: value);
        });
      }

      final snapshot = await query.get();
      final userIds = snapshot.docs
          .map((doc) => doc.id)
          .where((id) => id != excludeUserId)
          .toList();

      return userIds;
    } catch (e) {
      debugPrint('搜索活躍用戶失敗: $e');
      return [];
    }
  }

  /// 📍 獲取附近的用戶（激情模式專用）
  Future<List<String>> getNearbyUsersInPassionMode(
    double latitude,
    double longitude,
    double radiusKm, {
    int limit = 20,
    String? excludeUserId,
  }) async {
    try {
      // 使用 GeoFirestore 或簡單的邊界框查詢
      final poolCollection = _poolCollections[DatingMode.passion]!;
      
      // 簡單的邊界框查詢（實際項目中應使用 GeoFirestore）
      final latDelta = radiusKm / 111.0; // 1度緯度約111公里
      final lngDelta = radiusKm / (111.0 * 1); // 簡化計算

      final snapshot = await _firestore
          .collection(poolCollection)
          .where('active', isEqualTo: true)
          .where('profileData.currentLocation.latitude', 
                 isGreaterThan: latitude - latDelta)
          .where('profileData.currentLocation.latitude', 
                 isLessThan: latitude + latDelta)
          .limit(limit)
          .get();

      final userIds = snapshot.docs
          .map((doc) => doc.id)
          .where((id) => id != excludeUserId)
          .toList();

      return userIds;
    } catch (e) {
      debugPrint('獲取附近用戶失敗: $e');
      return [];
    }
  }

  /// 📈 獲取用戶池統計信息
  Future<Map<String, dynamic>> getPoolStatistics(DatingMode mode) async {
    try {
      final statsDoc = await _firestore
          .collection('pool_statistics')
          .doc(mode.toString().split('.').last)
          .get();

      if (statsDoc.exists) {
        return statsDoc.data() ?? {};
      }
      
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'dailyJoins': 0,
        'dailyLeaves': 0,
      };
    } catch (e) {
      debugPrint('獲取用戶池統計失敗: $e');
      return {};
    }
  }

  /// 🔄 用戶模式切換處理
  Future<bool> handleModeSwitch(String userId, DatingMode fromMode, DatingMode toMode, UserModel user) async {
    try {
      final batch = _firestore.batch();

      // 從舊用戶池移除
      final oldPoolRef = _firestore.collection(_poolCollections[fromMode]!).doc(userId);
      batch.update(oldPoolRef, {
        'active': false,
        'leftAt': FieldValue.serverTimestamp(),
        'switchedTo': toMode.toString().split('.').last,
      });

      // 加入新用戶池
      final newPoolRef = _firestore.collection(_poolCollections[toMode]!).doc(userId);
      final profileData = _buildModeSpecificProfile(toMode, user);
      
      batch.set(newPoolRef, {
        'active': true,
        'joinedAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'profileData': profileData,
        'lastActiveAt': FieldValue.serverTimestamp(),
        'mode': toMode.toString().split('.').last,
        'switchedFrom': fromMode.toString().split('.').last,
      });

      await batch.commit();
      
      // 更新統計
      await _updatePoolStats(fromMode, 'leave');
      await _updatePoolStats(toMode, 'join');
      
      return true;
    } catch (e) {
      debugPrint('處理模式切換失敗: $e');
      return false;
    }
  }

  /// 🏗️ 構建模式專屬檔案
  Map<String, dynamic> _buildModeSpecificProfile(DatingMode mode, UserModel user) {
    final baseProfile = {
      'userId': user.uid,
      'name': user.name,
      'age': user.age,
      'photos': user.photoUrls,
      'bio': user.bio,
      'location': user.location,
    };

    switch (mode) {
      case DatingMode.serious:
        return {
          ...baseProfile,
          'occupation': user.profession ?? '',
          'education': user.education ?? '',
          'relationshipGoals': '長期關係',
          'mbtiType': user.mbtiType ?? '',
          'interests': user.interests,
        };

      case DatingMode.explore:
        return {
          ...baseProfile,
          'interests': user.interests,
          'languages': <String>[], // 暫時使用空列表
          'activityLevel': 'moderate',
        };

      case DatingMode.passion:
        return {
          ...baseProfile,
          'currentLocation': null, // 暫時設為 null，後續需要添加地理位置支持
          'isOnline': user.isActive,
          'lastSeen': user.lastActive,
        };
    }
  }

  /// 📊 更新用戶池統計
  Future<void> _updatePoolStats(DatingMode mode, String action) async {
    try {
      final statsRef = _firestore
          .collection('pool_statistics')
          .doc(mode.toString().split('.').last);

      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(statsRef);
        
        if (statsDoc.exists) {
          final data = statsDoc.data()!;
          final increment = action == 'join' ? 1 : -1;
          
          transaction.update(statsRef, {
            'totalUsers': (data['totalUsers'] ?? 0) + increment,
            'activeUsers': (data['activeUsers'] ?? 0) + increment,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(statsRef, {
            'totalUsers': action == 'join' ? 1 : 0,
            'activeUsers': action == 'join' ? 1 : 0,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      debugPrint('更新用戶池統計失敗: $e');
    }
  }

  /// 🧹 清理非活躍用戶
  Future<void> cleanupInactiveUsers() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(days: 30));
      
      for (final mode in DatingMode.values) {
        final poolCollection = _poolCollections[mode]!;
        
        final inactiveQuery = await _firestore
            .collection(poolCollection)
            .where('lastActiveAt', isLessThan: Timestamp.fromDate(cutoffTime))
            .where('active', isEqualTo: true)
            .get();

        final batch = _firestore.batch();
        
        for (final doc in inactiveQuery.docs) {
          batch.update(doc.reference, {
            'active': false,
            'deactivatedAt': FieldValue.serverTimestamp(),
            'reason': 'inactive_cleanup',
          });
        }

        if (inactiveQuery.docs.isNotEmpty) {
          await batch.commit();
          debugPrint('清理了 ${inactiveQuery.docs.length} 個非活躍用戶 (${mode.toString()})');
        }
      }
    } catch (e) {
      debugPrint('清理非活躍用戶失敗: $e');
    }
  }
} 