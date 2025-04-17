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

class FlashcardElement {
  final int atomicNumber;
  final String symbol;
  final String name;
  final double atomicMass;
  final String cpkHexColor;
  final Color color; // Derived from cpkHexColor
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

  FlashcardElement({
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
  }) : color = _parseColor(cpkHexColor); // Initialize color here

  // Assumes the order in the JSON matches the Column order:
  // ["AtomicNumber", "Symbol", "Name", "AtomicMass", "CPKHexColor", "ElectronConfiguration",
  // "Electronegativity", "AtomicRadius", "IonizationEnergy", "ElectronAffinity", "OxidationStates",
  // "StandardState", "MeltingPoint", "BoilingPoint", "Density", "GroupBlock", "YearDiscovered"]
  factory FlashcardElement.fromJson(List<dynamic> cellData) {
    // Basic validation
    if (cellData.length < 17) {
      print(
          "Error: FlashcardElement cellData has length ${cellData.length}, expected 17.");
      throw FormatException(
          "Invalid FlashcardElement data length: ${cellData.length}");
    }

    return FlashcardElement(
      atomicNumber: _parseInt(cellData[0]),
      symbol: cellData[1]?.toString() ?? '',
      name: cellData[2]?.toString() ?? '',
      atomicMass: _parseDouble(cellData[3]),
      cpkHexColor:
          cellData[4]?.toString() ?? 'CCCCCC', // Default hex if missing
      electronConfiguration: cellData[5]?.toString() ?? '',
      electronegativity: _parseDouble(cellData[6]),
      atomicRadius: _parseDouble(cellData[7]), // Assuming pm
      ionizationEnergy: _parseDouble(cellData[8]), // Assuming eV
      electronAffinity: _parseDouble(cellData[9]), // Assuming eV
      oxidationStates: cellData[10]?.toString() ?? '',
      standardState: cellData[11]?.toString() ?? '', // e.g., Gas, Solid, Liquid
      meltingPoint: _parseDouble(cellData[12]), // Assuming K
      boilingPoint: _parseDouble(cellData[13]), // Assuming K
      density: _parseDouble(cellData[14]), // Assuming g/cm^3 or g/L
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
  factory FlashcardElement.fromJsonMap(Map<String, dynamic> json) {
    return FlashcardElement(
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

  // Example helper for display
  String get formattedAtomicMass => atomicMass.toStringAsFixed(4);
}
