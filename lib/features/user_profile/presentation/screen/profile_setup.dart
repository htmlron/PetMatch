import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/widgets/custom_button.dart';
import 'package:petmatch/widgets/style/themed_textfield.dart';
import 'package:petmatch/widgets/text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _adultsController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  final TextEditingController _seniorsController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedLivingArrangement;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _seniorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
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
              Text(
                "Let's get to know you! 🐾",
                style: TextStyle(
                  fontSize: isSmallScreen ? 26 : 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B7A75),
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                "Help us find your perfect furry companion",
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),

              SizedBox(height: isSmallScreen ? 28 : 32),

              // Full Name
              _buildSectionLabel("What's your name?", isSmallScreen),
              const SizedBox(height: 10),
              ThemedTextField(
                controller: _fullNameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
              ),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Age & Gender Row
              Row(
                children: [
                  // Age
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("How old are you?", isSmallScreen),
                        const SizedBox(height: 10),
                        TextFieldWidget(
                          controller: _ageController,
                          label: 'Age',
                          prefixIcon: Icons.cake_outlined,
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
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("Gender", isSmallScreen),
                        const SizedBox(height: 10),
                        _buildGenderDropdown(isSmallScreen),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Location
              _buildSectionLabel("Where do you live?", isSmallScreen),
              const SizedBox(height: 10),
              ThemedTextField(
                controller: _locationController,
                label: 'City / ZIP Code',
                prefixIcon: Icons.location_on_outlined,
              ),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Living Arrangement
              _buildSectionLabel("Your living space", isSmallScreen),
              const SizedBox(height: 10),
              _buildLivingArrangementCards(isSmallScreen),

              SizedBox(height: isSmallScreen ? 20 : 24),

              // Household Size
              _buildSectionLabel("Who's in your household?", isSmallScreen),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInput(
                      'Adults',
                      Icons.person,
                      _adultsController,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInput(
                      'Children',
                      Icons.child_care,
                      _childrenController,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInput(
                      'Seniors',
                      Icons.elderly,
                      _seniorsController,
                      isSmallScreen,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 32 : 40),

              // Continue Button
              CustomButton(
                label: 'Continue',
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Handle form submission
                    _submitProfile();
                  }
                },
                horizontalPadding: 0,
                verticalPadding: isSmallScreen ? 12 : 14,
                icon: Icons.arrow_forward,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isSmall) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isSmall ? 15 : 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
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
        initialValue: _selectedGender ?? 'Prefer not to say',
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.wc,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.onPrimary),
        items: ['Male', 'Female', 'Other', 'Prefer not to say']
            .map((gender) => DropdownMenuItem(
                  value: gender,
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

  Widget _buildLivingArrangementCards(bool isSmall) {
    final arrangements = [
      {'title': 'Apartment', 'icon': Icons.apartment},
      {'title': 'TownHouse', 'icon': Icons.home},
      {'title': 'Farm', 'icon': Icons.agriculture},
      {'title': 'Shared Housing', 'icon': Icons.people},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: arrangements.map((arrangement) {
        final isSelected = _selectedLivingArrangement == arrangement['title'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedLivingArrangement = arrangement['title'] as String;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 14 : 16,
              vertical: isSmall ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  arrangement['icon'] as IconData,
                  size: isSmall ? 18 : 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Text(
                  arrangement['title'] as String,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberInput(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isSmall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: isSmall ? 20 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: isSmall ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: isSmall ? 16 : 18,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitProfile() {
    // Collect all data
    final profileData = {
      'fullName': _fullNameController.text,
      'age': _ageController.text,
      'gender': _selectedGender,
      'location': _locationController.text,
      'livingArrangement': _selectedLivingArrangement,
      'adults': _adultsController.text,
      'children': _childrenController.text,
      'seniors': _seniorsController.text,
    };

    // TODO: Save to database or provider
    print('Profile Data: $profileData');

    // Navigate to next screen or show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }
}
