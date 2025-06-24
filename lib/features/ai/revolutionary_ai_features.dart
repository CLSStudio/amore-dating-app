import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';

// ================== 革命性 AI 功能 ==================

/// 🧠 情感智能分析引擎
/// 這是我們的核心競爭優勢 - 能夠深度分析對話中的情感模式
class EmotionalIntelligenceEngine {
  
  /// 分析對話中的真心度指數
  static Future<SincerityAnalysis> analyzeSincerity(
    List<Map<String, dynamic>> conversationHistory,
    Map<String, dynamic> userProfile,
    Map<String, dynamic> partnerProfile,
  ) async {
    
    // 分析語言模式
    final languagePatterns = _analyzeLanguagePatterns(conversationHistory);
    
    // 分析回應時間模式
    final responseTimePatterns = _analyzeResponseTimePatterns(conversationHistory);
    
    // 分析情感一致性
    final emotionalConsistency = _analyzeEmotionalConsistency(conversationHistory);
    
    // 分析深度分享意願
    final sharingDepth = _analyzeSharingDepth(conversationHistory);
    
    // 計算真心度分數
    final sincerityScore = _calculateSincerityScore(
      languagePatterns,
      responseTimePatterns,
      emotionalConsistency,
      sharingDepth,
    );
    
    return SincerityAnalysis(
      sincerityScore: sincerityScore,
      languagePatterns: languagePatterns,
      responseTimePatterns: responseTimePatterns,
      emotionalConsistency: emotionalConsistency,
      sharingDepth: sharingDepth,
      redFlags: _identifyRedFlags(conversationHistory),
      greenFlags: _identifyGreenFlags(conversationHistory),
      confidenceLevel: _calculateConfidenceLevel(conversationHistory.length),
      analysis: _generateSincerityAnalysis(sincerityScore),
      recommendations: _generateSincerityRecommendations(sincerityScore),
    );
  }
  
  /// 預測關係成功率
  static Future<RelationshipPrediction> predictRelationshipSuccess(
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
    List<Map<String, dynamic>> conversationHistory,
  ) async {
    
    // MBTI 深度兼容性分析
    final mbtiCompatibility = _analyzeMBTIDeepCompatibility(
      user1['mbtiType'], 
      user2['mbtiType']
    );
    
    // 溝通模式分析
    final communicationCompatibility = _analyzeCommunicationCompatibility(
      conversationHistory, user1, user2
    );
    
    // 價值觀對齊分析
    final valueAlignment = _analyzeValueAlignment(user1, user2);
    
    // 生活方式匹配
    final lifestyleMatch = _analyzeLifestyleMatch(user1, user2);
    
    // 情感智商匹配
    final emotionalIQMatch = _analyzeEmotionalIQMatch(conversationHistory);
    
    // 衝突處理能力
    final conflictResolution = _analyzeConflictResolutionStyle(conversationHistory);
    
    // 綜合成功率計算
    final successProbability = _calculateSuccessProbability({
      'mbti': mbtiCompatibility,
      'communication': communicationCompatibility,
      'values': valueAlignment,
      'lifestyle': lifestyleMatch,
      'emotionalIQ': emotionalIQMatch,
      'conflictResolution': conflictResolution,
    });
    
    return RelationshipPrediction(
      successProbability: successProbability,
      timeToExclusivity: _predictTimeToExclusivity(successProbability),
      potentialChallenges: _identifyPotentialChallenges(user1, user2),
      strengthAreas: _identifyStrengthAreas(user1, user2),
      improvementSuggestions: _generateImprovementSuggestions(successProbability),
      milestonesPrediction: _generateMilestonesPrediction(successProbability),
    );
  }
  
  /// 🎯 實時情感支援系統
  static Future<EmotionalSupport> provideEmotionalSupport(
    String situation,
    String userMBTI,
    Map<String, dynamic> relationshipContext,
  ) async {
    
    final supportType = _determineSupportType(situation, userMBTI);
    final strategies = _generateEmotionalStrategies(supportType, userMBTI);
    
    return EmotionalSupport(
      supportType: supportType,
      immediateActions: _generateImmediateActions(situation, userMBTI),
      longTermStrategies: strategies,
      mbtiSpecificAdvice: _generateMBTISpecificAdvice(userMBTI, situation),
      selfCareRecommendations: _generateSelfCareRecommendations(userMBTI),
      professionalHelp: _assessProfessionalHelpNeed(situation),
    );
  }
  
  // ================ 私有方法實現 ================
  
  static LanguagePatterns _analyzeLanguagePatterns(List<Map<String, dynamic>> conversation) {
    int questionCount = 0;
    int complimentCount = 0;
    int futureReferenceCount = 0;
    int personalStoryCount = 0;
    int emojiCount = 0;
    
    final totalMessages = conversation.length;
    
    for (final message in conversation) {
      final content = message['content'] as String? ?? '';
      
      // 分析問題
      if (content.contains('?') || content.contains('？') || 
          content.contains('嗎') || content.contains('呢')) {
        questionCount++;
      }
      
      // 分析讚美
      if (_isCompliment(content)) {
        complimentCount++;
      }
      
      // 分析未來規劃
      if (_containsFutureReference(content)) {
        futureReferenceCount++;
      }
      
      // 分析個人分享
      if (_isPersonalStory(content)) {
        personalStoryCount++;
      }
      
      // 分析表情符號
      emojiCount += _countEmojis(content);
    }
    
    return LanguagePatterns(
      questionFrequency: questionCount / totalMessages,
      complimentFrequency: complimentCount / totalMessages,
      futureReferenceFrequency: futureReferenceCount / totalMessages,
      personalStoryFrequency: personalStoryCount / totalMessages,
      emojiUsage: emojiCount / totalMessages,
      averageMessageLength: _calculateAverageMessageLength(conversation),
    );
  }
  
  static ResponseTimePatterns _analyzeResponseTimePatterns(List<Map<String, dynamic>> conversation) {
    final responseTimes = <Duration>[];
    
    for (int i = 1; i < conversation.length; i++) {
      final currentTime = (conversation[i]['timestamp'] as Timestamp).toDate();
      final previousTime = (conversation[i-1]['timestamp'] as Timestamp).toDate();
      responseTimes.add(currentTime.difference(previousTime));
    }
    
    if (responseTimes.isEmpty) {
      return ResponseTimePatterns(
        averageResponseTime: Duration.zero,
        responseConsistency: 0.0,
        immediateResponseRatio: 0.0,
        nightTimeActivity: 0.0,
      );
    }
    
    final averageResponse = Duration(
      milliseconds: responseTimes
          .map((d) => d.inMilliseconds)
          .reduce((a, b) => a + b) ~/ responseTimes.length
    );
    
    final immediateResponses = responseTimes
        .where((d) => d.inMinutes < 5)
        .length;
    
    return ResponseTimePatterns(
      averageResponseTime: averageResponse,
      responseConsistency: _calculateConsistency(responseTimes),
      immediateResponseRatio: immediateResponses / responseTimes.length,
      nightTimeActivity: _calculateNightTimeActivity(conversation),
    );
  }
  
  static double _analyzeMBTIDeepCompatibility(String? mbti1, String? mbti2) {
    if (mbti1 == null || mbti2 == null) return 0.5;
    
    // 深度 MBTI 兼容性分析
    final cognitiveStack1 = _getMBTICognitiveStack(mbti1);
    final cognitiveStack2 = _getMBTICognitiveStack(mbti2);
    
    double compatibility = 0.0;
    
    // 主導功能互補性
    compatibility += _analyzeDominantFunctionCompatibility(
      cognitiveStack1[0], cognitiveStack2[0]
    ) * 0.4;
    
    // 輔助功能協調性
    compatibility += _analyzeAuxiliaryFunctionCompatibility(
      cognitiveStack1[1], cognitiveStack2[1]
    ) * 0.3;
    
    // 第三功能支持性
    compatibility += _analyzeTertiaryFunctionCompatibility(
      cognitiveStack1[2], cognitiveStack2[2]
    ) * 0.2;
    
    // 劣勢功能互補性
    compatibility += _analyzeInferiorFunctionCompatibility(
      cognitiveStack1[3], cognitiveStack2[3]
    ) * 0.1;
    
    return compatibility;
  }
  
  static double _calculateSincerityScore(
    LanguagePatterns language,
    ResponseTimePatterns timing,
    double emotional,
    double sharing,
  ) {
    double score = 0.0;
    
    // 語言真誠度 (30%)
    score += (language.questionFrequency * 0.3 + 
              language.personalStoryFrequency * 0.4 +
              language.futureReferenceFrequency * 0.3) * 0.3;
    
    // 回應模式真誠度 (25%)
    score += (timing.responseConsistency * 0.4 +
              (1 - timing.immediateResponseRatio) * 0.3 + // 不是總是立即回復
              timing.nightTimeActivity * 0.3) * 0.25;
    
    // 情感一致性 (25%)
    score += emotional * 0.25;
    
    // 分享深度 (20%)
    score += sharing * 0.2;
    
    return score.clamp(0.0, 1.0);
  }
  
  // ================ 輔助方法 ================
  
  static bool _isCompliment(String content) {
    final complimentWords = ['漂亮', '帥', '聰明', '有趣', '可愛', '溫柔', '幽默', '才華'];
    return complimentWords.any((word) => content.contains(word));
  }
  
  static bool _containsFutureReference(String content) {
    final futureWords = ['將來', '未來', '以後', '明天', '下次', '希望', '計劃', '想要'];
    return futureWords.any((word) => content.contains(word));
  }
  
  static bool _isPersonalStory(String content) {
    final personalIndicators = ['我的', '我曾經', '記得', '小時候', '以前', '有一次'];
    return personalIndicators.any((indicator) => content.contains(indicator));
  }
  
  static int _countEmojis(String content) {
    final emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]', unicode: true);
    return emojiRegex.allMatches(content).length;
  }
  
  static List<String> _getMBTICognitiveStack(String mbti) {
    // 簡化的認知功能堆疊
    final stacks = {
      'INTJ': ['Ni', 'Te', 'Fi', 'Se'],
      'INFJ': ['Ni', 'Fe', 'Ti', 'Se'],
      'INFP': ['Fi', 'Ne', 'Si', 'Te'],
      'INTP': ['Ti', 'Ne', 'Si', 'Fe'],
      'ENTJ': ['Te', 'Ni', 'Se', 'Fi'],
      'ENTP': ['Ne', 'Ti', 'Fe', 'Si'],
      'ENFJ': ['Fe', 'Ni', 'Se', 'Ti'],
      'ENFP': ['Ne', 'Fi', 'Te', 'Si'],
      'ISTJ': ['Si', 'Te', 'Fi', 'Ne'],
      'ISFJ': ['Si', 'Fe', 'Ti', 'Ne'],
      'INFP': ['Fi', 'Ne', 'Si', 'Te'],
      'ISFP': ['Fi', 'Se', 'Ni', 'Te'],
      'ESTJ': ['Te', 'Si', 'Ne', 'Fi'],
      'ESFJ': ['Fe', 'Si', 'Ne', 'Ti'],
      'ESTP': ['Se', 'Ti', 'Fe', 'Ni'],
      'ESFP': ['Se', 'Fi', 'Te', 'Ni'],
    };
    
    return stacks[mbti] ?? ['', '', '', ''];
  }
  
  static double _analyzeDominantFunctionCompatibility(String func1, String func2) {
    // 主導功能兼容性矩陣
    final compatibilityMatrix = {
      'Ni-Fe': 0.9, 'Ni-Te': 0.8, 'Ni-Fi': 0.7, 'Ni-Ti': 0.8,
      'Ne-Fi': 0.9, 'Ne-Ti': 0.8, 'Ne-Fe': 0.7, 'Ne-Te': 0.6,
      'Si-Te': 0.9, 'Si-Fe': 0.8, 'Si-Ti': 0.7, 'Si-Fi': 0.8,
      'Se-Fi': 0.9, 'Se-Ti': 0.8, 'Se-Fe': 0.7, 'Se-Te': 0.6,
      'Te-Ni': 0.8, 'Te-Si': 0.9, 'Te-Fi': 0.6, 'Te-Ti': 0.5,
      'Fe-Ni': 0.9, 'Fe-Si': 0.8, 'Fe-Ti': 0.6, 'Fe-Fi': 0.7,
      'Ti-Ne': 0.8, 'Ti-Se': 0.8, 'Ti-Ni': 0.8, 'Ti-Si': 0.7,
      'Fi-Ne': 0.9, 'Fi-Se': 0.9, 'Fi-Ni': 0.7, 'Fi-Si': 0.8,
    };
    
    final key = '$func1-$func2';
    final reverseKey = '$func2-$func1';
    
    return compatibilityMatrix[key] ?? compatibilityMatrix[reverseKey] ?? 0.5;
  }
  
  static double _analyzeAuxiliaryFunctionCompatibility(String func1, String func2) {
    // 輔助功能的協調性分析
    return _analyzeDominantFunctionCompatibility(func1, func2) * 0.8;
  }
  
  static double _analyzeTertiaryFunctionCompatibility(String func1, String func2) {
    // 第三功能的支持性分析
    return _analyzeDominantFunctionCompatibility(func1, func2) * 0.6;
  }
  
  static double _analyzeInferiorFunctionCompatibility(String func1, String func2) {
    // 劣勢功能的互補性分析
    return _analyzeDominantFunctionCompatibility(func1, func2) * 0.4;
  }
  
  static double _calculateAverageMessageLength(List<Map<String, dynamic>> conversation) {
    if (conversation.isEmpty) return 0.0;
    
    final totalLength = conversation
        .map((msg) => (msg['content'] as String? ?? '').length)
        .reduce((a, b) => a + b);
    
    return totalLength / conversation.length;
  }
  
  static double _calculateConsistency(List<Duration> responseTimes) {
    if (responseTimes.length < 2) return 0.5;
    
    final mean = responseTimes
        .map((d) => d.inMinutes)
        .reduce((a, b) => a + b) / responseTimes.length;
    
    final variance = responseTimes
        .map((d) => pow(d.inMinutes - mean, 2))
        .reduce((a, b) => a + b) / responseTimes.length;
    
    final standardDeviation = sqrt(variance);
    
    // 標準差越小，一致性越高
    return 1.0 - (standardDeviation / (mean + 1)).clamp(0.0, 1.0);
  }
  
  static double _calculateNightTimeActivity(List<Map<String, dynamic>> conversation) {
    int nightMessages = 0;
    
    for (final message in conversation) {
      final timestamp = (message['timestamp'] as Timestamp).toDate();
      final hour = timestamp.hour;
      
      // 晚上 10 點到早上 6 點算夜間
      if (hour >= 22 || hour <= 6) {
        nightMessages++;
      }
    }
    
    return conversation.isEmpty ? 0.0 : nightMessages / conversation.length;
  }
  
  static double _analyzeEmotionalConsistency(List<Map<String, dynamic>> conversation) {
    // 分析情感表達的一致性
    // 這裡簡化實現，實際應該使用情感分析API
    
    final emotionalWords = {
      'positive': ['開心', '高興', '興奮', '愛', '喜歡', '美好', '棒', '讚'],
      'negative': ['難過', '失望', '生氣', '煩', '累', '壓力', '焦慮', '擔心'],
    };
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final message in conversation) {
      final content = message['content'] as String? ?? '';
      
      for (final word in emotionalWords['positive']!) {
        if (content.contains(word)) positiveCount++;
      }
      
      for (final word in emotionalWords['negative']!) {
        if (content.contains(word)) negativeCount++;
      }
    }
    
    final totalEmotional = positiveCount + negativeCount;
    if (totalEmotional == 0) return 0.5;
    
    // 情感平衡度 - 不是完全正面或負面更真實
    final ratio = positiveCount / totalEmotional;
    return 1.0 - (ratio - 0.7).abs(); // 70% 正面情感是理想比例
  }
  
  static double _analyzeSharingDepth(List<Map<String, dynamic>> conversation) {
    int deepSharingCount = 0;
    
    final deepSharingIndicators = [
      '感覺', '覺得', '希望', '夢想', '害怕', '擔心', '想要', '需要',
      '家人', '朋友', '工作', '未來', '過去', '經歷', '回憶', '目標'
    ];
    
    for (final message in conversation) {
      final content = message['content'] as String? ?? '';
      
      for (final indicator in deepSharingIndicators) {
        if (content.contains(indicator)) {
          deepSharingCount++;
          break; // 每條消息只算一次
        }
      }
    }
    
    return conversation.isEmpty ? 0.0 : deepSharingCount / conversation.length;
  }
  
  static List<String> _identifyRedFlags(List<Map<String, dynamic>> conversation) {
    final redFlags = <String>[];
    
    // 檢查各種危險信號
    for (final message in conversation) {
      final content = message['content'] as String? ?? '';
      
      if (content.contains('錢') || content.contains('借')) {
        redFlags.add('💰 提及金錢話題');
      }
      
      if (content.contains('前任') || content.contains('ex')) {
        redFlags.add('💔 過度談論前任');
      }
      
      if (_isOverlyPersistent(content)) {
        redFlags.add('🚨 過度堅持或催促');
      }
      
      if (_containsInappropriateContent(content)) {
        redFlags.add('🔞 不當內容');
      }
    }
    
    return redFlags.toSet().toList(); // 去重
  }
  
  static List<String> _identifyGreenFlags(List<Map<String, dynamic>> conversation) {
    final greenFlags = <String>[];
    
    for (final message in conversation) {
      final content = message['content'] as String? ?? '';
      
      if (_showsEmpathy(content)) {
        greenFlags.add('💚 展現同理心');
      }
      
      if (_asksThoughtfulQuestions(content)) {
        greenFlags.add('🤔 提出深度問題');
      }
      
      if (_sharesVulnerability(content)) {
        greenFlags.add('🦋 願意展現脆弱面');
      }
      
      if (_showsRespect(content)) {
        greenFlags.add('🙏 表現出尊重');
      }
    }
    
    return greenFlags.toSet().toList();
  }
  
  static bool _isOverlyPersistent(String content) {
    final persistentPhrases = ['為什麼不回', '快回我', '在嗎', '你在幹嘛'];
    return persistentPhrases.any((phrase) => content.contains(phrase));
  }
  
  static bool _containsInappropriateContent(String content) {
    // 簡化的不當內容檢測
    final inappropriateWords = ['性', '床', '做愛']; // 實際應該更完整
    return inappropriateWords.any((word) => content.contains(word));
  }
  
  static bool _showsEmpathy(String content) {
    final empathyPhrases = ['理解', '感受', '辛苦了', '加油', '支持你'];
    return empathyPhrases.any((phrase) => content.contains(phrase));
  }
  
  static bool _asksThoughtfulQuestions(String content) {
    final thoughtfulQuestions = ['為什麼', '怎麼想', '感覺如何', '有什麼想法'];
    return thoughtfulQuestions.any((question) => content.contains(question));
  }
  
  static bool _sharesVulnerability(String content) {
    final vulnerabilityWords = ['緊張', '不安', '害怕', '擔心', '脆弱', '困難'];
    return vulnerabilityWords.any((word) => content.contains(word));
  }
  
  static bool _showsRespect(String content) {
    final respectPhrases = ['謝謝', '請', '不好意思', '抱歉', '尊重'];
    return respectPhrases.any((phrase) => content.contains(phrase));
  }
  
  static double _calculateConfidenceLevel(int messageCount) {
    if (messageCount < 10) return 0.3;
    if (messageCount < 50) return 0.6;
    if (messageCount < 100) return 0.8;
    return 0.9;
  }
  
  static String _generateSincerityAnalysis(double score) {
    if (score >= 0.8) {
      return '💎 這個人顯示出高度的真誠性，他們的對話表現出真實的興趣和投入。';
    } else if (score >= 0.6) {
      return '✅ 這個人表現出良好的真誠度，但某些方面可能需要更多觀察。';
    } else if (score >= 0.4) {
      return '⚠️ 真誠度中等，建議保持謹慎並觀察更多互動。';
    } else {
      return '🚨 真誠度較低，建議謹慎進行，可能存在不真實的動機。';
    }
  }
  
  static List<String> _generateSincerityRecommendations(double score) {
    if (score >= 0.8) {
      return [
        '繼續深入了解這個人',
        '可以考慮安排面對面見面',
        '分享更多個人經歷',
        '建立更深層的連結'
      ];
    } else if (score >= 0.6) {
      return [
        '繼續觀察對方的行為模式',
        '嘗試提出更深入的問題',
        '注意對方的回應一致性',
        '保持開放但謹慎的態度'
      ];
    } else {
      return [
        '保持警惕，不要透露過多個人信息',
        '觀察是否有其他紅色警告信號',
        '考慮減慢關係發展速度',
        '如有疑慮，考慮尋求朋友意見'
      ];
    }
  }
  
  // ================ 其他分析方法 ================
  
  static double _analyzeCommunicationCompatibility(
    List<Map<String, dynamic>> conversation,
    Map<String, dynamic> user1,
    Map<String, dynamic> user2,
  ) {
    // 分析溝通風格匹配度
    return 0.75; // 簡化實現
  }
  
  static double _analyzeValueAlignment(Map<String, dynamic> user1, Map<String, dynamic> user2) {
    final values1 = List<String>.from(user1['values'] ?? []);
    final values2 = List<String>.from(user2['values'] ?? []);
    
    if (values1.isEmpty || values2.isEmpty) return 0.5;
    
    final commonValues = values1.where((v) => values2.contains(v)).length;
    final totalUniqueValues = {...values1, ...values2}.length;
    
    return commonValues / totalUniqueValues;
  }
  
  static double _analyzeLifestyleMatch(Map<String, dynamic> user1, Map<String, dynamic> user2) {
    // 分析生活方式匹配度
    return 0.7; // 簡化實現
  }
  
  static double _analyzeEmotionalIQMatch(List<Map<String, dynamic>> conversation) {
    // 分析情商匹配度
    return 0.8; // 簡化實現
  }
  
  static double _analyzeConflictResolutionStyle(List<Map<String, dynamic>> conversation) {
    // 分析衝突解決風格
    return 0.75; // 簡化實現
  }
  
  static double _calculateSuccessProbability(Map<String, double> factors) {
    double weighted = 0.0;
    weighted += factors['mbti']! * 0.25;
    weighted += factors['communication']! * 0.20;
    weighted += factors['values']! * 0.20;
    weighted += factors['lifestyle']! * 0.15;
    weighted += factors['emotionalIQ']! * 0.15;
    weighted += factors['conflictResolution']! * 0.05;
    
    return weighted.clamp(0.0, 1.0);
  }
  
  static Duration _predictTimeToExclusivity(double successProbability) {
    if (successProbability >= 0.8) {
      return const Duration(days: 30);
    } else if (successProbability >= 0.6) {
      return const Duration(days: 60);
    } else {
      return const Duration(days: 120);
    }
  }
  
  static List<String> _identifyPotentialChallenges(
    Map<String, dynamic> user1, 
    Map<String, dynamic> user2
  ) {
    return ['溝通方式差異', '生活節奏不同']; // 簡化實現
  }
  
  static List<String> _identifyStrengthAreas(
    Map<String, dynamic> user1, 
    Map<String, dynamic> user2
  ) {
    return ['共同價值觀', 'MBTI 互補性']; // 簡化實現
  }
  
  static List<String> _generateImprovementSuggestions(double successProbability) {
    return ['增進溝通技巧', '建立共同活動']; // 簡化實現
  }
  
  static List<Map<String, dynamic>> _generateMilestonesPrediction(double successProbability) {
    return [
      {'milestone': '第一次約會', 'timeline': '1-2 週'},
      {'milestone': '確定關係', 'timeline': '1-2 個月'},
    ]; // 簡化實現
  }
  
  static SupportType _determineSupportType(String situation, String userMBTI) {
    // 根據情況和 MBTI 決定支援類型
    return SupportType.emotional; // 簡化實現
  }
  
  static List<String> _generateEmotionalStrategies(SupportType type, String userMBTI) {
    return ['深呼吸練習', '正面思考']; // 簡化實現
  }
  
  static List<String> _generateImmediateActions(String situation, String userMBTI) {
    return ['暫停並深呼吸', '尋求朋友支持']; // 簡化實現
  }
  
  static String _generateMBTISpecificAdvice(String userMBTI, String situation) {
    return '根據你的 $userMBTI 性格特點，建議你...'; // 簡化實現
  }
  
  static List<String> _generateSelfCareRecommendations(String userMBTI) {
    return ['冥想', '運動', '聽音樂']; // 簡化實現
  }
  
  static bool _assessProfessionalHelpNeed(String situation) {
    return false; // 簡化實現
  }
}

// ================ 數據模型 ================

class SincerityAnalysis {
  final double sincerityScore;
  final LanguagePatterns languagePatterns;
  final ResponseTimePatterns responseTimePatterns;
  final double emotionalConsistency;
  final double sharingDepth;
  final List<String> redFlags;
  final List<String> greenFlags;
  final double confidenceLevel;
  final String analysis;
  final List<String> recommendations;

  SincerityAnalysis({
    required this.sincerityScore,
    required this.languagePatterns,
    required this.responseTimePatterns,
    required this.emotionalConsistency,
    required this.sharingDepth,
    required this.redFlags,
    required this.greenFlags,
    required this.confidenceLevel,
    required this.analysis,
    required this.recommendations,
  });
}

class LanguagePatterns {
  final double questionFrequency;
  final double complimentFrequency;
  final double futureReferenceFrequency;
  final double personalStoryFrequency;
  final double emojiUsage;
  final double averageMessageLength;

  LanguagePatterns({
    required this.questionFrequency,
    required this.complimentFrequency,
    required this.futureReferenceFrequency,
    required this.personalStoryFrequency,
    required this.emojiUsage,
    required this.averageMessageLength,
  });
}

class ResponseTimePatterns {
  final Duration averageResponseTime;
  final double responseConsistency;
  final double immediateResponseRatio;
  final double nightTimeActivity;

  ResponseTimePatterns({
    required this.averageResponseTime,
    required this.responseConsistency,
    required this.immediateResponseRatio,
    required this.nightTimeActivity,
  });
}

class RelationshipPrediction {
  final double successProbability;
  final Duration timeToExclusivity;
  final List<String> potentialChallenges;
  final List<String> strengthAreas;
  final List<String> improvementSuggestions;
  final List<Map<String, dynamic>> milestonesPrediction;

  RelationshipPrediction({
    required this.successProbability,
    required this.timeToExclusivity,
    required this.potentialChallenges,
    required this.strengthAreas,
    required this.improvementSuggestions,
    required this.milestonesPrediction,
  });
}

enum SupportType {
  emotional,
  practical,
  motivational,
  conflict,
}

class EmotionalSupport {
  final SupportType supportType;
  final List<String> immediateActions;
  final List<String> longTermStrategies;
  final String mbtiSpecificAdvice;
  final List<String> selfCareRecommendations;
  final bool professionalHelp;

  EmotionalSupport({
    required this.supportType,
    required this.immediateActions,
    required this.longTermStrategies,
    required this.mbtiSpecificAdvice,
    required this.selfCareRecommendations,
    required this.professionalHelp,
  });
} 