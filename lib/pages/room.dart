import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../exts.dart';
import '../method_channels/replay_kit_channel.dart';
import '../options/flag_options.dart';
import '../rpc/external_api.dart';
import '../utils.dart';
import '../widgets/controls.dart';
import '../widgets/participant.dart';
import '../widgets/participant_info.dart';
import 'room_util.dart' if (dart.library.html) 'room_util_web.dart';

class RoomPage extends StatefulWidget {
  final Room room;
  final EventsListener<RoomEvent> listener;

  const RoomPage(
    this.room,
    this.listener, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  static final _logger = Logger('RoomPage');

  List<ParticipantTrack> participantTracks = [];
  EventsListener<RoomEvent> get _listener => widget.listener;
  bool get fastConnection => widget.room.engine.fastConnectOptions != null;
  bool _flagStartedReplayKit = false;
  @override
  void initState() {
    super.initState();
    _logger.info('初始化房间页面');
    widget.room.addListener(_onRoomDidUpdate);
    _setUpListeners();
    _sortParticipants();

    WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
      if (!fastConnection) {
        _logger.info('快速连接不可用，请求发布媒体流');
        _askPublish();
      }
    });

    if (lkPlatformIs(PlatformType.android)) {
      Hardware.instance.setSpeakerphoneOn(true);
    }

    if (lkPlatformIs(PlatformType.iOS)) {
      ReplayKitChannel.listenMethodChannel(widget.room);
    }

    if (lkPlatformIsDesktop()) {
      onWindowShouldClose = () async {
        // 如果是断开连接后主动关闭窗口，则没有RoomDisconnectedEvent，所以直接等待disconnect，不等事件，
        await widget.room.disconnect();
      };
    }
    ExternalApi.instance.registerMethod(
        ExternalApiMethod.hangUp, () => widget.room.disconnect());
  }

  @override
  void dispose() {
    ExternalApi.instance.unregisterMethod(ExternalApiMethod.hangUp);
    // always dispose listener
    (() async {
      if (lkPlatformIs(PlatformType.iOS)) {
        ReplayKitChannel.closeReplayKit();
      }
      widget.room.removeListener(_onRoomDidUpdate);
      await _listener.dispose();
      await widget.room.dispose();
    })();
    onWindowShouldClose = null;
    super.dispose();
  }

  /// for more information, see [event types](https://docs.livekit.io/client/events/#events)
  void _setUpListeners() {
    _logger.info('设置房间事件监听器');

    _listener
      ..once<RoomDisconnectedEvent>((event) async {
        _logger.info('房间已断开连接: ${event.reason}');
        ExternalApi.instance.onDisconnected();
        WidgetsBindingCompatible.instance?.addPostFrameCallback((timeStamp) {
          final autoConnect = context.read<FlagOptions>().autoConnect;
          if (autoConnect) {
            Navigator.popUntil(context, (_) => false);
            roomCloseApp();
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          }
        });
      })
      ..on<ParticipantEvent>((event) {
        _logger.info('收到参与者事件: ${event.runtimeType}');
        _sortParticipants();
      })
      ..on<RoomRecordingStatusChanged>((event) {
        _logger.info('录制状态变更: ${event.activeRecording}');
        context.showRecordingStatusChangedDialog(event.activeRecording);
      })
      ..on<RoomAttemptReconnectEvent>((event) {
        _logger.info('尝试重新连接 ${event.attempt}/${event.maxAttemptsRetry}, '
            '(下次尝试延迟 ${event.nextRetryDelaysInMs}ms)');
      })
      ..on<LocalTrackSubscribedEvent>((event) {
        _logger.info('本地轨道已订阅: ${event.trackSid}');
      })
      ..on<LocalTrackPublishedEvent>((_) => _sortParticipants())
      ..on<LocalTrackUnpublishedEvent>((_) => _sortParticipants())
      ..on<TrackSubscribedEvent>((_) => _sortParticipants())
      ..on<TrackUnsubscribedEvent>((_) => _sortParticipants())
      ..on<TrackE2EEStateEvent>(_onE2EEStateEvent)
      ..on<ParticipantNameUpdatedEvent>((event) {
        _logger.info(
            '参与者名称已更新: ${event.participant.identity}, 新名称 => ${event.name}');
        _sortParticipants();
      })
      ..on<ParticipantMetadataUpdatedEvent>((event) {
        _logger.info(
            '参与者元数据已更新: ${event.participant.identity}, 元数据 => ${event.metadata}');
      })
      ..on<RoomMetadataChangedEvent>((event) {
        _logger.info('房间元数据已更改: ${event.metadata}');
      })
      ..on<DataReceivedEvent>((event) {
        String decoded = '解码失败';
        try {
          decoded = utf8.decode(event.data);
        } catch (err) {
          _logger.severe('数据解码失败: $err');
        }
        context.showDataReceivedDialog(decoded);
      })
      ..on<AudioPlaybackStatusChanged>((event) async {
        if (!widget.room.canPlaybackAudio) {
          _logger.warning('iOS Safari 音频播放失败');
          bool? yesno = await context.showPlayAudioManuallyDialog();
          if (yesno == true) {
            await widget.room.startAudio();
          }
        }
      });
  }

  void _askPublish() async {
    final result = await context.showPublishDialog();
    if (result != true) return;
    try {
      await widget.room.localParticipant?.setCameraEnabled(true);
    } catch (error) {
      _logger.severe('无法发布视频: $error');
      await context.showErrorDialog(error);
    }
    try {
      await widget.room.localParticipant?.setMicrophoneEnabled(true);
    } catch (error) {
      _logger.severe('无法发布音频: $error');
      await context.showErrorDialog(error);
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _onE2EEStateEvent(TrackE2EEStateEvent e2eeState) {
    _logger.info('端到端加密状态: $e2eeState');
  }

  void _sortParticipants() {
    _logger.info('对参与者进行排序');
    List<ParticipantTrack> userMediaTracks = [];
    List<ParticipantTrack> screenTracks = [];

    _logger.info('远程参与者数量: ${widget.room.remoteParticipants.length}');

    for (var participant in widget.room.remoteParticipants.values) {
      _logger.fine('处理参与者轨道: ${participant.identity}');
      for (var t in participant.videoTrackPublications) {
        if (t.isScreenShare) {
          screenTracks.add(ParticipantTrack(
            participant: participant,
            type: ParticipantTrackType.kScreenShare,
          ));
        } else {
          userMediaTracks.add(ParticipantTrack(participant: participant));
        }
      }
    }
    // sort speakers for the grid
    userMediaTracks.sort((a, b) {
      // loudest speaker first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // last spoken at
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      // video on
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // joinedAt
      return a.participant.joinedAt.millisecondsSinceEpoch -
          b.participant.joinedAt.millisecondsSinceEpoch;
    });

    final localParticipantTracks =
        widget.room.localParticipant?.videoTrackPublications;
    if (localParticipantTracks != null) {
      for (var t in localParticipantTracks) {
        if (t.isScreenShare) {
          if (lkPlatformIs(PlatformType.iOS)) {
            if (!_flagStartedReplayKit) {
              _flagStartedReplayKit = true;

              ReplayKitChannel.startReplayKit();
            }
          }
          screenTracks.add(ParticipantTrack(
            participant: widget.room.localParticipant!,
            type: ParticipantTrackType.kScreenShare,
          ));
        } else {
          if (lkPlatformIs(PlatformType.iOS)) {
            if (_flagStartedReplayKit) {
              _flagStartedReplayKit = false;

              ReplayKitChannel.closeReplayKit();
            }
          }

          userMediaTracks.add(
              ParticipantTrack(participant: widget.room.localParticipant!));
        }
      }
    }
    setState(() {
      participantTracks = [...screenTracks, ...userMediaTracks];
    });
    _logger.info('参与者排序完成，总轨道数: ${participantTracks.length}');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    child: participantTracks.isNotEmpty
                        ? ParticipantWidget.widgetFor(participantTracks.first,
                            showStatsLayer: true)
                        : Container()),
                if (widget.room.localParticipant != null)
                  SafeArea(
                    top: false,
                    child: ControlsWidget(
                        widget.room, widget.room.localParticipant!),
                  )
              ],
            ),
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: math.max(0, participantTracks.length - 1),
                    itemBuilder: (BuildContext context, int index) => SizedBox(
                      width: 180,
                      height: 120,
                      child: ParticipantWidget.widgetFor(
                          participantTracks[index + 1]),
                    ),
                  ),
                )),
          ],
        ),
      );
}
