import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/features/home/provider/favorites_provider.dart';
import 'package:petmatch/widgets/divider_widget.dart';

class PetDetailsModal extends StatefulWidget {
  final List<Pet> pets;
  final int initialIndex;

  const PetDetailsModal({
    super.key,
    required this.pets,
    required this.initialIndex,
  });

  @override
  State<PetDetailsModal> createState() => _PetDetailsModalState();
}

class _PetDetailsModalState extends State<PetDetailsModal> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, PageController> _imagePageControllers = {};
  final Map<int, int> _currentImageIndices = {};

  @override
  void initState() {
    super.initState();
    // Ensure initialIndex is within bounds
    _currentIndex = widget.initialIndex.clamp(0, widget.pets.length - 1);
    try {
      _pageController = PageController(initialPage: _currentIndex);
    } catch (e) {
      print('Error initializing PageController: $e');
      _pageController = PageController(initialPage: 0);
    }
    for (int i = 0; i < widget.pets.length; i++) {
      _imagePageControllers[i] = PageController();
      _currentImageIndices[i] = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _imagePageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Guard against empty pet list
    if (widget.pets.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No pet data available',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _currentImageIndices[index] = 0;
                    });
                    if (_imagePageControllers[index]?.hasClients ?? false) {
                      _imagePageControllers[index]!.jumpToPage(0);
                    }
                  },
                  itemCount: widget.pets.length,
                  itemBuilder: (context, index) => _buildPetDetails(
                      widget.pets[index], index, scrollController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetDetails(
      Pet pet, int petIndex, ScrollController scrollController) {
    try {
      final imageUrls = pet.fullImageUrls;
      print('Image Url: $imageUrls');

      // Ensure imagePageController exists for this pet
      if (!_imagePageControllers.containsKey(petIndex)) {
        _imagePageControllers[petIndex] = PageController();
      }
      
      final imagePageController = _imagePageControllers[petIndex]!;
      final currentImageIndex = _currentImageIndices[petIndex] ?? 0;

      // Use the provided scrollController so the DraggableScrollableSheet
      // can control scrolling. ListView provides a proper scrollable
      // child that works with the sheet's controller.
      final screenHeight = MediaQuery.of(context).size.height;
      return ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Pet Images Carousel (or placeholder if no images)
          Stack(
            children: [
              SizedBox(
                // Make the image area responsive: cap to 45% of screen
                // height but keep the previous 450px as a maximum.
                height: screenHeight * 0.45 > 450 ? 450 : screenHeight * 0.45,
                child: imageUrls.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(25)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No images available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    )
                  : PageView.builder(
                      controller: imagePageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndices[petIndex] = index;
                        });
                      },
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(25)),
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            height: 450,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            maxHeightDiskCache: 800,
                            maxWidthDiskCache: 800,
                            memCacheHeight: 720,
                            memCacheWidth: 480,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(strokeWidth: 2),
                                    const SizedBox(height: 12),
                                    Text('Loading image...',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported,
                                        size: 80, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    Text('Image failed to load',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Image indicators
            if (imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        imageUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: currentImageIndex == index ? 8 : 6,
                          height: currentImageIndex == index ? 8 : 6,
                          decoration: BoxDecoration(
                            color: currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Close button
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 24),
                ),
              ),
            ),

            // Favorite button
            Positioned(
              top: 16,
              right: 16,
              child: Consumer(
                builder: (context, ref, _) {
                  final favoritesState = ref.watch(favoritesProvider);
                  final favoritesNotifier =
                      ref.read(favoritesProvider.notifier);
                  final isFavorite =
                      favoritesState.favoriteIds.contains(pet.id);
                  return GestureDetector(
                    onTap: () async {
                      if (isFavorite) {
                        await favoritesNotifier.removeFavorite(context, pet.id);
                      } else {
                        await favoritesNotifier.addFavorite(context, pet.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 24,
                        color: isFavorite ? Colors.red : _getPrimaryColor(pet),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    if (widget.pets.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.pets.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentIndex == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? _getPrimaryColor(
                                        widget.pets[_currentIndex])
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Pet Info Section
        Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 500 ? 20.0 : 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Gender (restructured to prevent overflow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pet.species.toLowerCase() == 'dog')
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              'assets/icons/dog.png',
                              width: 28,
                              height: 28,
                            ),
                          )
                        else if (pet.species.toLowerCase() == 'cat')
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              'assets/icons/cat.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            pet.name,
                            style: GoogleFonts.newsreader(
                              fontSize: MediaQuery.of(context).size.width > 500 ? 28 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          pet.gender?.toLowerCase() == 'male'
                              ? Icons.male
                              : Icons.female,
                          color: pet.gender?.toLowerCase() == 'male'
                              ? Colors.blue
                              : Colors.pink,
                          size: MediaQuery.of(context).size.width > 500 ? 24 : 20,
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width > 500 ? 8 : 6),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 500 ? 220 : 180,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                      ),
                      child: Text(
                        pet.breed ?? pet.species,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 500 ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (pet.description != null &&
                    pet.description!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      pet.description!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),

                // Quirk display (optional)
                if (pet.quirks != null && pet.quirks!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.18),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quirk',
                            style: GoogleFonts.newsreader(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pet.quirks!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                const DividerWidget(verticalHeight: 5),

                // Info Chips
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoChip(pet, pet.species, Icons.pets),
                    _buildInfoChip(
                        pet, pet.size ?? "Medium", Icons.straighten),
                    _buildInfoChip(pet, pet.displayAge, Icons.cake),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.health_and_safety, size: 22),
                    const SizedBox(width: 5),
                    Text(
                      'Health',
                      style: GoogleFonts.newsreader(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildHealthSection(pet),

                const SizedBox(height: 24),

                // Characteristics Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      'Characteristics',
                      style: GoogleFonts.newsreader(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Behavior Section
                _buildBehaviorSection(pet),

                const SizedBox(height: 15),

                // Temperament
                _buildCharacteristicsSection(pet),
              ],
            )),
      ],
    );
    } catch (e) {
      print('Error building pet details: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading pet details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHealthSection(Pet pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((pet.vaccinations != null || pet.vaccinationTypes.isNotEmpty) ||
            pet.spayedNeutered != null ||
            pet.groomingNeeds != null ||
            pet.sheddingLevel != null ||
            pet.specialNeeds != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (pet.dailyExercise != null)
                _buildHealthBadge('Daily Exercise - ${pet.dailyExercise}',
                    Icons.directions_run, Colors.blue),
              if (pet.isVaccinated)
                _buildHealthBadge(
                    pet.vaccinationTypes.isNotEmpty
                    ? 'Vaccinated: ${pet.vaccinationSummary}${pet.vaccinationUpdateMonthsSuffix}'
                    : 'Vaccinated${pet.vaccinationUpdateMonthsSuffix}',
                    Icons.vaccines,
                    Colors.green),
              if (pet.spayedNeutered == true)
                _buildHealthBadge(
                    'Spayed/Neutered', Icons.healing, Colors.teal),
              if (pet.specialNeeds == true)
                _buildHealthBadge(
                    'Special Needs', Icons.medical_services, Colors.red),
              if (pet.groomingNeeds != null)
                _buildHealthBadge(
                  pet.getGroomingDescription(),
                  Icons.content_cut,
                  Colors.indigo,
                ),
              if (pet.sheddingLevel != null)
                _buildHealthBadge(
                  pet.getSheddingDescription(),
                  Icons.brush,
                  Colors.deepOrange,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildBehaviorSection(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPrimaryColorMedium(pet), width: 2),
        color: _getPrimaryColorLight(pet).withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pet.goodWithChildren != null)
            _buildBehaviorItem(
              pet,
              'Good with Children',
              pet.goodWithChildren == true,
              Icons.child_care,
            ),
          DividerWidget(
            verticalHeight: 1,
            color: _getPrimaryColor(pet).withOpacity(0.5),
          ),
          if (pet.goodWithDogs != null)
            _buildBehaviorItem(
              pet,
              'Good with Dogs',
              pet.goodWithDogs == true,
              Icons.pets,
            ),
          DividerWidget(
            verticalHeight: 1,
            color: _getPrimaryColor(pet).withOpacity(0.5),
          ),
          if (pet.goodWithCats != null)
            _buildBehaviorItem(
              pet,
              'Good with Cats',
              pet.goodWithCats == true,
              Icons.pets,
            ),
          DividerWidget(
            verticalHeight: 1,
            color: _getPrimaryColor(pet).withOpacity(0.5),
          ),
          if (pet.houseTrained != null)
            _buildBehaviorItem(
              pet,
              'House Trained',
              pet.houseTrained == true,
              Icons.home,
            ),
        ],
      ),
    );
  }

  Widget _buildBehaviorItem(Pet pet, String label, bool isYes, IconData icon) {
    final color = _getPrimaryColor(pet);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isYes ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isYes ? Colors.green[300]! : Colors.red[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isYes ? Icons.check_circle : Icons.cancel,
                color: isYes ? Colors.green[700] : Colors.red[700],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isYes ? 'Yes' : 'No',
                style: TextStyle(
                  color: isYes ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacteristicsSection(Pet pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pet.energyLevel != null)
          Column(
            children: [
              _buildLevelIndicator(
                'Energy Level',
                pet.energyLevel!,
                pet.getEnergyLevelDescription(),
                Colors.orange,
                Icons.bolt,
              ),
              const SizedBox(height: 16),
            ],
          ),

        // Playfulness
        if (pet.playfulness != null)
          Column(
            children: [
              _buildLevelIndicator(
                'Playfulness',
                pet.playfulness!,
                pet.playfulness! <= 3
                    ? 'Calm and relaxed'
                    : pet.playfulness! <= 6
                        ? 'Enjoys playtime'
                        : 'Very playful',
                Colors.purple,
                Icons.toys,
              ),
              const SizedBox(height: 16),
            ],
          ),

        if (pet.affectionLevel != null)
          Column(
            children: [
              _buildLevelIndicator(
                'Affection Level',
                pet.affectionLevel!,
                pet.getAffectionLevelDescription(),
                Colors.pink,
                Icons.favorite,
              ),
              const SizedBox(height: 16),
            ],
          ),

        // Independence
        if (pet.independence != null)
          Column(
            children: [
              _buildLevelIndicator(
                'Independence',
                pet.independence!,
                pet.independence! <= 3
                    ? 'Needs companionship'
                    : pet.independence! <= 6
                        ? 'Moderately independent'
                        : 'Very independent',
                Colors.indigo,
                Icons.self_improvement,
              ),
              const SizedBox(height: 16),
            ],
          ),

        // Adaptability
        if (pet.adaptability != null)
          Column(
            children: [
              _buildLevelIndicator(
                'Adaptability',
                pet.adaptability!,
                pet.getAdaptabilityDescription(),
                Colors.teal,
                Icons.adjust,
              ),
              const SizedBox(height: 16),
            ],
          ),

        // Training Difficulty
        if (pet.trainingDifficulty != null)
          Column(
            children: [
              _buildLevelIndicator(
                'Training',
                pet.trainingDifficulty!,
                pet.getTrainingDescription(),
                Colors.blue,
                Icons.school,
              ),
              const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }

  Widget _buildLevelIndicator(
    String label,
    int level,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.newsreader(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: level / 5,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.6), color],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$level/5',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(String label, IconData icon, Color color) {
    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                softWrap: true,
                maxLines: null,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(Pet pet, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _getPrimaryColorLight(pet),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPrimaryColorMedium(pet), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getPrimaryColorDark(pet),
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: _getPrimaryColorDark(pet)),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHealthItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Gender-based theme helpers
  Color _getPrimaryColor(Pet pet) {
    return pet.gender?.toLowerCase() == 'male' ? Colors.blue : Colors.pink;
  }

  Color _getPrimaryColorLight(Pet pet) {
    return pet.gender?.toLowerCase() == 'male'
        ? Colors.blue[50]!
        : Colors.pink[50]!;
  }

  Color _getPrimaryColorMedium(Pet pet) {
    return pet.gender?.toLowerCase() == 'male'
        ? Colors.blue[200]!
        : Colors.pink[200]!;
  }

  Color _getPrimaryColorDark(Pet pet) {
    return pet.gender?.toLowerCase() == 'male'
        ? Colors.blue[700]!
        : Colors.pink[700]!;
  }

  // ignore: unused_element
  List<Color> _getGradientColors(Pet pet) {
    return pet.gender?.toLowerCase() == 'male'
        ? [Colors.blue[100]!, Colors.blue[200]!]
        : [Colors.pink[100]!, Colors.pink[200]!];
  }
}

// Helper method to show the modal
void showPetDetailsModal(
  BuildContext context,
  List<Pet> pets,
  int initialIndex,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PetDetailsModal(
      pets: pets,
      initialIndex: initialIndex,
    ),
  );
}
