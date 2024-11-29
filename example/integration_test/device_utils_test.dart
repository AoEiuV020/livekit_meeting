import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meeting_flutter/utils/device_utils.dart';
import 'package:universal_platform/universal_platform.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('测试设备信息', (WidgetTester tester) async {
    // 获取并打印设备名称
    final deviceName = await DeviceUtils.getDeviceName();
    print('设备名称: $deviceName');
    expect(deviceName.isNotEmpty, true);
    expect(deviceName != 'unknown', true);

    // 获取并打印设备型号
    final deviceModel = await DeviceUtils.getDeviceModel();
    print('设备型号: $deviceModel');
    expect(deviceModel.isNotEmpty, true);
    expect(deviceModel != 'unknown', true);

    // 获取并打印完整设备标识
    final deviceIdentifier = await DeviceUtils.getDeviceIdentifier();
    print('设备标识: $deviceIdentifier');
    expect(deviceIdentifier.isNotEmpty, true);
    expect(deviceIdentifier.contains('_'), true);

    // 验证设备标识格式是否正确
    expect(deviceIdentifier, equals('${deviceName}_$deviceModel'));

    // 根据平台进行特定验证
    if (UniversalPlatform.isIOS) {
      expect(
          deviceModel.contains('iPhone') || deviceModel.contains('iPad'), true);
    } else if (UniversalPlatform.isAndroid) {
      // Android设备型号通常包含字母和数字
      expect(deviceModel.contains(RegExp(r'[A-Za-z0-9]')), true);
    } else if (UniversalPlatform.isMacOS) {
      expect(deviceModel.contains('Mac'), true);
    } else if (UniversalPlatform.isWindows) {
      expect(deviceModel.contains('Windows'), true);
    }
  });
}
