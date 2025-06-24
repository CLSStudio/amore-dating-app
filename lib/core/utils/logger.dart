import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// 應用程式日誌工具類
class Logger {
  static const String _name = 'Amore';

  /// 輸出信息日誌
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _name,
        level: 800, // INFO level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 輸出警告日誌
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _name,
        level: 900, // WARNING level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 輸出錯誤日誌
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: 1000, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 輸出調試日誌
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _name,
        level: 700, // DEBUG level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 輸出詳細日誌
  static void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: _name,
        level: 500, // VERBOSE level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
} 