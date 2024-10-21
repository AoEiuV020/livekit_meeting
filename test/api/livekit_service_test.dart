import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_flutter/api/livekit_service.dart';

void main() {
  test('livekit getToken', () async {
    final service = LivekitService('https://meet.livekit.io');
    final serverToken = await service.getToken('123456', 'FlutterTest1');
    expect(serverToken, isNotNull);
    print(serverToken.serverUrl);
    print(serverToken.token);
  });
}
