import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/pet_profile/widgets/build_field_label.dart';

class ActivityInfoStep extends ConsumerStatefulWidget {
  final double energyLevel;
  final String? dailyExerciseNeeds;
  final double playfulness;
  final Function(double) onEnergyLevelChanged;
  final Function(String?) onDailyExerciseNeedsChanged;
  final Function(double) onPlayfulnessChanged;

  const ActivityInfoStep({
    super.key,
    required this.energyLevel,
    required this.dailyExerciseNeeds,
    required this.playfulness,
    required this.onEnergyLevelChanged,
    required this.onDailyExerciseNeedsChanged,
    required this.onPlayfulnessChanged,
  });

  @override
  ConsumerState<ActivityInfoStep> createState() => _ActivityInfoStepState();
}

class _ActivityInfoStepState extends ConsumerState<ActivityInfoStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BuildFieldLabel(text: 'Energy Level', emoji: '⚡'),
          const SizedBox(height: 12),
          _buildEnergySlider(),
          const SizedBox(height: 24),

          // Daily Exercise
          const BuildFieldLabel(text: 'Daily Exercise Needs', emoji: '🏃'),
          const SizedBox(height: 12),
          _buildExerciseCards(),
          const SizedBox(height: 24),

          // Playfulness
          const BuildFieldLabel(text: 'Playfulness', emoji: '🎾'),
          const SizedBox(height: 12),
          _buildPlayfulnessSlider(),
        ],
      ),
    );
  }

  // ------------------------
  // UI Component Builders
  // ------------------------
  Widget _buildEnergySlider() {
    final labels = [
      'None',
      'Very Calm',
      'Calm',
      'Moderate',
      'Active',
      'Very Energetic'
    ];
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFF9800),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFFFF9800),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: widget.energyLevel,
            min: 0,
            max: 5,
            divisions: 5,
            label: labels[widget.energyLevel.round().clamp(0, 5).toInt()],
            onChanged: (value) => widget.onEnergyLevelChanged(value),
          ),
        ),
        Text(
          labels[widget.energyLevel.round().clamp(0, 5).toInt()],
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF9800)),
        ),
      ],
    );
  }

  Widget _buildPlayfulnessSlider() {
    final labels = [
      'None',
      'Not Playful',
      'Rarely Plays',
      'Sometimes',
      'Playful',
      'Very Playful'
    ];
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFBA68C8),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFFBA68C8),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: widget.playfulness,
            min: 0,
            max: 5,
            divisions: 5,
            label: labels[widget.playfulness.round().clamp(0, 5).toInt()],
            onChanged: (value) => widget.onPlayfulnessChanged(value),
          ),
        ),
        Text(
          labels[widget.playfulness.round().clamp(0, 5).toInt()],
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFBA68C8)),
        ),
      ],
    );
  }

  Widget _buildExerciseCards() {
    final exercises = [
      {
        'label': 'Low',
        'emoji': '🎈',
        'value': 'Low',
        'color': const Color(0xFF81C784)
      },
      {
        'label': 'Moderate',
        'emoji': '🎾',
        'value': 'Moderate',
        'color': const Color(0xFFFFB74D)
      },
      {
        'label': 'High',
        'emoji': '🏃‍♂️',
        'value': 'High',
        'color': const Color(0xFFE57373)
      },
    ];

    return Column(
      children: exercises.map((exercise) {
        final isSelected = widget.dailyExerciseNeeds == exercise['value'];
        return GestureDetector(
          onTap: () =>
              widget.onDailyExerciseNeedsChanged(exercise['value'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? (exercise['color'] as Color) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (exercise['color'] as Color)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(exercise['emoji'] as String,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  exercise['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
