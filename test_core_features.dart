// 核心功能測試腳本
import 'lib/features/mbti/services/mbti_service.dart';
import 'lib/features/profile/models/user_profile.dart';
import 'lib/features/matching/services/matching_service.dart';

void main() async {
  print('🎯 Amore 核心功能測試');
  print('=' * 50);
  
  // 測試 MBTI 系統
  await testMBTISystem();
  
  // 測試個人檔案系統
  await testProfileSystem();
  
  // 測試匹配算法
  await testMatchingSystem();
  
  print('\n🎉 所有核心功能測試完成！');
}

Future<void> testMBTISystem() async {
  print('\n🧠 測試 MBTI 系統...');
  
  try {
    final mbtiService = MBTIService();
    
    // 測試問題加載
    final questions = mbtiService.getQuestions();
    print('✅ 成功加載 ${questions.length} 道 MBTI 問題');
    
    // 測試計算結果
    final testAnswers = <String, String>{};
    for (final question in questions) {
      testAnswers[question.id] = question.answers.first.id;
    }
    
    final result = mbtiService.calculateResult('test_user', testAnswers);
    print('✅ 成功計算 MBTI 結果: ${result.type}');
    print('   描述: ${result.description}');
    print('   特質: ${result.traits.join(', ')}');
    
    // 測試兼容性計算
    final compatibility = mbtiService.calculateCompatibility('ENFP', 'INTJ');
    print('✅ ENFP 與 INTJ 兼容性: ${(compatibility * 100).toStringAsFixed(1)}%');
    
  } catch (e) {
    print('❌ MBTI 系統測試失敗: $e');
  }
}

Future<void> testProfileSystem() async {
  print('\n👤 測試個人檔案系統...');
  
  try {
    // 創建測試用戶檔案
    final profile = UserProfile(
      userId: 'test_user_1',
      name: '測試用戶',
      age: 25,
      gender: 'female',
      bio: '喜歡旅行和閱讀的女生',
      photos: ['photo1.jpg', 'photo2.jpg'],
      interests: ['旅行', '閱讀', '電影', '咖啡'],
      occupation: '軟體工程師',
      education: '大學',
      location: '香港',
      height: 165,
      mbtiType: 'ENFP',
      isProfileComplete: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    print('✅ 成功創建用戶檔案');
    print('   姓名: ${profile.name}');
    print('   年齡: ${profile.age}');
    print('   MBTI: ${profile.mbtiType}');
    print('   興趣: ${profile.interests.join(', ')}');
    
    // 測試檔案完成度計算
    final completion = profile.completionPercentage;
    print('✅ 檔案完成度: ${(completion * 100).toStringAsFixed(1)}%');
    
    // 測試 JSON 序列化
    final json = profile.toJson();
    final fromJson = UserProfile.fromJson(json);
    print('✅ JSON 序列化測試成功');
    
  } catch (e) {
    print('❌ 個人檔案系統測試失敗: $e');
  }
}

Future<void> testMatchingSystem() async {
  print('\n🎯 測試匹配算法...');
  
  try {
    final matchingService = MatchingService();
    
    // 創建兩個測試用戶
    final user1 = UserProfile(
      userId: 'user_1',
      name: 'Alice',
      age: 26,
      gender: 'female',
      bio: '喜歡藝術和音樂',
      photos: ['alice1.jpg'],
      interests: ['藝術', '音樂', '旅行'],
      occupation: '設計師',
      location: '香港',
      height: 160,
      mbtiType: 'ENFP',
      isProfileComplete: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final user2 = UserProfile(
      userId: 'user_2',
      name: 'Bob',
      age: 28,
      gender: 'male',
      bio: '科技愛好者',
      photos: ['bob1.jpg'],
      interests: ['科技', '旅行', '攝影'],
      occupation: '工程師',
      location: '香港',
      height: 175,
      mbtiType: 'INTJ',
      isProfileComplete: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 測試兼容性計算
    final compatibilityScore = await matchingService.calculateCompatibilityScore(user1, user2);
    print('✅ 兼容性分數計算成功: ${(compatibilityScore * 100).toStringAsFixed(1)}%');
    
    // 測試詳細分析
    final analysis = await matchingService.getDetailedCompatibilityAnalysis(user1, user2);
    print('✅ 詳細兼容性分析:');
    print('   MBTI 分數: ${(analysis.mbtiScore * 100).toStringAsFixed(1)}%');
    print('   興趣分數: ${(analysis.interestScore * 100).toStringAsFixed(1)}%');
    print('   年齡分數: ${(analysis.ageScore * 100).toStringAsFixed(1)}%');
    print('   位置分數: ${(analysis.locationScore * 100).toStringAsFixed(1)}%');
    print('   優勢: ${analysis.strengths.join(', ')}');
    if (analysis.considerations.isNotEmpty) {
      print('   考慮因素: ${analysis.considerations.join(', ')}');
    }
    
  } catch (e) {
    print('❌ 匹配算法測試失敗: $e');
  }
} 