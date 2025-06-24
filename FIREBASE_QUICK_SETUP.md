# 🔥 Firebase 快速設置指南

## ✅ 已完成的配置

我已經為您設置了以下 Firebase 配置：

### 📁 已創建的文件
- `lib/firebase_options.dart` - Firebase 配置選項
- `lib/core/services/firebase_service.dart` - Firebase 服務類
- `firestore.rules` - Firestore 安全規則
- `storage.rules` - Storage 安全規則
- `amore/android/build.gradle` - Android 構建配置
- `amore/android/app/build.gradle` - Android 應用配置
- `amore/android/app/src/main/AndroidManifest.xml` - Android 權限配置
- `amore/ios/Runner/Info.plist` - iOS 配置和權限

### 🛠 已配置的功能
- ✅ Firebase Core 初始化
- ✅ Authentication 配置
- ✅ Firestore 數據庫配置
- ✅ Storage 文件存儲配置
- ✅ Messaging 推送通知配置
- ✅ Analytics 分析配置
- ✅ Crashlytics 錯誤報告配置
- ✅ Android 和 iOS 平台配置

## 🚀 下一步操作

### 1. 創建 Firebase 項目

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「創建項目」
3. 項目名稱：`Amore Dating App`
4. 項目 ID：`amore-hk`
5. 啟用 Google Analytics

### 2. 啟用 Firebase 服務

在 Firebase Console 中啟用以下服務：

#### Authentication
- 前往 Authentication > Sign-in method
- 啟用：Email/Password、Google、Facebook

#### Firestore Database
- 前往 Firestore Database
- 創建數據庫（測試模式）
- 地區選擇：`asia-east1`（香港）

#### Storage
- 前往 Storage
- 開始使用
- 地區選擇：`asia-east1`（香港）

#### Cloud Messaging
- 前往 Cloud Messaging
- 自動啟用

### 3. 添加應用程式

#### Android 應用
1. 點擊「添加應用」> Android
2. 包名稱：`com.amore.hk`
3. 應用暱稱：`Amore Android`
4. 下載 `google-services.json`
5. 將文件放置在 `amore/android/app/` 目錄下

#### iOS 應用
1. 點擊「添加應用」> iOS
2. Bundle ID：`com.amore.hk`
3. 應用暱稱：`Amore iOS`
4. 下載 `GoogleService-Info.plist`
5. 將文件添加到 `amore/ios/Runner/` 目錄下

### 4. 更新配置文件

#### 更新 Firebase Options
編輯 `lib/firebase_options.dart`，將佔位符替換為實際值：

```dart
// 從 Firebase Console 獲取這些值
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: '1:your-project-number:android:your-android-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'amore-hk',
  storageBucket: 'amore-hk.appspot.com',
);
```

#### 更新環境變量
複製 `env.example` 為 `.env` 並填入實際值：

```bash
cp env.example .env
```

### 5. 設置安全規則

#### Firestore 規則
1. 前往 Firestore Database > 規則
2. 複製 `firestore.rules` 的內容並發布

#### Storage 規則
1. 前往 Storage > 規則
2. 複製 `storage.rules` 的內容並發布

### 6. 配置第三方登入

#### Google Sign-In
1. 前往 Google Cloud Console
2. 啟用 Google+ API
3. 創建 OAuth 2.0 客戶端 ID
4. 更新 `Info.plist` 中的 Google 客戶端 ID

#### Facebook Login
1. 前往 Facebook Developers
2. 創建應用程式
3. 獲取 App ID 和 Client Token
4. 更新 Android 和 iOS 配置

## 🧪 測試配置

運行以下命令測試 Firebase 連接：

```bash
cd amore
flutter run
```

檢查控制台輸出，確保看到：
- ✅ Firebase 初始化成功
- ✅ Firestore 配置完成
- ✅ Analytics 配置完成
- ✅ Messaging 配置完成

## 🔧 故障排除

### 常見問題

1. **Android 構建失敗**
   ```bash
   cd amore/android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **iOS 構建失敗**
   - 確保 `GoogleService-Info.plist` 已正確添加到 Xcode 項目
   - 檢查 Bundle ID 是否匹配

3. **Firebase 連接失敗**
   - 檢查 `google-services.json` 和 `GoogleService-Info.plist` 是否在正確位置
   - 確認項目 ID 和 API 密鑰正確

### 調試模式

在 `lib/core/services/firebase_service.dart` 中啟用調試：

```dart
if (kDebugMode) {
  print('🔥 Firebase 調試模式已啟用');
}
```

## 📱 下一步開發

Firebase 設置完成後，您可以開始：

1. **用戶認證** - 實現登入/註冊功能
2. **個人檔案** - 完成檔案設置 UI
3. **匹配系統** - 實現滑動匹配界面
4. **聊天功能** - 實現即時聊天
5. **推送通知** - 配置消息通知

## 🎯 重要提醒

- 🔒 在生產環境中使用強化的安全規則
- 📊 定期檢查 Firebase 使用量和成本
- 🔄 設置自動備份策略
- 🚨 配置監控和警報

---

**需要幫助？** 查看 [Firebase 文檔](https://firebase.google.com/docs) 或聯繫開發團隊。 