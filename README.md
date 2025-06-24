# 💕 Amore - 智能約會應用

> 一個針對香港市場的跨平台約會應用，使用 Flutter 開發，提供超越傳統約會應用的深度連結體驗。

## 🎯 項目概述

Amore 是一個創新的約會應用，專為 Gen Z 和 30-40 歲群體設計，通過 AI 技術和深度匹配算法，提供更有意義的約會體驗。

### ✨ 核心特色

- 🧠 **AI 驅動的智能匹配** - 基於 MBTI、興趣、價值觀的多維度算法
- 💬 **智能聊天助手** - 個性化破冰話題和約會建議
- 📱 **Stories 功能** - 24小時限時動態，展示真實生活
- 📹 **內建視頻通話** - 安全的線上見面功能
- 💎 **Premium 訂閱** - 多層級付費功能
- 🔔 **智能通知系統** - 個性化通知管理
- 🌐 **社交媒體集成** - 連接 Instagram、Spotify、TikTok
- 🎪 **活動推薦** - 基於興趣的個性化活動匹配
- 📊 **關係追蹤** - 完整的關係生命週期管理

## 🏗️ 技術架構

### 前端技術
- **Flutter** - 跨平台移動應用開發
- **Dart** - 程式語言
- **Riverpod** - 狀態管理
- **Material Design 3** - UI 設計系統

### 後端服務
- **Firebase** - 後端即服務
  - Authentication - 用戶認證
  - Firestore - 實時數據庫
  - Cloud Storage - 文件存儲
  - Cloud Functions - 雲端函數
  - Cloud Messaging - 推送通知

### AI 技術
- **多維度匹配算法** - 智能配對
- **自然語言處理** - 聊天建議
- **機器學習** - 用戶偏好學習

## 📱 功能模組

### ✅ 已完成功能 (9/9)

1. **🎯 增強滑動算法** - 多維度智能匹配
2. **🤖 AI 聊天助手** - 智能對話建議和約會規劃
3. **📸 Stories 功能** - 多媒體生活分享
4. **📹 視頻通話** - 實時音視頻通信
5. **💎 Premium 訂閱** - 多層級付費功能
6. **🔔 推送通知** - 個性化通知系統
7. **🌐 社交媒體集成** - Instagram、Spotify、TikTok 連接
8. **🎪 活動推薦系統** - 智能活動匹配和社交機會
9. **📊 關係成功追蹤** - 完整關係生命週期管理

### 🎨 UI/UX 特色

- **溫暖粉色系主色調** (#E91E63)
- **流暢動畫效果** - 60fps 性能優化
- **響應式設計** - 適配不同屏幕尺寸
- **無障礙性支援** - 包容性設計
- **直觀手勢操作** - 滑動、點擊、長按

## 🚀 快速開始

### 環境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- iOS 開發需要 Xcode (macOS)

### 安裝步驟

1. **克隆項目**
   ```bash
   git clone https://github.com/your-username/amore.git
   cd amore
   ```

2. **安裝依賴**
   ```bash
   flutter pub get
   ```

3. **配置 Firebase**
   - 在 Firebase Console 創建新項目
   - 下載 `google-services.json` (Android) 和 `GoogleService-Info.plist` (iOS)
   - 放置到相應的平台目錄

4. **運行應用**
   ```bash
   # 運行功能演示版本
   flutter run lib/demo_main.dart
   
   # 或運行完整版本
   flutter run
   ```

### 🎮 演示模式

我們提供了一個功能演示版本，可以直接體驗所有已完成的功能：

```bash
flutter run lib/demo_main.dart
```

這將啟動功能展示頁面，您可以：
- 瀏覽所有 9 個核心功能
- 體驗 Premium 訂閱流程
- 測試通知設置
- 探索社交媒體集成
- 查看活動推薦系統
- 分析關係追蹤功能

## 📁 項目結構

```
lib/
├── core/                    # 核心配置和服務
├── features/               # 功能模組
│   ├── discovery/          # 智能滑動匹配
│   ├── chat/              # AI 聊天助手
│   ├── stories/           # Stories 功能
│   ├── video_call/        # 視頻通話
│   ├── premium/           # Premium 訂閱
│   ├── notifications/     # 推送通知
│   ├── social_media/      # 社交媒體集成
│   ├── events/            # 活動推薦
│   ├── relationship_tracking/ # 關係追蹤
│   └── home/              # 主頁和導航
├── shared/                # 共享組件
└── main.dart             # 應用入口
```

## 🎯 目標用戶

### Gen Z (18-25歲)
- **特點**: 數位原住民，重視真實性和創意表達
- **需求**: 趣味互動、視覺化內容、社交媒體整合
- **提供價值**: Stories 功能、AI 助手、活動推薦

### 30-40歲群體
- **特點**: 事業穩定，尋求長期關係和深度連結
- **需求**: 高效匹配、關係指導、安全可靠
- **提供價值**: 智能匹配、關係追蹤、專業建議

## 📊 性能指標

### 技術性能
- ⚡ 應用啟動時間: < 3 秒
- 🚀 頁面載入時間: < 2 秒
- 💾 內存使用: 優化的內存管理
- 🔋 電池消耗: 高效的後台處理

### 用戶體驗目標
- 📈 日活躍用戶: > 70%
- 💕 匹配成功率: > 25%
- 📱 Stories 使用率: > 60%
- 📹 視頻通話使用率: > 40%
- 💎 Premium 轉化率: > 15%

## 🔒 安全和隱私

### 數據保護
- 🔐 端到端加密傳輸
- 🛡️ Firebase 安全規則
- 🔒 用戶隱私控制
- 📝 數據最小化原則

### 安全功能
- 🚨 多層級舉報機制
- 🚫 即時封鎖和過濾
- 🤖 AI 輔助內容審核
- 📱 照片真實性驗證

## 🚀 部署

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### 測試
```bash
# 運行單元測試
flutter test

# 運行集成測試
flutter drive --target=test_driver/app.dart
```

## 🤝 貢獻指南

1. Fork 項目
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 許可證

本項目採用 MIT 許可證 - 查看 [LICENSE](LICENSE) 文件了解詳情。

## 📞 聯繫我們

- 📧 Email: contact@amore.app
- 🌐 Website: https://amore.app
- 📱 App Store: [即將上線]
- 🤖 Google Play: [即將上線]

## 🙏 致謝

感謝所有為 Amore 項目做出貢獻的開發者和設計師。

---

**讓愛情更智能，讓連結更深刻** 💕

Made with ❤️ in Hong Kong 