# Amore iOS 開發設置指南

## 概述

本指南將幫助您設置 Amore iOS 應用程式的完整開發環境，包括本地開發、自動構建和 App Store 發布。

## 前置要求

### 硬體要求
- macOS 電腦（用於本地 iOS 開發）
- 或者：使用 GitHub Actions 進行雲端構建（推薦）

### 軟體要求
- Flutter 3.16.0+
- Xcode 15.0+
- CocoaPods
- Apple Developer 帳戶（付費）

## 1. 本地開發環境設置

### 安裝 Flutter 和 Xcode

```bash
# 1. 安裝 Flutter（如果尚未安裝）
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# 2. 安裝 Xcode
# 從 Mac App Store 安裝 Xcode

# 3. 安裝 CocoaPods
sudo gem install cocoapods

# 4. 驗證環境
flutter doctor
```

### 設置 iOS 專案

```bash
# 1. 克隆專案
git clone [your-repo-url]
cd Amore

# 2. 安裝依賴
flutter pub get

# 3. 安裝 iOS 依賴
cd ios
pod install
cd ..
```

## 2. Apple Developer 帳戶設置

### 創建 App ID

1. 登入 [Apple Developer Console](https://developer.apple.com/account/)
2. 前往 Certificates, Identifiers & Profiles
3. 創建新的 App ID:
   - Bundle ID: `hk.amore.dating`
   - Description: Amore Dating App
   - 啟用所需的 Capabilities:
     - Push Notifications
     - Background Modes
     - Sign in with Apple
     - Associated Domains

### 創建證書

1. 創建 iOS Distribution Certificate
2. 下載 .p12 文件（包含私鑰）
3. 記錄密碼

### 創建 Provisioning Profile

1. 創建 App Store Distribution Provisioning Profile
2. 選擇您的 App ID 和 Distribution Certificate
3. 下載 .mobileprovision 文件

## 3. Firebase 配置

### iOS 應用程式註冊

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 選擇 amore-hk 專案
3. 添加 iOS 應用程式:
   - Bundle ID: `hk.amore.dating`
   - App Store ID: (稍後填寫)
4. 下載 `GoogleService-Info.plist`
5. 將文件放置在 `ios/Runner/` 目錄中

### Firebase App Distribution 設置

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 登入 Firebase
firebase login

# 設置專案
firebase use amore-hk
```

## 4. GitHub Actions 自動構建設置

### 創建 GitHub Secrets

在 GitHub 倉庫設置中添加以下 Secrets：

#### iOS 相關 Secrets

```
BUILD_CERTIFICATE_BASE64
# Apple Distribution Certificate (.p12) 的 base64 編碼
# 生成方法：base64 -i certificate.p12 | pbcopy

P12_PASSWORD
# .p12 文件的密碼

BUILD_PROVISION_PROFILE_BASE64
# Provisioning Profile (.mobileprovision) 的 base64 編碼
# 生成方法：base64 -i profile.mobileprovision | pbcopy

KEYCHAIN_PASSWORD
# 臨時 keychain 密碼（隨機生成）

IOS_TEAM_ID
# Apple Developer Team ID（在 Membership 頁面查看）

IOS_CODE_SIGN_IDENTITY
# 例如："iPhone Distribution: Your Company Name (XXXXXXXXXX)"

IOS_PROVISIONING_PROFILE_NAME
# Provisioning Profile 的名稱
```

#### Firebase 相關 Secrets

```
FIREBASE_IOS_APP_ID
# Firebase iOS 應用程式 ID，格式：1:380903609347:ios:532f9ba1ffd4f54f60aa36

CREDENTIAL_FILE_CONTENT
# Firebase Service Account JSON 的內容
```

### 生成 Service Account

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 選擇您的專案
3. 前往 IAM & Admin > Service Accounts
4. 創建新的 Service Account
5. 授予 Firebase Admin SDK Administrator Service Agent 角色
6. 創建 JSON 密鑰
7. 將 JSON 內容作為 `CREDENTIAL_FILE_CONTENT` Secret

## 5. 本地構建和測試

### 運行 iOS 模擬器

```bash
# 列出可用的模擬器
xcrun simctl list devices

# 啟動模擬器
open -a Simulator

# 運行應用程式
flutter run -d ios
```

### 構建 iOS Beta

```bash
# 使用提供的腳本（僅 macOS）
chmod +x scripts/build_ios_beta.sh
./scripts/build_ios_beta.sh

# 或手動構建
flutter build ios --release
```

## 6. 自動構建觸發

### 推送到 Beta 分支

```bash
git checkout -b beta
git push origin beta
```

### 手動觸發構建

```bash
# 使用 GitHub CLI
gh workflow run beta_release.yml

# 或在 GitHub Web 界面手動觸發
```

## 7. App Store 發布準備

### 更新版本信息

在 `pubspec.yaml` 中：

```yaml
version: 1.0.1+2
```

### 創建 App Store 應用程式

1. 前往 [App Store Connect](https://appstoreconnect.apple.com/)
2. 創建新應用程式
3. 填寫應用程式信息
4. 上傳應用程式圖標和截圖

### 提交審核

```bash
# 構建生產版本
flutter build ios --release --build-name=1.0.1 --build-number=2

# 上傳到 App Store
# （通過 Xcode 或 GitHub Actions）
```

## 8. 故障排除

### 常見問題

#### 1. "No provisioning profile found"

```bash
# 檢查 Bundle ID 是否匹配
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/

# 確保 Provisioning Profile 包含正確的 Bundle ID
```

#### 2. "Code signing error"

```bash
# 檢查證書有效性
security find-identity -v -p codesigning

# 檢查 Team ID
grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/
```

#### 3. "Firebase configuration missing"

```bash
# 確保 GoogleService-Info.plist 存在
ls -la ios/Runner/GoogleService-Info.plist

# 檢查 Bundle ID 匹配
grep -A1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist
```

### Debug 命令

```bash
# 檢查 iOS 構建設置
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showBuildSettings

# 檢查可用的證書
security find-identity -v -p codesigning

# 檢查 Provisioning Profiles
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/
```

## 9. 最佳實踐

### 版本管理

- 使用語義化版本 (Semantic Versioning)
- 為每個發布創建 Git 標籤
- 保持 CHANGELOG.md 更新

### 測試策略

- 在多個 iOS 版本上測試
- 使用真實設備測試關鍵功能
- 設置自動化 UI 測試

### 發布流程

1. 開發 → `dev` 分支
2. 測試 → `beta` 分支（觸發 Beta 發布）
3. 生產 → `main` 分支（觸發 App Store 發布）

## 10. 資源連結

- [Flutter iOS 開發指南](https://docs.flutter.dev/development/platform-integration/ios)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Firebase iOS 設置](https://firebase.google.com/docs/ios/setup)
- [App Store Connect 指南](https://developer.apple.com/app-store-connect/)

---

🎯 **下一步行動項目：**

1. ✅ 設置 Apple Developer 帳戶
2. ✅ 創建必要的證書和 Provisioning Profiles
3. ✅ 配置 GitHub Secrets
4. ✅ 測試自動構建流程
5. ✅ 準備 App Store 發布

**需要幫助？** 請查看故障排除部分或聯繫開發團隊。 