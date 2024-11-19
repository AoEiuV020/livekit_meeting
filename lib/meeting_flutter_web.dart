// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web/web.dart' as web;

import 'meeting_flutter_platform_interface.dart';
import 'rpc/json_rpc_service.dart';

/// A web implementation of the MeetingFlutterPlatform of the MeetingFlutter plugin.
class MeetingFlutterWeb extends MeetingFlutterPlatform {
  final JsonRpcService jsonRpcService;

  /// Constructs a MeetingFlutterWeb
  factory MeetingFlutterWeb() {
    final StreamController<String> inputController =
        StreamController<String>.broadcast();
    final StreamController<String> outputController =
        StreamController<String>.broadcast();
    final inputStream = web.window.onMessage
        .map((event) => event.data?.toJSBox.toDart.toString() ?? '{}');
    inputController.addStream(inputStream);
    final parent = web.window.parentCrossOrigin?.parent;
    outputController.stream.listen((s) =>
        parent?.postMessage(s.toJS, '*'.toJS));
    final channel =
        StreamChannel(inputController.stream, outputController.sink);
    // 用两次， 收消息时json解析会有两次，功能不影响，
    final jsonRpcService = JsonRpcService.fromStream(channel, channel);
    return MeetingFlutterWeb._(jsonRpcService);
  }

  MeetingFlutterWeb._(this.jsonRpcService) {
    jsonRpcService.listen();
  }

  static void registerWith(Registrar registrar) {
    MeetingFlutterPlatform.instance = MeetingFlutterWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  @override
  void registerMethod(String method, Function callback) {
    jsonRpcService.registerMethod(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) {
    return jsonRpcService.sendRequest(method, parameters);
  }
}
