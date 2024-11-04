import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'options/parse.dart';
import 'rpc/external_api.dart';
import 'utils.dart';

void meetingMain(List<String> args) async {
  final format = DateFormat('HH:mm:ss');
  // configure logs for debugging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '${format.format(record.time)}: ${record.loggerName}: ${record.level.name} ${record.message}');
  });

  List<InheritedProvider> providerList;
  try {
    providerList = await parseGlobalOptions(args);
  } catch (error, stackTrace) {
    print('Could not parse global options: $error\n$stackTrace');
    // 这里如果直接崩溃的话连窗口都没有，啥也看不到， 所以强制不崩溃，
    providerList = [];
  }

  WidgetsFlutterBinding.ensureInitialized();

  if (lkPlatformIsDesktop()) {
    await FlutterWindowClose.setWindowShouldCloseHandler(() async {
      await onWindowShouldClose?.call();
      return true;
    });
  }

  await ExternalApi.instance.init();

  runApp(MultiProvider(
    providers: providerList,
    child: const MeetingApp(),
  ));
}
