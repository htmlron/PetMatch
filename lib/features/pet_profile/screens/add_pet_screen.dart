import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_provider.dart';
import 'package:petmatch/features/pet_profile/widgets/add_pet_widgets/steps/activity_info_step.dart';
import 'package:petmatch/features/pet_profile/widgets/add_pet_widgets/steps/basic_info_step.dart';
import 'package:petmatch/features/pet_profile/widgets/add_pet_widgets/steps/behavior_info_step.dart';
import 'package:petmatch/features/pet_profile/widgets/add_pet_widgets/steps/health_info_step.dart';
import 'package:petmatch/features/pet_profile/widgets/add_pet_widgets/steps/temperament_info_step.dart';
import 'package:uuid/uuid.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  final Pet? petToEdit;

  const AddPetScreen({super.key, this.petToEdit});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Image handling
  final List<File> _selectedImages = [];
  File? _thumbnailImage;
  List<String> _existingImageUrls = [];
  String? _existingThumbnailUrl;
  final List<String> _deletedImagePaths = [];

  // Basic Information Controllers
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quirkController = TextEditingController();

  String? _petId;

  // Basic Information Values
  String? _selectedSpecies;
  String? _selectedGender;
  String? _selectedSize;
  String? _selectedStatus;

  // Health Information Controllers
  final TextEditingController _healthNotesController = TextEditingController();
  final TextEditingController _specialNeedsDescController =
      TextEditingController();

  // Health Information Values
  bool? _isVaccinationUpToDate;
  bool? _isSpayedNeutered;
  bool? _hasSpecialNeeds;

  // Behavior Information Controllers
  final TextEditingController _behavioralNotesController =
      TextEditingController();

  // Behavior Information Values
  bool? _goodWithChildren;
  bool? _goodWithDogs;
  bool? _goodWithCats;
  bool? _houseTrained;

  // Activity Information Values
  double _energyLevel = 3.0;
  double _playfulness = 3.0;
  String? _dailyExerciseNeeds;

  // Temperament Information Values
  final List<String> _selectedTraits = [];
  double _affectionLevel = 3.0;
  double _independence = 3.0;
  double _adaptability = 3.0;
  double _trainingDifficulty = 3.0; // 1: beginner ... 5: expert
  int? _groomingNeeds;

  @override
  void initState() {
    super.initState();
    if (widget.petToEdit != null) {
      _prefillFormData();
    } else {
      // Generate new UUID for new pet
      _petId = const Uuid().v4();
    }
  }

  void _prefillFormData() {
    final pet = widget.petToEdit!;

    // Basic Information
    _petId = pet.id;
    _petNameController.text = pet.name;
    _breedController.text = pet.breed ?? '';
    _ageController.text = pet.age?.toString() ?? '';
    _descriptionController.text = pet.description ?? '';
    _quirkController.text = pet.quirks ?? '';
    _selectedSpecies = pet.species;
    // Normalize gender to capitalized form for the dropdown
    _selectedGender = pet.gender == null
        ? null
        : (pet.gender!.trim().isEmpty
            ? null
            : '${pet.gender!.trim()[0].toUpperCase()}${pet.gender!.trim().substring(1).toLowerCase()}');
    _selectedSize = pet.size;
    _selectedStatus = pet.status;

    // Existing images - use fullImageUrls to get complete Supabase URLs
    _existingImageUrls = List.from(pet.fullImageUrls);
    _existingThumbnailUrl = pet.thumbnailUrl;

    // Health Information
    _isVaccinationUpToDate = pet.vaccinations;
    _isSpayedNeutered = pet.spayedNeutered;
    _hasSpecialNeeds = pet.specialNeeds;
    _groomingNeeds = pet.groomingNeeds;

    // Behavior Information
    _goodWithChildren = pet.goodWithChildren;
    _goodWithDogs = pet.goodWithDogs;
    _goodWithCats = pet.goodWithCats;
    _houseTrained = pet.houseTrained;

    // Activity Information
    _energyLevel = pet.energyLevel?.toDouble() ?? 3.0;
    _playfulness = pet.playfulness?.toDouble() ?? 3.0;
    _dailyExerciseNeeds = pet.dailyExercise;

    // Temperament Information
    _selectedTraits.clear();
    _selectedTraits.addAll(pet.temperamentTraits);
    _affectionLevel = pet.affectionLevel?.toDouble() ?? 3.0;
    _independence = pet.independence?.toDouble() ?? 3.0;
    _adaptability = pet.adaptability?.toDouble() ?? 3.0;
    _trainingDifficulty = pet.trainingDifficulty?.toDouble() ?? 2.0;
  }

  // ignore: unused_element
  String? _mapTrainingDifficultyToLevel(int difficulty) {
    if (difficulty <= 1) return 'beginner';
    if (difficulty == 2) return 'novice';
    if (difficulty == 3) return 'intermediate';
    if (difficulty == 4) return 'advanced';
    return 'expert';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _petNameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _healthNotesController.dispose();
    _specialNeedsDescController.dispose();
    _behavioralNotesController.dispose();
    _quirkController.dispose();
    super.dispose();
  }

  String _capitalize(String? s, {String defaultValue = ''}) {
    if (s == null || s.trim().isEmpty) return defaultValue;
    final trimmed = s.trim();
    return trimmed.length == 1
        ? trimmed.toUpperCase()
        : '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill in all required fields');
      return;
    }

    try {
      final isEditing = widget.petToEdit != null;

      if (isEditing) {
        // Update existing pet
        await ref.read(petsProvider.notifier).updatePet(
              petId: widget.petToEdit!.id,
              petName: _petNameController.text.trim(),
              species: _selectedSpecies!,
              breed: _breedController.text.trim(),
              age: int.tryParse(_ageController.text.trim()) ?? 0,
              gender: _capitalize(_selectedGender),
              size: _selectedSize!,
              status: _capitalize(_selectedStatus, defaultValue: 'Available'),
              description: _descriptionController.text.trim(),
              thumbnailImage: _thumbnailImage,
              selectedImages: _selectedImages,
              deletedImagePaths: _deletedImagePaths,
              isVaccinationUpToDate: _isVaccinationUpToDate,
              isSpayedNeutered: _isSpayedNeutered,
              healthNotes: _healthNotesController.text.trim(),
              hasSpecialNeeds: _hasSpecialNeeds,
              specialNeedsDescription: _hasSpecialNeeds == true
                  ? _specialNeedsDescController.text.trim()
                  : '',
              groomingNeeds: _groomingNeeds,
              goodWithChildren: _goodWithChildren,
              goodWithDogs: _goodWithDogs,
              goodWithCats: _goodWithCats,
              houseTrained: _houseTrained,
              behavioralNotes: _behavioralNotesController.text.trim(),
              energyLevel: _energyLevel,
              playfulness: _playfulness,
              dailyExerciseNeeds: _dailyExerciseNeeds,
              selectedTraits: _selectedTraits,
              affectionLevel: _affectionLevel,
              independence: _independence,
              adaptability: _adaptability,
              trainingDifficulty: _trainingDifficulty.toInt(),
              quirk: _quirkController.text.trim(),
              existingThumbnailPath: _existingThumbnailUrl,
            );
      } else {
        // Add new pet
        await ref.read(petsProvider.notifier).savePet(
              petName: _petNameController.text.trim(),
              species: _selectedSpecies!,
              breed: _breedController.text.trim(),
              age: int.tryParse(_ageController.text.trim()) ?? 0,
              gender: _capitalize(_selectedGender),
              size: _selectedSize!,
              status: _capitalize(_selectedStatus, defaultValue: 'Available'),
              description: _descriptionController.text.trim(),
              thumbnailImage: _thumbnailImage,
              selectedImages: _selectedImages,
              isVaccinationUpToDate: _isVaccinationUpToDate,
              isSpayedNeutered: _isSpayedNeutered,
              healthNotes: _healthNotesController.text.trim(),
              hasSpecialNeeds: _hasSpecialNeeds,
              groomingNeeds: _groomingNeeds,
              goodWithChildren: _goodWithChildren,
              goodWithDogs: _goodWithDogs,
              goodWithCats: _goodWithCats,
              houseTrained: _houseTrained,
              energyLevel: _energyLevel,
              playfulness: _playfulness,
              dailyExerciseNeeds: _dailyExerciseNeeds,
              affectionLevel: _affectionLevel,
              independence: _independence,
              adaptability: _adaptability,
              trainingDifficulty: _trainingDifficulty.toInt(),
              quirk: _quirkController.text.trim(),
            );
      }

      final errorMessage = ref.read(petsProvider).errorMessage;
      if (errorMessage != null) {
        _showErrorSnackBar(errorMessage);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEditing
                        ? '✅ ${_petNameController.text} has been updated successfully!'
                        : '🎉 ${_petNameController.text} has been added successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Error saving pet: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _savePet();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.petToEdit != null ? 'Edit Pet' : 'Add New Pet',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  BasicInfoStep(
                    petId: _petId!,
                    petNameController: _petNameController,
                    breedController: _breedController,
                    ageController: _ageController,
                    descriptionController: _descriptionController,
                    quirkController: _quirkController,
                    selectedSpecies: _selectedSpecies,
                    selectedGender: _selectedGender,
                    selectedSize: _selectedSize,
                    selectedStatus: _selectedStatus,
                    onSpeciesChanged: (value) =>
                        setState(() => _selectedSpecies = value),
                    onGenderChanged: (value) =>
                        setState(() => _selectedGender = value),
                    onSizeChanged: (value) =>
                        setState(() => _selectedSize = value),
                    onStatusChanged: (value) =>
                        setState(() => _selectedStatus = value),
                    selectedImages: _selectedImages,
                    thumbnailImage: _thumbnailImage,
                    onImagesChanged: (images) => setState(() => _selectedImages
                      ..clear()
                      ..addAll(images)),
                    onThumbnailChanged: (image) =>
                        setState(() => _thumbnailImage = image),
                    existingImageUrls: _existingImageUrls,
                    existingThumbnailUrl: _existingThumbnailUrl,
                    onExistingImagesChanged: (updatedUrls) {
                      setState(() {
                        final deleted = _existingImageUrls
                            .where((url) => !updatedUrls.contains(url))
                            .toList();

                        _deletedImagePaths.addAll(deleted);
                        _existingImageUrls = updatedUrls;
                      });
                    },
                    onExistingThumbnailChanged: (url) {
                      setState(() {
                        _existingThumbnailUrl = url;
                        _thumbnailImage = null;
                      });
                    },
                  ),
                  HealthInfoStep(
                    healthNotesController: _healthNotesController,
                    specialNeedsDescController: _specialNeedsDescController,
                    groomingNeeds: _groomingNeeds,
                    hasSpecialNeeds: _hasSpecialNeeds,
                    isVaccinationUpToDate: _isVaccinationUpToDate,
                    isSpayedNeutered: _isSpayedNeutered,
                    onGroomingNeedsChanged: (value) =>
                        setState(() => _groomingNeeds = value),
                    onHasSpecialNeedsChanged: (value) =>
                        setState(() => _hasSpecialNeeds = value),
                    onVaccinationChanged: (value) =>
                        setState(() => _isVaccinationUpToDate = value),
                    onSpayedNeuteredChanged: (value) =>
                        setState(() => _isSpayedNeutered = value),
                  ),
                  BehaviorInfoStep(
                    behavioralNotesController: _behavioralNotesController,
                    goodWithChildren: _goodWithChildren,
                    goodWithDogs: _goodWithDogs,
                    goodWithCats: _goodWithCats,
                    houseTrained: _houseTrained,
                    onGoodWithChildrenChanged: (value) =>
                        setState(() => _goodWithChildren = value),
                    onGoodWithDogsChanged: (value) =>
                        setState(() => _goodWithDogs = value),
                    onGoodWithCatsChanged: (value) =>
                        setState(() => _goodWithCats = value),
                    onHouseTrainedChanged: (value) =>
                        setState(() => _houseTrained = value),
                  ),
                  ActivityInfoStep(
                    energyLevel: _energyLevel,
                    dailyExerciseNeeds: _dailyExerciseNeeds,
                    playfulness: _playfulness,
                    onEnergyLevelChanged: (value) =>
                        setState(() => _energyLevel = value),
                    onDailyExerciseNeedsChanged: (value) =>
                        setState(() => _dailyExerciseNeeds = value),
                    onPlayfulnessChanged: (value) =>
                        setState(() => _playfulness = value),
                  ),
                  TemperamentInfoStep(
                    selectedTraits: _selectedTraits,
                    affectionLevel: _affectionLevel,
                    independence: _independence,
                    adaptability: _adaptability,
                    trainingDifficulty: _trainingDifficulty,
                    onSelectedTraitsChanged: (traits) =>
                        setState(() => _selectedTraits
                          ..clear()
                          ..addAll(traits)),
                    onAffectionLevelChanged: (value) =>
                        setState(() => _affectionLevel = value),
                    onIndependenceChanged: (value) =>
                        setState(() => _independence = value),
                    onAdaptabilityChanged: (value) =>
                        setState(() => _adaptability = value),
                    onTrainingDifficultyChanged: (value) =>
                        setState(() => _trainingDifficulty = value),
                  ),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? Colors.black
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < _totalSteps - 1) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(_currentStep),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return '📝 Basic Information';
      case 1:
        return '🏥 Health Information';
      case 2:
        return '🐾 Behavior & Compatibility';
      case 3:
        return '⚡ Activity & Energy';
      case 4:
        return '🧠 Temperament';
      default:
        return '';
    }
  }

  Widget _buildNavigationButtons() {
    final isLoading = ref.watch(petsProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFFF9800), width: 2),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFF9800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == _totalSteps - 1 ? 'Save Pet' : 'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
