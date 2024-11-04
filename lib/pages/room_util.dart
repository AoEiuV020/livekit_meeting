import 'package:flutter/services.dart';

import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:livekit_client/livekit_client.dart';

roomCloseApp() {
  if (lkPlatformIsDesktop()) {
    FlutterWindowClose.closeWindow();
  } else {
    SystemNavigator.pop();
  }
}
