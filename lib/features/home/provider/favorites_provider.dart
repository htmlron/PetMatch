// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/core/repository/favorites_repository.dart';
import 'package:petmatch/core/repository/pet_repository.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_provider.dart';
import 'package:petmatch/features/home/provider/match_provider/match_provider.dart';
import 'package:petmatch/core/utils/notifier_helpers.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petmatch/core/config/supabase_config.dart';

class FavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? errorMessage;
  final List<Pet> favoritePets;

  const FavoritesState({
    this.favoriteIds = const {},
    this.isLoading = false,
    this.errorMessage,
    this.favoritePets = const [],
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    bool? isLoading,
    String? errorMessage,
    List<Pet>? favoritePets,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      favoritePets: favoritePets ?? this.favoritePets,
    );
  }
}

/// 🧠 Notifier
class FavoritesNotifier extends Notifier<FavoritesState> {
  final FavoritesRepository _favoritesRepository;
  RealtimeChannel? _favoritesChannel;

  FavoritesNotifier(this._favoritesRepository);

  String? get userId => ref.read(authProvider).userId;

  @override
  FavoritesState build() {
    print('BUILD: FavoritesNotifier initializing...');
    _setupRealtimeSync();
    // Defer initial fetch to avoid reading uninitialized providers
    Future.microtask(() => fetchFavorites());
    return const FavoritesState();
  }

  void _setupRealtimeSync() {
    if (_favoritesChannel != null) return;

    try {
      print('🔌 Setting up favorites realtime sync...');
      _favoritesChannel = supabase
          .channel('favorites-realtime-sync')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'favorites',
            callback: (payload) {
              print('🔔 Favorites table changed: ${payload.eventType}');
              fetchFavorites();
            },
          )
          .subscribe((status, error) {
            print('✅ Favorites realtime subscription status: $status');
            if (error != null) print('❌ Subscription error: $error');
          });
    } catch (e) {
      print('❌ Error setting up favorites realtime: $e');
    }

    ref.onDispose(() {
      if (_favoritesChannel != null) {
        print('🧹 Disposing favorites realtime channel');
        supabase.removeChannel(_favoritesChannel!);
        _favoritesChannel = null;
      }
    });
  }

  Future<void> fetchFavorites() async {
    if (userId == null) return;
    print('📤 Fetching favorites for user: $userId');

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final favoriteIds = await _favoritesRepository.getFavoritePetIds(userId!);
      // Build favorite Pets list
      final petRepo = PetRepository();
      final favPets = <Pet>[];
      for (final id in favoriteIds) {
        final pet = await petRepo.getPetById(id);
        if (pet != null) favPets.add(pet);
      }

      state = state.copyWith(
        favoriteIds: favoriteIds.toSet(),
        isLoading: false,
        favoritePets: favPets,
      );
      print('✅ Loaded ${favoriteIds.length} favorites');
    } catch (e) {
      print('❌ Error fetching favorites: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch favorites: $e',
      );
    }
  }

  /// 🔹 Fetch all favorite most favorite pets
  Future<void> fetchMostFavoritePets() async {
    try {
      final pets = await _favoritesRepository.getMostFavoritedPets(limit: 10);
      state = state.copyWith(favoritePets: pets);
      print('✅ Fetched most favorite pets:');
      for (final pet in pets) {
        print('Pet: ${pet.id}, Name: ${pet.name}');
      }
    } catch (e) {
      print('❌ Error fetching most favorite pets: $e');
    }
  }

  /// 🔹 Add a pet to favorites
  Future<void> addFavorite(BuildContext context, String petId) async {
    if (userId == null) return;

    try {
      await _favoritesRepository.addFavorite(userId!, petId);
      state = state.copyWith(
        favoriteIds: {...state.favoriteIds, petId},
      );

      // Fetch the pet details and add to favoritePets list so UI updates immediately
      try {
        final petRepo = PetRepository();
        final pet = await petRepo.getPetById(petId);
        if (pet != null) {
          // Add to local favorites list
          state = state.copyWith(
            favoritePets: [...state.favoritePets, pet],
          );

          // Ensure petsProvider contains this pet so Favorite screen can display it
          ref.read(petsProvider.notifier).addPetIfMissing(pet);

          // Remove from current matches so it won't reappear
          ref.read(matchProvider.notifier).removePetFromMatches(petId);
        }
      } catch (e) {
        // Non-fatal: continue
        print('⚠️ Warning: could not fetch pet after adding favorite: $e');
      }

      NotifierHelper.showSuccessToast(context, 'Added to favorites!');
    } catch (e) {
      print('❌ Error adding favorite: $e');
      state = state.copyWith(errorMessage: 'Failed to add favorite: $e');
    }
  }

  /// 🔹 Remove a pet from favorites
  Future<void> removeFavorite(BuildContext context, String petId) async {
    if (userId == null) return;

    try {
      await _favoritesRepository.removeFavorite(userId!, petId);
      state = state.copyWith(
        favoriteIds: state.favoriteIds.where((id) => id != petId).toSet(),
      );
      // Remove from local favoritePets list so UI updates immediately
      state = state.copyWith(
        favoritePets: state.favoritePets.where((p) => p.id != petId).toList(),
      );

      // Refresh matches so the pet can reappear in matching view
      try {
        await ref.read(matchProvider.notifier).fetchMatchedPets();
      } catch (e) {
        print('⚠️ Warning: failed to refresh matches after removing favorite: $e');
      }

      NotifierHelper.showSuccessToast(context, 'Removed from favorites!');
    } catch (e) {
      print('❌ Error removing favorite: $e');
      state = state.copyWith(errorMessage: 'Failed to remove favorite: $e');
    }
  }

  /// 🔹 Utility methods
  bool isFavorite(String petId) => state.favoriteIds.contains(petId);

  void clearError() => state = state.copyWith(errorMessage: null);

  Future<void> refreshFavorites() async {
    print('🔄 Refreshing favorites...');
    await fetchFavorites();
  }
}

/// 🪄 Provider
final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  () => FavoritesNotifier(FavoritesRepository()),
);
