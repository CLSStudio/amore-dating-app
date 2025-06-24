# Firebase 配置指南

## 📋 設置步驟

### 1. 創建 Firebase 項目

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「創建項目」
3. 項目名稱：`amore-dating-hk`
4. 啟用 Google Analytics（推薦）
5. 選擇或創建 Analytics 帳戶

### 2. 配置應用平台

#### Web 應用
1. 在 Firebase 項目中點擊「添加應用」→ Web
2. 應用昵稱：`Amore Web`
3. 勾選「設置 Firebase Hosting」
4. 複製配置對象，更新 `lib/firebase_options.dart`

#### Android 應用
1. 點擊「添加應用」→ Android
2. Android 包名：`com.amore.dating.hk`
3. 應用昵稱：`Amore Android`
4. 下載 `google-services.json` 到 `android/app/`
5. 按照指南配置 Gradle 文件

#### iOS 應用
1. 點擊「添加應用」→ iOS
2. iOS 捆綁包 ID：`com.amore.dating.hk`
3. 應用昵稱：`Amore iOS`
4. 下載 `GoogleService-Info.plist` 到 `ios/Runner/`
5. 在 Xcode 中添加文件到項目

### 3. 啟用 Firebase 服務

#### Authentication
1. 前往 Authentication → Sign-in method
2. 啟用以下登錄方式：
   - 電子郵件/密碼
   - Google
   - Facebook（需要額外配置）
   - Apple（iOS 需要）
   - 電話號碼

#### Cloud Firestore
1. 前往 Firestore Database
2. 創建數據庫（測試模式開始）
3. 選擇位置：`asia-east2` (香港)
4. 設置安全規則（見下方）

#### Cloud Storage
1. 前往 Storage
2. 開始使用
3. 選擇位置：`asia-east2` (香港)
4. 設置安全規則（見下方）

#### Analytics
1. 自動啟用（如果在創建項目時選擇）
2. 配置轉換事件

#### Crashlytics
1. 前往 Crashlytics
2. 啟用 Crashlytics
3. 按照指南設置

#### Cloud Messaging
1. 前往 Cloud Messaging
2. 生成服務器密鑰（用於後端推送）

#### Remote Config
1. 前往 Remote Config
2. 添加參數（見下方建議配置）

## 🔒 安全規則

### Firestore 規則
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用戶只能訪問自己的文檔
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 配對邏輯
    match /matches/{matchId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid in resource.data.userIds);
    }
    
    // 聊天消息
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid in resource.data.participants);
        
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          (request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants);
      }
    }
    
    // 公開數據（僅讀取）
    match /public/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

### Storage 規則
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 用戶照片
    match /users/{userId}/photos/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // 其他用戶可以查看
    }
    
    // 聊天媒體
    match /conversations/{conversationId}/media/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid in firestore.get(/databases/(default)/documents/conversations/$(conversationId)).data.participants;
    }
  }
}
```

## ⚙️ Remote Config 建議配置

| 參數名稱 | 類型 | 默認值 | 描述 |
|---------|------|--------|------|
| `feature_video_call_enabled` | Boolean | `true` | 啟用視頻通話功能 |
| `feature_voice_call_enabled` | Boolean | `true` | 啟用語音通話功能 |
| `daily_swipe_limit` | Number | `100` | 每日滑卡限制 |
| `premium_daily_swipe_limit` | Number | `500` | Premium 用戶每日滑卡限制 |
| `min_match_threshold` | Number | `0.6` | 最小匹配閾值 |
| `maintenance_mode` | Boolean | `false` | 維護模式 |
| `app_version_required` | String | `1.0.0` | 最低要求應用版本 |

## 📱 平台特定配置

### Android 配置

#### `android/app/build.gradle`
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
    implementation 'com.google.firebase:firebase-messaging'
}

apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

#### `android/build.gradle`
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
    classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.4'
}
```

### iOS 配置

#### `ios/Runner/Info.plist`
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 🔧 故障排除

### 常見問題

1. **Web 版本編譯錯誤**
   - 當前 Firebase Web 版本與最新 Flutter 版本有兼容性問題
   - 建議先在 Android/iOS 平台測試
   - 等待 Firebase 更新或降級 Flutter 版本

2. **權限問題**
   - 確保 Firestore 和 Storage 規則正確設置
   - 檢查 Authentication 配置

3. **推送通知不工作**
   - 檢查 FCM 服務器密鑰配置
   - 確認應用已獲得通知權限

4. **社交登錄問題**
   - 確保 OAuth 客戶端 ID 正確配置
   - 檢查重定向 URI 設置

## 📞 後續步驟

1. **設置 Firebase 項目**：按照上述指南創建和配置
2. **更新配置文件**：將實際的 Firebase 配置替換到代碼中
3. **測試功能**：逐一測試認證、數據庫、存儲功能
4. **部署**：設置 Firebase Hosting 或其他部署方案

## 📚 相關資源

- [Firebase 文檔](https://firebase.google.com/docs)
- [FlutterFire 文檔](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Firebase 配置指南](https://firebase.flutter.dev/docs/overview) 