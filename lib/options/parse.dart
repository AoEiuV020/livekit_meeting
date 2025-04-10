import 'dart:convert';

import 'package:args/args.dart';
import 'package:provider/provider.dart';

import '../api/livekit_service.dart';
import '../meeting_flutter_json_rpc_method_channel.dart';
import 'flag_options.dart';
import 'livekit_demo_options.dart';
import 'parse_util.dart' if (dart.library.html) 'parse_util_web.dart';

// example/build/macos/Build/Products/Debug/meeting_flutter_example.app/Contents/MacOS/meeting_flutter_example --autoConnect --serverUrl https://meet.livekit.io --room 123456 --name mac
// example\build\windows\x64\runner\Debug\meeting_flutter_example.exe --autoConnect --serverUrl https://meet.livekit.io --room 123456 --name pc
// ?autoConnect&serverUrl=https%3A%2F%2Fmeet.livekit.io&room=123456&name=web

Future<ArgResults> parseArgs(List<String> args) async {
  ArgResults parseResult;
  // ArgParser必须一次指定所有可能出现的选项， 出现未知选择就会报错，
  var parser = ArgParser()
    ..addOption('serverUrl')
    ..addOption('room')
    ..addOption('name')
    ..addOption('livekitDemoOptions')
    ..addFlag('keepWindowOpen', defaultsTo: false)
    ..addFlag('jsonRpcMode', defaultsTo: false)
    ..addFlag('startWithAudioMuted', defaultsTo: false)
    ..addFlag('startWithVideoMuted', defaultsTo: false)
    ..addFlag('disableAudioMutedButton', defaultsTo: false)
    ..addFlag('disableVideoMutedButton', defaultsTo: false)
    ..addFlag('autoConnect', defaultsTo: false);
  try {
    args = await prepareArgs(args);
    parseResult = parser.parse(args);
  } catch (error, stackTrace) {
    print('Could not parse args: $error\n$stackTrace');
    parseResult = parser.parse([]);
  }
  return parseResult;
}

Future<List<InheritedProvider>> parseGlobalOptions(List<String> args) async {
  ArgResults parseResult = await parseArgs(args);
  List<InheritedProvider> result = [];

  if (parseResult.flag('jsonRpcMode')) {
    MeetingFlutterJsonRpcMethodChannel.registerWith();
  }
  FlagOptions flagOptions = FlagOptions();
  flagOptions.autoConnect = parseResult.flag('autoConnect');
  flagOptions.startWithAudioMuted = parseResult.flag('startWithAudioMuted');
  flagOptions.startWithVideoMuted = parseResult.flag('startWithVideoMuted');
  flagOptions.keepWindowOpen = parseResult.flag('keepWindowOpen');
  // Provider必须指定泛型，
  result.add(ChangeNotifierProvider<FlagOptions>.value(value: flagOptions));

  ButtonFlagOptions buttonFlagOptions = ButtonFlagOptions();
  buttonFlagOptions.disableAudio = parseResult.flag('disableAudioMutedButton');
  buttonFlagOptions.disableVideo = parseResult.flag('disableVideoMutedButton');
  result.add(ChangeNotifierProvider<ButtonFlagOptions>.value(
      value: buttonFlagOptions));

  LivekitDemoOptions livekitDemoOptions;
  if (parseResult.wasParsed('livekitDemoOptions')) {
    livekitDemoOptions = LivekitDemoOptions.fromJson(
        utf8.decode(base64Decode(parseResult['livekitDemoOptions'])));
    flagOptions.autoConnect = true;
  } else {
    livekitDemoOptions = LivekitDemoOptions(
      serverUrl: parseResult['serverUrl'],
      room: parseResult['room'],
      name: parseResult['name'],
    );
  }
  result.add(Provider<LivekitDemoOptions>.value(value: livekitDemoOptions));

  final livekitService = LivekitService(livekitDemoOptions.serverUrl ?? '');
  result.add(Provider<LivekitService>.value(value: livekitService));

  return result;
}
