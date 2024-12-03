import 'package:logging/logging.dart';

import 'log_writer_io.dart' if (dart.library.html) 'log_writer_web.dart';

/// 日志写入器基类
abstract class LogWriter {
  /// 写入日志记录
  Future<void> writeLog(LogRecord record);

  /// 根据平台返回具体实现
  static Future<LogWriter> init() {
    return LogWriterImpl.init();
  }
}
