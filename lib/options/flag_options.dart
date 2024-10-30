import 'package:flutter/foundation.dart';

class FlagOptions extends ChangeNotifier {
  ButtonFlagOptions button = ButtonFlagOptions();
}

class ButtonFlagOptions extends ChangeNotifier {
  bool disableAudio = false;
  bool disableVideo = false;
  bool disableScreenShare = false;
  bool disableHangup = false;
  void updateFlags() {
    notifyListeners();
  }
}
