import 'package:flutter/material.dart';

/// Reusable filter dropdown with consistent styling for history/filter screens.
class FilterDropdown extends StatelessWidget {
  final String value;
  final String labelText;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final EdgeInsetsGeometry? contentPadding;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
