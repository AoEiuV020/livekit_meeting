import 'package:json_rpc_2/json_rpc_2.dart';

import 'channel_service.dart';

class MeetingRpc {
  static final MeetingRpc _instance = MeetingRpc._internal();
  static MeetingRpc get instance => _instance;
  MeetingRpc._internal() {
    channel = ChannelService();
  }

  Server? rpcServer;
  Client? rpcClient;
  ChannelService? channel;

  void registerMethod(String method, Function callback) {
    rpcServer?.registerMethod(method, callback);
    channel?.registerMethod(method, callback);
  }

  /// parameters只能是List或者Map，
  Future sendRequest(String method, [dynamic parameters]) {
    return rpcClient?.sendRequest(method, parameters) ??
        channel?.sendRequest(method, parameters) ??
        Future.error('Not connected');
  }
}
