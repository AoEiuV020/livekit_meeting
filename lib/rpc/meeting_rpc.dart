import 'package:logging/logging.dart';

import 'platform_service.dart';
import 'service.dart';

typedef ZeroArgumentFunction = Function();

class MeetingRpc {
  final logger = Logger('MeetingRpc');
  static final MeetingRpc _instance = MeetingRpc._internal();
  static MeetingRpc get instance => _instance;
  MeetingRpc._internal() {
    service = PlatformService();
  }

  Service? service;
  final Map<String, Function> _handlers = {};

  void registerMethod(String method, Function callback) {
    logger.fine('registerMethod: $method');
    final Function handler;
    // 封装一层调用， 以便支持取消注册，释放callback防内存泄漏，
    // TODO: 封装后的callback可以是同一个对象，不需要每次创建新的Function，
    // 封装callback异常处理，可能不太必要，直接抛出效果应该一样，
    if (callback is ZeroArgumentFunction) {
      handler = () => callback();
      service?.registerMethod(method, () async {
        final handler = _handlers[method];
        if (handler == null) return;
        try {
          return await handler();
        } catch (e, s) {
          logger.severe('$method, callback error: $e, $s');
          return Future.error(e, s);
        }
      });
    } else {
      handler = (param) => callback(param);
      service?.registerMethod(method, (param) async {
        final handler = _handlers[method];
        if (handler == null) return;
        try {
          return await handler(param);
        } catch (e, s) {
          logger.severe('$method, callback error: $e, $s');
          return Future.error(e, s);
        }
      });
    }
    _handlers[method] = handler;
  }

  void unregisterMethod(String method) {
    logger.fine('unregisterMethod: $method');
    // TODO: 如果出现重复注册的情况，可能导致误取消，AB注册然后A取消，B也失效了，可能是页面误重复启动了，
    _handlers.remove(method);
  }

  /// parameters只能是List或者Map，
  Future sendRequest(String method, [dynamic parameters]) {
    logger.fine('sendRequest: $method, $parameters');
    return service?.sendRequest(method, parameters) ??
        Future.error('Not connected');
  }
}
