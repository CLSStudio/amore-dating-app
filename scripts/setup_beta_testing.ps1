# Amore Beta 測試設置腳本 (PowerShell 版本)
# 此腳本將幫助設置 Firebase App Distribution 和測試人員群組

$ErrorActionPreference = "Stop"

Write-Host "🔧 設置 Amore Beta 測試環境..." -ForegroundColor Green

# 檢查 Firebase CLI
try {
    firebase --version | Out-Null
} catch {
    Write-Host "❌ Firebase CLI 未安裝。請執行: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

# 登入 Firebase
Write-Host "🔐 登入 Firebase..." -ForegroundColor Yellow
firebase login

# 初始化 Firebase App Distribution
Write-Host "📱 初始化 Firebase App Distribution..." -ForegroundColor Yellow

# 創建測試人員群組
Write-Host "👥 創建測試人員群組..." -ForegroundColor Yellow

Write-Host "創建內部測試人員群組..." -ForegroundColor Cyan
Write-Host "注意：測試人員群組需要在 Firebase Console 中手動創建" -ForegroundColor Yellow
Write-Host "或使用較新版本的 Firebase CLI" -ForegroundColor Yellow

# 顯示應用程式列表
Write-Host "📋 Firebase 應用程式列表:" -ForegroundColor Yellow
firebase apps:list

Write-Host "✅ Beta 測試環境設置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "接下來的步驟："
Write-Host "1. 在 scripts\internal_testers.txt 中添加內部測試人員的電子郵件"
Write-Host "2. 在 scripts\beta_testers.txt 中添加 Beta 測試人員的電子郵件"
Write-Host "3. 運行 .\scripts\build_and_distribute.ps1 來構建和分發第一個 Beta 版本"
Write-Host ""
Write-Host "🔗 Firebase Console: https://console.firebase.google.com/"

# 獲取當前項目 ID
try {
    $ProjectId = firebase use | Where-Object { $_ -match "Now using project" } | ForEach-Object { ($_ -split " ")[3] }
    Write-Host "📱 App Distribution: https://console.firebase.google.com/project/$ProjectId/appdistribution"
} catch {
    Write-Host "📱 App Distribution: https://console.firebase.google.com/"
} 