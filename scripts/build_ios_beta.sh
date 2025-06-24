#!/bin/bash

# Amore iOS Beta 構建腳本
# 此腳本需要在 macOS 環境中運行

set -e  # 遇到錯誤時退出

echo "🍎 開始 Amore iOS Beta 構建流程..."

# 檢查是否在 macOS 上運行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 錯誤：此腳本只能在 macOS 上運行"
    echo "💡 建議：使用 GitHub Actions 進行 iOS 構建"
    exit 1
fi

# 檢查必要工具
echo "🔍 檢查構建環境..."

if ! command -v flutter &> /dev/null; then
    echo "❌ 錯誤：Flutter 未安裝或不在 PATH 中"
    exit 1
fi

if ! command -v xcodebuild &> /dev/null; then
    echo "❌ 錯誤：Xcode 未安裝"
    exit 1
fi

if ! command -v pod &> /dev/null; then
    echo "❌ 錯誤：CocoaPods 未安裝"
    echo "💡 請運行：sudo gem install cocoapods"
    exit 1
fi

# 檢查 iOS 模擬器
echo "📱 檢查 iOS 模擬器..."
if ! xcrun simctl list devices | grep -q "iOS"; then
    echo "⚠️  警告：未檢測到 iOS 模擬器"
fi

# 清理之前的構建
echo "🧹 清理之前的構建..."
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf build/

# 獲取 Flutter 依賴
echo "📦 獲取 Flutter 依賴..."
flutter pub get

# 檢查 Flutter 分析
echo "🔍 運行 Flutter 分析..."
flutter analyze --no-fatal-infos

# 運行測試
echo "🧪 運行測試..."
flutter test

# 安裝 CocoaPods 依賴
echo "🍫 安裝 CocoaPods 依賴..."
cd ios
pod install --repo-update
cd ..

# 檢查 iOS 專案配置
echo "⚙️  檢查 iOS 專案配置..."
if [ ! -f "ios/GoogleService-Info.plist" ]; then
    echo "❌ 錯誤：ios/GoogleService-Info.plist 不存在"
    echo "💡 請確保已添加 Firebase iOS 配置文件"
    exit 1
fi

# 檢查簽名配置
echo "✍️  檢查代碼簽名配置..."
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -showBuildSettings | grep -E "(CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER)"

# 構建 iOS (Debug)
echo "🔨 構建 iOS Debug 版本..."
flutter build ios --debug

# 檢查是否可以構建發布版本（如果有簽名）
echo "🚀 嘗試構建 iOS Release 版本..."
if flutter build ios --release; then
    echo "✅ iOS Release 構建成功"
    
    # 嘗試創建 archive（如果配置了簽名）
    echo "📦 嘗試創建 Xcode Archive..."
    cd ios
    
    # 創建輸出目錄
    mkdir -p ../build-output
    
    if xcodebuild -workspace Runner.xcworkspace \
        -scheme Runner \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath ../build-output/app.xcarchive \
        clean archive; then
        
        echo "✅ Xcode Archive 創建成功"
        
        # 嘗試導出 IPA
        if [ -f "ExportOptions.plist" ]; then
            echo "📤 導出 IPA..."
            if xcodebuild -exportArchive \
                -archivePath ../build-output/app.xcarchive \
                -exportPath ../build-output/ios \
                -exportOptionsPlist ExportOptions.plist; then
                
                echo "🎉 IPA 導出成功！"
                echo "📍 IPA 位置：build-output/ios/"
                ls -la ../build-output/ios/
                
                # 檢查是否有 Firebase CLI 來上傳
                if command -v firebase &> /dev/null; then
                    echo "🔥 檢測到 Firebase CLI"
                    echo "💡 可以使用以下命令上傳到 Firebase App Distribution："
                    echo "firebase appdistribution:distribute build-output/ios/*.ipa --app \$FIREBASE_IOS_APP_ID --groups beta-testers"
                else
                    echo "💡 安裝 Firebase CLI 來自動上傳 IPA："
                    echo "npm install -g firebase-tools"
                fi
            else
                echo "⚠️  IPA 導出失敗，但 Archive 成功"
            fi
        else
            echo "⚠️  ExportOptions.plist 不存在，跳過 IPA 導出"
        fi
    else
        echo "⚠️  Xcode Archive 失敗，可能需要配置代碼簽名"
        echo "💡 確保在 Xcode 中配置了有效的開發者帳戶和證書"
    fi
    
    cd ..
else
    echo "⚠️  iOS Release 構建失敗，可能需要配置代碼簽名"
fi

# 提供使用 GitHub Actions 的建議
echo ""
echo "🚀 GitHub Actions 自動構建建議："
echo "   推送代碼到 'beta' 分支以觸發自動構建"
echo "   或手動觸發：gh workflow run beta_release.yml"
echo ""

# 顯示構建總結
echo "📊 構建總結："
echo "   ✅ Flutter 依賴已安裝"
echo "   ✅ CocoaPods 依賴已安裝"
echo "   ✅ 測試通過"
echo "   ✅ iOS Debug 構建成功"

if [ -d "build-output/ios" ] && [ "$(ls -A build-output/ios)" ]; then
    echo "   🎉 IPA 文件已生成"
else
    echo "   ⚠️  需要配置代碼簽名來生成 IPA"
fi

echo ""
echo "🎯 下一步："
echo "   1. 配置 iOS 開發者證書和 Provisioning Profile"
echo "   2. 在 GitHub Secrets 中添加 iOS 簽名信息"
echo "   3. 使用 GitHub Actions 進行自動構建和分發"
echo ""
echo "✨ iOS 構建流程完成！" 