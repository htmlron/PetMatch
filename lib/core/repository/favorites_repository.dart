import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class FavoritesRepository {
  Future<List<String>> getFavoritePetIds(String userId) async {
    final response =
        await supabase.from('favorites').select('pet_id').eq('user_id', userId);
    return (response as List).map((row) => row['pet_id'] as String).toList();
  }

  Future<List<Pet>> getMostFavoritedPets({int limit = 5}) async {
    final response = await supabase.rpc('get_most_favorited_pets',
        params: {'limit_count': limit}).select();
    print('Response: $response');

    return (response as List)
        .map((json) => Pet.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(String userId, String petId) async {
    await supabase.from('favorites').upsert({
      'user_id': userId,
      'pet_id': petId,
    }, onConflict: 'user_id,pet_id');

    await auditTrailService.track(
      action: 'favorite_added',
      actorId: userId,
      entityType: 'favorite',
      entityId: petId,
      metadata: {'pet_id': petId},
    );
  }

  Future<void> removeFavorite(String userId, String petId) async {
    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('pet_id', petId);

    await auditTrailService.track(
      action: 'favorite_removed',
      actorId: userId,
      entityType: 'favorite',
      entityId: petId,
      metadata: {'pet_id': petId},
    );
  }
}
