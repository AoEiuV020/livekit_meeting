import 'package:args/args.dart';

import 'global_options.dart';
import 'livekit_demo_options.dart';

// example/build/macos/Build/Products/Debug/meeting_flutter_example.app/Contents/MacOS/meeting_flutter_example --autoConnect --serverUrl https://meet.livekit.io --room 123456 --name mac
// example\build\windows\x64\runner\Debug\meeting_flutter_example.exe --autoConnect --serverUrl https://meet.livekit.io --room 123456 --name pc

Future<GlobalOptions> parseGlobalOptions(List<String> args) async {
  // ArgParser必须一次指定所有可能出现的选项， 出现未知选择就会报错，
  var parser = ArgParser()
    ..addOption('serverUrl')
    ..addOption('room')
    ..addOption('name')
    ..addFlag('autoConnect', defaultsTo: false);
  var results = parser.parse(args);
  final options = LivekitDemoOptions(
    serverUrl: results['serverUrl'],
    room: results['room'],
    name: results['name'],
  );
  return GlobalOptions(
    autoConnect: results.flag('autoConnect'),
    livekitDemoOptions: options,
  );
}
