import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petmatch/widgets/custom_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _floatA;
  late final Animation<double> _floatB;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatA = Tween<double>(begin: 0, end: 18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _floatB = Tween<double>(begin: 0, end: -16).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Positioned(
                bottom: 250 + _floatB.value,
                right: -20 + (_floatA.value / 4),
                child: Transform.rotate(
                  angle: 6 + (_floatA.value * 0.004),
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/get_started_screen/paws.png',
              width: isSmallScreen ? 60 : 80,
              height: isSmallScreen ? 60 : 80,
            ),
          ),

          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Positioned(
                bottom: 120 + _floatB.value,
                left: -35 + (_floatB.value / 6),
                child: Transform.rotate(
                  angle: -6 + (_floatB.value * 0.003),
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/get_started_screen/paws.png',
              width: isSmallScreen ? 75 : 100,
              height: isSmallScreen ? 75 : 100,
            ),
          ),

          // Main content with dog (on top)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final localIsSmall = constraints.maxHeight < 700;

                return Column(
                  children: [
                    SizedBox(height: localIsSmall ? 40 : 80),

                    Image.asset(
                      "assets/petmatch_logo.png",
                      height: localIsSmall ? 100 : 140,
                    ),

                    SizedBox(height: localIsSmall ? 12 : 24),

                    // Tagline and description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontSize: localIsSmall ? 26 : 34,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                              children: [
                                const TextSpan(text: "Where "),
                                TextSpan(
                                  text: "companions",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: localIsSmall ? 26 : 34,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        height: 1.2,
                                        fontWeight: FontWeight.w900,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                const TextSpan(text: "\nfind each other."),
                              ],
                            ),
                          ),
                          SizedBox(height: localIsSmall ? 10 : 16),
                          Text(
                            "PetMatch connects people and pets through smart, caring technology—helping adopters discover the perfect furry friend.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: localIsSmall ? 13 : 14,
                                  color: const Color(0xFF666666),
                                  height: 1.6,
                                ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: localIsSmall ? 16 : 28),

                    CustomButton(
                      label: 'Create Account',
                      onPressed: () {
                        context.push('/register');
                      },
                      icon: Icons.pets,
                      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                      verticalPadding: localIsSmall ? 12 : 14,
                    ),

                    SizedBox(height: localIsSmall ? 10 : 16),

                    GestureDetector(
                      onTap: () {
                        context.push('/login');
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "I already have an account, ",
                          style: TextStyle(
                              color: const Color(0xFF666666),
                              fontSize: localIsSmall ? 13 : 14),
                          children: [
                            TextSpan(
                              text: "Sign in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Flexible bottom image so the column won't overflow
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          "assets/get_started_screen/dog.png",
                          fit: BoxFit.contain,
                          height: localIsSmall ? 210 : 330,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
