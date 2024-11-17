import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'meeting_flutter_platform_interface.dart';

/// An implementation of [MeetingFlutterPlatform] that uses method channels.
class MethodChannelMeetingFlutter extends MeetingFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('meeting_flutter');
  final Map<String, Function> _handlers = {};

  MethodChannelMeetingFlutter() {
    methodChannel.setMethodCallHandler((call) async {
      final handler = _handlers[call.method];
      if (handler != null) {
        if (call.arguments == null) {
          return await handler();
        } else {
          return await handler(call.arguments);
        }
      } else {
        // 没有匹配的 handler，
        logger.severe('No handler found for method: ${call.method}');
      }
    });
  }

  void _addMethodCallHandler(String method, Function handler) {
    _handlers[method] = handler;
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void registerMethod(String method, Function callback) {
    logger.fine('registerMethod: $method');
    _addMethodCallHandler(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) {
    logger.fine('sendRequest: $method, $parameters');
    return methodChannel.invokeMethod(method, parameters);
  }
}
