import 'package:logging/logging.dart';
import 'package:universal_platform/universal_platform.dart';

import 'desktop_service.dart';
import 'platform_service.dart';
import 'service.dart';

typedef ZeroArgumentFunction = Function();

class MeetingRpc {
  final logger = Logger('MeetingRpc');
  static final MeetingRpc _instance = MeetingRpc._internal();
  static MeetingRpc get instance => _instance;
  MeetingRpc._internal();

  late final Service? service = _initService();
  final Map<String, Function> _handlers = {};
  final Set<String> _registeredMethods = {};

  static final Map<String, Function> _staticHandlers = {};

  Service? _initService() {
    if (UniversalPlatform.isAndroid ||
        UniversalPlatform.isIOS ||
        UniversalPlatform.isWeb) {
      return PlatformService();
    } else if (UniversalPlatform.isDesktop) {
      return DesktopService();
    }
    logger.severe('Unsupported platform ${UniversalPlatform.value.name}');
    return null;
  }

  Function _createHandler(String method, Function callback) {
    if (callback is ZeroArgumentFunction) {
      return () {
        logger.fine('执行无参回调: $method, $callback');
        return callback();
      };
    } else {
      return (param) {
        logger.fine('执行回调: $method, 参数: $param');
        return callback(param);
      };
    }
  }

  void registerMethod(String method, Function callback) {
    logger.finer('registerMethod: $method');
    late final Function handler;

    try {
      handler = _createHandler(method, callback);

      if (!_registeredMethods.contains(method)) {
        if (callback is ZeroArgumentFunction) {
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
        _registeredMethods.add(method);
      }
    } catch (e, s) {
      logger.severe('registerMethod error: $e, $s');
    }
    _handlers[method] = handler;
  }

  void unregisterMethod(String method) {
    logger.finer('unregisterMethod: $method');
    _handlers.remove(method);
    // 这里不处理_registeredMethods，要用来下次registerMethod判断使用，
  }

  /// 静态注册方法，用于本地实现
  static void registerStaticMethod(String method, Function callback) {
    _staticHandlers[method] = callback;
  }

  /// 修改 sendRequest 方法，优先使用本地实现
  Future sendRequest(String method, [dynamic parameters]) async {
    logger.fine('sendRequest: $method, $parameters');

    // 优先检查是否有本地实现
    if (_staticHandlers.containsKey(method)) {
      try {
        final result = await _staticHandlers[method]?.call(parameters);
        logger.fine('sendRequest[$method] result: $result');
        return result;
      } catch (e, s) {
        logger.severe('Static handler error: $e, $s');
        return Future.error(e, s);
      }
    }

    final result = await (service?.sendRequest(method, parameters) ??
        Future.error('Not connected'));
    logger.fine('sendRequest[$method] result: $result');
    return result;
  }

  void sendNotification(String method, [dynamic parameters]) {
    logger.finer('sendNotification: $method, $parameters');

    // 优先检查是否有本地实现
    if (_staticHandlers.containsKey(method)) {
      try {
        _staticHandlers[method]?.call(parameters);
        return;
      } catch (e, s) {
        logger.severe('Static handler notification error: $e, $s');
        // 本地实现失败，继续尝试服务实现
      }
    }

    service?.sendNotification(method, parameters);
  }
}
