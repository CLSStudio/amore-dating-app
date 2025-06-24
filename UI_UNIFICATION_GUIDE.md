# 🎨 Amore UI 統一指南

## 📋 概述

本指南說明 Amore 應用的統一設計系統，確保所有功能頁面都有一致的視覺風格和用戶體驗。

## 🏗️ 設計系統架構

### 1. **核心設計系統** (`lib/core/theme/app_design_system.dart`)

#### 🎨 顏色系統 (AppColors)
```dart
// 主色調
AppColors.primary        // #E91E63 (粉紅色)
AppColors.secondary      // #9C27B0 (紫色)

// 文字顏色
AppColors.textPrimary    // #2D3748 (深灰)
AppColors.textSecondary  // #718096 (中灰)
AppColors.textTertiary   // #A0AEC0 (淺灰)

// 狀態顏色
AppColors.success        // #48BB78 (綠色)
AppColors.warning        // #ED8936 (橙色)
AppColors.error          // #F56565 (紅色)
AppColors.info           // #4299E1 (藍色)

// 功能色彩
AppColors.like           // 綠色 (喜歡)
AppColors.superLike      // 藍色 (超級喜歡)
AppColors.nope           // 紅色 (不喜歡)
AppColors.boost          // 橙色 (Boost)
```

#### 📝 字體系統 (AppTextStyles)
```dart
// 標題
AppTextStyles.h1         // 32px, Bold
AppTextStyles.h2         // 28px, Bold
AppTextStyles.h3         // 24px, Bold
AppTextStyles.h4         // 20px, SemiBold
AppTextStyles.h5         // 18px, SemiBold
AppTextStyles.h6         // 16px, SemiBold

// 正文
AppTextStyles.bodyLarge  // 16px, Normal
AppTextStyles.bodyMedium // 14px, Normal
AppTextStyles.bodySmall  // 12px, Normal

// 按鈕
AppTextStyles.buttonLarge   // 16px, SemiBold
AppTextStyles.buttonMedium  // 14px, SemiBold
AppTextStyles.buttonSmall   // 12px, SemiBold
```

#### 📏 間距系統 (AppSpacing)
```dart
AppSpacing.xs    // 4px
AppSpacing.sm    // 8px
AppSpacing.md    // 16px
AppSpacing.lg    // 24px
AppSpacing.xl    // 32px
AppSpacing.xxl   // 48px

// 預設邊距
AppSpacing.pagePadding      // 16px 全方向
AppSpacing.cardPadding      // 24px 全方向
AppSpacing.listItemPadding  // 16px 水平, 8px 垂直
```

#### 🔄 圓角系統 (AppBorderRadius)
```dart
AppBorderRadius.xs    // 4px
AppBorderRadius.sm    // 8px
AppBorderRadius.md    // 12px
AppBorderRadius.lg    // 16px
AppBorderRadius.xl    // 20px

// 預設圓角
AppBorderRadius.small       // 8px
AppBorderRadius.medium      // 12px
AppBorderRadius.large       // 16px
AppBorderRadius.extraLarge  // 20px
```

#### 🌟 陰影系統 (AppShadows)
```dart
AppShadows.small     // 輕微陰影
AppShadows.medium    // 中等陰影
AppShadows.large     // 較大陰影
AppShadows.card      // 卡片陰影
AppShadows.floating  // 浮動陰影 (帶主色調)
```

### 2. **統一組件庫** (`lib/shared/widgets/app_components.dart`)

#### 🔘 按鈕組件 (AppButton)
```dart
AppButton(
  text: '按鈕文字',
  onPressed: () {},
  type: AppButtonType.primary,    // primary, secondary, success, warning, error, outline, ghost
  size: AppButtonSize.medium,     // small, medium, large
  icon: Icons.favorite,           // 可選圖標
  isLoading: false,               // 載入狀態
  isFullWidth: false,             // 全寬度
)
```

#### 🃏 卡片組件 (AppCard)
```dart
AppCard(
  child: Widget,
  padding: AppSpacing.cardPadding,
  margin: AppSpacing.cardMargin,
  onTap: () {},                   // 可選點擊事件
  hasShadow: true,                // 是否有陰影
  backgroundColor: AppColors.surface,
)
```

#### 📝 輸入框組件 (AppTextField)
```dart
AppTextField(
  label: '標籤',
  hint: '提示文字',
  controller: controller,
  prefixIcon: Icons.email,
  suffixIcon: Icons.visibility,
  obscureText: false,
  keyboardType: TextInputType.email,
)
```

#### 👤 頭像組件 (AppAvatar)
```dart
AppAvatar(
  imageUrl: 'https://...',
  name: '用戶名',
  size: 50,
  onTap: () {},
)
```

#### 🏷️ 標籤組件 (AppChip)
```dart
AppChip(
  label: '標籤文字',
  isSelected: false,
  onTap: () {},
  backgroundColor: AppColors.primary,
  textColor: AppColors.textOnPrimary,
)
```

#### 📄 頁面標題組件 (AppPageHeader)
```dart
AppPageHeader(
  title: '頁面標題',
  subtitle: '副標題',
  showBackButton: true,
  actions: [IconButton(...)],
)
```

#### 📭 空狀態組件 (AppEmptyState)
```dart
AppEmptyState(
  icon: Icons.inbox,
  title: '沒有內容',
  subtitle: '這裡還沒有任何內容',
  actionText: '重新載入',
  onAction: () {},
)
```

## 🎯 使用指南

### 1. **導入設計系統**
```dart
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
```

### 2. **應用主題**
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  home: YourPage(),
)
```

### 3. **使用統一組件**
```dart
class YourPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppPageHeader(
            title: '頁面標題',
            subtitle: '頁面描述',
          ),
          Expanded(
            child: Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          '標題',
                          style: AppTextStyles.h4,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          '內容',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: '操作按鈕',
                    onPressed: () {},
                    type: AppButtonType.primary,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🎨 設計原則

### 1. **一致性**
- 所有頁面使用相同的顏色、字體、間距
- 統一的組件行為和交互方式
- 一致的視覺層次和信息架構

### 2. **可訪問性**
- 足夠的顏色對比度
- 適當的字體大小和行高
- 清晰的視覺焦點和狀態反饋

### 3. **響應式設計**
- 適配不同屏幕尺寸
- 靈活的佈局和間距
- 觸摸友好的交互區域

### 4. **性能優化**
- 輕量級的組件設計
- 高效的渲染和動畫
- 合理的內存使用

## 📱 頁面模板

### 1. **標準頁面模板**
```dart
class StandardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppPageHeader(
            title: '頁面標題',
            subtitle: '頁面描述',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 頁面內容
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. **列表頁面模板**
```dart
class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppPageHeader(title: '列表頁面'),
          Expanded(
            child: ListView.builder(
              padding: AppSpacing.pagePadding,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    // 列表項內容
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. **表單頁面模板**
```dart
class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppPageHeader(title: '表單頁面'),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                children: [
                  AppTextField(
                    label: '輸入框',
                    hint: '請輸入...',
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: '提交',
                    onPressed: () {},
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔄 遷移指南

### 從舊設計遷移到新設計系統：

1. **替換硬編碼顏色**
   ```dart
   // 舊的
   Color(0xFFE91E63)
   
   // 新的
   AppColors.primary
   ```

2. **使用統一字體樣式**
   ```dart
   // 舊的
   TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
   
   // 新的
   AppTextStyles.h4
   ```

3. **統一間距**
   ```dart
   // 舊的
   EdgeInsets.all(16)
   
   // 新的
   AppSpacing.pagePadding
   ```

4. **使用統一組件**
   ```dart
   // 舊的
   ElevatedButton(...)
   
   // 新的
   AppButton(...)
   ```

## 🎯 最佳實踐

1. **始終使用設計系統中的值**
2. **優先使用統一組件**
3. **保持一致的視覺層次**
4. **遵循無障礙設計原則**
5. **定期檢查和更新設計一致性**

## 📊 檢查清單

- [ ] 使用 AppColors 而非硬編碼顏色
- [ ] 使用 AppTextStyles 而非自定義字體樣式
- [ ] 使用 AppSpacing 而非硬編碼間距
- [ ] 使用統一組件 (AppButton, AppCard 等)
- [ ] 頁面使用 AppPageHeader
- [ ] 空狀態使用 AppEmptyState
- [ ] 載入狀態使用 AppLoadingIndicator
- [ ] 遵循響應式設計原則
- [ ] 確保無障礙性

---

**讓設計更統一，讓體驗更一致** 🎨✨ 