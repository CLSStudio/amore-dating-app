#!/bin/bash

# Amore Beta 版本構建和分發腳本
# 用法: ./scripts/build_and_distribute.sh [android|ios|both] [release_notes]

set -e

PLATFORM=${1:-both}
RELEASE_NOTES=${2:-"Beta release - 手動構建 $(date '+%Y-%m-%d %H:%M')"}
BUILD_NUMBER=$(date +%s)
BUILD_NAME="1.0.$BUILD_NUMBER"

echo "🚀 開始 Amore Beta 版本構建..."
echo "平台: $PLATFORM"
echo "版本: $BUILD_NAME"
echo "構建號: $BUILD_NUMBER"
echo "發布說明: $RELEASE_NOTES"

# 檢查 Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI 未安裝。請執行: npm install -g firebase-tools"
    exit 1
fi

# 檢查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安裝。請安裝 Flutter SDK"
    exit 1
fi

# 清理之前的構建
echo "🧹 清理之前的構建..."
flutter clean
flutter pub get

# 運行測試
echo "🧪 運行測試..."
flutter test

# 構建 Android
if [[ $PLATFORM == "android" || $PLATFORM == "both" ]]; then
    echo "🤖 構建 Android APK..."
    flutter build apk --release --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
    
    echo "📤 分發 Android APK 到 Firebase App Distribution..."
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
        --app $(firebase apps:list | grep android | awk '{print $4}') \
        --groups "beta-testers" \
        --release-notes "$RELEASE_NOTES"
    
    echo "✅ Android APK 已成功分發！"
fi

# 構建 iOS
if [[ $PLATFORM == "ios" || $PLATFORM == "both" ]]; then
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "⚠️  iOS 構建僅支援 macOS"
    else
        echo "🍎 構建 iOS IPA..."
        flutter build ios --release --build-name=$BUILD_NAME --build-number=$BUILD_NUMBER
        
        # 注意：需要手動配置代碼簽名
        echo "⚠️  iOS 構建完成，但需要手動配置代碼簽名才能分發"
        echo "請在 Xcode 中打開項目並配置開發團隊和配置文件"
    fi
fi

echo "🎉 構建和分發完成！"
echo "📱 測試人員將收到通知，可以下載和安裝 Beta 版本" 