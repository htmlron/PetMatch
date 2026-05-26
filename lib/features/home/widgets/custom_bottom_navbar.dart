import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, Icons.home, 0, '/home'),
              _buildNavItem(
                  context, Icons.favorite_border, 1, '/home/match-dashboard'),
              _buildNavItem(context, Icons.star, 2, '/home/favorite-pets'),
              _buildNavItem(
                  context, Icons.person_outline, 3, '/home/profile-screen'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, int index, String route) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        String cleanTabName;
        switch (route) {
          case '/home':
            cleanTabName = 'Home Dashboard';
            break;
          case '/home/match-dashboard':
            cleanTabName = 'Pet Match Dashboard';
            break;
          case '/home/favorite-pets':
            cleanTabName = 'Favorite Pets Screen';
            break;
          case '/home/profile-screen':
            cleanTabName = 'User Profile Screen';
            break;
          default:
            cleanTabName = route.replaceAll('/home/', '').replaceAll('-', ' ');
        }

        auditTrailService.track(
          action: 'nav_tab_clicked',
          entityType: 'navigation',
          entityId: cleanTabName,
          metadata: {
            'route': cleanTabName,
            'tab_index': index,
            'selected': isSelected,
          },
        );
        if (!isSelected) {
          context.go(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Icon(
          icon,
          color: isSelected
              ? const Color.fromARGB(255, 34, 34, 34)
              : Colors.grey[600],
          size: 28,
        ),
      ),
    );
  }
}
