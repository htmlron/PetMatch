// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileStateImpl _$$UserProfileStateImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProfileStateImpl(
      petPreference: json['petPreference'] as String?,
      activityLevel: (json['activityLevel'] as num?)?.toInt(),
      activityLabel: json['activityLabel'] as String?,
      affectionLevel: (json['affectionLevel'] as num?)?.toInt(),
      affectionLabel: json['affectionLabel'] as String?,
      patienceLevel: (json['patienceLevel'] as num?)?.toInt(),
      patienceLabel: json['patienceLabel'] as String?,
      hairinessLevel: (json['hairinessLevel'] as num?)?.toInt(),
      hairinessLabel: json['hairinessLabel'] as String?,
      groomingLevel: (json['groomingLevel'] as num?)?.toInt(),
      groomingLabel: json['groomingLabel'] as String?,
      hasChildren: json['hasChildren'] as bool?,
      hasOtherPets: json['hasOtherPets'] as bool?,
      existingPetsDescription: json['existingPetsDescription'] as String?,
      comfortableWithShyPet: json['comfortableWithShyPet'] as bool?,
      financialReady: json['financialReady'] as bool?,
      hadPetBefore: json['hadPetBefore'] as bool?,
      okayWithSpecialNeeds: json['okayWithSpecialNeeds'] as bool?,
      livingSpace: json['livingSpace'] as String?,
      experience: json['experience'] as String?,
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
      'activityLevel': instance.activityLevel,
      'activityLabel': instance.activityLabel,
      'affectionLevel': instance.affectionLevel,
      'affectionLabel': instance.affectionLabel,
      'patienceLevel': instance.patienceLevel,
      'patienceLabel': instance.patienceLabel,
      'hairinessLevel': instance.hairinessLevel,
      'hairinessLabel': instance.hairinessLabel,
      'groomingLevel': instance.groomingLevel,
      'groomingLabel': instance.groomingLabel,
      'hasChildren': instance.hasChildren,
      'hasOtherPets': instance.hasOtherPets,
      'existingPetsDescription': instance.existingPetsDescription,
      'comfortableWithShyPet': instance.comfortableWithShyPet,
      'financialReady': instance.financialReady,
      'hadPetBefore': instance.hadPetBefore,
      'okayWithSpecialNeeds': instance.okayWithSpecialNeeds,
      'livingSpace': instance.livingSpace,
      'experience': instance.experience,
      'preferredBreeds': instance.preferredBreeds,
      'agePreference': instance.agePreference,
      'sizePreference': instance.sizePreference,
      'isComplete': instance.isComplete,
      'isSubmitting': instance.isSubmitting,
      'errorMessage': instance.errorMessage,
    };
