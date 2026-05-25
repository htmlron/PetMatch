import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/core/utils/responsive_helper.dart';
import 'package:petmatch/core/constants/asset_paths.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/features/user_profile/provider/user_profile_provider.dart';
import 'package:petmatch/widgets/back_button.dart';

class SizePreferenceScreen extends ConsumerStatefulWidget {
  const SizePreferenceScreen({super.key});

  @override
  ConsumerState<SizePreferenceScreen> createState() =>
      _SizePreferenceScreenState();
}

class _SizePreferenceScreenState extends ConsumerState<SizePreferenceScreen> {
  double _selectedSizeValue = 2.0;

  // Cat size options
  final List<Map<String, dynamic>> _catSizeOptions = [
    {
      'value': 3,
      'label': 'Large',
      'emoji': '🦁',
      'image': UserProfileAssets.sizeLargeCat,
      'color': const Color.fromARGB(255, 117, 154, 253),
      'description': 'Large cats (15+ lbs). Majestic and gentle giants.'
    },
    {
      'value': 2,
      'label': 'Medium',
      'emoji': '😺',
      'image': UserProfileAssets.sizeMediumCat,
      'color': const Color.fromARGB(255, 166, 124, 253),
      'description':
          'Medium cats (10-15 lbs). The most common and versatile size.'
    },
    {
      'value': 1,
      'label': 'Small',
      'emoji': '🐱',
      'image': UserProfileAssets.sizeSmallCat,
      'color': const Color.fromARGB(255, 255, 145, 222),
      'description':
          'Small cats (5-10 lbs). Perfect for apartments and cozy spaces.'
    },
  ];

  // Dog size options
  final List<Map<String, dynamic>> _dogSizeOptions = [
    {
      'value': 3,
      'label': 'Large',
      'emoji': '🐕‍🦺',
      'image': UserProfileAssets.sizeLargeDog,
      'color': const Color.fromARGB(255, 255, 127, 80),
      'description':
          'Large dogs (50+ lbs) like Golden Retriever or German Shepherd. Loyal companions with big hearts.'
    },
    {
      'value': 2,
      'label': 'Medium',
      'emoji': '🐶',
      'image': UserProfileAssets.sizeMediumDog,
      'color': const Color.fromARGB(255, 63, 211, 154),
      'description':
          'Medium dogs (20-50 lbs). Great balance of energy and manageability.'
    },
    {
      'value': 1,
      'label': 'Small',
      'emoji': '🐕',
      'image': UserProfileAssets.sizeSmallDog,
      'color': const Color.fromARGB(255, 255, 206, 43),
      'description':
          'Small dogs (under 20 lbs). Easy to carry and apartment-friendly.'
    },
  ];

  // No preference options (shows both cat and dog)
  final List<Map<String, dynamic>> _noPreferenceOptions = [
    {
      'value': 3,
      'label': 'Large Pet',
      'emoji': '🐾',
      'image': UserProfileAssets.sizeNoCat,
      'color': const Color.fromARGB(255, 144, 238, 144),
      'description':
          'Large pets are wonderful companions with plenty of love to give.'
    },
    {
      'value': 2,
      'label': 'Medium Pet',
      'emoji': '🐾',
      'image': UserProfileAssets.sizeNoDog,
      'color': const Color.fromARGB(255, 176, 196, 222),
      'description':
          'Medium-sized pets offer a great balance between manageability and presence.'
    },
    {
      'value': 1,
      'label': 'Small Pet',
      'emoji': '🐾',
      'image': UserProfileAssets.sizeNoCat,
      'color': const Color.fromARGB(255, 255, 182, 193),
      'description':
          'Small pets are easier to handle and perfect for smaller living spaces.'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load saved size preference if it exists
    final savedSize = ref.read(userProfileProvider).sizePreference;
    if (savedSize != null) {
      // Map size string to value (1 = small, 2 = medium, 3 = large)
      if (savedSize.toLowerCase().contains('small')) {
        _selectedSizeValue = 1.0;
      } else if (savedSize.toLowerCase().contains('medium')) {
        _selectedSizeValue = 2.0;
      } else if (savedSize.toLowerCase().contains('large')) {
        _selectedSizeValue = 3.0;
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  // Get size options based on selected pet preference
  List<Map<String, dynamic>> get _currentSizeOptions {
    final petPreference = ref.watch(userProfileProvider).petPreference;

    if (petPreference == null) {
      return _noPreferenceOptions;
    }

    switch (petPreference.toLowerCase()) {
      case 'cat':
        return _catSizeOptions;
      case 'dog':
        return _dogSizeOptions;
      case 'no preference':
      default:
        return _noPreferenceOptions;
    }
  }

  Map<String, dynamic> get _currentSizeOption {
    final roundedLevel = _selectedSizeValue.round();
    return _currentSizeOptions.firstWhere(
      (level) => level['value'] == roundedLevel,
      orElse: () => _currentSizeOptions[1], // Default to medium
    );
  }

  int get _currentSizeIndex {
    final roundedLevel = _selectedSizeValue.round();
    final matchIndex = _currentSizeOptions
        .indexWhere((level) => level['value'] == roundedLevel);
    return matchIndex >= 0 ? matchIndex : 1;
  }

  // Get title based on pet preference
  String get _title {
    final petPreference = ref.watch(userProfileProvider).petPreference;

    if (petPreference == null) return 'What size pet\ndo you prefer?';

    switch (petPreference.toLowerCase()) {
      case 'cat':
        return 'What size of cat\ndo you prefer?';
      case 'dog':
        return 'What size of dog\ndo you prefer?';
      case 'no preference':
      default:
        return 'What size of pet\ndo you prefer?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button at top left
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: BackButtonCircle(
                  iconSize: getResponsiveValue(
                    context,
                    verySmall: 14,
                    small: 16,
                    medium: 18,
                    large: 20,
                  ),
                  borderColor: Colors.grey.shade300,
                  iconColor: Colors.black87,
                  onTap: () => context.pop(),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: getResponsiveValue(
                    context,
                    verySmall: 0,
                    small: 4,
                    medium: 6,
                    large: 8,
                  ),
                ),
                child: Column(
                  children: [
                    // Text(
                    //   '[ STEP 2 OF 8 ]',
                    //   style: TextStyle(
                    //     fontSize: getResponsiveValue(
                    //       context,
                    //       verySmall: 11,
                    //       small: 12,
                    //       medium: 13,
                    //       large: 14,
                    //     ),
                    //     color: Colors.grey[600],
                    //     fontWeight: FontWeight.w500,
                    //     letterSpacing: 1.2,
                    //   ),
                    // ),
                    SizedBox(
                      height: getResponsiveValue(
                        context,
                        verySmall: 8,
                        small: 9,
                        medium: 10,
                        large: 12,
                      ),
                    ),
                    Text(
                      _title,
                      style: GoogleFonts.newsreader(
                        fontSize: getResponsiveValue(
                          context,
                          verySmall: 32,
                          small: 40,
                          medium: 48,
                          large: 54,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -1.1,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: getResponsiveValue(
                        context,
                        verySmall: 14,
                        small: 16,
                        medium: 18,
                        large: 20,
                      ),
                    ),

                    // Swipeable cards stack
                    _buildSwipeableCards(screenHeight),

                    SizedBox(
                      height: getResponsiveValue(
                        context,
                        verySmall: 20,
                        small: 30,
                        medium: 40,
                        large: 50,
                      ),
                    ),

                    // Swipe indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,
                            size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Text(
                          'SWIPE TO CHANGE SIZE',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            size: 16, color: Colors.grey[400]),
                      ],
                    ),

                    SizedBox(
                      height: getResponsiveValue(
                        context,
                        verySmall: 12,
                        small: 15,
                        medium: 18,
                        large: 22,
                      ),
                    ),

                    GestureDetector(
                      onTap: _saveSizePreference,
                      child: Container(
                        width: getResponsiveValue(
                          context,
                          verySmall: 260,
                          small: 280,
                          medium: 300,
                          large: 320,
                        ),
                        height: getResponsiveValue(
                          context,
                          verySmall: 48,
                          small: 50,
                          medium: 53,
                          large: 56,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              _currentSizeOption['color'],
                              _currentSizeOption['color'].withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: _currentSizeOption['color'],
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _currentSizeOption['color'].withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
                            style: GoogleFonts.newsreader(
                              fontSize: getResponsiveValue(
                                context,
                                verySmall: 18,
                                small: 19,
                                medium: 21,
                                large: 22,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
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
      ),
    );
  }

  Widget _buildSwipeableCards(double screenHeight) {
    return SizedBox(
      height: getResponsiveValue(
        context,
        verySmall: screenHeight * 0.5,
        small: screenHeight * 0.52,
        medium: screenHeight * 0.54,
        large: screenHeight * 0.55,
      ),
      child: PageView.builder(
        controller: PageController(
          viewportFraction: 0.85,
          initialPage: _currentSizeIndex,
        ),
        onPageChanged: (index) {
          final selectedLevel = _currentSizeOptions[index]['value'] as num;
          setState(() {
            _selectedSizeValue = selectedLevel.toDouble();
          });
        },
        itemCount: _currentSizeOptions.length,
        itemBuilder: (context, index) {
          final level = _currentSizeOptions[index];
          final isActive = _selectedSizeValue.round() == level['value'];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: isActive ? 0 : 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: level['color'],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 180,
                          small: 230,
                          medium: 280,
                          large: 330,
                        ),
                        child: Image.asset(
                          level['image'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: level['color'].withOpacity(0.1),
                              child: Center(
                                child: Text(
                                  level['emoji'],
                                  style: TextStyle(
                                    fontSize: getResponsiveValue(
                                      context,
                                      verySmall: 48,
                                      small: 60,
                                      medium: 74,
                                      large: 90,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Label and description at the bottom
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 32, left: 24, right: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              level['label'],
                              style: GoogleFonts.newsreader(
                                fontSize: isActive
                                    ? getResponsiveValue(
                                        context,
                                        verySmall: 16,
                                        small: 18,
                                        medium: 20,
                                        large: 22,
                                      )
                                    : getResponsiveValue(
                                        context,
                                        verySmall: 12,
                                        small: 13,
                                        medium: 14,
                                        large: 16,
                                      ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 300,
                            child: Text(
                              level['description'],
                              style: TextStyle(
                                fontSize: isActive
                                    ? getResponsiveValue(
                                        context,
                                        verySmall: 13,
                                        small: 14,
                                        medium: 15,
                                        large: 16,
                                      )
                                    : getResponsiveValue(
                                        context,
                                        verySmall: 11,
                                        small: 12,
                                        medium: 13,
                                        large: 14,
                                      ),
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveSizePreference() {
    final selectedSize = _currentSizeOption['label'] as String;
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    if (onboardingComplete) {
      ref.read(userProfileProvider.notifier).updateSizePreference(selectedSize);
      Navigator.of(context).pop();
    } else {
      ref
          .read(userProfileProvider.notifier)
          .setSizePreference(context, selectedSize);
    }
  }
}
