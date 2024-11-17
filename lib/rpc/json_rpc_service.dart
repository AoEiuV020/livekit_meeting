import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:stream_channel/stream_channel.dart';

import 'service.dart';

class JsonRpcService implements Service {
  Server rpcServer;
  Client rpcClient;

  JsonRpcService(this.rpcServer, this.rpcClient);
  factory JsonRpcService.fromStream(
    StreamChannel<String> channelServer,
    StreamChannel<String> channelClient,
  ) {
    return JsonRpcService(Server(channelServer), Client(channelClient));
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
