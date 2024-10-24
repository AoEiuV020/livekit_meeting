import 'package:flutter/material.dart';

import 'pages/livekit_demo.dart';
import 'theme.dart';

class MeetingApp extends StatefulWidget {
  //
  const MeetingApp({
    super.key,
  });

  @override
  State<MeetingApp> createState() => _MeetingAppState();
}

class _MeetingAppState extends State<MeetingApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'LiveKit Flutter Example',
        theme: LiveKitTheme().buildThemeData(context),
        home: const LivekitDemoPage(),
      );
}
