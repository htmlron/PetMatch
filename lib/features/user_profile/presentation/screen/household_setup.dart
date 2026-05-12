// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/core/utils/notifier_helpers.dart';
import 'package:petmatch/core/utils/responsive_helper.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/features/user_profile/provider/user_profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:petmatch/widgets/back_button.dart';
import 'package:petmatch/widgets/custom_button.dart';

class HouseholdSetupScreen extends ConsumerStatefulWidget {
  const HouseholdSetupScreen({super.key});

  @override
  ConsumerState<HouseholdSetupScreen> createState() =>
      _HouseholdSetupScreenState();
}

class _HouseholdSetupScreenState extends ConsumerState<HouseholdSetupScreen> {
  // Controllers
  // State for other pet types
  bool? _hasOtherPets;
  bool _hasOtherDog = false;
  bool _hasOtherCat = false;

  bool? _hasChildren;
  bool? _comfortableWithShyPet;
  bool? _financiallyReady;
  bool? _hadPetsBefore;
  bool? _okayWithSpecialNeeds;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _hasOtherPets = profile.hasOtherPets;
    // No controller for other pets, use toggles
    _hasChildren = profile.hasChildren;
    _comfortableWithShyPet = profile.comfortableWithShyPet;
    _financiallyReady = profile.financialReady;
    _hadPetsBefore = profile.hadPetBefore;
    _okayWithSpecialNeeds = profile.okayWithSpecialNeeds;
  }

  @override
  void dispose() {
    // No controller to dispose for pet type toggles
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: isSmallScreen ? 20 : 24,
              right: isSmallScreen ? 20 : 24,
              top: isSmallScreen
                  ? 60
                  : 70, // Extra padding for back button + safe area
              bottom: isSmallScreen ? 16 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButtonCircle(
                  iconSize: getResponsiveValue(
                    context,
                    verySmall: 14,
                    small: 16,
                    medium: 18,
                    large: 20,
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: isSmallScreen ? 10 : 20),
                // Text(
                //   '[ STEP 1 OF 8 ]',
                //   style: TextStyle(
                //     fontSize: getResponsiveValue(
                //       context,
                //       verySmall: 10,
                //       small: 12,
                //       medium: 14,
                //       large: 16,
                //     ),
                //     color: Colors.grey[600],
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                const SizedBox(height: 20),
                Text(
                  'Tell us about your household.',
                  style: GoogleFonts.newsreader(
                    fontSize: getResponsiveValue(
                      context,
                      verySmall: 40,
                      small: 44,
                      medium: 48,
                      large: 50,
                    ),
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.9,
                    height: 0.9,
                  ),
                  textAlign: TextAlign.left,
                ),

                const SizedBox(height: 20),

                // Other Pets
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFDDD6FE), // light purple
                        Color(0xFFC084FC), // medium purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Color(0xFFA855F7), // purple border
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(
                          "Do you have other pets?", "🐾", isSmallScreen),
                      const SizedBox(height: 16),
                      _buildYesNoToggle(
                        _hasOtherPets,
                        (value) {
                          setState(() {
                            _hasOtherPets = value;
                            if (value == false) {
                              _hasOtherDog = false;
                              _hasOtherCat = false;
                            }
                          });
                        },
                        isSmallScreen,
                        yesGradient: const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                        ),
                        yesBorderColor: const Color(0xFF9333EA),
                        yesColor: const Color(0xFFA855F7),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Children
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFBAE6FD), // light blue
                        Color(0xFF7DD3FC), // medium blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Color(0xFF0EA5E9), // blue border
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(
                          "Do you have children?", "👶", isSmallScreen),
                      const SizedBox(height: 16),
                      _buildYesNoToggle(
                        _hasChildren,
                        (value) {
                          setState(() {
                            _hasChildren = value;
                          });
                        },
                        isSmallScreen,
                        yesGradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                        ),
                        yesBorderColor: const Color(0xFF0284C7),
                        yesColor: const Color(0xFF0EA5E9),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFBBF7D0), // light green
                        Color(0xFF4ADE80), // medium green
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF22C55E), // green border
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(
                          "Comfortable with a shy pet?", "🥺", isSmallScreen),
                      Text(
                        "Some pets need extra patience and gentle care",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildYesNoToggle(
                        _comfortableWithShyPet,
                        (value) {
                          setState(() {
                            _comfortableWithShyPet = value;
                          });
                        },
                        isSmallScreen,
                        yesGradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        ),
                        yesBorderColor: const Color(0xFF16A34A),
                        yesColor: const Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 187, 247, 226),
                        Color.fromARGB(255, 96, 223, 180),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color.fromARGB(255, 34, 197, 140),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(
                          "Are you okay with pets with special needs?",
                          "💙",
                          isSmallScreen),
                      Text(
                        "Some pets may need extra medical care or attention.",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildYesNoToggle(
                        _okayWithSpecialNeeds,
                        (value) {
                          setState(() {
                            _okayWithSpecialNeeds = value;
                          });
                        },
                        isSmallScreen,
                        yesGradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 34, 197, 140),
                            Color.fromARGB(255, 22, 163, 107)
                          ],
                        ),
                        yesBorderColor: const Color.fromARGB(255, 22, 163, 107),
                        yesColor: const Color.fromARGB(255, 34, 197, 159),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Continue Button
                CustomButton(
                  label: 'Continue',
                  onPressed: () {
                    _submitHousehold();
                  },
                  gradient: LinearGradient(
                    colors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  horizontalPadding: 0,
                )
              ], // End Column children
            ), // End Column
          ), // End SingleC
        ], // End Stack children
      ), // End Stack (body)
    ); // End Scaffold
  }

  Widget _buildSectionLabel(String text, String emoji, bool isSmall) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoToggle(
    bool? currentValue,
    Function(bool) onChanged,
    bool isSmall, {
    LinearGradient? yesGradient,
    Color? yesBorderColor,
    Color? yesColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            'Yes! 👍',
            true,
            currentValue == true,
            () => onChanged(true),
            isSmall,
            customGradient: yesGradient,
            customBorderColor: yesBorderColor,
            customColor: yesColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            'No',
            false,
            currentValue == false,
            () => onChanged(false),
            isSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String label,
    bool value,
    bool isSelected,
    VoidCallback onTap,
    bool isSmall, {
    LinearGradient? customGradient,
    Color? customBorderColor,
    Color? customColor,
  }) {
    // Default colors
    final gradient = customGradient ??
        const LinearGradient(
          colors: [
            Color(0xFF0EA5E9),
            Color(0xFF0284C7),
          ],
        );
    final borderColor = customBorderColor ?? const Color(0xFF0284C7);
    final mainColor = customColor ?? const Color(0xFF0EA5E9);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 5 : 10,
        ),
        decoration: BoxDecoration(
          gradient: isSelected && value ? gradient : null,
          color: isSelected && !value
              ? Colors.grey[300]
              : isSelected
                  ? null
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (value ? borderColor : Colors.grey[400]!)
                : mainColor.withOpacity(0.3),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected && value
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : isSelected && !value
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: isSelected && value
                  ? Colors.white
                  : isSelected
                      ? Colors.grey[700]
                      : mainColor,
            ),
          ),
        ),
      ),
    );
  }

  void _submitHousehold() async {
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    if (_hasOtherPets == null ||
        _hasChildren == null ||
        _comfortableWithShyPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before continuing'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save to provider
    // Compose a string for selected pets
    String? selectedPets;
    if (_hasOtherDog && _hasOtherCat) {
      selectedPets = 'Dog, Cat';
    } else if (_hasOtherDog) {
      selectedPets = 'Dog';
    } else if (_hasOtherCat) {
      selectedPets = 'Cat';
    } else {
      selectedPets = null;
    }
    ref.read(userProfileProvider.notifier).setHouseholdInfo(
          _hasChildren!,
          _hasOtherPets!,
          selectedPets,
          _comfortableWithShyPet!,
          _financiallyReady ?? false,
          _hadPetsBefore ?? false,
          _okayWithSpecialNeeds ?? false,
        );

    if (!onboardingComplete) {
      context.push('/onboarding/profile-loading');

      final success =
          await ref.read(userProfileProvider.notifier).submitProfile();

      if (context.canPop()) context.pop();

      if (success) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      NotifierHelper.showLoadingToast(context, 'Updating Profile');

      final success =
          await ref.read(userProfileProvider.notifier).submitProfile();

      if (success) {
        NotifierHelper.showSuccessToast(context, 'Profile Updated');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
