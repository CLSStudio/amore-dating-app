# AI 對話分析功能

## 功能概述

Amore 應用新增了強大的 AI 對話分析功能，幫助用戶深度了解聊天對象的真實意圖和兼容性。這個功能使用 Google Gemini Pro AI 來分析聊天記錄，提供專業的洞察和建議。

## 主要功能

### 1. 真心度分析 (Sincerity Analysis)
- **功能描述**：分析對方在聊天中的真心程度和誠意
- **分析維度**：
  - 回應的及時性和頻率
  - 消息的深度和個人化程度
  - 情感表達的真實性
  - 對話的主動性和投入度
  - 是否有敷衍或套路化的回應
  - 對未來的態度和規劃

- **輸出結果**：
  - 真心度分數 (0-100)
  - 回應質量評估
  - 情感深度分析
  - 一致性評估
  - 積極信號列表
  - 警告信號列表
  - 總體評估和建議

### 2. 對象比較 (Partner Comparison)
- **功能描述**：比較多個聊天對象，找出最適合的匹配
- **比較維度**：
  - 整體兼容性分數
  - 溝通品質評估
  - 性格匹配度
  - 價值觀一致性
  - 未來發展潛力

- **輸出結果**：
  - 排序後的對象列表
  - 最佳推薦對象
  - 詳細比較報告
  - 主要洞察和建議

### 3. 對話模式分析 (Conversation Pattern Analysis)
- **功能描述**：深入分析對話模式和溝通風格
- **分析內容**：
  - 對話的節奏和流暢度
  - 主導對話的一方
  - 話題轉換的自然度
  - 情感表達的方式
  - 溝通風格的匹配度

- **統計數據**：
  - 消息數量統計
  - 平均回應時間
  - 最活躍時段
  - 對話持續天數

## 技術實現

### 核心服務
- **ConversationAnalysisService**: 主要的分析服務類
- **Google Gemini Pro API**: 提供 AI 分析能力
- **Firebase Firestore**: 存儲聊天記錄和分析結果

### 數據模型
```dart
// 真心度分析結果
class SincerityAnalysis {
  final String id;
  final String partnerId;
  final int sincerityScore;
  final String responseQuality;
  final String emotionalDepth;
  final String consistency;
  final List<String> redFlags;
  final List<String> positiveSignals;
  final String overallAssessment;
  final List<String> recommendations;
  final DateTime analyzedAt;
}

// 伴侶分析結果
class PartnerAnalysis {
  final String partnerId;
  final String partnerName;
  final double overallScore;
  final double communicationScore;
  final double personalityMatch;
  final double valueAlignment;
  final double futureCompatibility;
  final List<String> strengths;
  final List<String> concerns;
  final String recommendation;
}

// 對話模式分析
class ConversationPattern {
  final String conversationFlow;
  final String dominancePattern;
  final String topicDiversity;
  final String emotionalTone;
  final String communicationStyle;
  final List<String> patterns;
  final List<String> suggestions;
  final Map<String, dynamic> statistics;
}
```

### API 調用示例
```dart
// 分析真心度
final analysis = await ConversationAnalysisService.analyzeSincerity(
  chatId: 'chat_id',
  partnerId: 'partner_id',
  messageLimit: 50,
);

// 比較多個對象
final comparison = await ConversationAnalysisService.comparePartners(
  partnerIds: ['partner1', 'partner2', 'partner3'],
  messageLimit: 30,
);

// 分析對話模式
final pattern = await ConversationAnalysisService.analyzeConversationPattern(
  chatId: 'chat_id',
  partnerId: 'partner_id',
  messageLimit: 100,
);
```

## 用戶界面

### 主要頁面
- **ConversationAnalysisPage**: 主分析頁面，包含三個標籤頁
- **PartnerComparisonResultPage**: 詳細的比較結果頁面

### 訪問入口
1. **個人檔案頁面**: 點擊 "AI 對話分析" 卡片
2. **聊天頁面**: 點擊右上角的分析圖標或主要功能卡片

### 界面特色
- 現代化的卡片設計
- 直觀的分數顯示
- 詳細的分析報告
- 互動式的結果展示
- 拖拽式的詳情頁面

## 數據隱私和安全

### 隱私保護
- 所有分析都在用戶同意下進行
- 聊天內容僅用於分析，不會被存儲或分享
- 分析結果僅對用戶本人可見

### 數據安全
- 使用 Firebase 安全規則保護數據
- API 調用使用加密傳輸
- 分析結果自動過期清理

## 使用建議

### 最佳實踐
1. **充足的聊天記錄**: 建議至少有 20-30 條消息才能獲得準確分析
2. **定期分析**: 隨著對話的進展，定期重新分析以獲得最新洞察
3. **結合其他信息**: AI 分析應該與實際互動和直覺相結合
4. **理性對待結果**: 分析結果僅供參考，不應作為唯一決策依據

### 注意事項
- 分析結果基於文字內容，可能無法完全反映真實情況
- 不同的溝通風格可能影響分析準確性
- 建議將分析結果與實際相處體驗相結合

## 未來發展

### 計劃功能
- 情感趨勢分析
- 關係發展預測
- 個性化建議生成
- 多語言支持
- 語音消息分析

### 技術優化
- 提高分析準確性
- 減少 API 調用成本
- 增加離線分析能力
- 優化用戶體驗

## 技術支持

如果您在使用過程中遇到問題，請檢查：
1. 網絡連接是否正常
2. 是否有足夠的聊天記錄
3. Firebase 配置是否正確
4. Google AI API 密鑰是否有效

---

這個功能代表了 Amore 在 AI 輔助約會方面的重要進步，幫助用戶做出更明智的感情決策。 