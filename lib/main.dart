import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'app.dart';
import 'rpc/external_api.dart';
import 'utils.dart';

void meetingMain(List<String> args) async {
  final format = DateFormat('HH:mm:ss');
  // configure logs for debugging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${format.format(record.time)}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  if (lkPlatformIsDesktop()) {
    await FlutterWindowClose.setWindowShouldCloseHandler(() async {
      await onWindowShouldClose?.call();
      return true;
    });
  }

  await ExternalApi.instance.init();

  runApp(MeetingApp(args));
}
