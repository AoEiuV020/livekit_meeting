// ignore_for_file: avoid_print

import 'dart:async';

import 'package:logging/logging.dart';

import 'log_level/log_level.dart';
import 'log_writer/log_writer.dart';

/// 应用日志记录器
class AppLogger {
  static final Logger _logger = Logger('MeetingFlutter');
  static bool _initialized = false;
  static late LogLevelHandler _levelHandler;

  static Future<void> init() async {
    if (_initialized) return;
    // 初始化日志级别处理器
    _levelHandler = await LogLevelHandler.create();
    // 初始化日志处理器
    await LoggerHandler.init(_logger.name);
    _initialized = true;
  }

  static void finest(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.finest(message, error, stackTrace);

  static void finer(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.finer(message, error, stackTrace);

  static void fine(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.fine(message, error, stackTrace);

  static void info(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.info(message, error, stackTrace);

  static void warning(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.warning(message, error, stackTrace);

  static void severe(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.severe(message, error, stackTrace);

  static void shout(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _logger.shout(message, error, stackTrace);

  /// 获取日志级别处理器实例
  static LogLevelHandler getLevelHandler() {
    if (!_initialized) {
      throw StateError('AppLogger 尚未初始化');
    }
    return _levelHandler;
  }
}

/// 日志处理器配置
class LoggerHandler {
  static bool writeToFile = true;
  static bool _initialized = false;
  static late LogWriter _logWriter;

  /// 初始化日志处理器
  static Future<void> init(String loggerName) async {
    if (_initialized) return;

    _logWriter = await LogWriter.init();

    Logger.root.level = Level.ALL; // 设置为ALL，让具体的过滤在onRecord中处理
    Logger.root.onRecord.listen((record) async {
      // 检查控制台打印级别
      final printLevel =
          AppLogger._levelHandler.getLoggerPrintLevel(record.loggerName) ??
              Level.INFO;
      if (record.level.value >= printLevel.value) {
        // 打印到控制台
        final time = '${record.time.hour.toString().padLeft(2, '0')}:'
            '${record.time.minute.toString().padLeft(2, '0')}:'
            '${record.time.second.toString().padLeft(2, '0')}';
        final level = record.level.name[0]; // 只取第一个字母
        final message = record.message;
        var output = '[$time] $level ${record.loggerName}: $message';

        if (record.error != null) {
          output += '\nError: ${record.error}';
        }
        if (record.stackTrace != null) {
          output += '\n${record.stackTrace}';
        }

        print(output);
      }

      // 检查文件写入级别
      if (writeToFile) {
        final writeLevel =
            AppLogger._levelHandler.getLoggerWriteLevel(record.loggerName) ??
                Level.WARNING;
        if (record.level.value >= writeLevel.value) {
          await _logWriter.writeLog(record);
        }
      }
    });

    _initialized = true;
  }
}
