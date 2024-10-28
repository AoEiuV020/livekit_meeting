import 'channel_service.dart';
import 'service.dart';

class MeetingRpc {
  static final MeetingRpc _instance = MeetingRpc._internal();
  static MeetingRpc get instance => _instance;
  MeetingRpc._internal() {
    service = ChannelService();
  }

  Service? service;

  void registerMethod(String method, Function callback) {
    service?.registerMethod(method, callback);
  }

  /// parameters只能是List或者Map，
  Future sendRequest(String method, [dynamic parameters]) {
    return service?.sendRequest(method, parameters) ??
        Future.error('Not connected');
  }
}
