// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/model/pet_match_model.dart';
import 'package:petmatch/core/services/gemini_service.dart';
import 'package:petmatch/features/home/provider/match_provider/match_provider.dart';
// removed unused favorites import
import 'package:petmatch/features/home/widgets/ai_loader.dart';
import 'package:petmatch/features/home/widgets/bumble_style_pet_card.dart';
import 'package:petmatch/features/home/widgets/custom_bottom_navbar.dart';
import 'package:petmatch/features/home/widgets/pet_details_modal.dart';
import 'package:petmatch/core/model/pet_model.dart';

class MatchDashboard extends ConsumerStatefulWidget {
  const MatchDashboard({super.key});

  @override
  ConsumerState<MatchDashboard> createState() => _MatchDashboardState();
}

class _MatchDashboardState extends ConsumerState<MatchDashboard> {
  int _currentCardIndex = 0;
  bool _showListView = false;
  List<Pet>? _sizeMismatchedDogs;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(matchProvider.notifier).fetchMatchedPets());
  }

  void _showPetDetailsFromList(int index, List<PetMatch> petMatches) {
    try {
      if (petMatches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pet data available')),
        );
        return;
      }

      final matchedPets = petMatches.map((m) => m.pet).toList();
      final validIndex = index.clamp(0, matchedPets.length - 1);

      showPetDetailsModal(context, matchedPets, validIndex);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> showAppleIntelligenceLoader(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppleIntelligenceLoader(),
    );
  }

  Future<void> _showMatchExplanation(PetMatch petMatch) async {
    showAppleIntelligenceLoader(context);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final userProfileData = await supabase
          .from('user_profile')
          .select('user_lifestyle, personality_traits, household_info')
          .eq('user_id', userId)
          .single();

      final userLifestyle =
          userProfileData['user_lifestyle'] as Map<String, dynamic>?;
      final userPersonality =
          userProfileData['personality_traits'] as Map<String, dynamic>?;
      final userHousehold =
          userProfileData['household_info'] as Map<String, dynamic>?;

      final geminiService = GeminiService();
      final explanation = await geminiService.generateMatchExplanation(
        petMatch,
        userLifestyle: userLifestyle,
        userPersonality: userPersonality,
        userHousehold: userHousehold,
      );

      if (mounted) Navigator.pop(context);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _AppleIntelligenceModal(
            petMatch: petMatch,
            explanation: explanation,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate explanation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final petMatches = matchState.matches;
    final isLoading = matchState.isLoading;
    final errorMessage = matchState.errorMessage;

    // If currently loading but have no matches yet, show loading
    final shouldShowLoading = isLoading && petMatches.isEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pet Matches',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showListView ? Icons.view_carousel : Icons.view_list,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () {
                      setState(() {
                        _showListView = !_showListView;
                        _currentCardIndex = 0;
                      });
                    },
                    tooltip: _showListView
                        ? 'Switch to Swipe View'
                        : 'Switch to List View',
                  ),
                ],
              ),
            ),
            Expanded(
              child: shouldShowLoading
                  ? _buildLoadingState()
                  : errorMessage != null
                      ? _buildErrorState(errorMessage)
                      : petMatches.isEmpty
                          ? _buildEmptyState()
                          : _showListView
                              ? _buildListView(petMatches)
                              : _buildSwipeView(petMatches),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSwipeView(List<PetMatch> petMatches) {
    // Safety check: ensure we have matches and valid index
    if (petMatches.isEmpty || _currentCardIndex >= petMatches.length) {
      return _buildEmptyState();
    }

    // Reset index if it goes out of bounds
    if (_currentCardIndex < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentCardIndex = 0;
        });
      });
      return _buildLoadingState();
    }

    return BumbleStylePetCard(
      petMatch: petMatches[_currentCardIndex],
      onSkip: () {
        setState(() {
          _currentCardIndex++;
        });
      },
      onLike: () {
        setState(() {
          _currentCardIndex++;
        });
      },
      onLearnMore: () => _showMatchExplanation(petMatches[_currentCardIndex]),
    );
  }

  Widget _buildLoadingState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final animationSize = (screenWidth * 0.72).clamp(180.0, 300.0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: animationSize,
            height: animationSize,
            child: Lottie.asset(
              'assets/lottie/Dog walking.json',
              repeat: true,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Finding your perfect match...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.deepOrange[300]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              errorMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(matchProvider.notifier).fetchMatchedPets();
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchSizeMismatchedDogs() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get user's size preference
      final userProfileData = await supabase
          .from('user_profile')
          .select('user_lifestyle')
          .eq('user_id', userId)
          .maybeSingle();

      final userLifestyle = userProfileData?['user_lifestyle'] as Map<String, dynamic>?;
      final preferredSize = userLifestyle?['size_preference'] as String?;

      if (preferredSize == null) return;

      // Fetch dogs from different sizes and include their images
      final response = await supabase
          .from('pet')
          .select('*, pets_images(*)')
          .eq('species', 'Dog')
          .neq('size', preferredSize)
          .limit(3);

      final pets = (response as List)
          .map((json) => Pet.fromJson(json))
          .toList();
      if (mounted) {
        setState(() {
          _sizeMismatchedDogs = pets;
        });
      }
    } catch (e) {
      print('Error fetching size-mismatched dogs: $e');
    }
  }

  Widget _buildEmptyState() {
    // If we don't have fetched size-mismatched dogs yet, fetch them
    if (_sizeMismatchedDogs == null) {
      _fetchSizeMismatchedDogs();
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.pets,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                'You\'ve reviewed all perfect matches!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'But we found some great dogs that don\'t match your size preference',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (_sizeMismatchedDogs != null && _sizeMismatchedDogs!.isNotEmpty)
                ..._buildSizeMismatchedCards()
              else if (_sizeMismatchedDogs != null && _sizeMismatchedDogs!.isEmpty)
                Text(
                  'Check back later for more dogs!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSizeMismatchedCards() {
    return [
      Text(
        'Why These Dogs?',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 16),
      ..._sizeMismatchedDogs!.map((dog) => _buildSizeMismatchCard(dog)),
    ];
  }

  Widget _buildSizeMismatchCard(Pet dog) {
    return GestureDetector(
      onTap: () => _showPetDetailsFromList(0, []),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: dog.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: dog.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.pets,
                              size: 28, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.pets,
                            size: 28, color: Colors.grey[400]),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dog.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dog.size ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '65% match',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Personality matches great, but size is different',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<PetMatch> petMatches) {
    return ListView.builder(
      itemCount: petMatches.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showPetDetailsFromList(index, petMatches),
          child: _buildHorizontalCard(petMatches[index]),
        );
      },
    );
  }

  Widget _buildHorizontalCard(PetMatch petMatch) {
    final pet = petMatch.pet;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth <= 360
        ? 152.0
        : screenWidth <= 420
            ? 164.0
            : 170.0;
    final imageWidth = (cardHeight * 0.82).clamp(118.0, 140.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: SizedBox(
              width: imageWidth,
              height: cardHeight,
              child: pet.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: pet.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.pets, size: 40, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.pets, size: 40, color: Colors.grey[400]),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: petMatch.matchColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: petMatch.matchColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(petMatch.matchIcon, color: petMatch.matchColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${petMatch.totalMatchPercent.toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: petMatch.matchColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showMatchExplanation(petMatch),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Colors.deepOrange,
                      ),
                      icon: const Icon(Icons.lightbulb_outline, size: 16),
                      label: Text(
                        'Why this match?',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cake_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${pet.age ?? '?'} ${pet.ageUnit ?? 'years'}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (pet.breed != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.pets, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            pet.breed!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (pet.description != null)
                    Flexible(
                      child: Text(
                        pet.description!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (pet.goodWithChildren == true)
                        _buildSmallTraitBadge('👶', Colors.blue),
                      if (pet.goodWithDogs == true)
                        _buildSmallTraitBadge('🐕', Colors.orange),
                      if (pet.goodWithCats == true)
                        _buildSmallTraitBadge('🐱', Colors.purple),
                      if (pet.energyLevel != null && pet.energyLevel! >= 7)
                        _buildSmallTraitBadge('⚡', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTraitBadge(String emoji, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _AppleIntelligenceModal extends StatefulWidget {
  final PetMatch petMatch;
  final String explanation;

  const _AppleIntelligenceModal({
    required this.petMatch,
    required this.explanation,
  });

  @override
  State<_AppleIntelligenceModal> createState() => _AppleIntelligenceModalState();
}

class _AppleIntelligenceModalState extends State<_AppleIntelligenceModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 500;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 16 : 24,
                      isSmallScreen ? 16 : 24,
                      isSmallScreen ? 16 : 24,
                      (isSmallScreen ? 16 : 24) + bottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lightbulb,
                                color: Colors.deepOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Why ${widget.petMatch.pet.name}?',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 16 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.petMatch.totalMatchPercent.toInt()}% Match',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: widget.petMatch.matchColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        Text(
                          widget.explanation,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 13 : 15,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
