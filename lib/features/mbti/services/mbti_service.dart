import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mbti_question.dart';
import '../data/extended_mbti_questions_data.dart';

class MBTIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 獲取測試問題
  List<MBTIQuestion> getQuestions([TestMode mode = TestMode.simple]) {
    return ExtendedMBTIQuestionsData.getQuestions(mode);
  }

  // 計算 MBTI 結果
  MBTIResult calculateResult(String userId, Map<String, String> answers, [TestMode mode = TestMode.simple]) {
    final questions = getQuestions(mode);
    final scores = <String, int>{
      'E': 0, 'I': 0,
      'S': 0, 'N': 0,
      'T': 0, 'F': 0,
      'J': 0, 'P': 0,
    };

    // 計算每個維度的分數
    for (final question in questions) {
      final answerId = answers[question.id];
      if (answerId != null) {
        final answer = question.answers.firstWhere(
          (a) => a.id == answerId,
          orElse: () => question.answers.first,
        );
        scores[answer.type] = (scores[answer.type] ?? 0) + answer.weight;
      }
    }

    // 確定 MBTI 類型
    final type = _determineMBTIType(scores);
    final description = ExtendedMBTIQuestionsData.getMBTIDescriptions()[type] ?? '';
    final traits = ExtendedMBTIQuestionsData.getMBTITraits()[type] ?? [];

    // 計算信心度（基於問題數量和分數差異）
    final confidence = _calculateConfidence(scores, questions.length);

    return MBTIResult(
      userId: userId,
      type: type,
      scores: scores,
      completedAt: DateTime.now(),
      traits: traits,
      description: description,
      testMode: mode,
      confidence: confidence,
    );
  }

  // 確定 MBTI 類型
  String _determineMBTIType(Map<String, int> scores) {
    final ei = (scores['E'] ?? 0) > (scores['I'] ?? 0) ? 'E' : 'I';
    final sn = (scores['S'] ?? 0) > (scores['N'] ?? 0) ? 'S' : 'N';
    final tf = (scores['T'] ?? 0) > (scores['F'] ?? 0) ? 'T' : 'F';
    final jp = (scores['J'] ?? 0) > (scores['P'] ?? 0) ? 'J' : 'P';
    
    return '$ei$sn$tf$jp';
  }

  // 計算結果信心度
  double _calculateConfidence(Map<String, int> scores, int questionCount) {
    // 基礎信心度根據問題數量
    double baseConfidence = questionCount >= 60 ? 0.9 : 
                           questionCount >= 20 ? 0.8 : 0.7;
    
    // 根據各維度分數差異調整信心度
    final dimensions = [
      ['E', 'I'], ['S', 'N'], ['T', 'F'], ['J', 'P']
    ];
    
    double totalDifference = 0;
    for (final dimension in dimensions) {
      final score1 = scores[dimension[0]] ?? 0;
      final score2 = scores[dimension[1]] ?? 0;
      final difference = (score1 - score2).abs();
      totalDifference += difference;
    }
    
    // 分數差異越大，信心度越高
    final averageDifference = totalDifference / 4;
    final confidenceBonus = (averageDifference / 10).clamp(0.0, 0.1);
    
    return (baseConfidence + confidenceBonus).clamp(0.5, 1.0);
  }

  // 保存測試結果到 Firebase
  Future<void> saveResult(MBTIResult result) async {
    try {
      await _firestore
          .collection('mbti_results')
          .doc(result.userId)
          .set(result.toJson());
    } catch (e) {
      throw Exception('保存 MBTI 結果失敗: $e');
    }
  }

  // 獲取用戶的 MBTI 結果
  Future<MBTIResult?> getUserResult(String userId) async {
    try {
      final doc = await _firestore
          .collection('mbti_results')
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return MBTIResult.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('獲取 MBTI 結果失敗: $e');
    }
  }

  // 檢查用戶是否已完成測試
  Future<bool> hasUserCompletedTest(String userId) async {
    final result = await getUserResult(userId);
    return result != null;
  }

  // 獲取 MBTI 兼容性分數
  double calculateCompatibility(String type1, String type2) {
    if (type1 == type2) return 1.0;

    final compatibility = _mbtiCompatibilityMatrix[type1]?[type2] ?? 0.5;
    return compatibility;
  }

  // MBTI 兼容性矩陣 (簡化版)
  static const Map<String, Map<String, double>> _mbtiCompatibilityMatrix = {
    'ENFP': {
      'INTJ': 0.9, 'INFJ': 0.8, 'ENFJ': 0.7, 'ENTP': 0.8,
      'ISFP': 0.7, 'ISTP': 0.6, 'ESFP': 0.6, 'ESTP': 0.5,
    },
    'ENFJ': {
      'INFP': 0.9, 'ISFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.7,
      'ISTP': 0.6, 'ESTP': 0.6, 'ESFJ': 0.7, 'ISFJ': 0.8,
    },
    'ENTP': {
      'INTJ': 0.9, 'INFJ': 0.8, 'ENFP': 0.8, 'INTP': 0.7,
      'ISFJ': 0.6, 'ESFJ': 0.5, 'ISTP': 0.7, 'ESTP': 0.6,
    },
    'ENTJ': {
      'INTP': 0.9, 'INFP': 0.8, 'ENFP': 0.7, 'INTJ': 0.8,
      'ISFP': 0.6, 'ESFP': 0.5, 'ISTJ': 0.7, 'ESTJ': 0.6,
    },
    'INFP': {
      'ENFJ': 0.9, 'ENTJ': 0.8, 'INFJ': 0.8, 'ENFP': 0.7,
      'ISTJ': 0.6, 'ESTJ': 0.5, 'ISFJ': 0.7, 'ESFJ': 0.6,
    },
    'INFJ': {
      'ENTP': 0.8, 'ENFP': 0.8, 'INTJ': 0.7, 'INFP': 0.8,
      'ESTP': 0.5, 'ESFP': 0.6, 'ISTJ': 0.6, 'ISFJ': 0.7,
    },
    'INTP': {
      'ENTJ': 0.9, 'ENFJ': 0.7, 'ENTP': 0.7, 'INTJ': 0.8,
      'ESFJ': 0.5, 'ISFJ': 0.6, 'ESTP': 0.6, 'ISTP': 0.7,
    },
    'INTJ': {
      'ENFP': 0.9, 'ENTP': 0.9, 'INFJ': 0.7, 'INTP': 0.8,
      'ESFP': 0.5, 'ISFP': 0.6, 'ESTJ': 0.6, 'ISTJ': 0.7,
    },
    'ISFP': {
      'ENFJ': 0.8, 'ESFJ': 0.7, 'ISFJ': 0.7, 'ENFP': 0.7,
      'ENTJ': 0.6, 'ESTJ': 0.5, 'INTP': 0.6, 'ENTP': 0.6,
    },
    'ISFJ': {
      'ESFP': 0.8, 'ENFP': 0.7, 'ISFP': 0.7, 'ESFJ': 0.8,
      'ENTP': 0.6, 'INTP': 0.6, 'ENTJ': 0.5, 'INTJ': 0.6,
    },
    'ISTP': {
      'ESFJ': 0.7, 'ENFJ': 0.6, 'ESTJ': 0.6, 'ENTJ': 0.6,
      'INFP': 0.6, 'ENFP': 0.6, 'ISFP': 0.7, 'ESFP': 0.7,
    },
    'ISTJ': {
      'ESFP': 0.7, 'ISFP': 0.6, 'ESFJ': 0.8, 'ISFJ': 0.7,
      'ENFP': 0.6, 'INFP': 0.6, 'ENTP': 0.5, 'INTP': 0.6,
    },
    'ESFP': {
      'ISTJ': 0.7, 'ISFJ': 0.8, 'ISTP': 0.7, 'ESTP': 0.6,
      'INTJ': 0.5, 'INFJ': 0.6, 'ENTJ': 0.5, 'ENFJ': 0.6,
    },
    'ESFJ': {
      'ISFP': 0.7, 'ISTP': 0.7, 'ISTJ': 0.8, 'ISFJ': 0.8,
      'INTP': 0.5, 'INFP': 0.6, 'ENTP': 0.5, 'ENFP': 0.6,
    },
    'ESTP': {
      'ISFJ': 0.7, 'ESFJ': 0.6, 'ISTJ': 0.6, 'ESTJ': 0.7,
      'INFJ': 0.5, 'INTJ': 0.5, 'INFP': 0.5, 'INTP': 0.6,
    },
    'ESTJ': {
      'ISTP': 0.6, 'ISFP': 0.5, 'ESTP': 0.7, 'ESFP': 0.6,
      'INFP': 0.5, 'ENFP': 0.6, 'INFJ': 0.6, 'ENFJ': 0.6,
    },
  };

  // 為缺失的組合填充默認值
  double _getCompatibilityScore(String type1, String type2) {
    return _mbtiCompatibilityMatrix[type1]?[type2] ?? 
           _mbtiCompatibilityMatrix[type2]?[type1] ?? 
           0.5; // 默認中等兼容性
  }
} 