import 'meeting_rpc.dart';

class ExternalApi {
  static final ExternalApi _instance = ExternalApi._internal();
  static ExternalApi get instance => _instance;
  ExternalApi._internal();

  bool interceptHangUpEnabled = false;

  init() {
    registerMethod(ExternalApiMethod.setInterceptHangUpEnabled,
        (params) => setInterceptHangUpEnabled(params['enabled']));
  }

  void setInterceptHangUpEnabled(bool enabled) {
    interceptHangUpEnabled = enabled;
  }

  Future<bool> interceptHangUp() async {
    if (!interceptHangUpEnabled) return false;
    final response = await MeetingRpc.instance.sendRequest('interceptHangUp');
    return response['intercept'] as bool;
  }

  void onAudioMuteChanged(bool muted) {
    MeetingRpc.instance
        .sendNotification('onAudioMuteChanged', {'muted': muted});
  }

  void onVideoMuteChanged(bool muted) {
    MeetingRpc.instance
        .sendNotification('onVideoMuteChanged', {'muted': muted});
  }

  void onDisconnected() {
    MeetingRpc.instance.sendNotification('onDisconnected');
  }

  void registerMethod(ExternalApiMethod method, Function callback) {
    MeetingRpc.instance.registerMethod(method.name, callback);
  }

  void unregisterMethod(ExternalApiMethod method) {
    MeetingRpc.instance.unregisterMethod(method.name);
  }
}

enum ExternalApiMethod {
  setInterceptHangUpEnabled,
  setAudioMute,
  setVideoMute,
  hangUp,
  toggleCamera,
}
