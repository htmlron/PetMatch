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

    // Quick guard: ensure API key exists
    if (apiKey.isEmpty) {
      return 'AI not configured. Please set GEMINI_API_KEY in your environment to enable explanations.';
    }

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

    final userActivityLevel = userPersonality?['activity_level'] ?? 'Unknown';
    final userGroomingLevel =
        userPersonality?['grooming_tolerance'] ?? 'Unknown';
    final userPetPreference = userLifestyle?['pet_preference'] ?? 'Unknown';
    final userSizePreference = userLifestyle?['size_preference'] ?? 'Unknown';

    final userTrainingPatience =
        userPersonality?['training_patience'] ?? 'Unknown';
    final userSnugglyPreference =
        userPersonality?['snuggly_preference'] ?? 'Unknown';

    final userHasChildren = userHousehold?['has_children'] ?? false;
    final userHasOtherPets = userHousehold?['has_other_pets'] ?? false;
    final userComfortableWithShyPet =
        userHousehold?['comfortable_with_shy_pet'] ?? false;
    final userHadPetBefore = userHousehold?['had_pet_before'] ?? false;

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
      ? (pet.vaccinationTypes.isNotEmpty ? pet.vaccinationTypes.join(', ') : 'Yes')
      : 'No';
    final petSpayedNeutered = pet.spayedNeutered == null
        ? 'Unknown'
        : (pet.spayedNeutered! ? 'Yes' : 'No');

    return '''
You are a pet adoption expert AI helping users understand why a pet is a perfect match for THEM specifically.

Your task is to explain the compatibility between THIS USER and THIS PET by comparing their traits.

🧑 USER PROFILE (The person adopting):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Lifestyle Preferences:
  • Activity Level: $userActivityLevel/5 (1=Couch potato, 5=Very active)
  • Grooming Tolerance: $userGroomingLevel/5 (1=Low maintenance, 5=High maintenance OK)
  • Pet Type Preference: $userPetPreference
  • Size Preference: $userSizePreference

Personality Traits:
  • Training Patience: $userTrainingPatience/5 (1=Low patience, 5=Very patient)
  • Snuggly Preference: $userSnugglyPreference/5 (1=Independent pets OK, 5=Loves cuddles)

Household Situation:
  • Has Children: ${userHasChildren ? 'Yes' : 'No'}
  • Has Other Pets: ${userHasOtherPets ? 'Yes' : 'No'}
  • Comfortable with Shy Pets: ${userComfortableWithShyPet ? 'Yes' : 'No'}
  • Previous Pet Experience: ${userHadPetBefore ? 'Yes' : 'No'}

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
  • Energy Level: $petEnergyLevel/5 (1=Very calm, 5=Extremely energetic)
  • Playfulness: $petPlayfulness/5 (1=Not playful, 5=Very playful)
  • Daily Exercise Needs: $petDailyExerciseNeeds

Temperament & Personality:
  • Affection Level: $petAffectionLevel/5 (1=Independent, 5=Very affectionate)
  • Independence: $petIndependence/5 (1=Needs constant attention, 5=Very independent)
  • Adaptability: $petAdaptability/5 (1=Needs routine, 5=Highly adaptable)
  • Training Difficulty: $petTrainingDifficulty/5 (1=Easy to train, 5=Challenging)
  • Grooming Needs: $petGroomingNeeds/5 (1=Low, 5=High)
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
  • Overall Match: ${petMatch.totalMatchPercent.toInt()}% (${petMatch.matchLabel})
  • Lifestyle Compatibility: ${petMatch.lifestyleScore.toInt()}% (Activity & Size alignment)
  • Personality Compatibility: ${petMatch.personalityScore.toInt()}% (Affection, Independence, Training, Snuggliness)
  • Household Compatibility: ${petMatch.householdScore.toInt()}% (Children, Other pets, Shy pet comfort)
  • Health & Grooming: ${petMatch.healthScore.toInt()}% (Grooming needs, Special needs)

📝 YOUR TASK:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Write a warm, friendly, personalized explanation (2-3 short paragraphs, max 150 words) that:

1. **Starts with excitement** about ${pet.name} being a great match
2. **Compares USER traits with PET traits** - Show specific alignments like:
   - "Your calm, low-key lifestyle pairs perfectly with ${pet.name}'s relaxed demeanor"
   - "Since you're comfortable with regular grooming, ${pet.name}'s grooming needs won't be overwhelming"
   - "Your patient approach to training is ideal for ${pet.name}'s learning style"
  - "Your love for cuddles matches ${pet.name}'s affectionate personality"
3. **Highlight household compatibility** if relevant (children, other pets)
4. **If a quirk exists (not "None"), weave it naturally into the explanation** - This is ${pet.name}'s unique personality trait that makes them special! Use it to add character and warmth to your explanation. Examples:
   - "${pet.name} is sweet and easygoing, making her a perfect companion for your moderate activity lifestyle"
   - "Known as the 'mayordoma' who greets everyone at the kennel doors, ${pet.name}'s friendly nature will bring joy to your home"
5. **Mention 1-2 strongest score categories** (above 75%) without stating exact percentages
6. **Explicitly connect affection** - compare the user's snuggly preference with the pet's affection level and say whether that comfort level matches well
7. **Use a warm, conversational tone** - like a friend giving advice
8. **CRITICAL: DO NOT include ANY numbers, scales, or percentages in your explanation** - No "4/5", "7/10", percentages, or rating numbers. Only use descriptive language like "highly energetic", "moderately affectionate", "very patient", etc.
9. **Focus on WHY this pet fits the user's lifestyle and personality** without referencing any numerical scales

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
