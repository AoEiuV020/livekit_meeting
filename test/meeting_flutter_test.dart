import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_flutter/meeting_flutter.dart';
import 'package:meeting_flutter/meeting_flutter_platform_interface.dart';
import 'package:meeting_flutter/meeting_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMeetingFlutterPlatform
    with MockPlatformInterfaceMixin
    implements MeetingFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MeetingFlutterPlatform initialPlatform =
      MeetingFlutterPlatform.instance;

  test('$MethodChannelMeetingFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMeetingFlutter>());
  });

  test('getPlatformVersion', () async {
    MeetingFlutter meetingFlutterPlugin = MeetingFlutter();
    MockMeetingFlutterPlatform fakePlatform = MockMeetingFlutterPlatform();
    MeetingFlutterPlatform.instance = fakePlatform;

    expect(await meetingFlutterPlugin.getPlatformVersion(), '42');
  });
}
