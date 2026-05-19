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

class GroomingLevelSetupScreen extends ConsumerStatefulWidget {
  const GroomingLevelSetupScreen({super.key});

  @override
  ConsumerState<GroomingLevelSetupScreen> createState() =>
      _GroomingLevelSetupScreenState();
}

class _GroomingLevelSetupScreenState
    extends ConsumerState<GroomingLevelSetupScreen>
    with SingleTickerProviderStateMixin {
  double _groomingLevel = 3.0; // 0-5 scale

  final List<Map<String, dynamic>> _groomingLevels = [
    {
      'value': 0,
      'label': 'No Grooming',
      'emoji': '✨',
      'image': UserProfileAssets.groomingLowMaintenance,
      'color': const Color.fromARGB(255, 180, 180, 180),
      'darkColor': const Color.fromARGB(255, 120, 120, 120),
      'description': 'Almost no grooming is needed.'
    },
    {
      'value': 1,
      'label': 'Low Maintenance',
      'emoji': '🛋️',
      'image': UserProfileAssets.groomingLowMaintenance,
      'color': const Color.fromARGB(255, 255, 164, 103),
      'darkColor': const Color.fromARGB(255, 226, 111, 66),
      'description': 'Minimal grooming needed. Low-maintenance lifestyle.'
    },
    {
      'value': 2,
      'label': 'Basic Care',
      'emoji': '😌',
      'image': UserProfileAssets.groomingBasicCare,
      'color': const Color.fromARGB(255, 245, 211, 98),
      'darkColor': const Color.fromARGB(255, 218, 158, 47),
      'description': 'Basic grooming required. Occasional brushing or care.'
    },
    {
      'value': 3,
      'label': 'Regular Grooming',
      'emoji': '🚶',
      'image': UserProfileAssets.groomingRegularGrooming,
      'color': const Color.fromARGB(255, 68, 127, 236),
      'darkColor': const Color.fromARGB(255, 21, 96, 196),
      'description': 'Regular grooming needed. Moderate effort for upkeep.'
    },
    {
      'value': 4,
      'label': 'Frequent Care',
      'emoji': '🏃',
      'image': UserProfileAssets.groomingFrequentCare,
      'color': const Color.fromARGB(255, 166, 72, 243),
      'darkColor': const Color.fromARGB(255, 90, 30, 160),
      'description': 'Frequent grooming required. High attention to care.'
    },
    {
      'value': 5,
      'label': 'High Maintenance',
      'emoji': '💪',
      'image': UserProfileAssets.groomingHighMaintenance,
      'color': const Color.fromARGB(255, 221, 69, 163),
      'darkColor': const Color.fromARGB(255, 180, 21, 140),
      'description': 'Intensive grooming needed. High-maintenance routine.'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load saved grooming level if it exists
    final savedLevel = ref.read(userProfileProvider).groomingLevel;
    if (savedLevel != null && savedLevel >= 0 && savedLevel <= 5) {
      _groomingLevel = savedLevel.toDouble();
    }
  }

  @override
  void dispose() {
    // Restore system UI when leaving screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Map<String, dynamic> get _currentLevel {
    // Round to nearest integer to match one of the 5 levels
    final roundedLevel = _groomingLevel.round();
    return _groomingLevels.firstWhere(
      (level) => level['value'] == roundedLevel,
      orElse: () => _groomingLevels[3],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background layer
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _currentLevel['darkColor'],
                    _currentLevel['color'].withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Content overlay
          Column(
            children: [
              // Top section with title and slider
              Container(
                width: screenWidth,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: getResponsiveValue(
                    context,
                    verySmall: 16,
                    small: 20,
                    medium: 28,
                    large: 32,
                  ),
                  vertical: getResponsiveValue(
                    context,
                    verySmall: 6,
                    small: 10,
                    medium: 12,
                    large: 15,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: getResponsiveValue(
                      context,
                      verySmall: 75,
                      small: 80,
                      medium: 82,
                      large: 85,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 8,
                          small: 10,
                          medium: 11,
                          large: 12,
                        ),
                      ),
                      Text(
                        'What is your grooming preference?',
                        style: GoogleFonts.newsreader(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 36,
                            small: 38,
                            medium: 42,
                            large: 46,
                          ),
                          fontWeight: FontWeight.bold,
                          color: _currentLevel['darkColor'],
                          letterSpacing: -0.9,
                          height: 0.9,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 6,
                          small: 12,
                          medium: 16,
                          large: 20,
                        ),
                      ),
                      _buildCuteSlider(screenHeight),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: getResponsiveValue(
              context,
              verySmall: 120,
              small: 150,
              medium: 160,
              large: 180,
            ),
            child: Center(
              child: SizedBox(
                height: getResponsiveValue(
                  context,
                  verySmall: 180,
                  small: 220,
                  medium: 290,
                  large: 330,
                ),
                width: double.infinity,
                child: Image.asset(
                  _currentLevel['image'],
                  key: ValueKey(_currentLevel['value']),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _currentLevel['color'],
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: getResponsiveValue(
              context,
              verySmall: 85,
              small: 95,
              medium: 105,
              large: 110,
            ),
            child: Column(
              children: [
                Text(
                  '${_groomingLevel.round()}',
                  style: GoogleFonts.newsreader(
                    fontSize: getResponsiveValue(
                      context,
                      verySmall: 24,
                      small: 26,
                      medium: 27,
                      large: 28,
                    ),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: screenWidth * 0.7,
                  child: Text(
                    _currentLevel['description'],
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 12,
                            small: 13,
                            medium: 15,
                            large: 16,
                          ),
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: getResponsiveValue(
              context,
              verySmall: 24,
              small: 26,
              medium: 28,
              large: 30,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getResponsiveValue(
                  context,
                  verySmall: 34,
                  small: 42,
                  medium: 48,
                  large: 54,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: getResponsiveValue(
                  context,
                  verySmall: 36,
                  small: 42,
                  medium: 48,
                  large: 55,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    backgroundColor: _currentLevel['color'].withOpacity(0.5),
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: _saveGroomingLevel,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _currentLevel['color'],
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.newsreader(
                        fontSize: getResponsiveValue(
                          context,
                          verySmall: 16,
                          small: 20,
                          medium: 23,
                          large: 26,
                        ),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
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
                  onTap: () =>
                      context.pop(), // optional, defaults to Navigator.pop
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuteSlider(double screenHeight) {
    // Helper function to get responsive values
    double getSliderValue({
      required double verySmall,
      required double small,
      required double medium,
      required double large,
    }) {
      if (screenHeight < 700) return verySmall;
      if (screenHeight < 800) return small;
      if (screenHeight < 900) return medium;
      return large;
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: getSliderValue(
              verySmall: 12,
              small: 20,
              medium: 25,
              large: 30,
            ),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: getSliderValue(
                verySmall: 20,
                small: 21,
                medium: 23,
                large: 24,
              ),
              elevation: 4,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: getSliderValue(
                verySmall: 32,
                small: 35,
                medium: 38,
                large: 40,
              ),
            ),
            activeTrackColor: _currentLevel['color'],
            inactiveTrackColor: Colors.grey[200],
            thumbColor: _currentLevel['color'],
            overlayColor: _currentLevel['color'].withOpacity(0.2),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: _currentLevel['color'],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Slider(
              value: _groomingLevel,
              min: 0,
              max: 5,
              divisions: 5,
              label: _groomingLevel.round().toString(),
              onChanged: (value) {
                setState(() {
                  _groomingLevel = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _saveGroomingLevel() {
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    if (onboardingComplete) {
      ref.read(userProfileProvider.notifier).updateUserProfile(
            level: _groomingLevel.round(),
            label: _groomingLevel.round().toString(),
            column: 'personality_traits',
            key: 'grooming_tolerance',
          );
      Navigator.of(context).pop();
    } else {
      ref.read(userProfileProvider.notifier).setGroomingLevel(
          context, _groomingLevel.round(), _groomingLevel.round().toString());
    }
  }
}
