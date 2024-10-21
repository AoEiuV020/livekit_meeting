import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'pages/livekit_demo.dart';
import 'pages/prejoin.dart';
import 'rpc/external_api.dart';
import 'rpc/meeting_rpc.dart';
import 'utils.dart';
import 'theme.dart';

void meetingMain() async {
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

  runApp(const LiveKitExampleApp());
}

class LiveKitExampleApp extends StatefulWidget {
  //
  const LiveKitExampleApp({
    super.key,
  });

  @override
  State<LiveKitExampleApp> createState() => _LiveKitExampleAppState();
}

class _LiveKitExampleAppState extends State<LiveKitExampleApp> {
  final bool _simulcast = true;
  final bool _adaptiveStream = true;
  final bool _dynacast = true;
  final bool _e2ee = false;
  final String _preferredCodec = 'H264';
  @override
  void initState() {
    super.initState();
    MeetingRpc.instance.registerMethod('joinLiveKit', (params) {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute(
            builder: (_) => PreJoinPage(
                  args: JoinArgs(
                    url: params['url'],
                    token: params['token'],
                    e2ee: _e2ee,
                    e2eeKey: null,
                    simulcast: _simulcast,
                    adaptiveStream: _adaptiveStream,
                    dynacast: _dynacast,
                    preferredCodec: _preferredCodec,
                    enableBackupVideoCodec:
                        ['VP9', 'AV1'].contains(_preferredCodec),
                  ),
                )),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'LiveKit Flutter Example',
        theme: LiveKitTheme().buildThemeData(context),
        home: const LivekitDemoPage(),
      );
}
