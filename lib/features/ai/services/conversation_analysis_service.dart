import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConversationAnalysisService {
  static const String _geminiApiKey = 'AIzaSyDjLnHcNBOEoGvnzQGzUCLknoWu9RRsvbY';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 分析對話內容，評估對方的真心度
  static Future<SincerityAnalysis> analyzeSincerity({
    required String chatId,
    required String partnerId,
    int? messageLimit = 50,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      // 獲取聊天記錄
      final messages = await _getChatMessages(chatId, messageLimit ?? 50);
      if (messages.isEmpty) {
        throw Exception('沒有足夠的聊天記錄進行分析');
      }

      // 分析對話內容
      final analysis = await _performSincerityAnalysis(messages, partnerId);
      
      // 保存分析結果
      await _saveSincerityAnalysis(chatId, partnerId, analysis);
      
      return analysis;
    } catch (e) {
      print('真心度分析失敗: $e');
      throw Exception('分析失敗: $e');
    }
  }

  /// 比較多個聊天對象，找出最佳匹配
  static Future<PartnerComparison> comparePartners({
    required List<String> partnerIds,
    int? messageLimit = 30,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('用戶未登入');

      final comparisons = <PartnerAnalysis>[];

      for (final partnerId in partnerIds) {
        final chatId = _generateChatId(currentUserId, partnerId);
        final messages = await _getChatMessages(chatId, messageLimit ?? 30);
        
        if (messages.isNotEmpty) {
          final analysis = await _analyzePartnerCompatibility(messages, partnerId);
          comparisons.add(analysis);
        }
      }

      if (comparisons.isEmpty) {
        throw Exception('沒有足夠的聊天記錄進行比較');
      }

      // 排序並生成比較報告
      comparisons.sort((a, b) => b.overallScore.compareTo(a.overallScore));
      
      final comparison = PartnerComparison(
        id: _generateId(),
        userId: currentUserId,
        partners: comparisons,
        topRecommendation: comparisons.first,
        analysisDate: DateTime.now(),
        insights: _generateComparisonInsights(comparisons),
      );

      // 保存比較結果
      await _savePartnerComparison(comparison);
      
      return comparison;
    } catch (e) {
      print('對象比較失敗: $e');
      throw Exception('比較失敗: $e');
    }
  }

  /// 分析對話模式和溝通風格
  static Future<ConversationPattern> analyzeConversationPattern({
    required String chatId,
    required String partnerId,
    int? messageLimit = 100,
  }) async {
    try {
      final messages = await _getChatMessages(chatId, messageLimit ?? 100);
      if (messages.isEmpty) {
        throw Exception('沒有足夠的聊天記錄進行分析');
      }

      final pattern = await _analyzeConversationPatterns(messages, partnerId);
      
      // 保存分析結果
      await _saveConversationPattern(chatId, partnerId, pattern);
      
      return pattern;
    } catch (e) {
      print('對話模式分析失敗: $e');
      throw Exception('分析失敗: $e');
    }
  }

  /// 獲取聊天記錄
  static Future<List<Map<String, dynamic>>> _getChatMessages(
    String chatId, 
    int limit,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
      print('獲取聊天記錄失敗: $e');
      return [];
    }
  }

  /// 執行真心度分析
  static Future<SincerityAnalysis> _performSincerityAnalysis(
    List<Map<String, dynamic>> messages,
    String partnerId,
  ) async {
    final partnerMessages = messages
        .where((msg) => msg['senderId'] == partnerId)
        .toList();

    if (partnerMessages.isEmpty) {
      throw Exception('沒有對方的消息記錄');
    }

    // 準備分析提示
    final conversationText = partnerMessages
        .map((msg) => msg['content'] as String)
        .join('\n');

    final prompt = '''
請分析以下聊天記錄，評估發送者的真心度和誠意：

聊天內容：
$conversationText

請從以下角度進行分析：
1. 回應的及時性和頻率
2. 消息的深度和個人化程度
3. 情感表達的真實性
4. 對話的主動性和投入度
5. 是否有敷衍或套路化的回應
6. 對未來的態度和規劃

請用 JSON 格式回答，包含以下字段：
{
  "sincerityScore": 0-100的分數,
  "responseQuality": "回應質量評估",
  "emotionalDepth": "情感深度評估", 
  "consistency": "一致性評估",
  "redFlags": ["警告信號列表"],
  "positiveSignals": ["積極信號列表"],
  "overallAssessment": "總體評估",
  "recommendations": ["建議列表"]
}
''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // 解析 JSON 回應
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          final analysisData = jsonDecode(jsonString) as Map<String, dynamic>;
          
          return SincerityAnalysis.fromJson(analysisData, partnerId);
        }
      }
    } catch (e) {
      print('AI 分析失敗: $e');
    }

    // 備用分析
    return _getFallbackSincerityAnalysis(partnerMessages, partnerId);
  }

  /// 分析伴侶兼容性
  static Future<PartnerAnalysis> _analyzePartnerCompatibility(
    List<Map<String, dynamic>> messages,
    String partnerId,
  ) async {
    final currentUserId = _auth.currentUser?.uid;
    final userMessages = messages
        .where((msg) => msg['senderId'] == currentUserId)
        .toList();
    final partnerMessages = messages
        .where((msg) => msg['senderId'] == partnerId)
        .toList();

    // 獲取用戶資料
    final partnerDoc = await _firestore.collection('users').doc(partnerId).get();
    final partnerData = partnerDoc.data() ?? {};

    final prompt = '''
請分析這段對話，評估兩人的兼容性：

用戶消息數量：${userMessages.length}
對方消息數量：${partnerMessages.length}
對方 MBTI：${partnerData['mbtiType'] ?? '未知'}
對方年齡：${partnerData['age'] ?? '未知'}

最近的對話內容：
${messages.take(20).map((msg) => '${msg['senderId'] == currentUserId ? '我' : '對方'}: ${msg['content']}').join('\n')}

請評估：
1. 溝通頻率和平衡性
2. 話題的多樣性和深度
3. 幽默感和個性匹配
4. 價值觀的一致性
5. 未來發展的潛力

請用 JSON 格式回答：
{
  "overallScore": 0-100的總分,
  "communicationScore": 0-100,
  "personalityMatch": 0-100,
  "valueAlignment": 0-100,
  "futureCompatibility": 0-100,
  "strengths": ["優勢列表"],
  "concerns": ["關注點列表"],
  "recommendation": "建議"
}
''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          final analysisData = jsonDecode(jsonString) as Map<String, dynamic>;
          
          return PartnerAnalysis.fromJson(analysisData, partnerId, partnerData);
        }
      }
    } catch (e) {
      print('兼容性分析失敗: $e');
    }

    // 備用分析
    return _getFallbackPartnerAnalysis(messages, partnerId, partnerData);
  }

  /// 分析對話模式
  static Future<ConversationPattern> _analyzeConversationPatterns(
    List<Map<String, dynamic>> messages,
    String partnerId,
  ) async {
    final currentUserId = _auth.currentUser?.uid;
    
    // 統計數據
    final stats = _calculateConversationStats(messages, currentUserId!, partnerId);
    
    final prompt = '''
請分析這段對話的模式和特徵：

統計數據：
- 總消息數：${messages.length}
- 用戶消息數：${stats['userMessageCount']}
- 對方消息數：${stats['partnerMessageCount']}
- 平均回應時間：${stats['averageResponseTime']}分鐘
- 最活躍時段：${stats['mostActiveHour']}點

最近對話樣本：
${messages.take(30).map((msg) => '${msg['senderId'] == currentUserId ? '我' : '對方'}: ${msg['content']}').join('\n')}

請分析：
1. 對話的節奏和流暢度
2. 主導對話的一方
3. 話題轉換的自然度
4. 情感表達的方式
5. 溝通風格的匹配度

請用 JSON 格式回答：
{
  "conversationFlow": "對話流暢度評估",
  "dominancePattern": "主導模式分析",
  "topicDiversity": "話題多樣性",
  "emotionalTone": "情感基調",
  "communicationStyle": "溝通風格",
  "patterns": ["發現的模式列表"],
  "suggestions": ["改進建議"]
}
''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.5,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          final analysisData = jsonDecode(jsonString) as Map<String, dynamic>;
          
          return ConversationPattern.fromJson(analysisData, stats);
        }
      }
    } catch (e) {
      print('對話模式分析失敗: $e');
    }

    // 備用分析
    return _getFallbackConversationPattern(stats);
  }

  /// 計算對話統計數據
  static Map<String, dynamic> _calculateConversationStats(
    List<Map<String, dynamic>> messages,
    String userId,
    String partnerId,
  ) {
    final userMessages = messages.where((msg) => msg['senderId'] == userId).toList();
    final partnerMessages = messages.where((msg) => msg['senderId'] == partnerId).toList();
    
    // 計算平均回應時間
    double totalResponseTime = 0;
    int responseCount = 0;
    
    for (int i = 1; i < messages.length; i++) {
      final current = messages[i];
      final previous = messages[i - 1];
      
      if (current['senderId'] != previous['senderId']) {
        final currentTime = (current['timestamp'] as Timestamp).toDate();
        final previousTime = (previous['timestamp'] as Timestamp).toDate();
        final diff = currentTime.difference(previousTime).inMinutes;
        
        if (diff < 1440) { // 小於24小時
          totalResponseTime += diff;
          responseCount++;
        }
      }
    }
    
    final averageResponseTime = responseCount > 0 ? totalResponseTime / responseCount : 0;
    
    // 計算最活躍時段
    final hourCounts = <int, int>{};
    for (final message in messages) {
      final hour = (message['timestamp'] as Timestamp).toDate().hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    final mostActiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return {
      'userMessageCount': userMessages.length,
      'partnerMessageCount': partnerMessages.length,
      'averageResponseTime': averageResponseTime.round(),
      'mostActiveHour': mostActiveHour,
      'totalMessages': messages.length,
      'conversationDays': _calculateConversationDays(messages),
    };
  }

  /// 計算對話天數
  static int _calculateConversationDays(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) return 0;
    
    final firstMessage = messages.last;
    final lastMessage = messages.first;
    
    final firstTime = (firstMessage['timestamp'] as Timestamp).toDate();
    final lastTime = (lastMessage['timestamp'] as Timestamp).toDate();
    
    return lastTime.difference(firstTime).inDays + 1;
  }

  /// 生成比較洞察
  static List<String> _generateComparisonInsights(List<PartnerAnalysis> comparisons) {
    final insights = <String>[];
    
    if (comparisons.length >= 2) {
      final best = comparisons.first;
      final second = comparisons[1];
      
      insights.add('${best.partnerName} 在整體兼容性上領先 ${(best.overallScore - second.overallScore).round()} 分');
      
      if (best.communicationScore > 80) {
        insights.add('與 ${best.partnerName} 的溝通最為順暢');
      }
      
      if (best.personalityMatch > 85) {
        insights.add('${best.partnerName} 與你的性格最為匹配');
      }
    }
    
    final highScorers = comparisons.where((p) => p.overallScore > 75).toList();
    if (highScorers.length > 1) {
      insights.add('你有 ${highScorers.length} 位高兼容性的聊天對象');
    }
    
    return insights;
  }

  /// 備用真心度分析
  static SincerityAnalysis _getFallbackSincerityAnalysis(
    List<Map<String, dynamic>> messages,
    String partnerId,
  ) {
    final messageCount = messages.length;
    final avgLength = messages.map((m) => (m['content'] as String).length).reduce((a, b) => a + b) / messageCount;
    
    double sincerityScore = 50;
    final positiveSignals = <String>[];
    final redFlags = <String>[];
    
    if (messageCount > 20) {
      sincerityScore += 15;
      positiveSignals.add('積極參與對話');
    }
    
    if (avgLength > 30) {
      sincerityScore += 10;
      positiveSignals.add('回應內容豐富');
    }
    
    return SincerityAnalysis(
      id: _generateId(),
      partnerId: partnerId,
      sincerityScore: sincerityScore.round(),
      responseQuality: '中等',
      emotionalDepth: '適中',
      consistency: '一致',
      redFlags: redFlags,
      positiveSignals: positiveSignals,
      overallAssessment: '需要更多對話來進行準確評估',
      recommendations: ['繼續深入交流', '觀察對方的行動是否與言語一致'],
      analyzedAt: DateTime.now(),
    );
  }

  /// 備用伴侶分析
  static PartnerAnalysis _getFallbackPartnerAnalysis(
    List<Map<String, dynamic>> messages,
    String partnerId,
    Map<String, dynamic> partnerData,
  ) {
    return PartnerAnalysis(
      partnerId: partnerId,
      partnerName: partnerData['name'] ?? '未知',
      partnerAge: partnerData['age'] ?? 0,
      partnerMBTI: partnerData['mbtiType'] ?? '未知',
      overallScore: 60,
      communicationScore: 60,
      personalityMatch: 60,
      valueAlignment: 60,
      futureCompatibility: 60,
      strengths: ['需要更多對話來評估'],
      concerns: ['對話記錄不足'],
      recommendation: '建議繼續深入交流',
    );
  }

  /// 備用對話模式分析
  static ConversationPattern _getFallbackConversationPattern(
    Map<String, dynamic> stats,
  ) {
    return ConversationPattern(
      id: _generateId(),
      conversationFlow: '需要更多數據分析',
      dominancePattern: '平衡',
      topicDiversity: '中等',
      emotionalTone: '友好',
      communicationStyle: '標準',
      patterns: ['對話剛開始'],
      suggestions: ['繼續保持交流'],
      statistics: stats,
      analyzedAt: DateTime.now(),
    );
  }

  /// 保存真心度分析結果
  static Future<void> _saveSincerityAnalysis(
    String chatId,
    String partnerId,
    SincerityAnalysis analysis,
  ) async {
    try {
      await _firestore.collection('conversation_analysis').add({
        'type': 'sincerity',
        'chatId': chatId,
        'partnerId': partnerId,
        'userId': _auth.currentUser?.uid,
        'analysis': analysis.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('保存真心度分析失敗: $e');
    }
  }

  /// 保存伴侶比較結果
  static Future<void> _savePartnerComparison(PartnerComparison comparison) async {
    try {
      await _firestore.collection('partner_comparisons').add({
        'userId': comparison.userId,
        'comparison': comparison.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('保存伴侶比較失敗: $e');
    }
  }

  /// 保存對話模式分析
  static Future<void> _saveConversationPattern(
    String chatId,
    String partnerId,
    ConversationPattern pattern,
  ) async {
    try {
      await _firestore.collection('conversation_patterns').add({
        'chatId': chatId,
        'partnerId': partnerId,
        'userId': _auth.currentUser?.uid,
        'pattern': pattern.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('保存對話模式分析失敗: $e');
    }
  }

  /// 獲取歷史分析記錄
  static Future<List<Map<String, dynamic>>> getAnalysisHistory({
    String? type,
    int limit = 10,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      Query query = _firestore
          .collection('conversation_analysis')
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      print('獲取分析歷史失敗: $e');
      return [];
    }
  }

  /// 輔助方法
  static String _generateId() => _firestore.collection('temp').doc().id;
  
  static String _generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }
}

/// 真心度分析結果
class SincerityAnalysis {
  final String id;
  final String partnerId;
  final int sincerityScore;
  final String responseQuality;
  final String emotionalDepth;
  final String consistency;
  final List<String> redFlags;
  final List<String> positiveSignals;
  final String overallAssessment;
  final List<String> recommendations;
  final DateTime analyzedAt;

  SincerityAnalysis({
    required this.id,
    required this.partnerId,
    required this.sincerityScore,
    required this.responseQuality,
    required this.emotionalDepth,
    required this.consistency,
    required this.redFlags,
    required this.positiveSignals,
    required this.overallAssessment,
    required this.recommendations,
    required this.analyzedAt,
  });

  factory SincerityAnalysis.fromJson(Map<String, dynamic> json, String partnerId) {
    return SincerityAnalysis(
      id: ConversationAnalysisService._generateId(),
      partnerId: partnerId,
      sincerityScore: json['sincerityScore'] ?? 50,
      responseQuality: json['responseQuality'] ?? '',
      emotionalDepth: json['emotionalDepth'] ?? '',
      consistency: json['consistency'] ?? '',
      redFlags: List<String>.from(json['redFlags'] ?? []),
      positiveSignals: List<String>.from(json['positiveSignals'] ?? []),
      overallAssessment: json['overallAssessment'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      analyzedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'sincerityScore': sincerityScore,
      'responseQuality': responseQuality,
      'emotionalDepth': emotionalDepth,
      'consistency': consistency,
      'redFlags': redFlags,
      'positiveSignals': positiveSignals,
      'overallAssessment': overallAssessment,
      'recommendations': recommendations,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
}

/// 伴侶分析結果
class PartnerAnalysis {
  final String partnerId;
  final String partnerName;
  final int partnerAge;
  final String partnerMBTI;
  final double overallScore;
  final double communicationScore;
  final double personalityMatch;
  final double valueAlignment;
  final double futureCompatibility;
  final List<String> strengths;
  final List<String> concerns;
  final String recommendation;

  PartnerAnalysis({
    required this.partnerId,
    required this.partnerName,
    required this.partnerAge,
    required this.partnerMBTI,
    required this.overallScore,
    required this.communicationScore,
    required this.personalityMatch,
    required this.valueAlignment,
    required this.futureCompatibility,
    required this.strengths,
    required this.concerns,
    required this.recommendation,
  });

  factory PartnerAnalysis.fromJson(
    Map<String, dynamic> json,
    String partnerId,
    Map<String, dynamic> partnerData,
  ) {
    return PartnerAnalysis(
      partnerId: partnerId,
      partnerName: partnerData['name'] ?? '未知',
      partnerAge: partnerData['age'] ?? 0,
      partnerMBTI: partnerData['mbtiType'] ?? '未知',
      overallScore: (json['overallScore'] ?? 50).toDouble(),
      communicationScore: (json['communicationScore'] ?? 50).toDouble(),
      personalityMatch: (json['personalityMatch'] ?? 50).toDouble(),
      valueAlignment: (json['valueAlignment'] ?? 50).toDouble(),
      futureCompatibility: (json['futureCompatibility'] ?? 50).toDouble(),
      strengths: List<String>.from(json['strengths'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerAge': partnerAge,
      'partnerMBTI': partnerMBTI,
      'overallScore': overallScore,
      'communicationScore': communicationScore,
      'personalityMatch': personalityMatch,
      'valueAlignment': valueAlignment,
      'futureCompatibility': futureCompatibility,
      'strengths': strengths,
      'concerns': concerns,
      'recommendation': recommendation,
    };
  }
}

/// 伴侶比較結果
class PartnerComparison {
  final String id;
  final String userId;
  final List<PartnerAnalysis> partners;
  final PartnerAnalysis topRecommendation;
  final DateTime analysisDate;
  final List<String> insights;

  PartnerComparison({
    required this.id,
    required this.userId,
    required this.partners,
    required this.topRecommendation,
    required this.analysisDate,
    required this.insights,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partners': partners.map((p) => p.toJson()).toList(),
      'topRecommendation': topRecommendation.toJson(),
      'analysisDate': analysisDate.toIso8601String(),
      'insights': insights,
    };
  }
}

/// 對話模式分析
class ConversationPattern {
  final String id;
  final String conversationFlow;
  final String dominancePattern;
  final String topicDiversity;
  final String emotionalTone;
  final String communicationStyle;
  final List<String> patterns;
  final List<String> suggestions;
  final Map<String, dynamic> statistics;
  final DateTime analyzedAt;

  ConversationPattern({
    required this.id,
    required this.conversationFlow,
    required this.dominancePattern,
    required this.topicDiversity,
    required this.emotionalTone,
    required this.communicationStyle,
    required this.patterns,
    required this.suggestions,
    required this.statistics,
    required this.analyzedAt,
  });

  factory ConversationPattern.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> stats,
  ) {
    return ConversationPattern(
      id: ConversationAnalysisService._generateId(),
      conversationFlow: json['conversationFlow'] ?? '',
      dominancePattern: json['dominancePattern'] ?? '',
      topicDiversity: json['topicDiversity'] ?? '',
      emotionalTone: json['emotionalTone'] ?? '',
      communicationStyle: json['communicationStyle'] ?? '',
      patterns: List<String>.from(json['patterns'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      statistics: stats,
      analyzedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationFlow': conversationFlow,
      'dominancePattern': dominancePattern,
      'topicDiversity': topicDiversity,
      'emotionalTone': emotionalTone,
      'communicationStyle': communicationStyle,
      'patterns': patterns,
      'suggestions': suggestions,
      'statistics': statistics,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
} 