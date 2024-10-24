import 'package:livekit_client/livekit_client.dart';

extension MediaDeviceExt on MediaDevice {
  /// 针对安卓设备添加判断前后摄像头，靠谱，因为label本来就是这样拼接出来的，
  /// 具体安卓代码在 com.cloudwebrtc.webrtc.MethodCallHandlerImpl#getCameraInfo
  /// 其他平台暂没办法， flutter层丢弃了前后摄像头信息，也没看到方法获取这些，可能需要一个一个添加，
  bool get front => label.contains('Facing front');
}
