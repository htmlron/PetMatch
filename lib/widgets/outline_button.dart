import 'package:flutter/material.dart';
import 'package:petmatch/core/services/audit_trail_service.dart';

class OutlineCustomButton extends StatelessWidget {
  const OutlineCustomButton(
      {super.key,
      required this.buttonText,
      this.onPressed,
      this.iconData,
      this.auditLabel});

  final String buttonText;
  final Function()? onPressed;
  final IconData? iconData;
  final String? auditLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
          ),
          onPressed: onPressed == null
              ? null
              : () {
                  auditTrailService.trackButtonClick(
                    buttonLabel: auditLabel ?? buttonText,
                  );
                  onPressed?.call();
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8.0),
              ],
              Text(
                buttonText,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
