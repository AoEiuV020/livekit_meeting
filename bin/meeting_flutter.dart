// ignore_for_file: avoid_print

import 'package:args/args.dart';

void main(List<String> arguments) {
  print('Received arguments:');
  for (var arg in arguments) {
    print(arg);
  }
  var parser = ArgParser()
    ..addOption('web-browser-flag')
    ..addOption('web-port')
    ..addOption('web-launch-url')
    ..addMultiOption('dart-entrypoint-args');
  var results = parser.parse(arguments);
  final map = {for (var key in results.options) key: results[key]};
  print(map);
  map.forEach((key, value) {
    print('--$key=$value');
  });
}
