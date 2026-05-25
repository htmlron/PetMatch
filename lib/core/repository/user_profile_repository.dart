// ignore_for_file: avoid_print

import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class UserProfileRepository {
  Future<void> saveUserProfile({
    required String userId,
    required Map<String, dynamic> userLifestyle,
    required Map<String, dynamic> personalityTraits,
    required Map<String, dynamic> householdInfo,
  }) async {
    final data = {
      'user_id': userId,
      'user_lifestyle': userLifestyle,
      'personality_traits': personalityTraits,
      'household_info': householdInfo,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Check if profile exists
    final existing = await supabase
        .from('user_profile')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await supabase.from('user_profile').update(data).eq('user_id', userId);
    } else {
      await supabase.from('user_profile').insert(data);
    }

    await supabase.from('users').update({
      'onboarding_completed': true,
    }).eq('user_id', userId);

    await auditTrailService.track(
      action: 'profile_setup_completed',
      actorId: userId,
      entityType: 'user_profile',
      entityId: userId,
      metadata: {
        'has_lifestyle': userLifestyle.isNotEmpty,
        'has_traits': personalityTraits.isNotEmpty,
        'has_household_info': householdInfo.isNotEmpty,
      },
    );
  }

  Future<void> updatePersonalityTrait(
    String userId,
    String column, // EXAMPLE: USER LIFESTYLE
    String key, // EXAMPLE: activity_level (IN THE JSON FILE)
    dynamic value,
  ) async {
    try {
      await supabase.rpc('update_user_profile', params: {
        'uid': userId,
        'column_name': column,
        'key': key,
        'value': value,
      });
      print('✅ Activity level updated successfully for user $userId');

      await auditTrailService.track(
        action: 'profile_trait_updated',
        actorId: userId,
        entityType: 'user_profile',
        entityId: userId,
        metadata: {
          'column': column,
          'key': key,
          'value': value,
        },
      );
    } catch (e) {
      print('❌ Error updating activity level: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('user_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      return null;
    }
  }
}
