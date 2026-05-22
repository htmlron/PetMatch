import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const Color _accent = Color.fromARGB(255, 68, 127, 236);

  static const List<String> _options = <String>[
    'Mostly Home',
    'Away 4–6 Hours',
    'Away 8+ Hours',
    'Flexible Schedule',
  ];

  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(userProfileProvider).dailyAvailability;
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected != null && _selected!.trim().isNotEmpty;
    final onboardingComplete = ref.watch(authProvider).onboardingComplete;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                child: BackButtonCircle(
                  iconSize: 18,
                  borderColor: Colors.grey.shade300,
                  iconColor: Colors.black87,
                  onTap: () => context.pop(),
                ),
              ),
              Text(
                'Daily Availability',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How often are you typically home during the day?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = option == _selected;
                    return _OptionTile(
                      label: option,
                      accent: _accent,
                      selected: isSelected,
                      onTap: () => setState(() => _selected = option),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          final value = _selected!;
                          final notifier =
                              ref.read(userProfileProvider.notifier);
                          if (onboardingComplete) {
                            notifier.updateLifestylePreference(
                              key: 'daily_availability',
                              value: value,
                            );
                            Navigator.of(context).pop();
                          } else {
                            notifier.setDailyAvailability(context, value);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? accent : Colors.grey.shade300;
    final bgColor = selected ? accent.withOpacity(0.10) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? accent : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
