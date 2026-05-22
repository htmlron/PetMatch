import 'package:petmatch/core/model/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class UserAuthState with _$UserAuthState {
  factory UserAuthState({
    AppUser? userProfile,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPassword,
    String? userType,
    int? failedAttempts,
    DateTime? lockoutTime,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoggingIn,
    @Default(false) bool isRegistering,
    @Default(false) bool isRequestingChange,
    @Default(false) bool onboardingComplete,
  }) = _UserAuthState;
}
