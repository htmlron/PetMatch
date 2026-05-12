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

class AffectionLevelSetupScreen extends ConsumerStatefulWidget {
  const AffectionLevelSetupScreen({super.key});

  @override
  ConsumerState<AffectionLevelSetupScreen> createState() =>
      _AffectionLevelSetupScreenState();
}

class _AffectionLevelSetupScreenState
    extends ConsumerState<AffectionLevelSetupScreen>
    with SingleTickerProviderStateMixin {
  double _affectionLevel = 3.0;

  final List<Map<String, dynamic>> _affectionLevels = [
    {
      'value': 1,
      'label': 'Very Independent',
      'emoji': '🧘‍♂️',
      'image': UserProfileAssets.affectionVeryIndependent,
      'color': const Color.fromARGB(255, 133, 54, 179),
      'description': 'I prefer having my own space and time'
    },
    {
      'value': 2,
      'label': 'Somewhat Independent',
      'emoji': '😌',
      'image': UserProfileAssets.affectionSomewhatIndependent,
      'color': const Color.fromARGB(255, 201, 65, 194),
      'description': 'I enjoy occasional affection but value independence'
    },
    {
      'value': 3,
      'label': 'Balanced',
      'emoji': '⚖️',
      'image': UserProfileAssets.affectionBalanced,
      'color': const Color.fromARGB(255, 50, 122, 182),
      'description': 'I like a good mix of affection and independence'
    },
    {
      'value': 4,
      'label': 'Pretty Affectionate',
      'emoji': '🤗',
      'image': UserProfileAssets.affectionPrettyAffectionate,
      'color': const Color.fromARGB(255, 48, 50, 184),
      'description': 'I enjoy regular affection and companionship'
    },
    {
      'value': 5,
      'label': 'Very Affectionate',
      'emoji': '💖',
      'image': UserProfileAssets.affectionVeryAffectionate,
      'color': const Color.fromARGB(255, 16, 64, 153),
      'description': 'I love constant affection and closeness'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load saved affection level if it exists
    final savedLevel = ref.read(userProfileProvider).affectionLevel;
    if (savedLevel != null && savedLevel >= 1 && savedLevel <= 5) {
      _affectionLevel = savedLevel.toDouble();
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
    final roundedLevel = _affectionLevel.round();
    return _affectionLevels.firstWhere(
      (level) => level['value'] == roundedLevel,
      orElse: () => _affectionLevels[2],
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _currentLevel['color'].withOpacity(0.7),
                    _currentLevel['color'],
                    _currentLevel['color'].withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: getResponsiveValue(
              context,
              verySmall: 40,
              small: 60,
              medium: 80,
              large: 100,
            ),
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${_affectionLevel.round()}',
                  style: GoogleFonts.newsreader(
                    fontSize: getResponsiveValue(
                      context,
                      verySmall: 13,
                      small: 15,
                      medium: 25,
                      large: 28,
                    ),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: screenWidth * 0.6,
                  child: Text(
                    _currentLevel['description'],
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 11,
                            small: 12,
                            medium: 14,
                            large: 16,
                          ),
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.85),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Full screen background image
          Positioned(
            left: 0,
            right: 0,
            bottom: getResponsiveValue(
              context,
              verySmall: 380,
              small: 280,
              medium: 330,
              large: 380,
            ),
            child: Image.asset(
              _currentLevel['image'],
              key: ValueKey(_currentLevel['value']),
              fit: BoxFit.contain,
              height: getResponsiveValue(
                context,
                verySmall: 280,
                small: 320,
                medium: 360,
                large: 400,
              ),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: getResponsiveValue(
                    context,
                    verySmall: 280,
                    small: 320,
                    medium: 360,
                    large: 400,
                  ),
                  color: _currentLevel['color'],
                );
              },
            ),
          ),

          // Content overlay
          Column(
            children: [
              const Spacer(),
              SizedBox(
                height: getResponsiveValue(
                  context,
                  verySmall: 12,
                  small: 15,
                  medium: 18,
                  large: 20,
                ),
              ),
              Container(
                width: screenWidth,
                height: getResponsiveValue(
                  context,
                  verySmall: 300,
                  small: 360,
                  medium: 400,
                  large: 450,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: getResponsiveValue(
                    context,
                    verySmall: 24,
                    small: 26,
                    medium: 29,
                    large: 32,
                  ),
                  vertical: getResponsiveValue(
                    context,
                    verySmall: 24,
                    small: 26,
                    medium: 29,
                    large: 32,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center horizontally
                    children: [
                      // Text(
                      //   '[ STEP 4 OF 8 ]',
                      //   style: TextStyle(
                      //     fontSize: getResponsiveValue(
                      //       context,
                      //       verySmall: 12,
                      //       small: 13,
                      //       medium: 15,
                      //       large: 16,
                      //     ),
                      //     color: Colors.grey[600],
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 6,
                          small: 8,
                          medium: 10,
                          large: 12,
                        ),
                      ),
                      Text(
                        'How snuggly you want your pet to be?',
                        style: GoogleFonts.newsreader(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 24,
                            small: 28,
                            medium: 36,
                            large: 42,
                          ),
                          fontWeight: FontWeight.bold,
                          color: _currentLevel['color'],
                          letterSpacing: -0.9,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 8,
                          small: 10,
                          medium: 12,
                          large: 14,
                        ),
                      ),
                      _buildCuteSlider(screenHeight),
                      SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 8,
                          small: 10,
                          medium: 12,
                          large: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _saveAffectionLevel,
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
                                _currentLevel['color'],
                                _currentLevel['color'].withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: _currentLevel['color'],
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _currentLevel['color'].withOpacity(0.25),
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
                  borderColor: Colors.white,
                  iconColor: Colors.white,
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
              value: _affectionLevel,
              min: 1,
              max: 5,
              divisions: 4,
              label: _affectionLevel.round().toString(),
              onChanged: (value) {
                setState(() {
                  _affectionLevel = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _saveAffectionLevel() {
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    if (onboardingComplete) {
      ref.read(userProfileProvider.notifier).updateUserProfile(
            level: _affectionLevel.round(),
            label: _affectionLevel.round().toString(),
            column: 'personality_traits',
            key: 'snuggly_preference',
          );
      Navigator.of(context).pop();
    } else {
      ref.read(userProfileProvider.notifier).setAffectionLevel(
          context, _affectionLevel.round(), _affectionLevel.round().toString());
    }
  }
}
