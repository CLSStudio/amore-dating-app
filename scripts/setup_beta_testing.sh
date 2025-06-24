#!/bin/bash

# Amore Beta 測試設置腳本
# 此腳本將幫助設置 Firebase App Distribution 和測試人員群組

set -e

echo "🔧 設置 Amore Beta 測試環境..."

# 檢查 Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI 未安裝。請執行: npm install -g firebase-tools"
    exit 1
fi

# 登入 Firebase
echo "🔐 登入 Firebase..."
firebase login

# 初始化 Firebase App Distribution
echo "📱 初始化 Firebase App Distribution..."

# 創建測試人員群組
echo "👥 創建測試人員群組..."

echo "創建內部測試人員群組..."
firebase appdistribution:group:create \
    --group-alias "internal-testers" \
    --display-name "內部測試人員" \
    --file scripts/internal_testers.txt || echo "群組可能已存在"

echo "創建 Beta 測試人員群組..."
firebase appdistribution:group:create \
    --group-alias "beta-testers" \
    --display-name "Beta 測試人員" \
    --file scripts/beta_testers.txt || echo "群組可能已存在"

# 顯示應用程式列表
echo "📋 Firebase 應用程式列表:"
firebase apps:list

echo "✅ Beta 測試環境設置完成！"
echo ""
echo "接下來的步驟："
echo "1. 在 scripts/internal_testers.txt 中添加內部測試人員的電子郵件"
echo "2. 在 scripts/beta_testers.txt 中添加 Beta 測試人員的電子郵件"
echo "3. 運行 ./scripts/build_and_distribute.sh 來構建和分發第一個 Beta 版本"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/"
echo "📱 App Distribution: https://console.firebase.google.com/project/$(firebase use --current)/appdistribution" 