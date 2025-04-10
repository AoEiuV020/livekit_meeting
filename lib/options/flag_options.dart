import 'package:flutter/foundation.dart';

class FlagOptions extends ChangeNotifier {
  bool autoConnect = false;
  bool startWithAudioMuted = false;
  bool startWithVideoMuted = false;
  bool keepWindowOpen = false;
  void updateFlags() {
    notifyListeners();
  }
}

class ButtonFlagOptions extends ChangeNotifier {
  bool disableAudio = false;
  bool disableVideo = false;
  bool disableScreenShare = false;
  bool disableHangUp = false;
  void updateFlags() {
    notifyListeners();
  }
}
