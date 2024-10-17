// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'meeting_flutter_platform_interface.dart';

/// A web implementation of the MeetingFlutterPlatform of the MeetingFlutter plugin.
class MeetingFlutterWeb extends MeetingFlutterPlatform {
  /// Constructs a MeetingFlutterWeb
  MeetingFlutterWeb();

  static void registerWith(Registrar registrar) {
    MeetingFlutterPlatform.instance = MeetingFlutterWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
