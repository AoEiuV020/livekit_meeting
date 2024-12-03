import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'options/parse.dart';
import 'rpc/external_api.dart';
import 'utils.dart';
import 'utils/logger.dart';

void meetingMain(List<String> args) {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppLogger.init();

    List<InheritedProvider> providerList;
    try {
      providerList = await parseGlobalOptions(args);
    } catch (error, stackTrace) {
      AppLogger.severe('无法解析全局选项', error, stackTrace);
      // 这里如果直接崩溃的话连窗口都没有，啥也看不到， 所以强制不崩溃，
      providerList = [];
    }

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
  }, (error, stack) {
    AppLogger.shout('未捕获的错误: ', error, stack);
  });
}
