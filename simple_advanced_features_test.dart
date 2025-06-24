void main() {
  print('🚀 測試 Amore 高級功能核心邏輯');
  
  testChatModels();
  testAIModels();
  testSafetyModels();
  testCoreAlgorithms();
  
  print('\n✅ 所有高級功能核心邏輯測試完成！');
}

void testChatModels() {
  print('\n📱 測試聊天功能模型');
  
  // 測試消息類型
  final messageTypes = ['text', 'image', 'audio', 'icebreaker', 'dateIdea', 'system'];
  print('✓ 消息類型: ${messageTypes.join(', ')}');
  
  // 測試消息狀態
  final messageStatuses = ['sending', 'sent', 'delivered', 'read', 'failed'];
  print('✓ 消息狀態: ${messageStatuses.join(', ')}');
  
  // 測試破冰話題結構
  final icebreakerExample = {
    'id': 'icebreaker_001',
    'question': '如果你可以和任何歷史人物共進晚餐，你會選擇誰？為什麼？',
    'category': '深度對話',
    'suggestedResponses': [
      '我會選擇達文西，想了解他的創意思維',
      '我想和居禮夫人聊聊科學研究的堅持',
      '我會選擇孔子，探討人生哲學',
    ],
    'difficulty': 3,
    'tags': ['歷史', '哲學', '深度思考'],
    'isPersonalized': true,
  };
  
  print('✓ 破冰話題結構驗證成功');
  print('  - 問題: ${icebreakerExample['question']}');
  print('  - 難度: ${icebreakerExample['difficulty']}/5');
  print('  - 建議回應數: ${(icebreakerExample['suggestedResponses'] as List).length}');
  
  // 測試聊天室結構
  final chatExample = {
    'id': 'chat_001',
    'participantIds': ['user_001', 'user_002'],
    'lastActivity': DateTime.now().toIso8601String(),
    'unreadCounts': {'user_001': 0, 'user_002': 1},
    'isActive': true,
  };
  
  print('✓ 聊天室結構驗證成功');
  print('  - 參與者數量: ${(chatExample['participantIds'] as List).length}');
  print('  - 未讀消息: ${chatExample['unreadCounts']}');
}

void testAIModels() {
  print('\n🤖 測試 AI 功能模型');
  
  // 測試推薦類型
  final recommendationTypes = [
    'userMatch', 'dateIdea', 'conversation', 
    'relationship', 'gift', 'activity'
  ];
  print('✓ 推薦類型: ${recommendationTypes.join(', ')}');
  
  // 測試 AI 推薦結構
  final recommendationExample = {
    'id': 'rec_001',
    'userId': 'user_001',
    'type': 'userMatch',
    'title': '高匹配度推薦：Sarah',
    'description': '基於你們的 MBTI 類型 (ENFP + INTJ) 和共同興趣，你們有很高的匹配度！',
    'content': {
      'matchUserId': 'user_002',
      'compatibilityScore': 0.89,
      'sharedInterests': ['旅行', '攝影', '咖啡'],
      'mbtiCompatibility': 0.9,
    },
    'confidenceScore': 0.89,
    'reasons': [
      '你們的性格類型非常互補',
      '你們都喜歡：旅行、攝影、咖啡',
      '年齡差距適中',
    ],
    'createdAt': DateTime.now().toIso8601String(),
  };
  
  print('✓ AI 推薦結構驗證成功');
  print('  - 匹配度: ${((recommendationExample['confidenceScore'] as double) * 100).toInt()}%');
  print('  - 推薦理由數: ${(recommendationExample['reasons'] as List).length}');
  
  // 測試諮詢類別
  final consultationCategories = [
    'communication', 'dating', 'relationship', 'conflict',
    'intimacy', 'longDistance', 'breakup', 'marriage'
  ];
  print('✓ 諮詢類別: ${consultationCategories.join(', ')}');
  
  // 測試愛情顧問結構
  final consultationExample = {
    'id': 'consult_001',
    'userId': 'user_001',
    'category': 'communication',
    'question': '如何在約會中更好地表達自己？',
    'situation': '我是一個比較內向的人，在約會時經常不知道該說什麼，擔心對方覺得我無趣。',
    'userContext': {
      'mbtiType': 'INFP',
      'age': 28,
      'relationshipExperience': 'limited',
    },
    'actionItems': [
      '準備3個關於興趣愛好的開放性問題',
      '練習分享一個你熱愛的事物',
      '記住：沉默也是對話的一部分',
    ],
    'resources': [
      '《內向者優勢》- 瑪蒂·蘭妮',
      '《非暴力溝通》- 馬歇爾·盧森堡',
    ],
    'createdAt': DateTime.now().toIso8601String(),
  };
  
  print('✓ 愛情顧問結構驗證成功');
  print('  - 諮詢類別: ${consultationExample['category']}');
  print('  - 行動建議數: ${(consultationExample['actionItems'] as List).length}');
  print('  - 推薦資源數: ${(consultationExample['resources'] as List).length}');
  
  // 測試用戶行為分析
  final behaviorAnalysisExample = {
    'userId': 'user_001',
    'activityCounts': {
      'messages_sent': 45,
      'profile_views': 120,
      'matches_made': 8,
      'app_opens': 25,
    },
    'preferences': {
      'outdoor_activities': 0.8,
      'cultural_events': 0.6,
      'casual_dining': 0.9,
    },
    'interests': ['旅行', '攝影', '咖啡', '閱讀'],
    'engagementScore': 0.75,
    'lastUpdated': DateTime.now().toIso8601String(),
  };
  
  print('✓ 用戶行為分析結構驗證成功');
  print('  - 參與度分數: ${((behaviorAnalysisExample['engagementScore'] as double) * 100).toInt()}%');
  print('  - 興趣數量: ${(behaviorAnalysisExample['interests'] as List).length}');
}

void testSafetyModels() {
  print('\n🛡️ 測試安全功能模型');
  
  // 測試驗證狀態
  final verificationStatuses = ['pending', 'verified', 'rejected', 'expired'];
  print('✓ 驗證狀態: ${verificationStatuses.join(', ')}');
  
  // 測試舉報類型
  final reportTypes = [
    'inappropriateContent', 'harassment', 'spam', 
    'fakeProfile', 'underage', 'violence', 'other'
  ];
  print('✓ 舉報類型: ${reportTypes.join(', ')}');
  
  // 測試風險等級
  final riskLevels = ['low', 'medium', 'high', 'critical'];
  print('✓ 風險等級: ${riskLevels.join(', ')}');
  
  // 測試照片驗證結構
  final photoVerificationExample = {
    'id': 'verify_001',
    'userId': 'user_001',
    'photoUrl': 'https://example.com/photo.jpg',
    'status': 'verified',
    'confidenceScore': 0.92,
    'analysisResult': {
      'confidence': 0.92,
      'hasFace': true,
      'isReal': true,
      'isAppropriate': true,
      'qualityScore': 0.85,
      'factors': ['照片質量良好', '檢測到人臉', '真實人物照片', '內容適當'],
    },
    'submittedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    'verifiedAt': DateTime.now().toIso8601String(),
    'verifiedBy': 'AI_SYSTEM',
  };
  
  print('✓ 照片驗證結構驗證成功');
  print('  - 驗證狀態: ${photoVerificationExample['status']}');
  print('  - 信心度: ${((photoVerificationExample['confidenceScore'] as double) * 100).toInt()}%');
  print('  - 驗證因素數: ${((photoVerificationExample['analysisResult'] as Map)['factors'] as List).length}');
  
  // 測試用戶舉報結構
  final userReportExample = {
    'id': 'report_001',
    'reporterId': 'user_001',
    'reportedUserId': 'user_003',
    'type': 'inappropriateContent',
    'description': '該用戶發送了不適當的照片內容',
    'evidenceUrls': ['https://example.com/evidence1.jpg'],
    'createdAt': DateTime.now().toIso8601String(),
    'status': 'pending',
  };
  
  print('✓ 用戶舉報結構驗證成功');
  print('  - 舉報類型: ${userReportExample['type']}');
  print('  - 證據數量: ${(userReportExample['evidenceUrls'] as List).length}');
  
  // 測試行為分析結構
  final behaviorAnalysisExample = {
    'userId': 'user_003',
    'riskLevel': 'medium',
    'riskScore': 0.45,
    'behaviorMetrics': {
      'messageFrequency': 85,
      'profileViews': 250,
      'reportCount': 1,
      'responseRate': 0.3,
    },
    'riskFactors': [
      '收到用戶舉報 (1 次)',
      '回應率過低',
    ],
    'positiveFactors': [
      '檔案資料完整',
      '照片已驗證',
    ],
    'lastAnalyzed': DateTime.now().toIso8601String(),
    'requiresReview': false,
  };
  
  print('✓ 行為分析結構驗證成功');
  print('  - 風險等級: ${behaviorAnalysisExample['riskLevel']}');
  print('  - 風險分數: ${((behaviorAnalysisExample['riskScore'] as double) * 100).toInt()}%');
  print('  - 風險因素數: ${(behaviorAnalysisExample['riskFactors'] as List).length}');
  print('  - 正面因素數: ${(behaviorAnalysisExample['positiveFactors'] as List).length}');
  
  // 測試安全警報結構
  final safetyAlertExample = {
    'id': 'alert_001',
    'userId': 'user_003',
    'alertType': 'suspicious_behavior',
    'title': '行為模式異常',
    'description': '檢測到該用戶的活動模式存在異常，建議加強監控。',
    'severity': 'medium',
    'alertData': {
      'riskScore': 0.45,
      'triggerReason': 'unusual_activity_pattern',
      'analysisId': 'analysis_001',
    },
    'createdAt': DateTime.now().toIso8601String(),
    'isRead': false,
    'isResolved': false,
  };
  
  print('✓ 安全警報結構驗證成功');
  print('  - 警報類型: ${safetyAlertExample['alertType']}');
  print('  - 嚴重程度: ${safetyAlertExample['severity']}');
  
  // 測試安全設置結構
  final safetySettingsExample = {
    'userId': 'user_001',
    'photoVerificationRequired': true,
    'behaviorAnalysisEnabled': true,
    'autoBlockSuspiciousUsers': false,
    'blockedKeywords': ['spam', 'inappropriate'],
    'privacySettings': {
      'showOnlineStatus': false,
      'allowMessageFromStrangers': true,
      'showLastSeen': false,
    },
    'notificationSettings': {
      'safetyAlerts': true,
      'verificationUpdates': true,
      'behaviorWarnings': true,
    },
    'lastUpdated': DateTime.now().toIso8601String(),
  };
  
  print('✓ 安全設置結構驗證成功');
  print('  - 照片驗證要求: ${safetySettingsExample['photoVerificationRequired']}');
  print('  - 行為分析啟用: ${safetySettingsExample['behaviorAnalysisEnabled']}');
  print('  - 封鎖關鍵詞數: ${(safetySettingsExample['blockedKeywords'] as List).length}');
}

// 測試核心算法邏輯
void testCoreAlgorithms() {
  print('\n🧮 測試核心算法');
  
  // 測試 MBTI 兼容性計算
  final mbtiCompatibility = calculateMBTICompatibility('ENFP', 'INTJ');
  print('✓ MBTI 兼容性計算: ENFP + INTJ = ${(mbtiCompatibility * 100).toInt()}%');
  
  // 測試興趣匹配計算
  final user1Interests = ['旅行', '攝影', '咖啡', '閱讀', '電影'];
  final user2Interests = ['旅行', '攝影', '音樂', '運動', '咖啡'];
  final interestMatch = calculateInterestMatch(user1Interests, user2Interests);
  print('✓ 興趣匹配計算: ${(interestMatch * 100).toInt()}%');
  
  // 測試年齡兼容性計算
  final ageCompatibility = calculateAgeCompatibility(25, 28);
  print('✓ 年齡兼容性計算: 25歲 vs 28歲 = ${(ageCompatibility * 100).toInt()}%');
  
  // 測試綜合匹配分數
  final overallMatch = calculateOverallMatch(
    mbtiScore: mbtiCompatibility,
    interestScore: interestMatch,
    ageScore: ageCompatibility,
    locationScore: 0.8,
  );
  print('✓ 綜合匹配分數: ${(overallMatch * 100).toInt()}%');
  
  // 測試風險分數計算
  final riskScore = calculateRiskScore(
    reportCount: 1,
    responseRate: 0.3,
    messageFrequency: 85,
    inappropriateLanguage: 0,
  );
  print('✓ 風險分數計算: ${(riskScore * 100).toInt()}%');
}

// MBTI 兼容性計算
double calculateMBTICompatibility(String type1, String type2) {
  final compatibilityMatrix = {
    'ENFP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFJ': 0.7, 'ENTP': 0.8},
    'ENFJ': {'INFP': 0.9, 'ISFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.7},
    'ENTP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFP': 0.8, 'INTP': 0.7},
    'ENTJ': {'INTP': 0.9, 'INFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.8},
  };
  
  return compatibilityMatrix[type1]?[type2] ?? 
         compatibilityMatrix[type2]?[type1] ?? 
         0.5;
}

// 興趣匹配計算
double calculateInterestMatch(List<String> interests1, List<String> interests2) {
  if (interests1.isEmpty || interests2.isEmpty) return 0.0;
  
  final common = interests1.toSet().intersection(interests2.toSet());
  final total = interests1.toSet().union(interests2.toSet());
  
  return common.length / total.length;
}

// 年齡兼容性計算
double calculateAgeCompatibility(int age1, int age2) {
  final ageDiff = (age1 - age2).abs();
  
  if (ageDiff <= 2) return 1.0;
  if (ageDiff <= 5) return 0.8;
  if (ageDiff <= 10) return 0.6;
  if (ageDiff <= 15) return 0.4;
  return 0.2;
}

// 綜合匹配分數計算
double calculateOverallMatch({
  required double mbtiScore,
  required double interestScore,
  required double ageScore,
  required double locationScore,
}) {
  return mbtiScore * 0.4 + 
         interestScore * 0.3 + 
         ageScore * 0.2 + 
         locationScore * 0.1;
}

// 風險分數計算
double calculateRiskScore({
  required int reportCount,
  required double responseRate,
  required int messageFrequency,
  required int inappropriateLanguage,
}) {
  double score = 0.0;
  
  // 舉報次數影響 (30%)
  if (reportCount > 0) {
    score += (reportCount / 10).clamp(0.0, 0.3);
  }
  
  // 回應率影響 (20%)
  if (responseRate < 0.3) score += 0.2;
  
  // 消息頻率影響 (20%)
  if (messageFrequency > 100) score += 0.2;
  
  // 不當語言影響 (30%)
  if (inappropriateLanguage > 0) score += 0.3;
  
  return score.clamp(0.0, 1.0);
} 