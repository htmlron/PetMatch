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

    String intOrUnknown(dynamic value) {
      if (value == null) return 'Unknown';
      if (value is int) return value.toString();
      if (value is num) return value.toInt().toString();
      if (value is String && int.tryParse(value) != null) return value;
      return 'Unknown';
    }

    String yesNoUnknown(dynamic value) {
      if (value is bool) return value ? 'Yes' : 'No';
      return 'Unknown';
    }

    /// Bucket a 0-5 or 1-5 style level into a user-friendly range.
    /// Example buckets: 0-2 vs 3-5, or 1-2 vs 3-5.
    String levelBucketOrUnknown(
      dynamic value, {
      required int min,
      required int max,
      required int splitStart,
    }) {
      if (value == null) return 'Unknown';

      int? asInt;
      if (value is int) {
        asInt = value;
      } else if (value is num) {
        asInt = value.toInt();
      } else if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return 'Unknown';
        // If already stored as a range like "3-5", keep it.
        if (RegExp(r'^\d+\s*-\s*\d+$').hasMatch(trimmed)) {
          return trimmed.replaceAll(RegExp(r'\s+'), '');
        }
        asInt = int.tryParse(trimmed);
      }

      if (asInt == null) return 'Unknown';
      final clamped = asInt.clamp(min, max);
      if (clamped < splitStart) return '$min-${splitStart - 1}';
      return '$splitStart-$max';
    }

    final userActivityBucket = levelBucketOrUnknown(
      userPersonality?['activity_level'],
      min: 1,
      max: 5,
      splitStart: 3,
    );
    final userGroomingBucket = levelBucketOrUnknown(
      userPersonality?['grooming_tolerance'],
      min: 1,
      max: 5,
      splitStart: 3,
    );
    final userHairinessBucket = levelBucketOrUnknown(
      userPersonality?['hairiness_preference'],
      min: 0,
      max: 5,
      splitStart: 3,
    );
    final userPetPreference = userLifestyle?['pet_preference'] ?? 'Unknown';
    final userSizePreference = userLifestyle?['size_preference'] ?? 'Unknown';

    final userTrainingBucket = levelBucketOrUnknown(
      userPersonality?['training_patience'],
      min: 1,
      max: 5,
      splitStart: 3,
    );
    final userSnugglyBucket = levelBucketOrUnknown(
      userPersonality?['snuggly_preference'],
      min: 1,
      max: 5,
      splitStart: 3,
    );

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
You are a pet adoption expert AI helping users understand why a pet is a perfect match for THEM specifically.

Your task is to explain the compatibility between THIS USER and THIS PET by comparing their traits.

🧑 USER PROFILE (The person adopting):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Lifestyle Preferences:
  • Activity Level Bucket: $userActivityBucket (low=1-2, high=3-5)
  • Hairiness Bucket: $userHairinessBucket (0-2=low shedding preferred, 3-5=heavy shedding OK)
  • Grooming Bucket: $userGroomingBucket (low=1-2, high=3-5)
  • Pet Type Preference: $userPetPreference
  • Size Preference: $userSizePreference

Personality Traits:
  • Training Patience Bucket: $userTrainingBucket (low=1-2, high=3-5)
  • Snuggly Preference Bucket: $userSnugglyBucket (low=1-2=more independent OK, high=3-5=loves cuddles)

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
  • Lifestyle Compatibility: ${scoreStrengths['Lifestyle']} (Activity & Size alignment)
  • Personality Compatibility: ${scoreStrengths['Personality']} (Affection, Independence, Training, Snuggliness)
  • Household Compatibility: ${scoreStrengths['Household']} (Children, Other pets, Shy pet comfort)
  • Health & Grooming: ${scoreStrengths['Health & Grooming']} (Grooming needs, Special needs)
  • Top Match Areas (to highlight): ${topAreas.isEmpty ? 'None stand out strongly' : topAreas.join(', ')}

📝 YOUR TASK:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write a warm, friendly, personalized explanation (2-3 short paragraphs, max 150 words) that:

1. **Starts with excitement** about ${pet.name} being a great match
2. **Compares USER traits with PET traits** - Show specific alignments like:
  - "Your activity level bucket (3-5) pairs nicely with ${pet.name}'s energy and daily routine"
  - "With your hairiness bucket (3-5), you'll feel comfortable with a pet that sheds a bit"
  - "Since your grooming bucket is (3-5), a more hands-on routine won't feel overwhelming"
  - "Your training patience bucket (3-5) is great for supporting ${pet.name}'s learning style"
  - "Your snuggly preference bucket (3-5) lines up well with an affectionate companion"
3. **Highlight household compatibility** if relevant (children, other pets)
4. **If a quirk exists (not "None"), weave it naturally into the explanation** - This is ${pet.name}'s unique personality trait that makes them special! Use it to add character and warmth to your explanation. Examples:
   - "${pet.name} is sweet and easygoing, making her a perfect companion for your moderate activity lifestyle"
   - "Known as the 'mayordoma' who greets everyone at the kennel doors, ${pet.name}'s friendly nature will bring joy to your home"
5. **Mention 1-2 strongest score categories** using the "Top Match Areas" list above (do not mention numbers)
6. **Explicitly connect affection** - compare the user's snuggly preference with the pet's affection level and say whether that comfort level matches well
7. **Use a warm, conversational tone** - like a friend giving advice
8. **Include the user's selected level BUCKETS as quick parenthetical refs when you mention each preference** (blend into sentences; do NOT add a separate list at the top or bottom). Do NOT put any numeric refs in the very first sentence. For each preference that is NOT "Unknown", you MUST include:
  - Activity bucket (e.g., "activity level (3-5)")
  - Hairiness bucket (e.g., "hairiness tolerance (3-5)")
  - Grooming bucket (e.g., "grooming tolerance (1-2)")
  - Snuggly / affection bucket (e.g., "snuggly preference (1-2)")
  - Training patience bucket (e.g., "training patience (3-5)")
  - Size preference (e.g., "size preference (Medium)")
  - Household setup (work in children/other pets/shy-pet comfort/pet experience as "(Yes/No)" when relevant)
9. **CRITICAL: DO NOT include match score percentages or ANY pet numeric ratings**. The ONLY numbers allowed are the user's bucket ranges in the form "1-2", "3-5", or "0-2".
10. **If any user preference is listed as "Unknown", do not mention that trait**
11. **Treat low buckets as "low" and high buckets as "high"** (e.g., 1-2 = low, 3-5 = high; for hairiness 0-2 = low shedding preferred, 3-5 = lots of shedding OK)
12. **Treat hairiness preference as shedding tolerance** (0 = prefers low shedding, 5 = totally OK with lots of shedding)

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
