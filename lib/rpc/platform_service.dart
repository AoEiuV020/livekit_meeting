import '../meeting_flutter.dart';
import 'exception_converter.dart';
import 'service.dart';

class PlatformService implements Service {
  final MeetingFlutter platform = MeetingFlutter();
  @override
  void registerMethod(String method, Function callback) {
    platform.registerMethod(method, callback);
  }

  @override
  Future sendRequest(String method, parameters) async {
    try {
      if (parameters is Iterable) parameters = parameters.toList();
      if (parameters is! Map && parameters is! List && parameters != null) {
        throw ArgumentError('Only maps and lists may be used as JSON-RPC '
            'parameters, was "$parameters".');
      }
      return await platform.sendRequest(method, parameters);
    } catch (e) {
      throw RpcExceptionConverter.convertPlatformException(e);
    }
  }

  @override
  void sendNotification(String method, parameters) {
    try {
      if (parameters is Iterable) parameters = parameters.toList();
      if (parameters is! Map && parameters is! List && parameters != null) {
        throw ArgumentError('Only maps and lists may be used as JSON-RPC '
            'parameters, was "$parameters".');
      }
      platform.sendNotification(method, parameters);
    } catch (e) {
      throw RpcExceptionConverter.convertPlatformException(e);
    }
  }
}
