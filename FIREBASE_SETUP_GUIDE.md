# 🔥 Amore Firebase 完整設置指南

## 📋 **前置準備**

### 1. 安裝 Firebase CLI
```bash
# 使用 npm 安裝 Firebase CLI
npm install -g firebase-tools

# 或使用 Chocolatey (Windows)
choco install firebase-cli

# 驗證安裝
firebase --version
```

### 2. 登入 Firebase
```bash
firebase login
```

## 🚀 **快速設置步驟**

### 步驟 1: 創建 Firebase 項目
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「創建項目」
3. 項目名稱：`amore-hk`
4. 項目 ID：`amore-hk` (如果被佔用，使用 `amore-hk-2024`)
5. 啟用 Google Analytics（推薦）
6. 選擇地區：`asia-east1`（香港）

### 步驟 2: 添加 Web 應用
1. 在 Firebase 控制台中點擊「Web」圖標 `</>`
2. 應用暱稱：`Amore Web App`
3. ✅ 啟用 Firebase Hosting
4. 複製配置信息

### 步驟 3: 更新 Flutter 配置
將 Firebase 配置信息更新到 `lib/firebase_options.dart`：

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:web:YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'amore-hk',
    authDomain: 'amore-hk.firebaseapp.com',
    storageBucket: 'amore-hk.appspot.com',
    measurementId: 'G-YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'amore-hk',
    storageBucket: 'amore-hk.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'amore-hk',
    storageBucket: 'amore-hk.appspot.com',
    iosBundleId: 'com.amore.hk',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'amore-hk',
    storageBucket: 'amore-hk.appspot.com',
    iosBundleId: 'com.amore.hk',
  );
}
```

## 🔧 **詳細服務配置**

### 1. Authentication 設置
```bash
# 在 Firebase Console 中
1. 前往 Authentication > Sign-in method
2. 啟用以下登入方式：
   - ✅ Email/Password
   - ✅ Google
   - ✅ Facebook
   - ✅ Apple (iOS)
```

**Google 登入配置：**
- 添加授權網域：`localhost`, `amore-hk.web.app`
- 下載 `google-services.json` (Android)
- 下載 `GoogleService-Info.plist` (iOS)

### 2. Firestore Database 設置
```bash
# 創建數據庫
1. 前往 Firestore Database
2. 創建數據庫（生產模式）
3. 選擇地區：asia-east1（香港）
```

**安全規則：**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用戶資料
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // 允許其他用戶查看基本信息
    }
    
    // 配對資料
    match /matches/{matchId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // 聊天室
    match /chatRooms/{chatRoomId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // 消息
    match /chatRooms/{chatRoomId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // MBTI 測試結果
    match /mbtiResults/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 用戶偏好設置
    match /userPreferences/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Storage 設置
```bash
# 創建 Storage
1. 前往 Storage
2. 開始使用
3. 選擇地區：asia-east1
```

**Storage 規則：**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 用戶照片
    match /users/{userId}/photos/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024; // 5MB 限制
    }
    
    // 用戶頭像
    match /users/{userId}/avatar/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 2 * 1024 * 1024; // 2MB 限制
    }
    
    // 聊天圖片
    match /chats/{chatId}/images/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Cloud Messaging 設置
```bash
1. 前往 Cloud Messaging
2. 生成服務器密鑰
3. 配置 FCM 設置
```

### 5. Analytics 設置
```bash
1. 前往 Analytics
2. 啟用 Google Analytics
3. 配置轉換事件：
   - user_signup
   - user_login
   - profile_complete
   - mbti_test_complete
   - match_created
   - message_sent
```

## 📱 **平台特定配置**

### Android 配置
1. 下載 `google-services.json` 到 `android/app/`
2. 更新 `android/app/build.gradle`：
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.amore.hk"
        minSdkVersion 21
        targetSdkVersion 34
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-analytics'
}

apply plugin: 'com.google.gms.google-services'
```

3. 更新 `android/build.gradle`：
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

### iOS 配置
1. 下載 `GoogleService-Info.plist` 到 `ios/Runner/`
2. 在 Xcode 中添加到項目
3. 更新 `ios/Runner/Info.plist`：
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

## 🧪 **測試配置**

### 1. 測試 Firebase 連接
創建 `test_firebase.dart`：
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 初始化成功');
    
    // 測試 Firestore
    print('🔥 Firestore 可用');
    
    // 測試 Auth
    print('🔐 Authentication 可用');
    
    // 測試 Storage
    print('📁 Storage 可用');
    
  } catch (e) {
    print('❌ Firebase 初始化失敗: $e');
  }
}
```

### 2. 運行測試
```bash
dart test_firebase.dart
```

## 🚀 **部署設置**

### 1. Firebase Hosting
```bash
# 初始化 Hosting
firebase init hosting

# 構建 Web 版本
flutter build web

# 部署
firebase deploy --only hosting
```

### 2. 環境變量
創建 `.env` 文件：
```env
FIREBASE_PROJECT_ID=amore-hk
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=amore-hk.firebaseapp.com
FIREBASE_STORAGE_BUCKET=amore-hk.appspot.com
```

## 📊 **監控和分析**

### 1. Performance Monitoring
```bash
1. 前往 Performance
2. 啟用性能監控
3. 設置自定義追蹤
```

### 2. Crashlytics
```bash
1. 前往 Crashlytics
2. 啟用崩潰報告
3. 配置符號上傳
```

## 🔒 **安全最佳實踐**

### 1. API 密鑰安全
- 限制 API 密鑰使用範圍
- 設置 HTTP 引用者限制
- 定期輪換密鑰

### 2. 數據庫安全
- 使用嚴格的安全規則
- 啟用審計日誌
- 定期檢查訪問權限

### 3. 用戶隱私
- 實施數據加密
- 提供數據刪除選項
- 遵循 GDPR 規範

## 🎯 **下一步行動**

### 立即執行：
1. ✅ 創建 Firebase 項目
2. ✅ 配置 Web 應用
3. ✅ 更新 `firebase_options.dart`
4. ✅ 測試基本連接

### 本週完成：
1. 🔄 設置 Authentication
2. 🔄 配置 Firestore
3. 🔄 設置 Storage
4. 🔄 測試所有服務

### 下週目標：
1. 📱 添加 Android/iOS 配置
2. 🚀 部署到 Hosting
3. 📊 設置監控
4. 🔒 加強安全設置

---

**🎉 恭喜！完成這些步驟後，你的 Amore 應用將擁有完整的 Firebase 後端支持！** 