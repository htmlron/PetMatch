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

    // Lifestyle compatibility preferences (tap-to-select)
    String? livingEnvironment,
    String? dailyAvailability,
    String? petOwnershipExperience,
    String? lifestylePace,
    String? budgetForPetCare,

    // Household fields
    bool? hasChildren,
    bool? hasOtherPets,
    String? existingPetsDescription,
    bool? comfortableWithShyPet,
    bool? financialReady,
    bool? hadPetBefore,
    bool? okayWithSpecialNeeds,

    // Additional fields for future steps
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
        livingEnvironment != null &&
        dailyAvailability != null &&
        petOwnershipExperience != null &&
        lifestylePace != null &&
        budgetForPetCare != null;
  }

  int get completionPercentage {
    int filledFields = 0;
    int totalFields = 6;

    if (petPreference != null) filledFields++;
    if (livingEnvironment != null) filledFields++;
    if (dailyAvailability != null) filledFields++;
    if (petOwnershipExperience != null) filledFields++;
    if (lifestylePace != null) filledFields++;
    if (budgetForPetCare != null) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }
}
