# Amore - 智能約會應用程式

Amore 是一款專為香港市場設計的智能約會應用程式，旨在連接 Gen Z 和 30-40 歲群體，提供超越傳統約會應用的深度配對體驗。

## 項目概述

Amore 運用先進的 AI 技術，基於 MBTI 性格類型和深層價值觀分析，為用戶提供更精準、更有意義的配對服務。

### 核心特色

- 🧠 **AI 智能配對** - 基於 MBTI 和價值觀的深度匹配算法
- 🔒 **安全認證** - AI 照片驗證和多重安全機制
- 💝 **專業諮詢** - AI 愛情顧問和專業關係指導
- 📱 **原生性能** - Flutter 構建的跨平台原生應用
- 🎥 **視頻通話** - 應用內安全視頻通話功能
- 🇭🇰 **本地化** - 專為香港市場優化

## 技術架構

### 前端技術
- **Flutter 3.1+** - 跨平台移動應用開發框架
- **Dart** - 程式語言
- **Riverpod** - 狀態管理
- **Go Router** - 路由管理
- **Flutter Animate** - 動畫效果

### 後端服務
- **Firebase** - 完整的後端即服務平台
  - Authentication - 用戶認證
  - Firestore - 雲端數據庫
  - Storage - 文件存儲
  - Cloud Functions - 服務端邏輯
  - Analytics - 用戶分析
  - Crashlytics - 崩潰報告
  - Remote Config - 遠程配置
  - Cloud Messaging - 推送通知

### 第三方集成
- **Agora** - 視頻通話服務
- **Google Maps** - 位置服務
- **In-App Purchase** - 付費功能

## 項目結構

```
amore/
├── lib/
│   ├── core/                 # 核心功能
│   │   ├── app_config.dart  # 應用配置
│   │   ├── router/          # 路由配置
│   │   ├── theme/           # 主題配置
│   │   ├── services/        # 核心服務
│   │   │   ├── firebase_service.dart        # Firebase 統一服務
│   │   │   ├── auth_service.dart           # 認證服務
│   │   │   └── app_service_manager.dart    # 應用服務管理器
│   │   └── models/          # 數據模型
│   │       ├── user_model.dart             # 用戶模型
│   │       ├── match_model.dart            # 配對模型
│   │       ├── chat_model.dart             # 聊天模型
│   │       └── video_call_model.dart       # 視頻通話模型
│   ├── features/            # 功能模組
│   │   ├── auth/           # 認證模組
│   │   ├── profile/        # 個人檔案
│   │   ├── matching/       # 配對功能
│   │   │   └── services/
│   │   │       └── matching_service.dart   # 智能配對算法
│   │   ├── chat/           # 聊天功能
│   │   │   └── services/
│   │   │       ├── chat_service.dart       # 實時聊天服務
│   │   │       └── video_call_service.dart # 視頻通話服務
│   │   ├── settings/       # 設定
│   │   └── premium/        # 付費功能
│   ├── shared/             # 共享組件
│   │   └── widgets/        # 通用組件
│   ├── firebase_options.dart  # Firebase 配置
│   └── main.dart           # 應用入口
├── assets/                 # 資源文件
├── android/               # Android 平台配置
├── ios/                   # iOS 平台配置
├── FIREBASE_SETUP.md      # Firebase 設置指南
├── FEATURE_USAGE_GUIDE.md # 功能使用指南
└── pubspec.yaml           # 依賴配置
```

## 核心功能

### 1. ✅ 用戶認證系統
- 電子郵件/手機號碼註冊
- 社交媒體登錄（Google、Facebook、Apple）
- 多步驟註冊流程
- 身份驗證和安全檢查

### 2. ✅ 智能檔案創建
- MBTI 性格測試（60 題）
- 價值觀問卷（30 題）
- 多媒體檔案支持
- 社交帳戶連接

### 3. ✅ AI 配對算法
- **MBTI 兼容性分析** (30%): 基於 16 型人格匹配
- **興趣匹配度計算** (25%): 共同興趣和愛好
- **年齡兼容性評估** (15%): 年齡差距和偏好範圍
- **地理位置評分** (15%): 距離和位置偏好
- **價值觀匹配** (10%): 關係目標和生活方式
- **用戶活躍度** (5%): 最近活躍時間評估

### 4. ✅ 實時聊天系統
- **即時消息**: 文字、圖片、語音、視頻消息
- **已讀狀態**: 消息送達和已讀指示器
- **輸入狀態**: 實時顯示對方輸入狀態
- **媒體上傳**: Firebase Storage 集成
- **消息管理**: 刪除、回覆、轉發功能
- **用戶封鎖**: 安全和隱私保護

### 5. ✅ 視頻通話功能
- **高質量視頻通話**: Agora SDK 集成
- **語音通話**: 純音頻通話選項
- **實時控制**: 攝像頭/麥克風開關、前後攝像頭切換
- **通話管理**: 發起、接聽、拒絕、結束通話
- **通話歷史**: 完整的通話記錄和統計
- **來電處理**: 後台來電監聽和通知

### 6. ✅ 互動功能
- 流暢的滑卡介面
- AI 破冰話題生成
- 約會建議系統
- 配對成功慶祝動畫

### 7. 🔄 Premium 功能
- 無限滑卡
- 高級篩選器
- 查看誰喜歡你
- AI 愛情顧問服務
- 專業關係諮詢

## 🚀 快速開始

### 先決條件
- Flutter SDK 3.1.0 或更高版本
- Dart SDK
- Android Studio / VS Code
- iOS 開發需要 Xcode (macOS)
- Firebase 項目帳戶
- Agora 開發者帳戶

### 安裝步驟

1. **克隆專案**
   ```bash
   git clone <repository-url>
   cd amore
   ```

2. **安裝依賴**
   ```bash
   flutter pub get
   ```

3. **Firebase 配置**
   
   **重要：** 請按照 [FIREBASE_SETUP.md](FIREBASE_SETUP.md) 詳細指南設置 Firebase 項目：
   
   - 創建 Firebase 項目
   - 配置 Authentication、Firestore、Storage 等服務
   - 下載並配置平台特定的配置文件
   - 更新 `lib/firebase_options.dart` 中的實際配置

4. **Agora 配置**
   
   - 在 [Agora Console](https://console.agora.io/) 創建項目
   - 獲取 App ID
   - 更新 `lib/features/chat/services/video_call_service.dart` 中的 `_agoraAppId`

5. **生成代碼**
   ```bash
   flutter packages pub run build_runner build
   ```

6. **設置開發環境**
   ```bash
   flutter doctor
   ```

7. **運行應用**
   ```bash
   # Android
   flutter run

   # iOS (需要 macOS)
   flutter run -d ios
   
   # Web (目前有兼容性問題，推薦使用移動平台)
   flutter run -d chrome
   ```

## 🔧 開發說明

### 當前狀態

✅ **已完成：**
- 完整的項目架構和文件結構
- 用戶界面和路由系統
- Firebase 服務集成代碼
- 認證服務實現
- 用戶數據模型
- **智能配對算法系統**
- **實時聊天功能**
- **視頻通話服務**
- 主題和樣式系統
- 應用服務管理器

⚠️ **需要配置：**
- Firebase 項目設置（按照 FIREBASE_SETUP.md）
- Agora 項目配置
- 平台特定的配置文件
- 第三方服務 API 密鑰

🐛 **已知問題：**
- Web 平台目前有 Firebase 兼容性問題，建議使用 Android/iOS 平台測試

### 功能使用指南

詳細的功能使用說明請參考 [FEATURE_USAGE_GUIDE.md](FEATURE_USAGE_GUIDE.md)，包含：

- 智能配對算法的使用和自定義
- 實時聊天功能的實現
- 視頻通話服務的集成
- 性能優化建議

### 測試指南

```bash
# 單元測試
flutter test

# 集成測試
flutter drive --target=test_driver/app.dart

# Widget 測試
flutter test test/widget_test.dart
```

## 📋 Firebase 設置

這個項目需要完整的 Firebase 配置才能正常運行。請按照以下步驟設置：

1. **閱讀設置指南：** 詳細閱讀 [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
2. **創建 Firebase 項目：** 在 Firebase Console 創建新項目
3. **配置服務：** 啟用 Authentication、Firestore、Storage 等
4. **下載配置文件：** 獲取平台特定的配置文件
5. **更新代碼：** 將實際配置替換到 `firebase_options.dart`

### 必需的 Firebase 服務

- ✅ **Authentication** - 用戶登錄註冊
- ✅ **Cloud Firestore** - 數據存儲（用戶、配對、聊天、通話記錄）
- ✅ **Cloud Storage** - 文件上傳（用戶照片、聊天媒體）
- ✅ **Analytics** - 用戶分析
- ✅ **Crashlytics** - 崩潰報告
- ✅ **Cloud Messaging** - 推送通知
- ✅ **Remote Config** - 遠程配置

## 🎥 Agora 視頻通話設置

1. **創建 Agora 項目：** 在 [Agora Console](https://console.agora.io/) 註冊並創建項目
2. **獲取 App ID：** 從項目設置中獲取 App ID
3. **更新配置：** 將 App ID 更新到 `VideoCallService` 中
4. **權限配置：** 確保 Android/iOS 項目已添加攝像頭和麥克風權限

## 🗺️ 路線圖

### v1.1 (已完成)
- ✅ 智能配對算法實現
- ✅ 實時聊天功能
- ✅ 視頻通話集成

### v1.2 (計劃中)
- [ ] AI 聊天機器人集成
- [ ] 群組約會功能
- [ ] 事件和活動系統
- [ ] 高級配對算法優化

### v2.0 (未來)
- [ ] AR 濾鏡和特效
- [ ] 語音信息功能
- [ ] 智能約會建議
- [ ] 多語言支持擴展

## 📊 技術架構

### 前端架構
- **狀態管理**: Riverpod
- **路由**: Go Router
- **UI框架**: Flutter Material Design
- **動畫**: Flutter Animate

### 後端架構
- **數據庫**: Cloud Firestore
- **認證**: Firebase Auth
- **存儲**: Firebase Storage
- **實時通信**: Firestore Realtime Updates
- **視頻通話**: Agora RTC SDK
- **推送通知**: Firebase Cloud Messaging

### 數據流架構
```
UI Layer (Widgets)
    ↕
Business Logic Layer (AppServiceManager)
    ↕
Service Layer (MatchingService, ChatService, VideoCallService)
    ↕
Data Layer (Firebase, Agora)
```

## 🏗️ 構建和部署

### Android 構建
```bash
# 調試版本
flutter build apk --debug

# 發布版本
flutter build apk --release
flutter build appbundle --release
```

### iOS 構建
```bash
# 調試版本
flutter build ios --debug

# 發布版本
flutter build ios --release
```

### 部署到應用商店

詳細的部署指南請參考：
- [Google Play Store 發布指南](https://developer.android.com/distribute/googleplay)
- [Apple App Store 發布指南](https://developer.apple.com/app-store/)

## 🔐 安全和隱私

- 端到端加密的聊天消息
- GDPR 和香港隱私法規合規
- 用戶數據匿名化處理
- 安全的支付處理
- 定期安全審計

## 🌍 國際化

目前支持的語言：
- 繁體中文（香港）
- 繁體中文（台灣）
- 英語

## 🤝 貢獻指南

1. Fork 專案
2. 創建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 創建 Pull Request

## 📄 許可證

此項目使用 MIT 許可證。詳情請參閱 [LICENSE](LICENSE) 文件。

## 📞 支持

如有任何問題或需要支持：

- 📧 Email: support@amore.hk
- 📱 技術支持: +852-1234-5678
- 💬 Discord: [Amore 開發者社群](https://discord.gg/amore)

## 🗺️ 路線圖

### v1.1 (下一版本)
- [ ] AI 聊天機器人集成
- [ ] 視頻通話功能
- [ ] 高級配對算法優化

### v1.2
- [ ] 群組約會功能
- [ ] 事件和活動系統
- [ ] 多語言支持擴展

### v2.0
- [ ] AR 濾鏡和特效
- [ ] 語音信息功能
- [ ] 智能約會建議

---

© 2024 Amore Dating App. 保留所有權利。

Made with ❤️ in Hong Kong 