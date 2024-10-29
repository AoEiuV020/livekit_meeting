import 'meeting_rpc.dart';

class ExternalApi {
  static final ExternalApi _instance = ExternalApi._internal();
  static ExternalApi get instance => _instance;
  ExternalApi._internal();

  bool interceptHangupEnabled = false;

  init() {
    MeetingRpc.instance.registerMethod('setInterceptHangupEnabled',
        (params) => setInterceptHangupEnabled(params['enabled']));
  }

  void setInterceptHangupEnabled(bool enabled) {
    interceptHangupEnabled = enabled;
  }

  Future<bool> interceptHangup() async {
    if (!interceptHangupEnabled) return false;
    return await MeetingRpc.instance.sendRequest('interceptHangup');
  }

  void onAudioMuteChanged(bool muted) {
    MeetingRpc.instance.sendRequest('onAudioMuteChanged', {'muted': muted});
  }

  void onVideoMuteChanged(bool muted) {
    MeetingRpc.instance.sendRequest('onVideoMuteChanged', {'muted': muted});
  }

  void onHangup() {
    MeetingRpc.instance.sendRequest('onHangup');
  }
}
