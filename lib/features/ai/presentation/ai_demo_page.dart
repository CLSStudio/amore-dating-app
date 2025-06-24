import 'package:flutter/material.dart';
import '../ai_manager.dart';
import '../services/ai_test_service.dart';

class AIDemoPage extends StatefulWidget {
  const AIDemoPage({super.key});

  @override
  State<AIDemoPage> createState() => _AIDemoPageState();
}

class _AIDemoPageState extends State<AIDemoPage> {
  bool _isLoading = false;
  String _result = '';
  Map<String, dynamic> _serviceStatus = {};

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  void _loadServiceStatus() {
    setState(() {
      _serviceStatus = AIManager.getServiceStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 功能展示'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 服務狀態卡片
            _buildServiceStatusCard(),
            
            const SizedBox(height: 20),
            
            // AI 功能測試區域
            _buildAIFunctionCard(
              title: '💕 愛情建議',
              description: '基於 MBTI 和情況的個性化愛情建議',
              onTap: _testLoveAdvice,
            ),
            
            const SizedBox(height: 16),
            
            _buildAIFunctionCard(
              title: '🧊 破冰話題',
              description: '根據共同興趣生成破冰話題',
              onTap: _testIcebreakers,
            ),
            
            const SizedBox(height: 16),
            
            _buildAIFunctionCard(
              title: '🌟 約會建議',
              description: '個性化約會活動建議',
              onTap: _testDateIdea,
            ),
            
            const SizedBox(height: 16),
            
            _buildAIFunctionCard(
              title: '📊 使用統計',
              description: '查看 AI 功能使用統計',
              onTap: _testUsageStats,
            ),
            
            const SizedBox(height: 16),
            
            _buildAIFunctionCard(
              title: '🧪 API 連接測試',
              description: '測試 Google AI API 連接狀態',
              onTap: _testAPIConnection,
            ),
            
            const SizedBox(height: 20),
            
            // 結果顯示區域
            if (_result.isNotEmpty) _buildResultCard(),
            
            const SizedBox(height: 20),
            
            // 管理功能
            _buildManagementCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusCard() {
    final isConfigured = _serviceStatus['configured'] ?? false;
    final configStatus = _serviceStatus['configurationStatus'] ?? {};
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI 服務狀態',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildStatusItem('Gemini API', configStatus['gemini'] ?? false),
            _buildStatusItem('Vision API', configStatus['vision'] ?? false),
            _buildStatusItem('Firebase 連接', true),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConfigured ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isConfigured 
                    ? '✅ AI 服務已完全配置，可以使用所有功能'
                    : '⚠️ 需要配置 API 密鑰才能使用完整功能',
                style: TextStyle(
                  color: isConfigured ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check : Icons.close,
            color: isActive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildAIFunctionCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'AI 回應結果',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _result,
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _result = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('清除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🛠️ 管理功能',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.download),
                    label: const Text('導出數據'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cleanupData,
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('清理數據'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _resetData,
                icon: const Icon(Icons.restore),
                label: const Text('重置所有 AI 數據'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testLoveAdvice() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final advice = await AIManager.generateLoveAdvice(
        situation: '我和對方剛開始約會，但不知道如何進一步發展關係',
        userMBTI: 'ENFP',
        partnerMBTI: 'INTJ',
        category: 'relationship',
      );

      setState(() {
        _result = advice;
      });
    } catch (e) {
      setState(() {
        _result = '錯誤: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testIcebreakers() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final topics = await AIManager.generateIcebreakers(
        userMBTI: 'ENFP',
        partnerMBTI: 'INTJ',
        commonInterests: ['旅行', '音樂', '電影'],
        count: 5,
      );

      setState(() {
        _result = '破冰話題：\n\n${topics.map((topic) => '• $topic').join('\n\n')}';
      });
    } catch (e) {
      setState(() {
        _result = '錯誤: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDateIdea() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final dateIdea = await AIManager.generateDateIdea(
        userMBTI: 'ENFP',
        partnerMBTI: 'INTJ',
        commonInterests: ['藝術', '咖啡', '博物館'],
        budget: 500,
        location: '香港中環',
      );

      setState(() {
        _result = '''
約會建議：${dateIdea['title'] ?? '未知'}

描述：${dateIdea['description'] ?? '無描述'}

地點：${dateIdea['location'] ?? '未指定'}

預計花費：HK\$${dateIdea['estimatedCost'] ?? 0}

建議時長：${dateIdea['duration'] ?? '未知'}

原因：${dateIdea['reasoning'] ?? '無說明'}
''';
      });
    } catch (e) {
      setState(() {
        _result = '錯誤: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUsageStats() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final stats = await AIManager.getUsageStats();

      setState(() {
        _result = '''
AI 使用統計：

愛情建議：${stats['loveAdvice'] ?? 0} 次
破冰話題：${stats['icebreakers'] ?? 0} 次
約會建議：${stats['dateIdeas'] ?? 0} 次
照片分析：${stats['photoAnalysis'] ?? 0} 次

總使用次數：${stats['totalUsage'] ?? 0} 次
統計月份：${stats['month'] ?? '未知'}
''';
      });
    } catch (e) {
      setState(() {
        _result = '錯誤: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await AIManager.exportUserData();
      
      setState(() {
        _result = '數據導出成功！\n\n導出時間：${data['exportedAt']}\n數據項目：${data.keys.length} 個';
      });
    } catch (e) {
      setState(() {
        _result = '導出失敗: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AIManager.cleanupExpiredData();
      
      setState(() {
        _result = '✅ 過期數據清理完成';
      });
    } catch (e) {
      setState(() {
        _result = '清理失敗: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認重置'),
        content: const Text('這將刪除所有 AI 相關數據，此操作無法撤銷。確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AIManager.resetUserData();
      
      setState(() {
        _result = '✅ 所有 AI 數據已重置';
      });
    } catch (e) {
      setState(() {
        _result = '重置失敗: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAPIConnection() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final testResults = await AITestService.testAllConnections();
      
      final geminiResult = testResults['gemini'];
      final visionResult = testResults['vision'];
      final overallResult = testResults['overall'];
      
      setState(() {
        _result = '''
API 連接測試結果：

🤖 Gemini API:
狀態：${geminiResult['success'] ? '✅ 成功' : '❌ 失敗'}
${geminiResult['success'] ? '回應：${geminiResult['response']}' : '錯誤：${geminiResult['error']}'}

👁️ Vision API:
狀態：${visionResult['success'] ? '✅ 成功' : '❌ 失敗'}
${visionResult['success'] ? '連接正常' : '錯誤：${visionResult['error']}'}

📊 總體結果：
${overallResult['message']}

測試時間：${DateTime.now().toString()}
''';
      });
    } catch (e) {
      setState(() {
        _result = 'API 測試失敗: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 