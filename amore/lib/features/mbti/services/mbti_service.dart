import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mbti_models.dart';
import '../../../core/services/firebase_service.dart';

class MBTIService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 獲取所有 MBTI 問題
  Future<List<MBTIQuestion>> getQuestions() async {
    try {
      final snapshot = await _firestore
          .collection('mbti_questions')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => MBTIQuestion.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'get_mbti_questions'},
      );
      rethrow;
    }
  }

  // 開始新的測試會話
  Future<MBTITestSession> startTestSession(String userId) async {
    try {
      final session = MBTITestSession(
        id: '', // Firestore 會自動生成
        userId: userId,
        startedAt: DateTime.now(),
        currentScores: {
          'E': 0, 'I': 0,
          'S': 0, 'N': 0,
          'T': 0, 'F': 0,
          'J': 0, 'P': 0,
        },
      );

      final docRef = await _firestore
          .collection('mbti_sessions')
          .add(session.toJson());

      await FirebaseService.logEvent(
        name: 'mbti_test_started',
        parameters: {'user_id': userId},
      );

      return session.copyWith(id: docRef.id);
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'start_mbti_test', 'user_id': userId},
      );
      rethrow;
    }
  }

  // 獲取測試會話
  Future<MBTITestSession?> getTestSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection('mbti_sessions')
          .doc(sessionId)
          .get();

      if (doc.exists) {
        return MBTITestSession.fromJson({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'get_mbti_session', 'session_id': sessionId},
      );
      return null;
    }
  }

  // 回答問題
  Future<MBTITestSession> answerQuestion({
    required String sessionId,
    required String questionId,
    required String answerId,
    required MBTIAnswer answer,
  }) async {
    try {
      final session = await getTestSession(sessionId);
      if (session == null) {
        throw Exception('測試會話不存在');
      }

      // 更新答案
      final newAnswers = Map<String, String>.from(session.answers);
      newAnswers[questionId] = answerId;

      // 更新分數
      final newScores = Map<String, int>.from(session.currentScores);
      newScores[answer.type] = (newScores[answer.type] ?? 0) + answer.score;

      // 更新會話
      final updatedSession = session.copyWith(
        answers: newAnswers,
        currentScores: newScores,
        currentQuestionIndex: session.currentQuestionIndex + 1,
      );

      await _firestore
          .collection('mbti_sessions')
          .doc(sessionId)
          .update(updatedSession.toJson());

      return updatedSession;
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {
          'method': 'answer_mbti_question',
          'session_id': sessionId,
          'question_id': questionId,
        },
      );
      rethrow;
    }
  }

  // 完成測試並計算結果
  Future<MBTIResult> completeTest(String sessionId) async {
    try {
      final session = await getTestSession(sessionId);
      if (session == null) {
        throw Exception('測試會話不存在');
      }

      // 計算 MBTI 類型
      final type = MBTIResult.calculateType(session.currentScores);
      final percentages = MBTIResult.calculatePercentages(session.currentScores);

      // 獲取人格描述
      final personality = await getPersonalityDescription(type);

      // 創建結果
      final result = MBTIResult(
        userId: session.userId,
        type: type,
        scores: session.currentScores,
        percentages: percentages,
        completedAt: DateTime.now(),
        answeredQuestions: session.answers.keys.toList(),
        personality: personality,
      );

      // 保存結果
      await _firestore
          .collection('mbti_results')
          .doc(session.userId)
          .set(result.toJson());

      // 更新會話為已完成
      await _firestore
          .collection('mbti_sessions')
          .doc(sessionId)
          .update({
        'isCompleted': true,
        'completedAt': Timestamp.now(),
      });

      // 記錄事件
      await FirebaseService.logEvent(
        name: 'mbti_test_completed',
        parameters: {
          'user_id': session.userId,
          'mbti_type': type,
        },
      );

      return result;
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'complete_mbti_test', 'session_id': sessionId},
      );
      rethrow;
    }
  }

  // 獲取用戶的 MBTI 結果
  Future<MBTIResult?> getUserResult(String userId) async {
    try {
      final doc = await _firestore
          .collection('mbti_results')
          .doc(userId)
          .get();

      if (doc.exists) {
        return MBTIResult.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'get_user_mbti_result', 'user_id': userId},
      );
      return null;
    }
  }

  // 獲取人格描述
  Future<MBTIPersonality> getPersonalityDescription(String type) async {
    try {
      final doc = await _firestore
          .collection('mbti_personalities')
          .doc(type)
          .get();

      if (doc.exists) {
        return MBTIPersonality.fromJson(doc.data()!);
      }

      // 如果沒有找到，返回默認描述
      return _getDefaultPersonality(type);
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'get_mbti_personality', 'type': type},
      );
      return _getDefaultPersonality(type);
    }
  }

  // 計算兩個用戶的兼容性
  Future<double> calculateCompatibility(String userId1, String userId2) async {
    try {
      final result1 = await getUserResult(userId1);
      final result2 = await getUserResult(userId2);

      if (result1 == null || result2 == null) {
        return 0.0;
      }

      return MBTICompatibility.calculateCompatibility(result1.type, result2.type);
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {
          'method': 'calculate_mbti_compatibility',
          'user1': userId1,
          'user2': userId2,
        },
      );
      return 0.0;
    }
  }

  // 獲取兼容性原因
  Future<List<String>> getCompatibilityReasons(String userId1, String userId2) async {
    try {
      final result1 = await getUserResult(userId1);
      final result2 = await getUserResult(userId2);

      if (result1 == null || result2 == null) {
        return [];
      }

      return MBTICompatibility.getCompatibilityReasons(result1.type, result2.type);
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {
          'method': 'get_mbti_compatibility_reasons',
          'user1': userId1,
          'user2': userId2,
        },
      );
      return [];
    }
  }

  // 初始化 MBTI 問題數據
  Future<void> initializeQuestions() async {
    try {
      final questions = _getDefaultQuestions();
      
      for (final question in questions) {
        await _firestore
            .collection('mbti_questions')
            .doc(question.id)
            .set(question.toJson());
      }

      await FirebaseService.logEvent(
        name: 'mbti_questions_initialized',
        parameters: {'count': questions.length},
      );
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'initialize_mbti_questions'},
      );
      rethrow;
    }
  }

  // 初始化人格描述數據
  Future<void> initializePersonalities() async {
    try {
      final personalities = _getDefaultPersonalities();
      
      for (final personality in personalities) {
        await _firestore
            .collection('mbti_personalities')
            .doc(personality.type)
            .set(personality.toJson());
      }

      await FirebaseService.logEvent(
        name: 'mbti_personalities_initialized',
        parameters: {'count': personalities.length},
      );
    } catch (e) {
      await FirebaseService.recordError(
        exception: e,
        fatal: false,
        additionalData: {'method': 'initialize_mbti_personalities'},
      );
      rethrow;
    }
  }

  // 默認人格描述
  MBTIPersonality _getDefaultPersonality(String type) {
    final personalities = _getDefaultPersonalities();
    return personalities.firstWhere(
      (p) => p.type == type,
      orElse: () => MBTIPersonality(
        type: type,
        title: '$type 人格',
        description: '這是一個獨特的人格類型。',
        strengths: ['適應性強', '有創造力'],
        weaknesses: ['需要更多了解'],
        compatibleTypes: [],
        challengingTypes: [],
        loveStyle: '真誠而深刻',
        communicationStyle: '開放而直接',
        idealDateIdeas: ['咖啡約會', '散步聊天'],
      ),
    );
  }

  // 默認問題數據
  List<MBTIQuestion> _getDefaultQuestions() {
    return [
      // E/I 問題
      const MBTIQuestion(
        id: 'q1',
        question: '在聚會中，你更傾向於：',
        category: 'EI',
        order: 1,
        answers: [
          MBTIAnswer(id: 'a1', text: '主動與很多人交談', type: 'E', score: 2),
          MBTIAnswer(id: 'a2', text: '與少數幾個人深入交流', type: 'I', score: 2),
        ],
      ),
      const MBTIQuestion(
        id: 'q2',
        question: '當你需要充電時，你會：',
        category: 'EI',
        order: 2,
        answers: [
          MBTIAnswer(id: 'a3', text: '和朋友出去玩', type: 'E', score: 2),
          MBTIAnswer(id: 'a4', text: '獨自待在安靜的地方', type: 'I', score: 2),
        ],
      ),
      // S/N 問題
      const MBTIQuestion(
        id: 'q3',
        question: '你更關注：',
        category: 'SN',
        order: 3,
        answers: [
          MBTIAnswer(id: 'a5', text: '具體的事實和細節', type: 'S', score: 2),
          MBTIAnswer(id: 'a6', text: '可能性和潛在意義', type: 'N', score: 2),
        ],
      ),
      const MBTIQuestion(
        id: 'q4',
        question: '在學習新事物時，你偏好：',
        category: 'SN',
        order: 4,
        answers: [
          MBTIAnswer(id: 'a7', text: '循序漸進，按部就班', type: 'S', score: 2),
          MBTIAnswer(id: 'a8', text: '跳躍式思考，尋找模式', type: 'N', score: 2),
        ],
      ),
      // T/F 問題
      const MBTIQuestion(
        id: 'q5',
        question: '做決定時，你更依賴：',
        category: 'TF',
        order: 5,
        answers: [
          MBTIAnswer(id: 'a9', text: '邏輯分析和客觀事實', type: 'T', score: 2),
          MBTIAnswer(id: 'a10', text: '個人價值觀和他人感受', type: 'F', score: 2),
        ],
      ),
      const MBTIQuestion(
        id: 'q6',
        question: '在衝突中，你傾向於：',
        category: 'TF',
        order: 6,
        answers: [
          MBTIAnswer(id: 'a11', text: '直接指出問題所在', type: 'T', score: 2),
          MBTIAnswer(id: 'a12', text: '考慮每個人的感受', type: 'F', score: 2),
        ],
      ),
      // J/P 問題
      const MBTIQuestion(
        id: 'q7',
        question: '你的生活方式更像：',
        category: 'JP',
        order: 7,
        answers: [
          MBTIAnswer(id: 'a13', text: '有計劃、有組織', type: 'J', score: 2),
          MBTIAnswer(id: 'a14', text: '靈活、隨性', type: 'P', score: 2),
        ],
      ),
      const MBTIQuestion(
        id: 'q8',
        question: '面對截止日期，你會：',
        category: 'JP',
        order: 8,
        answers: [
          MBTIAnswer(id: 'a15', text: '提前完成任務', type: 'J', score: 2),
          MBTIAnswer(id: 'a16', text: '在最後時刻完成', type: 'P', score: 2),
        ],
      ),
    ];
  }

  // 默認人格描述數據
  List<MBTIPersonality> _getDefaultPersonalities() {
    return [
      const MBTIPersonality(
        type: 'ENFP',
        title: '活動家',
        description: '熱情、創造性和社交性強的自由精神，總能找到理由微笑。',
        strengths: ['熱情洋溢', '創造力強', '社交能力佳', '靈活適應'],
        weaknesses: ['容易分心', '過度樂觀', '缺乏專注', '情緒化'],
        compatibleTypes: ['INTJ', 'INFJ', 'ENFJ', 'ENTP'],
        challengingTypes: ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
        loveStyle: '充滿激情和創意，喜歡探索關係的各種可能性',
        communicationStyle: '開放、熱情、富有表現力',
        idealDateIdeas: ['音樂會', '藝術展覽', '戶外探險', '創意工作坊'],
      ),
      const MBTIPersonality(
        type: 'INTJ',
        title: '建築師',
        description: '富有想像力和戰略性的思想家，一切皆在計劃之中。',
        strengths: ['戰略思維', '獨立自主', '決心堅定', '高效執行'],
        weaknesses: ['過於批判', '傲慢自大', '缺乏耐心', '社交困難'],
        compatibleTypes: ['ENFP', 'ENTP', 'INFJ', 'ENTJ'],
        challengingTypes: ['ESFP', 'ESTP', 'ISFP', 'ISTP'],
        loveStyle: '深思熟慮，尋求深層的智力和情感連接',
        communicationStyle: '直接、簡潔、注重效率',
        idealDateIdeas: ['博物館參觀', '深度討論', '策略遊戲', '安靜的晚餐'],
      ),
      // 可以繼續添加其他 14 種類型...
    ];
  }
}

// Riverpod 提供者
final mbtiServiceProvider = Provider<MBTIService>((ref) => MBTIService());

final mbtiQuestionsProvider = FutureProvider<List<MBTIQuestion>>((ref) {
  final service = ref.watch(mbtiServiceProvider);
  return service.getQuestions();
});

final userMBTIResultProvider = FutureProvider.family<MBTIResult?, String>((ref, userId) {
  final service = ref.watch(mbtiServiceProvider);
  return service.getUserResult(userId);
}); 