import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'log_level.dart';

/// 文件系统日志级别处理器实现
class LogLevelHandlerImpl implements LogLevelHandler {
  // 添加默认日志级别的存储
  (Level? print, Level? write)? _defaultLevels;

  // 存储logger名称对应的打印和写入级别
  final Map<String, (Level? print, Level? write)> _loggerLevels = {};

  late final File _configFile;

  @override
  Future<void> init() async {
    Directory supportDir;
    try {
      supportDir = await getApplicationSupportDirectory();
    } catch (e) {
      print('警告: 获取应用支持目录失败: $e');
      rethrow;
    }

    _configFile = File(path.join(supportDir.path, 'logger.conf'));
    print('读取日志配置: $_configFile');

    try {
      if (await _configFile.exists()) {
        final content = await getConfig();
        _parseConfig(content);
      } else {
        await _createDefaultConfig();
        final content = await getConfig();
        _parseConfig(content);
      }
    } catch (e) {
      print('警告: 处理配置文件失败: $e');
    }
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

  /// 解析单行配置
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

    final levelNames = levelPart.split(',');
    Level? printLevel;
    Level? writeLevel;

    // 解析打印级别
    if (levelNames.isNotEmpty) {
      printLevel = _parseLevel(levelNames[0].trim());
    }

    // 解析写入级别（如果存在）
    if (levelNames.length > 1) {
      writeLevel = _parseLevel(levelNames[1].trim());
    }

    // 如果loggerName是ALL，设置为默认级别
    if (loggerName == 'ALL') {
      _defaultLevels = (printLevel, writeLevel);
    } else {
      _loggerLevels[loggerName] = (printLevel, writeLevel);
    }
  }

  /// 创建默认配置文件
  Future<void> _createDefaultConfig() async {
    await _configFile.create(recursive: true);
    await _configFile.writeAsString('''# 日志级别配置
# 格式：LoggerName=PrintLevel[,WriteLevel]
# 可用级别：ALL, FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, SHOUT, OFF
# 特殊名称：ALL 表示设置默认日志级别
# 默认：PrintLevel=INFO, WriteLevel=WARNING
# WriteLevel不设置则使用默认级别WARNING
# 示例：
# ALL=INFO,WARNING   - 设置默认日志级别：打印INFO及以上级别，写入WARNING及以上级别
# App=INFO,WARNING   - 打印INFO及以上级别，写入WARNING及以上级别
# App=INFO           - 打印INFO及以上级别，写入使用默认级别(WARNING)
# App=INFO,OFF       - 只打印不写入文件
# App=OFF,WARNING    - 只写入文件不打印
# App=OFF,OFF        - 既不打印也不写入

# 设置默认日志级别
ALL=INFO,WARNING
# 特定logger的配置
MeetingRpc=ALL,FINE
''');
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
    return _loggerLevels[loggerName]?.$1 ?? _defaultLevels?.$1;
  }

  @override
  Level? getLoggerWriteLevel(String loggerName) {
    return _loggerLevels[loggerName]?.$2 ?? _defaultLevels?.$2;
  }

  @override
  Future<String> getConfig() async {
    try {
      if (await _configFile.exists()) {
        return await _configFile.readAsString();
      }
    } catch (e) {
      print('读取配置文件失败: $e');
    }
    return '';
  }

  @override
  Future<void> saveConfig(String content) async {
    try {
      await _configFile.writeAsString(content);
      // 清空缓存
      _defaultLevels = null;
      _loggerLevels.clear();
      // 重新解析配置
      _parseConfig(content);
    } catch (e) {
      print('保存配置文件失败: $e');
    }
  }
}
