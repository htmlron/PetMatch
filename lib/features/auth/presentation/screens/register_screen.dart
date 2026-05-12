// ignore_for_file: library_private_types_in_public_api, library_prefixes

// location imports removed — location/region fields are not needed here
import 'package:petmatch/core/utils/validators.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/style/themed_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    username.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateNotifier = ref.read(authProvider.notifier);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final kb = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: kb), // keyboard-aware padding
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      AnimatedCrossFade(
                        firstChild: Padding(
                          padding:
                              EdgeInsets.only(top: isSmallScreen ? 30 : 50),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Image(
                                image: AssetImage('assets/petmatch_logo.png'),
                                height: 84,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 20),
                              if (!isSmallScreen)
                                Text(
                                  'Your journey starts here\nTake the first step',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 24,
                                        height: 1.1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: kb > 0
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 220),
                        sizeCurve: Curves.easeInOut,
                      ),

                      SizedBox(height: isSmallScreen ? 30 : 70),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 20.0 : 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ThemedTextField(
                                  label: 'Username',
                                  controller: username,
                                  prefixIcon: Icons.person,
                                ),
                                ThemedTextField(
                                  label: 'E-mail',
                                  controller: emailController,
                                  prefixIcon: Icons.email,
                                  validator: Validators.validateEmail,
                                ),
                                ThemedTextField(
                                  label: 'Password',
                                  controller: passwordController,
                                  isPasswordField: true,
                                  prefixIcon: Icons.lock,
                                  validator: Validators.validatePassword,
                                ),
                                ThemedTextField(
                                  label: 'Confirm password',
                                  controller: confirmPasswordController,
                                  isPasswordField: true,
                                  prefixIcon: Icons.lock,
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),
                                CustomButton(
                                  label: 'Sign up',
                                  onPressed: () {
                                    authStateNotifier.signUp(
                                        context,
                                        emailController.text,
                                        passwordController.text,
                                        username.text,
                                        confirmPasswordController.text);
                                  },
                                  horizontalPadding: 0,
                                  verticalPadding: isSmallScreen ? 10 : 12,
                                ),
                                SizedBox(height: isSmallScreen ? 16 : 20),
                                Text(
                                  "By creating an account, you agree to our \nterms and conditions",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: isSmallScreen ? 13 : null,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom spacer keeps middle vertically centered
                      const Spacer(),

                      // Optional small footer text (still inside SafeArea)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "Already have an account? Sign in",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
