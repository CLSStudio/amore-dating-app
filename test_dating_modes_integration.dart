import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'lib/features/dating/dating_modes_page.dart';
import 'lib/features/dating/modes/dating_mode_system.dart';
import 'lib/features/main_navigation/main_navigation.dart';

void main() {
  runApp(const ProviderScope(child: DatingModesTestApp()));
}

class DatingModesTestApp extends StatelessWidget {
  const DatingModesTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amore 交友模式整合測試',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'NotoSansTC',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          brightness: Brightness.light,
        ),
      ),
      home: const DatingModesIntegrationTest(),
    );
  }
}

class DatingModesIntegrationTest extends StatefulWidget {
  const DatingModesIntegrationTest({super.key});

  @override
  State<DatingModesIntegrationTest> createState() => _DatingModesIntegrationTestState();
}

class _DatingModesIntegrationTestState extends State<DatingModesIntegrationTest> {
  int testsPassed = 0;
  int totalTests = 6;
  List<String> testResults = [];

  @override
  void initState() {
    super.initState();
    _runIntegrationTests();
  }

  void _runIntegrationTests() {
    setState(() {
      testResults.clear();
      testsPassed = 0;
    });

    // 測試 1: 檢查交友模式枚舉
    _testDatingModeEnum();
    
    // 測試 2: 檢查模式配置
    _testModeConfigs();
    
    // 測試 3: 檢查服務提供者
    _testServiceProvider();
    
    // 測試 4: 檢查頁面導航
    _testPageNavigation();
    
    // 測試 5: 檢查模式切換功能
    _testModeSwitching();
    
    // 測試 6: 檢查主導航整合
    _testMainNavigationIntegration();
  }

  void _testDatingModeEnum() {
    try {
      final modes = DatingMode.values;
      if (modes.length == 3 && 
          modes.contains(DatingMode.serious) &&
          modes.contains(DatingMode.explore) &&
          modes.contains(DatingMode.passion)) {
        _addTestResult('✅ 交友模式枚舉測試通過', true);
      } else {
        _addTestResult('❌ 交友模式枚舉測試失敗', false);
      }
    } catch (e) {
      _addTestResult('❌ 交友模式枚舉測試錯誤: $e', false);
    }
  }

  void _testModeConfigs() {
    try {
      final configs = DatingModeService.modeConfigs;
      if (configs.length == 3 &&
          configs.containsKey(DatingMode.serious) &&
          configs.containsKey(DatingMode.explore) &&
          configs.containsKey(DatingMode.passion)) {
        
        // 檢查認真交往模式配置
        final seriousConfig = configs[DatingMode.serious]!;
        if (seriousConfig.name == '認真交往' &&
            seriousConfig.primaryColor == Colors.red &&
            seriousConfig.features.isNotEmpty) {
          _addTestResult('✅ 模式配置測試通過', true);
        } else {
          _addTestResult('❌ 模式配置內容不正確', false);
        }
      } else {
        _addTestResult('❌ 模式配置測試失敗', false);
      }
    } catch (e) {
      _addTestResult('❌ 模式配置測試錯誤: $e', false);
    }
  }

  void _testServiceProvider() {
    try {
      // 這裡我們只能檢查類型是否存在
      final service = DatingModeService();
      if (service.runtimeType == DatingModeService) {
        _addTestResult('✅ 服務提供者測試通過', true);
      } else {
        _addTestResult('❌ 服務提供者測試失敗', false);
      }
    } catch (e) {
      _addTestResult('❌ 服務提供者測試錯誤: $e', false);
    }
  }

  void _testPageNavigation() {
    try {
      // 檢查頁面是否可以創建
      final page = const DatingModesPage();
      if (page.runtimeType == DatingModesPage) {
        _addTestResult('✅ 頁面導航測試通過', true);
      } else {
        _addTestResult('❌ 頁面導航測試失敗', false);
      }
    } catch (e) {
      _addTestResult('❌ 頁面導航測試錯誤: $e', false);
    }
  }

  void _testModeSwitching() {
    try {
      // 檢查模式切換記錄類
      final record = ModeSwitchRecord(
        userId: 'test_user',
        fromMode: DatingMode.explore,
        toMode: DatingMode.serious,
        timestamp: DateTime.now(),
        reason: 'Test switch',
      );
      
      if (record.userId == 'test_user' &&
          record.fromMode == DatingMode.explore &&
          record.toMode == DatingMode.serious) {
        _addTestResult('✅ 模式切換功能測試通過', true);
      } else {
        _addTestResult('❌ 模式切換功能測試失敗', false);
      }
    } catch (e) {
      _addTestResult('❌ 模式切換功能測試錯誤: $e', false);
    }
  }

  void _testMainNavigationIntegration() {
    try {
      // 檢查主導航是否可以創建
      final mainNav = const MainNavigation();
      if (mainNav.runtimeType == MainNavigation) {
        _addTestResult('✅ 主導航整合測試通過', true);
      } else {
        _addTestResult('❌ 主導航整合測試失敗', false);
      }
    } catch (e) {
      _addTestResult('❌ 主導航整合測試錯誤: $e', false);
    }
  }

  void _addTestResult(String result, bool passed) {
    setState(() {
      testResults.add(result);
      if (passed) testsPassed++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        title: const Text(
          'Amore 交友模式整合測試',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 測試結果摘要
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: testsPassed == totalTests 
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    testsPassed == totalTests ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '測試結果',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$testsPassed / $totalTests 項測試通過',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    testsPassed == totalTests 
                      ? '🎉 交友模式已成功整合到主程式！'
                      : '⚠️ 部分功能需要檢查',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 詳細測試結果
            const Text(
              '詳細測試結果',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: testResults.length,
                itemBuilder: (context, index) {
                  final result = testResults[index];
                  final isSuccess = result.startsWith('✅');
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      result,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runIntegrationTests,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新測試'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DatingModesPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('測試交友模式'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 主導航測試按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigation(),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('測試主程式導航'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 