// ignore_for_file: library_private_types_in_public_api

import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/style/themed_textfield.dart';
import 'package:petmatch/widgets/text_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isRequestingChange;
    final authNotifier = ref.read(authProvider.notifier);
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            margin: const EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextHeader(
                  text: 'Reset Password',
                  fontSize: 42,
                  letterSpacing: -2.5,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Enter the email address you used when you joined and we'll send you instructions to reset your password.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 25.0),
                ThemedTextField(
                  prefixIcon: Icons.email_outlined,
                  label: 'Enter your email...',
                  controller: emailController,
                )
              ],
            ),
          ),
          if (keyboardHeight == 0)
            Positioned(
              bottom: 30.0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("You remember your password? ",
                            style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Login",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    CustomButton(
                      label: 'Request Password Reset',
                      onPressed: isLoading
                          ? null
                          : () {
                              authNotifier.requestResetPassword(
                                  context, emailController.text);
                            },
                    ),
                    const SizedBox(height: 25.0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
