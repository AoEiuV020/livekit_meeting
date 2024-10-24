import 'package:args/args.dart';
import 'package:flutter/foundation.dart';

import 'livekit_demo_options.dart';

Future<LivekitDemoOptions?> parseLiveKitOptionsOptions(
    List<String> args) async {
  if (kIsWeb) return null;
  var parser = ArgParser();
  parser.addOption('serverUrl');
  parser.addOption('room');
  parser.addOption('name');
  // example/build/macos/Build/Products/Debug/meeting_flutter_example.app/Contents/MacOS/meeting_flutter_example --serverUrl https://meet.livekit.io --room 123456 --name mac
  // example\build\windows\x64\runner\Debug\meeting_flutter_example.exe --serverUrl https://meet.livekit.io --room 123456 --name pc
  var results = parser.parse(args);
  return LivekitDemoOptions(
    serverUrl: results['serverUrl'],
    room: results['room'],
    name: results['name'],
  );
}
