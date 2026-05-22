import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/user_profile/provider/user_profile_provider.dart';
import 'package:petmatch/widgets/back_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    await ref.read(userProfileProvider.notifier).loadUserProfile();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BackButtonCircle(
            iconSize: 20,
            borderColor: Colors.grey.shade300,
            iconColor: Colors.black87,
            onTap: () => context.pop(),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6BCF7F),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserProfile,
              color: const Color(0xFF6BCF7F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Your Preferences',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap any section to edit',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pet Preferences Section
                    _buildSectionHeader('Pet Preferences', Icons.pets),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.favorite_rounded,
                      title: 'Pet Type',
                      value: profile.petPreference ?? 'Not set',
                      color: const Color.fromARGB(255, 117, 154, 253),
                      onTap: () => context.push('/onboarding/pet-preference'),
                    ),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.straighten_rounded,
                      title: 'Size Preference',
                      value: profile.sizePreference ?? 'Not set',
                      color: const Color.fromARGB(255, 63, 211, 154),
                      onTap: () => context.push('/onboarding/size-preference'),
                    ),

                    const SizedBox(height: 24),

                    // Lifestyle Section
                    _buildSectionHeader('Your Lifestyle', Icons.directions_run),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.home_work_rounded,
                      title: 'Living Environment',
                      value: profile.livingEnvironment ?? 'Not set',
                      color: const Color.fromARGB(255, 247, 127, 211),
                      onTap: () => context.push('/onboarding/activity-level'),
                    ),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.schedule_rounded,
                      title: 'Daily Availability',
                      value: profile.dailyAvailability ?? 'Not set',
                      color: const Color.fromARGB(255, 68, 127, 236),
                      onTap: () => context.push('/onboarding/hairiness-level'),
                    ),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.pets_rounded,
                      title: 'Pet Ownership Experience',
                      value: profile.petOwnershipExperience ?? 'Not set',
                      color: const Color.fromARGB(255, 68, 127, 236),
                      onTap: () => context.push('/onboarding/grooming-level'),
                    ),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Lifestyle Pace',
                      value: profile.lifestylePace ?? 'Not set',
                      color: const Color.fromARGB(255, 63, 211, 154),
                      onTap: () => context.push('/onboarding/affection-level'),
                    ),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.payments_rounded,
                      title: 'Budget for Pet Care',
                      value: profile.budgetForPetCare ?? 'Not set',
                      color: const Color.fromARGB(255, 255, 206, 43),
                      onTap: () => context.push('/onboarding/patience-level'),
                    ),

                    const SizedBox(height: 24),

                    // Household Section
                    _buildSectionHeader('Household Info', Icons.home),
                    const SizedBox(height: 12),
                    _buildEditCard(
                      icon: Icons.family_restroom_rounded,
                      title: 'Household Setup',
                      value: _getHouseholdSummary(profile),
                      color: const Color.fromARGB(255, 255, 206, 43),
                      onTap: () => context.push('/onboarding/household'),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
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
          color: Colors.white,
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
    if (profile.financialReady == true) items.add('Financially ready');
    if (profile.hadPetBefore == true) items.add('Pet experience');

    if (items.isEmpty) return 'Not set';
    if (items.length == 1) return items.first;
    return '${items.length} settings configured';
  }
}
