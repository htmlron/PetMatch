import 'package:flutter/widgets.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class AuditNavigationObserver extends NavigatorObserver {
  String? _extractRouteToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final stripped = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final validRouteToken = RegExp(r'^[a-zA-Z0-9_\-/]+$');
    if (validRouteToken.hasMatch(stripped)) {
      return stripped;
    }

    // Fallback: pick the first path-like token from noisy framework strings.
    final match = RegExp(r'/[a-zA-Z0-9_\-/]+').firstMatch(trimmed);
    if (match != null) {
      final token = match.group(0) ?? '';
      return token.startsWith('/') ? token.substring(1) : token;
    }

    return null;
  }

  String? _cleanRouteName(Route<dynamic>? route) {
    final rawName = (route?.settings.name ?? '').trim();

    // Filter out meaningless system transition names and uninitialized route names
    if (rawName.isEmpty ||
        rawName == 'null' ||
        rawName.contains('RouteSettings') ||
        rawName.contains('TransitionPage') ||
        rawName == 'none') {
      return null;
    }

    final name = _extractRouteToken(rawName);
    if (name == null || name.isEmpty) {
      return null;
    }

    // Direct mapping to beautiful, human-friendly screen names
    final cleanNamesMapping = {
      '': 'Home Dashboard',
      'home': 'Home Dashboard',
      'splash': 'Splash Screen',
      'get-started': 'Get Started Screen',
      'login': 'Login Screen',
      'register': 'Registration Screen',
      'forgot-password': 'Forgot Password Screen',
      'reset-password': 'Reset Password Screen',
      'verify-reset-otp': 'Verify Reset OTP Screen',
      'verify-email': 'Email Verification Screen',
      'setup': 'App Setup Screen',
      'onboarding': 'Onboarding Screen',
      'onboarding-household-setup': 'Household Setup Onboarding',
      'onboarding-profile-loading': 'Profile Loading Onboarding',
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
      'pet-information': 'Pet Information Screen',
      'pet-health-information': 'Pet Health Screen',
      'pet-activity-information': 'Pet Activity Screen',
      'pet-temperament-information': 'Pet Temperament Screen',
      'pet-behavior-information': 'Pet Behavior Screen',
      'pet-preference-setup': 'Pet Preference Setup Screen',
      'activity-level-setup': 'Activity Level Setup Screen',
      'patience-level-setup': 'Patience Level Setup Screen',
      'affection-level-setup': 'Affection Level Setup Screen',
      'grooming-level-setup': 'Grooming Level Setup Screen',
      'size-preference-setup': 'Size Preference Setup Screen',
      'admin-pet-management': 'Admin Pet Management',
    };

    if (cleanNamesMapping.containsKey(name)) {
      return cleanNamesMapping[name];
    }

    // Dynamic clean fallback for valid route-like tokens only.
    return name
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll('/', ' › ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _track(
      String action, Route<dynamic>? route, Route<dynamic>? previousRoute,
      {String? eventType}) {
    final routeName = _cleanRouteName(route);
    final previousRouteName = _cleanRouteName(previousRoute);

    // Skip tracking if the route is a technical/system transition to keep audit logs clean and relevant
    if (routeName == null) {
      return;
    }

    auditTrailService.track(
      action: action,
      entityType: 'screen',
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
