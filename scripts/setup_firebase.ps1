# Firebase 設置腳本
# 此腳本將幫助您設置 Firebase 項目

Write-Host "🔥 Amore Firebase 設置腳本" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 檢查 Flutter 是否已安裝
Write-Host "📋 檢查 Flutter 安裝..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter 已安裝" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter 未安裝或未在 PATH 中" -ForegroundColor Red
    Write-Host "請先安裝 Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Red
    exit 1
}

# 檢查 Firebase CLI 是否已安裝
Write-Host "📋 檢查 Firebase CLI..." -ForegroundColor Yellow
try {
    $firebaseVersion = firebase --version
    Write-Host "✅ Firebase CLI 已安裝" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI 未安裝" -ForegroundColor Red
    Write-Host "正在安裝 Firebase CLI..." -ForegroundColor Yellow
    npm install -g firebase-tools
}

# 檢查 FlutterFire CLI 是否已安裝
Write-Host "📋 檢查 FlutterFire CLI..." -ForegroundColor Yellow
try {
    $flutterfireVersion = flutterfire --version
    Write-Host "✅ FlutterFire CLI 已安裝" -ForegroundColor Green
} catch {
    Write-Host "❌ FlutterFire CLI 未安裝" -ForegroundColor Red
    Write-Host "正在安裝 FlutterFire CLI..." -ForegroundColor Yellow
    dart pub global activate flutterfire_cli
}

Write-Host ""
Write-Host "🚀 開始 Firebase 設置..." -ForegroundColor Cyan

# 登入 Firebase
Write-Host "📝 登入 Firebase..." -ForegroundColor Yellow
firebase login

# 創建或選擇 Firebase 項目
Write-Host ""
Write-Host "📋 Firebase 項目設置" -ForegroundColor Yellow
Write-Host "請選擇一個選項:" -ForegroundColor White
Write-Host "1. 創建新的 Firebase 項目" -ForegroundColor White
Write-Host "2. 使用現有的 Firebase 項目" -ForegroundColor White

$choice = Read-Host "請輸入選項 (1 或 2)"

if ($choice -eq "1") {
    Write-Host "正在創建新的 Firebase 項目..." -ForegroundColor Yellow
    $projectId = Read-Host "請輸入項目 ID (建議: amore-hk)"
    firebase projects:create $projectId --display-name "Amore Dating App"
} else {
    Write-Host "請選擇現有的 Firebase 項目..." -ForegroundColor Yellow
    firebase projects:list
    $projectId = Read-Host "請輸入項目 ID"
}

# 設置 Firebase 項目
Write-Host "正在設置 Firebase 項目..." -ForegroundColor Yellow
firebase use $projectId

# 初始化 Firebase 服務
Write-Host "正在初始化 Firebase 服務..." -ForegroundColor Yellow

# Authentication
Write-Host "設置 Authentication..." -ForegroundColor Yellow
firebase auth:enable

# Firestore
Write-Host "設置 Firestore..." -ForegroundColor Yellow
firebase firestore:databases:create --location=asia-east1

# Storage
Write-Host "設置 Storage..." -ForegroundColor Yellow
firebase storage:buckets:create gs://$projectId-storage --location=asia-east1

# Functions
Write-Host "設置 Functions..." -ForegroundColor Yellow
firebase functions:config:set runtime=nodejs18

# 配置 FlutterFire
Write-Host ""
Write-Host "🔧 配置 FlutterFire..." -ForegroundColor Cyan
Set-Location "amore"
flutterfire configure --project=$projectId

# 返回根目錄
Set-Location ".."

Write-Host ""
Write-Host "✅ Firebase 設置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📋 下一步操作:" -ForegroundColor Yellow
Write-Host "1. 在 Firebase Console 中啟用 Authentication 提供商" -ForegroundColor White
Write-Host "2. 設置 Firestore 安全規則" -ForegroundColor White
Write-Host "3. 設置 Storage 安全規則" -ForegroundColor White
Write-Host "4. 配置 Google Sign-In 和 Facebook Login" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Firebase Console: https://console.firebase.google.com/project/$projectId" -ForegroundColor Cyan 