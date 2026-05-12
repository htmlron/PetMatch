// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/repository/pet_repository.dart';
import 'package:petmatch/features/home/provider/match_provider/match_state.dart';
import 'package:petmatch/features/home/provider/favorites_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchNotifier extends Notifier<MatchState> {
  final PetRepository _repository;
  RealtimeChannel? _matchChannel;

  MatchNotifier(this._repository);

  @override
  MatchState build() {
    _setupRealtimeSync();
    return MatchState();
  }

  void _setupRealtimeSync() {
    if (_matchChannel != null) return;

    _matchChannel = supabase
        .channel('matches-realtime-sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pets',
          callback: (_) => fetchMatchedPets(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pets_images',
          callback: (_) => fetchMatchedPets(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pet_characteristics',
          callback: (_) => fetchMatchedPets(),
        )
        .subscribe();

    ref.onDispose(() {
      if (_matchChannel != null) {
        supabase.removeChannel(_matchChannel!);
        _matchChannel = null;
      }
    });
  }

  Future<void> fetchMatchedPets() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      print('🎯 Fetching matched pets for current user...');

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final matches = await _repository.getMatchedPetsForUser(userId);

      // Exclude pets that are already favorited locally to avoid showing them again
      final favoriteIds = ref.read(favoritesProvider).favoriteIds;
      final filteredMatches = matches.where((m) => !favoriteIds.contains(m.pet.id)).toList();

      state = state.copyWith(
        matches: filteredMatches,
        isLoading: false,
      );

      print('✅ Fetched ${matches.length} matched pets successfully!');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch matched pets: $e',
      );
      print('❌ Error fetching matched pets: $e');
    }
  }

  void clearMatches() {
    state = state.copyWith(matches: [], errorMessage: null);
  }

  /// Remove a pet from the current matches (e.g., when it's favorited)
  void removePetFromMatches(String petId) {
    final updated = state.matches.where((m) => m.pet.id != petId).toList();
    state = state.copyWith(matches: updated);
  }
}

// Provider instance
final matchProvider = NotifierProvider<MatchNotifier, MatchState>(() {
  return MatchNotifier(PetRepository());
});
