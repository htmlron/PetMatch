import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/pet_profile/widgets/build_field_label.dart';

class TemperamentInfoStep extends ConsumerStatefulWidget {
  final List<String> selectedTraits;
  final double affectionLevel;
  final double independence;
  final double adaptability;
  final double trainingDifficulty;
  final Function(List<String>) onSelectedTraitsChanged;
  final Function(double) onAffectionLevelChanged;
  final Function(double) onIndependenceChanged;
  final Function(double) onAdaptabilityChanged;
  final Function(double) onTrainingDifficultyChanged;

  const TemperamentInfoStep({
    super.key,
    required this.selectedTraits,
    required this.affectionLevel,
    required this.independence,
    required this.adaptability,
    required this.trainingDifficulty,
    required this.onSelectedTraitsChanged,
    required this.onAffectionLevelChanged,
    required this.onIndependenceChanged,
    required this.onAdaptabilityChanged,
    required this.onTrainingDifficultyChanged,
  });

  @override
  ConsumerState<TemperamentInfoStep> createState() =>
      _TemperamentInfoStepState();
}

class _TemperamentInfoStepState extends ConsumerState<TemperamentInfoStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affection Level
          const BuildFieldLabel(
            text: 'Affection Level',
            emoji: '💕',
          ),
          const SizedBox(height: 12),
          _buildAffectionSlider(),
          const SizedBox(height: 24),

          // Independence
          const BuildFieldLabel(
            text: 'Independence',
            emoji: '🦅',
          ),
          const SizedBox(height: 12),
          _buildIndependenceSlider(),
          const SizedBox(height: 24),

          // Adaptability
          const BuildFieldLabel(
            text: 'Adaptability',
            emoji: '🌟',
          ),
          const SizedBox(height: 12),
          _buildAdaptabilitySlider(),
          const SizedBox(height: 24),

          // Training Level
          const BuildFieldLabel(
            text: 'Training Level',
            emoji: '🎯',
          ),
          const SizedBox(height: 12),
          _buildTrainingSlider(),
        ],
      ),
    );
  }

  // ---------------------------
  // Widget Builders
  // ---------------------------
  // ignore: unused_element
  Widget _buildTraitChips() {
    final traits = [
      {'label': 'Gentle', 'emoji': '🕊️'},
      {'label': 'Protective', 'emoji': '🛡️'},
      {'label': 'Social', 'emoji': '🎉'},
      {'label': 'Independent', 'emoji': '🦅'},
      {'label': 'Affectionate', 'emoji': '💖'},
      {'label': 'Shy', 'emoji': '🙈'},
      {'label': 'Confident', 'emoji': '😎'},
      {'label': 'Loyal', 'emoji': '💙'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: traits.map((trait) {
        final isSelected = widget.selectedTraits.contains(trait['label']);
        final isDisabled = !isSelected && widget.selectedTraits.length >= 3;

        return Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    final updatedTraits =
                        List<String>.from(widget.selectedTraits);
                    if (isSelected) {
                      updatedTraits.remove(trait['label']);
                    } else {
                      updatedTraits.add(trait['label'] as String);
                    }
                    widget.onSelectedTraitsChanged(updatedTraits);
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF42A5F5) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trait['emoji'] as String,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    trait['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAffectionSlider() {
    final labels = [
      'None',
      'Very Independent',
      'Somewhat Independent',
      'Balanced',
      'Affectionate',
      'Very Affectionate'
    ];
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFF4081),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFFFF4081),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: widget.affectionLevel,
            min: 0,
            max: 5,
            divisions: 5,
            label: labels[widget.affectionLevel.round().clamp(0, 5).toInt()],
            onChanged: (value) => widget.onAffectionLevelChanged(value),
          ),
        ),
        Text(
          labels[widget.affectionLevel.round().clamp(0, 5).toInt()],
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFF4081)),
        ),
      ],
    );
  }

  Widget _buildIndependenceSlider() {
    final labels = [
      'None',
      'Highly Dependent',
      'Dependent',
      'Moderate',
      'Independent',
      'Very Independent'
    ];
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFFB300),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFFFFB300),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: widget.independence,
            min: 0,
            max: 5,
            divisions: 5,
            label: labels[widget.independence.round().clamp(0, 5).toInt()],
            onChanged: (value) => widget.onIndependenceChanged(value),
          ),
        ),
        Text(
          labels[widget.independence.round().clamp(0, 5).toInt()],
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFB300)),
        ),
      ],
    );
  }

  Widget _buildAdaptabilitySlider() {
    final labels = [
      'None',
      'Struggles with Change',
      'Difficult',
      'Moderate',
      'Adaptable',
      'Very Adaptable'
    ];
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF26A69A),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFF26A69A),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: widget.adaptability,
            min: 0,
            max: 5,
            divisions: 5,
            label: labels[widget.adaptability.round().clamp(0, 5).toInt()],
            onChanged: (value) => widget.onAdaptabilityChanged(value),
          ),
        ),
        Text(
          labels[widget.adaptability.round().clamp(0, 5).toInt()],
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF26A69A)),
        ),
      ],
    );
  }

  Widget _buildTrainingSlider() {
    final labels = [
      'None',
      'Beginner',
      'Novice',
      'Intermediate',
      'Advanced',
      'Expert',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF81C784),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: const Color(0xFF81C784),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: widget.trainingDifficulty,
            min: 0,
            max: 5,
            divisions: 5,
            label: labels[widget.trainingDifficulty.round().clamp(0, 5).toInt()],
            onChanged: (value) => widget.onTrainingDifficultyChanged(value),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          labels[widget.trainingDifficulty.round().clamp(0, 5).toInt()],
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF81C784),
          ),
        ),
      ],
    );
  }
}
