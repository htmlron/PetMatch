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

class PatienceLevelSetupScreen extends ConsumerStatefulWidget {
  const PatienceLevelSetupScreen({super.key});

  @override
  ConsumerState<PatienceLevelSetupScreen> createState() =>
      _PatienceLevelSetupScreenState();
}

class _PatienceLevelSetupScreenState
    extends ConsumerState<PatienceLevelSetupScreen>
    with SingleTickerProviderStateMixin {
  double _patienceLevel = 3.0; // 1-5 scale

  final List<Map<String, dynamic>> _patienceLevels = [
    {
      'value': 1,
      'label': 'Very Low',
      'emoji': '�',
      'image': UserProfileAssets.patienceVeryLow,
      'color': const Color.fromARGB(255, 255, 145, 222),
      'darkColor': const Color.fromARGB(255, 180, 80, 150),
      'description':
          'I get impatient quickly and prefer short, simple interactions.'
    },
    {
      'value': 2,
      'label': 'Somewhat Low',
      'emoji': '�',
      'image': UserProfileAssets.patienceSomewhatLow,
      'color': const Color.fromARGB(255, 117, 154, 253),
      'darkColor': const Color.fromARGB(255, 44, 70, 140),
      'description':
          'I can manage brief training sessions but prefer quick wins.'
    },
    {
      'value': 3,
      'label': 'Moderate',
      'emoji': '�',
      'image': UserProfileAssets.patienceModerate,
      'color': const Color.fromARGB(255, 63, 211, 154),
      'darkColor': const Color.fromARGB(255, 20, 120, 80),
      'description':
          'I have steady patience for regular training and reinforcement.'
    },
    {
      'value': 4,
      'label': 'Pretty High',
      'emoji': '😊',
      'image': UserProfileAssets.patiencePrettyHigh,
      'color': const Color.fromARGB(255, 166, 72, 243),
      'darkColor': const Color.fromARGB(255, 90, 30, 160),
      'description':
          'I am comfortable with longer training sessions and gradual progress.'
    },
    {
      'value': 5,
      'label': 'Very High',
      'emoji': '🧘',
      'image': UserProfileAssets.patienceVeryHigh,
      'color': const Color.fromARGB(255, 231, 122, 49),
      'darkColor': const Color.fromARGB(255, 150, 60, 20),
      'description':
          'I have excellent patience and can handle long, consistent training routines.'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load saved patience level if it exists
    final savedLevel = ref.read(userProfileProvider).patienceLevel;
    if (savedLevel != null && savedLevel >= 1 && savedLevel <= 5) {
      _patienceLevel = savedLevel.toDouble();
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
    final roundedLevel = _patienceLevel.round();
    return _patienceLevels.firstWhere(
      (level) => level['value'] == roundedLevel,
      orElse: () => _patienceLevels[2],
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
                      //   '[ STEP 3 OF 8 ]',
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
                        'How patient \nare you?',
                        style: GoogleFonts.newsreader(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 44,
                            small: 48,
                            medium: 54,
                            large: 58,
                          ),
                          fontWeight: FontWeight.bold,
                          color: _currentLevel['darkColor'],
                          letterSpacing: -0.9,
                          height: 0.8,
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
              small: 140,
              medium: 150,
              large: 160,
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
                    '${_patienceLevel.round()}',
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
                  onPressed: _saveActivityLevel,
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
              value: _patienceLevel,
              min: 1,
              max: 5,
              divisions: 4,
              label: _patienceLevel.round().toString(),
              onChanged: (value) {
                setState(() {
                  _patienceLevel = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _saveActivityLevel() {
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    if (onboardingComplete) {
      ref
          .read(userProfileProvider.notifier)
          .updatePatienceLevel(
              _patienceLevel.round(), _patienceLevel.round().toString());
      Navigator.of(context).pop();
      ref.read(userProfileProvider.notifier).updateUserProfile(
            level: _patienceLevel.round(),
            label: _patienceLevel.round().toString(),
            column: 'personality_traits',
            key: 'training_patience',
          );
      Navigator.of(context).pop();
    } else {
      ref.read(userProfileProvider.notifier).setPatienceLevel(
            context,
            _patienceLevel.round(),
            _patienceLevel.round().toString(),
          );
    }
  }
}
