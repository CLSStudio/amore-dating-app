# ⌨️ Amore 鍵盤快捷鍵指南

## 管理員快捷鍵

### 主要快捷鍵
| 快捷鍵 | 功能 | 說明 |
|--------|------|------|
| `Ctrl + Alt + A` | 管理員登入 | 在歡迎頁面快速登入管理員帳戶 |
| `Ctrl + Alt + H` | 顯示/隱藏提示 | 切換快捷鍵提示的顯示狀態 |
| `Esc × 3` | 快速管理員登入 | 2秒內連續按三次 Escape 鍵 |

### 為什麼選擇這些快捷鍵？

#### 避免瀏覽器衝突
我們特意選擇了不會與常見瀏覽器快捷鍵衝突的組合：

**Chrome 常用快捷鍵（已避免）：**
- `Ctrl + H` - 歷史記錄
- `Ctrl + Shift + A` - 搜索標籤頁
- `Ctrl + Shift + N` - 無痕模式
- `Ctrl + Shift + T` - 重新打開關閉的標籤頁

**我們的選擇：**
- `Ctrl + Alt + A` - 不與任何瀏覽器功能衝突
- `Ctrl + Alt + H` - 不與任何瀏覽器功能衝突
- `Esc × 3` - 完全獨立的序列，不會誤觸

### 快捷鍵使用技巧

#### 1. Ctrl + Alt 組合鍵
```
步驟：
1. 按住 Ctrl 鍵
2. 按住 Alt 鍵  
3. 按下目標鍵（A 或 H）
4. 同時釋放所有鍵
```

#### 2. Escape 序列
```
步驟：
1. 快速按下 Esc 鍵
2. 再次快速按下 Esc 鍵
3. 第三次快速按下 Esc 鍵
4. 整個序列需在 2 秒內完成
```

### 故障排除

#### 快捷鍵不起作用？

**檢查清單：**
- [ ] 確保頁面有焦點（點擊頁面任意位置）
- [ ] 確認按鍵順序正確
- [ ] 檢查是否有其他軟體攔截快捷鍵
- [ ] 嘗試刷新頁面後重試

**常見問題：**

1. **Ctrl + Alt 組合不響應**
   - 某些系統可能將此組合用於輸入法切換
   - 解決方案：使用 Escape 序列替代

2. **Escape 序列太快/太慢**
   - 序列必須在 2 秒內完成
   - 但也不能按得太快，每次按鍵間隔至少 100ms

3. **在某些鍵盤佈局下不工作**
   - 確保使用標準 QWERTY 鍵盤佈局
   - 或嘗試使用 Escape 序列

### 安全考量

#### 為什麼需要特殊快捷鍵？
1. **防止意外觸發**：複雜的組合鍵避免誤操作
2. **隱蔽性**：不會被普通用戶意外發現
3. **快速訪問**：開發和測試時的便利性

#### 安全措施
- 快捷鍵僅在歡迎頁面有效
- 需要有效的 Firebase 連接才能登入
- 管理員權限在後端驗證
- 所有操作都有日誌記錄

### 開發者注意事項

#### 添加新快捷鍵
如需添加新的快捷鍵，請遵循以下原則：

1. **避免衝突**：檢查與瀏覽器、操作系統的衝突
2. **邏輯性**：使用有意義的鍵位組合
3. **一致性**：保持與現有快捷鍵的風格一致
4. **文檔化**：更新所有相關文檔

#### 測試快捷鍵
```dart
// 測試快捷鍵的代碼示例
void _testKeyboardShortcuts() {
  // 模擬按鍵事件
  final event = KeyDownEvent(
    logicalKey: LogicalKeyboardKey.keyA,
    physicalKey: PhysicalKeyboardKey.keyA,
  );
  
  // 測試處理邏輯
  _handleKeyEvent(event);
}
```

### 跨平台兼容性

#### Windows
- `Ctrl + Alt + A/H` ✅ 完全支持
- `Esc × 3` ✅ 完全支持

#### macOS  
- `Cmd + Option + A/H` ✅ 自動映射
- `Esc × 3` ✅ 完全支持

#### Linux
- `Ctrl + Alt + A/H` ⚠️ 可能與桌面環境衝突
- `Esc × 3` ✅ 推薦使用

### 未來改進

#### 計劃中的功能
- **可自定義快捷鍵**：允許管理員設置自己的快捷鍵
- **手勢支持**：觸控設備的手勢快捷方式
- **語音命令**：語音激活管理員模式
- **生物識別**：指紋或面部識別快速登入

#### 技術改進
- **更好的衝突檢測**：自動檢測並避免快捷鍵衝突
- **上下文感知**：根據當前頁面調整可用快捷鍵
- **國際化支持**：支持不同鍵盤佈局和語言

---

這個快捷鍵系統設計考慮了實用性、安全性和用戶體驗，為 Amore 管理員提供了便捷而安全的訪問方式。 