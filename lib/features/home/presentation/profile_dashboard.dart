// ignore_for_file: prefer_const_constructors, unused_import, unused_element, avoid_unnecessary_containers, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/features/home/widgets/custom_bottom_navbar.dart';
import 'package:petmatch/features/user_profile/provider/user_profile_provider.dart';
import 'package:petmatch/widgets/divider_widget.dart';

class ProfileDashboard extends ConsumerStatefulWidget {
  const ProfileDashboard({super.key});

  @override
  ConsumerState<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends ConsumerState<ProfileDashboard> {
  bool _isLoading = true;

  final catPfps = [
    'assets/cat_pfp/cat1.png',
    'assets/cat_pfp/cat2.png',
    'assets/cat_pfp/cat3.png',
    'assets/cat_pfp/cat4.png',
    'assets/cat_pfp/cat5.png',
    'assets/cat_pfp/cat6.png',
    'assets/cat_pfp/cat7.png',
    'assets/cat_pfp/cat8.png',
    'assets/cat_pfp/cat9.png',
  ];

  final dogPfps = [
    'assets/dog_pfp/dog1.png',
    'assets/dog_pfp/dog2.png',
    'assets/dog_pfp/dog3.png',
    'assets/dog_pfp/dog4.png',
    'assets/dog_pfp/dog5.png',
    'assets/dog_pfp/dog6.png',
    'assets/dog_pfp/dog7.png',
    'assets/dog_pfp/dog8.png',
    'assets/dog_pfp/dog9.png',
  ];

  final fallbackPfp = 'assets/geometric.png';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(userProfileProvider.notifier).loadUserProfile();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final authState = ref.watch(authProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    // Show loading indicator while profile is loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'My Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 15 : 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: isSmallScreen ? 45 : 50,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.userName ?? 'Charlotte King',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.userEmail ?? '@johnkingraphics',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6BCF7F),
                      Color(0xFF4DB8E8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap on a label below to edit your specific profile preferences.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _buildEditCard(
                      icon: Icons.favorite_rounded,
                      title: 'Pet Type',
                      value: profile.petPreference ?? 'Not set',
                      color: const Color.fromARGB(255, 117, 154, 253),
                      onTap: () => context.push('/onboarding/pet-preference'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.straighten_rounded,
                      title: 'Size Preference',
                      value: profile.sizePreference ?? 'Not set',
                      color: const Color.fromARGB(255, 63, 211, 154),
                      onTap: () => context.push('/onboarding/size-preference'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.fitness_center_rounded,
                      title: 'Activity Level',
                      value: profile.activityLabel ?? '0',
                      subtitle: '${profile.activityLevel ?? 0}/5',
                      color: const Color.fromARGB(255, 247, 127, 211),
                      onTap: () => context.push('/onboarding/activity-level'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.brush_rounded,
                      title: 'Hairiness Preference',
                      value: profile.hairinessLabel ?? '0',
                      subtitle: '${profile.hairinessLevel ?? 0}/5',
                      color: const Color.fromARGB(255, 68, 127, 236),
                      onTap: () => context.push('/onboarding/hairiness-level'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.spa_rounded,
                      title: 'Grooming Tolerance',
                      value: profile.groomingLabel ?? '0',
                      subtitle: '${profile.groomingLevel ?? 0}/5',
                      color: const Color.fromARGB(255, 68, 127, 236),
                      onTap: () => context.push('/onboarding/grooming-level'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.favorite_border_rounded,
                      title: 'Affection Preference',
                      value: profile.affectionLabel ?? '0',
                      subtitle: '${profile.affectionLevel ?? 0}/5',
                      color: const Color.fromARGB(255, 133, 54, 179),
                      onTap: () => context.push('/onboarding/affection-level'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.timelapse_rounded,
                      title: 'Training Patience',
                      value: profile.patienceLabel ?? '0',
                      subtitle: '${profile.patienceLevel ?? 0}/5',
                      color: const Color.fromARGB(255, 63, 211, 154),
                      onTap: () => context.push('/onboarding/patience-level'),
                    ),
                    const SizedBox(height: 10),
                    _buildEditCard(
                      icon: Icons.family_restroom_rounded,
                      title: 'Household Setup',
                      value: _getHouseholdSummary(profile),
                      color: const Color.fromARGB(255, 255, 206, 43),
                      onTap: () => context.push('/onboarding/household'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5757),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ref.read(authProvider.notifier).signOut(context);
                  },
                  child: const Text(
                    'Log out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? emoji,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            if (emoji != null)
              Text(
                emoji,
                style: TextStyle(fontSize: 24),
              )
            else if (icon != null)
              Icon(
                icon,
                size: 24,
                color: textColor ?? Colors.black87,
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 238, 238),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _getHouseholdSummary(profile) {
    final List<String> items = [];

    if (profile.hasChildren == true) items.add('Has children');
    if (profile.hasOtherPets == true) items.add('Has pets');
    if (profile.comfortableWithShyPet == true) items.add('OK with shy pets');
    if (profile.okayWithSpecialNeeds == true) {
      items.add('OK with special needs');
    }

    if (items.isEmpty) return 'Not set';
    if (items.length == 1) return items.first;
    return '${items.length} settings configured';
  }
}
