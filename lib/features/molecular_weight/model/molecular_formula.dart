import '../../elements/model/periodic_element.dart';

class FormulaElement {
  final String symbol;
  final int count;

  FormulaElement(this.symbol, this.count);

  @override
  String toString() => count > 1 ? '$symbol$count' : symbol;
}

class MolecularFormula {
  // Raw formula string
  final String formula;

  // Parsed elements and their counts
  final List<FormulaElement> elements;

  MolecularFormula(this.formula, this.elements);

  /// Parse a chemical formula string and convert it to a MolecularFormula object
  static MolecularFormula parse(String formulaString) {
    final normalizedFormula = formulaString.trim();

    if (normalizedFormula.isEmpty) {
      return MolecularFormula(normalizedFormula, []);
    }

    // Map to store elements and their counts
    final Map<String, int> elementCounts = {};

    // Regular expression to match elements and their counts
    // This will match element symbols (first letter uppercase, optional second lowercase)
    // followed by an optional number
    final RegExp elementRegex = RegExp(r'([A-Z][a-z]?)(\d*)');

    // Find all matches in the formula
    final matches = elementRegex.allMatches(normalizedFormula);

    for (final match in matches) {
      final symbol = match.group(1)!;
      final countStr = match.group(2) ?? '';
      final count = countStr.isNotEmpty ? int.parse(countStr) : 1;

      // Add or update element count
      elementCounts[symbol] = (elementCounts[symbol] ?? 0) + count;
    }

    // Convert the map to a list of FormulaElement objects
    final List<FormulaElement> elements = elementCounts.entries
        .map((entry) => FormulaElement(entry.key, entry.value))
        .toList();

    return MolecularFormula(normalizedFormula, elements);
  }

  /// Calculate the molecular weight based on a list of periodic elements
  double calculateMolecularWeight(List<PeriodicElement> periodicElements) {
    double totalWeight = 0.0;

    for (final element in elements) {
      // Find the matching periodic element
      final periodicElement = periodicElements.firstWhere(
        (e) => e.symbol == element.symbol,
        orElse: () => throw Exception(
            'Element ${element.symbol} not found in the periodic table'),
      );

      // Add the weight of this element (atomic mass × count)
      totalWeight += periodicElement.atomicMass * element.count;
    }

    return totalWeight;
  }

  @override
  String toString() {
    return elements.join('');
  }
}
