// ignore_for_file: unnecessary_brace_in_string_interps

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

class ActivityLevelSetupScreen extends ConsumerStatefulWidget {
  const ActivityLevelSetupScreen({super.key});

  @override
  ConsumerState<ActivityLevelSetupScreen> createState() =>
      _ActivityLevelSetupScreenState();
}

class _ActivityLevelSetupScreenState
    extends ConsumerState<ActivityLevelSetupScreen>
    with SingleTickerProviderStateMixin {
  double _activityLevel = 3.0;

  final List<Map<String, dynamic>> _activityLevels = [
    {
      'value': 1,
      'label': 'Inactive',
      'emoji': '🛋️',
      'image': UserProfileAssets.activityInactive,
      'color': const Color.fromARGB(255, 247, 127, 211),
      'description': 'I prefer staying home and relaxing'
    },
    {
      'value': 2,
      'label': 'Lightly Active',
      'emoji': '😌',
      'image': UserProfileAssets.activityLightlyActive,
      'color': const Color.fromARGB(255, 104, 186, 253),
      'description': 'I enjoy occasional light activities'
    },
    {
      'value': 3,
      'label': 'Moderately Active',
      'emoji': '🚶',
      'image': UserProfileAssets.activityModeratelyActive,
      'color': const Color.fromARGB(255, 143, 103, 253), // Orange from image
      'description': 'I like regular walks and moderate exercise'
    },
    {
      'value': 4,
      'label': 'Very Active',
      'emoji': '🏃',
      'image': UserProfileAssets.activityVeryActive,
      'color': const Color.fromARGB(255, 255, 206, 43), // Red from image
      'description': 'I exercise regularly and enjoy outdoor activities'
    },
    {
      'value': 5,
      'label': 'Extremely Active',
      'emoji': '💪',
      'image': UserProfileAssets.activityExtremelyActive,
      'color': const Color.fromARGB(255, 39, 209, 53), // Bright red from image
      'description': 'I\'m always on the move with high-energy activities'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load saved activity level if it exists
    final savedLevel = ref.read(userProfileProvider).activityLevel;
    if (savedLevel != null && savedLevel >= 1 && savedLevel <= 5) {
      _activityLevel = savedLevel.toDouble();
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
    final roundedLevel = _activityLevel.round();
    return _activityLevels.firstWhere(
      (level) => level['value'] == roundedLevel,
      orElse: () => _activityLevels[2],
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

          // Full screen background image
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: () {
                    final value = _currentLevel['value'];
                    if (value == 1 || value == 2 || value == 3) {
                      // Inactive
                      return getResponsiveValue(
                        context,
                        verySmall: 100,
                        small: 60,
                        medium: 165,
                        large: 180,
                      );
                    } else {
                      // Very Active & Extremely Active
                      return getResponsiveValue(
                        context,
                        verySmall: 80,
                        small: 40,
                        medium: 100,
                        large: 110,
                      );
                    }
                  }(),
                ),
                child: Image.asset(
                  _currentLevel['image'],
                  key: ValueKey(_currentLevel['value']),
                  fit: BoxFit.contain,
                  width: getResponsiveValue(
                    context,
                    verySmall: 250,
                    small: 195,
                    medium: 225,
                    large: 270,
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _currentLevel['color'],
                    );
                  },
                ),
              ),
            ),
          ),

          // Content overlay
          Column(
            children: [
              const Spacer(),
              Column(
                children: [
                  Text(
                    '${_activityLevel.round()}',
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
                      //   '[ STEP 2 OF 8 ]',
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
                        'How active \nare you?',
                        style: GoogleFonts.newsreader(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 44,
                            small: 48,
                            medium: 54,
                            large: 58,
                          ),
                          fontWeight: FontWeight.bold,
                          color: _currentLevel['color'],
                          letterSpacing: -0.9,
                          height: 0.8,
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
                        onTap: _saveActivityLevel,
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
              value: _activityLevel,
              min: 1,
              max: 5,
              divisions: 4,
              label: _activityLevel.round().toString(),
              onChanged: (value) {
                setState(() {
                  _activityLevel = value;
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
      ref.read(userProfileProvider.notifier).updateUserProfile(
            level: _activityLevel.round(),
            label: _activityLevel.round().toString(),
            column: 'personality_traits',
            key: 'activity_level',
          );
      Navigator.of(context).pop();
    } else {
      ref.read(userProfileProvider.notifier).setActivityLevel(
          context, _activityLevel.round(), _activityLevel.round().toString());
    }
  }
}
