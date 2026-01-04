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

/// JS互操作：WebViewClientBridge全局对象
@JS('WebViewClientBridge')
extension type WebViewClientBridge._(JSObject _) implements JSObject {
  external void send(String message);
  external void addMessageListener(JSFunction listener);
  external void removeMessageListener(JSFunction listener);
  external bool isAvailable();
}

/// 获取WebViewClientBridge对象
@JS('WebViewClientBridge')
external WebViewClientBridge? get webViewClientBridge;

/// 检查WebViewClientBridge是否存在
bool hasWebViewClientBridge() {
  try {
    return webViewClientBridge != null;
  } catch (e) {
    return false;
  }
}

/// A web implementation of the MeetingFlutterPlatform of the MeetingFlutter plugin.
class MeetingFlutterWeb extends MeetingFlutterPlatform {
  final JsonRpcService jsonRpcService;

  /// Constructs a MeetingFlutterWeb
  factory MeetingFlutterWeb() {
    final StreamController<String> inputController =
        StreamController<String>.broadcast();
    final StreamController<String> outputController =
        StreamController<String>.broadcast();

    // 优先使用WebViewClientBridge（支持原生平台和iframe）
    if (hasWebViewClientBridge()) {
      final bridge = webViewClientBridge!;
      // 添加消息监听
      final listener = ((JSAny? data) {
        final message = data?.toString() ?? '{}';
        inputController.add(message);
      }).toJS;
      bridge.addMessageListener(listener);
      // 发送消息
      outputController.stream.listen((s) => bridge.send(s));
    } else if (isRunningInIframe()) {
      // 兼容旧的iframe处理逻辑
      final inputStream = web.window.onMessage
          .map((event) => event.data?.toJSBox.toDart.toString() ?? '{}');
      inputController.addStream(inputStream);
      final parent = web.window.parentCrossOrigin!;
      outputController.stream
          .listen((s) => parent.postMessage(s.toJS, '*'.toJS));
    }

    final channel =
        StreamChannel(inputController.stream, outputController.sink);
    final jsonRpcService = JsonRpcService.fromSingleStream(channel);
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

  @override
  void sendNotification(String method, parameters) {
    jsonRpcService.sendNotification(method, parameters);
  }

  static bool isRunningInIframe() {
    try {
      return web.window.self != web.window.top;
    } catch (e) {
      // 针对iframe内外跨域的情况， 无法访问top， 所以捕获异常， 返回true
      return true;
    }
  }
}
