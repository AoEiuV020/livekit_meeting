import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'meeting_flutter_platform_interface.dart';

/// An implementation of [MeetingFlutterPlatform] that uses method channels.
class MethodChannelMeetingFlutter extends MeetingFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('meeting_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
