import 'dart:convert';
import 'package:http/http.dart' as http;
import 'google_ai_service.dart';

class AITestService {
  // 測試 Gemini API 連接
  static Future<Map<String, dynamic>> testGeminiConnection() async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyDjLnHcNBOEoGvnzQGzUCLknoWu9RRsvbY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Hello, this is a test message. Please respond with "API connection successful!"'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 50,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'No response';
        
        return {
          'success': true,
          'statusCode': response.statusCode,
          'response': content,
          'message': 'Gemini API 連接成功',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
          'message': 'Gemini API 連接失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Gemini API 測試異常',
      };
    }
  }

  // 測試 Vision API 連接
  static Future<Map<String, dynamic>> testVisionConnection() async {
    try {
      // 使用一個簡單的測試圖片 (1x1 像素的透明 PNG，base64 編碼)
      const testImageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
      
      final response = await http.post(
        Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDjLnHcNBOEoGvnzQGzUCLknoWu9RRsvbY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': testImageBase64},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': 1},
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return {
          'success': true,
          'statusCode': response.statusCode,
          'response': data,
          'message': 'Vision API 連接成功',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body,
          'message': 'Vision API 連接失敗',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Vision API 測試異常',
      };
    }
  }

  // 測試所有 API 連接
  static Future<Map<String, dynamic>> testAllConnections() async {
    final results = <String, dynamic>{};
    
    print('🧪 開始測試 AI API 連接...');
    
    // 測試 Gemini
    print('📡 測試 Gemini API...');
    final geminiResult = await testGeminiConnection();
    results['gemini'] = geminiResult;
    
    if (geminiResult['success']) {
      print('✅ Gemini API 測試成功');
    } else {
      print('❌ Gemini API 測試失敗: ${geminiResult['message']}');
    }
    
    // 測試 Vision
    print('📡 測試 Vision API...');
    final visionResult = await testVisionConnection();
    results['vision'] = visionResult;
    
    if (visionResult['success']) {
      print('✅ Vision API 測試成功');
    } else {
      print('❌ Vision API 測試失敗: ${visionResult['message']}');
    }
    
    // 總結
    final allSuccess = geminiResult['success'] && visionResult['success'];
    results['overall'] = {
      'success': allSuccess,
      'message': allSuccess ? '所有 API 連接測試成功' : '部分 API 連接測試失敗',
    };
    
    print(allSuccess ? '🎉 所有 API 測試完成！' : '⚠️ 部分 API 測試失敗');
    
    return results;
  }

  // 生成測試愛情建議
  static Future<String> generateTestAdvice() async {
    try {
      final advice = await GoogleAIService.generateLoveAdviceWithGemini(
        situation: '這是一個測試情況',
        userMBTI: 'ENFP',
        partnerMBTI: 'INTJ',
        category: 'communication',
      );
      
      return advice;
    } catch (e) {
      return '測試失敗: $e';
    }
  }

  // 生成測試破冰話題
  static Future<List<String>> generateTestIcebreakers() async {
    try {
      final topics = await GoogleAIService.generateIcebreakersWithGemini(
        userMBTI: 'ENFP',
        partnerMBTI: 'INTJ',
        commonInterests: ['音樂', '旅行'],
        count: 3,
      );
      
      return topics;
    } catch (e) {
      return ['測試失敗: $e'];
    }
  }

  // 生成測試約會建議
  static Future<Map<String, dynamic>> generateTestDateIdea() async {
    try {
      final dateIdea = await GoogleAIService.generateDateIdeaWithGemini(
        userMBTI: 'ENFP',
        partnerMBTI: 'INTJ',
        commonInterests: ['咖啡', '藝術'],
        budget: 300,
        location: '香港中環',
      );
      
      return dateIdea;
    } catch (e) {
      return {
        'title': '測試失敗',
        'description': e.toString(),
        'location': '未知',
        'estimatedCost': 0,
        'duration': '0分鐘',
      };
    }
  }
} 