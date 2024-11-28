// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:developer';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:json_rpc_2/src/utils.dart';
import 'package:stream_channel/stream_channel.dart';

import 'json_rpc_validator.dart';
import 'service.dart';

class JsonRpcService implements Service {
  Server rpcServer;
  Client rpcClient;

  JsonRpcService(this.rpcServer, this.rpcClient);

  /// 从两个独立的stream创建
  /// 不能是同一个stream， 否则会死循环
  factory JsonRpcService.fromStream(
    StreamChannel<String> channelServer,
    StreamChannel<String> channelClient,
  ) {
    return JsonRpcService(Server(channelServer), Client(channelClient));
  }

  /// 从单个stream创建
  /// 通过过滤分离出server和client各自需要的消息
  factory JsonRpcService.fromSingleStream(
    StreamChannel<String> channel,
  ) {
    final jsonChannel =
        jsonDocument.bind(channel).transform(respondToFormatExceptions);

    // 为server和client创建独立的controller，使用Object类型以支持所有消息类型
    final serverController = StreamController<Object?>();
    final clientController = StreamController<Object?>();

    // 监听原始消息并分发
    jsonChannel.stream.listen((message) {
      if (JsonRpcValidator.isJsonRpcRequest(message) ||
          JsonRpcValidator.isJsonRpcRequests(message)) {
        serverController.add(message);
      } else if (JsonRpcValidator.isJsonRpcResponse(message) ||
          JsonRpcValidator.isJsonRpcResponses(message)) {
        clientController.add(message);
      } else {
        // 其他消息类型， 直接丢弃
        log('unsupported message: $message');
      }
    });

    // 创建server和client的channel
    final serverChannel = StreamChannel(
      serverController.stream,
      jsonChannel.sink,
    );

    final clientChannel = StreamChannel(
      clientController.stream,
      jsonChannel.sink,
    );

    return JsonRpcService(
      Server.withoutJson(serverChannel),
      Client.withoutJson(clientChannel),
    );
  }

  @override
  void registerMethod(String method, Function callback) {
    rpcServer.registerMethod(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) {
    return rpcClient.sendRequest(method, parameters);
  }

  listen() {
    unawaited(rpcClient.listen());
    unawaited(rpcServer.listen());
  }
}
