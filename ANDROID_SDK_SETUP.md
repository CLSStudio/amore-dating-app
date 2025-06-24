# 🛠️ Android SDK 設置指南

## 📋 **當前問題**
根據 `flutter doctor` 的輸出，我們需要解決以下問題：
- ❌ cmdline-tools 組件缺失
- ❌ Android 許可證未接受

## 🔧 **解決方案**

### **步驟 1：在 Android Studio 中安裝 SDK 工具**

1. **打開 Android Studio**
2. **進入 SDK Manager**：
   - 點擊 `File` > `Settings` (Windows) 或 `Android Studio` > `Preferences` (Mac)
   - 選擇 `Appearance & Behavior` > `System Settings` > `Android SDK`

3. **安裝必要的 SDK 工具**：
   - 切換到 `SDK Tools` 標籤
   - 確保以下項目已勾選並安裝：
     - ✅ **Android SDK Build-Tools**
     - ✅ **Android SDK Command-line Tools (latest)**
     - ✅ **Android SDK Platform-Tools**
     - ✅ **Android Emulator**
     - ✅ **Intel x86 Emulator Accelerator (HAXM installer)**

4. **點擊 "Apply" 並等待下載完成**

### **步驟 2：設置環境變數**

#### **Windows 設置**：
1. **打開系統環境變數**：
   - 按 `Win + R`，輸入 `sysdm.cpl`
   - 點擊 "環境變數"

2. **添加 ANDROID_HOME**：
   - 在 "系統變數" 中點擊 "新增"
   - 變數名稱：`ANDROID_HOME`
   - 變數值：`C:\Users\[你的用戶名]\AppData\Local\Android\Sdk`

3. **更新 PATH**：
   - 找到 PATH 變數，點擊 "編輯"
   - 添加以下路徑：
     ```
     %ANDROID_HOME%\platform-tools
     %ANDROID_HOME%\cmdline-tools\latest\bin
     %ANDROID_HOME%\emulator
     ```

### **步驟 3：驗證安裝**

重新啟動命令提示字元，然後運行：

```bash
# 檢查 Flutter 狀態
flutter doctor

# 接受 Android 許可證
flutter doctor --android-licenses
```

### **步驟 4：創建 Android 模擬器**

1. **在 Android Studio 中**：
   - 點擊 `Tools` > `AVD Manager`
   - 點擊 "Create Virtual Device"

2. **選擇設備**：
   - 推薦：**Pixel 7 Pro**
   - 點擊 "Next"

3. **選擇系統映像**：
   - 選擇 **API 34 (Android 14.0)**
   - 如果未下載，點擊 "Download" 下載
   - 點擊 "Next"

4. **配置 AVD**：
   - AVD 名稱：`Amore_Test_Device`
   - 啟動方向：Portrait
   - 點擊 "Finish"

### **步驟 5：測試模擬器**

```bash
# 列出可用的模擬器
flutter emulators

# 啟動模擬器
flutter emulators --launch Amore_Test_Device

# 或者在 Android Studio 中點擊播放按鈕啟動
```

## 🎯 **預期結果**

完成後，`flutter doctor` 應該顯示：

```
[√] Flutter (Channel stable, 3.32.0, on Microsoft Windows [版本 10.0.26100.3775], locale zh-TW)
[√] Windows Version (11 家用版 64-bit, 24H2, 2009)
[√] Android toolchain - develop for Android devices (Android SDK version 35.0.1)
[√] Chrome - develop for the web
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.14.2)
[√] Android Studio (version 2024.3.2)
[√] Connected device (3 available)
[√] Network resources
```

## 🚨 **常見問題**

### **問題 1：HAXM 安裝失敗**
**解決方案**：
1. 在 BIOS 中啟用虛擬化技術
2. 關閉 Hyper-V（如果啟用）
3. 手動下載並安裝 HAXM

### **問題 2：模擬器啟動緩慢**
**解決方案**：
1. 增加 AVD 的 RAM 分配（建議 4GB）
2. 啟用硬體加速
3. 關閉不必要的背景程式

### **問題 3：許可證接受失敗**
**解決方案**：
```bash
# 手動接受所有許可證
cd %ANDROID_HOME%\cmdline-tools\latest\bin
sdkmanager --licenses
```

## 📱 **下一步：測試 Flutter 應用**

完成 SDK 設置後，我們將：
1. 啟動 Android 模擬器
2. 運行 Amore 應用的 UI 測試
3. 驗證所有組件正常工作 