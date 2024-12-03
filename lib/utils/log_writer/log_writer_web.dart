import 'package:logging/logging.dart';

import 'log_writer.dart';

/// Web平台的日志写入器实现（空实现）
class LogWriterImpl implements LogWriter {
  LogWriterImpl._();

  static Future<LogWriter> init() async {
    return LogWriterImpl._();
  }

  @override
  Future<void> writeLog(LogRecord record) async {
    // Web平台不执行文件写入
    return;
  }
}
