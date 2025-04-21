import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Main export file for all detail screen widgets
export 'element_header.dart';
export 'element_sections.dart';
export 'property_displays.dart';

/// Utility class for formatting element values
class DetailFormatter {
  /// Format element value (return N/A for null, empty, or zero values)
  static String formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    // For numeric values, check if they're zero
    if (value is num || value is String && double.tryParse(value) != null) {
      double? numValue =
          value is num ? value.toDouble() : double.tryParse(value.toString());

      if (numValue != null && numValue == 0) {
        return 'N/A';
      }
    }

    return value.toString();
  }
}

/// Widget for displaying a section in the element detail screen
class ElementDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const ElementDetailSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
