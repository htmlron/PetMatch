// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/core/model/pet_match_model.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class PetRepository {
  final _supabase = supabase;

  String _capitalize(String value) {
    if (value.trim().isEmpty) return value;
    final t = value.trim();
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  String? _normalizeSize(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    if (normalized.contains('small')) return 'small';
    if (normalized.contains('medium')) return 'medium';
    if (normalized.contains('large')) return 'large';
    if (normalized.contains('no preference')) return 'no_preference';

    return normalized;
  }

  Future<List<Pet>> getPets({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('pets')
          .select('*, pets_images(*), pet_characteristics(*)')
          .neq('status', 'adopted')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print(
          '📤 Fetched ${(response as List).length} pets (offset: $offset, limit: $limit).');

      return (response as List)
          .map((json) => Pet.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching pets: $e');
      rethrow;
    }
  }

  Future<Pet?> getPetById(String petId) async {
    try {
      final response = await _supabase
          .from('pets')
          .select('*, pets_images(*), pet_characteristics(*)')
          .eq('pet_id', petId)
          .single();

      return Pet.fromJson(response);
    } catch (e) {
      print('❌ Error fetching pet: $e');
      return null;
    }
  }

  /// Get matched pets for a user using the database function
  Future<List<PetMatch>> getMatchedPetsForUser(String userId) async {
    try {
      print('🎯 Fetching matched pets for user: $userId');

      // Validate user profile before attempting match
      final userProfile = await _supabase
          .from('user_profile')
          .select('personality_traits, user_lifestyle, household_info')
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('User profile fetch timeout'),
          );

      if (userProfile == null) {
        print('⚠️ User profile not found');
        return [];
      }

      print('✅ User profile loaded successfully');

      // Call the PostgreSQL function with timeout
      late dynamic response;
      try {
        response = await _supabase
            .rpc('match_pets_for_user_weighted_detailed_v3', params: {
          'user_uuid': userId,
        }).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Database timeout - taking too long to fetch matches');
          },
        );
      } catch (rpcError) {
        print('❌ RPC Error: $rpcError');
        print('   Stack trace: $rpcError');
        // Return empty list as fallback instead of crashing
        print('⚠️ Falling back to empty match list due to RPC error');
        return [];
      }

      final responseList = response as List?;
      if (responseList == null || responseList.isEmpty) {
        print('⚠️ No matched pets found for user $userId');
        return [];
      }

      print('📊 Received ${responseList.length} matched pets');

      // Parse the results - fetch all pet IDs first
      final petIds = <String>{};
      for (var matchData in responseList) {
        final petId = matchData['pet_id'] as String?;
        if (petId != null) {
          petIds.add(petId);
        }
      }

      if (petIds.isEmpty) {
        print('⚠️ No valid pet IDs found in match results');
        return [];
      }

      // Fetch all pets in one query using filter
      final petsData = await _supabase
          .from('pets')
          .select('*, pets_images(*), pet_characteristics(*)')
          .inFilter('pet_id', petIds.toList())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Database timeout - taking too long to fetch pet details');
            },
          );

      // Build a map of pet_id -> Pet for quick lookup
      final petMap = <String, Pet>{};
      for (var petJson in petsData as List) {
        try {
          final pet = Pet.fromJson(petJson as Map<String, dynamic>);
          petMap[pet.id] = pet;
        } catch (e) {
          print('⚠️ Error parsing pet data: $e');
        }
      }

      // Parse the results using the pet map
      final List<PetMatch> matches = [];
      for (var matchData in responseList) {
        try {
          final petId = matchData['pet_id'] as String?;
          if (petId != null && petMap.containsKey(petId)) {
            final pet = petMap[petId]!;
            matches.add(PetMatch.fromJson(matchData, pet));
          }
        } catch (e) {
          print('⚠️ Error creating PetMatch: $e');
        }
      }

        final profile = await _supabase
          .from('user_profile')
          .select('user_lifestyle')
          .eq('user_id', userId)
          .maybeSingle();

        final userLifestyle = profile?['user_lifestyle'] as Map<String, dynamic>?;
        final normalizedPreferredSize =
          _normalizeSize(userLifestyle?['size_preference'] as String?);

        if (normalizedPreferredSize != null &&
          normalizedPreferredSize != 'no_preference') {
        final filteredMatches = matches
          .where((match) =>
            _normalizeSize(match.pet.size) == normalizedPreferredSize)
          .toList();

        print(
          '🔎 Applied size filter "$normalizedPreferredSize": ${filteredMatches.length}/${matches.length} matches');
        return filteredMatches;
        }

      print('✅ Successfully parsed ${matches.length} pet matches');
      return matches;
    } on TimeoutException catch (e) {
      print('❌ Timeout error fetching matched pets: $e');
      print('⚠️ Falling back to basic pet list as fallback...');
      return await _getFallbackMatches(userId);
    } catch (e) {
      print('❌ Error fetching matched pets: $e');
      print('⚠️ Falling back to basic pet list...');
      return await _getFallbackMatches(userId);
    }
  }

  /// Fallback matching method when SQL function fails
  /// Returns available pets with basic matching scores
  Future<List<PetMatch>> _getFallbackMatches(String userId) async {
    try {
      print('🔄 Using fallback matching logic...');

      // Fetch all available pets
      final petsData = await _supabase
          .from('pets')
          .select('*, pets_images(*), pet_characteristics(*)')
          .neq('status', 'adopted')
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Fallback: Failed to fetch pets'),
          );

      if ((petsData as List).isEmpty) {
        print('⚠️ No pets available for fallback matching');
        return [];
      }

      // Convert to Pet objects and create basic PetMatch with fallback scores
      final matches = <PetMatch>[];
      for (var petJson in petsData) {
        try {
          final pet = Pet.fromJson(petJson);
          // Create basic match with default scores
          final match = PetMatch(
            pet: pet,
            lifestyleScore: 60.0,
            personalityScore: 60.0,
            householdScore: 60.0,
            healthScore: 60.0,
            totalMatchPercent: 60.0,
            matchLabel: 'Good Match',
          );
          matches.add(match);
        } catch (e) {
          print('⚠️ Error parsing fallback pet: $e');
        }
      }

      print('✅ Fallback matching returned ${matches.length} pets');
      return matches;
    } catch (e) {
      print('❌ Fallback matching also failed: $e');
      return [];
    }
  }

  Future<void> savePet({
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
    // Optional single-line quirk/notes
    required String? quirk,
  }) async {
    try {
      print('💾 Starting to save pet: $petName');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('Pet ID: $petId');
      print('Pet Name: $petName');
      print('Species: $species');
      print('Breed: $breed');
      print('Age: $age');
      print('Gender: $gender');
      print('Size: $size');
      print('Status: $status');
      print('Thumbnail Image: ${thumbnailImage?.path}');
      print('Selected Images: ${selectedImages.map((f) => f.path).toList()}');
      print('Is Vaccination Up To Date: $isVaccinationUpToDate');
      print('Is Spayed/Neutered: $isSpayedNeutered');
      print('Has Special Needs: $hasSpecialNeeds');
      print('Grooming Needs: $groomingNeeds');
      print('Good With Children: $goodWithChildren');
      print('Good With Dogs: $goodWithDogs');
      print('Good With Cats: $goodWithCats');
      print('House Trained: $houseTrained');
      print('Energy Level: $energyLevel');
      print('Playfulness: $playfulness');
      print('Daily Exercise Needs: $dailyExerciseNeeds');
      print('Affection Level: $affectionLevel');
      print('Independence: $independence');
      print('Adaptability: $adaptability');
      print('Training Difficulty: $trainingDifficulty');

      // Upload thumbnail to Supabase Storage
      String? thumbnailPath;
      if (thumbnailImage != null) {
        print('📸 Uploading thumbnail image...');
        final thumbnailFileName = '$petName-thumbnail.png';
        final thumbnailStoragePath = '$petId/$thumbnailFileName';

        await _supabase.storage
            .from('pets')
            .upload(thumbnailStoragePath, thumbnailImage);

        thumbnailPath = thumbnailFileName;
        print('✅ Thumbnail uploaded: $thumbnailPath');
      }

      await _supabase.from('pets').insert({
        'pet_id': petId,
        'name': petName,
        'species': species,
        'breed': breed,
        'age': age,
        'gender': gender,
        'size': size,
        'status': _capitalize(status),
        'description': description,
        'thumbnail_path': thumbnailPath,
        'is_adopted': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      print('✅ Pet basic information saved');

      // Upload additional images to Supabase Storage
      final List<Map<String, dynamic>> imageInserts = [];
      // Upload only non-thumbnail images into the `pets` folder and insert
      // their records into `pets_images`. The thumbnail is handled above
      // and should not be duplicated as a regular pet image.
      final nonThumbnailImages = <File>[];
      for (var img in selectedImages) {
        // Compare by path when possible to avoid File equality issues
        final isThumb =
            thumbnailImage != null && img.path == thumbnailImage.path;
        if (!isThumb) nonThumbnailImages.add(img);
      }

      print('📸 Uploading ${nonThumbnailImages.length} additional images...');

      for (var i = 0; i < nonThumbnailImages.length; i++) {
        final imageFile = nonThumbnailImages[i];
        final imageFileName = '$petName-$i.png';

        await _supabase.storage
            .from('pets')
            .upload('$petId/$imageFileName', imageFile);

        imageInserts.add({
          'pet_id': petId,
          'image_path': imageFileName,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (imageInserts.isNotEmpty) {
        await _supabase.from('pets_images').insert(imageInserts);
        print('✅ ${imageInserts.length} images uploaded and saved');
      }

      // print('📋 Saving pet characteristics...');
      await _supabase.from('pet_characteristics').insert({
        'pet_id': petId,
        'behavior_tags': {
          'good_with_children': goodWithChildren,
          'good_with_dogs': goodWithDogs,
          'good_with_cats': goodWithCats,
          'house_trained': houseTrained,
        },
        'health_notes': {
          'vaccinations': isVaccinationUpToDate,
          'spayed_neutered': isSpayedNeutered,
          'health_notes': healthNotes,
          'special_needs': hasSpecialNeeds,
        },
        'activity_level': {
          'energy_level': energyLevel,
          'playfulness': playfulness,
          'daily_exercise': dailyExerciseNeeds,
        },
        'temperament': {
          'affection_level': affectionLevel,
          'independence': independence,
          'adaptability': adaptability,
          'training_difficulty': trainingDifficulty,
          'grooming_needs': groomingNeeds,
        },
        'quirk': quirk,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await auditTrailService.track(
        action: 'pet_created',
        entityType: 'pet',
        entityId: petId,
        metadata: {
          'name': petName,
          'species': species,
          'status': _capitalize(status),
          'image_count': imageInserts.length + (thumbnailPath != null ? 1 : 0),
        },
      );

      print('🎉 Pet saved successfully with ID: $petId');
    } catch (e) {
      print('❌ Error saving pet: $e');
      rethrow;
    }
  }

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
    String? existingThumbnailPath,
  }) async {
    try {
      print('✏️ Updating pet: $petName (ID: $petId)');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Note: Image deletions are now handled immediately when user clicks delete button
      // So deletedImagePaths is kept for backward compatibility but may not be used
      if (deletedImagePaths.isNotEmpty) {
        print('🗑️ Processing ${deletedImagePaths.length} deleted images...');
        for (final pathOrUrl in deletedImagePaths) {
          try {
            String filename;
            if (pathOrUrl.contains('/pets/')) {
              filename = pathOrUrl.split('/').last;
            } else {
              filename = pathOrUrl;
            }

            // Check if the file exists before attempting to delete
            final storagePath = '$petId/$filename';
            print('Attempting to delete: $storagePath');

            await _supabase.storage.from('pets').remove([storagePath]);
            await _supabase.from('pets_images').delete().match({
              'pet_id': petId,
              'image_path': filename,
            });
            print('✅ Deleted image: $filename');
          } catch (e) {
            print('⚠️ Could not delete image (may already be deleted): $e');
          }
        }
      }

      // Upload new thumbnail if provided
      String? thumbnailPath;
      if (thumbnailImage != null) {
        print('📸 Uploading new thumbnail image...');
        final thumbnailFileName = '$petName-thumbnail.png';
        final thumbnailStoragePath = '$petId/$thumbnailFileName';

        // Delete old thumbnail first, then upload new one
        try {
          await _supabase.storage.from('pets').remove([thumbnailStoragePath]);
        } catch (e) {
          print('Note: Could not remove old thumbnail (may not exist): $e');
        }

        await _supabase.storage
            .from('pets')
            .upload(thumbnailStoragePath, thumbnailImage);

        thumbnailPath = thumbnailFileName;
        print('✅ Thumbnail uploaded: $thumbnailPath');
      }

      // Update pet basic information
      print('📝 Updating pet basic information...');
      final petUpdateData = {
        'name': petName,
        'species': species,
        'breed': breed,
        'age': age,
        'gender': gender,
        'size': size,
        'status': _capitalize(status),
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (thumbnailPath != null) {
        petUpdateData['thumbnail_path'] = thumbnailPath;
      } else if (existingThumbnailPath != null) {
        String filename = existingThumbnailPath;
        try {
          final uri = Uri.parse(existingThumbnailPath);
          if (uri.pathSegments.isNotEmpty) filename = uri.pathSegments.last;
        } catch (_) {}

        petUpdateData['thumbnail_path'] = filename;
      }

      await _supabase.from('pets').update(petUpdateData).eq('pet_id', petId);
      print('✅ Pet basic information updated');

      if (selectedImages.isNotEmpty) {
        final List<Map<String, dynamic>> imageInserts = [];
        print('📸 Uploading ${selectedImages.length} new images...');

        final nonThumbs = <File>[];
        for (var img in selectedImages) {
          final isThumb =
              thumbnailImage != null && img.path == thumbnailImage.path;
          if (!isThumb) nonThumbs.add(img);
        }

        for (var i = 0; i < nonThumbs.length; i++) {
          final imageName =
              '$petName-image-${DateTime.now().millisecondsSinceEpoch}-$i.png';
          final imagePath = '$petId/$imageName';

          await _supabase.storage.from('pets').upload(imagePath, nonThumbs[i]);

          imageInserts.add({
            'pet_id': petId,
            'image_path': imageName,
            'created_at': DateTime.now().toIso8601String(),
          });

          print('✅ Image uploaded: $imageName');
        }

        if (imageInserts.isNotEmpty) {
          await _supabase.from('pets_images').insert(imageInserts);
          print('✅ Image records inserted');
        }
      }

      print('📋 Updating pet characteristics...');
      await _supabase.from('pet_characteristics').update({
        'behavior_tags': {
          'good_with_children': goodWithChildren,
          'good_with_dogs': goodWithDogs,
          'good_with_cats': goodWithCats,
          'house_trained': houseTrained,
        },
        'health_notes': {
          'vaccinations': isVaccinationUpToDate,
          'spayed_neutered': isSpayedNeutered,
          'special_needs': hasSpecialNeeds,
          'health_notes_text': healthNotes,
          'special_needs_description': specialNeedsDescription,
        },
        'activity_level': {
          'energy_level': energyLevel.toInt(),
          'playfulness': playfulness.toInt(),
          'daily_exercise': dailyExerciseNeeds,
        },
        'temperament': {
          'temperament_traits': selectedTraits,
          'affection_level': affectionLevel.toInt(),
          'independence': independence.toInt(),
          'adaptability': adaptability.toInt(),
          'training_difficulty': trainingDifficulty,
          'grooming_needs': groomingNeeds,
        },
        'quirk': quirk,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('pet_id', petId);
      print('✅ Pet characteristics updated');

      await auditTrailService.track(
        action: 'pet_updated',
        entityType: 'pet',
        entityId: petId,
        metadata: {
          'name': petName,
          'species': species,
          'status': _capitalize(status),
          'deleted_image_count': deletedImagePaths.length,
          'added_image_count': selectedImages.length,
        },
      );

      print('🎉 Pet updated successfully with ID: $petId');
    } catch (e) {
      print('❌ Error updating pet: $e');
      rethrow;
    }
  }

  /// 🗑️ Delete pet and all associated data
  Future<void> deletePet(String petId) async {
    try {
      print('🗑️ Deleting pet with ID: $petId');

      // Get pet details first to find images to delete from storage
      final pet = await getPetById(petId);

      // Delete images from storage
      if (pet != null) {
        // Delete thumbnail
        if (pet.thumbnailPath != null) {
          try {
            await _supabase.storage
                .from('pet_thumbnails')
                .remove([pet.thumbnailPath!]);
            print('✅ Deleted thumbnail from storage');
          } catch (e) {
            print('⚠️ Error deleting thumbnail: $e');
          }
        }

        // Delete all pet images from storage
        for (final imageUrl in pet.imageUrls) {
          try {
            // Extract path from URL
            final uri = Uri.parse(imageUrl);
            final path = uri.pathSegments.last;
            await _supabase.storage.from('pet_images').remove([path]);
          } catch (e) {
            print('⚠️ Error deleting image: $e');
          }
        }
      }

      // Delete pet images records (will cascade from pets_images table)
      await _supabase.from('pets_images').delete().eq('pet_id', petId);
      print('✅ Deleted pet images records');

      // Delete pet characteristics
      await _supabase.from('pet_characteristics').delete().eq('pet_id', petId);
      print('✅ Deleted pet characteristics');

      // Delete favorites
      await _supabase.from('favorites').delete().eq('pet_id', petId);
      print('✅ Deleted favorites');

      // Finally delete the pet record
      await _supabase.from('pets').delete().eq('pet_id', petId);
      print('✅ Deleted pet record');

      await auditTrailService.track(
        action: 'pet_deleted',
        entityType: 'pet',
        entityId: petId,
        metadata: {
          'pet_id': petId,
          'pet_name': pet?.name,
        },
      );

      print('🎉 Pet deleted successfully!');
    } catch (e) {
      print('❌ Error deleting pet: $e');
      rethrow;
    }
  }

  Future<void> deletePetImage({
    required String petId,
    required String imageUrl,
  }) async {
    try {
      print('🗑️ Attempting to delete image...');
      print('Pet ID: $petId');
      print('Image URL: $imageUrl');

      String storagePath;
      if (imageUrl.contains('/pets/')) {
        storagePath = imageUrl.split('/pets/').last;
        print('📍 Extracted storage path: $storagePath');
      } else {
        storagePath = '$petId/$imageUrl';
        print('📍 Constructed storage path: $storagePath');
      }

      final bucket = _supabase.storage.from('pets');

      try {
        final list = await supabase.storage.from('pets').list(path: petId);
        print('📂 Files in folder $petId: ${list.map((e) => e.name).toList()}');
      } catch (e) {
        print('⚠️ Could not list files: $e');
      }

      final result = await bucket.remove([storagePath]);
      print('✅ Deleted from storage: $storagePath');
      print('Delete result: $result');

      final filename = storagePath.split('/').last;

      try {
        await _supabase
            .from('pets_images')
            .delete()
            .eq('pet_id', petId)
            .eq('image_path', filename);
        print('✅ Deleted database record for: $filename');

        await auditTrailService.track(
          action: 'pet_image_deleted',
          entityType: 'pet_image',
          entityId: petId,
          metadata: {
            'pet_id': petId,
            'image_path': filename,
          },
        );
      } catch (e) {
        print('⚠️ Could not delete DB record for $filename: $e');
      }
    } catch (e) {
      print('❌ Error deleting pet image: $e');
      rethrow;
    }
  }
}
