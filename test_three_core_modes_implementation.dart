import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/core/dating_modes/dating_mode_strategy.dart';
import 'lib/core/dating_modes/mode_manager.dart';
import 'lib/core/dating_modes/theme_manager.dart';
import 'lib/features/dating/modes/dating_mode_system.dart';
import 'lib/core/models/user_model.dart';

/// 🎯 Amore 三大核心交友模式實施測試
/// 驗證策略模式架構、模式管理器和主題系統的完整實現
void main() {
  runApp(
    ProviderScope(
      child: ThreeCoreModesTestApp(),
    ),
  );
}

class ThreeCoreModesTestApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    
    return MaterialApp(
      title: 'Amore 三大核心模式測試',
      theme: currentTheme,
      home: const ModeTestHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ModeTestHomePage extends ConsumerStatefulWidget {
  const ModeTestHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ModeTestHomePage> createState() => _ModeTestHomePageState();
}

class _ModeTestHomePageState extends ConsumerState<ModeTestHomePage> {
  final ThemeManager _themeManager = ThemeManager();
  List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  /// 🧪 運行所有測試
  Future<void> _runTests() async {
    print('🎯 開始 Amore 三大核心交友模式測試...\n');
    
    await _testModeStrategies();
    await _testModeManager();
    await _testThemeManager();
    await _testModeConfiguration();
    await _testUserPoolSystem();
    
    print('\n✅ 所有測試完成！');
    setState(() {});
  }

  /// 🎯 測試交友模式策略
  Future<void> _testModeStrategies() async {
    print('📋 測試 1: 交友模式策略架構');
    
    try {
      // 測試三個策略實例
      final seriousStrategy = SeriousDatingStrategy();
      final exploreStrategy = ExploreStrategy();
      final passionStrategy = PassionStrategy();
      
      _addTestResult('✅ 策略實例創建成功');
      
      // 測試策略模式對應
      assert(seriousStrategy.mode == DatingMode.serious);
      assert(exploreStrategy.mode == DatingMode.explore);
      assert(passionStrategy.mode == DatingMode.passion);
      
      _addTestResult('✅ 策略模式映射正確');
      
      // 測試配置獲取
      final seriousConfig = seriousStrategy.config;
      final exploreConfig = exploreStrategy.config;
      final passionConfig = passionStrategy.config;
      
      assert(seriousConfig.name == '認真交往');
      assert(exploreConfig.name == '探索模式');
      assert(passionConfig.name == '激情模式');
      
      _addTestResult('✅ 模式配置獲取正確');
      
      // 測試主題生成
      final seriousTheme = seriousStrategy.getModeTheme();
      final exploreTheme = exploreStrategy.getModeTheme();
      final passionTheme = passionStrategy.getModeTheme();
      
      assert(seriousTheme.colorScheme.primary == const Color(0xFF1565C0));
      assert(exploreTheme.colorScheme.primary == Colors.orange);
      assert(passionTheme.colorScheme.primary == Colors.red);
      
      _addTestResult('✅ 模式主題生成正確');
      
      print('   ✅ 策略架構測試通過\n');
      
    } catch (e) {
      _addTestResult('❌ 策略測試失敗: $e');
      print('   ❌ 策略架構測試失敗: $e\n');
    }
  }

  /// 🎛️ 測試模式管理器
  Future<void> _testModeManager() async {
    print('📋 測試 2: 模式管理器');
    
    try {
      final modeManager = DatingModeManager();
      
      // 測試初始狀態
      assert(modeManager.currentMode != null);
      _addTestResult('✅ 模式管理器初始化成功');
      
      // 測試當前策略獲取
      final currentStrategy = modeManager.currentStrategy;
      assert(currentStrategy != null);
      _addTestResult('✅ 當前策略獲取正確');
      
      // 測試當前配置
      final currentConfig = modeManager.currentConfig;
      assert(currentConfig != null);
      _addTestResult('✅ 當前配置獲取正確');
      
      // 測試當前主題
      final currentTheme = modeManager.currentTheme;
      assert(currentTheme != null);
      _addTestResult('✅ 當前主題獲取正確');
      
      print('   ✅ 模式管理器測試通過\n');
      
    } catch (e) {
      _addTestResult('❌ 模式管理器測試失敗: $e');
      print('   ❌ 模式管理器測試失敗: $e\n');
    }
  }

  /// 🎨 測試主題管理器
  Future<void> _testThemeManager() async {
    print('📋 測試 3: 主題管理器');
    
    try {
      // 測試三種模式主題
      final seriousTheme = _themeManager.getThemeForMode(DatingMode.serious);
      final exploreTheme = _themeManager.getThemeForMode(DatingMode.explore);
      final passionTheme = _themeManager.getThemeForMode(DatingMode.passion);
      
      // 驗證主題不為空
      assert(seriousTheme != null);
      assert(exploreTheme != null);
      assert(passionTheme != null);
      
      _addTestResult('✅ 三種模式主題創建成功');
      
      // 驗證主題差異化
      assert(seriousTheme.colorScheme.primary != exploreTheme.colorScheme.primary);
      assert(exploreTheme.colorScheme.primary != passionTheme.colorScheme.primary);
      assert(seriousTheme.brightness != passionTheme.brightness);
      
      _addTestResult('✅ 主題差異化驗證成功');
      
      print('   ✅ 主題管理器測試通過\n');
      
    } catch (e) {
      _addTestResult('❌ 主題管理器測試失敗: $e');
      print('   ❌ 主題管理器測試失敗: $e\n');
    }
  }

  /// ⚙️ 測試模式配置
  Future<void> _testModeConfiguration() async {
    print('📋 測試 4: 模式配置');
    
    try {
      final modeConfigs = DatingModeService.modeConfigs;
      
      // 驗證配置完整性
      assert(modeConfigs.containsKey(DatingMode.serious));
      assert(modeConfigs.containsKey(DatingMode.explore));
      assert(modeConfigs.containsKey(DatingMode.passion));
      
      _addTestResult('✅ 模式配置映射完整');
      
      // 驗證配置內容
      final seriousConfig = modeConfigs[DatingMode.serious]!;
      assert(seriousConfig.features.isNotEmpty);
      assert(seriousConfig.uniqueFeatures.isNotEmpty);
      assert(seriousConfig.restrictions.isNotEmpty);
      
      _addTestResult('✅ 認真交往模式配置完整');
      
      final exploreConfig = modeConfigs[DatingMode.explore]!;
      assert(exploreConfig.features.isNotEmpty);
      assert(exploreConfig.uniqueFeatures.isNotEmpty);
      
      _addTestResult('✅ 探索模式配置完整');
      
      final passionConfig = modeConfigs[DatingMode.passion]!;
      assert(passionConfig.features.isNotEmpty);
      assert(passionConfig.restrictions.isNotEmpty);
      
      _addTestResult('✅ 激情模式配置完整');
      
      print('   ✅ 模式配置測試通過\n');
      
    } catch (e) {
      _addTestResult('❌ 模式配置測試失敗: $e');
      print('   ❌ 模式配置測試失敗: $e\n');
    }
  }

  /// 🏊‍♀️ 測試用戶池系統
  Future<void> _testUserPoolSystem() async {
    print('📋 測試 5: 用戶池系統');
    
    try {
      // 創建測試用戶
      final testUser = UserModel(
        uid: 'test_user_001',
        name: '測試用戶',
        email: 'test@amore.com',
        age: 28,
        gender: 'female',
        location: 'Hong Kong',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      
      _addTestResult('✅ 測試用戶創建成功');
      
      // 測試用戶是否可以加入不同模式
      final seriousStrategy = SeriousDatingStrategy();
      final exploreStrategy = ExploreStrategy();
      final passionStrategy = PassionStrategy();
      
      final canJoinSerious = await seriousStrategy.canUserJoinMode(testUser);
      final canJoinExplore = await exploreStrategy.canUserJoinMode(testUser);
      final canJoinPassion = await passionStrategy.canUserJoinMode(testUser);
      
      print('   📊 用戶池准入測試:');
      print('      認真交往: ${canJoinSerious ? "✅" : "❌"}');
      print('      探索模式: ${canJoinExplore ? "✅" : "❌"}');
      print('      激情模式: ${canJoinPassion ? "✅" : "❌"}');
      
      _addTestResult('✅ 用戶池准入規則測試完成');
      
      print('   ✅ 用戶池系統測試通過\n');
      
    } catch (e) {
      _addTestResult('❌ 用戶池系統測試失敗: $e');
      print('   ❌ 用戶池系統測試失敗: $e\n');
    }
  }

  /// 添加測試結果
  void _addTestResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(currentModeProvider);
    final modeManager = ref.watch(datingModeManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amore 三大核心模式測試'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 當前模式顯示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                Text(
                  '當前模式: ${modeManager.currentConfig.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  modeManager.currentConfig.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // 模式切換按鈕
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton(context, DatingMode.serious, '認真交往'),
                _buildModeButton(context, DatingMode.explore, '探索模式'),
                _buildModeButton(context, DatingMode.passion, '激情模式'),
              ],
            ),
          ),
          
          const Divider(),
          
          // 測試結果
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                final isSuccess = result.startsWith('✅');
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      result,
                      style: TextStyle(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _testResults.clear();
          });
          _runTests();
        },
        child: const Icon(Icons.refresh),
        tooltip: '重新運行測試',
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, DatingMode mode, String label) {
    final modeManager = ref.watch(datingModeManagerProvider);
    final isActive = modeManager.currentMode == mode;
    
    return ElevatedButton(
      onPressed: isActive ? null : () async {
        final success = await modeManager.switchMode(mode, reason: '測試模式切換');
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已切換至 $label 模式')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('模式切換失敗')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive 
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isActive 
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }
}

/// 🎯 模式功能展示頁面
class ModeFeaturesPage extends ConsumerWidget {
  final DatingMode mode;
  
  const ModeFeaturesPage({Key? key, required this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategy = ref.watch(datingModeManagerProvider).currentStrategy;
    final config = strategy.config;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${config.name} 功能'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 模式描述
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '模式描述',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(config.detailedDescription),
                ],
              ),
            ),
          ),
          
          // 核心功能
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '核心功能',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  ...config.features.map((feature) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(feature)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 獨特功能
          if (config.uniqueFeatures.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '獨特功能',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    ...config.uniqueFeatures.map((feature) => 
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(feature)),
                          ],
                        ),
                      ),
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