import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'log_level.dart';

/// Web平台的日志级别处理器实现
class LogLevelHandlerImpl implements LogLevelHandler {
  static const _configKey = 'logger_config';
  late final SharedPreferences _prefs;

  // 添加默认日志级别的存储
  Level? _defaultPrintLevel;
  // 存储logger名称对应的打印级别
  final Map<String, Level?> _loggerLevels = {};

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    String config = await getConfig();
    if (config.isEmpty) {
      config = _getDefaultConfig();
      await saveConfig(config);
    }
    _parseConfig(config);
  }

  String _getDefaultConfig() {
    return '''# 日志级别配置
# 格式：LoggerName=PrintLevel
# 可用级别：ALL, FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, SHOUT, OFF
# 特殊名称：ALL 表示设置默认日志级别
# 默认：PrintLevel=INFO
# 示例：
# ALL=INFO     - 设置默认日志级别：打印INFO及以上级别
# App=INFO     - 打印INFO及以上级别
# App=OFF      - 不打印日志

# 设置默认日志级别
ALL=INFO
# 特定logger的配置
MeetingRpc=ALL
''';
  }

  void _parseConfig(String config) {
    final lines = config.split('\n');
    for (final line in lines) {
      try {
        _parseLine(line);
      } catch (e) {
        print('警告: 解析配置行失败: "$line": $e');
        continue;
      }
    }
  }

  void _parseLine(String line) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) return;

    final parts = trimmedLine.split('=');
    if (parts.length != 2) {
      print('警告: 无效的配置行格式: "$line"');
      return;
    }

    final loggerName = parts[0].trim();
    if (loggerName.isEmpty) {
      print('警告: logger名称为空: "$line"');
      return;
    }

    final levelPart = parts[1].trim();
    if (levelPart.isEmpty) {
      print('警告: 日志级别为空: "$line"');
      return;
    }

    // 只取第一个逗号前的部分作为打印级别
    final printLevelName = levelPart.split(',')[0].trim();
    final printLevel = _parseLevel(printLevelName);

    // Web平台只处理打印级别
    if (loggerName == 'ALL') {
      _defaultPrintLevel = printLevel;
    } else {
      _loggerLevels[loggerName] = printLevel;
    }
  }

  Level? _parseLevel(String levelName) {
    try {
      final name = levelName.trim().toUpperCase();
      if (name.isEmpty) {
        print('警告: 日志级别名称为空');
        return Level.INFO;
      }
      return Level.LEVELS.firstWhere(
        (level) => level.name == name,
        orElse: () {
          print('警告: 未知的日志级别: "$levelName"，使用默认级别INFO');
          return Level.INFO;
        },
      );
    } catch (e) {
      print('警告: 解析日志级别失败: "$levelName": $e');
      return Level.INFO;
    }
  }

  @override
  Level? getLoggerPrintLevel(String loggerName) {
    return _loggerLevels[loggerName] ?? _defaultPrintLevel ?? Level.INFO;
  }

  @override
  Level? getLoggerWriteLevel(String loggerName) {
    return null; // Web平台不支持写入文件
  }

  @override
  Future<String> getConfig() async {
    return _prefs.getString(_configKey) ?? '';
  }

  @override
  Future<void> saveConfig(String content) async {
    await _prefs.setString(_configKey, content);
    // 清空缓存
    _defaultPrintLevel = null;
    _loggerLevels.clear();
    // 重新解析配置
    _parseConfig(content);
  }
}
