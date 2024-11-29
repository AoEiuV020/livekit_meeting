import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 获取设备名称
  ///
  /// 返回示例：
  /// - iOS: "iPhone"
  /// - Android: "Samsung"
  /// - macOS: "张三的MacBook Pro"
  /// - Windows: "DESKTOP-ABC123"
  /// - Linux: "ubuntu"
  /// - Web: "chrome", "firefox", "safari"
  static Future<String> getDeviceName() async {
    if (UniversalPlatform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.name;
    } else if (UniversalPlatform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.brand;
    } else if (UniversalPlatform.isMacOS) {
      final macInfo = await _deviceInfo.macOsInfo;
      return macInfo.computerName;
    } else if (UniversalPlatform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      return windowsInfo.computerName;
    } else if (UniversalPlatform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      return linuxInfo.name;
    } else if (UniversalPlatform.isWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return webInfo.browserName.name;
    }
    return 'unknown';
  }

  /// 获取设备型号
  ///
  /// 返回示例：
  /// - iOS: "iPhone13,2" (iPhone 12)
  /// - Android: "SM-G998B" (Galaxy S21 Ultra)
  /// - macOS: "MacBookPro17,1"
  /// - Windows: "Windows 10 Pro"
  /// - Linux: "12345678" (machineId前8位)
  /// - Web: "MacIntel_5.0 (Macintosh; Intel Mac OS X 10_15_7)"
  static Future<String> getDeviceModel() async {
    if (UniversalPlatform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.model;
    } else if (UniversalPlatform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (UniversalPlatform.isMacOS) {
      final macInfo = await _deviceInfo.macOsInfo;
      return macInfo.model;
    } else if (UniversalPlatform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      return windowsInfo.productName;
    } else if (UniversalPlatform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      return linuxInfo.machineId?.substring(0, 8) ?? 'unknown';
    } else if (UniversalPlatform.isWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return '${webInfo.platform ?? "unknown"}_${webInfo.appVersion ?? "unknown"}';
    }
    return 'unknown';
  }

  /// 获取完整的设备标识，格式为: 设备名_型号
  ///
  /// 返回示例：
  /// - iOS: "iPhone_iPhone13,2"
  /// - Android: "Samsung_SM-G998B"
  /// - macOS: "张三的MacBook Pro_MacBookPro17,1"
  /// - Windows: "DESKTOP-ABC123_Windows 10 Pro"
  /// - Linux: "ubuntu_12345678"
  /// - Web: "chrome_MacIntel_5.0 (Macintosh; Intel Mac OS X 10_15_7)"
  static Future<String> getDeviceIdentifier() async {
    final name = await getDeviceName();
    final model = await getDeviceModel();
    return '${name}_$model';
  }
}
