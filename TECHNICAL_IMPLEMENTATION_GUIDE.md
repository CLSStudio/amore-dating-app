# 🔧 Amore 三大交友模式技術實施指南

## 🚀 立即修復清單

基於當前應用程式運行日誌，我們需要優先修復以下關鍵問題：

### 1. Hero Widget 標籤衝突修復
```dart
// 使用現有的 UIBugFixes.uniqueHero 方法
Hero(
  tag: 'profile_${user.id}', // 改為唯一標籤
  child: ProfileImage(user: user),
)
```

### 2. RenderFlex 溢出修復 (39 pixels)
```dart
// 使用 Expanded 或 Flexible 包裝
Row(
  children: [
    Expanded(child: widget1),
    Expanded(child: widget2),
  ],
)
```

### 3. 圖片 URI 錯誤修復
```dart
// 檢查並修復無效的圖片 URI
String validateImageUrl(String url) {
  if (url.startsWith('file:///')) {
    return 'assets/images/placeholder.jpg'; // 使用佔位圖
  }
  return url;
}
```

### 4. Gemini AI API 配置修復
```dart
// 確保 API 密鑰正確配置
class GeminiService {
  static const String apiKey = 'YOUR_GEMINI_API_KEY';
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
}
```

## 🏗️ 核心架構實施

### 策略模式基礎架構

```dart
// lib/core/dating_modes/dating_mode_strategy.dart
abstract class DatingModeStrategy {
  DatingMode get mode;
  ThemeData get themeData;
  
  Future<List<User>> getMatchingUsers(String userId);
  double calculateCompatibility(User user1, User user2);
  Widget buildProfileCard(User user);
  Widget buildExploreView();
}

// 三個具體實現
class SeriousDatingStrategy extends DatingModeStrategy {
  @override
  DatingMode get mode => DatingMode.serious;
  
  @override
  double calculateCompatibility(User user1, User user2) {
    // 價值觀匹配 + MBTI 相容性 + 生活目標對齊
    return 0.85; // 示例分數
  }
}

class CasualSocialStrategy extends DatingModeStrategy {
  @override
  DatingMode get mode => DatingMode.casual;
  
  @override
  double calculateCompatibility(User user1, User user2) {
    // 興趣重疊 + 活動偏好 + 社交風格
    return 0.75; // 示例分數
  }
}

class LocationExplorerStrategy extends DatingModeStrategy {
  @override
  DatingMode get mode => DatingMode.explorer;
  
  @override
  double calculateCompatibility(User user1, User user2) {
    // 地理距離 + 時間可用性 + 即時活動匹配
    return 0.90; // 示例分數
  }
}
```

### 模式管理器
```dart
// lib/core/dating_modes/mode_manager.dart
class DatingModeManager extends ChangeNotifier {
  static final DatingModeManager _instance = DatingModeManager._internal();
  factory DatingModeManager() => _instance;
  
  DatingMode _currentMode = DatingMode.serious;
  DatingModeStrategy get currentStrategy => _strategies[_currentMode]!;
  
  final Map<DatingMode, DatingModeStrategy> _strategies = {
    DatingMode.serious: SeriousDatingStrategy(),
    DatingMode.casual: CasualSocialStrategy(),
    DatingMode.explorer: LocationExplorerStrategy(),
  };
  
  Future<void> switchMode(DatingMode newMode) async {
    if (_currentMode == newMode) return;
    
    // 切換邏輯
    _currentMode = newMode;
    await _updateTheme();
    await _updateUserPool();
    notifyListeners();
  }
}
```

## 📊 資料庫架構

### Firestore 集合設計
```yaml
# 用戶主集合
users/{userId}:
  profile: {}
  currentMode: "serious|casual|explorer"
  modeHistory: []

# 模式專屬用戶池
serious_dating_pool/{userId}:
  active: true
  profileData:
    occupation: string
    education: string
    relationshipGoals: string
    coreValues: array
    mbtiType: string

casual_social_pool/{userId}:
  active: true
  profileData:
    hobbies: array
    musicGenres: array
    socialActivities: array
    currentMood: string

location_explorer_pool/{userId}:
  active: true
  currentLocation: geopoint
  availableUntil: timestamp
  currentActivity: string
```

## 🎨 UI 主題系統

### 三大模式主題配置
```dart
// lib/core/themes/mode_themes.dart
class ModeThemes {
  static final Map<DatingMode, ThemeData> themes = {
    DatingMode.serious: ThemeData(
      primaryColor: Color(0xFF1565C0), // 深藍色
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF1565C0),
      ),
      fontFamily: 'NotoSerif',
    ),
    
    DatingMode.casual: ThemeData(
      primaryColor: Color(0xFFFF7043), // 活潑橘色
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFFF7043),
      ),
      fontFamily: 'Roboto',
    ),
    
    DatingMode.explorer: ThemeData(
      primaryColor: Color(0xFF2E7D32), // 探險綠色
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF2E7D32),
      ),
      fontFamily: 'Inter',
    ),
  };
}
```

### 動態主題切換
```dart
// lib/providers/theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = ModeThemes.themes[DatingMode.serious]!;
  
  ThemeData get currentTheme => _currentTheme;
  
  void updateTheme(DatingMode mode) {
    _currentTheme = ModeThemes.themes[mode]!;
    notifyListeners();
  }
}
```

## 🔄 配對演算法實施

### 認真交往配對邏輯
```dart
class SeriousMatchingService {
  static double calculateCompatibility(User user1, User user2) {
    final profile1 = user1.seriousProfile;
    final profile2 = user2.seriousProfile;
    
    if (profile1 == null || profile2 == null) return 0.0;
    
    // 價值觀對齊 (35%)
    double valueScore = _calculateValueAlignment(profile1, profile2);
    
    // MBTI 相容性 (25%)
    double mbtiScore = _calculateMBTICompatibility(profile1, profile2);
    
    // 生活目標匹配 (25%)
    double goalScore = _calculateGoalAlignment(profile1, profile2);
    
    // 教育/職業匹配 (15%)
    double backgroundScore = _calculateBackgroundMatch(profile1, profile2);
    
    return (valueScore * 0.35 + mbtiScore * 0.25 + 
            goalScore * 0.25 + backgroundScore * 0.15);
  }
  
  static double _calculateValueAlignment(SeriousProfile p1, SeriousProfile p2) {
    final values1 = Set<String>.from(p1.coreValues);
    final values2 = Set<String>.from(p2.coreValues);
    
    final intersection = values1.intersection(values2).length;
    final union = values1.union(values2).length;
    
    return union > 0 ? intersection / union : 0.0;
  }
  
  static double _calculateMBTICompatibility(SeriousProfile p1, SeriousProfile p2) {
    // MBTI 相容性對照表
    final compatibilityMap = {
      'ENFJ': ['INFP', 'ISFP', 'ENFJ', 'INFJ'],
      'INFP': ['ENFJ', 'ENTJ', 'INFJ', 'ENFP'],
      // ... 其他 MBTI 類型
    };
    
    final compatible = compatibilityMap[p1.mbtiType]?.contains(p2.mbtiType) ?? false;
    return compatible ? 0.8 : 0.4;
  }
}
```

### 輕鬆交友配對邏輯
```dart
class CasualMatchingService {
  static double calculateCompatibility(User user1, User user2) {
    final profile1 = user1.casualProfile;
    final profile2 = user2.casualProfile;
    
    if (profile1 == null || profile2 == null) return 0.0;
    
    // 興趣重疊 (40%)
    double interestScore = _calculateInterestOverlap(profile1, profile2);
    
    // 活動偏好匹配 (30%)
    double activityScore = _calculateActivityMatch(profile1, profile2);
    
    // 社交風格相似 (20%)
    double socialScore = _calculateSocialStyleMatch(profile1, profile2);
    
    // 時間可用性 (10%)
    double timeScore = _calculateTimeCompatibility(profile1, profile2);
    
    return (interestScore * 0.40 + activityScore * 0.30 + 
            socialScore * 0.20 + timeScore * 0.10);
  }
}
```

### 探索世界配對邏輯
```dart
class LocationMatchingService {
  static double calculateCompatibility(User user1, User user2) {
    final profile1 = user1.explorerProfile;
    final profile2 = user2.explorerProfile;
    
    if (profile1 == null || profile2 == null) return 0.0;
    
    // 地理距離 (50%)
    double distanceScore = _calculateProximityScore(profile1, profile2);
    
    // 時間同步性 (30%)
    double timeScore = _calculateTimeAlignment(profile1, profile2);
    
    // 活動匹配 (20%)
    double activityScore = _calculateActivityMatch(profile1, profile2);
    
    return (distanceScore * 0.50 + timeScore * 0.30 + activityScore * 0.20);
  }
  
  static double _calculateProximityScore(ExplorerProfile p1, ExplorerProfile p2) {
    final distance = GeolocatorService.distanceBetween(
      p1.currentLocation.latitude, p1.currentLocation.longitude,
      p2.currentLocation.latitude, p2.currentLocation.longitude,
    );
    
    // 距離轉分數：1km內=1.0, 5km=0.5, 10km+=0.1
    if (distance <= 1000) return 1.0;
    if (distance <= 5000) return 1.0 - (distance - 1000) / 4000 * 0.5;
    if (distance <= 10000) return 0.5 - (distance - 5000) / 5000 * 0.4;
    return 0.1;
  }
}
```

## 📱 UI 組件實施

### 模式切換器組件
```dart
// lib/widgets/mode_switcher.dart
class ModeSwitcher extends StatefulWidget {
  final DatingMode currentMode;
  final Function(DatingMode) onModeChanged;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: DatingMode.values.map((mode) {
          return _buildModeButton(mode);
        }).toList(),
      ),
    );
  }
  
  Widget _buildModeButton(DatingMode mode) {
    final isSelected = widget.currentMode == mode;
    final config = DatingModeService.modeConfigs[mode]!;
    
    return GestureDetector(
      onTap: () => widget.onModeChanged(mode),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? config.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          config.name,
          style: TextStyle(
            color: isSelected ? Colors.white : config.primaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
```

### 模式專屬檔案卡片
```dart
// lib/widgets/profile_cards/mode_profile_card.dart
class ModeProfileCard extends StatelessWidget {
  final User user;
  final DatingMode mode;
  
  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case DatingMode.serious:
        return _buildSeriousCard(user);
      case DatingMode.casual:
        return _buildCasualCard(user);
      case DatingMode.explorer:
        return _buildExplorerCard(user);
    }
  }
  
  Widget _buildSeriousCard(User user) {
    return Card(
      child: Column(
        children: [
          _buildHeader(user),
          _buildValueTags(user.seriousProfile?.coreValues ?? []),
          _buildRelationshipGoals(user.seriousProfile?.relationshipGoals),
          _buildCareerInfo(user.seriousProfile),
        ],
      ),
    );
  }
  
  Widget _buildCasualCard(User user) {
    return Card(
      child: Column(
        children: [
          _buildHeader(user),
          _buildInterestTags(user.casualProfile?.hobbies ?? []),
          _buildActivityPreferences(user.casualProfile?.socialActivities),
          _buildCurrentMood(user.casualProfile?.currentMood),
        ],
      ),
    );
  }
  
  Widget _buildExplorerCard(User user) {
    return Card(
      child: Column(
        children: [
          _buildMinimalHeader(user),
          _buildCurrentActivity(user.explorerProfile?.currentActivity),
          _buildLocationInfo(user.explorerProfile?.currentLocation),
          _buildAvailabilityStatus(user.explorerProfile),
        ],
      ),
    );
  }
}
```

## 🧪 測試策略

### 單元測試
```dart
// test/unit/dating_modes_test.dart
void main() {
  group('DatingModeStrategy Tests', () {
    test('SeriousDatingStrategy calculates compatibility correctly', () {
      // Arrange
      final strategy = SeriousDatingStrategy();
      final user1 = createTestUser(seriousProfile: SeriousProfile(
        coreValues: ['honesty', 'family'],
        mbtiType: 'ENFJ',
      ));
      final user2 = createTestUser(seriousProfile: SeriousProfile(
        coreValues: ['honesty', 'career'],
        mbtiType: 'INFP',
      ));
      
      // Act
      final score = strategy.calculateCompatibility(user1, user2);
      
      // Assert
      expect(score, greaterThan(0.5));
    });
  });
}
```

### 整合測試
```dart
// test/integration/mode_switching_test.dart
void main() {
  testWidgets('Mode switching updates theme and UI', (tester) async {
    // Arrange
    await tester.pumpWidget(MyApp());
    
    // Act
    await tester.tap(find.text('輕鬆交友'));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.byType(CasualTheme), findsOneWidget);
  });
}
```

## 📊 效能監控

### 關鍵指標追蹤
```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  static void trackModeSwitch(DatingMode from, DatingMode to, String reason) {
    FirebaseAnalytics.instance.logEvent(
      name: 'mode_switch',
      parameters: {
        'from_mode': from.toString(),
        'to_mode': to.toString(),
        'reason': reason,
      },
    );
  }
  
  static void trackCompatibilityCalculation(DatingMode mode, double score) {
    FirebaseAnalytics.instance.logEvent(
      name: 'compatibility_calculated',
      parameters: {
        'mode': mode.toString(),
        'score': score,
      },
    );
  }
}
```

## 🚀 部署檢查清單

### 發布前驗證
- [ ] 所有 Hero 標籤衝突已修復
- [ ] UI 佈局溢出問題已解決
- [ ] 圖片 URI 錯誤已修復
- [ ] Gemini AI API 正常運作
- [ ] 三大模式主題正確切換
- [ ] 配對演算法測試通過
- [ ] 用戶池隔離功能正常
- [ ] 效能指標在合理範圍

### 漸進式發布計劃
```yaml
第1週: 10%用戶 - 內測組
第2週: 25%用戶 - 早期採用者
第3週: 50%用戶 - 主流用戶
第4週: 100%用戶 - 全面發布
```

---

**技術負責人**: [姓名]  
**審核日期**: 2024年12月  
**版本**: v1.0 