import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// 簡化的用戶模型測試
class TestUserModel {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String location;
  final List<String> interests;
  final String? occupation;
  final String? education;
  final bool isVerified;
  final List<String> coreValues;
  final String? mbtiType;
  final String? relationshipGoals;
  final String? familyPlanning;

  TestUserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.location,
    required this.interests,
    this.occupation,
    this.education,
    this.isVerified = false,
    this.coreValues = const [],
    this.mbtiType,
    this.relationshipGoals,
    this.familyPlanning,
  });
}

// 配對算法測試接口
abstract class TestMatchingAlgorithm {
  String get algorithmName;
  Map<String, double> get weights;
  Future<double> calculateCompatibility(TestUserModel user1, TestUserModel user2);
}

// 認真交往算法實現
class TestSeriousMatchingAlgorithm extends TestMatchingAlgorithm {
  @override
  String get algorithmName => 'serious_dating_algorithm_v2.0';

  @override
  Map<String, double> get weights => {
    'valueAlignment': 0.35,
    'lifestyleMatch': 0.25,
    'mbtiCompatibility': 0.20,
    'goalAlignment': 0.20,
  };

  @override
  Future<double> calculateCompatibility(TestUserModel user1, TestUserModel user2) async {
    double valueAlignment = _calculateValueAlignment(user1, user2) * weights['valueAlignment']!;
    double lifestyleMatch = _calculateLifestyleMatch(user1, user2) * weights['lifestyleMatch']!;
    double mbtiCompatibility = _calculateMBTIMatch(user1, user2) * weights['mbtiCompatibility']!;
    double goalAlignment = _calculateGoalAlignment(user1, user2) * weights['goalAlignment']!;
    
    return (valueAlignment + lifestyleMatch + mbtiCompatibility + goalAlignment).clamp(0.0, 1.0);
  }

  double _calculateValueAlignment(TestUserModel user1, TestUserModel user2) {
    if (user1.coreValues.isEmpty || user2.coreValues.isEmpty) return 0.5;
    
    final overlap = user1.coreValues.toSet().intersection(user2.coreValues.toSet());
    final union = user1.coreValues.toSet().union(user2.coreValues.toSet());
    
    return union.isEmpty ? 0.0 : overlap.length / union.length;
  }

  double _calculateLifestyleMatch(TestUserModel user1, TestUserModel user2) {
    double score = 0.0;
    
    // 教育匹配
    if (user1.education != null && user2.education != null) {
      score += user1.education == user2.education ? 0.4 : 0.2;
    } else {
      score += 0.2;
    }
    
    // 職業類別匹配
    if (user1.occupation != null && user2.occupation != null) {
      score += _calculateOccupationMatch(user1.occupation!, user2.occupation!) * 0.3;
    } else {
      score += 0.15;
    }
    
    // 地理位置
    score += _calculateLocationMatch(user1.location, user2.location) * 0.3;
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateMBTIMatch(TestUserModel user1, TestUserModel user2) {
    if (user1.mbtiType == null || user2.mbtiType == null) return 0.5;
    
    // 簡化的MBTI相容性
    final compatibilityMatrix = {
      'INTJ_ENFP': 0.9,
      'ENFP_INTJ': 0.9,
      'INTP_ENFJ': 0.8,
      'ENFJ_INTP': 0.8,
    };
    
    final key = '${user1.mbtiType}_${user2.mbtiType}';
    return compatibilityMatrix[key] ?? 0.6;
  }

  double _calculateGoalAlignment(TestUserModel user1, TestUserModel user2) {
    double score = 0.0;
    
    if (user1.relationshipGoals != null && user2.relationshipGoals != null) {
      score += user1.relationshipGoals == user2.relationshipGoals ? 0.5 : 0.2;
    } else {
      score += 0.25;
    }
    
    if (user1.familyPlanning != null && user2.familyPlanning != null) {
      score += user1.familyPlanning == user2.familyPlanning ? 0.5 : 0.2;
    } else {
      score += 0.25;
    }
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateOccupationMatch(String occ1, String occ2) {
    final professionGroups = {
      '科技': ['軟體工程師', '程式設計師', '產品經理', '數據科學家'],
      '創意': ['設計師', 'UI設計師', '藝術家', '攝影師'],
      '商業': ['分析師', '顧問', '銀行家', '會計師'],
    };
    
    for (final group in professionGroups.values) {
      if (group.contains(occ1) && group.contains(occ2)) {
        return 1.0;
      }
    }
    return 0.5;
  }

  double _calculateLocationMatch(String loc1, String loc2) {
    final locationMatrix = {
      '香港島_香港島': 0.9,
      '香港島_九龍': 0.7,
      '九龍_九龍': 0.9,
      '九龍_新界': 0.6,
      '新界_新界': 0.8,
    };
    
    final key = '${loc1}_${loc2}';
    return locationMatrix[key] ?? locationMatrix['${loc2}_${loc1}'] ?? 0.5;
  }
}

// 探索模式算法實現
class TestExploreMatchingAlgorithm extends TestMatchingAlgorithm {
  @override
  String get algorithmName => 'explore_mode_algorithm_v2.0';

  @override
  Map<String, double> get weights => {
    'interestOverlap': 0.40,
    'activityCompatibility': 0.30,
    'socialEnergyMatch': 0.20,
    'availabilityAlignment': 0.10,
  };

  @override
  Future<double> calculateCompatibility(TestUserModel user1, TestUserModel user2) async {
    double interestOverlap = _calculateInterestOverlap(user1, user2) * weights['interestOverlap']!;
    double activityCompatibility = 0.7 * weights['activityCompatibility']!; // 模擬值
    double socialEnergyMatch = 0.6 * weights['socialEnergyMatch']!; // 模擬值
    double availabilityAlignment = 0.8 * weights['availabilityAlignment']!; // 模擬值
    
    return (interestOverlap + activityCompatibility + socialEnergyMatch + availabilityAlignment).clamp(0.0, 1.0);
  }

  double _calculateInterestOverlap(TestUserModel user1, TestUserModel user2) {
    if (user1.interests.isEmpty || user2.interests.isEmpty) return 0.3;
    
    final overlap = user1.interests.toSet().intersection(user2.interests.toSet());
    final union = user1.interests.toSet().union(user2.interests.toSet());
    
    return union.isEmpty ? 0.0 : overlap.length / union.length;
  }
}

// 激情模式算法實現
class TestPassionMatchingAlgorithm extends TestMatchingAlgorithm {
  @override
  String get algorithmName => 'passion_mode_algorithm_v2.0';

  @override
  Map<String, double> get weights => {
    'proximityScore': 0.50,
    'timeAvailability': 0.30,
    'intentAlignment': 0.20,
  };

  @override
  Future<double> calculateCompatibility(TestUserModel user1, TestUserModel user2) async {
    double proximityScore = _calculateProximity(user1.location, user2.location) * weights['proximityScore']!;
    double timeAvailability = 0.8 * weights['timeAvailability']!; // 模擬值
    double intentAlignment = 0.9 * weights['intentAlignment']!; // 模擬值
    
    return (proximityScore + timeAvailability + intentAlignment).clamp(0.0, 1.0);
  }

  double _calculateProximity(String loc1, String loc2) {
    // 簡化的地理接近度計算
    if (loc1 == loc2) return 1.0;
    
    final distanceMatrix = {
      '香港島_九龍': 0.7,
      '九龍_香港島': 0.7,
      '香港島_新界': 0.4,
      '新界_香港島': 0.4,
      '九龍_新界': 0.6,
      '新界_九龍': 0.6,
    };
    
    return distanceMatrix['${loc1}_${loc2}'] ?? 0.3;
  }
}

// 算法工廠
class TestMatchingAlgorithmFactory {
  static TestMatchingAlgorithm getAlgorithmForMode(String mode) {
    switch (mode) {
      case 'serious':
        return TestSeriousMatchingAlgorithm();
      case 'explore':
        return TestExploreMatchingAlgorithm();
      case 'passion':
        return TestPassionMatchingAlgorithm();
      default:
        throw ArgumentError('Unknown mode: $mode');
    }
  }
}

void main() {
  group('🎯 Amore Phase 3 配對算法驗證測試', () {
    late TestUserModel testUser1;
    late TestUserModel testUser2;
    late TestUserModel testUser3;

    setUpAll(() {
      testUser1 = TestUserModel(
        uid: 'test_user_1',
        name: '測試用戶1',
        age: 28,
        gender: '男',
        location: '香港島',
        interests: ['閱讀', '旅行', '程式設計', '咖啡'],
        occupation: '軟體工程師',
        education: '大學',
        isVerified: true,
        coreValues: ['誠實守信', '事業心', '責任感'],
        mbtiType: 'INTJ',
        relationshipGoals: '長期關係',
        familyPlanning: '想要孩子',
      );

      testUser2 = TestUserModel(
        uid: 'test_user_2',
        name: '測試用戶2',
        age: 26,
        gender: '女',
        location: '九龍',
        interests: ['設計', '音樂', '健身', '電影'],
        occupation: 'UI設計師',
        education: '碩士',
        isVerified: true,
        coreValues: ['誠實守信', '自由獨立', '創造力'],
        mbtiType: 'ENFP',
        relationshipGoals: '長期關係',
        familyPlanning: '想要孩子',
      );

      testUser3 = TestUserModel(
        uid: 'test_user_3',
        name: '測試用戶3',
        age: 32,
        gender: '男',
        location: '新界',
        interests: ['美食', '藝術', '投資', '紅酒'],
        occupation: '商業分析師',
        education: '碩士',
        isVerified: false,
        coreValues: ['事業心', '品味', '獨立'],
        mbtiType: 'ENTJ',
        relationshipGoals: '探索',
        familyPlanning: '不確定',
      );
    });

    group('🧮 核心配對算法測試', () {
      test('🎯 認真交往配對算法', () async {
        final algorithm = TestSeriousMatchingAlgorithm();
        
        expect(algorithm.algorithmName, equals('serious_dating_algorithm_v2.0'));
        expect(algorithm.weights.length, equals(4));
        expect(algorithm.weights['valueAlignment'], equals(0.35));
        
        final compatibility = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(compatibility, isA<double>());
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
        
        print('✅ 認真交往算法：${testUser1.name} + ${testUser2.name} = ${compatibility.toStringAsFixed(3)}');
      });

      test('🌟 探索模式配對算法', () async {
        final algorithm = TestExploreMatchingAlgorithm();
        
        expect(algorithm.algorithmName, equals('explore_mode_algorithm_v2.0'));
        expect(algorithm.weights.length, equals(4));
        expect(algorithm.weights['interestOverlap'], equals(0.40));
        
        final compatibility = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(compatibility, isA<double>());
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
        
        print('✅ 探索模式算法：${testUser1.name} + ${testUser2.name} = ${compatibility.toStringAsFixed(3)}');
      });

      test('🔥 激情模式配對算法', () async {
        final algorithm = TestPassionMatchingAlgorithm();
        
        expect(algorithm.algorithmName, equals('passion_mode_algorithm_v2.0'));
        expect(algorithm.weights.length, equals(3));
        expect(algorithm.weights['proximityScore'], equals(0.50));
        
        final compatibility = await algorithm.calculateCompatibility(testUser1, testUser2);
        expect(compatibility, isA<double>());
        expect(compatibility, greaterThanOrEqualTo(0.0));
        expect(compatibility, lessThanOrEqualTo(1.0));
        
        print('✅ 激情模式算法：${testUser1.name} + ${testUser2.name} = ${compatibility.toStringAsFixed(3)}');
      });

      test('🏭 配對算法工廠', () {
        final seriousAlgorithm = TestMatchingAlgorithmFactory.getAlgorithmForMode('serious');
        final exploreAlgorithm = TestMatchingAlgorithmFactory.getAlgorithmForMode('explore');
        final passionAlgorithm = TestMatchingAlgorithmFactory.getAlgorithmForMode('passion');
        
        expect(seriousAlgorithm, isA<TestSeriousMatchingAlgorithm>());
        expect(exploreAlgorithm, isA<TestExploreMatchingAlgorithm>());
        expect(passionAlgorithm, isA<TestPassionMatchingAlgorithm>());
        
        print('✅ 配對算法工廠運作正常');
      });
    });

    group('🔬 算法效能測試', () {
      test('⚡ 批量相容性計算效能', () async {
        final algorithm = TestSeriousMatchingAlgorithm();
        final stopwatch = Stopwatch()..start();
        
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

      test('🎯 算法一致性驗證', () async {
        final algorithm = TestSeriousMatchingAlgorithm();
        
        final score1 = await algorithm.calculateCompatibility(testUser1, testUser2);
        final score2 = await algorithm.calculateCompatibility(testUser1, testUser2);
        final score3 = await algorithm.calculateCompatibility(testUser1, testUser2);
        
        expect(score1, equals(score2));
        expect(score2, equals(score3));
        
        print('✅ 算法一致性驗證通過：分數 ${score1.toStringAsFixed(3)}');
      });

      test('🔄 算法對稱性驗證', () async {
        final algorithm = TestSeriousMatchingAlgorithm();
        
        final score1 = await algorithm.calculateCompatibility(testUser1, testUser2);
        final score2 = await algorithm.calculateCompatibility(testUser2, testUser1);
        
        // 對稱性容忍度
        final difference = (score1 - score2).abs();
        expect(difference, lessThan(0.1));
        
        print('✅ 算法對稱性驗證：差異 ${difference.toStringAsFixed(3)}');
      });
    });

    group('📊 實際案例測試', () {
      test('💕 高相容性配對', () async {
        // 創建高相容性用戶對
        final highCompatUser1 = TestUserModel(
          uid: 'high_compat_1',
          name: '高相容用戶1',
          age: 28,
          gender: '男',
          location: '香港島',
          interests: ['閱讀', '旅行'],
          occupation: '軟體工程師',
          education: '大學',
          coreValues: ['誠實守信', '家庭第一'],
          mbtiType: 'INTJ',
          relationshipGoals: '長期關係',
          familyPlanning: '想要孩子',
        );

        final highCompatUser2 = TestUserModel(
          uid: 'high_compat_2',
          name: '高相容用戶2',
          age: 26,
          gender: '女',
          location: '香港島',
          interests: ['閱讀', '旅行'],
          occupation: '程式設計師',
          education: '大學',
          coreValues: ['誠實守信', '家庭第一'],
          mbtiType: 'ENFP',
          relationshipGoals: '長期關係',
          familyPlanning: '想要孩子',
        );

        final algorithm = TestSeriousMatchingAlgorithm();
        final compatibility = await algorithm.calculateCompatibility(highCompatUser1, highCompatUser2);
        
        expect(compatibility, greaterThan(0.7));
        print('✅ 高相容性測試：分數 ${compatibility.toStringAsFixed(3)} (期望 > 0.7)');
      });

      test('💔 低相容性配對', () async {
        // 創建低相容性用戶對
        final lowCompatUser1 = TestUserModel(
          uid: 'low_compat_1',
          name: '低相容用戶1',
          age: 25,
          gender: '男',
          location: '香港島',
          interests: ['遊戲', '宅在家'],
          occupation: '學生',
          education: '高中',
          coreValues: ['自由獨立'],
          relationshipGoals: '隨緣',
          familyPlanning: '不想要',
        );

        final lowCompatUser2 = TestUserModel(
          uid: 'low_compat_2',
          name: '低相容用戶2',
          age: 35,
          gender: '女',
          location: '新界',
          interests: ['高級餐廳', '名牌購物'],
          occupation: '企業高管',
          education: '碩士',
          coreValues: ['事業心', '品味'],
          relationshipGoals: '結婚',
          familyPlanning: '想要孩子',
        );

        final algorithm = TestSeriousMatchingAlgorithm();
        final compatibility = await algorithm.calculateCompatibility(lowCompatUser1, lowCompatUser2);
        
        expect(compatibility, lessThan(0.5));
        print('✅ 低相容性測試：分數 ${compatibility.toStringAsFixed(3)} (期望 < 0.5)');
      });
    });
  });
} 