import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

class RouteLoggerObserver extends RouteObserver<PageRoute<dynamic>> {
  final Logger _logger = Logger('route');
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logger.info(
        'didPush: ${route.settings.name} -> ${previousRoute?.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logger.info(
        'didPop: ${route.settings.name} -> ${previousRoute?.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _logger.info(
        'didRemove: ${route.settings.name} -> ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logger.info(
        'didReplace: ${newRoute?.settings.name} -> ${oldRoute?.settings.name}');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    _logger.info(
        'didStartUserGesture: ${route.settings.name} -> ${previousRoute?.settings.name}');
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    _logger.info('didStopUserGesture');
  }
}
