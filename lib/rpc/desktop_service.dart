import 'dart:async';

import 'package:logging/logging.dart';

import 'exception_converter.dart';
import 'exceptions.dart';
import 'json_rpc_service.dart';
import 'service.dart';
import 'web_socket_server.dart';

/// 使用webSocket封装成jsonRpc实现的桌面端交互服务，
/// 使用前需要先启动WebSocket服务器，
/// 使用后需要调用dispose方法释放资源。
class DesktopService implements Service {
  final logger = Logger('DesktopService');
  late final JsonRpcService? _rpcService;
  late final WebSocketServer _webSocketServer;

  DesktopService() {
    _webSocketServer = WebSocketServer.instance;
    final channel = _webSocketServer.channel;
    _rpcService =
        channel == null ? null : JsonRpcService.fromSingleStream(channel);
    _rpcService?.listen();
  }

  @override
  void registerMethod(String method, Function callback) {
    _rpcService?.registerMethod(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) async {
    try {
      if (_rpcService == null) {
        throw InternalError('rpc服务未启动');
      }
      return await _rpcService.sendRequest(method, parameters);
    } catch (e) {
      logger.severe('发送请求时出错: $e');
      throw RpcExceptionConverter.convertJsonRpcException(e);
    }
  }

  @override
  void sendNotification(String method, parameters) {
    try {
      _rpcService?.sendNotification(method, parameters);
    } catch (e) {
      logger.severe('发送通知时出错: $e');
      throw RpcExceptionConverter.convertJsonRpcException(e);
    }
  }

  Future<void> dispose() async {
    await _webSocketServer.dispose();
  }
}
