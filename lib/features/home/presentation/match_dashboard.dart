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
import 'package:petmatch/features/home/widgets/ai_loader.dart';
import 'package:petmatch/features/home/widgets/custom_bottom_navbar.dart';
import 'package:petmatch/features/home/widgets/pet_details_modal.dart';
import 'package:petmatch/features/home/widgets/swipe_card.dart';

class MatchDashboard extends ConsumerStatefulWidget {
  const MatchDashboard({super.key});

  @override
  ConsumerState<MatchDashboard> createState() => _MatchDashboardState();
}

class _MatchDashboardState extends ConsumerState<MatchDashboard> {
  int _currentCardIndex = 0;
  bool _showListView = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(matchProvider.notifier).fetchMatchedPets());
  }

  void _handleSwipeLeft() {
    setState(() {
      _currentCardIndex++;
    });
  }

  void _handleSwipeRight() {
    setState(() {
      _currentCardIndex++;
    });
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

    return Stack(
      children: [
        if (_currentCardIndex + 1 < petMatches.length)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.3,
              child: Transform.translate(
                offset: const Offset(0, 16),
                child: SwipeCard(
                  petMatch: petMatches[_currentCardIndex + 1],
                  onSwipeLeft: () {},
                  onSwipeRight: () {},
                  onTap: () {},
                ),
              ),
            ),
          ),
        SwipeCard(
          petMatch: petMatches[_currentCardIndex],
          onSwipeLeft: _handleSwipeLeft,
          onSwipeRight: _handleSwipeRight,
          onTap: () => _showPetDetailsFromList(_currentCardIndex, petMatches),
          onInfoTap: () => _showMatchExplanation(petMatches[_currentCardIndex]),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.width > 500 ? 20 : 12,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 500 ? 40 : 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'skip_btn',
                      onPressed: _handleSwipeLeft,
                      backgroundColor: Colors.red.withOpacity(0.9),
                      mini: MediaQuery.of(context).size.width <= 500,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width > 500 ? 28 : 20,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width > 500 ? 6 : 4),
                    Text(
                      'SKIP',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'like_btn',
                      onPressed: _handleSwipeRight,
                      backgroundColor: Colors.green.withOpacity(0.9),
                      mini: MediaQuery.of(context).size.width <= 500,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width > 500 ? 28 : 20,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width > 500 ? 6 : 4),
                    Text(
                      'LIKE',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_currentCardIndex == 0)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Swipe left to skip | Swipe right to like',
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width > 500 ? 13 : 11,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No more pets to show',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Check back later for more matches!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
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
