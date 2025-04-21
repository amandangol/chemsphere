import 'package:flutter/material.dart';
import '../../../model/periodic_element.dart';

class ElementUtils {
  /// Returns the color associated with an element's category
  static Color getElementColor(String category) {
    return PeriodicElement.getElementColor(category);
  }

  /// Formats a value for display, handling nulls and zeros
  static String formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    // For numeric values, check if they're zero
    if (value is num || value is String && double.tryParse(value) != null) {
      double? numValue;
      if (value is num) {
        numValue = value.toDouble();
      } else {
        numValue = double.tryParse(value.toString());
      }

      if (numValue != null && numValue == 0) {
        return 'N/A';
      }
    }

    return value.toString();
  }

  /// Formats atomic mass with appropriate decimal places
  static String formatAtomicMass(double mass) {
    if (mass <= 0) {
      return "N/A";
    }
    String formatted = mass.toStringAsFixed(4);
    while (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  /// Returns emoji for an element category
  static String getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'nonmetal':
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return '🌿'; // Plant for nonmetal
      case 'noble gas':
        return '💨'; // Wind for noble gas
      case 'alkali metal':
        return '🔥'; // Fire for alkali metal
      case 'alkaline earth metal':
        return '🌋'; // Volcano for alkaline earth metal
      case 'metalloid':
        return '🔮'; // Crystal ball for metalloid
      case 'halogen':
        return '🧪'; // Test tube for halogen
      case 'transition metal':
        return '⚙️'; // Gear for transition metal
      case 'post-transition metal':
        return '🔧'; // Wrench for post-transition metal
      case 'lanthanide':
        return '✨'; // Sparkles for lanthanide
      case 'actinide':
        return '☢️'; // Radioactive for actinide
      default:
        return '🔍'; // Default
    }
  }
}
