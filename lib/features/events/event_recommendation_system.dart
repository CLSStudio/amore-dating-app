import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

// 活動推薦服務提供者
final eventRecommendationServiceProvider = Provider<EventRecommendationService>((ref) {
  return EventRecommendationService();
});

// 活動類型枚舉
enum EventType {
  social,        // 社交活動
  cultural,      // 文化活動
  sports,        // 運動活動
  food,          // 美食活動
  entertainment, // 娛樂活動
  educational,   // 教育活動
  outdoor,       // 戶外活動
  nightlife,     // 夜生活
  art,           // 藝術活動
  music,         // 音樂活動
}

// 活動難度等級
enum EventDifficulty {
  beginner,      // 初級
  intermediate,  // 中級
  advanced,      // 高級
  expert,        // 專家級
}

// 活動狀態
enum EventStatus {
  upcoming,      // 即將開始
  ongoing,       // 進行中
  completed,     // 已完成
  cancelled,     // 已取消
}

// 參與狀態
enum ParticipationStatus {
  interested,    // 感興趣
  going,         // 將參加
  maybe,         // 可能參加
  notGoing,      // 不參加
  attended,      // 已參加
}

// 活動模型
class Event {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final String organizerId;
  final String organizerName;
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final EventDifficulty difficulty;
  final EventStatus status;
  final List<String> tags;
  final List<String> requiredInterests;
  final String imageUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.organizerId,
    required this.organizerName,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.price,
    required this.difficulty,
    required this.status,
    required this.tags,
    required this.requiredInterests,
    required this.imageUrl,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => EventType.social,
      ),
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'] ?? '',
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      difficulty: EventDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => EventDifficulty.beginner,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      requiredInterests: List<String>.from(json['requiredInterests'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'price': price,
      'difficulty': difficulty.toString().split('.').last,
      'status': status.toString().split('.').last,
      'tags': tags,
      'requiredInterests': requiredInterests,
      'imageUrl': imageUrl,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventType? type,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? organizerId,
    String? organizerName,
    int? maxParticipants,
    int? currentParticipants,
    double? price,
    EventDifficulty? difficulty,
    EventStatus? status,
    List<String>? tags,
    List<String>? requiredInterests,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      price: price ?? this.price,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      requiredInterests: requiredInterests ?? this.requiredInterests,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 活動參與記錄
class EventParticipation {
  final String id;
  final String eventId;
  final String userId;
  final ParticipationStatus status;
  final DateTime registeredAt;
  final DateTime? attendedAt;
  final double? rating;
  final String? review;
  final List<String> connectedUsers; // 在活動中認識的用戶
  final Map<String, dynamic> metadata;

  const EventParticipation({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.registeredAt,
    this.attendedAt,
    this.rating,
    this.review,
    required this.connectedUsers,
    required this.metadata,
  });

  factory EventParticipation.fromJson(Map<String, dynamic> json) {
    return EventParticipation(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      status: ParticipationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ParticipationStatus.interested,
      ),
      registeredAt: (json['registeredAt'] as Timestamp).toDate(),
      attendedAt: json['attendedAt'] != null 
          ? (json['attendedAt'] as Timestamp).toDate() 
          : null,
      rating: json['rating']?.toDouble(),
      review: json['review'],
      connectedUsers: List<String>.from(json['connectedUsers'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'status': status.toString().split('.').last,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'attendedAt': attendedAt != null ? Timestamp.fromDate(attendedAt!) : null,
      'rating': rating,
      'review': review,
      'connectedUsers': connectedUsers,
      'metadata': metadata,
    };
  }
}

// 活動推薦結果
class EventRecommendation {
  final Event event;
  final double matchScore;
  final List<String> matchReasons;
  final List<String> potentialMatches; // 可能在活動中遇到的配對對象
  final double socialScore; // 社交機會評分
  final DateTime recommendedAt;

  const EventRecommendation({
    required this.event,
    required this.matchScore,
    required this.matchReasons,
    required this.potentialMatches,
    required this.socialScore,
    required this.recommendedAt,
  });
}

// 活動推薦服務
class EventRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 獲取個性化活動推薦
  Future<List<EventRecommendation>> getPersonalizedEventRecommendations({
    int limit = 10,
    double maxDistance = 50.0, // 公里
    List<EventType>? preferredTypes,
    double? maxPrice,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      // 獲取用戶資料
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) throw Exception('用戶資料不存在');
      
      final userData = userDoc.data()!;
      final userInterests = List<String>.from(userData['interests'] ?? []);
      final userLocation = userData['location'] as String?;

      // 獲取用戶位置
      Position? userPosition;
      try {
        userPosition = await Geolocator.getCurrentPosition();
      } catch (e) {
        print('無法獲取用戶位置: $e');
      }

      // 構建查詢
      Query query = _firestore.collection('events')
          .where('status', isEqualTo: 'upcoming')
          .where('startTime', isGreaterThan: DateTime.now())
          .orderBy('startTime')
          .limit(limit * 3); // 獲取更多以便篩選

      // 價格篩選
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      final eventsSnapshot = await query.get();
      final events = eventsSnapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // 計算推薦分數並排序
      final recommendations = <EventRecommendation>[];
      
      for (final event in events) {
        // 距離篩選
        if (userPosition != null) {
          final distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            event.latitude,
            event.longitude,
          ) / 1000; // 轉換為公里

          if (distance > maxDistance) continue;
        }

        // 類型篩選
        if (preferredTypes != null && !preferredTypes.contains(event.type)) {
          continue;
        }

        // 計算匹配分數
        final matchScore = await _calculateEventMatchScore(
          event,
          userInterests,
          userLocation,
          userPosition,
        );

        if (matchScore >= 0.3) { // 最低推薦閾值
          final matchReasons = _generateMatchReasons(event, userInterests);
          final potentialMatches = await _findPotentialMatches(event.id, currentUserId);
          final socialScore = _calculateSocialScore(event, potentialMatches.length);

          recommendations.add(EventRecommendation(
            event: event,
            matchScore: matchScore,
            matchReasons: matchReasons,
            potentialMatches: potentialMatches,
            socialScore: socialScore,
            recommendedAt: DateTime.now(),
          ));
        }
      }

      // 按綜合分數排序
      recommendations.sort((a, b) {
        final scoreA = a.matchScore * 0.7 + a.socialScore * 0.3;
        final scoreB = b.matchScore * 0.7 + b.socialScore * 0.3;
        return scoreB.compareTo(scoreA);
      });

      return recommendations.take(limit).toList();
    } catch (e) {
      print('獲取活動推薦失敗: $e');
      throw Exception('獲取活動推薦失敗: $e');
    }
  }

  // 計算活動匹配分數
  Future<double> _calculateEventMatchScore(
    Event event,
    List<String> userInterests,
    String? userLocation,
    Position? userPosition,
  ) async {
    double score = 0.0;

    // 興趣匹配 (40%)
    final interestScore = _calculateInterestMatch(event, userInterests);
    score += interestScore * 0.4;

    // 活動類型偏好 (20%)
    final typeScore = _calculateTypePreference(event.type, userInterests);
    score += typeScore * 0.2;

    // 地理位置便利性 (20%)
    final locationScore = _calculateLocationScore(event, userLocation, userPosition);
    score += locationScore * 0.2;

    // 時間適合度 (10%)
    final timeScore = _calculateTimeScore(event);
    score += timeScore * 0.1;

    // 價格合理性 (10%)
    final priceScore = _calculatePriceScore(event);
    score += priceScore * 0.1;

    return score.clamp(0.0, 1.0);
  }

  // 計算興趣匹配度
  double _calculateInterestMatch(Event event, List<String> userInterests) {
    if (userInterests.isEmpty || event.requiredInterests.isEmpty) return 0.5;

    final commonInterests = userInterests
        .where((interest) => event.requiredInterests.contains(interest))
        .length;

    final totalInterests = {...userInterests, ...event.requiredInterests}.length;
    
    return commonInterests / totalInterests;
  }

  // 計算活動類型偏好
  double _calculateTypePreference(EventType eventType, List<String> userInterests) {
    // 根據用戶興趣推斷對活動類型的偏好
    final typeInterestMap = {
      EventType.sports: ['運動', '健身', '戶外活動', '瑜伽'],
      EventType.cultural: ['文化', '歷史', '藝術', '博物館'],
      EventType.food: ['美食', '烹飪', '品酒', '咖啡'],
      EventType.music: ['音樂', '演唱會', '樂器', '唱歌'],
      EventType.art: ['藝術', '繪畫', '攝影', '設計'],
      EventType.social: ['社交', '聚會', '交友', '派對'],
      EventType.educational: ['學習', '閱讀', '講座', '工作坊'],
      EventType.outdoor: ['戶外活動', '遠足', '露營', '自然'],
      EventType.entertainment: ['娛樂', '電影', '遊戲', '表演'],
      EventType.nightlife: ['夜生活', '酒吧', '俱樂部', '派對'],
    };

    final relatedInterests = typeInterestMap[eventType] ?? [];
    final matchCount = userInterests
        .where((interest) => relatedInterests.contains(interest))
        .length;

    return matchCount > 0 ? (matchCount / relatedInterests.length).clamp(0.0, 1.0) : 0.3;
  }

  // 計算地理位置分數
  double _calculateLocationScore(Event event, String? userLocation, Position? userPosition) {
    if (userPosition != null) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        event.latitude,
        event.longitude,
      ) / 1000; // 轉換為公里

      if (distance <= 5) return 1.0;
      if (distance <= 15) return 0.8;
      if (distance <= 30) return 0.6;
      if (distance <= 50) return 0.4;
      return 0.2;
    }

    // 如果沒有精確位置，使用地區匹配
    if (userLocation != null && event.location.contains(userLocation)) {
      return 0.8;
    }

    return 0.5;
  }

  // 計算時間適合度
  double _calculateTimeScore(Event event) {
    final now = DateTime.now();
    final timeDiff = event.startTime.difference(now);

    // 太近或太遠的活動分數較低
    if (timeDiff.inHours < 2) return 0.3; // 太急
    if (timeDiff.inDays > 30) return 0.5; // 太遠
    if (timeDiff.inDays <= 7) return 1.0; // 一週內最佳
    if (timeDiff.inDays <= 14) return 0.8; // 兩週內良好
    
    return 0.6;
  }

  // 計算價格合理性
  double _calculatePriceScore(Event event) {
    if (event.price == 0) return 1.0; // 免費活動最佳

    // 根據活動類型和價格評估合理性
    final reasonablePrices = {
      EventType.social: 200.0,
      EventType.cultural: 150.0,
      EventType.sports: 300.0,
      EventType.food: 400.0,
      EventType.entertainment: 250.0,
      EventType.educational: 200.0,
      EventType.outdoor: 100.0,
      EventType.nightlife: 300.0,
      EventType.art: 200.0,
      EventType.music: 500.0,
    };

    final reasonablePrice = reasonablePrices[event.type] ?? 200.0;
    final priceRatio = event.price / reasonablePrice;

    if (priceRatio <= 0.5) return 1.0; // 很便宜
    if (priceRatio <= 1.0) return 0.8; // 合理
    if (priceRatio <= 1.5) return 0.6; // 稍貴
    if (priceRatio <= 2.0) return 0.4; // 較貴
    
    return 0.2; // 很貴
  }

  // 生成匹配原因
  List<String> _generateMatchReasons(Event event, List<String> userInterests) {
    final reasons = <String>[];

    // 興趣匹配
    final commonInterests = userInterests
        .where((interest) => event.requiredInterests.contains(interest))
        .toList();
    
    if (commonInterests.isNotEmpty) {
      reasons.add('符合你的興趣：${commonInterests.join('、')}');
    }

    // 活動特色
    if (event.price == 0) {
      reasons.add('免費活動，無經濟負擔');
    }

    if (event.difficulty == EventDifficulty.beginner) {
      reasons.add('適合初學者參與');
    }

    if (event.currentParticipants > 0) {
      reasons.add('已有 ${event.currentParticipants} 人參加');
    }

    // 時間優勢
    final timeDiff = event.startTime.difference(DateTime.now());
    if (timeDiff.inDays <= 3) {
      reasons.add('即將開始，不要錯過');
    }

    return reasons;
  }

  // 尋找潛在配對對象
  Future<List<String>> _findPotentialMatches(String eventId, String currentUserId) async {
    try {
      // 獲取參加此活動的其他用戶
      final participationsSnapshot = await _firestore
          .collection('event_participations')
          .where('eventId', isEqualTo: eventId)
          .where('status', whereIn: ['going', 'interested'])
          .get();

      final participantIds = participationsSnapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .where((id) => id != currentUserId)
          .toList();

      if (participantIds.isEmpty) return [];

      // 獲取當前用戶資料
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) return [];

      final currentUserData = currentUserDoc.data()!;
      final currentUserInterests = List<String>.from(currentUserData['interests'] ?? []);
      final currentUserMBTI = currentUserData['mbtiType'] as String?;

      // 計算與其他參與者的兼容性
      final potentialMatches = <String>[];

      for (final participantId in participantIds.take(20)) { // 限制查詢數量
        final participantDoc = await _firestore.collection('users').doc(participantId).get();
        if (!participantDoc.exists) continue;

        final participantData = participantDoc.data()!;
        final participantInterests = List<String>.from(participantData['interests'] ?? []);
        final participantMBTI = participantData['mbtiType'] as String?;

        // 簡單的兼容性計算
        final interestCompatibility = _calculateSimpleInterestCompatibility(
          currentUserInterests,
          participantInterests,
        );

        final mbtiCompatibility = _calculateSimpleMBTICompatibility(
          currentUserMBTI,
          participantMBTI,
        );

        final overallCompatibility = (interestCompatibility + mbtiCompatibility) / 2;

        if (overallCompatibility >= 0.6) {
          potentialMatches.add(participantId);
        }
      }

      return potentialMatches;
    } catch (e) {
      print('尋找潛在配對失敗: $e');
      return [];
    }
  }

  // 簡單興趣兼容性計算
  double _calculateSimpleInterestCompatibility(List<String> interests1, List<String> interests2) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.3;

    final commonInterests = interests1.where((i) => interests2.contains(i)).length;
    final totalInterests = {...interests1, ...interests2}.length;

    return totalInterests > 0 ? commonInterests / totalInterests : 0.0;
  }

  // 簡單 MBTI 兼容性計算
  double _calculateSimpleMBTICompatibility(String? mbti1, String? mbti2) {
    if (mbti1 == null || mbti2 == null) return 0.5;
    if (mbti1 == mbti2) return 0.9;

    // 簡化的 MBTI 兼容性
    final compatible = {
      'ENFP': ['INTJ', 'INFJ'],
      'ENFJ': ['INFP', 'ISFP'],
      'INFP': ['ENFJ', 'ESFJ'],
      'INFJ': ['ENFP', 'ESTP'],
      'ENTP': ['INTJ', 'INFJ'],
      'ENTJ': ['INTP', 'ISFP'],
      'INTP': ['ENTJ', 'ESTJ'],
      'INTJ': ['ENFP', 'ENTP'],
      'ESFP': ['ISFJ', 'ISTJ'],
      'ESFJ': ['ISFP', 'INFP'],
      'ISFP': ['ENFJ', 'ESFJ'],
      'ISFJ': ['ESFP', 'ESTP'],
      'ESTP': ['ISFJ', 'INFJ'],
      'ESTJ': ['INTP', 'ISTP'],
      'ISTP': ['ESTJ', 'ESFJ'],
      'ISTJ': ['ESFP', 'ESTP'],
    };

    if (compatible[mbti1]?.contains(mbti2) == true) return 0.8;
    return 0.4;
  }

  // 計算社交分數
  double _calculateSocialScore(Event event, int potentialMatchesCount) {
    double score = 0.0;

    // 參與人數影響
    final participationRatio = event.currentParticipants / event.maxParticipants;
    if (participationRatio >= 0.3 && participationRatio <= 0.8) {
      score += 0.4; // 適中的參與度最佳
    } else if (participationRatio > 0.8) {
      score += 0.2; // 太滿可能社交機會較少
    } else {
      score += 0.1; // 太少人可能不夠熱鬧
    }

    // 潛在配對數量
    if (potentialMatchesCount > 0) {
      score += math.min(potentialMatchesCount * 0.1, 0.4);
    }

    // 活動類型的社交性
    final socialTypes = {
      EventType.social: 0.2,
      EventType.entertainment: 0.15,
      EventType.food: 0.15,
      EventType.music: 0.1,
      EventType.cultural: 0.1,
      EventType.sports: 0.1,
      EventType.art: 0.05,
      EventType.educational: 0.05,
      EventType.outdoor: 0.05,
      EventType.nightlife: 0.05,
    };

    score += socialTypes[event.type] ?? 0.0;

    return score.clamp(0.0, 1.0);
  }

  // 註冊參加活動
  Future<void> registerForEvent(String eventId, ParticipationStatus status) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final participationId = '${currentUserId}_$eventId';

      final participation = EventParticipation(
        id: participationId,
        eventId: eventId,
        userId: currentUserId,
        status: status,
        registeredAt: DateTime.now(),
        connectedUsers: [],
        metadata: {},
      );

      await _firestore
          .collection('event_participations')
          .doc(participationId)
          .set(participation.toJson());

      // 更新活動參與人數
      if (status == ParticipationStatus.going) {
        await _firestore.collection('events').doc(eventId).update({
          'currentParticipants': FieldValue.increment(1),
        });
      }

      print('活動註冊成功');
    } catch (e) {
      print('活動註冊失敗: $e');
      throw Exception('活動註冊失敗: $e');
    }
  }

  // 更新參與狀態
  Future<void> updateParticipationStatus(
    String eventId,
    ParticipationStatus newStatus,
  ) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final participationId = '${currentUserId}_$eventId';

      // 獲取當前參與記錄
      final participationDoc = await _firestore
          .collection('event_participations')
          .doc(participationId)
          .get();

      if (!participationDoc.exists) {
        throw Exception('參與記錄不存在');
      }

      final currentParticipation = EventParticipation.fromJson(
        participationDoc.data()!,
      );

      // 更新狀態
      await _firestore
          .collection('event_participations')
          .doc(participationId)
          .update({
        'status': newStatus.toString().split('.').last,
      });

      // 更新活動參與人數
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (eventDoc.exists) {
        int increment = 0;
        
        // 計算人數變化
        if (currentParticipation.status != ParticipationStatus.going && 
            newStatus == ParticipationStatus.going) {
          increment = 1;
        } else if (currentParticipation.status == ParticipationStatus.going && 
                   newStatus != ParticipationStatus.going) {
          increment = -1;
        }

        if (increment != 0) {
          await _firestore.collection('events').doc(eventId).update({
            'currentParticipants': FieldValue.increment(increment),
          });
        }
      }

      print('參與狀態更新成功');
    } catch (e) {
      print('更新參與狀態失敗: $e');
      throw Exception('更新參與狀態失敗: $e');
    }
  }

  // 記錄活動出席
  Future<void> markEventAttendance(String eventId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final participationId = '${currentUserId}_$eventId';

      await _firestore
          .collection('event_participations')
          .doc(participationId)
          .update({
        'status': ParticipationStatus.attended.toString().split('.').last,
        'attendedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('出席記錄成功');
    } catch (e) {
      print('記錄出席失敗: $e');
      throw Exception('記錄出席失敗: $e');
    }
  }

  // 評價活動
  Future<void> rateEvent(String eventId, double rating, String? review) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final participationId = '${currentUserId}_$eventId';

      await _firestore
          .collection('event_participations')
          .doc(participationId)
          .update({
        'rating': rating,
        'review': review,
      });

      print('活動評價成功');
    } catch (e) {
      print('活動評價失敗: $e');
      throw Exception('活動評價失敗: $e');
    }
  }

  // 獲取用戶參與的活動
  Future<List<EventParticipation>> getUserParticipations({
    ParticipationStatus? status,
    int limit = 20,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      Query query = _firestore
          .collection('event_participations')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('registeredAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => EventParticipation.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('獲取參與記錄失敗: $e');
      throw Exception('獲取參與記錄失敗: $e');
    }
  }

  // 在活動中添加連接的用戶
  Future<void> addEventConnection(String eventId, String connectedUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final participationId = '${currentUserId}_$eventId';

      await _firestore
          .collection('event_participations')
          .doc(participationId)
          .update({
        'connectedUsers': FieldValue.arrayUnion([connectedUserId]),
      });

      print('活動連接添加成功');
    } catch (e) {
      print('添加活動連接失敗: $e');
      throw Exception('添加活動連接失敗: $e');
    }
  }

  // 獲取活動統計
  Future<Map<String, dynamic>> getEventStats() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final participations = await getUserParticipations(limit: 100);
      
      final stats = {
        'totalEvents': participations.length,
        'attendedEvents': participations.where((p) => p.status == ParticipationStatus.attended).length,
        'upcomingEvents': participations.where((p) => p.status == ParticipationStatus.going).length,
        'averageRating': 0.0,
        'totalConnections': 0,
        'favoriteEventType': '',
        'totalSpent': 0.0,
      };

      // 計算平均評分
      final ratedParticipations = participations.where((p) => p.rating != null).toList();
      if (ratedParticipations.isNotEmpty) {
        final totalRating = ratedParticipations.fold(0.0, (sum, p) => sum + p.rating!);
        stats['averageRating'] = totalRating / ratedParticipations.length;
      }

             // 計算總連接數
       stats['totalConnections'] = participations.fold<int>(0, (sum, p) => sum + p.connectedUsers.length);

      return stats;
    } catch (e) {
      print('獲取活動統計失敗: $e');
      return {};
    }
  }
}

// 活動推薦頁面
class EventRecommendationPage extends ConsumerStatefulWidget {
  const EventRecommendationPage({super.key});

  @override
  ConsumerState<EventRecommendationPage> createState() => _EventRecommendationPageState();
}

class _EventRecommendationPageState extends ConsumerState<EventRecommendationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EventRecommendation> _recommendations = [];
  List<EventParticipation> _myEvents = [];
  bool _isLoading = false;
  final String _selectedFilter = 'all';
  double _maxDistance = 50.0;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecommendations();
    _loadMyEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(eventRecommendationServiceProvider);
      final recommendations = await service.getPersonalizedEventRecommendations(
        limit: 20,
        maxDistance: _maxDistance,
        maxPrice: _maxPrice,
      );

      setState(() {
        _recommendations = recommendations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入推薦失敗: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMyEvents() async {
    try {
      final service = ref.read(eventRecommendationServiceProvider);
      final events = await service.getUserParticipations(limit: 50);

      setState(() {
        _myEvents = events;
      });
    } catch (e) {
      print('載入我的活動失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '活動推薦',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '推薦活動'),
            Tab(text: '我的活動'),
            Tab(text: '活動統計'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendationsTab(),
          _buildMyEventsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暫無推薦活動',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '調整篩選條件或稍後再試',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('重新載入'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      color: const Color(0xFFE91E63),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = _recommendations[index];
          return _buildEventRecommendationCard(recommendation);
        },
      ),
    );
  }

  Widget _buildEventRecommendationCard(EventRecommendation recommendation) {
    final event = recommendation.event;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活動圖片
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.8),
                    const Color(0xFF9C27B0).withOpacity(0.8),
                  ],
                ),
              ),
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildEventTypeIcon(event.type);
                      },
                    )
                  : _buildEventTypeIcon(event.type),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 活動標題和匹配分數
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getMatchScoreColor(recommendation.matchScore),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(recommendation.matchScore * 100).round()}% 匹配',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 活動描述
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // 活動詳情
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatEventTime(event.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event.currentParticipants}/${event.maxParticipants} 人',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event.price == 0 ? '免費' : 'HK\$${event.price.round()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: event.price == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 匹配原因
                if (recommendation.matchReasons.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recommendation.matchReasons.take(3).map((reason) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE91E63).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE91E63),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 潛在配對提示
                if (recommendation.potentialMatches.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.blue[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '有 ${recommendation.potentialMatches.length} 位高匹配度的人也會參加',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 操作按鈕
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showEventDetails(event),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE91E63),
                          side: const BorderSide(color: Color(0xFFE91E63)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('查看詳情'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _registerForEvent(event.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('我要參加'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeIcon(EventType type) {
    final iconData = {
      EventType.social: Icons.people,
      EventType.cultural: Icons.museum,
      EventType.sports: Icons.sports,
      EventType.food: Icons.restaurant,
      EventType.entertainment: Icons.movie,
      EventType.educational: Icons.school,
      EventType.outdoor: Icons.nature,
      EventType.nightlife: Icons.nightlife,
      EventType.art: Icons.palette,
      EventType.music: Icons.music_note,
    };

    return Center(
      child: Icon(
        iconData[type] ?? Icons.event,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Color _getMatchScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatEventTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '明天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
      return '${weekdays[dateTime.weekday - 1]} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMyEventsTab() {
    if (_myEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '還沒有參加任何活動',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去推薦頁面找找感興趣的活動吧',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myEvents.length,
      itemBuilder: (context, index) {
        final participation = _myEvents[index];
        return _buildMyEventCard(participation);
      },
    );
  }

  Widget _buildMyEventCard(EventParticipation participation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(participation.status),
          child: Icon(
            _getStatusIcon(participation.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          participation.eventId, // 實際應用中應該獲取活動標題
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getStatusText(participation.status),
              style: TextStyle(
                color: _getStatusColor(participation.status),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '註冊時間: ${_formatDate(participation.registeredAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (participation.rating != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < participation.rating!.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    participation.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: participation.status == ParticipationStatus.attended
            ? IconButton(
                icon: const Icon(Icons.rate_review),
                onPressed: () => _showRatingDialog(participation.eventId),
              )
            : null,
      ),
    );
  }

  Color _getStatusColor(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.interested:
        return Colors.blue;
      case ParticipationStatus.going:
        return Colors.green;
      case ParticipationStatus.maybe:
        return Colors.orange;
      case ParticipationStatus.notGoing:
        return Colors.red;
      case ParticipationStatus.attended:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.interested:
        return Icons.favorite_border;
      case ParticipationStatus.going:
        return Icons.check_circle;
      case ParticipationStatus.maybe:
        return Icons.help_outline;
      case ParticipationStatus.notGoing:
        return Icons.cancel;
      case ParticipationStatus.attended:
        return Icons.verified;
    }
  }

  String _getStatusText(ParticipationStatus status) {
    switch (status) {
      case ParticipationStatus.interested:
        return '感興趣';
      case ParticipationStatus.going:
        return '將參加';
      case ParticipationStatus.maybe:
        return '可能參加';
      case ParticipationStatus.notGoing:
        return '不參加';
      case ParticipationStatus.attended:
        return '已參加';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ref.read(eventRecommendationServiceProvider).getEventStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              '載入統計失敗',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          );
        }

        final stats = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 總覽卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        '活動統計總覽',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '總活動數',
                              stats['totalEvents'].toString(),
                              Icons.event,
                              Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              '已參加',
                              stats['attendedEvents'].toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '即將參加',
                              stats['upcomingEvents'].toString(),
                              Icons.schedule,
                              Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              '新認識',
                              stats['totalConnections'].toString(),
                              Icons.people,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 評分卡片
              if (stats['averageRating'] > 0) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          '平均評分',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stats['averageRating'].toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < stats['averageRating'].round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '滿分 5.0',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // 成就徽章
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        '成就徽章',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _buildAchievementBadges(stats),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAchievementBadges(Map<String, dynamic> stats) {
    final badges = <Widget>[];
    
    // 活動參與徽章
    if (stats['attendedEvents'] >= 1) {
      badges.add(_buildBadge('首次參與', Icons.star, Colors.blue));
    }
         if (stats['attendedEvents'] >= 5) {
       badges.add(_buildBadge('活動達人', Icons.emoji_events, Colors.amber));
     }
    if (stats['attendedEvents'] >= 10) {
      badges.add(_buildBadge('社交專家', Icons.people, Colors.purple));
    }
    
    // 評分徽章
    if (stats['averageRating'] >= 4.0) {
      badges.add(_buildBadge('好評如潮', Icons.thumb_up, Colors.green));
    }
    
    // 社交徽章
    if (stats['totalConnections'] >= 5) {
      badges.add(_buildBadge('人脈王', Icons.network_check, Colors.orange));
    }

    if (badges.isEmpty) {
      badges.add(
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            '參加更多活動來解鎖成就徽章！',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return badges;
  }

  Widget _buildBadge(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('篩選條件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 距離篩選
            Text('最大距離: ${_maxDistance.round()} 公里'),
            Slider(
              value: _maxDistance,
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // 價格篩選
            Row(
              children: [
                const Text('最高價格: '),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '不限制',
                      prefixText: 'HK\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxPrice = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadRecommendations();
            },
            child: const Text('應用'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            children: [
              // 標題欄
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE91E63),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // 活動詳情
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('時間', _formatEventTime(event.startTime)),
                      _buildDetailRow('地點', '${event.location}\n${event.address}'),
                      _buildDetailRow('參與人數', '${event.currentParticipants}/${event.maxParticipants} 人'),
                      _buildDetailRow('費用', event.price == 0 ? '免費' : 'HK\$${event.price.round()}'),
                      _buildDetailRow('難度', _getDifficultyText(event.difficulty)),
                      _buildDetailRow('主辦方', event.organizerName),
                      
                      if (event.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          '標籤',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE91E63).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // 操作按鈕
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _registerForEvent(event.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '我要參加',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(EventDifficulty difficulty) {
    switch (difficulty) {
      case EventDifficulty.beginner:
        return '初級';
      case EventDifficulty.intermediate:
        return '中級';
      case EventDifficulty.advanced:
        return '高級';
      case EventDifficulty.expert:
        return '專家級';
    }
  }

  Future<void> _registerForEvent(String eventId) async {
    try {
      final service = ref.read(eventRecommendationServiceProvider);
      await service.registerForEvent(eventId, ParticipationStatus.going);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('報名成功！'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadMyEvents(); // 重新載入我的活動
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('報名失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRatingDialog(String eventId) {
    double rating = 5.0;
    String review = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('評價活動'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('請為這次活動評分：'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      rating = index + 1.0;
                    });
                  },
                  child: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: '分享你的活動體驗（選填）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                review = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final service = ref.read(eventRecommendationServiceProvider);
                await service.rateEvent(eventId, rating, review.isEmpty ? null : review);
                
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('評價提交成功！'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                _loadMyEvents(); // 重新載入我的活動
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('評價提交失敗: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
} 