import 'package:flutter/material.dart';

import 'pages/livekit_demo.dart';
import 'theme.dart';

class MeetingApp extends StatefulWidget {
  final List<String> args;

  //
  const MeetingApp(
    this.args, {
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
        home: LivekitDemoPage(widget.args),
      );
}
