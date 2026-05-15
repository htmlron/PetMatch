import 'package:petmatch/core/config/supabase_config.dart';

class Pet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final String? gender;
  final int? age;
  final String? ageUnit;
  final String? size;
  final String? description;
  final String? thumbnailPath;
  final List<String> imageUrls;
  final String? ownerId;
  final bool isAdopted;
  final String? availablity;
  final String? status;
  final DateTime? createdAt;

  // Behavior traits
  final bool? goodWithChildren;
  final bool? goodWithDogs;
  final bool? goodWithCats;
  final bool? houseTrained;

  // Health information
  final bool? vaccinations;
  final List<String> vaccinationTypes;
  final int? vaccinationUpdateMonths;
  final bool? spayedNeutered;
  final bool? specialNeeds;
  final int? groomingNeeds; // 1-5 scale

  // Activity & Personality
  final int? energyLevel; // 1-5 scale
  final int? playfulness; // 1-5 scale
  final String? dailyExercise;

  // Temperament
  final int? affectionLevel; // 1-5 scale
  final int? independence; // 1-5 scale
  final int? adaptability; // 1-5 scale
  final int? trainingDifficulty; // 1-5 scale
  final List<String> temperamentTraits;
  final String? quirks;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.gender,
    this.age,
    this.ageUnit,
    this.size,
    this.description,
    this.thumbnailPath,
    this.imageUrls = const [],
    this.ownerId,
    this.isAdopted = false,
    this.availablity,
    this.status,
    this.createdAt,
    this.goodWithChildren,
    this.goodWithDogs,
    this.goodWithCats,
    this.houseTrained,
    this.vaccinations,
    this.vaccinationTypes = const [],
    this.vaccinationUpdateMonths,
    this.spayedNeutered,
    this.specialNeeds,
    this.groomingNeeds,
    this.energyLevel,
    this.playfulness,
    this.dailyExercise,
    this.affectionLevel,
    this.independence,
    this.adaptability,
    this.trainingDifficulty,
    this.temperamentTraits = const [],
    this.quirks,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    // Parse images from pets_images join
    List<String> images = [];

    if (json['pets_images'] != null) {
      final petsImages = json['pets_images'] as List<dynamic>;
      images = petsImages
          .map((img) => img['image_path'] as String?)
          .where((path) => path != null && path.isNotEmpty)
          .cast<String>()
          .toList();
    }

    // Parse characteristics from pet_characteristics table
    Map<String, dynamic>? behaviorTags;
    Map<String, dynamic>? healthNotes;
    Map<String, dynamic>? activityLevel;
    Map<String, dynamic>? temperament;
    String? quirk;

    if (json['pet_characteristics'] != null) {
      final characteristics = json['pet_characteristics'] is List
          ? (json['pet_characteristics'] as List).isNotEmpty
              ? json['pet_characteristics'][0]
              : null
          : json['pet_characteristics'];

      if (characteristics != null) {
        behaviorTags =
            characteristics['behavior_tags'] as Map<String, dynamic>?;
        healthNotes = characteristics['health_notes'] as Map<String, dynamic>?;
        activityLevel =
            characteristics['activity_level'] as Map<String, dynamic>?;
        temperament = characteristics['temperament'] as Map<String, dynamic>?;
        quirk = characteristics['quirk'] as String?;
      }
    }

    // Parse temperament traits from temperament JSON
    List<String> traits = [];
    if (temperament != null && temperament['temperament_traits'] != null) {
      if (temperament['temperament_traits'] is List) {
        traits = (temperament['temperament_traits'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    // helper to safely parse ints from dynamic values (num or String)
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Pet(
      id: json['pet_id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      gender: json['gender'] as String?,
      age: parseInt(json['age']),
      size: json['size'] as String?,
      description: json['description'] as String?,
      thumbnailPath: json['thumbnail_path'] as String?,
      imageUrls: images,
      status: json['status'] as String?,
      isAdopted: (json['status'] as String?)?.toLowerCase() == 'adopted',
      availablity: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      // Behavior traits from behavior_tags
      goodWithChildren: behaviorTags?['good_with_children'] as bool?,
      goodWithDogs: behaviorTags?['good_with_dogs'] as bool?,
      goodWithCats: behaviorTags?['good_with_cats'] as bool?,
      houseTrained: behaviorTags?['house_trained'] as bool?,
        // Health information from health_notes
        vaccinations: healthNotes?['vaccinations'] as bool?,
        vaccinationTypes: ((healthNotes?['vaccination_types'] is List)
            ? (healthNotes?['vaccination_types'] as List).map((e) => e.toString()).toList()
            : (healthNotes?['vaccination_types'] != null && healthNotes!['vaccination_types'] is String)
              ? (healthNotes!['vaccination_types'] as String).split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList()
              : <String>[]),
        vaccinationUpdateMonths: healthNotes?['vaccination_update_months'] is int
          ? healthNotes?['vaccination_update_months'] as int?
          : (healthNotes?['vaccination_update_months'] is String
            ? int.tryParse(healthNotes?['vaccination_update_months'] as String)
            : null),
      spayedNeutered: healthNotes?['spayed_neutered'] as bool?,
      specialNeeds: healthNotes?['special_needs'] as bool?,
      groomingNeeds: parseInt(temperament?['grooming_needs']),
      // Activity & Personality from activity_level
      energyLevel: parseInt(activityLevel?['energy_level']),
      playfulness: parseInt(activityLevel?['playfulness']),
      dailyExercise: activityLevel?['daily_exercise'] as String?,
      // Temperament from temperament
      affectionLevel: parseInt(temperament?['affection_level']),
      independence: parseInt(temperament?['independence']),
      adaptability: parseInt(temperament?['adaptability']),
      trainingDifficulty: parseInt(temperament?['training_difficulty']),
      temperamentTraits: traits,
      quirks: quirk,
    );
  }

  List<String> get fullImageUrls {
    const bucketName = 'pets';

    List<String> imagesToUse = [];

    // Always add the thumbnail first if it exists
    if (thumbnailPath != null && thumbnailPath!.isNotEmpty) {
      imagesToUse.add(thumbnailPath!);
    }

    // Add other images from the database, but skip if it's the same as thumbnail
    for (var imageUrl in imageUrls) {
      if (imageUrl != thumbnailPath) {
        imagesToUse.add(imageUrl);
      }
    }

    return imagesToUse
        .map((filename) =>
            supabase.storage.from(bucketName).getPublicUrl('$id/$filename'))
        .toList();
  }

  String? get thumbnailUrl {
    if (thumbnailPath == null || thumbnailPath!.isEmpty) {
      return null;
    }
    const bucketName = 'pets';
    return supabase.storage.from(bucketName).getPublicUrl('$id/$thumbnailPath');
  }

  // Display age in friendly format
  String get displayAge {
    if (age == null) return 'Age unknown';
    final unit = ageUnit ?? 'years';
    return '$age $unit old';
  }

  // Get age category (Young/Adult)
  String get ageCategory {
    if (age == null) return 'Unknown';

    final unit = ageUnit?.toLowerCase() ?? 'years';

    if (unit == 'months' || unit == 'month') {
      // Less than 12 months is young
      return 'Young';
    } else if (unit == 'years' || unit == 'year') {
      // Less than 2 years is young, otherwise adult
      return age! < 2 ? 'Young' : 'Adult';
    }

    return 'Adult';
  }

  // Get energy level description
  String getEnergyLevelDescription() {
    if (energyLevel == null) return 'Unknown';
    if (energyLevel! <= 3) return 'Low - Prefers calm environments';
    if (energyLevel! <= 6) return 'Moderate - Balanced activity';
    return 'High - Very active and playful';
  }

  // Get affection level description
  String getAffectionLevelDescription() {
    if (affectionLevel == null) return 'Unknown';
    if (affectionLevel! <= 3) return 'Independent - Enjoys alone time';
    if (affectionLevel! <= 6) return 'Moderate - Balanced affection';
    return 'Very Affectionate - Loves cuddles';
  }

  // Get training difficulty description
  String getTrainingDescription() {
    if (trainingDifficulty == null) return 'Unknown';
    if (trainingDifficulty! <= 3) return 'Easy - Quick learner';
    if (trainingDifficulty! <= 6) return 'Moderate - Patient training';
    return 'Challenging - Needs experience';
  }

  // Get grooming needs description
  String getGroomingDescription() {
    if (groomingNeeds == null) return 'Unknown';
    if (groomingNeeds! <= 2) return 'Low - Minimal grooming';
    if (groomingNeeds! <= 3) return 'Moderate - Regular brushing';
    return 'High - Frequent grooming';
  }

  // Get adaptability description
  String getAdaptabilityDescription() {
    if (adaptability == null) return 'Unknown';
    if (adaptability! <= 3) return 'Prefers routine';
    if (adaptability! <= 6) return 'Moderately flexible';
    return 'Highly adaptable';
  }

  // Whether pet is considered vaccinated (either boolean or types present)
  bool get isVaccinated {
    if (vaccinationTypes.isNotEmpty) return true;
    return vaccinations == true;
  }

  /// Human friendly vaccination summary
  String get vaccinationSummary {
    if (vaccinationTypes.isNotEmpty) return vaccinationTypes.join(', ');
    if (vaccinations == true) return 'Vaccinated (types not specified)';
    return 'Unknown';
  }
}
