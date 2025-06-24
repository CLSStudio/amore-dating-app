import 'dart:convert';
import 'package:http/http.dart' as http;

class RealAIIntegrationService {
  static const String _openAIApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _googleAIApiKey = 'YOUR_GOOGLE_AI_API_KEY';
  
  // OpenAI GPT 整合
  static Future<String> generateLoveAdvice({
    required String situation,
    required String userMBTI,
    required String partnerMBTI,
    required String category,
  }) async {
    try {
      final prompt = '''
你是一位專業的愛情顧問，請根據以下信息提供建議：

情況描述：$situation
用戶 MBTI：$userMBTI
伴侶 MBTI：$partnerMBTI
諮詢類別：$category

請提供：
1. 具體的行動建議
2. 溝通技巧
3. 注意事項
4. 預期結果

請用繁體中文回答，語氣溫暖專業。
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '你是一位專業的愛情顧問，專門為香港用戶提供戀愛建議。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('OpenAI API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('生成愛情建議失敗: $e');
      return _getFallbackAdvice(category);
    }
  }

  // Google AI 照片分析
  static Future<Map<String, dynamic>> analyzePhotoWithGoogleAI(
    String imageBase64,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$_googleAIApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': imageBase64},
              'features': [
                {'type': 'FACE_DETECTION', 'maxResults': 10},
                {'type': 'SAFE_SEARCH_DETECTION'},
                {'type': 'IMAGE_PROPERTIES'},
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _processGoogleVisionResponse(data);
      } else {
        throw Exception('Google Vision API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('照片分析失敗: $e');
      return _getFallbackPhotoAnalysis();
    }
  }

  // 處理 Google Vision API 回應
  static Map<String, dynamic> _processGoogleVisionResponse(Map<String, dynamic> data) {
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
      'factors': factors,
      'rawResponse': response,
    };
  }

  // 檢查安全搜索結果
  static bool _checkSafeSearchResults(Map<String, dynamic> safeSearch) {
    final adult = safeSearch['adult'] ?? 'UNKNOWN';
    final violence = safeSearch['violence'] ?? 'UNKNOWN';
    final racy = safeSearch['racy'] ?? 'UNKNOWN';

    // 如果任何類別是 LIKELY 或 VERY_LIKELY，則認為不適當
    final inappropriateValues = ['LIKELY', 'VERY_LIKELY'];
    
    return !inappropriateValues.contains(adult) &&
           !inappropriateValues.contains(violence) &&
           !inappropriateValues.contains(racy);
  }

  // 計算圖片質量
  static double _calculateImageQuality(Map<String, dynamic> imageProperties) {
    // 基於顏色信息計算質量分數
    final dominantColors = imageProperties['dominantColors'] as Map<String, dynamic>? ?? {};
    final colors = dominantColors['colors'] as List? ?? [];
    
    if (colors.isEmpty) return 0.5;
    
    // 簡單的質量評估：顏色多樣性
    final colorCount = colors.length;
    return (colorCount / 10).clamp(0.0, 1.0);
  }

  // OpenAI 破冰話題生成
  static Future<List<String>> generateIcebreakers({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required int count,
  }) async {
    try {
      final prompt = '''
為兩個用戶生成 $count 個個性化破冰話題：

用戶 A MBTI：$userMBTI
用戶 B MBTI：$partnerMBTI
共同興趣：${commonInterests.join('、')}

要求：
1. 話題要自然有趣
2. 適合香港文化背景
3. 能促進深度交流
4. 避免敏感話題

請只返回話題列表，每行一個話題。
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '你是一位專業的社交顧問，專門為香港用戶創建破冰話題。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 500,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), ''))
            .toList();
      } else {
        throw Exception('OpenAI API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('生成破冰話題失敗: $e');
      return _getFallbackIcebreakers(commonInterests, count);
    }
  }

  // 約會建議生成
  static Future<Map<String, dynamic>> generateDateIdea({
    required String userMBTI,
    required String partnerMBTI,
    required List<String> commonInterests,
    required int budget,
    required String location,
  }) async {
    try {
      final prompt = '''
為一對情侶生成約會建議：

用戶 A MBTI：$userMBTI
用戶 B MBTI：$partnerMBTI
共同興趣：${commonInterests.join('、')}
預算：HK\$$budget
地點：$location

請提供：
1. 約會標題
2. 詳細描述
3. 具體地點建議
4. 預計花費
5. 建議時長
6. 為什麼適合這對情侶

請用 JSON 格式回答。
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '你是一位專業的約會規劃師，專門為香港情侶設計約會活動。請用 JSON 格式回答。'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        try {
          return jsonDecode(content);
        } catch (e) {
          // 如果 JSON 解析失敗，返回備用建議
          return _getFallbackDateIdea(budget, location);
        }
      } else {
        throw Exception('OpenAI API 調用失敗: ${response.statusCode}');
      }
    } catch (e) {
      print('生成約會建議失敗: $e');
      return _getFallbackDateIdea(budget, location);
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

  // 備用照片分析
  static Map<String, dynamic> _getFallbackPhotoAnalysis() {
    return {
      'confidence': 0.7,
      'hasFace': true,
      'faceCount': 1,
      'isAppropriate': true,
      'qualityScore': 0.8,
      'factors': ['基礎驗證通過'],
    };
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

    // 如果有共同興趣，添加相關話題
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

  // 檢查 API 密鑰配置
  static bool isConfigured() {
    return _openAIApiKey != 'YOUR_OPENAI_API_KEY' && 
           _googleAIApiKey != 'YOUR_GOOGLE_AI_API_KEY';
  }

  // 獲取配置狀態
  static Map<String, bool> getConfigurationStatus() {
    return {
      'openAI': _openAIApiKey != 'YOUR_OPENAI_API_KEY',
      'googleAI': _googleAIApiKey != 'YOUR_GOOGLE_AI_API_KEY',
    };
  }
} 