import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/text_field.dart';

class VerifyResetOtpScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetOtpScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyResetOtpScreen> createState() =>
      _VerifyResetOtpScreenState();
}

class _VerifyResetOtpScreenState extends ConsumerState<VerifyResetOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate OTP
    if (otp.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the 6-digit code'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (otp.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code must be 6 digits'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validate passwords
    if (newPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a new password'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (newPassword.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 8 characters'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(authProvider.notifier).changePassword(
            context,
            newPassword,
            widget.email,
            otp,
          );
      // The changePassword method navigates to /password-changed on success
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                'Enter Reset Code',
                style: GoogleFonts.newsreader(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'We sent a 6-digit code to\n${widget.email}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Code Field
              TextFieldWidget(
                controller: _otpController,
                label: '6-Digit Code',
                prefixIcon: Icons.pin_outlined,
                isNumberOnly: true,
              ),

              const SizedBox(height: 24),

              // New Password Field
              TextFieldWidget(
                controller: _passwordController,
                label: 'New Password',
                isPasswordField: true,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 20),

              // Confirm Password Field
              TextFieldWidget(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                isPasswordField: true,
                prefixIcon: Icons.lock_outline,
              ),

              const SizedBox(height: 40),

              // Reset Password Button
              CustomButton(
                label: _isSubmitting ? 'Verifying...' : 'Reset Password',
                onPressed: _isSubmitting ? null : _submit,
                icon: Icons.lock_reset,
                backgroundColor: const Color.fromARGB(255, 24, 24, 24),
              ),

              const SizedBox(height: 20),

              // Resend Code
              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(authProvider.notifier)
                        .requestResetPassword(context, widget.email);
                  },
                  child: const Text(
                    'Didn\'t receive the code? Resend',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
