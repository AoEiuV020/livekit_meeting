import 'dart:async';

import 'package:flutter/services.dart';

import 'package:stream_channel/stream_channel.dart';

import 'meeting_flutter_platform_interface.dart';
import 'rpc/json_rpc_service.dart';

/// A web implementation of the MeetingFlutterPlatform of the MeetingFlutter plugin.
class MeetingFlutterJsonRpcMethodChannel extends MeetingFlutterPlatform {
  static const methodName = 'json-rpc-2.0';
  final JsonRpcService jsonRpcService;

  factory MeetingFlutterJsonRpcMethodChannel() {
    const methodChannel = MethodChannel('meeting_flutter');
    final StreamController<String> inputController =
        StreamController<String>.broadcast();
    final StreamController<String> outputController =
        StreamController<String>.broadcast();
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == methodName) {
        inputController.add(call.arguments as String);
      }
    });

    outputController.stream
        .listen((s) => methodChannel.invokeMethod(methodName, s));
    final channel =
        StreamChannel(inputController.stream, outputController.sink);
    final jsonRpcService = JsonRpcService.fromSingleStream(channel);
    return MeetingFlutterJsonRpcMethodChannel._(jsonRpcService);
  }

  MeetingFlutterJsonRpcMethodChannel._(this.jsonRpcService) {
    jsonRpcService.listen();
  }

  static void registerWith() {
    MeetingFlutterPlatform.instance = MeetingFlutterJsonRpcMethodChannel();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return null;
  }

  @override
  void registerMethod(String method, Function callback) {
    jsonRpcService.registerMethod(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) {
    return jsonRpcService.sendRequest(method, parameters);
  }

  @override
  void sendNotification(String method, parameters) {
    jsonRpcService.sendNotification(method, parameters);
  }
}
