import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ModernBottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;

  const ModernBottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
  });
}

class ModernBottomNavigation extends StatefulWidget {
  final List<ModernBottomNavigationItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final bool showLabels;

  const ModernBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.showLabels = true,
  });

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 0.6,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    // 初始化當前選中項的動畫
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ModernBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // 重置舊的動畫
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // 啟動新的動畫
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return _buildNavigationItem(
                item: item,
                index: index,
                isSelected: isSelected,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required ModernBottomNavigationItem item,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap(index);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimations[index],
          _fadeAnimations[index],
        ]),
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.modernPinkGradient : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 圖標
                Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected && item.activeIcon != null 
                          ? item.activeIcon! 
                          : item.icon,
                      color: isSelected 
                          ? Colors.white
                          : item.color ?? AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
                
                // 標籤
                if (widget.showLabels) ...[
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    opacity: _fadeAnimations[index].value,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      item.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected 
                            ? Colors.white
                            : item.color ?? AppColors.textSecondary,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
} 