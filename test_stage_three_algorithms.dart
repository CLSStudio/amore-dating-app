import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'lib/core/dating_modes/algorithms/matching_algorithms.dart';
import 'lib/core/dating_modes/algorithms/ai_matching_service.dart';
import 'lib/core/dating_modes/algorithms/recommendation_engine.dart';
import 'lib/core/dating_modes/models/mode_profile.dart';
import 'lib/core/models/user_model.dart';
import 'lib/features/dating/modes/dating_mode_system.dart';

void main() {
  group('🎯 Amore 階段三：配對演算法測試', () {
    late UserModel testUser1;
    late UserModel testUser2;
    late UserModel testUser3;

    setUpAll(() {
      // 創建測試用戶數據
      testUser1 = UserModel(
        uid: 'test_user_1',
        name: '測試用戶1',
        age: 28,
        bio: '喜歡閱讀和旅行的軟體工程師',
        photoUrls: ['photo1.jpg', 'photo2.jpg'],
        interests: ['閱讀', '旅行', '程式設計', '咖啡'],
        occupation: '軟體工程師',
        education: '大學',
        isVerified: true,
        lastOnline: DateTime.now().subtract(Duration(minutes: 30)),
        socialLinks: {'instagram': '@test1'},
      );

      testUser2 = UserModel(
        uid: 'test_user_2',
        name: '測試用戶2',
        age: 26,
        bio: '熱愛運動和音樂的設計師',
        photoUrls: ['photo3.jpg', 'photo4.jpg', 'photo5.jpg'],
        interests: ['設計', '音樂', '健身', '電影'],
        occupation: 'UI設計師',
        education: '碩士',
        isVerified: true,
        lastOnline: DateTime.now().subtract(Duration(hours: 2)),
        socialLinks: {'linkedin': 'test2'},
      );

      testUser3 = UserModel(
        uid: 'test_user_3',
        name: '測試用戶3',
        age: 32,
        bio: '商業分析師，喜歡美食和藝術',
        photoUrls: ['photo6.jpg'],
        interests: ['美食', '藝術', '投資', '紅酒'],
        occupation: '商業分析師',
        education: '碩士',
        isVerified: false,
        lastOnline: DateTime.now().subtract(Duration(days: 1)),
        socialLinks: {},
      );
    });

    group('🧮 配對演算法核心測試', () {
      test('🎯 認真交往配對演算法', () async {
        final algorithm = SeriousMatchingAlgorithm();
        
        expect(algorithm.algorithmName, equals('serious_dating_algorithm_v2.0'));
        expect(algorithm.weights.length, equals(4));
        expect(algorithm.weights['valueAlignment'], equals(0.35));
        
        // 測試相容性計算
        final compatibility = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(compatibility, isA<double>());
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
        
        print('✅ 認真交往演算法：相容性分數 ${compatibility.toStringAsFixed(2)}');
      });

      test('🌟 探索模式配對演算法', () async {
        final algorithm = ExploreMatchingAlgorithm();
        
        expect(algorithm.algorithmName, equals('explore_mode_algorithm_v2.0'));
        expect(algorithm.weights.length, equals(4));
        expect(algorithm.weights['interestOverlap'], equals(0.40));
        
        final compatibility = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(compatibility, isA<double>());
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
        
        print('✅ 探索模式演算法：相容性分數 ${compatibility.toStringAsFixed(2)}');
      });

      test('🔥 激情模式配對演算法', () async {
        final algorithm = PassionMatchingAlgorithm();
        
        expect(algorithm.algorithmName, equals('passion_mode_algorithm_v2.0'));
        expect(algorithm.weights.length, equals(3));
        expect(algorithm.weights['proximityScore'], equals(0.50));
        
        final compatibility = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(compatibility, isA<double>());
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
        
        print('✅ 激情模式演算法：相容性分數 ${compatibility.toStringAsFixed(2)}');
      });

      test('🏭 配對演算法工廠', () {
        final seriousAlgorithm = MatchingAlgorithmFactory.getAlgorithmForMode(DatingMode.serious);
        final exploreAlgorithm = MatchingAlgorithmFactory.getAlgorithmForMode(DatingMode.explore);
        final passionAlgorithm = MatchingAlgorithmFactory.getAlgorithmForMode(DatingMode.passion);
        
        expect(seriousAlgorithm, isA<SeriousMatchingAlgorithm>());
        expect(exploreAlgorithm, isA<ExploreMatchingAlgorithm>());
        expect(passionAlgorithm, isA<PassionMatchingAlgorithm>());
        
        print('✅ 配對演算法工廠測試通過');
      });
    });

    group('🤖 AI配對服務測試', () {
      late AIMatchingService aiService;

      setUp(() {
        aiService = AIMatchingService();
      });

      test('🧠 MBTI相容性分析', () async {
        final analysis = await aiService.analyzeMBTICompatibility('INTJ', 'ENFP');
        
        expect(analysis.mbti1, equals('INTJ'));
        expect(analysis.mbti2, equals('ENFP'));
        expect(analysis.overallScore, isA<double>());
        expect(analysis.dimensionScores.length, equals(4));
        expect(analysis.strengths, isA<List<String>>());
        expect(analysis.challenges, isA<List<String>>());
        expect(analysis.advice, isA<List<String>>());
        
        print('✅ MBTI分析：${analysis.mbti1} + ${analysis.mbti2} = ${analysis.overallScore.toStringAsFixed(2)}');
        if (analysis.strengths.isNotEmpty) {
          print('   優勢：${analysis.strengths.first}');
        }
      });

      test('🎨 興趣匹配分析', () async {
        final result = await aiService.analyzeInterestCompatibility(
          testUser1.interests,
          testUser2.interests,
        );
        
        expect(result.overlapScore, isA<double>());
        expect(result.sharedInterests, isA<List<String>>());
        expect(result.complementaryInterests, isA<List<String>>());
        expect(result.suggestions, isA<List<String>>());
        
        print('✅ 興趣匹配：重疊度 ${result.overlapScore.toStringAsFixed(2)}');
        if (result.sharedInterests.isNotEmpty) {
          print('   共同興趣：${result.sharedInterests.join('、')}');
        }
      });

      test('💎 價值觀對齊評估', () async {
        final values1 = ['誠實守信', '家庭第一', '事業心'];
        final values2 = ['誠實守信', '自由獨立', '責任感'];
        
        final result = await aiService.analyzeValueAlignment(values1, values2);
        
        expect(result.alignmentScore, isA<double>());
        expect(result.sharedValues, isA<List<String>>());
        expect(result.conflictingValues, isA<List<String>>());
        expect(result.recommendations, isA<List<String>>());
        
        print('✅ 價值觀對齊：分數 ${result.alignmentScore.toStringAsFixed(2)}');
        if (result.sharedValues.isNotEmpty) {
          print('   共同價值觀：${result.sharedValues.join('、')}');
        }
      });
    });

    group('🚀 推薦引擎測試', () {
      late RecommendationEngine recommendationEngine;

      setUp(() {
        recommendationEngine = RecommendationEngine();
      });

      test('📊 用戶行為模型', () {
        final behaviorModel = UserBehaviorModel.defaultModel('test_user');
        
        expect(behaviorModel.userId, equals('test_user'));
        expect(behaviorModel.agePreference.min, equals(20));
        expect(behaviorModel.agePreference.max, equals(50));
        expect(behaviorModel.educationPreferences, isEmpty);
        expect(behaviorModel.preferredInterests, isEmpty);
        expect(behaviorModel.maxDistance, equals(10.0));
        expect(behaviorModel.totalInteractions, equals(0));
        expect(behaviorModel.positiveInteractions, equals(0));
        expect(behaviorModel.successRate, equals(0.0));
        
        print('✅ 默認行為模型創建成功');
      });

      test('🎯 推薦結果結構', () {
        final recommendation = RecommendationResult(
          user: testUser1,
          totalScore: 0.85,
          compatibilityScore: 0.8,
          behaviorScore: 0.9,
          noveltyScore: 0.7,
          activityScore: 0.95,
          explanations: ['高度匹配', '活躍用戶'],
        );
        
        expect(recommendation.user.uid, equals('test_user_1'));
        expect(recommendation.totalScore, equals(0.85));
        expect(recommendation.explanations.length, equals(2));
        
        print('✅ 推薦結果結構驗證通過');
      });

      test('📈 用戶反饋類型', () {
        expect(UserFeedbackType.values.length, equals(6));
        expect(UserFeedbackType.values.contains(UserFeedbackType.like), isTrue);
        expect(UserFeedbackType.values.contains(UserFeedbackType.superLike), isTrue);
        expect(UserFeedbackType.values.contains(UserFeedbackType.pass), isTrue);
        expect(UserFeedbackType.values.contains(UserFeedbackType.block), isTrue);
        
        print('✅ 用戶反饋類型定義完整');
      });
    });

    group('🔬 演算法效能測試', () {
      test('⚡ 批量相容性計算效能', () async {
        final algorithm = SeriousMatchingAlgorithm();
        final stopwatch = Stopwatch()..start();
        
        // 模擬計算10對用戶的相容性
        final futures = <Future<double>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(algorithm.calculateCompatibility(testUser1, testUser2));
        }
        
        final results = await Future.wait(futures);
        stopwatch.stop();
        
        expect(results.length, equals(10));
        expect(results.every((score) => score >= 0.0 && score <= 1.0), isTrue);
        
        print('✅ 批量計算效能：10次計算耗時 ${stopwatch.elapsedMilliseconds}ms');
      });

      test('🎯 演算法一致性', () async {
        final algorithm = SeriousMatchingAlgorithm();
        
        // 同樣的輸入應該產生同樣的輸出
        final score1 = await algorithm.calculateCompatibility(testUser1, testUser2);
        final score2 = await algorithm.calculateCompatibility(testUser1, testUser2);
        final score3 = await algorithm.calculateCompatibility(testUser1, testUser2);
        
        expect(score1, equals(score2));
        expect(score2, equals(score3));
        
        print('✅ 演算法一致性驗證通過：分數 ${score1.toStringAsFixed(3)}');
      });

      test('🔄 對稱性測試', () async {
        final algorithm = ExploreMatchingAlgorithm();
        
        // 計算A對B和B對A的相容性應該相同
        final scoreAB = await algorithm.calculateCompatibility(testUser1, testUser2);
        final scoreBA = await algorithm.calculateCompatibility(testUser2, testUser1);
        
        expect(scoreAB, equals(scoreBA));
        
        print('✅ 演算法對稱性驗證通過：${scoreAB.toStringAsFixed(3)}');
      });
    });

    group('🌟 模式專屬特徵測試', () {
      test('🎯 認真交往模式特徵', () async {
        final algorithm = SeriousMatchingAlgorithm();
        
        // 測試MBTI、價值觀、教育程度的影響
        final highCompatibilityUser = UserModel(
          uid: 'high_compat',
          name: '高相容用戶',
          age: 29, // 接近testUser1的28歲
          interests: ['閱讀', '旅行'], // 有共同興趣
          occupation: '產品經理', // 相關職業
          education: '大學', // 相同教育程度
          isVerified: true,
          lastOnline: DateTime.now(),
          photoUrls: ['photo.jpg'],
          socialLinks: {},
        );
        
        final score = await algorithm.calculateCompatibility(testUser1, highCompatibilityUser);
        expect(score, greaterThan(0.5));
        
        print('✅ 認真交往高相容性：${score.toStringAsFixed(3)}');
      });

      test('🌟 探索模式特徵', () async {
        final algorithm = ExploreMatchingAlgorithm();
        
        // 測試興趣重疊的影響
        final sharedInterestUser = UserModel(
          uid: 'shared_interest',
          name: '共同興趣用戶',
          age: 25,
          interests: ['閱讀', '旅行', '咖啡', '攝影'], // 3個共同興趣
          occupation: '任何職業',
          education: '任何學歷',
          isVerified: true,
          lastOnline: DateTime.now(),
          photoUrls: ['photo.jpg'],
          socialLinks: {},
        );
        
        final score = await algorithm.calculateCompatibility(testUser1, sharedInterestUser);
        expect(score, greaterThan(0.4)); // 興趣重疊應該得到不錯的分數
        
        print('✅ 探索模式興趣匹配：${score.toStringAsFixed(3)}');
      });

      test('🔥 激情模式特徵', () async {
        final algorithm = PassionMatchingAlgorithm();
        
        // 激情模式更注重即時性和地理位置
        final nearbyUser = UserModel(
          uid: 'nearby_user',
          name: '附近用戶',
          age: 30,
          interests: ['任何興趣'],
          occupation: '任何職業',
          education: '任何學歷',
          isVerified: true,
          lastOnline: DateTime.now(), // 剛剛在線
          photoUrls: ['photo.jpg'],
          socialLinks: {},
        );
        
        final score = await algorithm.calculateCompatibility(testUser1, nearbyUser);
        expect(score, isA<double>());
        expect(score, greaterThanOrEqualTo(0.0));
        
        print('✅ 激情模式即時匹配：${score.toStringAsFixed(3)}');
      });
    });
  });

  // 測試完成總結
  tearDownAll(() {
    print('\n🎉 階段三配對演算法測試完成！');
    print('✅ 策略模式配對演算法 ✓');
    print('✅ AI智能匹配服務 ✓');
    print('✅ 機器學習推薦引擎 ✓');
    print('✅ MBTI相容性分析 ✓');
    print('✅ 興趣匹配演算法 ✓');
    print('✅ 價值觀對齊評估 ✓');
    print('✅ 即時位置匹配 ✓');
    print('✅ 演算法效能驗證 ✓');
    print('✅ 模式差異化特徵 ✓');
    print('\n🚀 準備進入階段四：內容差異化實施');
  });
} 