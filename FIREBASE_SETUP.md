# Firebase 項目設置指南

## 📋 設置步驟

### 1. 創建 Firebase 項目

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「創建項目」
3. 項目名稱：`amore-hk`
4. 啟用 Google Analytics（推薦）
5. 選擇 Analytics 帳戶或創建新帳戶

### 2. 啟用必要的服務

#### Authentication
1. 在 Firebase Console 中選擇「Authentication」
2. 點擊「開始使用」
3. 在「Sign-in method」標籤中啟用：
   - ✅ Email/Password
   - ✅ Google
   - ✅ Facebook
4. 配置授權域名（添加您的域名）

#### Firestore Database
1. 選擇「Firestore Database」
2. 點擊「創建數據庫」
3. 選擇「以測試模式啟動」（稍後會設置安全規則）
4. 選擇地區：`asia-east1`（香港）

#### Storage
1. 選擇「Storage」
2. 點擊「開始使用」
3. 選擇地區：`asia-east1`（香港）

#### Cloud Functions
1. 選擇「Functions」
2. 升級到 Blaze 計劃（按使用量付費）

### 3. 配置應用程式

#### Android 配置
1. 在項目概覽中點擊「添加應用」
2. 選擇 Android 圖標
3. 包名稱：`com.amore.hk`
4. 應用暱稱：`Amore`
5. 下載 `google-services.json`
6. 將文件放置在 `android/app/` 目錄下

#### iOS 配置
1. 點擊「添加應用」
2. 選擇 iOS 圖標
3. Bundle ID：`com.amore.hk`
4. 應用暱稱：`Amore`
5. 下載 `GoogleService-Info.plist`
6. 將文件添加到 iOS 項目中

### 4. 更新 Firebase 配置

運行以下命令生成配置文件：

```bash
# 安裝 FlutterFire CLI
dart pub global activate flutterfire_cli

# 配置 Firebase
flutterfire configure --project=amore-hk
```

### 5. 安全規則設置

#### Firestore 規則
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用戶只能讀寫自己的數據
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // MBTI 結果
    match /mbti_results/{resultId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // 價值觀評估結果
    match /values_assessments/{assessmentId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // 匹配數據（雙方都可以讀取）
    match /matches/{matchId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.user1Id || request.auth.uid == resource.data.user2Id);
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.user1Id || request.auth.uid == resource.data.user2Id);
    }
    
    // 聊天消息
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage 規則
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 用戶檔案圖片
    match /profile_images/{userId}/{imageId} {
      allow read: if true; // 公開可讀
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024 // 5MB 限制
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### 6. 環境變量配置

創建 `.env` 文件（不要提交到版本控制）：

```env
# Firebase 項目配置
FIREBASE_PROJECT_ID=amore-hk
FIREBASE_API_KEY_ANDROID=your_android_api_key
FIREBASE_API_KEY_IOS=your_ios_api_key
FIREBASE_API_KEY_WEB=your_web_api_key

# 第三方服務
GOOGLE_SIGN_IN_CLIENT_ID=your_google_client_id
FACEBOOK_APP_ID=your_facebook_app_id

# 其他配置
ENVIRONMENT=development
DEBUG_MODE=true
```

### 7. 測試配置

運行以下命令測試 Firebase 連接：

```bash
flutter run
```

檢查控制台輸出，確保 Firebase 初始化成功。

## 🔧 故障排除

### 常見問題

1. **Android 構建失敗**
   - 確保 `google-services.json` 在正確位置
   - 檢查 `android/build.gradle` 中的 Google Services 插件

2. **iOS 構建失敗**
   - 確保 `GoogleService-Info.plist` 已添加到 Xcode 項目
   - 檢查 Bundle ID 是否匹配

3. **認證失敗**
   - 檢查 SHA-1 指紋是否正確配置
   - 確保授權域名已添加

### 調試技巧

1. 啟用 Firebase 調試模式：
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

2. 檢查網絡連接：
```dart
final connectivityResult = await Connectivity().checkConnectivity();
```

## 📊 監控和分析

### Firebase Analytics 事件

建議追蹤的關鍵事件：
- `user_registration`
- `user_login`
- `mbti_test_completed`
- `profile_completed`
- `match_found`
- `message_sent`
- `premium_purchase`

### Performance Monitoring

啟用性能監控來追蹤應用程式性能：
```dart
FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
```

## 🚀 部署準備

### 生產環境配置

1. 更新安全規則為生產環境
2. 設置備份策略
3. 配置監控和警報
4. 設置 CI/CD 流水線

### 成本優化

1. 設置預算警報
2. 優化 Firestore 查詢
3. 使用 Firebase 緩存
4. 監控 Storage 使用量

---

**注意**：請確保在生產環境中使用強化的安全規則，並定期審查訪問權限。 