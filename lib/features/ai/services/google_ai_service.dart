import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


class GoogleAIService {
  static const String _geminiApiKey = 'AIzaSyDjLnHcNBOEoGvnzQGzUCLknoWu9RRsvbY';
  static const String _visionApiKey = 'AIzaSyDjLnHcNBOEoGvnzQGzUCLknoWu9RRsvbY';
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // 使用 Gemini Pro 生成愛情建議
  static Future<String> generateLoveAdviceWithGemini({
    required String situation,
    required String userMBTI,
    required String partnerMBTI,
    required String category,
  }) async {
    try {
      final prompt = '''
你是一位專業的愛情顧問，專門為香港用戶提供戀愛建議。

情況描述：$situation
用戶 MBTI：$userMBTI
伴侶 MBTI：$partnerMBTI
諮詢類別：$category

請根據以下要求提供建議：
1. 具體的行動建議（至少3個）
2. 溝通技巧和策略
3. 需要注意的事項
4. 預期的結果和時間框架

請用繁體中文回答，語氣溫暖專業，並考慮香港的文化背景。
''';

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
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        
        // 保存到 Firebase
        await _saveLoveAdviceToFirebase(
          situation: situation,
          advice: content,
          userMBTI: userMBTI,
          partnerMBTI: partnerMBTI,
          category: category,
        );
        
        return content;
      } else {
        throw Exception('Gemini API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('生成愛情建議失敗: $e');
      return _getFallbackAdvice(category);
    }
  }

  // 使用 Gemini Pro 生成破冰話題
  static Future<List<String>> generateIcebreakersWithGemini({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required int count,
  }) async {
    try {
      final prompt = '''
為兩個香港用戶生成 $count 個個性化破冰話題：

用戶 A MBTI：$userMBTI
用戶 B MBTI：$partnerMBTI
共同興趣：${commonInterests.join('、')}

要求：
1. 話題要自然有趣，適合線上聊天
2. 符合香港文化背景和生活方式
3. 能促進深度交流和了解
4. 避免敏感或爭議性話題
5. 考慮兩人的性格特點

請只返回話題列表，每行一個話題，不要編號。
''';

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
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 512,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        final topics = content.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .where((line) => line.isNotEmpty)
            .toList();

        // 保存到 Firebase
        await _saveIcebreakersToFirebase(
          userMBTI: userMBTI,
          partnerMBTI: partnerMBTI,
          commonInterests: commonInterests,
          topics: topics,
        );

        return topics.take(count).toList();
      } else {
        throw Exception('Gemini API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('生成破冰話題失敗: $e');
      return _getFallbackIcebreakers(commonInterests, count);
    }
  }

  // 使用 Gemini Pro 生成約會建議
  static Future<Map<String, dynamic>> generateDateIdeaWithGemini({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required int budget,
    required String location,
  }) async {
    try {
      final prompt = '''
為一對香港情侶生成約會建議：

用戶 A MBTI：$userMBTI
用戶 B MBTI：$partnerMBTI
共同興趣：${commonInterests.join('、')}
預算：HK\$$budget
地點：$location

請提供一個詳細的約會建議，包含：
1. 約會標題
2. 詳細描述（為什麼適合這對情侶）
3. 具體地點建議（香港實際地點）
4. 預計花費
5. 建議時長
6. 活動流程安排
7. 注意事項

請用 JSON 格式回答，確保所有字段都有值。
''';

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
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        try {
          // 嘗試解析 JSON
          final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
          if (jsonMatch != null) {
            final jsonString = jsonMatch.group(0)!;
            final dateIdea = jsonDecode(jsonString) as Map<String, dynamic>;
            
            // 保存到 Firebase
            await _saveDateIdeaToFirebase(
              userMBTI: userMBTI,
              partnerMBTI: partnerMBTI,
              commonInterests: commonInterests,
              budget: budget,
              location: location,
              dateIdea: dateIdea,
            );
            
            return dateIdea;
          }
        } catch (e) {
          print('JSON 解析失敗: $e');
        }
        
        // 如果 JSON 解析失敗，返回備用建議
        return _getFallbackDateIdea(budget, location);
      } else {
        throw Exception('Gemini API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('生成約會建議失敗: $e');
      return _getFallbackDateIdea(budget, location);
    }
  }

  // 使用 Google Vision API 分析照片
  static Future<Map<String, dynamic>> analyzePhotoWithVision(
    String imageBase64,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_visionApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': imageBase64},
              'features': [
                {'type': 'FACE_DETECTION', 'maxResults': 10},
                {'type': 'SAFE_SEARCH_DETECTION'},
                {'type': 'IMAGE_PROPERTIES'},
                {'type': 'LABEL_DETECTION', 'maxResults': 10},
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analysisResult = _processVisionResponse(data);
        
        // 保存分析結果到 Firebase
        await _savePhotoAnalysisToFirebase(analysisResult);
        
        return analysisResult;
      } else {
        throw Exception('Vision API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('照片分析失敗: $e');
      return _getFallbackPhotoAnalysis();
    }
  }

  // 處理 Vision API 回應
  static Map<String, dynamic> _processVisionResponse(Map<String, dynamic> data) {
    final responses = data['responses'] as List;
    if (responses.isEmpty) return _getFallbackPhotoAnalysis();

    final response = responses[0] as Map<String, dynamic>;
    
    // 人臉檢測
    final faceAnnotations = response['faceAnnotations'] as List? ?? [];
    final hasFace = faceAnnotations.isNotEmpty;
    final faceCount = faceAnnotations.length;

    // 安全搜索檢測
    final safeSearch = response['safeSearchAnnotation'] as Map<String, dynamic>? ?? {};
    final isAppropriate = _checkSafeSearchResults(safeSearch);

    // 圖片屬性
    final imageProperties = response['imagePropertiesAnnotation'] as Map<String, dynamic>? ?? {};
    final qualityScore = _calculateImageQuality(imageProperties);

    // 標籤檢測
    final labelAnnotations = response['labelAnnotations'] as List? ?? [];
    final labels = labelAnnotations.map((label) => label['description']).toList();

    // 計算總體信心度
    double confidence = 0.5;
    final factors = <String>[];

    if (hasFace) {
      confidence += 0.3;
      factors.add('檢測到人臉');
      
      if (faceCount == 1) {
        confidence += 0.1;
        factors.add('單人照片');
      } else {
        factors.add('檢測到 $faceCount 個人臉');
      }
    }

    if (isAppropriate) {
      confidence += 0.3;
      factors.add('內容適當');
    } else {
      factors.add('內容可能不適當');
    }

    if (qualityScore > 0.7) {
      confidence += 0.2;
      factors.add('照片質量良好');
    }

    return {
      'confidence': confidence.clamp(0.0, 1.0),
      'hasFace': hasFace,
      'faceCount': faceCount,
      'isAppropriate': isAppropriate,
      'qualityScore': qualityScore,
      'labels': labels,
      'factors': factors,
      'safeSearch': safeSearch,
      'analyzedAt': DateTime.now().toIso8601String(),
    };
  }

  // 檢查安全搜索結果
  static bool _checkSafeSearchResults(Map<String, dynamic> safeSearch) {
    final adult = safeSearch['adult'] ?? 'UNKNOWN';
    final violence = safeSearch['violence'] ?? 'UNKNOWN';
    final racy = safeSearch['racy'] ?? 'UNKNOWN';

    final inappropriateValues = ['LIKELY', 'VERY_LIKELY'];
    
    return !inappropriateValues.contains(adult) &&
           !inappropriateValues.contains(violence) &&
           !inappropriateValues.contains(racy);
  }

  // 計算圖片質量
  static double _calculateImageQuality(Map<String, dynamic> imageProperties) {
    final dominantColors = imageProperties['dominantColors'] as Map<String, dynamic>? ?? {};
    final colors = dominantColors['colors'] as List? ?? [];
    
    if (colors.isEmpty) return 0.5;
    
    final colorCount = colors.length;
    return (colorCount / 10).clamp(0.0, 1.0);
  }

  // 保存愛情建議到 Firebase
  static Future<void> _saveLoveAdviceToFirebase({
    required String situation,
    required String advice,
    required String userMBTI,
    required String partnerMBTI,
    required String category,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('ai_love_advice').add({
        'userId': userId,
        'situation': situation,
        'advice': advice,
        'userMBTI': userMBTI,
        'partnerMBTI': partnerMBTI,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'gemini-pro',
      });
    } catch (e) {
      print('保存愛情建議失敗: $e');
    }
  }

  // 保存破冰話題到 Firebase
  static Future<void> _saveIcebreakersToFirebase({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required List<String> topics,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('ai_icebreakers').add({
        'userId': userId,
        'userMBTI': userMBTI,
        'partnerMBTI': partnerMBTI,
        'commonInterests': commonInterests,
        'topics': topics,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'gemini-pro',
      });
    } catch (e) {
      print('保存破冰話題失敗: $e');
    }
  }

  // 保存約會建議到 Firebase
  static Future<void> _saveDateIdeaToFirebase({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required int budget,
    required String location,
    required Map<String, dynamic> dateIdea,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('ai_date_ideas').add({
        'userId': userId,
        'userMBTI': userMBTI,
        'partnerMBTI': partnerMBTI,
        'commonInterests': commonInterests,
        'budget': budget,
        'location': location,
        'dateIdea': dateIdea,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'gemini-pro',
      });
    } catch (e) {
      print('保存約會建議失敗: $e');
    }
  }

  // 保存照片分析結果到 Firebase
  static Future<void> _savePhotoAnalysisToFirebase(
    Map<String, dynamic> analysisResult,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('ai_photo_analysis').add({
        'userId': userId,
        'analysisResult': analysisResult,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'google-vision',
      });
    } catch (e) {
      print('保存照片分析失敗: $e');
    }
  }

  // 從 Firebase 獲取歷史愛情建議
  static Future<List<Map<String, dynamic>>> getLoveAdviceHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _firestore
          .collection('ai_love_advice')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('獲取愛情建議歷史失敗: $e');
      return [];
    }
  }

  // 從 Firebase 獲取歷史約會建議
  static Future<List<Map<String, dynamic>>> getDateIdeasHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _firestore
          .collection('ai_date_ideas')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('獲取約會建議歷史失敗: $e');
      return [];
    }
  }

  // 備用愛情建議
  static String _getFallbackAdvice(String category) {
    final adviceMap = {
      'communication': '''
溝通是關係的基石。建議你：

1. **主動傾聽**：給對方充分表達的機會，不要急於反駁。
2. **表達感受**：用「我覺得...」而不是「你總是...」來表達。
3. **選擇時機**：在雙方都冷靜的時候進行重要對話。
4. **保持耐心**：理解需要時間，不要急於求成。

記住，良好的溝通需要雙方的努力和練習。
''',
      'dating': '''
約會是增進感情的好機會。建議：

1. **選擇合適活動**：考慮雙方的興趣和舒適度。
2. **保持真實**：做真實的自己，不要刻意偽裝。
3. **專注當下**：放下手機，專心享受彼此的陪伴。
4. **創造回憶**：嘗試新的體驗，創造共同的美好回憶。

最重要的是享受過程，而不是結果。
''',
      'relationship': '''
健康的關係需要雙方的投入。建議：

1. **建立信任**：誠實透明，言行一致。
2. **保持獨立**：維持個人興趣和朋友圈。
3. **共同成長**：支持彼此的目標和夢想。
4. **處理衝突**：學會健康地解決分歧。

記住，關係是一個持續的過程，需要耐心和努力。
''',
    };

    return adviceMap[category] ?? '請保持開放的心態，真誠地對待感情。如果需要更具體的建議，請提供更多詳細信息。';
  }

  // 備用破冰話題
  static List<String> _getFallbackIcebreakers(List<String> interests, int count) {
    final defaultTopics = [
      '你最近有看什麼好看的電影或劇集嗎？',
      '你週末通常喜歡做什麼？',
      '你最喜歡香港的哪個地方？',
      '你有什麼特別的興趣愛好嗎？',
      '你最近學了什麼新技能嗎？',
      '你覺得什麼樣的人最有魅力？',
      '你有什麼想要實現的夢想嗎？',
      '你最珍惜的是什麼？',
    ];

    if (interests.isNotEmpty) {
      final interest = interests.first;
      defaultTopics.insert(0, '我看到你也喜歡$interest！你最喜歡的$interest體驗是什麼？');
    }

    return defaultTopics.take(count).toList();
  }

  // 備用約會建議
  static Map<String, dynamic> _getFallbackDateIdea(int budget, String location) {
    if (budget < 300) {
      return {
        'title': '海濱長廊漫步',
        'description': '在美麗的海景中悠閒散步，享受自然的浪漫氛圍',
        'location': '$location 海濱長廊',
        'estimatedCost': 0,
        'duration': '2小時',
        'reasoning': '免費且浪漫的選擇，美麗的環境有助於放鬆心情和深度交流',
      };
    } else if (budget < 600) {
      return {
        'title': '咖啡廳下午茶',
        'description': '在溫馨的咖啡廳享受輕鬆對話和美味點心',
        'location': '$location 特色咖啡廳',
        'estimatedCost': 200,
        'duration': '2-3小時',
        'reasoning': '舒適的環境適合深度交流，是了解彼此的完美選擇',
      };
    } else {
      return {
        'title': '精緻晚餐',
        'description': '在優雅的餐廳享用美食，創造浪漫的用餐體驗',
        'location': '$location 高級餐廳',
        'estimatedCost': 500,
        'duration': '3小時',
        'reasoning': '精緻的環境和美食能創造難忘的回憶，適合特殊場合',
      };
    }
  }

  // 備用照片分析
  static Map<String, dynamic> _getFallbackPhotoAnalysis() {
    return {
      'confidence': 0.7,
      'hasFace': true,
      'faceCount': 1,
      'isAppropriate': true,
      'qualityScore': 0.8,
      'labels': ['person', 'portrait'],
      'factors': ['基礎驗證通過'],
      'analyzedAt': DateTime.now().toIso8601String(),
    };
  }

  // 檢查 API 密鑰配置
  static bool isConfigured() {
    return _geminiApiKey.startsWith('AIza') && 
           _visionApiKey.startsWith('AIza') &&
           _geminiApiKey.length >= 35 &&
           _visionApiKey.length >= 35;
  }

  // 獲取配置狀態
  static Map<String, bool> getConfigurationStatus() {
    return {
      'gemini': _geminiApiKey.startsWith('AIza') && _geminiApiKey.length >= 35,
      'vision': _visionApiKey.startsWith('AIza') && _visionApiKey.length >= 35,
    };
  }

  // 獲取 AI 使用統計
  static Future<Map<String, dynamic>> getAIUsageStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // 獲取本月使用統計
      final adviceCount = await _firestore
          .collection('ai_love_advice')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: startOfMonth)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final dateIdeasCount = await _firestore
          .collection('ai_date_ideas')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: startOfMonth)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final icebreakersCount = await _firestore
          .collection('ai_icebreakers')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: startOfMonth)
          .get()
          .then((snapshot) => snapshot.docs.length);

      final photoAnalysisCount = await _firestore
          .collection('ai_photo_analysis')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: startOfMonth)
          .get()
          .then((snapshot) => snapshot.docs.length);

      return {
        'loveAdvice': adviceCount,
        'dateIdeas': dateIdeasCount,
        'icebreakers': icebreakersCount,
        'photoAnalysis': photoAnalysisCount,
        'totalUsage': adviceCount + dateIdeasCount + icebreakersCount + photoAnalysisCount,
        'month': '${now.year}-${now.month.toString().padLeft(2, '0')}',
      };
    } catch (e) {
      print('獲取 AI 使用統計失敗: $e');
      return {};
    }
  }
} 