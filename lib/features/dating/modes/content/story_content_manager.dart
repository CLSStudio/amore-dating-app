import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dating_mode_system.dart';
import '../../../../core/models/user_model.dart';

/// 📱 Story內容管理器
/// 為三大核心模式提供專屬的Story內容隔離和管理
class StoryContentManager {
  static final StoryContentManager _instance = StoryContentManager._internal();
  factory StoryContentManager() => _instance;
  StoryContentManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📝 獲取模式專屬Story內容
  Future<List<StoryContent>> getStoriesForMode(
    DatingMode mode,
    String userId,
    {int limit = 20}
  ) async {
    try {
      final query = _firestore
          .collection('stories')
          .where('targetModes', arrayContains: mode.toString())
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final snapshot = await query.get();
      final stories = snapshot.docs
          .map((doc) => StoryContent.fromMap(doc.data()))
          .toList();

      // 根據模式進行個人化過濾
      return await _personalizeStories(stories, mode, userId);
    } catch (e) {
      print('Error getting stories for mode: $e');
      return [];
    }
  }

  /// 📤 發布模式專屬Story
  Future<bool> publishStory(
    String userId,
    String title,
    String content,
    List<String> hashtags,
    List<DatingMode> targetModes,
  ) async {
    try {
      final storyData = {
        'userId': userId,
        'title': title,
        'content': content,
        'hashtags': hashtags,
        'targetModes': targetModes.map((mode) => mode.toString()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'viewCount': 0,
        'likeCount': 0,
        'reportCount': 0,
      };

      await _firestore.collection('stories').add(storyData);
      return true;
    } catch (e) {
      print('Error publishing story: $e');
      return false;
    }
  }

  /// 🎯 根據模式個人化故事內容
  Future<List<StoryContent>> _personalizeStories(
    List<StoryContent> stories,
    DatingMode mode,
    String userId,
  ) async {
    final userProfile = await _getUserProfile(userId);
    
    return stories.where((story) {
      switch (mode) {
        case DatingMode.serious:
          return _isSuitableForSeriousMode(story, userProfile);
        case DatingMode.explore:
          return _isSuitableForExploreMode(story, userProfile);
        case DatingMode.passion:
          return _isSuitableForPassionMode(story, userProfile);
      }
    }).toList();
  }

  /// 🎯 認真交往模式內容適合性檢查
  bool _isSuitableForSeriousMode(StoryContent story, UserModel userProfile) {
    final positiveKeywords = [
      '價值觀', '人生目標', '未來規劃', '家庭', '責任', '承諾',
      '深度', '成長', '穩定', '真誠', '長期', '婚姻', '信任',
      '理解', '支持', '陪伴', '共同', '建立', '發展'
    ];
    
    final negativeKeywords = [
      '一夜情', '約炮', '玩玩', '隨便', '刺激', '開放',
      '試試', '臨時', '即時'
    ];
    
    return _checkContentSuitability(story, positiveKeywords, negativeKeywords);
  }

  /// 🌟 探索模式內容適合性檢查
  bool _isSuitableForExploreMode(StoryContent story, UserModel userProfile) {
    final positiveKeywords = [
      '嘗試', '探索', '發現', '體驗', '學習', '成長',
      '興趣', '活動', '冒險', '新鮮', '多元', '開放',
      '好奇', '實驗', '變化', '機會', '可能性'
    ];
    
    // 探索模式較少負面關鍵字限制
    final negativeKeywords = ['無聊', '重複', '單調'];
    
    return _checkContentSuitability(story, positiveKeywords, negativeKeywords);
  }

  /// 🔥 激情模式內容適合性檢查
  bool _isSuitableForPassionMode(StoryContent story, UserModel userProfile) {
    final positiveKeywords = [
      '即時', '現在', '附近', '當下', '直接', '坦率',
      '自由', '釋放', '激情', '熱情', '大膽', '真實',
      '衝動', '火花', '化學反應', '吸引', '魅力'
    ];
    
    final negativeKeywords = [
      '承諾', '永遠', '結婚', '家庭', '責任', '規劃',
      '未來', '長期', '穩定'
    ];
    
    return _checkContentSuitability(story, positiveKeywords, negativeKeywords);
  }

  /// 檢查內容適合性
  bool _checkContentSuitability(
    StoryContent story,
    List<String> positiveKeywords,
    List<String> negativeKeywords,
  ) {
    final fullText = '${story.title} ${story.content} ${story.hashtags.join(' ')}';
    
    // 檢查正面關鍵字
    bool hasPositive = positiveKeywords.any((keyword) => 
        fullText.toLowerCase().contains(keyword.toLowerCase()));
    
    // 檢查負面關鍵字
    bool hasNegative = negativeKeywords.any((keyword) => 
        fullText.toLowerCase().contains(keyword.toLowerCase()));
    
    return hasPositive && !hasNegative;
  }

  /// 💡 生成模式專屬Story建議
  Future<List<StorySuggestion>> getStorySuggestions(
    DatingMode mode,
    String userId,
  ) async {
    switch (mode) {
      case DatingMode.serious:
        return _getSeriousStorySuggestions(userId);
      case DatingMode.explore:
        return _getExploreStorySuggestions(userId);
      case DatingMode.passion:
        return _getPassionStorySuggestions(userId);
    }
  }

  /// 🎯 認真交往模式Story建議
  Future<List<StorySuggestion>> _getSeriousStorySuggestions(String userId) async {
    return [
      StorySuggestion(
        template: '分享我的人生目標',
        prompt: '談談你最重要的人生目標和追求',
        hashtags: ['#人生目標', '#價值觀', '#成長'],
        example: '我希望在30歲前建立穩定的事業基礎，然後找到志同道合的伴侶...',
      ),
      StorySuggestion(
        template: '我的理想家庭',
        prompt: '描述你理想中的家庭生活',
        hashtags: ['#家庭價值', '#未來規劃', '#溫暖'],
        example: '我渴望的家庭是充滿愛與理解的，每個週末一起做飯，分享彼此的生活...',
      ),
      StorySuggestion(
        template: '最珍貴的品質',
        prompt: '分享你最看重的個人品質',
        hashtags: ['#品格', '#真誠', '#深度'],
        example: '我認為誠實是最重要的品質，因為只有真誠的溝通才能建立深度的關係...',
      ),
    ];
  }

  /// 🌟 探索模式Story建議
  Future<List<StorySuggestion>> _getExploreStorySuggestions(String userId) async {
    return [
      StorySuggestion(
        template: '最近的新發現',
        prompt: '分享你最近發現的有趣事物',
        hashtags: ['#新發現', '#探索', '#有趣'],
        example: '最近發現了一家隱藏在小巷裡的咖啡店，他們的手沖咖啡超棒...',
      ),
      StorySuggestion(
        template: '想嘗試的新體驗',
        prompt: '說說你想嘗試但還沒試過的活動',
        hashtags: ['#新體驗', '#冒險', '#嘗試'],
        example: '一直想學習攀岩，覺得挑戰自己的極限一定很有成就感...',
      ),
      StorySuggestion(
        template: '今天的心情',
        prompt: '分享你今天的心情和感受',
        hashtags: ['#心情', '#當下', '#真實'],
        example: '今天看到夕陽西下的美景，突然覺得生活充滿了無限可能...',
      ),
    ];
  }

  /// 🔥 激情模式Story建議
  Future<List<StorySuggestion>> _getPassionStorySuggestions(String userId) async {
    return [
      StorySuggestion(
        template: '此刻的感受',
        prompt: '分享你此刻最真實的感受',
        hashtags: ['#當下', '#真實', '#感受'],
        example: '現在的我就想找個人一起看星星，感受這個美妙的夜晚...',
      ),
      StorySuggestion(
        template: '附近的精彩',
        prompt: '分享你附近發現的有趣地點或活動',
        hashtags: ['#附近', '#即時', '#精彩'],
        example: '剛發現附近有個很棒的天台酒吧，view超讚，有人想一起去嗎？',
      ),
      StorySuggestion(
        template: '直接的邀請',
        prompt: '直接邀請想要的體驗或活動',
        hashtags: ['#直接', '#邀請', '#即時'],
        example: '想找個人一起喝杯酒聊聊天，就是現在，就在附近...',
      ),
    ];
  }

  /// 👤 獲取用戶檔案
  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return UserModel.empty();
    } catch (e) {
      print('Error getting user profile: $e');
      return UserModel.empty();
    }
  }

  /// 📊 Story統計更新
  Future<void> updateStoryStats(String storyId, StoryAction action) async {
    try {
      final storyRef = _firestore.collection('stories').doc(storyId);
      
      switch (action) {
        case StoryAction.view:
          await storyRef.update({'viewCount': FieldValue.increment(1)});
          break;
        case StoryAction.like:
          await storyRef.update({'likeCount': FieldValue.increment(1)});
          break;
        case StoryAction.report:
          await storyRef.update({'reportCount': FieldValue.increment(1)});
          break;
      }
    } catch (e) {
      print('Error updating story stats: $e');
    }
  }

  /// 🚫 舉報Story
  Future<bool> reportStory(
    String storyId,
    String reporterId,
    String reason,
  ) async {
    try {
      await _firestore.collection('story_reports').add({
        'storyId': storyId,
        'reporterId': reporterId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // 更新故事舉報計數
      await updateStoryStats(storyId, StoryAction.report);
      
      return true;
    } catch (e) {
      print('Error reporting story: $e');
      return false;
    }
  }
}

/// 📝 Story內容模型
class StoryContent {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> hashtags;
  final List<String> targetModes;
  final DateTime createdAt;
  final bool isActive;
  final int viewCount;
  final int likeCount;
  final int reportCount;

  const StoryContent({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.hashtags,
    required this.targetModes,
    required this.createdAt,
    required this.isActive,
    this.viewCount = 0,
    this.likeCount = 0,
    this.reportCount = 0,
  });

  factory StoryContent.fromMap(Map<String, dynamic> map) {
    return StoryContent(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      targetModes: List<String>.from(map['targetModes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'hashtags': hashtags,
      'targetModes': targetModes,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'reportCount': reportCount,
    };
  }
}

/// 💡 Story建議模型
class StorySuggestion {
  final String template;
  final String prompt;
  final List<String> hashtags;
  final String example;

  const StorySuggestion({
    required this.template,
    required this.prompt,
    required this.hashtags,
    required this.example,
  });
}

/// 📊 Story操作枚舉
enum StoryAction {
  view,
  like,
  report,
} 