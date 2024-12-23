import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/livekit_service.dart';
import '../exts.dart';
import '../options/flag_options.dart';
import '../options/livekit_demo_options.dart';
import '../utils/device_utils.dart';
import '../widgets/text_field.dart';
import 'prejoin.dart';

class LivekitDemoPage extends StatefulWidget {
  //
  const LivekitDemoPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LivekitDemoPageState();
}

class _LivekitDemoPageState extends State<LivekitDemoPage> {
  //
  static const _storeKeyUri = 'uri';
  static const _storeKeyRoom = 'room';
  static const _storeKeyName = 'name';

  final _uriCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final bool _simulcast = true;
  final bool _adaptiveStream = true;
  final bool _dynacast = true;
  bool _busy = false;
  final bool _e2ee = false;
  final String _preferredCodec = 'H264';

  static final _logger = Logger('LivekitDemoPage');

  @override
  void initState() {
    super.initState();
    _logger.info('初始化 LivekitDemoPage');
    if (lkPlatformIs(PlatformType.android)) {
      _logger.info('检查 Android 权限');
      _checkPermissions();
    }
    _initInput();
  }

  void _initInput() async {
    final prefs = await SharedPreferences.getInstance();
    final options = context.read<LivekitDemoOptions>();
    _uriCtrl.text = options.serverUrl ??
        prefs.getString(_storeKeyUri) ??
        'https://meet.livekit.io';
    _roomCtrl.text = options.room ?? prefs.getString(_storeKeyRoom) ?? '123456';
    _nameCtrl.text =
        options.name ?? prefs.getString(_storeKeyName) ?? lkPlatform().name;
    if (context.read<FlagOptions>().autoConnect) {
      if (kDebugMode && options.name == 'vscode') {
        // 只在调试模式且name为vscode时使用设备名
        _nameCtrl.text = await DeviceUtils.getDeviceIdentifier();
      }
      await _connect(context);
    }
  }

  @override
  void dispose() {
    _uriCtrl.dispose();
    _roomCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      _logger.warning('蓝牙权限被禁用');
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      _logger.warning('蓝牙连接权限被禁用');
    }

    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      _logger.warning('相机权限被禁用');
    }

    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      _logger.warning('麦克风权限被禁用');
    }
  }

  // Save URL and Token
  Future<void> _writePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKeyUri, _uriCtrl.text);
    await prefs.setString(_storeKeyRoom, _roomCtrl.text);
    await prefs.setString(_storeKeyName, _nameCtrl.text);
  }

  Future<void> _connect(BuildContext ctx) async {
    try {
      _logger.info('开始连接过程');
      setState(() {
        _busy = true;
      });

      await _writePrefs();

      final url = _uriCtrl.text;
      final roomName = _roomCtrl.text;
      final name = _nameCtrl.text;

      _logger.info('正在连接房间: $roomName, URL: $url, 用户名: $name');

      final service = context.read<LivekitService>();
      service.baseUrl = url;
      final serverToken = await service.getToken(roomName, name);
      _logger.info('成功获取服务器令牌');

      var route = MaterialPageRoute(
          settings: const RouteSettings(name: '/prejoin'),
          builder: (_) => PreJoinPage(
                args: JoinArgs(
                  url: serverToken.serverUrl,
                  token: serverToken.token,
                  e2ee: _e2ee,
                  e2eeKey: null,
                  simulcast: _simulcast,
                  adaptiveStream: _adaptiveStream,
                  dynacast: _dynacast,
                  preferredCodec: _preferredCodec,
                  enableBackupVideoCodec:
                      ['VP9', 'AV1'].contains(_preferredCodec),
                ),
              ));
      unawaited(Navigator.pushReplacement(ctx, route));
    } catch (error) {
      _logger.severe('连接失败', error);
      await ctx.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: SvgPicture.asset(
                      'images/logo-dark.svg',
                      package: 'meeting_flutter',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Server URL',
                      ctrl: _uriCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Room',
                      ctrl: _roomCtrl,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: LKTextField(
                      label: 'Name',
                      ctrl: _nameCtrl,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _busy ? null : () => _connect(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        const Text('CONNECT'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
