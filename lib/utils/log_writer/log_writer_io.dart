import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'log_writer.dart';

/// 文件系统日志写入器实现
class LogWriterImpl implements LogWriter {
  final File _logFile;
  late final IOSink _sink;
  bool _initialized = false;

  LogWriterImpl._(this._logFile);

  Future<void> _initSink() async {
    if (!_initialized) {
      _sink = _logFile.openWrite(mode: FileMode.append);
      _initialized = true;
    }
  }

  /// 获取日志目录
  /// 在不同平台下 getApplicationSupportDirectory 返回的路径：
  /// - macOS: ~/Library/Application Support/<app name>
  /// - Linux: ~/.local/share/<app name>
  /// - Windows: C:\Users\<username>\AppData\Roaming\<app name>
  /// - iOS: ~/Library/Application Support/<app name>
  /// - Android: /data/data/<package name>/files
  static Future<LogWriter> init() async {
    final supportDir = await getApplicationSupportDirectory();
    final logDir = Directory(path.join(supportDir.path, 'logs'));

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    final logFile = File(path.join(logDir.path, '$today.log'));
    final writer = LogWriterImpl._(logFile);
    await writer._initSink();
    return writer;
  }

  @override
  Future<void> writeLog(LogRecord record) async {
    try {
      final logMessage =
          '${record.time}: ${record.level.name}: [${record.loggerName}] ${record.message}\n'
          '${record.error != null ? 'Error: ${record.error}\n' : ''}'
          '${record.stackTrace != null ? 'Stack trace:\n${record.stackTrace}\n' : ''}';

      _sink.write(logMessage);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to write log to file: $e');
    }
  }

  /// 关闭日志文件
  Future<void> dispose() async {
    if (_initialized) {
      await _sink.flush();
      await _sink.close();
      _initialized = false;
    }
  }
}
