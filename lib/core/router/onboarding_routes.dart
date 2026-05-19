import 'package:go_router/go_router.dart';
import 'package:petmatch/features/user_profile/presentation/screen/activity_level_setup.dart';
import 'package:petmatch/features/user_profile/presentation/screen/affection_level_setup.dart';
import 'package:petmatch/features/user_profile/presentation/screen/hairiness_level_setup.dart';
import 'package:petmatch/features/user_profile/presentation/screen/patience_level_setup.dart';
import 'package:petmatch/features/user_profile/presentation/screen/grooming_level_setup.dart';
import 'package:petmatch/features/user_profile/presentation/screen/pet_preference.dart';
import 'package:petmatch/features/user_profile/presentation/screen/size_preference.dart';
import 'package:petmatch/features/user_profile/presentation/screen/household_setup.dart';
import 'package:petmatch/features/user_profile/presentation/widgets/saving_loading.dart';

/// Onboarding/User Profile Setup Routes
/// These routes are accessed after successful registration and email verification
final onboardingRoutes = [
  GoRoute(
    path: '/onboarding',
    name: 'onboarding',
    redirect: (context, state) => '/onboarding/pet-preference',
  ),

  // Step 0: Pet Preference (Starting point)
  GoRoute(
    path: '/onboarding/pet-preference',
    name: 'pet-preference',
    builder: (context, state) => const PetPreferenceScreen(),
  ),

  // Step 1: Activity Level
  GoRoute(
    path: '/onboarding/activity-level',
    name: 'activity-level',
    builder: (context, state) => const ActivityLevelSetupScreen(),
  ),

  // Step 2: Patience Level
  GoRoute(
    path: '/onboarding/patience-level',
    name: 'patience-level',
    builder: (context, state) => const PatienceLevelSetupScreen(),
  ),

  // Step 3: Affection Level
  GoRoute(
    path: '/onboarding/affection-level',
    name: 'affection-level',
    builder: (context, state) => const AffectionLevelSetupScreen(),
  ),

  // Step 4: Hairiness Preference
  GoRoute(
    path: '/onboarding/hairiness-level',
    name: 'hairiness-level',
    builder: (context, state) => const HairinessLevelSetupScreen(),
  ),

  // Step 5: Grooming Level
  GoRoute(
    path: '/onboarding/grooming-level',
    name: 'grooming-level',
    builder: (context, state) => const GroomingLevelSetupScreen(),
  ),

  // Step 6: Size Preference
  GoRoute(
    path: '/onboarding/size-preference',
    name: 'size-preference',
    builder: (context, state) => const SizePreferenceScreen(),
  ),

  // Step 7: Household Setup
  GoRoute(
    path: '/onboarding/household',
    name: 'onboarding-household-setup',
    builder: (context, state) => const HouseholdSetupScreen(),
  ),

  GoRoute(
    path: '/onboarding/profile-loading',
    name: 'onboarding-profile-loading',
    builder: (context, state) => const ProfileLoadingScreen(),
  ),
];
