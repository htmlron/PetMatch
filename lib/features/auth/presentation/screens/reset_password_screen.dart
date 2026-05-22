import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/auth/provider/auth_provider.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? token;

  const ResetPasswordScreen({
    super.key,
    this.email,
    this.token,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSubmitting = false;
  

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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
            widget.email ?? '',
            widget.token,
          );
      // The changePassword method handles navigation
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: $e'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Reset Password',
                  style: GoogleFonts.newsreader(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                if (widget.email != null && widget.email!.isNotEmpty)
                  Text(
                    'Creating a new password for\n${widget.email}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),

                const SizedBox(height: 40),

                // New Password Field
                TextFieldWidget(
                  label: 'Password',
                  controller: _passwordController,
                  isPasswordField: true,
                  prefixIcon: Icons.lock,
                  fillColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  filled: true,
                  iconColor: Theme.of(context).colorScheme.onPrimary,
                  focusedBorderColor: Theme.of(context).colorScheme.onPrimary,
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                TextFieldWidget(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isPasswordField: true,
                  prefixIcon: Icons.lock,
                  fillColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  filled: true,
                  iconColor: Theme.of(context).colorScheme.onPrimary,
                  focusedBorderColor: Theme.of(context).colorScheme.onPrimary,
                ),

                const SizedBox(height: 40),

                // Reset Password Button
                CustomButton(
                  label: _isSubmitting ? 'Resetting...' : 'Reset Password',
                  onPressed: _isSubmitting ? null : _submit,
                  icon: Icons.lock_reset,
                  backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                ),

                const SizedBox(height: 20),

                // Security Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure your password is at least 6 characters and includes a mix of letters and numbers.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
