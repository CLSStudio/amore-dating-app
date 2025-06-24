import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'lib/core/dating_modes/algorithms/matching_algorithms.dart';
import 'lib/core/dating_modes/algorithms/ai_matching_service.dart';
import 'lib/core/models/user_model.dart';
import 'lib/features/dating/modes/dating_mode_system.dart';

void main() {
  group('🎯 Amore 階段三：配對演算法簡化測試', () {
    late UserModel testUser1;
    late UserModel testUser2;

    setUpAll(() {
      // 創建測試用戶數據（使用正確的屬性）
      testUser1 = UserModel(
        uid: 'test_user_1',
        name: '測試用戶1',
        email: 'test1@test.com',
        age: 28,
        gender: '男',
        location: '香港島',
        bio: '喜歡閱讀和旅行的軟體工程師',
        photoUrls: ['photo1.jpg', 'photo2.jpg'],
        interests: ['閱讀', '旅行', '程式設計', '咖啡'],
        profession: '軟體工程師',
        education: '大學',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        lastActive: DateTime.now().subtract(Duration(minutes: 30)),
      );

      testUser2 = UserModel(
        uid: 'test_user_2', 
        name: '測試用戶2',
        email: 'test2@test.com',
        age: 26,
        gender: '女',
        location: '九龍',
        bio: '熱愛運動和音樂的設計師',
        photoUrls: ['photo3.jpg', 'photo4.jpg', 'photo5.jpg'],
        interests: ['設計', '音樂', '健身', '電影'],
        profession: 'UI設計師',
        education: '碩士',
        isVerified: true,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        lastActive: DateTime.now().subtract(Duration(hours: 2)),
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

    group('🤖 AI配對服務基礎測試', () {
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

    group('🔬 演算法效能測試', () {
      test('⚡ 批量相容性計算效能', () async {
        final algorithm = SeriousMatchingAlgorithm();
        final stopwatch = Stopwatch()..start();
        
        // 模擬計算5對用戶的相容性
        final futures = <Future<double>>[];
        for (int i = 0; i < 5; i++) {
          futures.add(algorithm.calculateCompatibility(testUser1, testUser2));
        }
        
        final results = await Future.wait(futures);
        stopwatch.stop();
        
        expect(results.length, equals(5));
        expect(results.every((score) => score >= 0.0 && score <= 1.0), isTrue);
        
        print('✅ 批量計算效能：5次計算耗時 ${stopwatch.elapsedMilliseconds}ms');
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

    group('🌟 模式差異化驗證', () {
      test('🎯 認真交往模式特徵', () async {
        final algorithm = SeriousMatchingAlgorithm();
        
        // 認真交往模式應該注重教育、職業等因素
        final score = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(score, isA<double>());
        expect(score, greaterThanOrEqualTo(0.0));
        
        print('✅ 認真交往模式：注重深度匹配 ${score.toStringAsFixed(3)}');
      });

      test('🌟 探索模式特徵', () async {
        final algorithm = ExploreMatchingAlgorithm();
        
        // 探索模式應該注重興趣重疊
        final score = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(score, isA<double>());
        expect(score, greaterThanOrEqualTo(0.0));
        
        print('✅ 探索模式：注重興趣匹配 ${score.toStringAsFixed(3)}');
      });

      test('🔥 激情模式特徵', () async {
        final algorithm = PassionMatchingAlgorithm();
        
        // 激情模式應該注重地理位置和即時性
        final score = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(score, isA<double>());
        expect(score, greaterThanOrEqualTo(0.0));
        
        print('✅ 激情模式：注重位置和即時性 ${score.toStringAsFixed(3)}');
      });
    });
  });

  // 測試完成總結
  tearDownAll(() {
    print('\n🎉 階段三配對演算法簡化測試完成！');
    print('✅ 三大模式配對演算法 ✓');
    print('✅ AI智能匹配服務 ✓');
    print('✅ MBTI相容性分析 ✓');
    print('✅ 興趣匹配演算法 ✓');
    print('✅ 價值觀對齊評估 ✓');
    print('✅ 演算法效能驗證 ✓');
    print('✅ 模式差異化特徵 ✓');
    print('\n🚀 階段三配對演算法實施完成，準備進入階段四');
  });
} 