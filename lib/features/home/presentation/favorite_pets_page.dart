import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/features/home/provider/favorites_provider.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_provider.dart';
import 'package:petmatch/features/home/widgets/pet_details_modal.dart';
import 'package:petmatch/features/home/widgets/custom_bottom_navbar.dart';
import 'package:petmatch/widgets/info_banner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

class FavoritePetsPage extends ConsumerStatefulWidget {
  const FavoritePetsPage({super.key});

  @override
  ConsumerState<FavoritePetsPage> createState() => _FavoritePetsPageState();
}

class _FavoritePetsPageState extends ConsumerState<FavoritePetsPage> {
  final List<Color> _cardColors = [
    const Color(0xFFFFF4E0),
    const Color(0xFFE8E8E8),
    const Color(0xFFFFE4F0),
    const Color(0xFFE3F2FD),
    const Color(0xFFF3E5F5),
  ];

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesProvider);
    final petsState = ref.watch(petsProvider);

    // Build favorite pets list from favorites state (preferred) and fall back to petsProvider
    final Map<String, Pet> favoriteMap = {};
    for (final p in favoritesState.favoritePets) {
      favoriteMap[p.id] = p;
    }
    for (final p in (petsState.filteredPets ?? [])) {
      if (favoritesState.favoriteIds.contains(p.id)) {
        favoriteMap[p.id] = p;
      }
    }
    final favoritePets = favoriteMap.values.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: favoritesState.isLoading
          ? Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Lottie.asset(
                  'assets/lottie/Smiling Dog.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            )
          : favoritePets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Lottie.asset(
                          'assets/lottie/Smiling Dog.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('No favorite pets yet!',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const InfoBanner(
                            message: 'Your favorite pets are here!'),
                        const SizedBox(height: 10),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: favoritePets.length,
                            itemBuilder: (context, index) {
                              final pet = favoritePets[index];
                              final cardColor =
                                  _cardColors[index % _cardColors.length];
                              return _buildPetCard(
                                  pet, cardColor, index, favoritePets);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
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
