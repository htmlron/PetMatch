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
  final int? groomingNeeds; // 0-5 scale
  final int? sheddingLevel; // 0-5 scale (hairiness / shedding)

  // Activity & Personality
  final int? energyLevel; // 0-5 scale
  final int? playfulness; // 0-5 scale
  final String? dailyExercise;

  // Temperament
  final int? affectionLevel; // 0-5 scale
  final int? independence; // 0-5 scale
  final int? adaptability; // 0-5 scale
  final int? trainingDifficulty; // 0-5 scale
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
    this.sheddingLevel,
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
      if (value is String) {
        final direct = int.tryParse(value.trim());
        if (direct != null) return direct;
        final match = RegExp(r'(\d+)').firstMatch(value);
        if (match != null) return int.tryParse(match.group(1)!);
        return null;
      }
      return null;
    }

    
    // Post-process some fields that were easier to compute outside the constructor call
    // (we couldn't reference local vars inline cleanly for complex parsing)
    // Parse vaccination types (could be List or comma-separated String)
    final vaxRaw = healthNotes?['vaccination_types'];
    final List<String> parsedVaxTypes;
    if (vaxRaw == null) {
      parsedVaxTypes = <String>[];
    } else if (vaxRaw is List) {
      parsedVaxTypes = vaxRaw.map((e) => e.toString()).toList();
    } else {
      parsedVaxTypes = vaxRaw.toString().split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
    }

    // Parse vaccination update months using helper
    final vaxUpdateMonths = parseInt(healthNotes?['vaccination_update_months']);

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
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      goodWithChildren: behaviorTags?['good_with_children'] as bool?,
      goodWithDogs: behaviorTags?['good_with_dogs'] as bool?,
      goodWithCats: behaviorTags?['good_with_cats'] as bool?,
      houseTrained: behaviorTags?['house_trained'] as bool?,
      vaccinations: healthNotes?['vaccinations'] as bool?,
      vaccinationTypes: parsedVaxTypes,
      vaccinationUpdateMonths: vaxUpdateMonths,
      spayedNeutered: healthNotes?['spayed_neutered'] as bool?,
      specialNeeds: healthNotes?['special_needs'] as bool?,
      groomingNeeds: parseInt(temperament?['grooming_needs']),
      sheddingLevel: parseInt(temperament?['shedding_level']),
      energyLevel: parseInt(activityLevel?['energy_level']),
      playfulness: parseInt(activityLevel?['playfulness']),
        dailyExercise: (activityLevel?['daily_exercise'] ??
            activityLevel?['daily_exercise_needs'])
          as String?,
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
        .map((filename) => supabase.storage.from(bucketName).getPublicUrl('$id/$filename').toString())
        .toList();
  }

  String? get thumbnailUrl {
    if (thumbnailPath == null || thumbnailPath!.isEmpty) {
      return null;
    }
    const bucketName = 'pets';
    return supabase.storage.from(bucketName).getPublicUrl('$id/$thumbnailPath').toString();
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

  // Get shedding / hairiness description
  String getSheddingDescription() {
    if (sheddingLevel == null) return 'Unknown';
    switch (sheddingLevel!.clamp(0, 5)) {
      case 0:
        return 'Low shedding';
      case 1:
        return 'Light shedding';
      case 2:
        return 'Some fur';
      case 3:
        return 'Noticeable shedding';
      case 4:
        return 'Lots of fur';
      case 5:
        return 'Heavy shedding';
      default:
        return 'Unknown';
    }
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

  /// Returns formatted text like `6 months` or `1 month`.
  String? get vaccinationUpdateMonthsText {
    final months = vaccinationUpdateMonths;
    if (months == null) return null;
    final unit = months == 1 ? 'month' : 'months';
    return '$months $unit';
  }

  /// Returns formatted suffix like ` (6 months)` for UI labels.
  String get vaccinationUpdateMonthsSuffix {
    final text = vaccinationUpdateMonthsText;
    if (text == null) return '';
    return ' ($text)';
  }
}
