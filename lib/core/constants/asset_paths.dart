/// Asset paths for user profile/onboarding screens
class UserProfileAssets {
  // Base path for all user profile assets
  static const String _basePath = 'assets/user_profile';

  // Activity level faces
  static const String activityInactive =
      '$_basePath/activities_faces/inactive.png';
  static const String activityLightlyActive =
      '$_basePath/activities_faces/lightly_active.png';
  static const String activityModeratelyActive =
      '$_basePath/activities_faces/moderately_active.png';
  static const String activityVeryActive =
      '$_basePath/activities_faces/very_active.png';
  static const String activityExtremelyActive =
      '$_basePath/activities_faces/extremely_active.png';

  // Patience level faces
  static const String patienceVeryLow =
      '$_basePath/patience_faces/very_low.png';
  static const String patienceSomewhatLow =
      '$_basePath/patience_faces/somewhat_low.png';
  static const String patienceModerate =
      '$_basePath/patience_faces/moderate.png';
  static const String patiencePrettyHigh =
      '$_basePath/patience_faces/pretty_high.png';
  static const String patienceVeryHigh =
      '$_basePath/patience_faces/very_high.png';

  // Affection level faces
  static const String affectionVeryIndependent =
      '$_basePath/affection_faces/very_independent.png';
  static const String affectionSomewhatIndependent =
      '$_basePath/affection_faces/somewhat_independent.png';
  static const String affectionBalanced =
      '$_basePath/affection_faces/balanced.png';
  static const String affectionPrettyAffectionate =
      '$_basePath/affection_faces/pretty_affectionate.png';
  static const String affectionVeryAffectionate =
      '$_basePath/affection_faces/very_affectionate.png';

  // Grooming level faces
  static const String groomingLowMaintenance =
      '$_basePath/grooming_faces/low_maintenance.png';
  static const String groomingBasicCare =
      '$_basePath/grooming_faces/basic_care.png';
  static const String groomingRegularGrooming =
      '$_basePath/grooming_faces/regular_grooming.png';
  static const String groomingFrequentCare =
      '$_basePath/grooming_faces/frequent_care.png';
  static const String groomingHighMaintenance =
      '$_basePath/grooming_faces/high_maintenance.png';

    // Hairiness level faces (0-5)
    // Note: level 0 and level 1 intentionally share the same image.
    static const String hairinessLevel0 =
        '$_basePath/hairiness_faces/Gemini_Generated_Image_6cuhpr6cuhpr6cuh-removebg-preview.png';
    static const String hairinessLevel1 =
        '$_basePath/hairiness_faces/Gemini_Generated_Image_6cuhpr6cuhpr6cuh-removebg-preview.png';
    static const String hairinessLevel2 =
        '$_basePath/hairiness_faces/Gemini_Generated_Image_jd0fc4jd0fc4jd0f-removebg-preview.png';
    static const String hairinessLevel3 =
        '$_basePath/hairiness_faces/Gemini_Generated_Image_lmthezlmthezlmth-removebg-preview.png';
    static const String hairinessLevel4 =
        '$_basePath/hairiness_faces/Gemini_Generated_Image_2ameoi2ameoi2ame-removebg-preview.png';
    static const String hairinessLevel5 =
        '$_basePath/hairiness_faces/Gemini_Generated_Image_om3rsjom3rsjom3r-removebg-preview.png';

  // Pet preference images
  static const String petPreferenceCat = '$_basePath/pet_preference/cat.png';
  static const String petPreferenceDog = '$_basePath/pet_preference/dog.png';
  static const String petPreferenceBoth = '$_basePath/pet_preference/both.png';

  // Size preference images
  static const String sizeSmallCat = '$_basePath/size_preference/small_cat.png';
  static const String sizeMediumCat =
      '$_basePath/size_preference/medium_cat.png';
  static const String sizeLargeCat = '$_basePath/size_preference/large_cat.png';
  static const String sizeSmallDog = '$_basePath/size_preference/small_dog.png';
  static const String sizeMediumDog =
      '$_basePath/size_preference/medium_dog.png';
  static const String sizeLargeDog = '$_basePath/size_preference/large_dog.png';
  static const String sizeNoCat = '$_basePath/size_preference/no_cat.png';
  static const String sizeNoDog = '$_basePath/size_preference/no_dog.png';

  // Get all asset paths for preloading
  static List<String> getAllAssets() {
    return [
      // Activity faces
      activityInactive,
      activityLightlyActive,
      activityModeratelyActive,
      activityVeryActive,
      activityExtremelyActive,

      // Patience faces
      patienceVeryLow,
      patienceSomewhatLow,
      patienceModerate,
      patiencePrettyHigh,
      patienceVeryHigh,

      // Affection faces
      affectionVeryIndependent,
      affectionSomewhatIndependent,
      affectionBalanced,
      affectionPrettyAffectionate,
      affectionVeryAffectionate,

      // Grooming faces
      groomingLowMaintenance,
      groomingBasicCare,
      groomingRegularGrooming,
      groomingFrequentCare,
      groomingHighMaintenance,

      // Hairiness faces
      hairinessLevel0,
      hairinessLevel1,
      hairinessLevel2,
      hairinessLevel3,
      hairinessLevel4,
      hairinessLevel5,

      // Pet preferences
      petPreferenceCat,
      petPreferenceDog,
      petPreferenceBoth,

      // Size preferences
      sizeSmallCat,
      sizeMediumCat,
      sizeLargeCat,
      sizeSmallDog,
      sizeMediumDog,
      sizeLargeDog,
      sizeNoCat,
      sizeNoDog,
    ];
  }

  // Get activity level assets
  static List<String> getActivityAssets() {
    return [
      activityInactive,
      activityLightlyActive,
      activityModeratelyActive,
      activityVeryActive,
      activityExtremelyActive,
    ];
  }

  // Get patience level assets
  static List<String> getPatienceAssets() {
    return [
      patienceVeryLow,
      patienceSomewhatLow,
      patienceModerate,
      patiencePrettyHigh,
      patienceVeryHigh,
    ];
  }

  // Get affection level assets
  static List<String> getAffectionAssets() {
    return [
      affectionVeryIndependent,
      affectionSomewhatIndependent,
      affectionBalanced,
      affectionPrettyAffectionate,
      affectionVeryAffectionate,
    ];
  }

  // Get grooming level assets
  static List<String> getGroomingAssets() {
    return [
      groomingLowMaintenance,
      groomingBasicCare,
      groomingRegularGrooming,
      groomingFrequentCare,
      groomingHighMaintenance,
    ];
  }

  static List<String> getHairinessAssets() {
    return [
      hairinessLevel0,
      hairinessLevel1,
      hairinessLevel2,
      hairinessLevel3,
      hairinessLevel4,
      hairinessLevel5,
    ];
  }

  // Get pet preference assets
  static List<String> getPetPreferenceAssets() {
    return [
      petPreferenceCat,
      petPreferenceDog,
      petPreferenceBoth,
    ];
  }

  // Get size preference assets
  static List<String> getSizePreferenceAssets() {
    return [
      sizeSmallCat,
      sizeMediumCat,
      sizeLargeCat,
      sizeSmallDog,
      sizeMediumDog,
      sizeLargeDog,
      sizeNoCat,
      sizeNoDog,
    ];
  }
}
