import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petmatch/features/pet_profile/widgets/build_field_label.dart';

class BehaviorInfoStep extends ConsumerStatefulWidget {
  final TextEditingController behavioralNotesController;
  final bool? goodWithChildren;
  final bool? goodWithDogs;
  final bool? goodWithCats;
  final bool? houseTrained;
  final Function(bool?) onGoodWithChildrenChanged;
  final Function(bool?) onGoodWithDogsChanged;
  final Function(bool?) onGoodWithCatsChanged;
  final Function(bool?) onHouseTrainedChanged;

  const BehaviorInfoStep({
    super.key,
    required this.behavioralNotesController,
    required this.goodWithChildren,
    required this.goodWithDogs,
    required this.goodWithCats,
    required this.houseTrained,
    required this.onGoodWithChildrenChanged,
    required this.onGoodWithDogsChanged,
    required this.onGoodWithCatsChanged,
    required this.onHouseTrainedChanged,
  });

  @override
  ConsumerState<BehaviorInfoStep> createState() => _BehaviorInfoStepState();
}

class _BehaviorInfoStepState extends ConsumerState<BehaviorInfoStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Good with Children
          const BuildFieldLabel(text: 'Good with children?', emoji: '👶'),
          const SizedBox(height: 12),
          _buildYesNoToggle(
            selected: widget.goodWithChildren,
            onChanged: (value) => widget.onGoodWithChildrenChanged(value),
          ),
          const SizedBox(height: 24),

          // Good with Dogs
          const BuildFieldLabel(text: 'Good with other dogs?', emoji: '🐕'),
          const SizedBox(height: 12),
          _buildYesNoToggle(
            selected: widget.goodWithDogs,
            onChanged: (value) => widget.onGoodWithDogsChanged(value),
          ),
          const SizedBox(height: 24),

          // Good with Cats
          const BuildFieldLabel(text: 'Good with cats?', emoji: '🐈'),
          const SizedBox(height: 12),
          _buildYesNoToggle(
            selected: widget.goodWithCats,
            onChanged: (value) => widget.onGoodWithCatsChanged(value),
          ),
          const SizedBox(height: 24),

          // House Trained
          const BuildFieldLabel(text: 'House-trained?', emoji: '🏠'),
          const SizedBox(height: 12),
          _buildYesNoToggle(
            selected: widget.houseTrained,
            onChanged: (value) => widget.onHouseTrainedChanged(value),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -------------------------------
  // Helper to build Yes/No toggle
  // -------------------------------
  Widget _buildYesNoToggle(
      {required bool? selected, required Function(bool) onChanged}) {
    final options = [
      {
        'label': 'Yes',
        'emoji': '✅',
        'value': true,
        'color': const Color(0xFF66BB6A)
      },
      {
        'label': 'No',
        'emoji': '❌',
        'value': false,
        'color': const Color(0xFFEF5350)
      },
    ];

    return Row(
      children: options.map((option) {
        final isSelected = selected == option['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option['value'] as bool),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? (option['color'] as Color) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (option['color'] as Color)
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(option['emoji'] as String,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    option['label'] as String,
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
}
