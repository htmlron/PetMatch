import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/core/constants/asset_paths.dart';
import 'package:petmatch/core/utils/responsive_helper.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/features/user_profile/provider/user_profile_provider.dart';
import 'package:petmatch/widgets/back_button.dart';

class HairinessLevelSetupScreen extends ConsumerStatefulWidget {
  const HairinessLevelSetupScreen({super.key});

  @override
  ConsumerState<HairinessLevelSetupScreen> createState() =>
      _HairinessLevelSetupScreenState();
}

class _HairinessLevelSetupScreenState
    extends ConsumerState<HairinessLevelSetupScreen> {
  double _hairinessLevel = 3.0; // 0-5 scale

  final List<Map<String, dynamic>> _hairinessLevels = [
    {
      'value': 0,
      'label': 'Low Shedding',
      'emoji': '🧼',
      'image': UserProfileAssets.hairinessLevel0,
      'color': const Color.fromARGB(255, 255, 164, 103),
      'darkColor': const Color.fromARGB(255, 226, 111, 66),
      'description': 'Prefer minimal shedding and fur around the home.'
    },
    {
      'value': 1,
      'label': 'Low Shedding',
      'emoji': '🧼',
      'image': UserProfileAssets.hairinessLevel1,
      'color': const Color.fromARGB(255, 255, 164, 103),
      'darkColor': const Color.fromARGB(255, 226, 111, 66),
      'description': 'Prefer minimal shedding and fur around the home.'
    },
    {
      'value': 2,
      'label': 'Some Fur',
      'emoji': '🧹',
      'image': UserProfileAssets.hairinessLevel2,
      'color': const Color.fromARGB(255, 245, 211, 98),
      'darkColor': const Color.fromARGB(255, 218, 158, 47),
      'description': 'Moderate shedding is fine with regular cleanup.'
    },
    {
      'value': 3,
      'label': 'Hairy is Fine',
      'emoji': '🐶',
      'image': UserProfileAssets.hairinessLevel3,
      'color': const Color.fromARGB(255, 68, 127, 236),
      'darkColor': const Color.fromARGB(255, 21, 96, 196),
      'description': 'Comfortable with noticeable fur and shedding.'
    },
    {
      'value': 4,
      'label': 'Very Hairy',
      'emoji': '🧻',
      'image': UserProfileAssets.hairinessLevel4,
      'color': const Color.fromARGB(255, 166, 72, 243),
      'darkColor': const Color.fromARGB(255, 90, 30, 160),
      'description': 'Okay with lots of fur and frequent lint-rolling.'
    },
    {
      'value': 5,
      'label': 'Fur? No Problem',
      'emoji': '🧡',
      'image': UserProfileAssets.hairinessLevel5,
      'color': const Color.fromARGB(255, 221, 69, 163),
      'darkColor': const Color.fromARGB(255, 180, 21, 140),
      'description': 'Heavy shedding is totally fine.'
    },
  ];

  @override
  void initState() {
    super.initState();
    final savedLevel = ref.read(userProfileProvider).hairinessLevel;
    if (savedLevel != null && savedLevel >= 0 && savedLevel <= 5) {
      _hairinessLevel = savedLevel.toDouble();
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

  Map<String, dynamic> get _currentLevel {
    final roundedLevel = _hairinessLevel.round();
    return _hairinessLevels.firstWhere(
      (level) => level['value'] == roundedLevel,
      orElse: () => _hairinessLevels[3],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
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
          Column(
            children: [
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
                      Text(
                        'How hairy should your future dog be?',
                        style: GoogleFonts.newsreader(
                          fontSize: getResponsiveValue(
                            context,
                            verySmall: 34,
                            small: 36,
                            medium: 40,
                            large: 44,
                          ),
                          fontWeight: FontWeight.bold,
                          color: _currentLevel['darkColor'],
                          letterSpacing: -0.9,
                          height: 0.95,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: getResponsiveValue(
                          context,
                          verySmall: 8,
                          small: 12,
                          medium: 16,
                          large: 20,
                        ),
                      ),
                      _buildCuteSlider(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: getResponsiveValue(
              context,
              verySmall: 120,
              small: 150,
              medium: 160,
              large: 180,
            ),
            bottom: 0,
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
                  _currentLevel['image'] as String,
                  key: ValueKey('hairiness_image_${_hairinessLevel.round()}'),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.pets_rounded,
                      size: 160,
                      color: Colors.white.withOpacity(0.9),
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
              verySmall: 88,
              small: 98,
              medium: 108,
              large: 115,
            ),
            child: Column(
              children: [
                Text(
                  '${_hairinessLevel.round()}',
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
                const SizedBox(height: 6),
                Text(
                  '${_currentLevel['emoji']} ${_currentLevel['label']}',
                  style: GoogleFonts.poppins(
                    fontSize: getResponsiveValue(
                      context,
                      verySmall: 16,
                      small: 17,
                      medium: 18,
                      large: 19,
                    ),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: screenWidth * 0.75,
                  child: Text(
                    _currentLevel['description'] as String,
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
                  onPressed: _saveHairinessLevel,
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
                  onTap: () => context.pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuteSlider(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          child: Slider(
            value: _hairinessLevel,
            min: 0,
            max: 5,
            divisions: 5,
            label: _hairinessLevel.round().toString(),
            onChanged: (value) {
              setState(() {
                _hairinessLevel = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void _saveHairinessLevel() {
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    if (onboardingComplete) {
      ref.read(userProfileProvider.notifier).updateUserProfile(
            level: _hairinessLevel.round(),
            label: _hairinessLevel.round().toString(),
            column: 'personality_traits',
            key: 'hairiness_preference',
          );
      Navigator.of(context).pop();
    } else {
      ref.read(userProfileProvider.notifier).setHairinessLevel(
            context,
            _hairinessLevel.round(),
            _hairinessLevel.round().toString(),
          );
    }
  }
}
