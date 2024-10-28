import 'channel_service.dart';
import 'service.dart';

typedef ZeroArgumentFunction = Function();

class MeetingRpc {
  static final MeetingRpc _instance = MeetingRpc._internal();
  static MeetingRpc get instance => _instance;
  MeetingRpc._internal() {
    service = ChannelService();
  }

  Service? service;
  final Map<String, Function> _handlers = {};

  void registerMethod(String method, Function callback) {
    final Function handler;
    // 封装一层调用， 以便支持取消注册，释放callback防内存泄漏，
    if (callback is ZeroArgumentFunction) {
      handler = () => callback();
      service?.registerMethod(method, () async {
        final handler = _handlers[method];
        if (handler == null) return;
        await handler();
      });
    } else {
      handler = (param) => callback(param);
      service?.registerMethod(method, (param) async {
        final handler = _handlers[method];
        if (handler == null) return;
        await handler(param);
      });
    }
    _handlers[method] = handler;
  }

  void unregisterMethod(String method) {
    // fixme 如果出现重复注册的情况，可能导致误取消，AB注册然后A取消，B也失效了，可能是页面误重复启动了，
    _handlers.remove(method);
  }

  /// parameters只能是List或者Map，
  Future sendRequest(String method, [dynamic parameters]) {
    return service?.sendRequest(method, parameters) ??
        Future.error('Not connected');
  }
}
