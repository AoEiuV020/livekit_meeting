// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:logging/logging.dart';

import 'log_writer/log_writer.dart';

/// 应用日志记录器
class AppLogger {
  static final Logger _logger = Logger('MeetingFlutter');
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
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

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) async {
      // 打印到控制台
      log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
        error: record.error,
        stackTrace: record.stackTrace,
      );
      // 只将 AdbTools 的日志写入文件
      if (writeToFile && record.loggerName == loggerName) {
        await _logWriter.writeLog(record);
      }
    });

    _initialized = true;
  }
}
