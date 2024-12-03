import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../ext/media_device_ext.dart';
import '../exts.dart';
import '../options/flag_options.dart';
import '../theme.dart';
import 'room.dart';

class JoinArgs {
  JoinArgs({
    required this.url,
    required this.token,
    this.e2ee = false,
    this.e2eeKey,
    this.simulcast = true,
    this.adaptiveStream = true,
    this.dynacast = true,
    this.preferredCodec = 'VP8',
    this.enableBackupVideoCodec = true,
  });
  final String url;
  final String token;
  final bool e2ee;
  final String? e2eeKey;
  final bool simulcast;
  final bool adaptiveStream;
  final bool dynacast;
  final String preferredCodec;
  final bool enableBackupVideoCodec;
}

class PreJoinPage extends StatefulWidget {
  const PreJoinPage({
    required this.args,
    super.key,
  });
  final JoinArgs args;
  @override
  State<StatefulWidget> createState() => _PreJoinPageState();
}

class _PreJoinPageState extends State<PreJoinPage> {
  static final _logger = Logger('PreJoinPage');

  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  StreamSubscription? _subscription;

  bool _busy = false;
  bool _enableVideo = true;
  bool _enableAudio = true;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;

  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  VideoParameters _selectedVideoParameters = VideoParametersPresets.h720_169;

  @override
  void initState() {
    super.initState();
    _subscription =
        Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    Hardware.instance.enumerateDevices().then(_loadDevices);
  }

  @override
  void deactivate() {
    _subscription?.cancel();
    super.deactivate();
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _logger.info('加载可用媒体设备');
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    _logger.info(
        '发现 ${_audioInputs.length} 个音频输入设备和 ${_videoInputs.length} 个视频输入设备');

    final flagOptions = context.read<FlagOptions>();
    if (_audioInputs.isNotEmpty) {
      _logger.info('设置音频设备');
      if (!flagOptions.startWithAudioMuted && _selectedAudioDevice == null) {
        _selectedAudioDevice = _audioInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          await _changeLocalAudioTrack();
          setState(() {});
        });
      }
    }

    if (_videoInputs.isNotEmpty) {
      if (_selectedVideoDevice == null) {
        if (flagOptions.startWithVideoMuted) {
          _join(context);
          return;
        }
        // 优先选择前置摄像头
        _selectedVideoDevice = _videoInputs.firstWhereOrNull((d) => d.front);
        _selectedVideoDevice ??= _videoInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          await _changeLocalVideoTrack();
          setState(() {});
          // 自动加入会议不等用户切换，
          _join(context);
        });
      }
      setState(() {});
    } else {
      _join(context);
    }
  }

  Future<void> _setEnableVideo(value) async {
    _enableVideo = value;
    if (!_enableVideo) {
      await _videoTrack?.stop();
      _videoTrack = null;
    } else {
      await _changeLocalVideoTrack();
    }
    setState(() {});
  }

  Future<void> _setEnableAudio(value) async {
    _enableAudio = value;
    if (!_enableAudio) {
      await _audioTrack?.stop();
      _audioTrack = null;
    } else {
      await _changeLocalAudioTrack();
    }
    setState(() {});
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_selectedAudioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(AudioCaptureOptions(
        deviceId: _selectedAudioDevice!.deviceId,
      ));
      await _audioTrack!.start();
    }
  }

  Future<void> _changeLocalVideoTrack() async {
    _logger.info('更改本地视频轨道');
    if (_videoTrack != null) {
      _logger.info('停止现有视频轨道');
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (_selectedVideoDevice != null) {
      _logger.info('使用设备创建新视频轨道: ${_selectedVideoDevice?.label}');
      _videoTrack =
          await LocalVideoTrack.createCameraTrack(CameraCaptureOptions(
        cameraPosition: _selectedVideoDevice?.front ?? false
            ? CameraPosition.front
            : CameraPosition.back,
        deviceId: _selectedVideoDevice!.deviceId,
        params: _selectedVideoParameters,
      ));
      _logger.info('启动视频轨道');
      await _videoTrack!.start();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  _join(BuildContext context) async {
    _busy = true;

    setState(() {});

    var args = widget.args;

    try {
      //create new room
      var cameraEncoding = const VideoEncoding(
        maxBitrate: 5 * 1000 * 1000,
        maxFramerate: 30,
      );

      var screenEncoding = const VideoEncoding(
        maxBitrate: 3 * 1000 * 1000,
        maxFramerate: 15,
      );

      E2EEOptions? e2eeOptions;
      if (args.e2ee && args.e2eeKey != null) {
        final keyProvider = await BaseKeyProvider.create();
        e2eeOptions = E2EEOptions(keyProvider: keyProvider);
        await keyProvider.setKey(args.e2eeKey!);
      }

      final room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: args.adaptiveStream,
          dynacast: args.dynacast,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'custom_audio_track_name',
          ),
          defaultCameraCaptureOptions: CameraCaptureOptions(
              cameraPosition: _selectedVideoDevice?.front ?? false
                  ? CameraPosition.front
                  : CameraPosition.back,
              maxFrameRate: 30,
              params: const VideoParameters(
                dimensions: VideoDimensions(1280, 720),
              )),
          defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
              useiOSBroadcastExtension: true,
              params: VideoParameters(
                dimensions: VideoDimensionsPresets.h1080_169,
              )),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: args.simulcast,
            videoCodec: args.preferredCodec,
            backupVideoCodec: BackupVideoCodec(
              enabled: args.enableBackupVideoCodec,
            ),
            videoEncoding: cameraEncoding,
            screenShareEncoding: screenEncoding,
          ),
          e2eeOptions: e2eeOptions,
        ),
      );
      // Create a Listener before connecting
      final listener = room.createListener();

      await room.prepareConnection(args.url, args.token);

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect(
        args.url,
        args.token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: _audioTrack),
          camera: TrackOption(track: _videoTrack),
        ),
      );

      unawaited(Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/room'),
          builder: (_) => RoomPage(room, listener),
        ),
        (route) => false,
      ));
    } catch (error) {
      print('Could not connect $error');
      await context.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  void _actionBack(BuildContext context) async {
    await _setEnableVideo(false);
    await _setEnableAudio(false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Select Devices',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _actionBack(context),
          ),
        ),
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
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                            width: 320,
                            height: 240,
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.black54,
                              child: _videoTrack != null
                                  ? VideoTrackRenderer(
                                      renderMode: VideoRenderMode.auto,
                                      _videoTrack!,
                                      fit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitContain,
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      child: LayoutBuilder(
                                        builder: (ctx, constraints) => Icon(
                                          Icons.videocam_off,
                                          color: LKColors.lkBlue,
                                          size: math.min(constraints.maxHeight,
                                                  constraints.maxWidth) *
                                              0.3,
                                        ),
                                      ),
                                    ),
                            ))),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Camera:'),
                          Switch(
                            value: _enableVideo,
                            onChanged: (value) => _setEnableVideo(value),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<MediaDevice>(
                          isExpanded: true,
                          disabledHint: const Text('Disable Camera'),
                          hint: const Text(
                            'Select Camera',
                          ),
                          items: _enableVideo
                              ? _videoInputs
                                  .map((MediaDevice item) =>
                                      DropdownMenuItem<MediaDevice>(
                                        value: item,
                                        child: Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : [],
                          value: _selectedVideoDevice,
                          onChanged: (MediaDevice? value) async {
                            if (value != null) {
                              _selectedVideoDevice = value;
                              await _changeLocalVideoTrack();
                              setState(() {});
                            }
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 140,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    if (_enableVideo)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<VideoParameters>(
                            isExpanded: true,
                            hint: const Text(
                              'Select Video Dimensions',
                            ),
                            items: [
                              VideoParametersPresets.h480_43,
                              VideoParametersPresets.h540_169,
                              VideoParametersPresets.h720_169,
                              VideoParametersPresets.h1080_169,
                            ]
                                .map((VideoParameters item) =>
                                    DropdownMenuItem<VideoParameters>(
                                      value: item,
                                      child: Text(
                                        '${item.dimensions.width}x${item.dimensions.height}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: _selectedVideoParameters,
                            onChanged: (VideoParameters? value) async {
                              if (value != null) {
                                _selectedVideoParameters = value;
                                await _changeLocalVideoTrack();
                                setState(() {});
                              }
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: 140,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Micriphone:'),
                          Switch(
                            value: _enableAudio,
                            onChanged: (value) => _setEnableAudio(value),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<MediaDevice>(
                          isExpanded: true,
                          disabledHint: const Text('Disable Microphone'),
                          hint: const Text(
                            'Select Micriphone',
                          ),
                          items: _enableAudio
                              ? _audioInputs
                                  .map((MediaDevice item) =>
                                      DropdownMenuItem<MediaDevice>(
                                        value: item,
                                        child: Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : [],
                          value: _selectedAudioDevice,
                          onChanged: (MediaDevice? value) async {
                            if (value != null) {
                              _selectedAudioDevice = value;
                              await _changeLocalAudioTrack();
                              setState(() {});
                            }
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 140,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _busy ? null : () => _join(context),
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
                          const Text('JOIN'),
                        ],
                      ),
                    ),
                  ]),
            ))));
  }
}
