import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dating_mode_system.dart';

/// 🎯 交友模式選擇器
class ModeSelectorWidget extends ConsumerStatefulWidget {
  final String userId;
  final DatingMode? currentMode;
  final Function(DatingMode)? onModeSelected;

  const ModeSelectorWidget({
    super.key,
    required this.userId,
    this.currentMode,
    this.onModeSelected,
  });

  @override
  ConsumerState<ModeSelectorWidget> createState() => _ModeSelectorWidgetState();
}

class _ModeSelectorWidgetState extends ConsumerState<ModeSelectorWidget> {
  DatingMode? selectedMode;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildModeList(),
          if (errorMessage != null) _buildErrorMessage(),
          const SizedBox(height: 16),
          _buildAISuggestion(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '選擇交友模式',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '根據你的目標找到最適合的交友方式',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: DatingMode.values.map((mode) {
          final config = DatingModeService.modeConfigs[mode]!;
          final isSelected = selectedMode == mode;
          final isCurrent = widget.currentMode == mode;
          
          return _buildModeCard(config, isSelected, isCurrent);
        }).toList(),
      ),
    );
  }

  Widget _buildModeCard(DatingModeConfig config, bool isSelected, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
              ? config.primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? config.primaryColor.withOpacity(0.05)
            : Colors.grey.shade50,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              selectedMode = config.mode;
              errorMessage = null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: config.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        config.icon,
                        color: config.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                config.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? config.primaryColor
                                      : Colors.black87,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    '目前',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              if (config.accessLevel == ModeAccessLevel.verified) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.blue.shade600,
                                ),
                              ],
                              if (config.accessLevel == ModeAccessLevel.premium) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber.shade600,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: config.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: config.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: config.primaryColor.withOpacity(0.3),
                        ),
                      ),
                                             child: Text(
                         feature,
                         style: TextStyle(
                           fontSize: 10,
                           color: config.primaryColor,
                         ),
                       ),
                    );
                  }).toList(),
                ),
                if (config.features.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '還有 ${config.features.length - 3} 項功能...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestion() {
    return FutureBuilder<DatingMode>(
      future: ref.read(datingModeServiceProvider).recommendOptimalMode(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final recommendedMode = snapshot.data!;
        final config = DatingModeService.modeConfigs[recommendedMode]!;
        
        if (recommendedMode == selectedMode) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.purple.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, 
                      color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'AI 建議',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '根據你的聊天習慣，我們建議你嘗試「${config.name}」模式',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedMode = recommendedMode;
                    errorMessage = null;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '採用建議',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedMode != null && selectedMode != widget.currentMode
                  ? _confirmModeSwitch
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedMode != null 
                    ? DatingModeService.modeConfigs[selectedMode]!.primaryColor
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                selectedMode == widget.currentMode ? '已選取' : '確認切換',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmModeSwitch() async {
    if (selectedMode == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final service = ref.read(datingModeServiceProvider);
      final success = await service.switchDatingMode(
        widget.userId, 
        selectedMode!,
        reason: 'User selected',
      );

      if (success) {
        widget.onModeSelected?.call(selectedMode!);
        if (mounted) {
          Navigator.of(context).pop();
          _showSuccessSnackBar();
        }
      } else {
        setState(() {
          errorMessage = '切換模式失敗，請稍後再試';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar() {
    if (!mounted) return;
    
    final config = DatingModeService.modeConfigs[selectedMode]!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(config.icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('成功切換到「${config.name}」模式'),
          ],
        ),
        backgroundColor: config.primaryColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '查看功能',
          textColor: Colors.white,
          onPressed: () {
            _showModeFeatures(config);
          },
        ),
      ),
    );
  }

  void _showModeFeatures(DatingModeConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(config.icon, color: config.primaryColor),
            const SizedBox(width: 8),
            Text(config.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(config.description),
            const SizedBox(height: 16),
            const Text(
              '功能特色：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...config.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, color: config.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: const TextStyle(fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
} 