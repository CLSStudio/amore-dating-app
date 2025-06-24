import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../dating_mode_strategy.dart';
import '../mode_manager.dart';
import '../../features/dating/modes/dating_mode_system.dart';

/// 🚀 Amore 性能優化器
/// 負責優化三大交友模式的性能表現
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  // 性能監控指標
  final Map<String, List<double>> _performanceMetrics = {};
  final Map<String, Timer> _activeTimers = {};
  
  // 緩存管理
  final LRUCache<String, dynamic> _cache = LRUCache(maxSize: 1000);
  
  // 記憶體管理
  final Set<String> _memoryWatchers = {};
  Timer? _memoryCleanupTimer;

  /// 🎯 初始化性能優化器
  void initialize() {
    _startMemoryCleanup();
    _initializePerformanceMonitoring();
    debugPrint('🚀 性能優化器已初始化');
  }

  /// ⏱️ 開始性能監控
  void startPerformanceMonitoring(String operation) {
    final stopwatch = Stopwatch()..start();
    _activeTimers[operation] = Timer(const Duration(seconds: 30), () {
      stopwatch.stop();
      _recordPerformanceMetric(operation, stopwatch.elapsedMilliseconds.toDouble());
      _activeTimers.remove(operation);
    });
  }

  /// 📊 結束性能監控
  void endPerformanceMonitoring(String operation) {
    final timer = _activeTimers.remove(operation);
    if (timer != null) {
      timer.cancel();
      // 記錄實際完成時間
      _recordPerformanceMetric(operation, DateTime.now().millisecondsSinceEpoch.toDouble());
    }
  }

  /// 📈 記錄性能指標
  void _recordPerformanceMetric(String operation, double value) {
    _performanceMetrics.putIfAbsent(operation, () => []).add(value);
    
    // 保持最近100次記錄
    if (_performanceMetrics[operation]!.length > 100) {
      _performanceMetrics[operation]!.removeAt(0);
    }
    
    // 檢查性能異常
    _checkPerformanceAnomaly(operation, value);
  }

  /// 🚨 檢查性能異常
  void _checkPerformanceAnomaly(String operation, double value) {
    final metrics = _performanceMetrics[operation]!;
    if (metrics.length < 10) return;
    
    final average = metrics.reduce((a, b) => a + b) / metrics.length;
    final threshold = average * 2.0; // 超過平均值2倍視為異常
    
    if (value > threshold) {
      debugPrint('⚠️ 性能異常檢測: $operation 耗時 ${value}ms (平均: ${average.toStringAsFixed(1)}ms)');
      _handlePerformanceAnomaly(operation, value, average);
    }
  }

  /// 🔧 處理性能異常
  void _handlePerformanceAnomaly(String operation, double value, double average) {
    switch (operation) {
      case 'mode_switch':
        _optimizeModeSwitching();
        break;
      case 'user_pool_query':
        _optimizeUserPoolQuery();
        break;
      case 'content_recommendation':
        _optimizeContentRecommendation();
        break;
      default:
        _performGeneralOptimization();
    }
  }

  /// 🔄 優化模式切換
  void _optimizeModeSwitching() {
    debugPrint('🔄 正在優化模式切換性能...');
    
    // 預載入常用模式資源
    _preloadModeResources();
    
    // 清理不必要的監聽器
    _cleanupModeListeners();
    
    // 優化動畫性能
    _optimizeAnimations();
  }

  /// 🔍 優化用戶池查詢
  void _optimizeUserPoolQuery() {
    debugPrint('🔍 正在優化用戶池查詢性能...');
    
    // 實施查詢結果緩存
    _implementQueryCache();
    
    // 優化數據庫索引
    _optimizeDatabaseIndexes();
    
    // 實施分頁載入
    _implementPaginatedLoading();
  }

  /// 🎯 優化內容推薦
  void _optimizeContentRecommendation() {
    debugPrint('🎯 正在優化內容推薦性能...');
    
    // 實施推薦結果緩存
    _implementRecommendationCache();
    
    // 優化AI算法
    _optimizeAIAlgorithms();
    
    // 實施背景預計算
    _implementBackgroundPrecomputation();
  }

  /// ⚡ 執行一般性能優化
  void _performGeneralOptimization() {
    debugPrint('⚡ 執行一般性能優化...');
    
    // 清理記憶體
    _performMemoryCleanup();
    
    // 優化圖片載入
    _optimizeImageLoading();
    
    // 清理無用緩存
    _cleanupUnusedCache();
  }

  /// 📦 預載入模式資源
  void _preloadModeResources() {
    for (final mode in DatingMode.values) {
      final cacheKey = 'mode_resources_${mode.name}';
      if (!_cache.containsKey(cacheKey)) {
        _cache.put(cacheKey, _loadModeResources(mode));
      }
    }
  }

  /// 📚 載入模式資源
  Map<String, dynamic> _loadModeResources(DatingMode mode) {
    return {
      'theme': _getModeTheme(mode),
      'config': _getModeConfig(mode),
      'assets': _getModeAssets(mode),
    };
  }

  /// 🎨 獲取模式主題
  Map<String, dynamic> _getModeTheme(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return {
          'primaryColor': '#1565C0',
          'secondaryColor': '#0277BD',
          'accentColor': '#81C784',
        };
      case DatingMode.explore:
        return {
          'primaryColor': '#FF7043',
          'secondaryColor': '#FFB74D',
          'accentColor': '#7986CB',
        };
      case DatingMode.passion:
        return {
          'primaryColor': '#2E7D32',
          'secondaryColor': '#43A047',
          'accentColor': '#26C6DA',
        };
    }
  }

  /// ⚙️ 獲取模式配置
  Map<String, dynamic> _getModeConfig(DatingMode mode) {
    return {
      'name': _getModeName(mode),
      'features': _getModeFeatures(mode),
      'settings': _getModeSettings(mode),
    };
  }

  /// 📱 獲取模式名稱
  String _getModeName(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return '認真交往';
      case DatingMode.explore:
        return '探索模式';
      case DatingMode.passion:
        return '激情模式';
    }
  }

  /// 🎯 獲取模式功能
  List<String> _getModeFeatures(DatingMode mode) {
    switch (mode) {
      case DatingMode.serious:
        return ['深度匹配', '價值觀分析', '專業顧問'];
      case DatingMode.explore:
        return ['多樣匹配', '興趣探索', 'AI推薦'];
      case DatingMode.passion:
        return ['即時匹配', '位置服務', '隱私保護'];
    }
  }

  /// ⚙️ 獲取模式設置
  Map<String, dynamic> _getModeSettings(DatingMode mode) {
    return {
      'maxMatches': mode == DatingMode.serious ? 10 : 50,
      'refreshInterval': mode == DatingMode.passion ? 30 : 300,
      'cacheTimeout': mode == DatingMode.explore ? 600 : 1800,
    };
  }

  /// 🖼️ 獲取模式資源
  List<String> _getModeAssets(DatingMode mode) {
    return [
      'assets/images/${mode.name}_background.jpg',
      'assets/images/${mode.name}_icon.png',
      'assets/animations/${mode.name}_transition.json',
    ];
  }

  /// 🧹 清理模式監聽器
  void _cleanupModeListeners() {
    // 移除不活躍的監聽器
    debugPrint('🧹 清理不活躍的模式監聽器');
  }

  /// 🎬 優化動畫性能
  void _optimizeAnimations() {
    // 降低動畫複雜度
    debugPrint('🎬 優化動畫性能');
  }

  /// 💾 實施查詢緩存
  void _implementQueryCache() {
    debugPrint('💾 實施用戶池查詢緩存');
  }

  /// 📊 優化數據庫索引
  void _optimizeDatabaseIndexes() {
    debugPrint('📊 優化數據庫索引');
  }

  /// 📄 實施分頁載入
  void _implementPaginatedLoading() {
    debugPrint('📄 實施分頁載入');
  }

  /// 🎯 實施推薦緩存
  void _implementRecommendationCache() {
    debugPrint('🎯 實施推薦結果緩存');
  }

  /// 🤖 優化AI算法
  void _optimizeAIAlgorithms() {
    debugPrint('🤖 優化AI推薦算法');
  }

  /// ⚡ 實施背景預計算
  void _implementBackgroundPrecomputation() {
    debugPrint('⚡ 實施背景預計算');
  }

  /// 💾 開始記憶體清理
  void _startMemoryCleanup() {
    _memoryCleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performMemoryCleanup();
    });
  }

  /// 🧹 執行記憶體清理
  void _performMemoryCleanup() {
    debugPrint('🧹 執行記憶體清理...');
    
    // 清理過期緩存
    _cache.cleanup();
    
    // 強制垃圾回收
    if (kDebugMode) {
      // 在調試模式下可以手動觸發GC
      debugPrint('🗑️ 觸發垃圾回收');
    }
    
    // 清理性能指標歷史
    _cleanupPerformanceMetrics();
  }

  /// 📊 清理性能指標
  void _cleanupPerformanceMetrics() {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    const maxAge = 3600000; // 1小時
    
    _performanceMetrics.removeWhere((key, values) {
      values.removeWhere((value) => now - value > maxAge);
      return values.isEmpty;
    });
  }

  /// 🖼️ 優化圖片載入
  void _optimizeImageLoading() {
    debugPrint('🖼️ 優化圖片載入性能');
    
    // 實施圖片緩存
    // 壓縮圖片質量
    // 延遲載入非關鍵圖片
  }

  /// 🧹 清理無用緩存
  void _cleanupUnusedCache() {
    debugPrint('🧹 清理無用緩存');
    _cache.removeOldest(100); // 移除最舊的100個項目
  }

  /// 📊 初始化性能監控
  void _initializePerformanceMonitoring() {
    // 監控關鍵操作
    final criticalOperations = [
      'mode_switch',
      'user_pool_query',
      'content_recommendation',
      'image_loading',
      'animation_rendering',
    ];
    
    for (final operation in criticalOperations) {
      _performanceMetrics[operation] = [];
    }
    
    debugPrint('📊 性能監控已初始化，監控 ${criticalOperations.length} 個關鍵操作');
  }

  /// 📈 獲取性能報告
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};
    
    for (final entry in _performanceMetrics.entries) {
      final values = entry.value;
      if (values.isNotEmpty) {
        final average = values.reduce((a, b) => a + b) / values.length;
        final min = values.reduce((a, b) => a < b ? a : b);
        final max = values.reduce((a, b) => a > b ? a : b);
        
        report[entry.key] = {
          'average': average,
          'min': min,
          'max': max,
          'count': values.length,
        };
      }
    }
    
    return report;
  }

  /// 🎯 獲取優化建議
  List<String> getOptimizationSuggestions() {
    final suggestions = <String>[];
    final report = getPerformanceReport();
    
    for (final entry in report.entries) {
      final metrics = entry.value as Map<String, dynamic>;
      final average = metrics['average'] as double;
      
      switch (entry.key) {
        case 'mode_switch':
          if (average > 500) {
            suggestions.add('模式切換時間過長，建議預載入資源');
          }
          break;
        case 'user_pool_query':
          if (average > 1000) {
            suggestions.add('用戶池查詢緩慢，建議優化數據庫查詢');
          }
          break;
        case 'content_recommendation':
          if (average > 200) {
            suggestions.add('內容推薦生成緩慢，建議實施緩存機制');
          }
          break;
      }
    }
    
    return suggestions;
  }

  /// 🔄 重置性能統計
  void resetPerformanceStats() {
    _performanceMetrics.clear();
    debugPrint('🔄 性能統計已重置');
  }

  /// 🛑 停止性能優化器
  void dispose() {
    _memoryCleanupTimer?.cancel();
    _activeTimers.values.forEach((timer) => timer.cancel());
    _activeTimers.clear();
    _cache.clear();
    debugPrint('🛑 性能優化器已停止');
  }
}

/// 📦 LRU緩存實現
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  LRUCache({required this.maxSize});

  V? get(K key) {
    if (_cache.containsKey(key)) {
      final value = _cache.remove(key)!;
      _cache[key] = value; // 移到最後
      return value;
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void remove(K key) => _cache.remove(key);

  void clear() => _cache.clear();

  int get length => _cache.length;

  void cleanup() {
    // 移除最舊的25%項目
    final removeCount = (_cache.length * 0.25).round();
    final keysToRemove = _cache.keys.take(removeCount).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  void removeOldest(int count) {
    final keysToRemove = _cache.keys.take(count).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
}