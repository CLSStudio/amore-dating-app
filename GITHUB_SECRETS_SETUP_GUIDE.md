# 🔐 Amore GitHub Secrets 配置指南

## 概述
為了啟用 iOS 和 Android 自動構建，您需要在 GitHub 倉庫中配置以下 Secrets。

**倉庫地址：** [https://github.com/CLSStudio/amore-dating-app.git](https://github.com/CLSStudio/amore-dating-app.git)

## 🗂️ 如何添加 GitHub Secrets

1. 前往您的 GitHub 倉庫
2. 點擊 **Settings** 標籤
3. 在左側邊欄中點擊 **Secrets and variables** → **Actions**
4. 點擊 **New repository secret** 按鈕
5. 輸入 Secret 名稱和值
6. 點擊 **Add secret** 保存

---

## 📱 iOS 構建必需的 Secrets

### 1. BUILD_CERTIFICATE_BASE64
**用途：** iOS 分發證書（base64 編碼）

**獲取方式：**
```bash
# 在 macOS 上執行
base64 -i Certificates.p12 | pbcopy
```

**步驟：**
1. 從 Apple Developer 下載分發證書
2. 導出為 .p12 格式
3. 使用上述命令轉換為 base64
4. 將結果粘貼到 GitHub Secret

---

### 2. P12_PASSWORD
**用途：** 證書密碼

**值：** 您創建 .p12 證書時設置的密碼

---

### 3. BUILD_PROVISION_PROFILE_BASE64
**用途：** iOS Provisioning Profile（base64 編碼）

**獲取方式：**
```bash
# 在 macOS 上執行
base64 -i YourProfile.mobileprovision | pbcopy
```

**步驟：**
1. 從 Apple Developer 下載 Distribution Provisioning Profile
2. 確保 Bundle ID 為 `hk.amore.dating`
3. 使用上述命令轉換為 base64
4. 將結果粘貼到 GitHub Secret

---

### 4. IOS_TEAM_ID
**用途：** Apple Developer Team ID

**獲取方式：**
1. 登入 [Apple Developer](https://developer.apple.com)
2. 前往 **Membership** 頁面
3. 複製 **Team ID**（10字符字符串）

---

## 🤖 Android 構建必需的 Secrets

### 5. ANDROID_KEYSTORE_BASE64
**用途：** Android 簽名密鑰庫（base64 編碼）

**創建和配置：**
```bash
# 創建新的密鑰庫
keytool -genkey -v -keystore amore-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias amore-key

# 轉換為 base64
base64 -i amore-keystore.jks | pbcopy
```

---

### 6. ANDROID_KEYSTORE_PASSWORD
**用途：** 密鑰庫密碼

**值：** 創建密鑰庫時設置的密碼

---

### 7. ANDROID_KEY_ALIAS
**用途：** 密鑰別名

**值：** `amore-key`（或您設置的別名）

---

### 8. ANDROID_KEY_PASSWORD
**用途：** 密鑰密碼

**值：** 創建密鑰時設置的密碼

---

## 🔥 Firebase 相關 Secrets

### 9. FIREBASE_CLI_TOKEN
**用途：** Firebase CLI 認證令牌

**獲取方式：**
```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 登入並獲取令牌
firebase login:ci
```

**步驟：**
1. 執行上述命令
2. 在瀏覽器中完成 Google 認證
3. 複製返回的令牌
4. 將令牌粘貼到 GitHub Secret

---

## 🚀 觸發自動構建

設置完所有 Secrets 後，您可以通過以下方式觸發構建：

### 方式 1：推送標籤
```bash
git tag v1.0.0-beta
git push origin v1.0.0-beta
```

### 方式 2：推送到 main 分支
```bash
git push origin main
```

### 方式 3：手動觸發
1. 前往 GitHub 倉庫的 **Actions** 標籤
2. 選擇 **Beta Release** workflow
3. 點擊 **Run workflow** 按鈕

---

## 📋 Secrets 檢查清單

在觸發構建前，請確保以下 Secrets 已正確配置：

### iOS Secrets ✅
- [ ] `BUILD_CERTIFICATE_BASE64`
- [ ] `P12_PASSWORD`
- [ ] `BUILD_PROVISION_PROFILE_BASE64`
- [ ] `IOS_TEAM_ID`

### Android Secrets ✅
- [ ] `ANDROID_KEYSTORE_BASE64`
- [ ] `ANDROID_KEYSTORE_PASSWORD`
- [ ] `ANDROID_KEY_ALIAS`
- [ ] `ANDROID_KEY_PASSWORD`

### Firebase Secrets ✅
- [ ] `FIREBASE_CLI_TOKEN`

---

## 🔧 故障排除

### 常見問題

**1. iOS 構建失敗："Code signing error"**
- 檢查證書和 Provisioning Profile 是否匹配
- 確認 Bundle ID 為 `hk.amore.dating`
- 驗證 Team ID 正確

**2. Android 構建失敗："Keystore error"**
- 檢查密鑰庫 base64 編碼是否正確
- 確認密碼和別名匹配

**3. Firebase 部署失敗**
- 重新生成 Firebase CLI 令牌
- 確認項目權限正確

### 獲取幫助
如果遇到問題，請檢查：
1. GitHub Actions 日誌
2. Firebase 控制台
3. Apple Developer 控制台

---

## 📞 下一步

設置完成後，請執行：
```bash
git tag v1.0.0-beta
git push origin v1.0.0-beta
```

這將觸發完整的 iOS/Android Beta 構建和分發流程！

---

**創建時間：** 2024年12月28日  
**更新人員：** Amore Development Team  
**版本：** 1.0.0 