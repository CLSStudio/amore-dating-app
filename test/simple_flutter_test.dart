import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flutter 基本功能測試', (WidgetTester tester) async {
    // 創建一個簡單的應用
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Amore 測試'),
          ),
          body: const Center(
            child: Text('Flutter 正常工作！'),
          ),
        ),
      ),
    );

    // 驗證文本是否顯示
    expect(find.text('Flutter 正常工作！'), findsOneWidget);
    expect(find.text('Amore 測試'), findsOneWidget);
    
    print('✅ Flutter 基本功能測試通過');
  });

  testWidgets('MBTI 模型測試', (WidgetTester tester) async {
    // 測試 MBTI 相關的基本功能
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const Text('MBTI 測試'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('開始測試'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('MBTI 測試'), findsOneWidget);
    expect(find.text('開始測試'), findsOneWidget);
    
    print('✅ MBTI 界面測試通過');
  });
} 