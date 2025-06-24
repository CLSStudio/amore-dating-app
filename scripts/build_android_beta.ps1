# Amore Android Beta 構建腳本 (簡化版本)
# 用法: .\scripts\build_android_beta.ps1 ["release_notes"]

param(
    [string]$ReleaseNotes = "Amore Beta release - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$ErrorActionPreference = "Stop"

$BuildNumber = [int](Get-Date -UFormat %s)
$BuildName = "1.0.$BuildNumber"

Write-Host "🚀 開始 Amore Android Beta 構建..." -ForegroundColor Green
Write-Host "版本: $BuildName" -ForegroundColor Cyan
Write-Host "構建號: $BuildNumber" -ForegroundColor Cyan
Write-Host "發布說明: $ReleaseNotes" -ForegroundColor Cyan

# 檢查 Firebase CLI
try {
    firebase --version | Out-Null
} catch {
    Write-Host "❌ Firebase CLI 未安裝。請執行: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

# 檢查 Flutter
try {
    flutter --version | Out-Null
} catch {
    Write-Host "❌ Flutter 未安裝。請安裝 Flutter SDK" -ForegroundColor Red
    exit 1
}

# 清理之前的構建
Write-Host "🧹 清理之前的構建..." -ForegroundColor Yellow
flutter clean
flutter pub get

# 運行測試
Write-Host "🧪 運行測試..." -ForegroundColor Yellow
flutter test

# 構建 Android APK
Write-Host "🤖 構建 Android APK..." -ForegroundColor Blue
flutter build apk --release --build-name=$BuildName --build-number=$BuildNumber

# 檢查 APK 是否成功構建
$ApkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $ApkPath) {
    Write-Host "✅ Android APK 構建成功！" -ForegroundColor Green
    Write-Host "APK 位置: $ApkPath" -ForegroundColor Cyan
    
    # 顯示 APK 信息
    $ApkSize = (Get-Item $ApkPath).Length / 1MB
    Write-Host "APK 大小: $([math]::Round($ApkSize, 2)) MB" -ForegroundColor Cyan
    
    Write-Host "📤 分發 Android APK 到 Firebase App Distribution..." -ForegroundColor Blue
    
    # 使用 Firebase CLI 分發
    try {
        firebase appdistribution:distribute $ApkPath --app "1:380903609347:android:b24c6150c55e1fb260aa36" --release-notes $ReleaseNotes
        
        Write-Host "✅ Android APK 已成功分發到 Firebase App Distribution！" -ForegroundColor Green
        Write-Host "📱 測試人員將收到通知，可以下載和安裝 Beta 版本" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Firebase App Distribution 分發失敗，但 APK 已成功構建" -ForegroundColor Yellow
        Write-Host "您可以手動上傳 APK 到 Firebase Console" -ForegroundColor Yellow
        Write-Host "🔗 Firebase Console: https://console.firebase.google.com/project/amore-hk/appdistribution" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ APK 構建失敗" -ForegroundColor Red
    exit 1
}

Write-Host "🎉 Android Beta 構建流程完成！" -ForegroundColor Green 