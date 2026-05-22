// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/utils/notifier_helpers.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String? password;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.password,
  });

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),

              SizedBox(
                height: screenHeight * 0.25,
                child: Lottie.asset(
                  'assets/lottie/email_animation.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_rounded,
                        size: 100,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'We\'ve sent a verification link to',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Please check your inbox and click the verification link to activate your account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 14,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              CustomButton(
                label: _isChecking ? 'Checking...' : 'I\'ve Verified My Email',
                onPressed: _isChecking ? null : _checkEmailVerification,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
              ),

              const SizedBox(height: 16),

              CustomButton(
                label:
                    _isResending ? 'Sending...' : 'Resend Verification Email',
                onPressed: _isResending ? null : _resendVerificationEmail,
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                borderColor: Theme.of(context).colorScheme.onPrimary,
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Need Help?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              _buildTipCard(
                context,
                icon: Icons.inbox_rounded,
                title: 'Check Spam Folder',
                description: 'The email might be in your spam or junk folder.',
              ),

              const SizedBox(height: 12),

              _buildTipCard(
                context,
                icon: Icons.schedule_rounded,
                title: 'Wait a Few Minutes',
                description:
                    'It may take a few minutes for the email to arrive.',
              ),

              const SizedBox(height: 12),

              _buildTipCard(
                context,
                icon: Icons.email_rounded,
                title: 'Check Email Address',
                description: 'Make sure the email address above is correct.',
              ),

              const SizedBox(height: 40),

              // Back to Login
              TextButton(
                onPressed: () => context.go('/sign-in'),
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isChecking = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: widget.email,
        password: widget.password ?? '',
      );

      if (response.user != null) {
        final user = response.user!;

        if (user.emailConfirmedAt != null) {
          await ref.read(authProvider.notifier).initializeAuth();
          final authState = ref.read(authProvider);

          NotifierHelper.showSuccessToast(
            context,
            'Email verified successfully! 🎉',
          );

          if (authState.userProfile?.role == 'admin') {
            context.go('/admin/pet-management');
          } else if (!authState.onboardingComplete) {
            context.go('/onboarding');
          } else {
            context.go('/home');
          }
        } else {
          NotifierHelper.showErrorToast(
            context,
            'Email not verified yet. Please check your inbox.',
          );
        }
      }
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        NotifierHelper.showErrorToast(
          context,
          'Email not verified yet. Please check your inbox and click the verification link.',
        );
      } else if (e.message.contains('Invalid login credentials')) {
        NotifierHelper.showErrorToast(
          context,
          'Unable to verify. Please try resending the email.',
        );
      } else {
        NotifierHelper.showErrorToast(
          context,
          e.message,
        );
      }
    } catch (e) {
      NotifierHelper.showErrorToast(
        context,
        'Error checking verification: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      NotifierHelper.showLoadingToast(context, 'Sending verification email...');

      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email,
        emailRedirectTo: 'https://petmatch-nine.vercel.app/verify-email',
      );

      NotifierHelper.closeToast(context);
      NotifierHelper.showSuccessToast(
        context,
        'Verification email sent! Check your inbox.',
      );
    } catch (e) {
      NotifierHelper.closeToast(context);
      NotifierHelper.showErrorToast(
        context,
        'Failed to resend email: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }
}
