# 🚀 Amore iOS Beta 測試觸發腳本
# 
# 用途：快速觸發 iOS 自動構建和分發
# 作者：Amore Development Team
# 日期：2024年12月28日

Write-Host "🍎 Amore iOS Beta 測試觸發器" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# 檢查 Git 狀態
Write-Host "📊 檢查 Git 狀態..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  警告：有未提交的更改" -ForegroundColor Red
    Write-Host $gitStatus
    $continue = Read-Host "是否繼續？(y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# 檢查遠程倉庫連接
Write-Host "🔗 檢查 GitHub 連接..." -ForegroundColor Yellow
try {
    git remote get-url origin | Out-Null
    Write-Host "✅ GitHub 倉庫連接正常" -ForegroundColor Green
} catch {
    Write-Host "❌ 無法連接到 GitHub 倉庫" -ForegroundColor Red
    exit 1
}

# 獲取當前版本
$currentTag = git describe --tags --abbrev=0 2>$null
if (!$currentTag) {
    $currentTag = "v0.0.0"
}

Write-Host "📋 當前版本：$currentTag" -ForegroundColor Cyan

# 生成新版本號
$versionParts = $currentTag -replace "v", "" -split "\."
$major = [int]$versionParts[0]
$minor = [int]$versionParts[1]
$patch = [int]$versionParts[2] + 1

$newVersion = "v$major.$minor.$patch-beta"
Write-Host "🎯 新版本號：$newVersion" -ForegroundColor Cyan

# 確認觸發構建
Write-Host ""
Write-Host "🚀 準備觸發 iOS Beta 構建" -ForegroundColor Yellow
Write-Host "   • Bundle ID: hk.amore.dating" -ForegroundColor Gray
Write-Host "   • 構建類型: iOS App Store 分發" -ForegroundColor Gray
Write-Host "   • Firebase 分發: Beta 測試" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "確認觸發構建？(y/n)"
if ($confirm -ne "y") {
    Write-Host "❌ 構建已取消" -ForegroundColor Red
    exit
}

# 創建並推送標籤
Write-Host ""
Write-Host "🏷️  創建版本標籤..." -ForegroundColor Yellow
try {
    git tag $newVersion
    Write-Host "✅ 標籤 $newVersion 創建成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 標籤創建失敗" -ForegroundColor Red
    exit 1
}

Write-Host "📤 推送到 GitHub..." -ForegroundColor Yellow
try {
    git push origin $newVersion
    Write-Host "✅ 標籤推送成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 推送失敗" -ForegroundColor Red
    git tag -d $newVersion
    exit 1
}

# 顯示構建信息
Write-Host ""
Write-Host "🎉 iOS Beta 構建已觸發！" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""
Write-Host "📱 構建信息："
Write-Host "   • 版本：$newVersion"
Write-Host "   • 應用名稱：Amore Dating"
Write-Host "   • Bundle ID：hk.amore.dating"
Write-Host ""
Write-Host "🔍 查看構建進度："
Write-Host "   GitHub Actions: https://github.com/CLSStudio/amore-dating-app/actions" -ForegroundColor Blue
Write-Host ""
Write-Host "📧 Beta 測試分發："
Write-Host "   Firebase App Distribution 將自動發送邀請" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ 預計構建時間：15-20 分鐘" -ForegroundColor Yellow
Write-Host ""

# 等待並檢查構建狀態（可選）
$monitor = Read-Host "是否監控構建狀態？(y/n)"
if ($monitor -eq "y") {
    Write-Host ""
    Write-Host "🔄 監控構建狀態..." -ForegroundColor Yellow
    Write-Host "💡 提示：您可以隨時按 Ctrl+C 停止監控" -ForegroundColor Gray
    Write-Host ""
    
    # 打開瀏覽器到 Actions 頁面
    Start-Process "https://github.com/CLSStudio/amore-dating-app/actions"
    
    # 簡單的狀態檢查循環
    $attempts = 0
    $maxAttempts = 60  # 30 分鐘
    
    while ($attempts -lt $maxAttempts) {
        Start-Sleep 30
        $attempts++
        
        Write-Host "[$attempts/60] 檢查構建狀態..." -ForegroundColor Gray
        
        # 這裡可以添加 GitHub API 調用來檢查狀態
        # 但需要 GitHub token
    }
}

Write-Host ""
Write-Host "✨ 腳本執行完成！" -ForegroundColor Green
Write-Host "📱 請檢查您的 GitHub Actions 頁面查看構建進度。" -ForegroundColor Cyan 