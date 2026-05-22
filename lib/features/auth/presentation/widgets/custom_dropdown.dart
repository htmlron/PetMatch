import 'package:flutter/material.dart';

class DropdownButtonFormFieldWidget<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final Widget Function(T item) itemBuilder;

  const DropdownButtonFormFieldWidget({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.prefixIcon,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 209, 209, 209)),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          hintText: label,
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey,
              ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2.0,
            ),
          ),
        ),
        initialValue: selectedValue,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16.0,
            ),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: itemBuilder(item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
