@echo off
echo 🚀 啟動 Amore Android 測試環境...
echo.

echo 📱 檢查 Android 模擬器狀態...
flutter devices

echo.
echo 🔄 等待模擬器啟動...
timeout /t 10 /nobreak

echo.
echo 📱 再次檢查設備狀態...
flutter devices

echo.
echo 🎨 運行 Amore UI 測試應用...
flutter run test_enhanced_ui_simple.dart

pause 