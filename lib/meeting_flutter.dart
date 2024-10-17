
import 'meeting_flutter_platform_interface.dart';

class MeetingFlutter {
  Future<String?> getPlatformVersion() {
    return MeetingFlutterPlatform.instance.getPlatformVersion();
  }
}
