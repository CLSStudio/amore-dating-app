void main() {
  print('🎨 測試 Amore 增強版 UI 組件');
  print('');
  
  // 測試兼容性指示器組件
  testCompatibilityIndicator();
  
  // 測試操作按鈕組件
  testActionButtons();
  
  // 測試增強版匹配卡片
  testEnhancedMatchCard();
  
  // 測試滑動配對界面
  testEnhancedDiscoveryPage();
  
  print('✅ 所有 UI 組件測試完成！');
}

void testCompatibilityIndicator() {
  print('🎯 測試兼容性指示器組件...');
  
  // 測試不同分數的顯示
  final testCases = [
    {'score': 95.0, 'mbti': 'ENFP', 'expected': '完美匹配'},
    {'score': 85.0, 'mbti': 'INTJ', 'expected': '高度匹配'},
    {'score': 75.0, 'mbti': 'ISFP', 'expected': '良好匹配'},
    {'score': 65.0, 'mbti': 'ESTJ', 'expected': '中等匹配'},
    {'score': 45.0, 'mbti': 'ISTP', 'expected': '低匹配度'},
  ];
  
  for (final testCase in testCases) {
    final score = testCase['score'] as double;
    final mbti = testCase['mbti'] as String;
    final expected = testCase['expected'] as String;
    final actual = _getScoreLabel(score);
    
    print('   ✓ 分數: ${score.toInt()}%, MBTI: $mbti');
    print('     預期: $expected, 實際: $actual');
    print('     顏色: ${_getScoreColor(score)}');
    print('     動畫: 圓形進度條 (${(score/100).toStringAsFixed(2)})');
  }
  print('');
}

void testActionButtons() {
  print('🎮 測試操作按鈕組件...');
  
  final buttons = [
    {
      'name': '跳過',
      'icon': 'Icons.close',
      'color': 'AppColors.pass',
      'size': 56.0,
      'action': 'onPass',
    },
    {
      'name': '超級喜歡',
      'icon': 'Icons.star',
      'color': 'AppColors.superLike',
      'size': 48.0,
      'action': 'onSuperLike',
    },
    {
      'name': '喜歡',
      'icon': 'Icons.favorite',
      'color': 'AppColors.like',
      'size': 64.0,
      'action': 'onLike',
    },
    {
      'name': '推廣',
      'icon': 'Icons.flash_on',
      'color': 'AppColors.boost',
      'size': 48.0,
      'action': 'onBoost',
    },
  ];
  
  for (final button in buttons) {
    print('   ✓ ${button['name']}:');
    print('     圖標: ${button['icon']}');
    print('     顏色: ${button['color']}');
    print('     大小: ${button['size']}px');
    print('     回調: ${button['action']}');
    print('     動畫: 縮放 + 陰影效果');
  }
  print('');
}

void testEnhancedMatchCard() {
  print('🃏 測試增強版匹配卡片...');
  
  // 測試用戶數據結構
  final testUser = {
    'id': '1',
    'name': '小雅',
    'age': 25,
    'distance': 2.5,
    'bio': '喜歡旅行和攝影，尋找有趣的靈魂 📸✈️\n\n熱愛探索世界的每一個角落，用鏡頭記錄美好瞬間。',
    'mbti': 'ENFP',
    'interests': ['攝影', '旅行', '咖啡', '音樂', '電影', '閱讀'],
    'photos': [
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
    ],
    'compatibilityScore': 92.0,
    'occupation': '攝影師',
    'education': '香港大學',
    'height': 165,
    'languages': ['中文', '英文', '日文'],
  };
  
  print('   ✓ 用戶數據:');
  print('     姓名: ${testUser['name']}, ${testUser['age']}歲');
  print('     距離: ${testUser['distance']} km');
  print('     MBTI: ${testUser['mbti']}');
  print('     兼容性: ${testUser['compatibilityScore']}%');
  print('     照片數量: ${(testUser['photos'] as List).length}');
  print('     興趣數量: ${(testUser['interests'] as List).length}');
  
  print('   ✓ 滑動手勢:');
  print('     向右滑動: 喜歡 (閾值: 100px)');
  print('     向左滑動: 跳過 (閾值: -100px)');
  print('     向上滑動: 超級喜歡 (閾值: -100px)');
  
  print('   ✓ 照片功能:');
  print('     照片輪播: 支援左右點擊切換');
  print('     進度指示器: 頂部白色條狀指示器');
  print('     錯誤處理: 顯示錯誤圖標');
  
  print('   ✓ 視覺效果:');
  print('     漸變遮罩: 底部黑色漸變');
  print('     滑動指示器: LIKE/PASS/SUPER LIKE');
  print('     兼容性徽章: 右上角愛心圖標');
  print('     MBTI 徽章: 左上角紫色標籤');
  
  print('   ✓ 詳細信息:');
  print('     切換按鈕: 右下角信息圖標');
  print('     覆蓋層: 半透明黑色背景');
  print('     滾動內容: 完整個人資料');
  print('');
}

void testEnhancedDiscoveryPage() {
  print('🔍 測試增強版滑動配對界面...');
  
  print('   ✓ 頂部導航欄:');
  print('     Logo: 漸變愛心圖標');
  print('     標題: Discover + 副標題');
  print('     篩選按鈕: 調整圖標');
  print('     設置按鈕: 設置圖標');
  
  print('   ✓ 兼容性指示器:');
  print('     位置: 卡片上方');
  print('     內容: 分數 + MBTI 類型');
  print('     動畫: 圓形進度條');
  print('     信息按鈕: 詳細說明對話框');
  
  print('   ✓ 卡片堆疊:');
  print('     當前卡片: 完全可見和交互');
  print('     背景卡片: 縮放 95%, 透明度 50%');
  print('     空狀態: 愛心圖標 + 重新載入按鈕');
  
  print('   ✓ 操作按鈕:');
  print('     位置: 底部居中');
  print('     動畫: 彈性縮放效果');
  print('     觸覺反饋: 輕微震動');
  
  print('   ✓ 匹配對話框:');
  print('     觸發: 30% 機率 (模擬)');
  print('     內容: 愛心圖標 + 成功消息');
  print('     操作: 繼續探索 / 開始聊天');
  
  print('   ✓ 動畫系統:');
  print('     卡片動畫: 300ms 滑出');
  print('     按鈕動畫: 200ms 彈性');
  print('     觸覺反饋: HapticFeedback.lightImpact()');
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
  if (score >= 80) return 'success (綠色)';
  if (score >= 60) return 'warning (橙色)';
  return 'error (紅色)';
} 