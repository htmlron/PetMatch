import 'package:flutter/material.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.gradient,
    this.horizontalPadding = 50,
    this.verticalPadding = 16,
    this.borderRadius = 30,
    this.fontSize = 17,
    this.borderColor,
    this.textColor,
    this.auditLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final Color? borderColor; // NEW
  final Color? textColor; // NEW
  final String? auditLabel;

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        backgroundColor ?? Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        width: double.infinity,
        child: gradient != null
            ? _buildGradientButton(context)
            : _buildSolidButton(context, buttonColor),
      ),
    );
  }

  Widget _buildSolidButton(BuildContext context, Color buttonColor) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () {
              auditTrailService.trackButtonClick(
                buttonLabel: auditLabel ?? label,
              );
              onPressed?.call();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor ?? Colors.transparent, // Use borderColor
            width: borderColor != null ? 2 : 0,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        elevation: 0,
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildGradientButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                auditTrailService.trackButtonClick(
                  buttonLabel: auditLabel ?? label,
                );
                onPressed?.call();
              },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            alignment: Alignment.center,
            child: _buildButtonContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white;
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: effectiveTextColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: effectiveTextColor,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      );
    } else {
      return Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: effectiveTextColor,
              letterSpacing: 0.5,
            ),
      );
    }
  }
}
