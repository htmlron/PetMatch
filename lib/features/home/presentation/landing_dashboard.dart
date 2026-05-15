import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_provider.dart';
import 'package:petmatch/features/home/widgets/custom_bottom_navbar.dart';
import 'package:petmatch/features/home/widgets/pet_details_modal.dart';
import 'package:petmatch/features/home/provider/favorites_provider.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/widgets/info_banner.dart';

class LandingDashboard extends ConsumerStatefulWidget {
  const LandingDashboard({super.key});

  @override
  ConsumerState<LandingDashboard> createState() => _LandingDashboardState();
}

class _LandingDashboardState extends ConsumerState<LandingDashboard> {
  bool _showMostFavorited = true;
  int _selectedCategoryIndex = 0;
  bool _isGridView = true;
  final ScrollController _scrollController = ScrollController();

  // Colors for pet cards
  final List<Color> _cardColors = [
    const Color(0xFFFFF4E0),
    const Color(0xFFE8E8E8),
    const Color(0xFFFFE4F0),
    const Color(0xFFE3F2FD),
    const Color(0xFFF3E5F5),
  ];

  final List<String> carouselImages = [
    'assets/carousel/first carousel.png',
    // Add more image paths
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petsProvider.notifier).fetchInitialPets();
      ref.read(favoritesProvider.notifier).fetchFavorites();
      ref.read(favoritesProvider.notifier).fetchMostFavoritePets();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    const threshold = 300;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    final notifier = ref.read(petsProvider.notifier);
    final state = ref.read(petsProvider);

    if (maxScroll - currentScroll <= threshold) {
      if (!state.isFetchingMore && state.hasMore && !state.isLoading) {
        notifier.fetchMorePets();
      }
    }
  }

  void _showHomeTutorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.help_outline, color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'How to start matching',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTutorialStep(
                'Go to Match',
                'Tap the heart icon in the bottom navigation bar to open the Matching screen. That is where the pet cards appear.',
                Icons.favorite_border,
              ),
              const SizedBox(height: 12),
              _buildTutorialStep(
                'Choose a pet',
                'On the Matching screen, use the heart button to like a pet and the X button to skip. Tap the card for more details.',
                Icons.touch_app,
              ),
              const SizedBox(height: 12),
              _buildTutorialStep(
                'See why it matches',
                'Tap the question mark button on the Matching screen to read the AI explanation about why that pet fits you.',
                Icons.help_outline,
              ),
              const SizedBox(height: 12),
              _buildTutorialStep(
                'Swipe to browse',
                'Swipe right to view the previous pet, or swipe left to see the next one. Use the heart and X buttons to like or skip.',
                Icons.swipe,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTutorialStep(String title, String body, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.deepOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName =
        authState.userName ?? authState.userEmail?.split('@').first ?? 'User';

    final petsState = ref.watch(petsProvider);
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: petsState.isLoading
            ? Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: Lottie.asset(
                    'assets/lottie/Smiling Dog.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(petsProvider.notifier).refresh();
                },
                child: ListView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    _buildHeader(userName),
                    const SizedBox(height: 20),
                    if (petsState.errorMessage != null)
                      _buildErrorSection(petsState.errorMessage!)
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCarouselHeader(),
                          const SizedBox(height: 10),
                          if (favoritesState.favoritePets.isNotEmpty)
                            _buildMostFavoritedSection(
                                favoritesState.favoritePets),
                          const SizedBox(height: 10),
                          _buildCategoryCards(),
                          Row(
                            children: [
                              const Expanded(
                                child: InfoBanner(
                                    message:
                                        'Tap a pet card to view more details'),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    _isGridView
                                        ? Icons.view_list
                                        : Icons.grid_view,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _buildPetsDisplay(petsState.filteredPets ?? []),
                          if (petsState.isFetchingMore)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildCarouselHeader() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: carouselImages.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              carouselImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back 👋',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.deepOrange),
          onPressed: _showHomeTutorial,
          tooltip: 'How to use PetMatch',
        ),
      ],
    );
  }

  Widget _buildErrorSection(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error loading pets',
                style: TextStyle(color: Colors.red[300])),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(petsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    final categories = [
      {'title': 'All', 'icon': Icons.all_inclusive, 'index': 0},
      {'title': 'Dog', 'icon': Icons.pets, 'index': 2},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((category) {
          final isSelected = _selectedCategoryIndex == category['index'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = category['index'] as int;
              });
              final title = category['title'] as String;
              ref.read(petsProvider.notifier).filterByCategory(
                  title.toLowerCase() == 'all' ? 'all' : title);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[100] : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.transparent,
                  width: 2,
                ),
              ),
              width: 64,
              height: 64,
              alignment: Alignment.center,
              child: Text(
                category['title'] == 'Cat'
                    ? '🐱'
                    : category['title'] == 'Dog'
                        ? '🐶'
                        : '🌟',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPetsDisplay(List<Pet> pets) {
    if (pets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No pets found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final cardColor = _cardColors[index % _cardColors.length];
          return _buildPetCard(pet, cardColor, index, pets);
        },
      );
    } else {
      // List view
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final pet = pets[index];
          final cardColor = _cardColors[index % _cardColors.length];
          return _buildPetListTile(pet, cardColor, index, pets);
        },
      );
    }
  }

  Widget _buildPetListTile(
      Pet pet, Color cardColor, int index, List<Pet> allPets) {
    return Consumer(
      builder: (context, ref, _) {
        final favoritesState = ref.watch(favoritesProvider);
        final favoritesNotifier = ref.read(favoritesProvider.notifier);
        final isFavorite = favoritesState.favoriteIds.contains(pet.id);
        return ListTile(
          onTap: () => showPetDetailsModal(context, allPets, index),
          tileColor: cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 56,
              height: 56,
              child: CachedNetworkImage(
                imageUrl: pet.thumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.pets, size: 32, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            pet.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              if (pet.gender != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pet.gender?.toLowerCase() == 'male'
                          ? Icons.male
                          : Icons.female,
                      size: 14,
                      color: pet.gender?.toLowerCase() == 'male'
                          ? Colors.blue[700]
                          : Colors.pink[700],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      pet.gender!,
                      style: TextStyle(
                        fontSize: 11,
                        color: pet.gender?.toLowerCase() == 'male'
                            ? Colors.blue[700]
                            : Colors.pink[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: pet.ageCategory == 'Young'
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: pet.ageCategory == 'Young'
                        ? Colors.green[300]!
                        : Colors.orange[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  pet.ageCategory,
                  style: TextStyle(
                    fontSize: 10,
                    color: pet.ageCategory == 'Young'
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () async {
              if (isFavorite) {
                await favoritesNotifier.removeFavorite(context, pet.id);
              } else {
                await favoritesNotifier.addFavorite(context, pet.id);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMostFavoritedSection(List<Pet> pets) {
    if (pets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 203, 203),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 255, 108, 108)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showMostFavorited = !_showMostFavorited;
              });
            },
            child: Row(
              children: [
                const Text(
                  '❤️ Most Favorited Pets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _showMostFavorited
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 28,
                ),
              ],
            ),
          ),
          _showMostFavorited
              ? const SizedBox(height: 12)
              : const SizedBox.shrink(),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _showMostFavorited
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final cardColor = _cardColors[index % _cardColors.length];
                return _buildPetCard(pet, cardColor, index, pets);
              },
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet, Color cardColor, int index, List<Pet> allPets) {
    return Consumer(
      builder: (context, ref, _) {
        final favoritesState = ref.watch(favoritesProvider);
        final favoritesNotifier = ref.read(favoritesProvider.notifier);
        final isFavorite = favoritesState.favoriteIds.contains(pet.id);
        return GestureDetector(
          onTap: () => showPetDetailsModal(context, allPets, index),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: pet.thumbnailUrl ?? '',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.pets,
                                  size: 64, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            if (isFavorite) {
                              await favoritesNotifier.removeFavorite(
                                  context, pet.id);
                            } else {
                              await favoritesNotifier.addFavorite(
                                  context, pet.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (pet.gender != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  pet.gender?.toLowerCase() == 'male'
                                      ? Icons.male
                                      : Icons.female,
                                  size: 12,
                                  color: pet.gender?.toLowerCase() == 'male'
                                      ? Colors.blue[700]
                                      : Colors.pink[700],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  pet.gender!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: pet.gender?.toLowerCase() == 'male'
                                        ? Colors.blue[700]
                                        : Colors.pink[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: pet.ageCategory == 'Young'
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: pet.ageCategory == 'Young'
                                    ? Colors.green[300]!
                                    : Colors.orange[300]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              pet.ageCategory,
                              style: TextStyle(
                                fontSize: 9,
                                color: pet.ageCategory == 'Young'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
