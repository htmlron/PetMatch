// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/core/repository/user_profile_repository.dart';
import 'package:petmatch/features/home/provider/match_provider/match_provider.dart';
import 'package:petmatch/features/user_profile/provider/user_profile_state.dart';

/// Notifier to manage user profile state
class UserProfileNotifier extends Notifier<UserProfileState> {
  final UserProfileRepository _repository;

  UserProfileNotifier(this._repository);

  @override
  UserProfileState build() {
    return const UserProfileState();
  }

  String get userId {
    return ref.watch(authProvider).userId!;
  }

  String? _normalizeSizePreference(String? size) {
    if (size == null) return null;
    final normalized = size.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    if (normalized.contains('small')) return 'Small';
    if (normalized.contains('medium')) return 'Medium';
    if (normalized.contains('large')) return 'Large';
    if (normalized.contains('no preference')) return 'No Preference';

    return size;
  }

  void setPetPreference(BuildContext context, String preference) {
    state = state.copyWith(petPreference: preference);
    _logState('Pet preference saved: $preference');
    context.push('/onboarding/activity-level');
  }

  /// Update pet preference without navigation (for editing)
  void updatePetPreference(String preference) {
    state = state.copyWith(petPreference: preference);
    _logState('Pet preference updated: $preference');

    // Persist change immediately for edit flows
    try {
      _repository.updatePersonalityTrait(
        userId,
        'user_lifestyle',
        'pet_preference',
        preference,
      );
      print('✅ Pet preference persisted for user $userId');
    } catch (e) {
      print('❌ Failed to persist pet preference: $e');
    }
  }

  // Lifestyle compatibility preference setters (onboarding flow)
  void setLivingEnvironment(BuildContext context, String selection) {
    state = state.copyWith(livingEnvironment: selection);
    _logState('Living environment saved: $selection');
    context.push('/onboarding/patience-level');
  }

  void setBudgetForPetCare(BuildContext context, String selection) {
    state = state.copyWith(budgetForPetCare: selection);
    _logState('Budget for pet care saved: $selection');
    context.push('/onboarding/affection-level');
  }

  void setLifestylePace(BuildContext context, String selection) {
    state = state.copyWith(lifestylePace: selection);
    _logState('Lifestyle pace saved: $selection');
    context.push('/onboarding/hairiness-level');
  }

  void setDailyAvailability(BuildContext context, String selection) {
    state = state.copyWith(dailyAvailability: selection);
    _logState('Daily availability saved: $selection');
    context.push('/onboarding/grooming-level');
  }

  void setPetOwnershipExperience(BuildContext context, String selection) {
    state = state.copyWith(petOwnershipExperience: selection);
    _logState('Pet ownership experience saved: $selection');
    context.push('/onboarding/size-preference');
  }

  /// Persist an edited lifestyle preference (profile edit flow)
  void updateLifestylePreference({
    required String key, // JSON key inside user_lifestyle
    required String value,
  }) {
    switch (key) {
      case 'living_environment':
        state = state.copyWith(livingEnvironment: value);
        break;
      case 'daily_availability':
        state = state.copyWith(dailyAvailability: value);
        break;
      case 'pet_ownership_experience':
        state = state.copyWith(petOwnershipExperience: value);
        break;
      case 'lifestyle_pace':
        state = state.copyWith(lifestylePace: value);
        break;
      case 'budget_for_pet_care':
        state = state.copyWith(budgetForPetCare: value);
        break;
      default:
        throw ArgumentError('Unsupported lifestyle update key: $key');
    }

    _repository.updatePersonalityTrait(
      userId,
      'user_lifestyle',
      key,
      value,
    );

    _logState('user_lifestyle updated: $key = $value');
  }

  void setSizePreference(BuildContext context, String size) {
    state = state.copyWith(sizePreference: size);
    _logState('Size preference saved: $size');
    context.push('/onboarding/household');
  }

  /// Update size preference without navigation (for editing)
  void updateSizePreference(String size) {
    state = state.copyWith(sizePreference: size);
    _logState('Size preference updated: $size');

    try {
      _repository.updatePersonalityTrait(
        userId,
        'user_lifestyle',
        'size_preference',
        _normalizeSizePreference(size),
      );
      print('✅ Size preference persisted for user $userId');
      ref.read(matchProvider.notifier).fetchMatchedPets();
    } catch (e) {
      print('❌ Failed to persist size preference: $e');
    }
  }

  /// Save whether user has children
  void setHouseholdInfo(
    bool hasChildren,
    bool hasOtherPets,
    String? existingPetsDescription,
    bool comfortableWithShyPet,
    bool financialReady,
    bool hadPetBefore,
    bool okayWithSpecialNeeds,
  ) {
    state = state.copyWith(
      hasChildren: hasChildren,
      hasOtherPets: hasOtherPets,
      existingPetsDescription: existingPetsDescription,
      comfortableWithShyPet: comfortableWithShyPet,
      financialReady: financialReady,
      hadPetBefore: hadPetBefore,
      okayWithSpecialNeeds: okayWithSpecialNeeds,
    );
  }

  Future<bool> submitProfile() async {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    if (!state.isValid) {
      state = state.copyWith(
        errorMessage: 'Please complete all required fields',
      );
      print('❌ Profile incomplete. Cannot submit.');
      print('Missing fields:');
      if (state.petPreference == null) print('  - Pet preference');
      if (state.livingEnvironment == null) print('  - Living environment');
      if (state.dailyAvailability == null) print('  - Daily availability');
      if (state.petOwnershipExperience == null)
        print('  - Pet ownership experience');
      if (state.lifestylePace == null) print('  - Lifestyle pace');
      if (state.budgetForPetCare == null) print('  - Budget for pet care');
      return false;
    }

    try {
      state = state.copyWith(isSubmitting: true, errorMessage: null);
      print('📤 Submitting profile to backend...');
      print('Profile data: ${state.toJson()}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 5));

      await _repository.saveUserProfile(
        userId: userId!,
        userLifestyle: {
          'pet_preference': state.petPreference,
          'size_preference': _normalizeSizePreference(state.sizePreference),
          'living_environment': state.livingEnvironment,
          'daily_availability': state.dailyAvailability,
          'pet_ownership_experience': state.petOwnershipExperience,
          'lifestyle_pace': state.lifestylePace,
          'budget_for_pet_care': state.budgetForPetCare,
        },
        personalityTraits: const {},
        householdInfo: {
          'has_children': state.hasChildren,
          'has_other_pets': state.hasOtherPets,
          'existing_pets_description': state.existingPetsDescription,
          'shy_pet_ok': state.comfortableWithShyPet,
          'financial_ready': state.financialReady,
          'had_pet_before': state.hadPetBefore,
          'okay_with_special_needs': state.okayWithSpecialNeeds,
        },
      );

      // Refresh auth state so screens that depend on `onboardingComplete`
      // (like edit-mode profile screens) behave correctly immediately.
      await ref.read(authProvider.notifier).fetchUserRecord(userId);

      state = state.copyWith(
        isSubmitting: false,
        isComplete: true,
      );

      print('✅ Profile submitted successfully!');
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit profile: $e',
      );
      print('❌ Error submitting profile: $e');
      return false;
    }
  }

  void clearProfile() {
    state = const UserProfileState();
    print('🗑️  Profile cleared');
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Load user profile from Supabase
  Future<void> loadUserProfile() async {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    if (userId == null) {
      print('❌ No user ID found. Cannot load profile.');
      return;
    }

    try {
      print('📥 Loading user profile from database...');
      final profileData = await _repository.getUserProfile(userId);

      if (profileData == null) {
        print('⚠️  No profile found for user');
        return;
      }

      // Extract data from JSON fields
      final userLifestyle =
          profileData['user_lifestyle'] as Map<String, dynamic>?;
      final householdInfo =
          profileData['household_info'] as Map<String, dynamic>?;

      // Update state with loaded data
      state = state.copyWith(
        petPreference: userLifestyle?['pet_preference'] as String?,
        livingEnvironment: userLifestyle?['living_environment'] as String?,
        dailyAvailability: userLifestyle?['daily_availability'] as String?,
        petOwnershipExperience:
          userLifestyle?['pet_ownership_experience'] as String?,
        lifestylePace: userLifestyle?['lifestyle_pace'] as String?,
        budgetForPetCare: userLifestyle?['budget_for_pet_care'] as String?,
        sizePreference: userLifestyle?['size_preference'] as String?,
        hasChildren: householdInfo?['has_children'] as bool?,
        hasOtherPets: householdInfo?['has_other_pets'] as bool?,
        existingPetsDescription:
            householdInfo?['existing_pets_description'] as String?,
        comfortableWithShyPet: householdInfo?['shy_pet_ok'] as bool?,
        financialReady: householdInfo?['financial_ready'] as bool?,
        hadPetBefore: householdInfo?['had_pet_before'] as bool?,
        okayWithSpecialNeeds:
            householdInfo?['okay_with_special_needs'] as bool?,
        isComplete: true,
      );

      print('✅ Profile loaded successfully!');
      print('Profile data: ${state.toJson()}');
    } catch (e) {
      print('❌ Error loading profile: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load profile: $e',
      );
    }
  }

  void _logState(String message) {
    print('📝 $message');
    print('Current completion: ${state.completionPercentage}%');
    print('Profile state: ${state.toJson()}');
    print('─' * 50);
  }

  String getProfileSummary() {
    final buffer = StringBuffer();
    buffer.writeln('🐾 User Profile Summary:');
    buffer.writeln('Pet Preference: ${state.petPreference ?? "Not set"}');
    buffer.writeln(
      'Living Environment: ${state.livingEnvironment ?? "Not set"}');
    buffer.writeln(
      'Daily Availability: ${state.dailyAvailability ?? "Not set"}');
    buffer.writeln(
      'Pet Ownership Experience: ${state.petOwnershipExperience ?? "Not set"}');
    buffer.writeln('Lifestyle Pace: ${state.lifestylePace ?? "Not set"}');
    buffer.writeln(
      'Budget for Pet Care: ${state.budgetForPetCare ?? "Not set"}');
    buffer.writeln('Age Preference: ${state.agePreference ?? "Not set"}');
    buffer.writeln('Size Preference: ${state.sizePreference ?? "Not set"}');
    buffer.writeln('Completion: ${state.completionPercentage}%');
    buffer.writeln('Valid: ${state.isValid ? "✅" : "❌"}');
    return buffer.toString();
  }
}

final userProfileRepositoryProvider =
    Provider((ref) => UserProfileRepository());

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
        () => UserProfileNotifier(UserProfileRepository()));
