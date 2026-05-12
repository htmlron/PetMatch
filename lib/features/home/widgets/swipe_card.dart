import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petmatch/core/model/pet_match_model.dart';

enum SwipeDirection { left, right, none }

class SwipeCard extends StatefulWidget {
  final PetMatch petMatch;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;
  final Duration animationDuration;

  const SwipeCard({
    Key? key,
    required this.petMatch,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
    this.onInfoTap,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  Offset _dragOffset = Offset.zero;
  SwipeDirection _currentDirection = SwipeDirection.none;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = Offset(
        _dragOffset.dx + details.delta.dx,
        _dragOffset.dy + details.delta.dy * 0.5, // Less vertical movement
      );

      // Determine swipe direction
      if (_dragOffset.dx > 50) {
        _currentDirection = SwipeDirection.right;
        _rotationController.forward();
      } else if (_dragOffset.dx < -50) {
        _currentDirection = SwipeDirection.left;
        _rotationController.reverse();
      } else {
        _currentDirection = SwipeDirection.none;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if swipe is far enough to trigger action
    if (_dragOffset.dx.abs() > screenWidth * 0.25 ||
        velocity.abs() > 500) {
      _isAnimating = true;

      // Animate card off screen
      Offset targetOffset;
      SwipeDirection finalDirection;

      if (_dragOffset.dx > 0 || velocity > 500) {
        targetOffset = Offset(screenWidth * 1.5, _dragOffset.dy);
        finalDirection = SwipeDirection.right;
      } else {
        targetOffset = Offset(-screenWidth * 1.5, _dragOffset.dy);
        finalDirection = SwipeDirection.left;
      }

      _animationController.forward().then((_) {
        if (finalDirection == SwipeDirection.right) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
      });

      _animateToPosition(targetOffset);
    } else {
      // Snap back to original position
      _animateToPosition(Offset.zero);
      _rotationController.reset();
    }
  }

  void _animateToPosition(Offset targetPosition) {
    Tween<Offset>(begin: _dragOffset, end: targetPosition)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        )
        .addListener(() {
      setState(() {
        _dragOffset = Tween<Offset>(begin: _dragOffset, end: targetPosition)
            .evaluate(
              CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
            );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.petMatch.pet;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final verticalMargin = screenHeight <= 740 ? 10.0 : 20.0;

    // Calculate opacity based on drag
    final dragPercentage = (_dragOffset.dx.abs() / (screenWidth * 0.25)).clamp(0.0, 1.0);
    final rotationAngle = (_dragOffset.dx / screenWidth) * 0.3; // Max 0.3 radians rotation

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotationAngle,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: verticalMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    // Pet Image - optimized for low-RAM devices
                    Positioned.fill(
                      child: pet.thumbnailUrl != null
                          ? CachedNetworkImage(
                              imageUrl: pet.thumbnailUrl!,
                              fit: BoxFit.cover,
                              maxHeightDiskCache: 720,
                              maxWidthDiskCache: 720,
                              memCacheHeight: 600,
                              memCacheWidth: 400,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets, size: 60, color: Colors.grey[400]),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Image failed to load',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pets, size: 60, color: Colors.grey[400]),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No image available',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Swipe indicators
                    if (_currentDirection == SwipeDirection.right)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.green.withOpacity(0.3 * dragPercentage),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_currentDirection == SwipeDirection.left)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Colors.red.withOpacity(0.3 * dragPercentage),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // "LIKE" label
                    if (_currentDirection == SwipeDirection.right)
                      Positioned(
                        top: 30,
                        left: 30,
                        child: Transform.rotate(
                          angle: -0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'LIKE',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // "SKIP" label
                    if (_currentDirection == SwipeDirection.left)
                      Positioned(
                        top: 30,
                        right: 30,
                        child: Transform.rotate(
                          angle: 0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'SKIP',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Match badge
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.petMatch.matchColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.petMatch.matchIcon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.petMatch.totalMatchPercent.toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Info button
                    Positioned(
                      top: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: widget.onInfoTap ?? widget.onTap,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'WHY THIS MATCH?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrange,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    // Pet info at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${pet.age ?? '?'} ${pet.ageUnit ?? 'years'} • ${pet.breed ?? pet.species}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (pet.description != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                pet.description!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (pet.goodWithChildren == true)
                                  _buildTraitBadge('👶 Kids', Colors.blue),
                                if (pet.goodWithDogs == true)
                                  _buildTraitBadge('🐕 Dogs', Colors.orange),
                                if (pet.goodWithCats == true)
                                  _buildTraitBadge('🐱 Cats', Colors.purple),
                                if (pet.energyLevel != null && pet.energyLevel! >= 7)
                                  _buildTraitBadge('⚡ Energetic', Colors.yellow[700]!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTraitBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.8), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
