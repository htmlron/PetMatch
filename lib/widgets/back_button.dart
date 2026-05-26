import 'package:flutter/material.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class BackButtonCircle extends StatelessWidget {
  final VoidCallback? onTap;
  final double iconSize;
  final double padding;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String auditLabel;

  const BackButtonCircle({
    super.key,
    this.onTap,
    this.iconSize = 20,
    this.padding = 8,
    this.borderColor = Colors.black54,
    this.icon = Icons.arrow_back_ios_new,
    this.iconColor = Colors.black,
    this.auditLabel = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        auditTrailService.trackButtonClick(buttonLabel: auditLabel);
        if (onTap != null) {
          onTap!.call();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
