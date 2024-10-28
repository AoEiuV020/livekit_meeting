import 'package:json_rpc_2/json_rpc_2.dart';

import 'service.dart';

class JsonRpcService implements Service {
  Server rpcServer;
  Client rpcClient;

  JsonRpcService(this.rpcServer, this.rpcClient);
  @override
  void registerMethod(String method, Function callback) {
    rpcServer.registerMethod(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) {
    return rpcClient.sendRequest(method, parameters);
  }
}
