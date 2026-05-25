import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petmatch/core/router/admin_routes.dart';
import 'package:petmatch/core/router/auth_routes.dart';
import 'package:petmatch/core/router/home_routes.dart';
import 'package:petmatch/core/router/onboarding_routes.dart';
import 'package:petmatch/core/services/audit_navigation_observer.dart';
import 'package:petmatch/get_started_screen.dart';
import 'package:petmatch/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    observers: [AuditNavigationObserver()],
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/get-started',
        name: 'get-started',
        builder: (context, state) => const GetStartedScreen(),
      ),
      ...homeRoutes,
      ...authRoutes,
      ...onboardingRoutes,
      ...adminRoutes,
    ],
    // Handle deep links with custom scheme
    redirect: (context, state) {
      final uri = state.uri;

      // Handle petmatch:// scheme deep links
      if (uri.scheme == 'petmatch') {
        // Extract the path and query parameters
        final path = uri.path;
        final queryParams = uri.queryParameters;

        // Redirect to the appropriate route
        if (path.contains('reset-password')) {
          final email = queryParams['email'] ?? '';
          final token =
              queryParams['token'] ?? queryParams['access_token'] ?? '';
          return '/reset-password?email=$email&token=$token';
        }
      }

      return null; // No redirect needed
    },
  );
});
