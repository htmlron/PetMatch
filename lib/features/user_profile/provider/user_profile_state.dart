import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_state.freezed.dart';
part 'user_profile_state.g.dart';

/// State class to hold user profile/onboarding data
@freezed
class UserProfileState with _$UserProfileState {
  const UserProfileState._();

  const factory UserProfileState({
    // Pet preference
    String? petPreference,

    // Activity level (Step 1)
    int? activityLevel, // 0-5
    String? activityLabel,

    // Affection level (Step 2)
    int? affectionLevel, // 0-5
    String? affectionLabel,

    // Patience level (Step 3)
    int? patienceLevel, // 0-5
    String? patienceLabel,

    // Hairiness preference (new, 0-5)
    int? hairinessLevel, // 0-5
    String? hairinessLabel,

    // Grooming level (Step 4)
    int? groomingLevel, // 0-5
    String? groomingLabel,

    // Household fields
    bool? hasChildren,
    bool? hasOtherPets,
    String? existingPetsDescription,
    bool? comfortableWithShyPet,
    bool? financialReady,
    bool? hadPetBefore,
    bool? okayWithSpecialNeeds,

    // Additional fields for future steps
    String? livingSpace, // e.g., 'Apartment', 'House', etc.
    String? experience, // e.g., 'First-time', 'Experienced', etc.
    List<String>? preferredBreeds,
    String? agePreference, // e.g., 'Puppy', 'Adult', 'Senior'
    String? sizePreference, // e.g., 'Small', 'Medium', 'Large'

    // Metadata
    @Default(false) bool isComplete,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _UserProfileState;

  factory UserProfileState.fromJson(Map<String, dynamic> json) =>
      _$UserProfileStateFromJson(json);

  bool get isValid {
    return petPreference != null &&
        activityLevel != null &&
        affectionLevel != null &&
      patienceLevel != null &&
      hairinessLevel != null &&
      groomingLevel != null;
  }

  int get completionPercentage {
    int filledFields = 0;
    int totalFields = 6;

    if (petPreference != null) filledFields++;
    if (activityLevel != null) filledFields++;
    if (affectionLevel != null) filledFields++;
    if (patienceLevel != null) filledFields++;
    if (hairinessLevel != null) filledFields++;
    if (groomingLevel != null) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }
}
