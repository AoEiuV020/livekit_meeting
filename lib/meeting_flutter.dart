import 'meeting_flutter_platform_interface.dart';

class MeetingFlutter {
  Future<String?> getPlatformVersion() {
    return MeetingFlutterPlatform.instance.getPlatformVersion();
  }

  void registerMethod(String method, Function callback) {
    MeetingFlutterPlatform.instance.registerMethod(method, callback);
  }

  Future sendRequest(String method, parameters) {
    return MeetingFlutterPlatform.instance.sendRequest(method, parameters);
  }

  void sendNotification(String method, parameters) {
    MeetingFlutterPlatform.instance.sendNotification(method, parameters);
  }
}
