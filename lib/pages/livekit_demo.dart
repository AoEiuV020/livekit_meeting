import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';
import '../api/livekit_service.dart';
import '../options/livekit_demo_options.dart';
import 'prejoin.dart';
import '../widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../exts.dart';

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

  @override
  void initState() {
    super.initState();
    if (lkPlatformIs(PlatformType.android)) {
      _checkPermissions();
    }
    _initInput();
  }

  void _initInput() async {
    final prefs = await SharedPreferences.getInstance();
    final options = context.read<LivekitDemoOptions?>();
    _uriCtrl.text = options?.serverUrl ??
        prefs.getString(_storeKeyUri) ??
        'https://meet.livekit.io';
    _roomCtrl.text =
        options?.room ?? prefs.getString(_storeKeyRoom) ?? '123456';
    _nameCtrl.text =
        options?.name ?? prefs.getString(_storeKeyName) ?? lkPlatform().name;
    if (options?.autoConnect ?? false) {
      await _connect(context);
      Navigator.pop(context);
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
      print('Bluetooth Permission disabled');
    }

    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Connect Permission disabled');
    }

    status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      print('Camera Permission disabled');
    }

    status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      print('Microphone Permission disabled');
    }
  }

  // Read saved URL and Token
  Future<void> _readPrefs() async {}

  // Save URL and Token
  Future<void> _writePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKeyUri, _uriCtrl.text);
    await prefs.setString(_storeKeyRoom, _roomCtrl.text);
    await prefs.setString(_storeKeyName, _nameCtrl.text);
  }

  Future<void> _connect(BuildContext ctx) async {
    //
    try {
      setState(() {
        _busy = true;
      });

      // Save URL and Token for convenience
      await _writePrefs();

      print('Connecting with url: ${_uriCtrl.text}, '
          'room: ${_roomCtrl.text}...');

      final url = _uriCtrl.text;
      final roomName = _roomCtrl.text;
      final name = _nameCtrl.text;
      final serverToken = await LivekitService(url).getToken(roomName, name);

      await Navigator.push<void>(
        ctx,
        MaterialPageRoute(
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
                )),
      );
    } catch (error) {
      print('Could not connect $error');
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
