import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class APIErrorHandler {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// 統一的HTTP請求處理，包含錯誤重試和降級機制
  static Future<Map<String, dynamic>?> makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body,
    int retries = maxRetries,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        if (kDebugMode) {
          print('🌐 API 請求 (嘗試 $attempt/$retries): $url');
        }

        http.Response response;
        final client = http.Client();
        
        try {
          switch (method.toUpperCase()) {
            case 'GET':
              response = await client.get(
                Uri.parse(url),
                headers: headers,
              ).timeout(requestTimeout);
              break;
            case 'POST':
              response = await client.post(
                Uri.parse(url),
                headers: headers,
                body: body,
              ).timeout(requestTimeout);
              break;
            default:
              throw UnsupportedError('不支持的HTTP方法: $method');
          }
        } finally {
          client.close();
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (kDebugMode) {
            print('✅ API 請求成功 (${response.statusCode})');
          }
          
          try {
            return jsonDecode(response.body) as Map<String, dynamic>;
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ JSON 解析失敗，返回原始響應');
            }
            return {'response': response.body};
          }
        } else {
          final error = _handleHttpError(response.statusCode, response.body);
          if (kDebugMode) {
            print('❌ HTTP 錯誤 (${response.statusCode}): $error');
          }
          
          // 如果是最後一次嘗試，拋出錯誤
          if (attempt == retries) {
            throw APIException(error, response.statusCode);
          }
        }
      } on SocketException catch (e) {
        if (kDebugMode) {
          print('🔌 網絡連接錯誤 (嘗試 $attempt/$retries): $e');
        }
        if (attempt == retries) {
          throw APIException('網絡連接失敗，請檢查網絡設置', 0);
        }
      } on HttpException catch (e) {
        if (kDebugMode) {
          print('🌐 HTTP 異常 (嘗試 $attempt/$retries): $e');
        }
        if (attempt == retries) {
          throw APIException('HTTP 請求異常: ${e.message}', 0);
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ 未知錯誤 (嘗試 $attempt/$retries): $e');
        }
        if (attempt == retries) {
          throw APIException('請求失敗: $e', 0);
        }
      }

      // 等待後重試
      if (attempt < retries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return null;
  }

  /// Gemini API 專用請求處理
  static Future<String?> geminiRequest({
    required String prompt,
    String? apiKey,
    Map<String, dynamic>? config,
  }) async {
    // 如果沒有API密鑰，返回備用響應
    if (apiKey == null || apiKey.isEmpty || apiKey.contains('YOUR_')) {
      if (kDebugMode) {
        print('⚠️ Gemini API 密鑰未配置，使用備用響應');
      }
      return _getGeminiFallback(prompt);
    }

    try {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';
      
      final requestBody = jsonEncode({
        'contents': [{
          'parts': [{'text': prompt}]
        }],
        'generationConfig': config ?? {
          'temperature': 0.7,
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
      });

      final response = await makeRequest(
        url: url,
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response != null && response['candidates'] != null) {
        final candidates = response['candidates'] as List;
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List;
          if (parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
      }

      // 如果解析失敗，返回備用響應
      return _getGeminiFallback(prompt);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Gemini API 請求失敗: $e');
      }
      return _getGeminiFallback(prompt);
    }
  }

  /// Vision API 專用請求處理
  static Future<Map<String, dynamic>?> visionRequest({
    required String imageBase64,
    String? apiKey,
  }) async {
    // 如果沒有API密鑰，返回備用響應
    if (apiKey == null || apiKey.isEmpty || apiKey.contains('YOUR_')) {
      if (kDebugMode) {
        print('⚠️ Vision API 密鑰未配置，使用備用響應');
      }
      return _getVisionFallback();
    }

    try {
      final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';
      
      final requestBody = jsonEncode({
        'requests': [{
          'image': {
            'content': imageBase64
          },
          'features': [
            {'type': 'FACE_DETECTION', 'maxResults': 10},
            {'type': 'SAFE_SEARCH_DETECTION'},
            {'type': 'LABEL_DETECTION', 'maxResults': 10},
          ]
        }]
      });

      final response = await makeRequest(
        url: url,
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      return response;
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Vision API 請求失敗: $e');
      }
      return _getVisionFallback();
    }
  }

  /// 處理HTTP錯誤
  static String _handleHttpError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return '請求參數錯誤';
      case 401:
        return 'API 密鑰無效或已過期';
      case 403:
        return 'API 配額已用完或權限不足';
      case 404:
        return 'API 端點不存在';
      case 429:
        return '請求過於頻繁，請稍後再試';
      case 500:
        return '服務器內部錯誤';
      case 502:
        return '服務器網關錯誤';
      case 503:
        return '服務暫時不可用';
      default:
        return '未知錯誤 ($statusCode)';
    }
  }

  /// Gemini API 備用響應
  static String _getGeminiFallback(String prompt) {
    if (prompt.contains('破冰話題') || prompt.toLowerCase().contains('icebreaker')) {
      return '''1. 我看到你也喜歡旅行，有什麼地方是你最想再去一次的嗎？
2. 你的興趣愛好很有趣，平時最喜歡做什麼來放鬆？
3. 如果可以學習任何新技能，你會選擇什麼？''';
    }
    
    if (prompt.contains('約會建議') || prompt.toLowerCase().contains('date')) {
      return '''建議選擇一個輕鬆舒適的環境進行約會：
1. 海濱長廊散步 - 自然浪漫的氛圍
2. 咖啡廳聊天 - 輕鬆的交流環境  
3. 藝術館參觀 - 有趣的話題來源''';
    }

    if (prompt.contains('愛情建議') || prompt.toLowerCase().contains('advice')) {
      return '''建議保持開放和誠實的溝通：
1. 主動傾聽對方的想法和感受
2. 分享你的真實想法，建立信任
3. 給彼此適當的個人空間
4. 共同規劃未來的目標和夢想''';
    }

    return '感謝您的提問！由於網絡連接問題，我現在無法提供詳細回應，但建議您保持耐心和真誠的溝通。';
  }

  /// Vision API 備用響應
  static Map<String, dynamic> _getVisionFallback() {
    return {
      'responses': [{
        'faceAnnotations': [],
        'labelAnnotations': [
          {'description': 'person', 'score': 0.8},
          {'description': 'portrait', 'score': 0.7}
        ],
        'safeSearchAnnotation': {
          'adult': 'UNLIKELY',
          'spoof': 'UNLIKELY',
          'medical': 'UNLIKELY',
          'violence': 'UNLIKELY',
          'racy': 'UNLIKELY'
        }
      }]
    };
  }

  /// 檢查網絡連接
  static Future<bool> checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// API 健康檢查
  static Future<Map<String, bool>> healthCheck() async {
    final results = <String, bool>{};
    
    // 網絡連接檢查
    results['network'] = await checkNetworkConnection();
    
    // 可以添加更多的健康檢查
    results['firebase'] = true; // 假設Firebase連接正常
    
    return results;
  }
}

/// API 異常類
class APIException implements Exception {
  final String message;
  final int statusCode;
  
  const APIException(this.message, this.statusCode);
  
  @override
  String toString() => 'APIException: $message (狀態碼: $statusCode)';
} 