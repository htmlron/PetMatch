import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';
import 'package:petmatch/core/model/pet_match_model.dart';

class BumbleStylePetCard extends StatefulWidget {
  final PetMatch petMatch;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkipPet;
  final VoidCallback onLikePet;
  final VoidCallback? onLearnMore;

  const BumbleStylePetCard({
    Key? key,
    required this.petMatch,
    required this.onPrevious,
    required this.onNext,
    required this.onSkipPet,
    required this.onLikePet,
    this.onLearnMore,
  }) : super(key: key);

  @override
  State<BumbleStylePetCard> createState() => _BumbleStylePetCardState();
}

class _BumbleStylePetCardState extends State<BumbleStylePetCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _swipeLocked = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleSwipe(DragEndDetails details) async {
    if (_swipeLocked) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 250) return;

    _swipeLocked = true;
    try {
      if (velocity < 0) {
        // Swipe left = view next pet
        widget.onNext();
      } else {
        // Swipe right = view previous pet
        widget.onPrevious();
      }
    } finally {
      if (mounted) {
        setState(() {
          _swipeLocked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.petMatch.pet;

    final images = pet.fullImageUrls.isNotEmpty
        ? pet.fullImageUrls
        : (pet.thumbnailUrl != null ? [pet.thumbnailUrl!] : []);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.6;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: _handleSwipe,
              child: Stack(
                children: [
                  // Fixed image area (TikTok-style)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight,
                    child: Stack(
                      children: [
                        PageView(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentImageIndex = index),
                          children: images.isNotEmpty
                              ? images.map((url) {
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    maxHeightDiskCache: 1200,
                                    maxWidthDiskCache: 800,
                                    memCacheHeight: 1000,
                                    memCacheWidth: 600,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.pets,
                                              size: 80,
                                              color: Colors.grey[400]),
                                          const SizedBox(height: 16),
                                          Text('Image failed to load',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList()
                              : [
                                  Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.pets,
                                            size: 80, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        Text('No image available',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                        ),

                        // Match badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  widget.petMatch.matchColor.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.petMatch.matchIcon,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                    '${widget.petMatch.totalMatchPercent.toInt()}%',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),

                        // Image indicators (dots)
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == index ? 18 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Left swipe indicator
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                        // Right swipe indicator
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content that starts below the image and scrolls over it
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // top spacing so content starts below the fixed image
                          SizedBox(height: imageHeight - 40),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(pet.name,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            const SizedBox(height: 4),
                                            Text(
                                                '${pet.age ?? '?'} ${pet.ageUnit ?? 'years old'} • ${pet.breed ?? pet.species}${pet.size != null ? ' • ${pet.size}' : ''}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (pet.description != null) ...[
                                    const SizedBox(height: 16),
                                    Text(pet.description!,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.6)),
                                  ],

                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (pet.goodWithChildren == true)
                                        _buildTraitChip('👶 Good with Kids'),
                                      if ((pet.goodWithDogs == true) ||
                                          (pet.goodWithCats == true))
                                        _buildTraitChip(
                                            '🐾 Good with other pets'),
                                      if (pet.affectionLevel != null)
                                        _buildTraitChip(
                                            '💞 ${pet.getAffectionLevelDescription()}'),
                                      if (pet.sheddingLevel != null)
                                        _buildTraitChip(
                                            '🧥 ${pet.getSheddingDescription()}'),
                                      if (pet.houseTrained == true)
                                        _buildTraitChip('🏠 House Trained'),
                                      if (pet.isVaccinated)
                                        _buildTraitChip(
                                            '💉 Vaccinated${pet.vaccinationUpdateMonthsSuffix}'),
                                      if (pet.spayedNeutered == true)
                                        _buildTraitChip('✂️ Spayed/Neutered'),
                                      if (pet.specialNeeds == true)
                                        _buildTraitChip('⭐ Special Needs'),
                                    ],
                                  ),

                                  const SizedBox(
                                      height:
                                          120), // leave space for fixed buttons
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Fixed action buttons
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            auditTrailService.trackButtonClick(
                              buttonLabel: 'Skip',
                              screen: 'Match dashboard',
                              metadata: {
                                'pet_name': pet.name,
                              },
                            );
                            widget.onSkipPet();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black),
                          child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Icon(Icons.close)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            auditTrailService.trackButtonClick(
                              buttonLabel: 'Like',
                              screen: 'Match dashboard',
                              metadata: {
                                'pet_name': pet.name,
                              },
                            );
                            widget.onLikePet();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white),
                          child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Icon(Icons.favorite)),
                        ),
                      ],
                    ),
                  ),

                  // Why This Match? button - placed on top level for proper tap detection
                  Positioned(
                    top: 80,
                    left: 16,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        auditTrailService.trackButtonClick(
                          buttonLabel: 'Why This Match?',
                          screen: 'Match dashboard',
                          metadata: {
                            'pet_name': pet.name,
                          },
                        );
                        widget.onLearnMore?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Text('Why This Match?',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTraitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(18)),
      child: Text(text,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800])),
    );
  }
}
