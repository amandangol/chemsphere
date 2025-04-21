import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../model/periodic_element.dart';

/// Main export file for all flashcard widgets
export 'flashcard_front.dart';
export 'flashcard_back.dart';
export 'property_widgets.dart';

/// Widget for displaying the page indicator at the bottom of the flashcard screen
class FlashcardPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const FlashcardPageIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              '${currentPage + 1} / $totalPages',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main content card for both front and back of the flashcard
class ElementFlashcard extends StatelessWidget {
  final PeriodicElement element;
  final bool isFront;
  final Widget child;

  const ElementFlashcard({
    Key? key,
    required this.element,
    required this.isFront,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = getThemeAdjustedColor(context, element.color);
    final bgColor = isFront ? cardColor : cardColor.withOpacity(0.95);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          gradient: isFront
              ? LinearGradient(
                  colors: [bgColor.withOpacity(0.6), bgColor.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isFront ? bgColor : null,
        ),
        child: child,
      ),
    );
  }

  /// Helper to adjust colors to be more theme-aligned
  static Color getThemeAdjustedColor(
      BuildContext context, Color originalColor) {
    final theme = Theme.of(context);

    // Map colors to theme-appropriate versions
    final colorMap = {
      Colors.green.value: const Color(0xFF2E7D32),
      const Color(0xFF4CAF50).value: const Color(0xFF2E7D32),
      Colors.red.value: const Color(0xFFB82E2E),
      const Color(0xFFF44336).value: const Color(0xFFB82E2E),
      Colors.blue.value: theme.colorScheme.primary,
      const Color(0xFF2196F3).value: theme.colorScheme.primary,
      Colors.deepPurple.value: theme.colorScheme.tertiary,
      const Color(0xFF673AB7).value: theme.colorScheme.tertiary,
      Colors.orange.value: const Color(0xFFE67700),
      const Color(0xFFFF9800).value: const Color(0xFFE67700),
      Colors.teal.value: theme.colorScheme.secondary,
      const Color(0xFF009688).value: theme.colorScheme.secondary,
    };

    return colorMap[originalColor.value] ?? originalColor;
  }
}

/// Utility class for property icons
class ElementIcons {
  /// Get icon for element property
  static IconData getPropertyIcon(String propertyLabel) {
    switch (propertyLabel.toLowerCase()) {
      case 'phase':
      case 'standard state':
        return FontAwesomeIcons.question; // Handled by getPhaseIcon
      case 'atomic mass':
        return FontAwesomeIcons.weightHanging;
      case 'e. config':
        return FontAwesomeIcons.atom;
      case 'electronegativity':
        return FontAwesomeIcons.bolt;
      case 'atomic radius':
        return FontAwesomeIcons.arrowsLeftRightToLine;
      case 'ionization energy':
        return FontAwesomeIcons.arrowUpRightDots;
      case 'electron affinity':
        return FontAwesomeIcons.handHoldingDollar;
      case 'oxidation states':
        return FontAwesomeIcons.layerGroup;
      case 'density':
        return FontAwesomeIcons.compress;
      case 'melting point':
        return FontAwesomeIcons.icicles;
      case 'boiling point':
        return FontAwesomeIcons.fire;
      case 'year discovered':
        return FontAwesomeIcons.calendarDays;
      default:
        return FontAwesomeIcons.flask;
    }
  }

  /// Get icon for element phase
  static IconData getPhaseIcon(String phase) {
    switch (phase.toLowerCase()) {
      case 'gas':
        return FontAwesomeIcons.smog;
      case 'liquid':
        return FontAwesomeIcons.droplet;
      case 'solid':
      default:
        return FontAwesomeIcons.square;
    }
  }
}

/// Utility class for formatting element values
class ElementFormatter {
  /// Format element value (return N/A for null, empty, or zero values)
  static String formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

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
