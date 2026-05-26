import 'package:flutter/widgets.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class AuditNavigationObserver extends NavigatorObserver {
  String? _cleanRouteName(Route<dynamic>? route) {
    final rawName = route?.settings.name ?? '';
    
    // Filter out meaningless system transition names and uninitialized route names
    if (rawName.isEmpty || 
        rawName == 'null' || 
        rawName.contains('RouteSettings') || 
        rawName.contains('TransitionPage') ||
        rawName == 'none') {
      return null;
    }

    // Strip leading slash for clean checking
    String name = rawName;
    if (name.startsWith('/')) {
      name = name.substring(1);
    }

    // Direct mapping to beautiful, human-friendly screen names
    final cleanNamesMapping = {
      '': 'Home Dashboard',
      'home': 'Home Dashboard',
      'splash': 'Splash Screen',
      'get-started': 'Get Started Screen',
      'login': 'Login Screen',
      'register': 'Registration Screen',
      'verify-email': 'Email Verification Screen',
      'setup': 'App Setup Screen',
      'onboarding': 'Onboarding Screen',
      'onboarding/profile-setup': 'Profile Setup Onboarding',
      'onboarding/household': 'Household Setup Onboarding',
      'onboarding/pet-preference': 'Pet Preference Onboarding',
      'onboarding/size-preference': 'Size Preference Onboarding',
      'onboarding/activity-level': 'Activity Level Onboarding',
      'onboarding/patience-level': 'Patience Level Onboarding',
      'onboarding/affection-level': 'Affection Level Onboarding',
      'onboarding/grooming-level': 'Grooming Level Onboarding',
      'home/profile-screen': 'User Profile Screen',
      'home/match-dashboard': 'Pet Match Dashboard',
      'home/favorite-pets': 'Favorite Pets Screen',
      'home/add-pet': 'Add Pet Screen',
      'home/edit-profile': 'Edit Profile Screen',
      'profile-screen': 'User Profile Screen',
      'match-dashboard': 'Pet Match Dashboard',
      'favorite-pets': 'Favorite Pets Screen',
      'add-pet': 'Add Pet Screen',
      'edit-profile': 'Edit Profile Screen',
      'size-preference': 'Size Preference Screen',
      'household-setup': 'Household Setup Screen',
      'profile-setup': 'Profile Setup Screen',
    };

    if (cleanNamesMapping.containsKey(name)) {
      return cleanNamesMapping[name];
    }

    // Dynamic clean fallback (e.g. "size-preference-setup" -> "Size Preference Setup Onboarding")
    return name.replaceAll('-', ' ').replaceAll('_', ' ').replaceAll('/', ' › ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _track(String action, Route<dynamic>? route, Route<dynamic>? previousRoute,
      {String? eventType}) {
    final routeName = _cleanRouteName(route);
    final previousRouteName = _cleanRouteName(previousRoute);

    // Skip tracking if the route is a technical/system transition to keep audit logs clean and relevant
    if (routeName == null) {
      return;
    }

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