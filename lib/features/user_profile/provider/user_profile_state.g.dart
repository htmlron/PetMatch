// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileStateImpl _$$UserProfileStateImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileStateImpl(
      petPreference: json['petPreference'] as String?,
      livingEnvironment: json['livingEnvironment'] as String?,
      dailyAvailability: json['dailyAvailability'] as String?,
      petOwnershipExperience: json['petOwnershipExperience'] as String?,
      lifestylePace: json['lifestylePace'] as String?,
      budgetForPetCare: json['budgetForPetCare'] as String?,
      hasChildren: json['hasChildren'] as bool?,
      hasOtherPets: json['hasOtherPets'] as bool?,
      existingPetsDescription: json['existingPetsDescription'] as String?,
      comfortableWithShyPet: json['comfortableWithShyPet'] as bool?,
      financialReady: json['financialReady'] as bool?,
      hadPetBefore: json['hadPetBefore'] as bool?,
      okayWithSpecialNeeds: json['okayWithSpecialNeeds'] as bool?,
      preferredBreeds: (json['preferredBreeds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      agePreference: json['agePreference'] as String?,
      sizePreference: json['sizePreference'] as String?,
      isComplete: json['isComplete'] as bool? ?? false,
      isSubmitting: json['isSubmitting'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$UserProfileStateImplToJson(
        _$UserProfileStateImpl instance) =>
    <String, dynamic>{
      'petPreference': instance.petPreference,
      'livingEnvironment': instance.livingEnvironment,
      'dailyAvailability': instance.dailyAvailability,
      'petOwnershipExperience': instance.petOwnershipExperience,
      'lifestylePace': instance.lifestylePace,
      'budgetForPetCare': instance.budgetForPetCare,
      'hasChildren': instance.hasChildren,
      'hasOtherPets': instance.hasOtherPets,
      'existingPetsDescription': instance.existingPetsDescription,
      'comfortableWithShyPet': instance.comfortableWithShyPet,
      'financialReady': instance.financialReady,
      'hadPetBefore': instance.hadPetBefore,
      'okayWithSpecialNeeds': instance.okayWithSpecialNeeds,
      'preferredBreeds': instance.preferredBreeds,
      'agePreference': instance.agePreference,
      'sizePreference': instance.sizePreference,
      'isComplete': instance.isComplete,
      'isSubmitting': instance.isSubmitting,
      'errorMessage': instance.errorMessage,
    };
