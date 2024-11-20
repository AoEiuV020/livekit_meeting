import 'meeting_rpc.dart';

class ExternalApi {
  static final ExternalApi _instance = ExternalApi._internal();
  static ExternalApi get instance => _instance;
  ExternalApi._internal();

  bool interceptHangupEnabled = false;

  init() {
    registerMethod(ExternalApiMethod.setInterceptHangupEnabled,
        (params) => setInterceptHangupEnabled(params['enabled']));
  }

  void setInterceptHangupEnabled(bool enabled) {
    interceptHangupEnabled = enabled;
  }

  Future<bool> interceptHangUp() async {
    if (!interceptHangupEnabled) return false;
    final response = await MeetingRpc.instance.sendRequest('interceptHangUp');
    return response['hangUp'] as bool;
  }

  void onAudioMuteChanged(bool muted) {
    MeetingRpc.instance.sendRequest('onAudioMuteChanged', {'muted': muted});
  }

  void onVideoMuteChanged(bool muted) {
    MeetingRpc.instance.sendRequest('onVideoMuteChanged', {'muted': muted});
  }

  void onDisconnected() {
    MeetingRpc.instance.sendRequest('onDisconnected');
  }

  void registerMethod(ExternalApiMethod method, Function callback) {
    MeetingRpc.instance.registerMethod(method.name, callback);
  }

  void unregisterMethod(ExternalApiMethod method) {
    MeetingRpc.instance.unregisterMethod(method.name);
  }
}

enum ExternalApiMethod {
  setInterceptHangupEnabled,
  setAudioMute,
  setVideoMute,
  hangUp,
  toggleCamera,
}
