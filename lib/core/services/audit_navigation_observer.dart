import 'package:flutter/widgets.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class AuditNavigationObserver extends NavigatorObserver {
  void _track(String action, Route<dynamic>? route, Route<dynamic>? previousRoute,
      {String? eventType}) {
    final routeName = route?.settings.name ?? route?.settings.toString() ?? 'unknown_route';
    final previousRouteName = previousRoute?.settings.name ?? previousRoute?.settings.toString();

    auditTrailService.track(
      action: action,
      entityType: 'navigation',
      entityId: routeName,
      metadata: {
        'route': routeName,
        if (previousRouteName != null) 'previous_route': previousRouteName,
        if (eventType != null) 'event_type': eventType,
      },
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _track('screen_opened', route, previousRoute, eventType: 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _track('screen_closed', previousRoute, route, eventType: 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track('screen_replaced', newRoute, oldRoute, eventType: 'replace');
  }
}