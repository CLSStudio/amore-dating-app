# Amore Beta 版本構建和分發腳本 (PowerShell 版本)
# 用法: .\scripts\build_and_distribute.ps1 [android|ios|both] ["release_notes"]

param(
    [string]$Platform = "android",
    [string]$ReleaseNotes = "Beta release - 手動構建 $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$ErrorActionPreference = "Stop"

$BuildNumber = [int](Get-Date -UFormat %s)
$BuildName = "1.0.$BuildNumber"

Write-Host "🚀 開始 Amore Beta 版本構建..." -ForegroundColor Green
Write-Host "平台: $Platform" -ForegroundColor Cyan
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

# 構建 Android
if ($Platform -eq "android" -or $Platform -eq "both") {
    Write-Host "🤖 構建 Android APK..." -ForegroundColor Blue
    flutter build apk --release --build-name=$BuildName --build-number=$BuildNumber
    
    Write-Host "📤 分發 Android APK 到 Firebase App Distribution..." -ForegroundColor Blue
    
    # 獲取 Android App ID
    $FirebaseApps = firebase apps:list --json | ConvertFrom-Json
    $AndroidApp = $FirebaseApps | Where-Object { $_.platform -eq "ANDROID" } | Select-Object -First 1
    
    if ($AndroidApp) {
        firebase appdistribution:distribute "build\app\outputs\flutter-apk\app-release.apk" `
            --app $AndroidApp.appId `
            --groups "beta-testers" `
            --release-notes $ReleaseNotes
        
        Write-Host "✅ Android APK 已成功分發！" -ForegroundColor Green
    } else {
        Write-Host "❌ 找不到 Android 應用程式 ID" -ForegroundColor Red
    }
}

# 構建 iOS
if ($Platform -eq "ios" -or $Platform -eq "both") {
    Write-Host "⚠️  iOS 構建需要 macOS 環境和 Xcode" -ForegroundColor Yellow
    Write-Host "請在 macOS 系統上使用 bash 腳本版本" -ForegroundColor Yellow
}

Write-Host "🎉 構建和分發完成！" -ForegroundColor Green
Write-Host "📱 測試人員將收到通知，可以下載和安裝 Beta 版本" -ForegroundColor Green 