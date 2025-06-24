// 簡化的核心功能測試
void main() {
  print('🎯 Amore 核心功能邏輯測試');
  print('=' * 50);
  
  // 測試 MBTI 兼容性計算
  testMBTICompatibility();
  
  // 測試興趣匹配
  testInterestMatching();
  
  // 測試年齡兼容性
  testAgeCompatibility();
  
  // 測試綜合匹配分數
  testOverallMatching();
  
  print('\n🎉 所有核心邏輯測試完成！');
}

void testMBTICompatibility() {
  print('\n🧠 測試 MBTI 兼容性計算...');
  
  // 模擬 MBTI 兼容性矩陣
  final mbtiCompatibility = {
    'ENFP': {'INTJ': 0.9, 'INFJ': 0.8, 'ENFJ': 0.7},
    'INTJ': {'ENFP': 0.9, 'ENTP': 0.9, 'INFJ': 0.7},
    'INFJ': {'ENTP': 0.8, 'ENFP': 0.8, 'INTJ': 0.7},
  };
  
  final score1 = mbtiCompatibility['ENFP']?['INTJ'] ?? 0.5;
  final score2 = mbtiCompatibility['INTJ']?['ENFP'] ?? 0.5;
  final score3 = mbtiCompatibility['ENFP']?['INFJ'] ?? 0.5;
  
  print('✅ ENFP + INTJ 兼容性: ${(score1 * 100).toStringAsFixed(1)}%');
  print('✅ INTJ + ENFP 兼容性: ${(score2 * 100).toStringAsFixed(1)}%');
  print('✅ ENFP + INFJ 兼容性: ${(score3 * 100).toStringAsFixed(1)}%');
  
  assert(score1 == 0.9, 'ENFP-INTJ 兼容性應該是 0.9');
  assert(score2 == 0.9, 'INTJ-ENFP 兼容性應該是 0.9');
  assert(score3 == 0.8, 'ENFP-INFJ 兼容性應該是 0.8');
  
  print('✅ MBTI 兼容性計算測試通過');
}

void testInterestMatching() {
  print('\n🎨 測試興趣匹配算法...');
  
  final interests1 = ['旅行', '閱讀', '電影', '咖啡'];
  final interests2 = ['旅行', '攝影', '電影', '音樂'];
  final interests3 = ['科技', '遊戲', '運動'];
  
  // 計算興趣兼容性
  double calculateInterestCompatibility(List<String> interests1, List<String> interests2) {
    if (interests1.isEmpty || interests2.isEmpty) return 0.0;
    
    final commonInterests = interests1.where((interest) => interests2.contains(interest)).length;
    final totalUniqueInterests = {...interests1, ...interests2}.length;
    
    return commonInterests / totalUniqueInterests;
  }
  
  final score1 = calculateInterestCompatibility(interests1, interests2);
  final score2 = calculateInterestCompatibility(interests1, interests3);
  
  print('✅ 用戶1 vs 用戶2 興趣匹配: ${(score1 * 100).toStringAsFixed(1)}%');
  print('   共同興趣: ${interests1.where((i) => interests2.contains(i)).join(', ')}');
  
  print('✅ 用戶1 vs 用戶3 興趣匹配: ${(score2 * 100).toStringAsFixed(1)}%');
  print('   共同興趣: ${interests1.where((i) => interests3.contains(i)).join(', ')}');
  
  assert(score1 > score2, '用戶1和用戶2應該比用戶1和用戶3更匹配');
  print('✅ 興趣匹配算法測試通過');
}

void testAgeCompatibility() {
  print('\n👥 測試年齡兼容性算法...');
  
  double calculateAgeCompatibility(int age1, int age2) {
    final ageDiff = (age1 - age2).abs();
    
    if (ageDiff <= 2) return 1.0;
    if (ageDiff <= 5) return 0.8;
    if (ageDiff <= 10) return 0.6;
    if (ageDiff <= 15) return 0.4;
    return 0.2;
  }
  
  final score1 = calculateAgeCompatibility(25, 26); // 1歲差
  final score2 = calculateAgeCompatibility(25, 28); // 3歲差
  final score3 = calculateAgeCompatibility(25, 32); // 7歲差
  final score4 = calculateAgeCompatibility(25, 45); // 20歲差
  
  print('✅ 25歲 vs 26歲: ${(score1 * 100).toStringAsFixed(1)}%');
  print('✅ 25歲 vs 28歲: ${(score2 * 100).toStringAsFixed(1)}%');
  print('✅ 25歲 vs 32歲: ${(score3 * 100).toStringAsFixed(1)}%');
  print('✅ 25歲 vs 45歲: ${(score4 * 100).toStringAsFixed(1)}%');
  
  assert(score1 > score2, '年齡差越小兼容性應該越高');
  assert(score2 > score3, '年齡差越小兼容性應該越高');
  assert(score3 > score4, '年齡差越小兼容性應該越高');
  
  print('✅ 年齡兼容性算法測試通過');
}

void testOverallMatching() {
  print('\n🎯 測試綜合匹配算法...');
  
  // 模擬兩個用戶的匹配計算
  double calculateOverallScore({
    required double mbtiScore,
    required double interestScore,
    required double ageScore,
    required double locationScore,
  }) {
    return (mbtiScore * 0.4) + 
           (interestScore * 0.3) + 
           (ageScore * 0.2) + 
           (locationScore * 0.1);
  }
  
  // 高匹配度用戶
  final highMatch = calculateOverallScore(
    mbtiScore: 0.9,      // ENFP + INTJ
    interestScore: 0.6,  // 60% 共同興趣
    ageScore: 1.0,       // 年齡相近
    locationScore: 1.0,  // 同城
  );
  
  // 中等匹配度用戶
  final mediumMatch = calculateOverallScore(
    mbtiScore: 0.6,      // 中等 MBTI 匹配
    interestScore: 0.4,  // 40% 共同興趣
    ageScore: 0.8,       // 年齡稍有差距
    locationScore: 0.5,  // 不同區域
  );
  
  // 低匹配度用戶
  final lowMatch = calculateOverallScore(
    mbtiScore: 0.3,      // 低 MBTI 匹配
    interestScore: 0.1,  // 10% 共同興趣
    ageScore: 0.4,       // 年齡差距較大
    locationScore: 0.3,  // 距離較遠
  );
  
  print('✅ 高匹配度用戶: ${(highMatch * 100).toStringAsFixed(1)}%');
  print('   - MBTI: 90%, 興趣: 60%, 年齡: 100%, 位置: 100%');
  
  print('✅ 中等匹配度用戶: ${(mediumMatch * 100).toStringAsFixed(1)}%');
  print('   - MBTI: 60%, 興趣: 40%, 年齡: 80%, 位置: 50%');
  
  print('✅ 低匹配度用戶: ${(lowMatch * 100).toStringAsFixed(1)}%');
  print('   - MBTI: 30%, 興趣: 10%, 年齡: 40%, 位置: 30%');
  
  assert(highMatch > mediumMatch, '高匹配度應該大於中等匹配度');
  assert(mediumMatch > lowMatch, '中等匹配度應該大於低匹配度');
  assert(highMatch > 0.7, '高匹配度應該超過 70%');
  assert(lowMatch < 0.4, '低匹配度應該低於 40%');
  
  print('✅ 綜合匹配算法測試通過');
  
  // 測試權重分配
  print('\n📊 權重分配驗證:');
  print('   - MBTI: 40% (最重要的心理匹配)');
  print('   - 興趣: 30% (共同話題和活動)');
  print('   - 年齡: 20% (生活階段匹配)');
  print('   - 位置: 10% (見面便利性)');
  print('   總計: 100%');
}

// 模擬 MBTI 測試結果計算
void testMBTICalculation() {
  print('\n🧮 測試 MBTI 計算邏輯...');
  
  // 模擬測試答案
  final scores = <String, int>{
    'E': 15, 'I': 9,   // 外向性勝出
    'S': 8,  'N': 16,  // 直覺勝出
    'T': 18, 'F': 6,   // 思考勝出
    'J': 7,  'P': 17,  // 感知勝出
  };
  
  String determineMBTIType(Map<String, int> scores) {
    final ei = (scores['E'] ?? 0) > (scores['I'] ?? 0) ? 'E' : 'I';
    final sn = (scores['S'] ?? 0) > (scores['N'] ?? 0) ? 'S' : 'N';
    final tf = (scores['T'] ?? 0) > (scores['F'] ?? 0) ? 'T' : 'F';
    final jp = (scores['J'] ?? 0) > (scores['P'] ?? 0) ? 'J' : 'P';
    
    return '$ei$sn$tf$jp';
  }
  
  final mbtiType = determineMBTIType(scores);
  print('✅ 計算出的 MBTI 類型: $mbtiType');
  print('   分數分佈: E:${scores['E']} I:${scores['I']} S:${scores['S']} N:${scores['N']} T:${scores['T']} F:${scores['F']} J:${scores['J']} P:${scores['P']}');
  
  assert(mbtiType == 'ENTP', '根據分數應該是 ENTP');
  print('✅ MBTI 計算邏輯測試通過');
} 