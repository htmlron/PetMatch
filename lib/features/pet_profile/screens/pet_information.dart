import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/style/themed_textfield.dart';
import 'package:petmatch/widgets/text_field.dart';

class PetInformationScreen extends ConsumerStatefulWidget {
  const PetInformationScreen({super.key});

  @override
  ConsumerState<PetInformationScreen> createState() =>
      _PetInformationScreenState();
}

class _PetInformationScreenState extends ConsumerState<PetInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Selected values
  String? _selectedSpecies;
  String? _selectedGender;
  String? _selectedSize;
  String? _selectedStatus;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add New Pet',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5F5),
              Colors.white,
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : 24,
            vertical: isSmallScreen ? 16 : 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFFFFC371)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's add a new friend! 🐾",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Fill in the details below",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 28 : 32),

                // Pet Name
                _buildFieldLabel("Pet Name", "🏷️", isSmallScreen),
                const SizedBox(height: 10),
                ThemedTextField(
                  controller: _petNameController,
                  label: 'e.g., Max, Luna, Whiskers',
                  prefixIcon: Icons.pets,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pet name';
                    }
                    return null;
                  },
                ),

                SizedBox(height: isSmallScreen ? 20 : 24),

                // Species
                _buildFieldLabel("Species", "🦴", isSmallScreen),
                const SizedBox(height: 10),
                _buildSpeciesCards(isSmallScreen),

                SizedBox(height: isSmallScreen ? 20 : 24),

                // Breed
                _buildFieldLabel("Breed", "📋", isSmallScreen),
                const SizedBox(height: 10),
                ThemedTextField(
                  controller: _breedController,
                  label: 'e.g., Golden Retriever, Persian',
                  prefixIcon: Icons.assignment,
                ),

                SizedBox(height: isSmallScreen ? 20 : 24),

                // Age and Gender Row
                Row(
                  children: [
                    // Age
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Age (years)", "🎂", isSmallScreen),
                          const SizedBox(height: 10),
                          TextFieldWidget(
                            controller: _ageController,
                            label: 'Age',
                            prefixIcon: Icons.calendar_today,
                            isNumberOnly: true,
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.05),
                            borderColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            focusedBorderColor:
                                Theme.of(context).colorScheme.primary,
                            iconColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Gender
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Gender", "⚧", isSmallScreen),
                          const SizedBox(height: 10),
                          _buildGenderDropdown(isSmallScreen),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 20 : 24),

                // Size
                _buildFieldLabel("Size", "📏", isSmallScreen),
                const SizedBox(height: 10),
                _buildSizeChips(isSmallScreen),

                SizedBox(height: isSmallScreen ? 20 : 24),

                // Status
                _buildFieldLabel("Adoption Status", "✅", isSmallScreen),
                const SizedBox(height: 10),
                _buildStatusCards(isSmallScreen),

                SizedBox(height: isSmallScreen ? 32 : 40),

                // Save Button
                CustomButton(
                  label: 'Add Pet',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _savePet();
                    }
                  },
                  horizontalPadding: 0,
                  verticalPadding: isSmallScreen ? 12 : 14,
                  icon: Icons.add_circle,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, String emoji, bool isSmall) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: isSmall ? 16 : 18),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 14 : 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesCards(bool isSmall) {
    final species = [
      {'label': 'Dog', 'emoji': '🐕', 'value': 'dog'},
      {'label': 'Cat', 'emoji': '🐈', 'value': 'cat'},
      {'label': 'Rabbit', 'emoji': '🐰', 'value': 'rabbit'},
      {'label': 'Other', 'emoji': '🦎', 'value': 'other'},
    ];

    return Row(
      children: species.map((spec) {
        final isSelected = _selectedSpecies == spec['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedSpecies = spec['value'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(
                vertical: isSmall ? 12 : 14,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Text(
                    spec['emoji'] as String,
                    style: TextStyle(fontSize: isSmall ? 28 : 32),
                  ),
                  SizedBox(height: isSmall ? 4 : 6),
                  Text(
                    spec['label'] as String,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
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

  Widget _buildGenderDropdown(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedGender,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.wc,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: 'Select',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: isSmall ? 14 : 15,
          ),
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onPrimary),
        items: ['Male', 'Female', 'Unknown']
            .map((gender) => DropdownMenuItem(
                  value: gender.toLowerCase(),
                  child: Text(
                    gender,
                    style: TextStyle(fontSize: isSmall ? 14 : 15),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
      ),
    );
  }

  Widget _buildSizeChips(bool isSmall) {
    final sizes = [
      {'label': 'Small', 'value': 'small'},
      {'label': 'Medium', 'value': 'medium'},
      {'label': 'Large', 'value': 'large'},
    ];

    return Row(
      children: sizes.map((size) {
        final isSelected = _selectedSize == size['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedSize = size['value'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(
                vertical: isSmall ? 12 : 14,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  size['label'] as String,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusCards(bool isSmall) {
    final statuses = [
      {
        'label': 'Available',
        'emoji': '✅',
        'value': 'available',
        'color': const Color(0xFF4CAF50)
      },
      {
        'label': 'Adopted',
        'emoji': '💚',
        'value': 'adopted',
        'color': const Color(0xFF2196F3)
      },
      {
        'label': 'Pending',
        'emoji': '⏳',
        'value': 'pending',
        'color': const Color(0xFFFF9800)
      },
      {
        'label': 'Not Available',
        'emoji': '🚫',
        'value': 'not_available',
        'color': const Color(0xFF9E9E9E)
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = _selectedStatus == status['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedStatus = status['value'] as String;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 14 : 16,
              vertical: isSmall ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? (status['color'] as Color) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? (status['color'] as Color) : Colors.grey[300]!,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (status['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status['emoji'] as String,
                  style: TextStyle(fontSize: isSmall ? 16 : 18),
                ),
                const SizedBox(width: 6),
                Text(
                  status['label'] as String,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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

  void _savePet() {
    final petData = {
      'name': _petNameController.text,
      'species': _selectedSpecies,
      'breed': _breedController.text,
      'age': _ageController.text,
      'gender': _selectedGender,
      'size': _selectedSize,
      'status': _selectedStatus,
    };

    // TODO: Save to database
    print('Pet Data: $petData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Pet added successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    // Navigate back or to next screen
    Navigator.of(context).pop();
  }
}
