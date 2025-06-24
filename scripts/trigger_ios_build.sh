#!/bin/bash

# Amore iOS 自動構建觸發腳本
# 此腳本可在任何平台上運行，用於觸發 GitHub Actions iOS 構建

set -e

echo "🚀 觸發 Amore iOS Beta 構建..."

# 檢查是否安裝了 git
if ! command -v git &> /dev/null; then
    echo "❌ 錯誤：Git 未安裝"
    exit 1
fi

# 檢查是否在 git 倉庫中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 錯誤：不在 Git 倉庫中"
    exit 1
fi

# 檢查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  警告：有未提交的更改"
    echo "請先提交所有更改："
    git status --porcelain
    
    read -p "是否要繼續？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 1
    fi
fi

# 獲取當前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 當前分支：$CURRENT_BRANCH"

# 檢查遠程倉庫
REMOTE_URL=$(git config --get remote.origin.url)
echo "🔗 遠程倉庫：$REMOTE_URL"

# 選項1：推送到 beta 分支觸發自動構建
echo ""
echo "🎯 選擇構建觸發方式："
echo "1. 推送到 beta 分支（自動觸發）"
echo "2. 使用 GitHub CLI 手動觸發"
echo "3. 創建新的 release 標籤"
echo "4. 顯示構建說明"

read -p "請選擇 (1-4): " -n 1 -r
echo

case $REPLY in
    1)
        echo "📤 推送到 beta 分支..."
        
        # 檢查是否已在 beta 分支
        if [ "$CURRENT_BRANCH" = "beta" ]; then
            echo "✅ 已在 beta 分支"
        else
            echo "🔄 切換到 beta 分支..."
            git checkout -b beta 2>/dev/null || git checkout beta
            git merge $CURRENT_BRANCH --no-edit
        fi
        
        # 推送到遠程
        echo "⬆️  推送到遠程倉庫..."
        git push origin beta
        
        echo "🎉 已觸發 iOS 自動構建！"
        echo "📊 查看構建狀態："
        echo "   GitHub Actions: ${REMOTE_URL%.git}/actions"
        ;;
        
    2)
        echo "🔧 使用 GitHub CLI 觸發構建..."
        
        if ! command -v gh &> /dev/null; then
            echo "❌ 錯誤：GitHub CLI 未安裝"
            echo "💡 安裝方法："
            echo "   macOS: brew install gh"
            echo "   Windows: winget install GitHub.cli"
            echo "   或訪問：https://cli.github.com/"
            exit 1
        fi
        
        # 檢查是否已登入
        if ! gh auth status &> /dev/null; then
            echo "🔐 需要登入 GitHub CLI..."
            gh auth login
        fi
        
        # 手動觸發工作流程
        echo "▶️  觸發工作流程..."
        gh workflow run beta_release.yml
        
        echo "🎉 已觸發 iOS 構建！"
        echo "📊 查看構建狀態："
        gh workflow view beta_release.yml --web
        ;;
        
    3)
        echo "🏷️  創建 release 標籤..."
        
        # 獲取當前版本
        if [ -f "pubspec.yaml" ]; then
            CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
            echo "📋 當前版本：$CURRENT_VERSION"
        fi
        
        read -p "輸入新版本號 (例如 1.0.1): " NEW_VERSION
        
        if [ -z "$NEW_VERSION" ]; then
            echo "❌ 版本號不能為空"
            exit 1
        fi
        
        # 創建標籤
        TAG_NAME="v$NEW_VERSION-beta"
        read -p "輸入發布說明: " RELEASE_NOTES
        
        echo "🏷️  創建標籤：$TAG_NAME"
        git tag -a "$TAG_NAME" -m "$RELEASE_NOTES"
        git push origin "$TAG_NAME"
        
        echo "🎉 已創建標籤！"
        echo "💡 手動觸發構建或等待自動觸發"
        ;;
        
    4)
        echo "📋 iOS 構建說明："
        echo ""
        echo "🤖 自動觸發條件："
        echo "   - 推送到 beta 分支"
        echo "   - 推送到 main 分支"
        echo "   - 創建新的 release"
        echo ""
        echo "🔧 手動觸發方法："
        echo "   1. GitHub Web 界面："
        echo "      前往 Actions → beta_release.yml → Run workflow"
        echo ""
        echo "   2. GitHub CLI："
        echo "      gh workflow run beta_release.yml"
        echo ""
        echo "   3. API 呼叫："
        echo "      curl -X POST \\"
        echo "        -H \"Accept: application/vnd.github.v3+json\" \\"
        echo "        -H \"Authorization: token YOUR_TOKEN\" \\"
        echo "        https://api.github.com/repos/OWNER/REPO/actions/workflows/beta_release.yml/dispatches \\"
        echo "        -d '{\"ref\":\"main\"}'"
        echo ""
        echo "📊 構建狀態查看："
        echo "   ${REMOTE_URL%.git}/actions"
        echo ""
        echo "🔥 Firebase App Distribution："
        echo "   https://console.firebase.google.com/project/amore-hk/appdistribution"
        ;;
        
    *)
        echo "❌ 無效選擇"
        exit 1
        ;;
esac

echo ""
echo "📱 iOS 構建信息："
echo "   Bundle ID: hk.amore.dating"
echo "   Firebase App ID: 1:380903609347:ios:532f9ba1ffd4f54f60aa36"
echo "   最低 iOS 版本: 12.0"
echo ""
echo "✨ iOS 構建觸發完成！" 