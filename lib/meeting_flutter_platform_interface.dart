import 'package:logging/logging.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'meeting_flutter_method_channel.dart';

final logger = Logger('MeetingFlutterPlatform');

abstract class MeetingFlutterPlatform extends PlatformInterface {
  /// Constructs a MeetingFlutterPlatform.
  MeetingFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static MeetingFlutterPlatform _instance = MethodChannelMeetingFlutter();

  /// The default instance of [MeetingFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelMeetingFlutter].
  static MeetingFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MeetingFlutterPlatform] when
  /// they register themselves.
  static set instance(MeetingFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void registerMethod(String method, Function callback) {
    throw UnimplementedError('registerMethod() has not been implemented.');
  }

  Future sendRequest(String method, parameters) {
    throw UnimplementedError('sendRequest() has not been implemented.');
  }

  void sendNotification(String method, parameters) {
    throw UnimplementedError('sendNotification() has not been implemented.');
  }
}
