import 'package:flutter/services.dart';

class ChannelService {
  static const methodChannel = MethodChannel('meeting_rpc');
  final Map<String, List<Function>> _handlers = {};

  ChannelService() {
    methodChannel.setMethodCallHandler((call) async {
      final handlers = _handlers[call.method];
      if (handlers != null) {
        for (final handler in handlers) {
          if (call.arguments == null) {
            handler();
          } else {
            await handler(call.arguments);
          }
        }
      } else {
        // 没有匹配的 handler，
        print('No handler found for method: ${call.method}');
      }
    });
  }

  void _addMethodCallHandler(String method, Function handler) {
    _handlers.putIfAbsent(method, () => []).add(handler);
  }

  void registerMethod(String method, Function callback) {
    _addMethodCallHandler(method, callback);
  }

  Future sendRequest(String method, parameters) {
    if (parameters is Iterable) parameters = parameters.toList();
    if (parameters is! Map && parameters is! List && parameters != null) {
      throw ArgumentError('Only maps and lists may be used as JSON-RPC '
          'parameters, was "$parameters".');
    }
    return methodChannel.invokeMethod(method, parameters);
  }
}
