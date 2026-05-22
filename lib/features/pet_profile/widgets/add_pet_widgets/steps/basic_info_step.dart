// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petmatch/features/home/provider/pets_provider/pet_provider.dart';
import 'package:petmatch/widgets/style/themed_textfield.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  final String petId;
  final TextEditingController petNameController;
  final TextEditingController breedController;
  final TextEditingController ageController;
  final TextEditingController descriptionController;
  final TextEditingController quirkController;
  final String? selectedSpecies;
  final String? selectedGender;
  final String? selectedSize;
  final String? selectedStatus;
  final Function(String?) onSpeciesChanged;
  final Function(String?) onGenderChanged;
  final Function(String?) onSizeChanged;
  final Function(String?)? onStatusChanged;
  final List<File> selectedImages;
  final File? thumbnailImage;
  final Function(List<File>) onImagesChanged;
  final Function(File?) onThumbnailChanged;
  // NEW: Existing images from database (URLs)
  final List<String> existingImageUrls;
  final String? existingThumbnailUrl;
  final Function(List<String>)? onExistingImagesChanged;
  final Function(String?)? onExistingThumbnailChanged;

  const BasicInfoStep({
    super.key,
    required this.petId,
    required this.petNameController,
    required this.breedController,
    required this.ageController,
    required this.descriptionController,
    required this.quirkController,
    required this.selectedSpecies,
    required this.selectedGender,
    required this.selectedSize,
    this.selectedStatus,
    required this.onSpeciesChanged,
    required this.onGenderChanged,
    required this.onSizeChanged,
    this.onStatusChanged,
    required this.selectedImages,
    required this.thumbnailImage,
    required this.onImagesChanged,
    required this.onThumbnailChanged,
    this.existingImageUrls = const [],
    this.existingThumbnailUrl,
    this.onExistingImagesChanged,
    this.onExistingThumbnailChanged,
  });

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera({bool asThumbnail = false}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final file = File(image.path);
        if (asThumbnail) {
          // Set the thumbnail file but do NOT add it to the regular
          // photos list. Thumbnail is stored separately and should not be
          // duplicated in the gallery photos collection.
          widget.onThumbnailChanged(file);
        } else {
          final updatedImages = List<File>.from(widget.selectedImages);
          updatedImages.add(file);
          widget.onImagesChanged(updatedImages);

          if (widget.thumbnailImage == null) {
            widget.onThumbnailChanged(file);
          }
        }
      }
    } catch (e) {
      print('Error picking camera image: $e');
    }
  }

  // --------------------------------
  // Functions to handle image picking, setting thumbnail, and removing images
  // --------------------------------
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final updatedImages = List<File>.from(widget.selectedImages);
        updatedImages.addAll(images.map((xFile) => File(xFile.path)));
        widget.onImagesChanged(updatedImages);

        if (widget.thumbnailImage == null && updatedImages.isNotEmpty) {
          widget.onThumbnailChanged(updatedImages.first);
        }
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  void _setThumbnail(int index) {
    widget.onThumbnailChanged(widget.selectedImages[index]);
  }

  void _removeImage(int index) {
    final updatedImages = List<File>.from(widget.selectedImages);
    final removedImage = updatedImages[index];
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);

    if (widget.thumbnailImage == removedImage && updatedImages.isNotEmpty) {
      widget.onThumbnailChanged(updatedImages.first);
    } else if (updatedImages.isEmpty) {
      widget.onThumbnailChanged(null);
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final newThumbnail = File(image.path);
        widget.onThumbnailChanged(newThumbnail);
      }
    } catch (e) {
      print('Error picking thumbnail: $e');
    }
  }

  Future<void> _removeExistingImage(String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text(
            'Are you sure you want to permanently delete this image from storage?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting image...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Delete from Supabase storage and database
      final petNotifier = ref.read(petsProvider.notifier);
      await petNotifier.deletePetImage(
        petId: widget.petId,
        imageUrl: url,
      );

      if (mounted) {
        // Remove from local state
        if (widget.onExistingImagesChanged != null) {
          final updatedUrls = List<String>.from(widget.existingImageUrls);
          updatedUrls.remove(url);
          widget.onExistingImagesChanged!(updatedUrls);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // --------------------------------
  // Build Method
  // --------------------------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compactFieldWidth = width >= 700 ? 150.0 : width;
        final wideFieldWidth = width >= 700 ? 340.0 : width;

        Widget compactFieldBlock({
          required String text,
          required String emoji,
          required Widget child,
          bool isRequired = false,
          String? subtitle,
          required double blockWidth,
        }) {
          return SizedBox(
            width: blockWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel(
                  text,
                  emoji,
                  subtitle: subtitle,
                  isRequired: isRequired,
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploadSection(),
              const SizedBox(height: 24),

              SizedBox(
                width: wideFieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Pet Name', '🏷️', isRequired: true),
                    const SizedBox(height: 8),
                    ThemedTextField(
                      controller: widget.petNameController,
                      label: 'e.g., Max, Bella, Charlie',
                      prefixIcon: Icons.pets,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter pet name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Species', '🦴', isRequired: true),
              const SizedBox(height: 8),
              _buildSpeciesCards(),
              const SizedBox(height: 20),

              Wrap(
                spacing: 10,
                runSpacing: 14,
                children: [
                  compactFieldBlock(
                    text: 'Breed',
                    emoji: '📋',
                    blockWidth: compactFieldWidth,
                    child: ThemedTextField(
                      controller: widget.breedController,
                      label: 'e.g., Golden Retriever, Persian Cat',
                      prefixIcon: Icons.assignment,
                    ),
                  ),
                  compactFieldBlock(
                    text: 'Age (years)',
                    emoji: '🎂',
                    isRequired: true,
                    blockWidth: compactFieldWidth,
                    child: ThemedTextField(
                      controller: widget.ageController,
                      label: 'e.g., 2',
                      prefixIcon: Icons.cake,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  compactFieldBlock(
                    text: 'Gender',
                    emoji: '⚧️',
                    isRequired: true,
                    blockWidth: compactFieldWidth,
                    child: _buildGenderDropdown(),
                  ),
                  compactFieldBlock(
                    text: 'Size',
                    emoji: '📏',
                    isRequired: true,
                    blockWidth: compactFieldWidth,
                    child: _buildSizeChips(),
                  ),
                  compactFieldBlock(
                    text: 'Status',
                    emoji: '📣',
                    blockWidth: compactFieldWidth,
                    child: _buildStatusToggle(),
                  ),
                  compactFieldBlock(
                    text: 'Description',
                    emoji: '📝',
                    blockWidth: wideFieldWidth,
                    child: ThemedTextField(
                      controller: widget.descriptionController,
                      label: 'A short description about the pet',
                      prefixIcon: Icons.description,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  compactFieldBlock(
                    text: 'Quirk',
                    emoji: '✨',
                    blockWidth: wideFieldWidth,
                    child: ThemedTextField(
                      controller: widget.quirkController,
                      label: 'e.g., Loves to hide socks, Very vocal at night',
                      prefixIcon: Icons.lightbulb,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  //---------------------------------
  // Widget Builders for various sections
  //---------------------------------
  Widget _buildSpeciesCards() {
    final species = [
      {'label': 'Dog', 'emoji': '🐕', 'value': 'Dog'},
      {'label': 'Cat', 'emoji': '🐈', 'value': 'Cat'},
    ];

    return Row(
      children: species.map((spec) {
        final isSelected = widget.selectedSpecies == spec['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onSpeciesChanged(spec['value'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF9800).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(spec['emoji'] as String,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    spec['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected ? const Color(0xFFFF9800) : Colors.black87,
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

  Widget _buildGenderDropdown() {
    final genders = ['Male', 'Female', 'Unknown'];
    final current = widget.selectedGender;
    final displayed = current == null
        ? null
        : (current.trim().isEmpty
            ? null
            : '${current.trim()[0].toUpperCase()}${current.trim().substring(1).toLowerCase()}');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: displayed,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.wc, color: Color(0xFFFF9800)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          hintText: 'Select',
        ),
        validator: (value) => value == null ? 'Required' : null,
        isExpanded: true,
        dropdownColor: Colors.white,
        items: genders
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender, style: GoogleFonts.poppins(fontSize: 14)),
                ))
            .toList(),
        onChanged: (value) => widget.onGenderChanged(value),
      ),
    );
  }

  Widget _buildSizeChips() {
    final sizes = ['Small', 'Medium', 'Large'];
    return Row(
      children: sizes.map((size) {
        final isSelected = widget.selectedSize == size;
        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onSizeChanged(size),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  size,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

  Widget _buildImageUploadSection() {
    final hasAnyImages =
        widget.selectedImages.isNotEmpty || widget.existingImageUrls.isNotEmpty;

    // Determine the current thumbnail to display
    final thumbnailToShow = widget.thumbnailImage != null
        ? null // Will use File
        : widget.existingThumbnailUrl; // Fall back to URL

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Pet Photos', '📸', isRequired: true),
        const SizedBox(height: 12),
        if (!hasAnyImages)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No photos yet',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickThumbnail(),
                      icon: const Icon(Icons.photo),
                      label:
                          Text('Pick Thumbnail', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _pickImages(),
                      icon: const Icon(Icons.photo_library),
                      label: Text('Add Photos', style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              // Thumbnail Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                  image: widget.thumbnailImage != null
                      ? DecorationImage(
                          image: FileImage(widget.thumbnailImage!),
                          fit: BoxFit.cover,
                        )
                      : (thumbnailToShow != null
                          ? DecorationImage(
                              image:
                                  CachedNetworkImageProvider(thumbnailToShow),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child:
                    (widget.thumbnailImage != null || thumbnailToShow != null)
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                            child: const Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Chip(
                                  label: Text('Thumbnail',
                                      style: TextStyle(color: Colors.white)),
                                  backgroundColor: Color(0xFFFF9800),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'No thumbnail set',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.existingImageUrls.length +
                      widget.selectedImages.length +
                      1,
                  itemBuilder: (context, index) {
                    final totalExisting = widget.existingImageUrls.length;
                    final totalNew = widget.selectedImages.length;
                    final totalImages = totalExisting + totalNew;

                    // Add button
                    if (index == totalImages) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          children: [
                            // Add Photos Button
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey[400]!, width: 2),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        size: 28, color: Colors.grey[600]),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Camera buttons column
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Camera for regular photo
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _pickImageFromCamera(
                                        asThumbnail: false),
                                    icon:
                                        const Icon(Icons.camera_alt, size: 14),
                                    label: Text('Photo',
                                        style:
                                            GoogleFonts.poppins(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Camera for thumbnail
                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _pickImageFromCamera(asThumbnail: true),
                                    icon:
                                        const Icon(Icons.camera_alt, size: 14),
                                    label: Text('Thumb',
                                        style:
                                            GoogleFonts.poppins(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16), // Extra padding at end
                          ],
                        ),
                      );
                    }

                    // Display existing URL images
                    if (index < totalExisting) {
                      final url = widget.existingImageUrls[index];
                      final isThumb = url == widget.existingThumbnailUrl &&
                          widget.thumbnailImage == null;

                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Tap to view or set as thumbnail
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isThumb
                                        ? const Color(0xFFFF9800)
                                        : Colors.grey[300]!,
                                    width: isThumb ? 3 : 1,
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.onExistingThumbnailChanged !=
                                        null) {
                                      widget.onExistingThumbnailChanged!(url);
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: url,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Badge to show this is existing/saved
                            Positioned(
                              bottom: 2,
                              left: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'saved',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // Remove button
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => _removeExistingImage(url),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Display newly picked File images
                    final fileIndex = index - totalExisting;
                    final image = widget.selectedImages[fileIndex];
                    final isThumbnail = image == widget.thumbnailImage;

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () => _setThumbnail(fileIndex),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isThumbnail
                                      ? const Color(0xFFFF9800)
                                      : Colors.grey[300]!,
                                  width: isThumbnail ? 3 : 1,
                                ),
                                image: DecorationImage(
                                  image: FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Badge to show this is new
                          Positioned(
                            bottom: 2,
                            left: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'new',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          // Remove button
                          Positioned(
                            top: -4,
                            right: -4,
                            child: GestureDetector(
                              onTap: () => _removeImage(fileIndex),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFieldLabel(String text, String emoji,
      {String? subtitle, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text('*',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusToggle() {
    final current = widget.selectedStatus?.trim();

    bool isAvailable = current != null && current.toLowerCase() == 'available';

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onStatusChanged?.call('Available'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isAvailable ? const Color(0xFFFF9800) : Colors.white,
                border: Border.all(
                  color:
                      isAvailable ? const Color(0xFFFF9800) : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  'Available',
                  style: GoogleFonts.poppins(
                    color: isAvailable ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onStatusChanged?.call('Not available'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: !isAvailable ? Colors.grey[300] : Colors.white,
                border: Border.all(
                  color: !isAvailable ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  'Not available',
                  style: GoogleFonts.poppins(
                    color: !isAvailable ? Colors.black87 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
