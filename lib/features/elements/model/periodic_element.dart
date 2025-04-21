import 'package:flutter/material.dart';

// Helper function to parse double safely
double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null || value == '') return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

// Helper function to parse int safely
int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null || value == '') return defaultValue;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  if (value is double) return value.toInt();
  return defaultValue;
}

// Helper function to parse color from hex string
Color _parseColor(String? hexColor) {
  if (hexColor == null || hexColor.isEmpty) {
    return Colors.grey; // Default color if hex is missing or empty
  }
  try {
    // Ensure the hex string is 6 characters long, pad if necessary
    String formattedHex = hexColor.padLeft(6, '0');
    return Color(int.parse('FF$formattedHex', radix: 16));
  } catch (e) {
    print('Error parsing color hex "$hexColor": $e');
    return Colors.grey; // Default color if parsing fails
  }
}

class PeriodicElement {
  final int atomicNumber;
  final String symbol;
  final String name;
  final double atomicMass;
  final String cpkHexColor;
  final Color color;
  final String electronConfiguration;
  final double electronegativity;
  final double atomicRadius;
  final double ionizationEnergy;
  final double electronAffinity;
  final String oxidationStates;
  final String standardState; // Phase
  final double meltingPoint; // K
  final double boilingPoint; // K
  final double density; // g/cm^3 or g/L for gases
  final String groupBlock; // Category
  final String yearDiscovered;

  PeriodicElement({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.atomicMass,
    required this.cpkHexColor,
    required this.electronConfiguration,
    required this.electronegativity,
    required this.atomicRadius,
    required this.ionizationEnergy,
    required this.electronAffinity,
    required this.oxidationStates,
    required this.standardState,
    required this.meltingPoint,
    required this.boilingPoint,
    required this.density,
    required this.groupBlock,
    required this.yearDiscovered,
  }) : color = _parseColor(cpkHexColor);

  //order in the JSON matches the Column order:
  // ["AtomicNumber", "Symbol", "Name", "AtomicMass", "CPKHexColor", "ElectronConfiguration",
  // "Electronegativity", "AtomicRadius", "IonizationEnergy", "ElectronAffinity", "OxidationStates",
  // "StandardState", "MeltingPoint", "BoilingPoint", "Density", "GroupBlock", "YearDiscovered"]
  factory PeriodicElement.fromJson(List<dynamic> cellData) {
    // Basic validation
    if (cellData.length < 17) {
      print(
          "Error: PeriodicElement cellData has length ${cellData.length}, expected 17.");
      throw FormatException(
          "Invalid PeriodicElement data length: ${cellData.length}");
    }

    return PeriodicElement(
      atomicNumber: _parseInt(cellData[0]),
      symbol: cellData[1]?.toString() ?? '',
      name: cellData[2]?.toString() ?? '',
      atomicMass: _parseDouble(cellData[3]),
      cpkHexColor:
          cellData[4]?.toString() ?? 'CCCCCC', // Default hex if missing
      electronConfiguration: cellData[5]?.toString() ?? '',
      electronegativity: _parseDouble(cellData[6]),
      atomicRadius: _parseDouble(cellData[7]),
      ionizationEnergy: _parseDouble(cellData[8]),
      electronAffinity: _parseDouble(cellData[9]),
      oxidationStates: cellData[10]?.toString() ?? '',
      standardState: cellData[11]?.toString() ?? '',
      meltingPoint: _parseDouble(cellData[12]),
      boilingPoint: _parseDouble(cellData[13]),
      density: _parseDouble(cellData[14]),
      groupBlock:
          cellData[15]?.toString() ?? '', // e.g., Nonmetal, Alkali metal
      yearDiscovered: cellData[16]?.toString() ?? '',
    );
  }

  // toJson might be needed for caching, ensure it reflects the new structure
  Map<String, dynamic> toJson() {
    return {
      'AtomicNumber': atomicNumber,
      'Symbol': symbol,
      'Name': name,
      'AtomicMass': atomicMass,
      'CPKHexColor': cpkHexColor,
      'ElectronConfiguration': electronConfiguration,
      'Electronegativity': electronegativity,
      'AtomicRadius': atomicRadius,
      'IonizationEnergy': ionizationEnergy,
      'ElectronAffinity': electronAffinity,
      'OxidationStates': oxidationStates,
      'StandardState': standardState,
      'MeltingPoint': meltingPoint,
      'BoilingPoint': boilingPoint,
      'Density': density,
      'GroupBlock': groupBlock,
      'YearDiscovered': yearDiscovered,
    };
  }

  // fromJsonMap potentially used for loading from cache
  factory PeriodicElement.fromJsonMap(Map<String, dynamic> json) {
    return PeriodicElement(
      atomicNumber: _parseInt(json['AtomicNumber']),
      symbol: json['Symbol'] ?? '',
      name: json['Name'] ?? '',
      atomicMass: _parseDouble(json['AtomicMass']),
      cpkHexColor: json['CPKHexColor'] ?? 'CCCCCC',
      electronConfiguration: json['ElectronConfiguration'] ?? '',
      electronegativity: _parseDouble(json['Electronegativity']),
      atomicRadius: _parseDouble(json['AtomicRadius']),
      ionizationEnergy: _parseDouble(json['IonizationEnergy']),
      electronAffinity: _parseDouble(json['ElectronAffinity']),
      oxidationStates: json['OxidationStates'] ?? '',
      standardState: json['StandardState'] ?? '',
      meltingPoint: _parseDouble(json['MeltingPoint']),
      boilingPoint: _parseDouble(json['BoilingPoint']),
      density: _parseDouble(json['Density']),
      groupBlock: json['GroupBlock'] ?? '',
      yearDiscovered: json['YearDiscovered'] ?? '',
    );
  }

  // Common color method used across the app for consistent element coloring
  static Color getElementColor(String category) {
    switch (category.toLowerCase()) {
      case 'nonmetal':
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return const Color(0xFF00C853); // Bright green
      case 'alkali metal':
        return const Color(0xFFD50000); // Bright red
      case 'alkaline earth metal':
        return const Color(0xFFFF6D00); // Bright orange
      case 'transition metal':
        return const Color(0xFFFFAB00); // Amber
      case 'metalloid':
        return const Color(0xFF6200EA); // Purple
      case 'post-transition metal':
        return const Color(0xFF1565C0); // Blue
      case 'halogen':
        return const Color(0xFF00B8D4); // Cyan
      case 'noble gas':
        return const Color(0xFF2962FF); // Bright blue
      case 'lanthanide':
        return const Color(0xFFC51162); // Pink
      case 'actinide':
        return const Color(0xFF4A148C); // Deep purple
      default:
        return Colors.grey;
    }
  }

  // Get the standardized color for this element based on its group
  Color get standardColor => PeriodicElement.getElementColor(groupBlock);

  // Example helper for display
  String get formattedAtomicMass => atomicMass.toStringAsFixed(4);
}
