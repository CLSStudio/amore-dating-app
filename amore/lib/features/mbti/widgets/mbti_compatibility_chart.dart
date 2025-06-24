import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/mbti_service.dart';

class MBTICompatibilityChart extends StatefulWidget {
  final String personalityType;

  const MBTICompatibilityChart({
    super.key,
    required this.personalityType,
  });

  @override
  State<MBTICompatibilityChart> createState() => _MBTICompatibilityChartState();
}

class _MBTICompatibilityChartState extends State<MBTICompatibilityChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  Map<String, double> _compatibilityData = {};
  bool _isLoading = true;

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
      curve: Curves.easeOut,
    ));
    
    _loadCompatibilityData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCompatibilityData() async {
    // 模擬載入兼容性數據
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 根據人格類型計算兼容性
    _compatibilityData = _calculateCompatibility(widget.personalityType);
    
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  Map<String, double> _calculateCompatibility(String personalityType) {
    // 這裡是簡化的兼容性計算邏輯
    // 實際應用中應該使用更複雜的算法
    final compatibilityMap = <String, double>{};
    
    final allTypes = [
      'INTJ', 'INTP', 'ENTJ', 'ENTP',
      'INFJ', 'INFP', 'ENFJ', 'ENFP',
      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
      'ISTP', 'ISFP', 'ESTP', 'ESFP',
    ];

    for (final type in allTypes) {
      if (type == personalityType) {
        compatibilityMap[type] = 1.0; // 自己 100% 兼容
      } else {
        compatibilityMap[type] = _calculateTypeCompatibility(personalityType, type);
      }
    }

    return compatibilityMap;
  }

  double _calculateTypeCompatibility(String type1, String type2) {
    // 簡化的兼容性計算
    int matches = 0;
    
    // 比較每個維度
    for (int i = 0; i < 4; i++) {
      if (type1[i] == type2[i]) {
        matches++;
      }
    }
    
    // 基於匹配數量計算兼容性
    switch (matches) {
      case 4:
        return 1.0; // 完全匹配
      case 3:
        return 0.85; // 高度兼容
      case 2:
        return 0.65; // 中等兼容
      case 1:
        return 0.45; // 低兼容
      case 0:
        return 0.25; // 最低兼容
      default:
        return 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 說明文字
          Text(
            '與其他人格類型的兼容性分析',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 兼容性等級說明
          _buildLegend(),
          
          const SizedBox(height: 20),
          
          // 兼容性網格
          _buildCompatibilityGrid(),
          
          const SizedBox(height: 20),
          
          // 最佳匹配
          _buildBestMatches(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('極佳', AppColors.success, 0.85),
        const SizedBox(width: 16),
        _buildLegendItem('良好', AppColors.info, 0.65),
        const SizedBox(width: 16),
        _buildLegendItem('一般', AppColors.warning, 0.45),
        const SizedBox(width: 16),
        _buildLegendItem('較低', AppColors.error, 0.25),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double threshold) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityGrid() {
    final sortedTypes = _compatibilityData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: sortedTypes.length,
      itemBuilder: (context, index) {
        final entry = sortedTypes[index];
        return _buildCompatibilityItem(entry.key, entry.value);
      },
    );
  }

  Widget _buildCompatibilityItem(String type, double compatibility) {
    final isCurrentType = type == widget.personalityType;
    final color = _getCompatibilityColor(compatibility);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeOutBack,
      decoration: BoxDecoration(
        color: isCurrentType ? AppColors.primary : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentType ? AppColors.primary : color,
          width: isCurrentType ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            type,
            style: AppTextStyles.button.copyWith(
              color: isCurrentType ? Colors.white : color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(compatibility * 100).round()}%',
            style: AppTextStyles.caption.copyWith(
              color: isCurrentType ? Colors.white.withOpacity(0.9) : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCompatibilityColor(double compatibility) {
    if (compatibility >= 0.85) return AppColors.success;
    if (compatibility >= 0.65) return AppColors.info;
    if (compatibility >= 0.45) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildBestMatches() {
    final bestMatches = _compatibilityData.entries
        .where((entry) => entry.key != widget.personalityType)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topMatches = bestMatches.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最佳匹配類型',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...topMatches.asMap().entries.map((entry) {
          final index = entry.key;
          final match = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 排名
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // 類型和兼容性
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.key,
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _getPersonalityTitle(match.key),
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 兼容性百分比
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCompatibilityColor(match.value).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getCompatibilityColor(match.value),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${(match.value * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: _getCompatibilityColor(match.value),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getPersonalityTitle(String type) {
    // 簡化的人格類型標題映射
    final titles = {
      'INTJ': '建築師',
      'INTP': '思想家',
      'ENTJ': '指揮官',
      'ENTP': '辯論家',
      'INFJ': '提倡者',
      'INFP': '調停者',
      'ENFJ': '主人公',
      'ENFP': '競選者',
      'ISTJ': '物流師',
      'ISFJ': '守護者',
      'ESTJ': '總經理',
      'ESFJ': '執政官',
      'ISTP': '鑑賞家',
      'ISFP': '探險家',
      'ESTP': '企業家',
      'ESFP': '娛樂家',
    };
    
    return titles[type] ?? '未知類型';
  }
} 