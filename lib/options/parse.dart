import 'dart:convert';

import 'package:args/args.dart';

import 'global_options.dart';
import 'livekit_demo_options.dart';
import 'parse_util.dart' if (dart.library.html) 'parse_util_web.dart';

// example/build/macos/Build/Products/Debug/meeting_flutter_example.app/Contents/MacOS/meeting_flutter_example --autoConnect --serverUrl https://meet.livekit.io --room 123456 --name mac
// example\build\windows\x64\runner\Debug\meeting_flutter_example.exe --autoConnect --serverUrl https://meet.livekit.io --room 123456 --name pc
// ?autoConnect&serverUrl=https%3A%2F%2Fmeet.livekit.io&room=123456&name=web

Future<GlobalOptions> parseGlobalOptions(List<String> args) async {
  args = await prepareArgs(args);
  // ArgParser必须一次指定所有可能出现的选项， 出现未知选择就会报错，
  var parser = ArgParser()
    ..addOption('serverUrl')
    ..addOption('room')
    ..addOption('name')
    ..addOption('livekitDemoOptions')
    ..addFlag('autoConnect', defaultsTo: false);
  var results = parser.parse(args);
  final LivekitDemoOptions livekitDemoOptions;
  final bool autoConnect;
  if (results.wasParsed('livekitDemoOptions')) {
    livekitDemoOptions = LivekitDemoOptions.fromJson(
        utf8.decode(base64Decode(results['livekitDemoOptions'])));
    autoConnect = true;
  } else {
    livekitDemoOptions = LivekitDemoOptions(
      serverUrl: results['serverUrl'],
      room: results['room'],
      name: results['name'],
    );
    autoConnect = results.flag('autoConnect');
  }
  return GlobalOptions(
    autoConnect: autoConnect,
    livekitDemoOptions: livekitDemoOptions,
  );
}
