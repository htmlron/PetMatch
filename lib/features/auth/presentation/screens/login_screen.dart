// ignore_for_file: library_private_types_in_public_api, library_prefixes

import 'dart:async';

import 'package:petmatch/core/utils/validators.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/widgets/back_button.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  int _calculateRemainingSeconds(DateTime? lockoutTime) {
    if (lockoutTime == null) return 0;
    final secondsLeft = lockoutTime.difference(DateTime.now()).inSeconds;
    return secondsLeft > 0 ? secondsLeft : 0;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authStateNotifier = ref.read(authProvider.notifier);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final lockoutTime = authState.lockoutTime;
    final remainingSeconds = _calculateRemainingSeconds(lockoutTime);
    final bool isLockedOut = remainingSeconds > 0;

    double lockoutProgress = 0;
    if (isLockedOut) {
      const totalLockoutDuration = 60;
      lockoutProgress =
          (totalLockoutDuration - remainingSeconds) / totalLockoutDuration;
      if (lockoutProgress < 0) lockoutProgress = 0;
      if (lockoutProgress > 1) lockoutProgress = 1;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final kb = MediaQuery.of(context).viewInsets.bottom;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: kb),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedCrossFade(
                          firstChild: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: isSmallScreen ? 20 : 90,
                                bottom: isSmallScreen ? 30 : 50,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image(
                                    image: const AssetImage(
                                        'assets/petmatch_logo.png'),
                                    height: isSmallScreen ? 84 : 150,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: kb > 0
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 220),
                          sizeCurve: Curves.easeInOut,
                        ),

                        SizedBox(
                            height: isSmallScreen
                                ? 40
                                : kb > 0
                                    ? 130
                                    : 40),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 20.0 : 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Login',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Welcome to PetMatch! Find your perfect pet companion and connect with loving animals looking for a home.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                                TextFieldWidget(
                                  label: 'Email',
                                  controller: emailController,
                                  prefixIcon: Icons.person,
                                  iconColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.05),
                                  borderColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(0.5),
                                  filled: true,
                                  focusedBorderColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                TextFieldWidget(
                                  label: 'Password',
                                  controller: passwordController,
                                  isPasswordField: true,
                                  prefixIcon: Icons.lock,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.05),
                                  borderColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(0.5),
                                  filled: true,
                                  iconColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  focusedBorderColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  validator: Validators.validatePassword,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      context.push('/forgot-password');
                                    },
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isSmallScreen ? 13 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 12 : 15),
                                CustomButton(
                                  label: authState.isLoggingIn
                                      ? 'Signing in...'
                                      : isLockedOut
                                          ? 'Locked (${remainingSeconds}s)'
                                          : 'Sign in',
                                  backgroundColor: isLockedOut
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary,
                                  onPressed:
                                      authState.isLoggingIn || isLockedOut
                                          ? null
                                          : () {
                                              authStateNotifier.signIn(
                                                context,
                                                emailController.text,
                                                passwordController.text,
                                              );
                                            },
                                  horizontalPadding: 0,
                                  verticalPadding: isSmallScreen ? 10 : 12,
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),
                              ],
                            ),
                          ),
                        ),

                        // Bottom spacer keeps middle vertically centered
                        const Spacer(),

                        GestureDetector(
                          onTap: () {
                            context.go('/register');
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: Text(
                              "Don't have an account? Sign up",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: BackButtonCircle(
                  iconSize: 18,
                  borderColor: Theme.of(context).colorScheme.onPrimary,
                  iconColor: Theme.of(context).colorScheme.onPrimary,
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/splash');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
