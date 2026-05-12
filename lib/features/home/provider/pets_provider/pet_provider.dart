// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_state.dart';
import 'package:petmatch/core/repository/pet_repository.dart';
import 'package:uuid/uuid.dart';

class PetNotifier extends Notifier<PetState> {
  final PetRepository _repository;

  PetNotifier(this._repository);

  static const int _pageSize = 10;

  @override
  PetState build() {
    return PetState();
  }

  Future<void> fetchInitialPets() async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 0,
        hasMore: true,
      );
      print('📤 Fetching first batch of pets...');

      final pets = await _repository.getPets(limit: _pageSize, offset: 0);

      state = state.copyWith(
        pets: pets,
        filteredPets: pets,
        isLoading: false,
        currentPage: 1,
        hasMore: pets.length == _pageSize,
      );

      print('✅ Fetched ${pets.length} pets (page 1)');
    } catch (e) {
      print('❌ Error fetching pets: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch pets: $e',
      );
    }
  }

  /// 🔹 Load next batch (pagination)
  Future<void> fetchMorePets() async {
    if (state.isFetchingMore || !state.hasMore) return;

    print('⬇️ Loading more pets...');
    state = state.copyWith(isFetchingMore: true);

    try {
      final offset = state.pets?.length ?? 0;
      final newPets =
          await _repository.getPets(limit: _pageSize, offset: offset);

      if (newPets.isEmpty) {
        print('🚫 No more pets to load.');
        state = state.copyWith(isFetchingMore: false, hasMore: false);
        return;
      }

      final updatedPets = [...?state.pets, ...newPets];

      state = state.copyWith(
        pets: updatedPets,
        filteredPets: updatedPets,
        isFetchingMore: false,
        hasMore: newPets.length == _pageSize,
        currentPage: state.currentPage + 1,
      );

      print(
          '✅ Loaded ${newPets.length} more pets (total: ${updatedPets.length})');
    } catch (e) {
      print('❌ Error loading more pets: $e');
      state = state.copyWith(
        isFetchingMore: false,
        errorMessage: 'Failed to load more pets: $e',
      );
    }
  }

  /// 🔹 Save new pet and refresh list
  Future<void> savePet({
    required String petName,
    required String species,
    required String breed,
    required int age,
    required String gender,
    required String size,
    required String status,
    required String description,
    required File? thumbnailImage,
    required List<File> selectedImages,
    // Health Information
    required bool? isVaccinationUpToDate,
    required bool? isSpayedNeutered,
    required String healthNotes,
    required bool? hasSpecialNeeds,
    required int? groomingNeeds,
    // Behavior Information
    required bool? goodWithChildren,
    required bool? goodWithDogs,
    required bool? goodWithCats,
    required bool? houseTrained,
    // Activity Information
    required double energyLevel,
    required double playfulness,
    required String? dailyExerciseNeeds,
    // Temperament Information
    required double affectionLevel,
    required double independence,
    required double adaptability,
    required int? trainingDifficulty,
    required String? quirk,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      print('💾 Saving new pet: $petName');

      const Uuid uuid = Uuid();
      final petId = uuid.v4();

      await _repository.savePet(
        petId: petId,
        petName: petName,
        species: species,
        breed: breed,
        age: age,
        gender: gender,
        size: size,
        status: status,
        description: description,
        thumbnailImage: thumbnailImage,
        selectedImages: selectedImages,
        isVaccinationUpToDate: isVaccinationUpToDate,
        isSpayedNeutered: isSpayedNeutered,
        healthNotes: healthNotes,
        hasSpecialNeeds: hasSpecialNeeds,
        groomingNeeds: groomingNeeds,
        goodWithChildren: goodWithChildren,
        goodWithDogs: goodWithDogs,
        goodWithCats: goodWithCats,
        houseTrained: houseTrained,
        energyLevel: energyLevel,
        playfulness: playfulness,
        dailyExerciseNeeds: dailyExerciseNeeds,
        affectionLevel: affectionLevel,
        independence: independence,
        adaptability: adaptability,
        trainingDifficulty: trainingDifficulty,
        quirk: quirk,
      );

      print('✅ Pet saved successfully!');

      // await fetchInitialPets();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save pet: $e',
      );
      print('❌ Error saving pet: $e');
      rethrow;
    }
  }

  /// 🔹 Local filtering
  void filterByCategory(String category) {
    print('🔍 Filtering pets locally by category: $category');

    final allPets = state.pets ?? [];
    List<Pet> filtered;

    if (category.toLowerCase() == 'all') {
      filtered = allPets;
    } else {
      filtered = allPets
          .where((pet) => pet.species.toLowerCase() == category.toLowerCase())
          .toList();
    }

    state = state.copyWith(
      filteredPets: filtered,
      selectedCategory: category,
      searchQuery: '',
    );
  }

  /// 🔹 Local search
  void searchPets(String query) {
    print('🔍 Searching pets locally with query: "$query"');

    if (query.isEmpty) {
      filterByCategory(state.selectedCategory ?? 'All');
      return;
    }

    final allPets = state.pets ?? [];
    final selectedCategory = state.selectedCategory ?? 'All';

    List<Pet> baseList = selectedCategory.toLowerCase() == 'all'
        ? allPets
        : allPets
            .where((pet) =>
                pet.species.toLowerCase() == selectedCategory.toLowerCase())
            .toList();

    final filtered = baseList
        .where((pet) => pet.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    state = state.copyWith(filteredPets: filtered, searchQuery: query);
  }

  void setSelectedCategory(String category) => filterByCategory(category);

  void clearError() => state = state.copyWith(errorMessage: null);

  void clearSearch() {
    print('🧹 Clearing search');
    filterByCategory(state.selectedCategory ?? 'All');
  }

  /// 🔹 Update existing pet
  Future<void> updatePet({
    required String petId,
    required String petName,
    required String species,
    required String breed,
    required int age,
    required String gender,
    required String size,
    required String status,
    required String description,
    required File? thumbnailImage,
    String? existingThumbnailPath,
    required List<File> selectedImages,
    required List<String> deletedImagePaths,
    // Health Information
    required bool? isVaccinationUpToDate,
    required bool? isSpayedNeutered,
    required String healthNotes,
    required bool? hasSpecialNeeds,
    required String specialNeedsDescription,
    required int? groomingNeeds,
    // Behavior Information
    required bool? goodWithChildren,
    required bool? goodWithDogs,
    required bool? goodWithCats,
    required bool? houseTrained,
    required String behavioralNotes,
    // Activity Information
    required double energyLevel,
    required double playfulness,
    required String? dailyExerciseNeeds,
    // Temperament Information
    required List<String> selectedTraits,
    required double affectionLevel,
    required double independence,
    required double adaptability,
    required int? trainingDifficulty,
    required String? quirk,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      print('✏️ Updating pet: $petName (ID: $petId)');

      await _repository.updatePet(
        petId: petId,
        petName: petName,
        species: species,
        breed: breed,
        age: age,
        gender: gender,
        size: size,
        status: status,
        description: description,
        thumbnailImage: thumbnailImage,
        existingThumbnailPath: existingThumbnailPath,
        selectedImages: selectedImages,
        deletedImagePaths: deletedImagePaths,
        isVaccinationUpToDate: isVaccinationUpToDate,
        isSpayedNeutered: isSpayedNeutered,
        healthNotes: healthNotes,
        hasSpecialNeeds: hasSpecialNeeds,
        specialNeedsDescription: specialNeedsDescription,
        groomingNeeds: groomingNeeds,
        goodWithChildren: goodWithChildren,
        goodWithDogs: goodWithDogs,
        goodWithCats: goodWithCats,
        houseTrained: houseTrained,
        behavioralNotes: behavioralNotes,
        energyLevel: energyLevel,
        playfulness: playfulness,
        dailyExerciseNeeds: dailyExerciseNeeds,
        selectedTraits: selectedTraits,
        affectionLevel: affectionLevel,
        independence: independence,
        adaptability: adaptability,
        trainingDifficulty: trainingDifficulty,
        quirk: quirk,
      );

      print('✅ Pet updated successfully!');
      print('🔄 Refreshing pet list...');

      await fetchInitialPets();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update pet: $e',
      );
      print('❌ Error updating pet: $e');
      rethrow;
    }
  }

  /// 🔹 Refresh pets (reload first page)
  Future<void> refresh() async {
    print('🔄 Refreshing pets...');
    await fetchInitialPets();

    final query = state.searchQuery ?? '';
    final category = state.selectedCategory ?? 'All';

    if (query.isNotEmpty) {
      searchPets(query);
    } else if (category != 'All') {
      filterByCategory(category);
    }
  }

  /// 🗑️ Delete pet
  Future<void> deletePet(String petId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      print('🗑️ Deleting pet with ID: $petId');

      await _repository.deletePet(petId);

      print('✅ Pet deleted successfully!');
      print('🔄 Refreshing pet list...');

      await fetchInitialPets();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete pet: $e',
      );
      print('❌ Error deleting pet: $e');
      rethrow;
    }
  }

  Future<void> deletePetImage(
      {required String petId, required String imageUrl}) async {
    try {
      print('🗑️ Deleting image for pet ID: $petId, Image URL: $imageUrl');

      await _repository.deletePetImage(petId: petId, imageUrl: imageUrl);
      await fetchInitialPets();
    } catch (e) {
      print('❌ Error deleting pet image: $e');
      rethrow;
    }
  }

  /// Add a pet to local lists if it's not already present
  void addPetIfMissing(Pet pet) {
    final existing = state.pets ?? [];
    if (existing.any((p) => p.id == pet.id)) return;
    final updated = [pet, ...existing];
    state = state.copyWith(pets: updated, filteredPets: updated);
  }
}

final petsProvider = NotifierProvider<PetNotifier, PetState>(
  () => PetNotifier(PetRepository()),
);
