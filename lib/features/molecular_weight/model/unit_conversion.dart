// Unit conversion model for molecular weight calculator

/// Enum for mass unit types
enum MassUnit {
  gPerMol, // Grams per mole
  kgPerMol, // Kilograms per mole
  lbPerMol, // Pounds per mole
  uPerMolecule // Atomic mass units per molecule
}

/// Utility class for mass unit conversions
class MassUnitConverter {
  /// Convert mass from grams per mole to the specified unit
  static double convert(double massInGramsPerMol, MassUnit targetUnit) {
    switch (targetUnit) {
      case MassUnit.gPerMol:
        return massInGramsPerMol;
      case MassUnit.kgPerMol:
        return massInGramsPerMol / 1000;
      case MassUnit.lbPerMol:
        return massInGramsPerMol * 0.0022046226;
      case MassUnit.uPerMolecule:
        return massInGramsPerMol; // g/mol is numerically equal to u/molecule
    }
  }

  /// Get the string representation of a unit
  static String getUnitString(MassUnit unit) {
    switch (unit) {
      case MassUnit.gPerMol:
        return 'g/mol';
      case MassUnit.kgPerMol:
        return 'kg/mol';
      case MassUnit.lbPerMol:
        return 'lb/mol';
      case MassUnit.uPerMolecule:
        return 'u';
    }
  }
}
