import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:petmatch/core/model/pet_match_model.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Stable, fast, and free
      apiKey: apiKey,
    );
  }

  Future<String> generateMatchExplanation(
    PetMatch petMatch, {
    Map<String, dynamic>? userLifestyle,
    Map<String, dynamic>? userPersonality,
    Map<String, dynamic>? userHousehold,
  }) async {
    final prompt = _buildMatchExplanationPrompt(
      petMatch,
      userLifestyle: userLifestyle,
      userPersonality: userPersonality,
      userHousehold: userHousehold,
    );

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Unable to generate explanation at this time.';
    } catch (e) {
      print('Error generating match explanation: $e');
      return 'Unable to generate explanation. Please try again later.';
    }
  }

  String _buildMatchExplanationPrompt(
    PetMatch petMatch, {
    Map<String, dynamic>? userLifestyle,
    Map<String, dynamic>? userPersonality,
    Map<String, dynamic>? userHousehold,
  }) {
    final pet = petMatch.pet;

    // Backward-compatible: this prompt is now lifestyle-focused.
    // ignore: unused_local_variable
    final unusedUserPersonality = userPersonality;

    String yesNoUnknown(dynamic value) {
      if (value is bool) return value ? 'Yes' : 'No';
      return 'Unknown';
    }

    String stringOrUnknown(dynamic value) {
      if (value == null) return 'Unknown';
      final asString = value.toString().trim();
      return asString.isEmpty ? 'Unknown' : asString;
    }

    final userLivingEnvironment =
        stringOrUnknown(userLifestyle?['living_environment']);
    final userDailyAvailability =
        stringOrUnknown(userLifestyle?['daily_availability']);
    final userPetOwnershipExperience =
        stringOrUnknown(userLifestyle?['pet_ownership_experience']);
    final userLifestylePace = stringOrUnknown(userLifestyle?['lifestyle_pace']);
    final userBudgetForPetCare =
        stringOrUnknown(userLifestyle?['budget_for_pet_care']);
    final userPetPreference = stringOrUnknown(userLifestyle?['pet_preference']);
    final userSizePreference = stringOrUnknown(userLifestyle?['size_preference']);

    final userHasChildren = userHousehold?['has_children'];
    final userHasOtherPets = userHousehold?['has_other_pets'];
    final userComfortableWithShyPet = userHousehold?['shy_pet_ok'];
    final userHadPetBefore = userHousehold?['had_pet_before'];

    final petGoodWithChildren = pet.goodWithChildren == null
        ? 'Unknown'
        : (pet.goodWithChildren! ? 'Yes' : 'No');
    final petGoodWithDogs = pet.goodWithDogs == null
        ? 'Unknown'
        : (pet.goodWithDogs! ? 'Yes' : 'No');
    final petGoodWithCats = pet.goodWithCats == null
        ? 'Unknown'
        : (pet.goodWithCats! ? 'Yes' : 'No');
    final petHouseTrained = pet.houseTrained == null
        ? 'Unknown'
        : (pet.houseTrained! ? 'Yes' : 'No');

    // activity_level JSON
    final petEnergyLevel = pet.energyLevel ?? 0;
    final petPlayfulness = pet.playfulness ?? 0;
    final petDailyExerciseNeeds = pet.dailyExercise ?? 'Unknown';

    // temperament JSON
    final petAffectionLevel = pet.affectionLevel ?? 0;
    final petIndependence = pet.independence ?? 0;
    final petGroomingNeeds = pet.groomingNeeds ?? 0;
    final petAdaptability = pet.adaptability ?? 0;
    final petTrainingDifficulty = pet.trainingDifficulty ?? 0;
    final petTraits = pet.temperamentTraits.isNotEmpty
        ? pet.temperamentTraits.join(', ')
        : 'Not specified';
    final petQuirks = pet.quirks ?? 'None';
    final hasQuirk = pet.quirks != null && pet.quirks!.trim().isNotEmpty;

    // health_notes JSON
    final petSpecialNeeds = pet.specialNeeds == null
        ? 'Unknown'
        : (pet.specialNeeds! ? 'Yes' : 'No');
    final petVaccinations = pet.isVaccinated
        ? (pet.vaccinationTypes.isNotEmpty
        ? '${pet.vaccinationTypes.join(', ')}${pet.vaccinationUpdateMonthsSuffix}'
        : 'Yes${pet.vaccinationUpdateMonthsSuffix}')
        : 'No';
    final petSpayedNeutered = pet.spayedNeutered == null
        ? 'Unknown'
        : (pet.spayedNeutered! ? 'Yes' : 'No');

    String bucketedDescriptor(
      int value, {
      required String low,
      required String mid,
      required String high,
    }) {
      final clamped = value.clamp(0, 5);
      if (clamped <= 1) return low;
      if (clamped <= 3) return mid;
      return high;
    }

    final petEnergyDescription = bucketedDescriptor(
      petEnergyLevel,
      low: 'Very calm / low energy',
      mid: 'Moderate energy',
      high: 'High energy',
    );
    final petPlayfulnessDescription = bucketedDescriptor(
      petPlayfulness,
      low: 'Not very playful',
      mid: 'Moderately playful',
      high: 'Very playful',
    );
    final petAffectionDescription = bucketedDescriptor(
      petAffectionLevel,
      low: 'More independent',
      mid: 'Balanced affection',
      high: 'Very affectionate / cuddly',
    );
    final petIndependenceDescription = bucketedDescriptor(
      petIndependence,
      low: 'Prefers lots of closeness',
      mid: 'Balanced independence',
      high: 'Very independent',
    );
    final petAdaptabilityDescription = bucketedDescriptor(
      petAdaptability,
      low: 'Prefers routine',
      mid: 'Moderately flexible',
      high: 'Highly adaptable',
    );
    final petTrainingDescription = bucketedDescriptor(
      petTrainingDifficulty,
      low: 'Easier to train',
      mid: 'Moderate training needs',
      high: 'More challenging to train',
    );
    final petGroomingDescription = bucketedDescriptor(
      petGroomingNeeds,
      low: 'Low grooming needs',
      mid: 'Moderate grooming needs',
      high: 'High grooming needs',
    );

    String scoreStrength(num? percent) {
      final p = (percent ?? 0).toDouble();
      if (p >= 80) return 'Very strong';
      if (p >= 65) return 'Strong';
      if (p >= 50) return 'Moderate';
      return 'Lower';
    }

    final scoreStrengths = <String, String>{
      'Lifestyle': scoreStrength(petMatch.lifestyleScore),
      'Personality': scoreStrength(petMatch.personalityScore),
      'Household': scoreStrength(petMatch.householdScore),
      'Health & Grooming': scoreStrength(petMatch.healthScore),
    };

    final topAreas = scoreStrengths.entries
        .where((e) => e.value == 'Very strong' || e.value == 'Strong')
        .map((e) => e.key)
        .toList();

    return '''
You are a pet adoption expert AI helping users understand why a pet is a great match for THEM specifically.

Always consider these pet fields when explaining matches: `size`, `age`, `ageUnit`, `species`, `breed`, `energyLevel`, `playfulness`, `dailyExercise`, `temperamentTraits`, `quirks`, `goodWithChildren`, `goodWithDogs`, `goodWithCats`, `houseTrained`, `specialNeeds`, `vaccinationTypes`, `spayedNeutered`, `groomingNeeds`, `sheddingLevel`.

Always consider these user profile fields: `living_environment`, `daily_availability`, `pet_ownership_experience`, `lifestyle_pace`, `budget_for_pet_care`, `pet_preference`, `size_preference`, and household flags (`has_children`, `has_other_pets`, `shy_pet_ok`, `had_pet_before`). Use the exact selected option strings from the user's profile when referring to their preferences (for example: "size preference (Subdivision)" or "Lifestyle Pace (Relaxed)"). If a user field is `Unknown`, omit it from the explanation.

Your task is to explain clearly WHY THIS PET matches THIS USER by directly comparing the user's provided answers with the pet's characteristics.

🧑 USER PROFILE (The person adopting):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Lifestyle Preferences:
  • Living Environment: $userLivingEnvironment
  • Daily Availability: $userDailyAvailability
  • Pet Ownership Experience: $userPetOwnershipExperience
  • Lifestyle Pace: $userLifestylePace
  • Budget for Pet Care: $userBudgetForPetCare
  • Pet Type Preference: $userPetPreference
  • Size Preference: $userSizePreference

Household Situation:
  • Has Children: ${yesNoUnknown(userHasChildren)}
  • Has Other Pets: ${yesNoUnknown(userHasOtherPets)}
  • Comfortable with Shy Pets: ${yesNoUnknown(userComfortableWithShyPet)}
  • Previous Pet Experience: ${yesNoUnknown(userHadPetBefore)}

🐾 PET CHARACTERISTICS (${pet.name}):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Basic Info:
  • Name: ${pet.name}
  • Species: ${pet.species}
  • Breed: ${pet.breed ?? 'Mixed'}
  • Age: ${pet.age ?? '?'} ${pet.ageUnit ?? 'years'}
  • Size: ${pet.size ?? 'Unknown'}
  • Gender: ${pet.gender ?? 'Unknown'}

Activity & Energy:
  • Energy: $petEnergyDescription
  • Playfulness: $petPlayfulnessDescription
  • Daily Exercise Needs: $petDailyExerciseNeeds

Temperament & Personality:
  • Affection: $petAffectionDescription
  • Independence: $petIndependenceDescription
  • Adaptability: $petAdaptabilityDescription
  • Training: $petTrainingDescription
  • Grooming: $petGroomingDescription
  • Personality Traits: $petTraits
  • Quirks: $petQuirks ${hasQuirk ? '⭐ (This is a unique characteristic!)' : ''}

Behavior & Compatibility:
  • Good with Children: $petGoodWithChildren
  • Good with Dogs: $petGoodWithDogs
  • Good with Cats: $petGoodWithCats
  • House Trained: $petHouseTrained

Health Status:
  • Special Needs: $petSpecialNeeds
  • Vaccinated: $petVaccinations
  • Spayed/Neutered: $petSpayedNeutered

📊 MATCH SCORES (from SQL function):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • Overall Match Label: ${petMatch.matchLabel}
  • Lifestyle Compatibility: ${scoreStrengths['Lifestyle']} (Home, availability, pace, budget, type/size)
  • Personality Compatibility: ${scoreStrengths['Personality']} (Temperament alignment)
  • Household Compatibility: ${scoreStrengths['Household']} (Children, Other pets, Shy pet comfort)
  • Health & Grooming: ${scoreStrengths['Health & Grooming']} (Grooming needs, Special needs)
  • Top Match Areas (to highlight): ${topAreas.isEmpty ? 'None stand out strongly' : topAreas.join(', ')}

📝 YOUR TASK:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write a warm, friendly, personalized explanation (2-3 short paragraphs, max 150 words) that:

1. Starts with excitement about ${pet.name} being a great match (no numeric refs in the first sentence).
2. Directly compares the user's provided answers (use their selected option strings in parentheses) with the pet's traits, explaining WHY each alignment matters for day-to-day life. For example:
   - "Because your `daily_availability` is (Flexible Schedule), ${pet.name}'s moderate energy and daily exercise needs fit into your routine." 
   - "Your `size_preference` (${userSizePreference}) aligns with ${pet.name}'s size (${pet.size ?? 'Unknown'}), meaning walks and home space are a good fit."
3. Highlight household compatibility when relevant (children, other pets, shy-pet comfort) and explain the consequences in practical terms.
4. If a quirk exists (not "None"), weave it naturally into the explanation to add warmth and character.
5. Mention 1-2 strongest score categories from the Top Match Areas list above (do not mention numeric percentages).
6. Explicitly connect the user's affection/snuggly preference to the pet's affection description and say whether that comfort level matches well. Use the user's selected string when available.
7. Use a warm, conversational tone like a friend giving advice.
8. Include the user's selected option strings in parentheses when you reference their preferences. If the user has numeric-style buckets for some settings, convert them to the user's chosen label or range and show that in parentheses (e.g., "activity level (3-5)" only if the user provided a bucket). Do NOT invent numeric buckets.
9. CRITICAL: DO NOT include match score percentages or ANY pet numeric ratings in the explanation — only the user's selected preference strings or explicitly provided buckets may include numbers.
10. If any user preference is listed as "Unknown", do not mention that trait.

Generate the explanation now:
''';
  }

  /// Generate a comparison between two pets
  Future<String> generatePetComparison(PetMatch pet1, PetMatch pet2) async {
    final prompt = _buildComparisonPrompt(pet1, pet2);

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Unable to generate comparison at this time.';
    } catch (e) {
      print('Error generating comparison: $e');
      return 'Unable to generate comparison. Please try again later.';
    }
  }

  String _buildComparisonPrompt(PetMatch pet1, PetMatch pet2) {
    return '''
You are a pet adoption expert. Compare these two pets and help the user understand the key differences:

Pet 1: ${pet1.pet.name}
- Match Score: ${pet1.totalMatchPercent.toInt()}%
- Breed: ${pet1.pet.breed ?? 'Mixed'}
- Age: ${pet1.pet.age ?? '?'} ${pet1.pet.ageUnit ?? 'years'}
- Energy: ${pet1.pet.energyLevel ?? '?'}/5
- Size: ${pet1.pet.size ?? 'Unknown'}
- Affection: ${pet1.pet.affectionLevel ?? '?'}/5
- Independence: ${pet1.pet.independence ?? '?'}/5
- Good with Children: ${pet1.pet.goodWithChildren ?? 'Unknown'}
- Good with Pets: Dogs: ${pet1.pet.goodWithDogs ?? 'Unknown'}, Cats: ${pet1.pet.goodWithCats ?? 'Unknown'}

Pet 2: ${pet2.pet.name}
- Match Score: ${pet2.totalMatchPercent.toInt()}%
- Breed: ${pet2.pet.breed ?? 'Mixed'}
- Age: ${pet2.pet.age ?? '?'} ${pet2.pet.ageUnit ?? 'years'}
- Energy: ${pet2.pet.energyLevel ?? '?'}/5
- Size: ${pet2.pet.size ?? 'Unknown'}
- Affection: ${pet2.pet.affectionLevel ?? '?'}/5
- Independence: ${pet2.pet.independence ?? '?'}/5
- Good with Children: ${pet2.pet.goodWithChildren ?? 'Unknown'}
- Good with Pets: Dogs: ${pet2.pet.goodWithDogs ?? 'Unknown'}, Cats: ${pet2.pet.goodWithCats ?? 'Unknown'}

Provide a brief comparison (2 paragraphs) highlighting:
1. Key differences in personality and energy
2. Which pet might be better for different lifestyles
3. Be balanced and objective

Generate the comparison now:
''';
  }

  /// Generate tips for transitioning with this specific pet
  Future<String> generateTransitionTips(Pet pet) async {
    final prompt = '''
You are a pet care expert. Provide 4-5 practical tips for someone adopting ${pet.name}, a ${pet.breed ?? 'mixed breed'} with:
- Energy Level: ${pet.energyLevel ?? '?'}/5
- Age: ${pet.age ?? '?'} ${pet.ageUnit ?? 'years'}
- Special Needs: ${pet.specialNeeds ?? 'None'}
- Training Difficulty: ${pet.trainingDifficulty ?? '?'}/5
- Adaptability: ${pet.adaptability ?? '?'}/5

Keep it concise, practical, and specific to this pet's characteristics. Format as a bulleted list with actionable advice.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Unable to generate tips at this time.';
    } catch (e) {
      print('Error generating tips: $e');
      return 'Unable to generate tips. Please try again later.';
    }
  }
}
