import 'package:flutter/material.dart';

class MBTICompatibility {
  // MBTI 兼容性矩陣 (0-100 分)
  static const Map<String, Map<String, int>> compatibilityMatrix = {
    'INTJ': {
      'ENFP': 95, 'ENTP': 90, 'INFP': 85, 'INTP': 80,
      'ENFJ': 75, 'ENTJ': 70, 'INFJ': 65, 'INTJ': 60,
    },
    'INTP': {
      'ENFJ': 95, 'ENTJ': 90, 'INFJ': 85, 'INTJ': 80,
      'ENFP': 75, 'ENTP': 70, 'INFP': 65, 'INTP': 60,
    },
    'ENTJ': {
      'INFP': 95, 'INTP': 90, 'ENFP': 85, 'ENTP': 80,
      'INFJ': 75, 'INTJ': 70, 'ENFJ': 65, 'ENTJ': 60,
    },
    'ENTP': {
      'INFJ': 95, 'INTJ': 90, 'ENFJ': 85, 'ENTJ': 80,
      'INFP': 75, 'INTP': 70, 'ENFP': 65, 'ENTP': 60,
    },
    'INFJ': {
      'ENTP': 95, 'ENFP': 90, 'INTP': 85, 'INTJ': 80,
      'ENTJ': 75, 'ENFJ': 70, 'INFP': 65, 'INFJ': 60,
    },
    'INFP': {
      'ENTJ': 95, 'ENFJ': 90, 'INTJ': 85, 'ENTP': 80,
      'INTP': 75, 'INFJ': 70, 'ENFP': 65, 'INFP': 60,
    },
    'ENFJ': {
      'INFP': 95, 'INTP': 90, 'ISFP': 85, 'ISTP': 80,
      'INTJ': 75, 'ENTJ': 70, 'INFJ': 65, 'ENFJ': 60,
    },
    'ENFP': {
      'INTJ': 95, 'INFJ': 90, 'ENTP': 85, 'INTP': 80,
      'ENTJ': 75, 'ENFJ': 70, 'INFP': 65, 'ENFP': 60,
    },
    'ISTJ': {
      'ESFP': 95, 'ESTP': 90, 'ISFP': 85, 'ISTP': 80,
      'ENFP': 75, 'ENTP': 70, 'INFP': 65, 'INTP': 60,
    },
    'ISFJ': {
      'ESFP': 95, 'ESTP': 90, 'ENTP': 85, 'ENFP': 80,
      'INFP': 75, 'INTP': 70, 'ISFP': 65, 'ISTP': 60,
    },
    'ESTJ': {
      'ISFP': 95, 'INFP': 90, 'ISTP': 85, 'INTP': 80,
      'ESFP': 75, 'ENFP': 70, 'ESTP': 65, 'ENTP': 60,
    },
    'ESFJ': {
      'ISFP': 95, 'ISTP': 90, 'INFP': 85, 'INTP': 80,
      'ISFJ': 75, 'ISTJ': 70, 'ESFP': 65, 'ESTP': 60,
    },
    'ISTP': {
      'ESFJ': 95, 'ENFJ': 90, 'ESTJ': 85, 'ENTJ': 80,
      'ISFJ': 75, 'INFJ': 70, 'ESFP': 65, 'ENFP': 60,
    },
    'ISFP': {
      'ESFJ': 95, 'ESTJ': 90, 'ENFJ': 85, 'ENTJ': 80,
      'ESFP': 75, 'ESTP': 70, 'ISFJ': 65, 'ISTJ': 60,
    },
    'ESTP': {
      'ISFJ': 95, 'ISTJ': 90, 'INFJ': 85, 'INTJ': 80,
      'ESFJ': 75, 'ESTJ': 70, 'ISFP': 65, 'ISTP': 60,
    },
    'ESFP': {
      'ISFJ': 95, 'ISTJ': 90, 'INFJ': 85, 'INTJ': 80,
      'ESFJ': 75, 'ESTJ': 70, 'ISFP': 65, 'ISTP': 60,
    },
  };

  // 獲取兼容性分數
  static int getCompatibilityScore(String type1, String type2) {
    return compatibilityMatrix[type1]?[type2] ?? 50;
  }

  // 獲取兼容性等級
  static String getCompatibilityLevel(int score) {
    if (score >= 90) return '完美配對';
    if (score >= 80) return '非常匹配';
    if (score >= 70) return '良好匹配';
    if (score >= 60) return '一般匹配';
    if (score >= 50) return '需要努力';
    return '具有挑戰';
  }

  // 獲取兼容性顏色
  static Color getCompatibilityColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.amber;
    if (score >= 50) return Colors.deepOrange;
    return Colors.red;
  }

  // 獲取詳細的兼容性分析
  static Map<String, dynamic> getDetailedCompatibilityAnalysis(String type1, String type2) {
    final score = getCompatibilityScore(type1, type2);
    final level = getCompatibilityLevel(score);
    final color = getCompatibilityColor(score);

    Map<String, List<String>> analysisData = _getAnalysisData(type1, type2);

    return {
      'score': score,
      'level': level,
      'color': color,
      'strengths': analysisData['strengths'] ?? [],
      'challenges': analysisData['challenges'] ?? [],
      'tips': analysisData['tips'] ?? [],
    };
  }

  static Map<String, List<String>> _getAnalysisData(String type1, String type2) {
    List<String> strengths = [];
    List<String> challenges = [];
    List<String> tips = [];

    // E/I 分析
    String e1 = type1[0], e2 = type2[0];
    if (e1 == e2) {
      if (e1 == 'E') {
        strengths.add('🗣️ 都喜歡社交活動，能一起享受熱鬧的聚會');
        tips.add('記得為彼此留出獨處時間');
      } else {
        strengths.add('🏠 都享受安靜的相處時光，深度交流');
        tips.add('偶爾挑戰自己參與社交活動');
      }
    } else {
      challenges.add('⚖️ 內向與外向的能量補充方式不同');
      tips.add('理解並尊重彼此的社交需求');
    }

    // S/N 分析
    String s1 = type1[1], s2 = type2[1];
    if (s1 == s2) {
      if (s1 == 'S') {
        strengths.add('🎯 都注重現實和具體細節，實用主義');
        tips.add('偶爾嘗試一些創新和抽象的話題');
      } else {
        strengths.add('💡 都喜歡探索可能性和創新想法');
        tips.add('記得關注現實生活的具體需求');
      }
    } else {
      challenges.add('🔍 現實主義與理想主義的視角差異');
      tips.add('欣賞彼此不同的思考方式');
    }

    // T/F 分析
    String t1 = type1[2], t2 = type2[2];
    if (t1 == t2) {
      if (t1 == 'T') {
        strengths.add('🧠 都重視邏輯分析，理性決策');
        tips.add('不要忽視情感需求的重要性');
      } else {
        strengths.add('❤️ 都關注情感和價值觀，富有同理心');
        tips.add('有時需要理性分析來補充決策');
      }
    } else {
      strengths.add('🤝 理性與感性的完美平衡');
      tips.add('學習從對方的角度看問題');
    }

    // J/P 分析
    String j1 = type1[3], j2 = type2[3];
    if (j1 == j2) {
      if (j1 == 'J') {
        strengths.add('📋 都喜歡有計劃的生活，井然有序');
        tips.add('偶爾放鬆計劃，享受自發性');
      } else {
        strengths.add('🌟 都享受靈活性和自發性');
        tips.add('在重要事情上建立一些結構和計劃');
      }
    } else {
      challenges.add('⏰ 計劃性與自發性的生活方式差異');
      tips.add('互相妥協，找到平衡點');
    }

    return {
      'strengths': strengths,
      'challenges': challenges,
      'tips': tips,
    };
  }

  // 獲取約會建議
  static List<String> getDatingTips(String type1, String type2) {
    List<String> tips = [];
    
    // 基於 E/I
    if (type1[0] == 'E' && type2[0] == 'I') {
      tips.add('選擇安靜舒適的約會場所，讓內向的伴侶感到自在');
    } else if (type1[0] == 'I' && type2[0] == 'E') {
      tips.add('偶爾參加社交活動，讓外向的伴侶感到滿足');
    }

    // 基於 S/N
    if (type1[1] == 'S' && type2[1] == 'N') {
      tips.add('結合實際活動和想像力的約會，如參觀博物館或藝術展');
    } else if (type1[1] == 'N' && type2[1] == 'S') {
      tips.add('在創意活動中融入實際元素，如烹飪課程或手工藝');
    }

    // 基於 T/F
    if (type1[2] == 'T' && type2[2] == 'F') {
      tips.add('在邏輯討論中加入情感表達，關注彼此的感受');
    } else if (type1[2] == 'F' && type2[2] == 'T') {
      tips.add('在情感分享時也考慮理性分析，平衡決策過程');
    }

    // 基於 J/P
    if (type1[3] == 'J' && type2[3] == 'P') {
      tips.add('在計劃約會時留出自發性的空間');
    } else if (type1[3] == 'P' && type2[3] == 'J') {
      tips.add('偶爾制定詳細的約會計劃，給對方安全感');
    }

    // 通用建議
    tips.addAll([
      '保持開放的溝通，誠實分享你的想法和感受',
      '欣賞並慶祝彼此的不同之處',
      '在衝突時保持耐心，尋求理解而非獲勝',
      '創造共同的成長目標和體驗',
    ]);

    return tips;
  }
} 