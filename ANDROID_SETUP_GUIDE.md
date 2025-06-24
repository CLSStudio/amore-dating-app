# 🚀 Android Studio 完整安裝設置指南

## 📥 **第一步：下載 Android Studio**

### **系統需求**
- **作業系統**: Windows 8.1/10/11 (64-bit)
- **記憶體**: 最少 8GB RAM (建議 16GB)
- **硬碟空間**: 最少 4GB (建議 8GB)
- **螢幕解析度**: 1280 x 800 最小

### **下載連結**
- **官方網站**: https://developer.android.com/studio
- **版本**: Android Studio Meerkat Feature Drop | 2024.3.2.14
- **檔案大小**: 1.3 GB

## 🛠️ **第二步：安裝 Android Studio**

### **安裝步驟**
1. **執行安裝檔案**
   ```
   android-studio-2024.3.2.14-windows.exe
   ```

2. **安裝選項**
   - ✅ Android Studio
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Performance (Intel ® HAXM)
   - ✅ Android Virtual Device

3. **安裝位置**
   - 預設: `C:\Program Files\Android\Android Studio`
   - SDK 位置: `C:\Users\[用戶名]\AppData\Local\Android\Sdk`

## 🔧 **第三步：首次設置精靈**

### **設置選項**
1. **Import Settings**: 選擇 "Do not import settings"
2. **Setup Type**: 選擇 "Standard"
3. **Select UI Theme**: 
   - Light (淺色主題)
   - Darcula (深色主題)
4. **Verify Settings**: 確認設置並點擊 "Finish"

### **SDK 下載**
系統會自動下載以下組件：
- Android SDK Build-Tools
- Android SDK Platform-Tools
- Android SDK Tools
- Intel x86 Emulator Accelerator (HAXM installer)

## 📱 **第四步：創建 Android 模擬器**

### **AVD Manager 設置**
1. **開啟 AVD Manager**
   ```
   Tools > AVD Manager
   ```

2. **創建新的虛擬設備**
   - 點擊 "Create Virtual Device"
   - 選擇設備類型: **Pixel 7 Pro** (推薦)
   - 選擇系統映像: **API 34 (Android 14)**
   - 設定名稱: "Amore_Test_Device"

3. **進階設置**
   ```
   RAM: 4096 MB
   VM Heap: 512 MB
   Internal Storage: 6144 MB
   SD Card: 1024 MB
   ```

### **推薦的測試設備配置**

#### **手機測試**
- **Pixel 7 Pro** (API 34) - 主要測試設備
- **Pixel 4** (API 30) - 兼容性測試
- **Nexus 5X** (API 28) - 舊版本測試

#### **平板測試**
- **Pixel Tablet** (API 34) - 平板界面測試

## 🚀 **第五步：驗證安裝**

### **檢查 Flutter 與 Android Studio 整合**
```bash
flutter doctor
```

預期輸出應該顯示：
```
[√] Android toolchain - develop for Android devices
[√] Android Studio (version 2024.3.2)
```

### **測試模擬器**
1. 啟動創建的 AVD
2. 等待模擬器完全載入
3. 確認可以正常操作

## 🔧 **第六步：配置 Flutter 專案**

### **在 Android Studio 中開啟 Amore 專案**
1. **File > Open**
2. 選擇 `C:\Users\user\Desktop\Amore`
3. 等待專案索引完成

### **配置運行設置**
1. **選擇目標設備**: 在頂部工具列選擇創建的模擬器
2. **選擇運行配置**: main.dart
3. **點擊運行按鈕** (綠色三角形)

## 📱 **第七步：測試 Amore 應用**

### **首次運行**
```bash
flutter run
```

### **熱重載測試**
- 修改代碼後按 `r` 進行熱重載
- 按 `R` 進行熱重啟
- 按 `q` 退出

## 🛠️ **常見問題解決**

### **HAXM 安裝失敗**
```bash
# 在 BIOS 中啟用虛擬化技術
# Intel: Intel VT-x
# AMD: AMD-V
```

### **模擬器啟動緩慢**
1. 確保已啟用硬體加速
2. 增加 AVD 的 RAM 分配
3. 關閉不必要的背景程式

### **Gradle 同步失敗**
```bash
# 清理專案
flutter clean
flutter pub get
```

## 🎯 **下一步：開始 UI 開發**

安裝完成後，我們將開始：
1. **MBTI 測試界面優化**
2. **滑動配對界面完善**
3. **個人檔案設置流程改進**

## 📞 **技術支援**

如果遇到任何問題：
1. 檢查 `flutter doctor` 輸出
2. 查看 Android Studio 的 Event Log
3. 確認所有必要的 SDK 組件已安裝

---

**重要提醒**: 首次安裝可能需要 30-60 分鐘，包括下載所有必要的組件。請確保網路連接穩定。 