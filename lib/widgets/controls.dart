import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:provider/provider.dart';

import '../exts.dart';
import '../options/flag_options.dart';
import '../rpc/external_api.dart';

class ControlsWidget extends StatefulWidget {
  //
  final Room room;
  final LocalParticipant participant;

  const ControlsWidget(
    this.room,
    this.participant, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ControlsWidgetState();
}

class _ControlsWidgetState extends State<ControlsWidget> {
  //
  CameraPosition position = CameraPosition.front;

  List<MediaDevice>? _audioInputs;
  List<MediaDevice>? _audioOutputs;
  List<MediaDevice>? _videoInputs;

  StreamSubscription? _subscription;

  bool _speakerphoneOn = Hardware.instance.preferSpeakerOutput;

  late final EventsListener<ParticipantEvent> _listener =
      widget.participant.createListener();

  @override
  void initState() {
    super.initState();
    participant.addListener(_onChange);
    _subscription = Hardware.instance.onDeviceChange.stream
        .listen((List<MediaDevice> devices) {
      _loadDevices(devices);
    });
    Hardware.instance.enumerateDevices().then(_loadDevices);
    position =
        widget.room.roomOptions.defaultCameraCaptureOptions.cameraPosition;
    ExternalApi.instance.registerMethod(
        ExternalApiMethod.setAudioMute, (param) => _setAudioMute(param));
    ExternalApi.instance.registerMethod(
        ExternalApiMethod.setVideoMute, (param) => _setVideoMute(param));
    ExternalApi.instance
        .registerMethod(ExternalApiMethod.toggleCamera, () => _toggleCamera());
    _listener
      ..on<TrackMutedEvent>((event) {
        if (event.participant != participant) return;
        if (event.publication.kind == TrackType.AUDIO) {
          ExternalApi.instance.onAudioMuteChanged(true);
        } else if (event.publication.kind == TrackType.VIDEO) {
          ExternalApi.instance.onVideoMuteChanged(true);
        }
      })
      ..on<TrackUnmutedEvent>((event) {
        if (event.participant != participant) return;
        if (event.publication.kind == TrackType.AUDIO) {
          ExternalApi.instance.onAudioMuteChanged(false);
        } else if (event.publication.kind == TrackType.VIDEO) {
          ExternalApi.instance.onVideoMuteChanged(false);
        }
      });
  }

  @override
  void dispose() {
    _listener.dispose();
    ExternalApi.instance.unregisterMethod(ExternalApiMethod.setAudioMute);
    ExternalApi.instance.unregisterMethod(ExternalApiMethod.setVideoMute);
    ExternalApi.instance.unregisterMethod(ExternalApiMethod.toggleCamera);
    _subscription?.cancel();
    participant.removeListener(_onChange);
    super.dispose();
  }

  Future<void> _setAudioMute(param) {
    if (param['muted'] == true) {
      return _disableAudio();
    } else {
      return _enableAudio();
    }
  }

  Future<void> _setVideoMute(param) {
    if (param['muted'] == true) {
      return _disableVideo();
    } else {
      return _enableVideo();
    }
  }

  LocalParticipant get participant => widget.participant;

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
    setState(() {});
  }

  void _onChange() {
    // trigger refresh
    setState(() {});
  }

  Future<void> _unpublishAll() async {
    final result = await context.showUnPublishDialog();
    if (result == true) await participant.unpublishAllTracks();
    final buttonOptions = context.read<ButtonFlagOptions>();
    buttonOptions.disableAudio = true;
    buttonOptions.disableVideo = true;
    buttonOptions.disableScreenShare = true;
    buttonOptions.updateFlags();
  }

  bool get isMuted => participant.isMuted;

  Future<void> _disableAudio() async {
    await participant.setMicrophoneEnabled(false);
  }

  Future<void> _enableAudio() async {
    await participant.setMicrophoneEnabled(true);
  }

  Future<void> _disableVideo() async {
    await participant.setCameraEnabled(false);
  }

  Future<void> _enableVideo() async {
    await participant.setCameraEnabled(true);
  }

  void _selectAudioOutput(MediaDevice device) async {
    await widget.room.setAudioOutputDevice(device);
    setState(() {});
  }

  void _selectAudioInput(MediaDevice device) async {
    await widget.room.setAudioInputDevice(device);
    setState(() {});
  }

  void _selectVideoInput(MediaDevice device) async {
    await widget.room.setVideoInputDevice(device);
    setState(() {});
  }

  void _setSpeakerphoneOn() {
    _speakerphoneOn = !_speakerphoneOn;
    Hardware.instance.setSpeakerphoneOn(_speakerphoneOn);
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    //
    final track = participant.videoTrackPublications.firstOrNull?.track;
    if (track == null) return;

    try {
      final newPosition = position.switched();
      await track.setCameraPosition(newPosition);
      setState(() {
        position = newPosition;
      });
    } catch (error) {
      print('could not restart track: $error');
      return;
    }
  }

  Future<void> _enableScreenShare() async {
    if (lkPlatformIsDesktop()) {
      try {
        final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => ScreenSelectDialog(),
        );
        if (source == null) {
          print('cancelled screenshare');
          return;
        }
        print('DesktopCapturerSource: ${source.id}');
        var track = await LocalVideoTrack.createScreenShareTrack(
          ScreenShareCaptureOptions(
            sourceId: source.id,
            maxFrameRate: 15.0,
          ),
        );
        await participant.publishVideoTrack(track);
      } catch (e) {
        print('could not publish video: $e');
      }
      return;
    }
    if (lkPlatformIs(PlatformType.android)) {
      // Android specific
      bool hasCapturePermission = await Helper.requestCapturePermission();
      if (!hasCapturePermission) {
        return;
      }

      requestBackgroundPermission([bool isRetry = false]) async {
        // Required for android screenshare.
        try {
          bool hasPermissions = await FlutterBackground.hasPermissions;
          if (!isRetry) {
            const androidConfig = FlutterBackgroundAndroidConfig(
              notificationTitle: 'Screen Sharing',
              notificationText: 'LiveKit Example is sharing the screen.',
              notificationImportance: AndroidNotificationImportance.normal,
              notificationIcon: AndroidResource(
                  name: 'livekit_ic_launcher', defType: 'mipmap'),
            );
            hasPermissions = await FlutterBackground.initialize(
                androidConfig: androidConfig);
          }
          if (hasPermissions &&
              !FlutterBackground.isBackgroundExecutionEnabled) {
            await FlutterBackground.enableBackgroundExecution();
          }
        } catch (e) {
          if (!isRetry) {
            return await Future<void>.delayed(const Duration(seconds: 1),
                () => requestBackgroundPermission(true));
          }
          print('could not publish video: $e');
        }
      }

      await requestBackgroundPermission();
    }
    if (lkPlatformIs(PlatformType.iOS)) {
      var track = await LocalVideoTrack.createScreenShareTrack(
        const ScreenShareCaptureOptions(
          useiOSBroadcastExtension: true,
          maxFrameRate: 15.0,
        ),
      );
      await participant.publishVideoTrack(track);
      return;
    }

    if (lkPlatformIsWebMobile()) {
      await context
          .showErrorDialog('Screen share is not supported on mobile web');
      return;
    }

    await participant.setScreenShareEnabled(true, captureScreenAudio: true);
  }

  Future<void> _disableScreenShare() async {
    await participant.setScreenShareEnabled(false);
    if (lkPlatformIs(PlatformType.android)) {
      // Android specific
      try {
        //   await FlutterBackground.disableBackgroundExecution();
      } catch (error) {
        print('error disabling screen share: $error');
      }
    }
  }

  Future<void> _onTapDisconnect() async {
    final externalIntercept = await ExternalApi.instance.interceptHangUp();
    if (externalIntercept) return;
    final result = await context.showDisconnectDialog();
    if (result == true) await widget.room.disconnect();
  }

  void _onTapUpdateSubscribePermission() async {
    final result = await context.showSubscribePermissionDialog();
    if (result != null) {
      try {
        widget.room.localParticipant?.setTrackSubscriptionPermissions(
          allParticipantsAllowed: result,
        );
      } catch (error) {
        await context.showErrorDialog(error);
      }
    }
  }

  void _onTapSimulateScenario() async {
    final result = await context.showSimulateScenarioDialog();
    if (result != null) {
      print('$result');

      if (SimulateScenarioResult.e2eeKeyRatchet == result) {
        await widget.room.e2eeManager?.ratchetKey();
      }

      if (SimulateScenarioResult.participantMetadata == result) {
        widget.room.localParticipant?.setMetadata(
            'new metadata ${widget.room.localParticipant?.identity}');
      }

      if (SimulateScenarioResult.participantName == result) {
        widget.room.localParticipant
            ?.setName('new name for ${widget.room.localParticipant?.identity}');
      }

      await widget.room.sendSimulateScenario(
        speakerUpdate:
            result == SimulateScenarioResult.speakerUpdate ? 3 : null,
        signalReconnect:
            result == SimulateScenarioResult.signalReconnect ? true : null,
        fullReconnect:
            result == SimulateScenarioResult.fullReconnect ? true : null,
        nodeFailure: result == SimulateScenarioResult.nodeFailure ? true : null,
        migration: result == SimulateScenarioResult.migration ? true : null,
        serverLeave: result == SimulateScenarioResult.serverLeave ? true : null,
        switchCandidate:
            result == SimulateScenarioResult.switchCandidate ? true : null,
      );
    }
  }

  void _onTapSendData() async {
    final result = await context.showSendDataDialog();
    if (result == true) {
      await widget.participant.publishData(
        utf8.encode('This is a sample data message'),
      );
    }
  }

  List<Widget> buildAudioButton(BuildContext context) => [
        if (participant.isMicrophoneEnabled())
          if (lkPlatformIs(PlatformType.android))
            IconButton(
              onPressed: _disableAudio,
              icon: const Icon(Icons.mic),
              tooltip: 'mute audio',
            )
          else
            PopupMenuButton<MediaDevice>(
              icon: const Icon(Icons.settings_voice),
              offset: const Offset(0, -90),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<MediaDevice>(
                    value: null,
                    onTap: isMuted ? _enableAudio : _disableAudio,
                    child: const ListTile(
                      leading: Icon(
                        Icons.mic_off,
                        color: Colors.white,
                      ),
                      title: Text('Mute Microphone'),
                    ),
                  ),
                  if (_audioInputs != null)
                    ..._audioInputs!.map((device) {
                      return PopupMenuItem<MediaDevice>(
                        value: device,
                        child: ListTile(
                          leading: (device.deviceId ==
                                  widget.room.selectedAudioInputDeviceId)
                              ? const Icon(
                                  Icons.check_box_outlined,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.check_box_outline_blank,
                                  color: Colors.white,
                                ),
                          title: Text(device.label),
                        ),
                        onTap: () => _selectAudioInput(device),
                      );
                    })
                ];
              },
            )
        else
          IconButton(
            onPressed: _enableAudio,
            icon: const Icon(Icons.mic_off),
            tooltip: 'un-mute audio',
          ),
      ];

  List<Widget> buildAudioRouteButton(BuildContext context) => [
        if (!lkPlatformIsMobile())
          PopupMenuButton<MediaDevice>(
            icon: const Icon(Icons.volume_up),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MediaDevice>(
                  value: null,
                  child: ListTile(
                    leading: Icon(
                      Icons.speaker,
                      color: Colors.white,
                    ),
                    title: Text('Select Audio Output'),
                  ),
                ),
                if (_audioOutputs != null)
                  ..._audioOutputs!.map((device) {
                    return PopupMenuItem<MediaDevice>(
                      value: device,
                      child: ListTile(
                        leading: (device.deviceId ==
                                widget.room.selectedAudioOutputDeviceId)
                            ? const Icon(
                                Icons.check_box_outlined,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.white,
                              ),
                        title: Text(device.label),
                      ),
                      onTap: () => _selectAudioOutput(device),
                    );
                  })
              ];
            },
          ),
      ];
  List<Widget> buildSpeakerphoneButton(BuildContext context) => [
        if (!kIsWeb && lkPlatformIsMobile())
          IconButton(
            disabledColor: Colors.grey,
            onPressed: Hardware.instance.canSwitchSpeakerphone
                ? _setSpeakerphoneOn
                : null,
            icon: Icon(
                _speakerphoneOn ? Icons.speaker_phone : Icons.phone_android),
            tooltip: 'Switch SpeakerPhone',
          ),
      ];

  List<Widget> buildVideoButton(BuildContext context) => [
        if (participant.isCameraEnabled())
          PopupMenuButton<MediaDevice>(
            icon: const Icon(Icons.videocam_sharp),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<MediaDevice>(
                  value: null,
                  onTap: _disableVideo,
                  child: const ListTile(
                    leading: Icon(
                      Icons.videocam_off,
                      color: Colors.white,
                    ),
                    title: Text('Disable Camera'),
                  ),
                ),
                if (_videoInputs != null)
                  ..._videoInputs!.map((device) {
                    return PopupMenuItem<MediaDevice>(
                      value: device,
                      child: ListTile(
                        leading: (device.deviceId ==
                                widget.room.selectedVideoInputDeviceId)
                            ? const Icon(
                                Icons.check_box_outlined,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.white,
                              ),
                        title: Text(device.label),
                      ),
                      onTap: () => _selectVideoInput(device),
                    );
                  })
              ];
            },
          )
        else
          IconButton(
            onPressed: _enableVideo,
            icon: const Icon(Icons.videocam_off),
            tooltip: 'un-mute video',
          ),
        IconButton(
          icon: Icon(position == CameraPosition.back
              ? Icons.video_camera_back
              : Icons.video_camera_front),
          onPressed: () => _toggleCamera(),
          tooltip: 'toggle camera',
        ),
      ];

  List<Widget> buildScreenSharingButton(BuildContext context) => [
        if (participant.isScreenShareEnabled())
          IconButton(
            icon: const Icon(Icons.monitor_outlined),
            onPressed: () => _disableScreenShare(),
            tooltip: 'unshare screen (experimental)',
          )
        else
          IconButton(
            icon: const Icon(Icons.monitor),
            onPressed: () => _enableScreenShare(),
            tooltip: 'share screen (experimental)',
          ),
      ];

  List<Widget> buildHangupButton(BuildContext context) => [
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onTapDisconnect();
          },
          child: IconButton(
            onPressed: _onTapDisconnect,
            icon: const Icon(Icons.close_sharp),
            tooltip: 'disconnect',
          ),
        ),
      ];
  @override
  Widget build(BuildContext context) {
    final buttonFlagOptions = context.watch<ButtonFlagOptions>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: 5,
        children: [
          IconButton(
            onPressed: _unpublishAll,
            icon: const Icon(Icons.cancel),
            tooltip: 'Unpublish all',
          ),
          if (!buttonFlagOptions.disableAudio) ...buildAudioButton(context),
          if (!buttonFlagOptions.disableAudio)
            ...buildAudioRouteButton(context),
          if (!buttonFlagOptions.disableAudio)
            ...buildSpeakerphoneButton(context),
          if (!buttonFlagOptions.disableVideo) ...buildVideoButton(context),
          if (!buttonFlagOptions.disableScreenShare)
            ...buildScreenSharingButton(context),
          if (!buttonFlagOptions.disableHangup) ...buildHangupButton(context),
          IconButton(
            onPressed: _onTapSendData,
            icon: const Icon(Icons.message),
            tooltip: 'send demo data',
          ),
          IconButton(
            onPressed: _onTapUpdateSubscribePermission,
            icon: const Icon(Icons.settings),
            tooltip: 'Subscribe permission',
          ),
          IconButton(
            onPressed: _onTapSimulateScenario,
            icon: const Icon(Icons.bug_report),
            tooltip: 'Simulate scenario',
          ),
        ],
      ),
    );
  }
}
