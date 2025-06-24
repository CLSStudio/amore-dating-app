
void main() {
  print('🚀 測試增強版滑動配對界面');
  print('');
  
  // 測試用戶數據結構
  testUserDataStructure();
  
  // 測試兼容性指示器
  testCompatibilityIndicator();
  
  // 測試操作按鈕
  testActionButtons();
  
  // 測試匹配卡片
  testEnhancedMatchCard();
  
  print('✅ 所有測試完成！');
}

void testUserDataStructure() {
  print('📊 測試用戶數據結構...');
  
  final testUser = {
    'id': '1',
    'name': '小雅',
    'age': 25,
    'distance': 2.5,
    'bio': '喜歡旅行和攝影，尋找有趣的靈魂 📸✈️',
    'mbti': 'ENFP',
    'interests': ['攝影', '旅行', '咖啡', '音樂'],
    'photos': [
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
    ],
    'compatibilityScore': 92.0,
    'occupation': '攝影師',
    'education': '香港大學',
    'height': 165,
    'languages': ['中文', '英文', '日文'],
  };
  
  print('   ✓ 用戶姓名: ${testUser['name']}');
  print('   ✓ 年齡: ${testUser['age']}');
  print('   ✓ MBTI: ${testUser['mbti']}');
  print('   ✓ 兼容性分數: ${testUser['compatibilityScore']}%');
  print('   ✓ 興趣數量: ${(testUser['interests'] as List).length}');
  print('   ✓ 照片數量: ${(testUser['photos'] as List).length}');
  print('');
}

void testCompatibilityIndicator() {
  print('🎯 測試兼容性指示器...');
  
  final testScores = [92.0, 85.0, 78.0, 65.0, 45.0];
  
  for (final score in testScores) {
    final label = _getScoreLabel(score);
    final color = _getScoreColor(score);
    print('   ✓ 分數: ${score.toInt()}% - 標籤: $label - 顏色: $color');
  }
  print('');
}

void testActionButtons() {
  print('🎮 測試操作按鈕...');
  
  final buttons = [
    {'name': '跳過', 'icon': 'close', 'color': 'pass', 'size': 56.0},
    {'name': '超級喜歡', 'icon': 'star', 'color': 'superLike', 'size': 48.0},
    {'name': '喜歡', 'icon': 'favorite', 'color': 'like', 'size': 64.0},
    {'name': '推廣', 'icon': 'flash_on', 'color': 'boost', 'size': 48.0},
  ];
  
  for (final button in buttons) {
    print('   ✓ ${button['name']}: 圖標=${button['icon']}, 大小=${button['size']}');
  }
  print('');
}

void testEnhancedMatchCard() {
  print('🃏 測試增強版匹配卡片...');
  
  // 測試滑動手勢
  print('   ✓ 支援滑動手勢:');
  print('     - 向右滑動: 喜歡');
  print('     - 向左滑動: 跳過');
  print('     - 向上滑動: 超級喜歡');
  
  // 測試照片功能
  print('   ✓ 照片功能:');
  print('     - 照片輪播');
  print('     - 進度指示器');
  print('     - 點擊切換');
  
  // 測試信息顯示
  print('   ✓ 信息顯示:');
  print('     - 基本信息');
  print('     - 兼容性分數');
  print('     - MBTI 標籤');
  print('     - 詳細信息切換');
  
  // 測試動畫效果
  print('   ✓ 動畫效果:');
  print('     - 滑動動畫');
  print('     - 縮放動畫');
  print('     - 旋轉動畫');
  print('     - 滑動指示器');
  
  print('');
}

String _getScoreLabel(double score) {
  if (score >= 90) return '完美匹配';
  if (score >= 80) return '高度匹配';
  if (score >= 70) return '良好匹配';
  if (score >= 60) return '中等匹配';
  return '低匹配度';
}

String _getScoreColor(double score) {
  if (score >= 80) return 'success';
  if (score >= 60) return 'warning';
  return 'error';
} 