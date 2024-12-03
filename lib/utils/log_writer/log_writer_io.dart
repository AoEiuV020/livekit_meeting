import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'log_writer.dart';

/// 文件系统日志写入器实现
class LogWriterImpl implements LogWriter {
  final File _logFile;

  LogWriterImpl._(this._logFile);

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

    return LogWriterImpl._(logFile);
  }

  @override
  Future<void> writeLog(LogRecord record) async {
    try {
      final logMessage =
          '${record.time}: ${record.level.name}: ${record.message}\n'
          '${record.error != null ? 'Error: ${record.error}\n' : ''}'
          '${record.stackTrace != null ? 'Stack trace:\n${record.stackTrace}\n' : ''}';

      await _logFile.writeAsString(
        logMessage,
        mode: FileMode.append,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Failed to write log to file: $e');
    }
  }
}
