import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 導入統一設計系統
import '../../core/theme/app_design_system.dart';
import '../../shared/widgets/app_components.dart';
import '../../core/ui/ui_bug_fixes.dart';
import 'modes/dating_mode_system.dart';
import 'modes/mode_specific_features.dart';

/// 🎯 Amore 三大交友模式選擇頁面
class DatingModesPage extends ConsumerStatefulWidget {
  const DatingModesPage({super.key});

  @override
  ConsumerState<DatingModesPage> createState() => _DatingModesPageState();
}

class _DatingModesPageState extends ConsumerState<DatingModesPage>
    with TickerProviderStateMixin {
  final DatingModeService _modeService = DatingModeService();
  
  DatingMode? currentMode;
  DatingMode? recommendedMode;
  bool isLoading = true;
  String? errorMessage;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadCurrentMode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentMode() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // 這裡應該從用戶檔案或本地儲存獲取當前模式
      // 目前使用默認的探索模式
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        currentMode = DatingMode.explore; // 默認模式
        isLoading = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      setState(() {
        errorMessage = '載入模式失敗：$e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Amore 三大交友模式',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showModeInfo,
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorView()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildCurrentModeHeader(),
                      Expanded(
                        child: _buildModeSelection(),
                      ),
                      _buildAIRecommendationPanel(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCurrentModeHeader() {
    if (currentMode == null) return const SizedBox();

    final config = DatingModeService.modeConfigs[currentMode]!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.primaryColor, config.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config.icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '當前模式',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '選擇你的交友模式',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '每種模式都有獨特的功能和匹配算法',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
        ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildModeCard(DatingMode.serious),
                const SizedBox(height: 16),
                _buildModeCard(DatingMode.explore),
                const SizedBox(height: 16),
                _buildModeCard(DatingMode.passion),
                const SizedBox(height: 100), // 為底部AI推薦面板留空間
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(DatingMode mode) {
    final config = DatingModeService.modeConfigs[mode]!;
    final isSelected = currentMode == mode;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, _slideAnimation.value / 50),
        end: Offset.zero,
      ).animate(_fadeAnimation),
      child: GestureDetector(
        onTap: () => _switchToMode(mode),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? config.primaryColor 
                  : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? config.primaryColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 15 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                    children: [
                      Container(
                    padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: config.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          config.icon,
                          color: config.primaryColor,
                      size: 28,
                        ),
                      ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        config.name,
                        style: TextStyle(
                            fontSize: 20,
                          fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? config.primaryColor 
                                : Colors.grey.shade800,
                        ),
                      ),
                        const SizedBox(height: 4),
                      Text(
                        config.description,
                        style: TextStyle(
                            fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: config.primaryColor,
                      size: 24,
                    ),
                    ],
                  ),
              const SizedBox(height: 16),
              Text(
                config.detailedDescription,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              _buildModeFeatures(config),
              if (isSelected) ...[
                const SizedBox(height: 16),
                _buildModeStats(mode),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeFeatures(DatingModeConfig config) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: config.uniqueFeatures.take(3).map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: config.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: config.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              color: config.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeStats(DatingMode mode) {
    final stats = _getModeStats(mode);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return Column(
            children: [
              Text(
                stat['value'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DatingModeService.modeConfigs[mode]!.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat['label'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, String>> _getModeStats(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return [
          {'value': '95%', 'label': '匹配精準度'},
          {'value': '87%', 'label': '長期成功率'},
          {'value': '92%', 'label': '用戶滿意度'},
        ];
      case DatingMode.explore:
        return [
          {'value': '88%', 'label': 'AI推薦準確度'},
          {'value': '91%', 'label': '探索滿意度'},
          {'value': '76%', 'label': '成功發現率'},
        ];
      case DatingMode.passion:
        return [
          {'value': '82%', 'label': '即時匹配率'},
          {'value': 'A+', 'label': '隱私保護'},
          {'value': '89%', 'label': '用戶滿意度'},
        ];
    }
  }

  Widget _buildAIRecommendationPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
              color: Colors.white,
                size: 24,
          ),
              SizedBox(width: 12),
              Text(
                  'AI 智能推薦',
                  style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            '不確定哪種模式適合你？讓 AI 根據你的個性和喜好推薦最適合的交友模式。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: _getAIRecommendation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
                '獲取 AI 推薦',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? '載入失敗',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCurrentMode,
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }

  Future<void> _switchToMode(DatingMode newMode) async {
    if (currentMode == newMode) return;

    try {
      setState(() {
        isLoading = true;
      });

      // 這裡應該調用實際的模式切換服務
      await Future.delayed(const Duration(milliseconds: 800));
      
        setState(() {
        currentMode = newMode;
          isLoading = false;
        });
        
             final modeName = DatingModeService.modeConfigs[newMode]?.name ?? '新模式';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
           content: Text('已切換到 $modeName'),
           backgroundColor: DatingModeService.modeConfigs[newMode]?.primaryColor ?? Colors.grey,
          ),
        );

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
           content: Text('切換模式失敗：${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getAIRecommendation() async {
    try {
      setState(() {
        isLoading = true;
      });

      // 模擬 AI 推薦過程
      await Future.delayed(const Duration(milliseconds: 1500));
      
      const recommendedMode = DatingMode.serious; // 模擬推薦結果
      final config = DatingModeService.modeConfigs[recommendedMode]!;

      setState(() {
        isLoading = false;
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: config.primaryColor),
              const SizedBox(width: 8),
              const Text('AI 推薦結果'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '根據你的個性分析，我們推薦：',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: config.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: config.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: config.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      config.detailedDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('稍後決定'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _switchToMode(recommendedMode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: config.primaryColor,
              ),
              child: const Text(
                '立即切換',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('獲取推薦失敗：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showModeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFFE91E63)),
            SizedBox(width: 8),
            Text('Amore 三大交友模式'),
          ],
        ),
        content: const Text(
          'Amore 提供三種核心交友模式，讓你根據當前的心境和目標選擇最適合的交友方式。每種模式都有獨特的功能和匹配算法，幫助你找到理想的連結。\n\n• 認真交往：專注長期關係\n• 探索模式：發現個人偏好\n• 激情模式：追求即時連結',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
} 