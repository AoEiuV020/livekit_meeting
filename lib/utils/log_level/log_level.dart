import 'package:logging/logging.dart';

import 'log_level_io.dart' if (dart.library.html) 'log_level_web.dart';

/// 日志级别处理器基类
abstract class LogLevelHandler {
  /// 初始化日志级别处理器
  Future<void> init();

  /// 获取指定logger的控制台打印日志级别
  /// 返回null表示不打印
  Level? getLoggerPrintLevel(String loggerName);

  /// 获取指定logger的文件写入日志级别
  /// 返回null表示不写入文件
  Level? getLoggerWriteLevel(String loggerName);

  /// 获取日志配置内容
  Future<String> getConfig();

  /// 保存日志配置内容
  Future<void> saveConfig(String content);

  /// 根据平台返回具体实现
  static Future<LogLevelHandler> create() async {
    final handler = LogLevelHandlerImpl();
    await handler.init();
    return handler;
  }
}
