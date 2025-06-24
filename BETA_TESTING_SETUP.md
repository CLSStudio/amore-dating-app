# Amore Beta 測試設置指南

## 🚀 快速開始

### 1. 安裝必要工具

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 確認 Flutter 已安裝並可用
flutter doctor
```

### 2. 設置 Firebase App Distribution

```bash
# 運行設置腳本
./scripts/setup_beta_testing.sh
```

### 3. 配置測試人員

編輯以下文件添加測試人員電子郵件：
- `scripts/internal_testers.txt` - 內部團隊成員
- `scripts/beta_testers.txt` - 外部 Beta 測試人員

### 4. 構建和分發 Beta 版本

```bash
# 構建並分發到所有平台
./scripts/build_and_distribute.sh both "第一個 Beta 版本 - 核心功能測試"

# 僅構建 Android
./scripts/build_and_distribute.sh android "Android 專屬更新"

# 僅構建 iOS (需要 macOS)
./scripts/build_and_distribute.sh ios "iOS 專屬更新"
```

## 📋 詳細配置

### Firebase Console 設置

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 選擇您的 Amore 項目
3. 導航到 **App Distribution**
4. 確認 Android 和 iOS 應用程式已註冊

### GitHub Secrets 配置

為了啟用自動化 CI/CD，需要在 GitHub 倉庫中配置以下 Secrets：

1. `FIREBASE_ANDROID_APP_ID` - Android 應用程式 ID
2. `FIREBASE_IOS_APP_ID` - iOS 應用程式 ID  
3. `CREDENTIAL_FILE_CONTENT` - Firebase 服務帳戶 JSON 內容
4. `IOS_TEAM_ID` - iOS 開發團隊 ID
5. `IOS_PROVISIONING_PROFILE_UUID` - iOS 配置文件 UUID
6. `IOS_CODE_SIGN_IDENTITY` - iOS 代碼簽名身份

### iOS 代碼簽名設置

1. 在 Apple Developer Console 中創建：
   - App ID: `com.example.amore`
   - 開發和分發證書
   - Ad-Hoc 配置文件

2. 在 Xcode 中配置：
   - 打開 `ios/Runner.xcworkspace`
   - 設置 Development Team
   - 選擇正確的配置文件

## 🔄 自動化工作流程

### GitHub Actions

項目已配置 GitHub Actions 工作流程 (`.github/workflows/beta_release.yml`)：

- **觸發條件**: 推送到 `main` 或 `beta` 分支
- **手動觸發**: 在 Actions 頁面手動運行
- **自動功能**: 
  - 運行測試
  - 構建 APK 和 IPA
  - 分發到 Firebase App Distribution
  - 通知測試人員

### 分支策略

- `main` - 穩定版本，每次推送觸發 Beta 分發
- `beta` - 測試版本，用於頻繁的 Beta 發布
- `develop` - 開發分支，不自動分發

## 📱 測試人員體驗

### 接收邀請

1. 測試人員將收到 Firebase App Distribution 的電子郵件邀請
2. 點擊邀請鏈接並按照說明安裝應用程式
3. 每次新版本發布時會收到通知

### Android 安裝

1. 允許從未知來源安裝應用程式
2. 下載並安裝 APK 文件
3. 提供反饋和錯誤報告

### iOS 安裝

1. 在 iOS 設備上點擊邀請鏈接
2. 安裝配置文件（如果需要）
3. 從主屏幕啟動應用程式

## 🐛 測試重點

### 核心功能測試

- [ ] 用戶註冊和登入
- [ ] MBTI 性格測試
- [ ] 個人資料創建和編輯
- [ ] 瀏覽和配對功能
- [ ] 聊天功能
- [ ] 推送通知

### 平台特定測試

**Android**:
- [ ] 各種屏幕尺寸適配
- [ ] Android 權限處理
- [ ] 後台應用程式行為

**iOS**:
- [ ] iOS 設計規範遵循
- [ ] iOS 權限處理
- [ ] App Store 合規性

### 性能測試

- [ ] 應用程式啟動時間
- [ ] 圖片加載性能
- [ ] 網絡連接穩定性
- [ ] 記憶體使用情況

## 📊 監控和分析

### Firebase Analytics

- 自動追蹤用戶行為
- 監控崩潰和錯誤
- 分析用戶流失和留存

### 反饋收集

1. **應用程式內反饋**: 整合反饋表單
2. **電子郵件反饋**: 直接聯繫開發團隊
3. **Firebase Crashlytics**: 自動錯誤報告

## 🚨 故障排除

### 常見問題

**構建失敗**:
1. 檢查 Flutter 版本兼容性
2. 運行 `flutter clean && flutter pub get`
3. 確認所有依賴項已正確安裝

**Firebase 分發失敗**:
1. 確認 Firebase CLI 已登入
2. 檢查項目權限
3. 驗證應用程式 ID 正確

**iOS 代碼簽名錯誤**:
1. 檢查證書有效性
2. 確認配置文件匹配
3. 驗證 Bundle ID 一致性

### 聯繫支援

- **技術問題**: 創建 GitHub Issue
- **測試反饋**: 發送至測試團隊電子郵件
- **緊急問題**: 聯繫項目負責人

## 📈 下一步

1. **擴展測試群組**: 逐步增加 Beta 測試人員
2. **性能優化**: 基於測試反饋優化應用程式
3. **準備發布**: 完成 App Store 和 Google Play 審核準備
4. **市場推廣**: 制定香港市場推廣策略

---

> 💡 **提示**: 定期更新此文檔以反映最新的設置和流程變化 