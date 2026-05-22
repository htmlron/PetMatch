// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:petmatch/core/model/pet_model.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_provider.dart';
import 'package:petmatch/features/pet_profile/screens/add_pet_screen.dart';

class PetManagementPage extends ConsumerStatefulWidget {
  const PetManagementPage({super.key});

  @override
  ConsumerState<PetManagementPage> createState() => _PetManagementPageState();
}

class _PetManagementPageState extends ConsumerState<PetManagementPage> {
  String _searchQuery = '';
  String _selectedSpecies = 'All';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Only fetch pets if we don't already have them loaded. This avoids
    // refetching every time this page is mounted (for example when
    // navigating back). The provider keeps the list in memory between
    // navigations.
    Future.microtask(() {
      final state = ref.read(petsProvider);
      if ((state.pets == null || state.pets!.isEmpty) && !state.isLoading) {
        ref.read(petsProvider.notifier).fetchInitialPets();
      }
    });
  }

  List<Pet> _getFilteredPets(List<Pet>? pets) {
    if (pets == null) return [];

    var filtered = pets;

    // Filter by species
    if (_selectedSpecies != 'All') {
      filtered = filtered
          .where((pet) =>
              pet.species.toLowerCase() == _selectedSpecies.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((pet) {
        final query = _searchQuery.toLowerCase();
        return pet.name.toLowerCase().contains(query) ||
            (pet.breed?.toLowerCase().contains(query) ?? false) ||
            (pet.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _navigateToEditPet(Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(petToEdit: pet),
      ),
    ).then((result) {
      // Only refresh if the edit screen reports that something changed.
      // The edit/add screens should return `true` when they successfully
      // created/updated a pet.
      if (result == true) {
        ref.read(petsProvider.notifier).fetchInitialPets();
      }
    });
  }

  void _navigateToAddPet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(),
      ),
    ).then((result) {
      // Only refresh if AddPetScreen returns true to indicate a new pet
      // was actually created.
      if (result == true) {
        ref.read(petsProvider.notifier).fetchInitialPets();
      }
    });
  }

  Future<void> _confirmDeletePet(Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ${pet.name}?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this pet? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(petsProvider.notifier).deletePet(pet.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete pet: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petsProvider);
    final pets = petState.pets;
    final filteredPets = _getFilteredPets(pets);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Pet Management',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.deepOrange,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip:
                _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.deepOrange),
            onPressed: _navigateToAddPet,
            tooltip: 'Add New Pet',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepOrange),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87),
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: GoogleFonts.poppins()),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                ref.read(authProvider.notifier).signOut(context);
              }
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, breed, or description...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Species filter
                Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Dog'),
                    _buildFilterChip('Cat'),
                  ],
                ),
              ],
            ),
          ),

          // Pet count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${filteredPets.length} ${filteredPets.length == 1 ? 'Pet' : 'Pets'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Pet list with pull-to-refresh. For loading and empty states we
          // ensure the child is scrollable so RefreshIndicator can trigger
          // (by using SingleChildScrollView with AlwaysScrollableScrollPhysics).
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(petsProvider.notifier).fetchInitialPets(),
              child: petState.isLoading
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        // Ensure there's enough height for pull-to-refresh
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: _buildLoadingState(),
                      ),
                    )
                  : filteredPets.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyState(),
                          ),
                        )
                      : _isGridView
                          ? _buildGridView(filteredPets)
                          : _buildListView(filteredPets),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedSpecies == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSpecies = label;
          });
        },
        selectedColor: Colors.deepOrange,
        backgroundColor: Colors.grey[200],
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/lottie/Catloading.json',
              repeat: true,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading pets...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
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
            Icons.pets_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No pets found',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try adjusting your filters or add a new pet',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _navigateToAddPet,
            icon: const Icon(Icons.add),
            label: Text(
              'Add Your First Pet',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Pet> pets) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return _buildPetGridCard(pets[index]);
      },
    );
  }

  Widget _buildListView(List<Pet> pets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return _buildPetListCard(pets[index]);
      },
    );
  }

  Widget _buildPetGridCard(Pet pet) {
    return GestureDetector(
      onTap: () => _navigateToEditPet(pet),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: pet.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: pet.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.pets,
                                  size: 40, color: Colors.grey[400]),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.pets,
                                size: 40, color: Colors.grey[400]),
                          ),
                  ),
                  // Action buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _buildActionButton(
                          Icons.edit,
                          Colors.blue,
                          () => _navigateToEditPet(pet),
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          Icons.delete,
                          Colors.red,
                          () => _confirmDeletePet(pet),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Pet Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.pets, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pet.breed ?? pet.species,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.cake_outlined,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${pet.age ?? '?'} ${pet.ageUnit ?? 'years'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
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
  }

  Widget _buildPetListCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 150,
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
          // Pet Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: pet.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: pet.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.pets,
                                size: 40, color: Colors.grey[400]),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.pets,
                              size: 40, color: Colors.grey[400]),
                        ),
                ),
              ),
            ],
          ),
          // Pet Info
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
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.pets, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          pet.breed ?? pet.species,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.cake_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${pet.age ?? '?'} ${pet.ageUnit ?? 'years'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (pet.gender != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          pet.gender == 'Male' ? Icons.male : Icons.female,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.gender!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _navigateToEditPet(pet),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(
                          'Edit',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _confirmDeletePet(pet),
                        icon: const Icon(Icons.delete, size: 16),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  // ignore: unused_element
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'adopted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
