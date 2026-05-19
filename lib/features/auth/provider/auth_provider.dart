// ignore_for_file: use_build_context_synchronously

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/model/user_model.dart';
import 'package:petmatch/core/utils/notifier_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/features/auth/provider/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends Notifier<UserAuthState> {
  @override
  UserAuthState build() {
    return UserAuthState();
  }

  Future<void> initializeAuth() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await fetchUserRecord(session.user.id);
      // await fetchRelatedData(true);
    } else {
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<void> fetchUserRecord(String userId) async {
    try {
      final userRecord = await supabase.from('users').select('''
      user_id,
      full_name,
      user_email,
      user_role,
      onboarding_completed
    ''').eq('user_id', userId).single();

      final profile = AppUser.fromJson(userRecord);
      final onboardingComplete =
          userRecord['onboarding_completed'] as bool? ?? false;

      print('Onboarding Status: $onboardingComplete');

      state = state.copyWith(
        userProfile: profile,
        userId: userId,
        userName: profile.fullName,
        userEmail: profile.email,
        isAuthenticated: true,
        onboardingComplete: onboardingComplete,
      );
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    // Trim inputs to remove whitespace
    email = email.trim();
    password = password.trim();

    NotifierHelper.logMessage('Locked out time: ${state.lockoutTime}');
    NotifierHelper.logMessage('Is logging in: ${state.isLoggingIn}');

    if (state.lockoutTime != null &&
        DateTime.now().isBefore(state.lockoutTime!)) {
      NotifierHelper.showErrorToast(
          context, 'Too many failed attempts. Try again later!');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      NotifierHelper.showErrorToast(context, 'Incomplete input fields!');
      return;
    }

    try {
      state = state.copyWith(isLoggingIn: true);
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = response.user!;

        // Check if email is verified
        if (user.emailConfirmedAt == null) {
          // Email not verified - redirect to verification screen
          await supabase.auth.signOut();

          NotifierHelper.showErrorToast(
            context,
            'Please verify your email before logging in.',
          );

          state = state.copyWith(
            userEmail: email,
            userPassword: password,
            isLoggingIn: false,
          );

          context.go('/verify-email?email=$email&password=$password');
          return;
        }

        // Email is verified - proceed with login
        await initializeAuth();

        NotifierHelper.closeToast(context);
        state = state.copyWith(
          isAuthenticated: true,
          failedAttempts: 0,
          lockoutTime: null,
        );

        if (state.userProfile?.role == 'admin') {
          context.go('/admin/pet-management');
        } else {
          if (!state.onboardingComplete) {
            context.go('/onboarding');
          } else {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      NotifierHelper.logError(e);
      int newFailedAttempts = (state.failedAttempts ?? 0) + 1;
      DateTime? newLockoutTime;

      if (newFailedAttempts >= 3) {
        newLockoutTime = DateTime.now().add(const Duration(minutes: 1));
        NotifierHelper.showErrorToast(
            context, 'Too many attempts. Locked for 1 minute');

        Future.delayed(const Duration(minutes: 1), () {
          if (state.lockoutTime != null &&
              DateTime.now().isAfter(state.lockoutTime!)) {
            state = state.copyWith(failedAttempts: 0, lockoutTime: null);
          }
        });
      } else {
        NotifierHelper.showErrorToast(
            context, "Invalid credentials. Attempt $newFailedAttempts/3.");
      }

      state = state.copyWith(
        failedAttempts: newFailedAttempts,
        lockoutTime: newLockoutTime,
      );
    } finally {
      state = state.copyWith(isLoggingIn: false);
    }
  }

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    String username,
    String confirmPassword,
  ) async {
    // Trim all inputs to remove whitespace
    email = email.trim();
    password = password.trim();
    username = username.trim();
    confirmPassword = confirmPassword.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        confirmPassword.isEmpty) {
      NotifierHelper.closeToast(context);
      NotifierHelper.showErrorToast(context, 'Incomplete input fields!');
      state = state.copyWith(isRegistering: false);
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      NotifierHelper.closeToast(context);
      NotifierHelper.showErrorToast(context, 'Invalid email format!');
      state = state.copyWith(isRegistering: false);
      return;
    }

    if (password.length < 6) {
      NotifierHelper.closeToast(context);
      NotifierHelper.showErrorToast(
          context, 'Password must be at least 6 characters long!');
      state = state.copyWith(isRegistering: false);
      return;
    }

    if (password != confirmPassword) {
      NotifierHelper.closeToast(context);
      NotifierHelper.showErrorToast(context, 'Passwords do not match!');
      state = state.copyWith(isRegistering: false);
      return;
    }

    state = state.copyWith(isRegistering: true);
    NotifierHelper.showLoadingToast(context, 'Signing up...');

    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('user_email', email)
          .maybeSingle();

      if (existingUser != null) {
        state = state.copyWith(userEmail: email, userPassword: password);
        await supabase.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: 'https://petmatch-nine.vercel.app/verify-email',
        );

        NotifierHelper.closeToast(context);
        NotifierHelper.showSuccessToast(
          context,
          'This email is already registered. We sent a new verification email.',
        );
        context.go('/verify-email?email=$email&password=$password');
        return;
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://petmatch-nine.vercel.app/verify-email',
      );

      if (response.user != null) {
        await supabase.from('users').insert(
          {
            'user_id': response.user!.id,
            'user_email': email,
            'full_name': username,
            'user_role': 'user',
            'created_at': DateTime.now().toIso8601String(),
            'onboarding_completed': false,
          },
        );

        state = state.copyWith(
          userEmail: email,
          userPassword: password,
          userId: response.user!.id,
        );

        NotifierHelper.closeToast(context);
        NotifierHelper.showSuccessToast(
          context,
          'Registration successful! Please verify your email.',
        );

        // Navigate to verify email screen
        context.go('/verify-email?email=$email&password=$password');
        return;
      }

      state = state.copyWith(userEmail: email, userPassword: password);
    } catch (e) {
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      }
      NotifierHelper.closeToast(context);
      throw (errorMessage);
    } finally {
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> requestResetPassword(BuildContext context,
      [String? email]) async {
    final emailToUse = (email ?? state.userEmail)?.trim();

    if (emailToUse == null || emailToUse.isEmpty) {
      NotifierHelper.showErrorToast(context, 'Email is required.');
      return;
    }

    try {
      state = state.copyWith(isRequestingChange: true);

      NotifierHelper.showLoadingToast(context, 'Sending reset link');

      // Send password reset email with web URL that supports universal links
      await supabase.auth.resetPasswordForEmail(
        emailToUse,
        redirectTo:
            'https://petmatch-nine.vercel.app/reset-password?email=${Uri.encodeComponent(emailToUse)}',
      );

      // Store email for the flow
      state = state.copyWith(userEmail: emailToUse);

      NotifierHelper.closeToast(context);
      NotifierHelper.showSuccessToast(
          context, 'Reset link sent! Check your email and click the link.');

      // Go back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      NotifierHelper.showErrorToast(context, 'Error: ${e.toString()}');
    } finally {
      state = state.copyWith(isRequestingChange: false);
    }
  }

  Future<void> changePassword(
    BuildContext context,
    String newPassword,
    String email, [
    String? token,
  ]) async {
    try {
      NotifierHelper.showLoadingToast(context, 'Changing password');

      if (state.isAuthenticated) {
        // User is already logged in, just update password
        await supabase.auth.updateUser(UserAttributes(password: newPassword));
      } else {
        // For password reset via email link, the token is automatically handled
        // Just update the password
        await supabase.auth.updateUser(UserAttributes(password: newPassword));
      }

      NotifierHelper.closeToast(context);
      NotifierHelper.showSuccessToast(
          context, 'Password changed successfully!');

      // Sign out and navigate to login
      await supabase.auth.signOut();
      context.go('/login');
    } catch (e) {
      if (e is AuthException && e.message.contains('expired')) {
        NotifierHelper.showErrorToast(
            context, 'Your reset link has expired. Please request a new one.');
      } else if (e is AuthException && e.message.contains('Invalid')) {
        NotifierHelper.showErrorToast(
            context, 'Invalid or expired link. Please request a new one.');
      } else {
        NotifierHelper.showErrorToast(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> fetchRelatedData(bool isInitialLoad) async {
    // final sensorNotifier = ref.read(sensorsProvider.notifier);
    // final weatherNotifier = ref.read(weatherProvider.notifier);
    // final cropsNotifier = ref.read(cropProvider.notifier);
    // final chatbotNotifier = ref.read(chatbotProvider.notifier);

    // await sensorNotifier.fetchSensors();
    // await weatherNotifier.fetchWeather();
    // await chatbotNotifier.fetchConversations();
    // await cropsNotifier.fetchAllCrops();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      state = UserAuthState();
      context.go('/login');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> tryToSignIn(
      BuildContext context, String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (state.isRegistering) {
        context.go('/setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (e is AuthException) {
        if (e.message.contains('Email not confirmed')) {
          NotifierHelper.showErrorToast(
              context, 'Email not confirmed, check your inbox.');
        } else {
          NotifierHelper.showErrorToast(context, e.message);
        }
      } else {
        NotifierHelper.showErrorToast(context, 'An unexpected error occurred.');
        print('Error: $e');
      }
    }
  }

  Future<void> resendEmailVerification(
      BuildContext context, String email, String password) async {
    // Trim inputs to remove whitespace
    email = email.trim();
    password = password.trim();

    try {
      NotifierHelper.showLoadingToast(
          context, 'Resending verification email...');
      await supabase.auth.signUp(password: password, email: email);
      NotifierHelper.showSuccessToast(context, 'Verification email resent!');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> saveDeviceToken(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from("users").upsert({
      'user_id': userId,
      'device_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  /// Mark onboarding as complete in database and state
  Future<void> completeOnboarding(BuildContext context) async {
    final userId = state.userId;
    if (userId == null) {
      NotifierHelper.showErrorToast(context, 'User not authenticated');
      return;
    }

    try {
      NotifierHelper.showLoadingToast(context, 'Completing setup...');

      // Update database
      await supabase.from('users').update({
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      // Update state
      state = state.copyWith(onboardingComplete: true);

      NotifierHelper.closeToast(context);
      NotifierHelper.showSuccessToast(context, 'Profile setup complete! 🎉');

      // Navigate to home
      context.go('/home');
    } catch (e) {
      NotifierHelper.closeToast(context);
      NotifierHelper.showErrorToast(
          context, 'Failed to complete setup: ${e.toString()}');
      NotifierHelper.logError(e);
    }
  }

  /// Check if user has completed onboarding
  bool get hasCompletedOnboarding => state.onboardingComplete;
}

final authProvider =
    NotifierProvider<AuthNotifier, UserAuthState>(() => AuthNotifier());
