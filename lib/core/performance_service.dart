import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';

// 性能服務提供者
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});

// 性能指標模型
class PerformanceMetrics {
  final double frameRate;
  final int memoryUsage;
  final double cpuUsage;
  final int networkLatency;
  final DateTime timestamp;

  PerformanceMetrics({
    required this.frameRate,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.networkLatency,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'frameRate': frameRate,
      'memoryUsage': memoryUsage,
      'cpuUsage': cpuUsage,
      'networkLatency': networkLatency,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// 快取配置
class CacheConfig {
  final int maxCacheSize;
  final Duration cacheExpiry;
  final bool enableImageCache;
  final bool enableDataCache;

  const CacheConfig({
    this.maxCacheSize = 100 * 1024 * 1024, // 100MB
    this.cacheExpiry = const Duration(hours: 24),
    this.enableImageCache = true,
    this.enableDataCache = true,
  });
}

// 動畫配置
class AnimationConfig {
  final bool enableAnimations;
  final double animationScale;
  final Duration defaultDuration;
  final bool enableHapticFeedback;

  const AnimationConfig({
    this.enableAnimations = true,
    this.animationScale = 1.0,
    this.defaultDuration = const Duration(milliseconds: 300),
    this.enableHapticFeedback = true,
  });
}

class PerformanceService {
  static const String _prefsKey = 'performance_settings';
  static const String _metricsKey = 'performance_metrics';
  
  SharedPreferences? _prefs;
  Timer? _metricsTimer;
  final List<PerformanceMetrics> _metricsHistory = [];
  
  CacheConfig _cacheConfig = const CacheConfig();
  AnimationConfig _animationConfig = const AnimationConfig();
  
  bool _isInitialized = false;
  bool _isMonitoring = false;

  // 初始化性能服務
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      await _setupImageCache();
      await _optimizeSystemSettings();
      
      _isInitialized = true;
      print('性能服務初始化完成');
    } catch (e) {
      print('性能服務初始化失敗: $e');
    }
  }

  // 載入設置
  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString(_prefsKey);
      if (settingsJson != null) {
        // 這裡可以解析保存的設置
        print('已載入性能設置');
      }
    } catch (e) {
      print('載入性能設置失敗: $e');
    }
  }

  // 設置圖片快取
  Future<void> _setupImageCache() async {
    if (!_cacheConfig.enableImageCache) return;

    try {
      // 設置圖片快取大小
      PaintingBinding.instance.imageCache.maximumSize = 1000;
      PaintingBinding.instance.imageCache.maximumSizeBytes = _cacheConfig.maxCacheSize;
      
      print('圖片快取已設置: ${_cacheConfig.maxCacheSize ~/ (1024 * 1024)}MB');
    } catch (e) {
      print('設置圖片快取失敗: $e');
    }
  }

  // 優化系統設置
  Future<void> _optimizeSystemSettings() async {
    try {
      // 設置系統 UI 覆蓋樣式
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // 設置首選方向
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      print('系統設置已優化');
    } catch (e) {
      print('優化系統設置失敗: $e');
    }
  }

  // 開始性能監控
  void startPerformanceMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _collectPerformanceMetrics();
    });

    print('性能監控已開始');
  }

  // 停止性能監控
  void stopPerformanceMonitoring() {
    _metricsTimer?.cancel();
    _metricsTimer = null;
    _isMonitoring = false;
    print('性能監控已停止');
  }

  // 收集性能指標
  Future<void> _collectPerformanceMetrics() async {
    try {
      final metrics = PerformanceMetrics(
        frameRate: await _getFrameRate(),
        memoryUsage: await _getMemoryUsage(),
        cpuUsage: await _getCpuUsage(),
        networkLatency: await _getNetworkLatency(),
        timestamp: DateTime.now(),
      );

      _metricsHistory.add(metrics);
      
      // 保持最近100條記錄
      if (_metricsHistory.length > 100) {
        _metricsHistory.removeAt(0);
      }

      // 檢查性能警告
      _checkPerformanceWarnings(metrics);
      
    } catch (e) {
      print('收集性能指標失敗: $e');
    }
  }

  // 獲取幀率
  Future<double> _getFrameRate() async {
    // 模擬幀率檢測
    return 60.0; // 實際實現需要使用 Flutter Inspector API
  }

  // 獲取記憶體使用量
  Future<int> _getMemoryUsage() async {
    try {
      if (Platform.isAndroid) {
        // Android 記憶體檢測
        return 50 * 1024 * 1024; // 50MB (模擬值)
      } else if (Platform.isIOS) {
        // iOS 記憶體檢測
        return 45 * 1024 * 1024; // 45MB (模擬值)
      }
    } catch (e) {
      print('獲取記憶體使用量失敗: $e');
    }
    return 0;
  }

  // 獲取 CPU 使用率
  Future<double> _getCpuUsage() async {
    // 模擬 CPU 使用率
    return 15.0; // 15% (模擬值)
  }

  // 獲取網路延遲
  Future<int> _getNetworkLatency() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // 簡單的網路延遲測試
      await InternetAddress.lookup('google.com');
      
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      print('獲取網路延遲失敗: $e');
      return 1000; // 1秒超時
    }
  }

  // 檢查性能警告
  void _checkPerformanceWarnings(PerformanceMetrics metrics) {
    final warnings = <String>[];

    if (metrics.frameRate < 30) {
      warnings.add('幀率過低: ${metrics.frameRate.toStringAsFixed(1)} FPS');
    }

    if (metrics.memoryUsage > 100 * 1024 * 1024) {
      warnings.add('記憶體使用過高: ${(metrics.memoryUsage / (1024 * 1024)).toStringAsFixed(1)} MB');
    }

    if (metrics.cpuUsage > 80) {
      warnings.add('CPU 使用率過高: ${metrics.cpuUsage.toStringAsFixed(1)}%');
    }

    if (metrics.networkLatency > 2000) {
      warnings.add('網路延遲過高: ${metrics.networkLatency} ms');
    }

    if (warnings.isNotEmpty) {
      print('性能警告: ${warnings.join(', ')}');
      _triggerPerformanceOptimization();
    }
  }

  // 觸發性能優化
  void _triggerPerformanceOptimization() {
    // 清理圖片快取
    _clearImageCache();
    
    // 垃圾回收
    _forceGarbageCollection();
    
    // 降低動畫質量
    _reduceAnimationQuality();
    
    print('已觸發性能優化');
  }

  // 清理圖片快取
  void _clearImageCache() {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      CachedNetworkImage.evictFromCache(''); // 清理網路圖片快取
      print('圖片快取已清理');
    } catch (e) {
      print('清理圖片快取失敗: $e');
    }
  }

  // 強制垃圾回收
  void _forceGarbageCollection() {
    try {
      // 在 Dart 中沒有直接的垃圾回收 API
      // 但可以通過清理大型對象來幫助 GC
      _metricsHistory.clear();
      print('已觸發垃圾回收');
    } catch (e) {
      print('垃圾回收失敗: $e');
    }
  }

  // 降低動畫質量
  void _reduceAnimationQuality() {
    _animationConfig = AnimationConfig(
      enableAnimations: _animationConfig.enableAnimations,
      animationScale: 0.5, // 降低動畫速度
      defaultDuration: const Duration(milliseconds: 150), // 縮短動畫時間
      enableHapticFeedback: false, // 關閉觸覺反饋
    );
    print('動畫質量已降低');
  }

  // 預載入關鍵資源
  Future<void> preloadCriticalResources() async {
    try {
      // 預載入關鍵圖片
      await _preloadImages();
      
      // 預載入字體
      await _preloadFonts();
      
      // 預載入數據
      await _preloadData();
      
      print('關鍵資源預載入完成');
    } catch (e) {
      print('預載入資源失敗: $e');
    }
  }

  // 預載入圖片
  Future<void> _preloadImages() async {
    final criticalImages = [
      'assets/images/logo.png',
      'assets/images/placeholder.png',
      'assets/icons/heart.png',
      'assets/icons/chat.png',
    ];

    for (final imagePath in criticalImages) {
      try {
        await precacheImage(AssetImage(imagePath), navigatorKey.currentContext!);
      } catch (e) {
        print('預載入圖片失敗: $imagePath - $e');
      }
    }
  }

  // 預載入字體
  Future<void> _preloadFonts() async {
    try {
      // 預載入自定義字體
      await Future.wait([
        // 這裡可以添加字體預載入邏輯
      ]);
    } catch (e) {
      print('預載入字體失敗: $e');
    }
  }

  // 預載入數據
  Future<void> _preloadData() async {
    try {
      // 預載入關鍵數據
      await Future.wait([
        _preloadUserProfile(),
        _preloadAppSettings(),
      ]);
    } catch (e) {
      print('預載入數據失敗: $e');
    }
  }

  // 預載入用戶檔案
  Future<void> _preloadUserProfile() async {
    // 實現用戶檔案預載入邏輯
  }

  // 預載入應用設置
  Future<void> _preloadAppSettings() async {
    // 實現應用設置預載入邏輯
  }

  // 優化列表性能
  Widget optimizeListView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    ScrollController? controller,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const BouncingScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 添加性能優化的包裝器
        return _OptimizedListItem(
          key: ValueKey(index),
          child: itemBuilder(context, index),
        );
      },
      // 優化設置
      cacheExtent: 500, // 快取範圍
      addAutomaticKeepAlives: false, // 不自動保持狀態
      addRepaintBoundaries: true, // 添加重繪邊界
    );
  }

  // 優化圖片載入
  Widget optimizeImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
             placeholder: (context, url) => placeholder ?? _buildImagePlaceholder(),
       errorWidget: (context, url, error) => errorWidget ?? _buildImageError(),
      // 性能優化設置
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      fadeInDuration: _animationConfig.enableAnimations 
          ? const Duration(milliseconds: 200)
          : Duration.zero,
      fadeOutDuration: _animationConfig.enableAnimations
          ? const Duration(milliseconds: 100)
          : Duration.zero,
    );
  }

  // 圖片佔位符
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  // 圖片錯誤組件
  Widget _buildImageError() {
    return Container(
      color: Colors.grey[100],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  // 優化動畫
  AnimationController optimizeAnimationController({
    required TickerProvider vsync,
    Duration? duration,
    String? debugLabel,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration ?? _animationConfig.defaultDuration,
      debugLabel: debugLabel,
    );
  }

  // 觸覺反饋
  void hapticFeedback({HapticFeedbackType type = HapticFeedbackType.lightImpact}) {
    if (_animationConfig.enableHapticFeedback) {
      switch (type) {
        case HapticFeedbackType.lightImpact:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.mediumImpact:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavyImpact:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selectionClick:
          HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.vibrate:
          HapticFeedback.vibrate();
          break;
      }
    }
  }

  // 獲取性能報告
  Map<String, dynamic> getPerformanceReport() {
    if (_metricsHistory.isEmpty) {
      return {'status': 'no_data'};
    }

    final recentMetrics = _metricsHistory.take(20).toList();
    final avgFrameRate = recentMetrics.map((m) => m.frameRate).reduce((a, b) => a + b) / recentMetrics.length;
    final avgMemoryUsage = recentMetrics.map((m) => m.memoryUsage).reduce((a, b) => a + b) / recentMetrics.length;
    final avgCpuUsage = recentMetrics.map((m) => m.cpuUsage).reduce((a, b) => a + b) / recentMetrics.length;
    final avgNetworkLatency = recentMetrics.map((m) => m.networkLatency).reduce((a, b) => a + b) / recentMetrics.length;

    String performanceGrade;
    if (avgFrameRate >= 55 && avgMemoryUsage < 50 * 1024 * 1024 && avgCpuUsage < 30) {
      performanceGrade = 'excellent';
    } else if (avgFrameRate >= 45 && avgMemoryUsage < 80 * 1024 * 1024 && avgCpuUsage < 50) {
      performanceGrade = 'good';
    } else if (avgFrameRate >= 30 && avgMemoryUsage < 120 * 1024 * 1024 && avgCpuUsage < 70) {
      performanceGrade = 'fair';
    } else {
      performanceGrade = 'poor';
    }

    return {
      'status': 'available',
      'grade': performanceGrade,
      'metrics': {
        'averageFrameRate': avgFrameRate.toStringAsFixed(1),
        'averageMemoryUsage': '${(avgMemoryUsage / (1024 * 1024)).toStringAsFixed(1)} MB',
        'averageCpuUsage': '${avgCpuUsage.toStringAsFixed(1)}%',
        'averageNetworkLatency': '${avgNetworkLatency.toStringAsFixed(0)} ms',
      },
      'recommendations': _getPerformanceRecommendations(performanceGrade),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // 獲取性能建議
  List<String> _getPerformanceRecommendations(String grade) {
    switch (grade) {
      case 'excellent':
        return ['性能表現優秀，繼續保持！'];
      case 'good':
        return [
          '性能表現良好',
          '可以考慮清理不必要的快取',
        ];
      case 'fair':
        return [
          '建議關閉部分動畫效果',
          '清理應用快取',
          '重啟應用以釋放記憶體',
        ];
      case 'poor':
        return [
          '建議重啟應用',
          '關閉其他應用以釋放記憶體',
          '檢查網路連接',
          '考慮升級設備',
        ];
      default:
        return [];
    }
  }

  // 更新快取配置
  void updateCacheConfig(CacheConfig config) {
    _cacheConfig = config;
    _setupImageCache();
  }

  // 更新動畫配置
  void updateAnimationConfig(AnimationConfig config) {
    _animationConfig = config;
  }

  // 獲取當前配置
  CacheConfig get cacheConfig => _cacheConfig;
  AnimationConfig get animationConfig => _animationConfig;
  bool get isMonitoring => _isMonitoring;
  List<PerformanceMetrics> get metricsHistory => List.unmodifiable(_metricsHistory);

  // 清理資源
  void dispose() {
    stopPerformanceMonitoring();
    _metricsHistory.clear();
    print('性能服務已清理');
  }
}

// 優化的列表項組件
class _OptimizedListItem extends StatelessWidget {
  final Widget child;

  const _OptimizedListItem({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}

// 觸覺反饋類型枚舉
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

// 全局導航鍵（需要在 main.dart 中設置）
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 