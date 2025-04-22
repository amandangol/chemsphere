import 'package:flutter/foundation.dart';
import '../../elements/provider/element_provider.dart';
import '../model/molecular_formula.dart';

class MolecularWeightProvider with ChangeNotifier {
  final ElementProvider _elementProvider;

  String _formula = '';
  MolecularFormula? _parsedFormula;
  double? _molecularWeight;
  String? _error;
  bool _isCalculating = false;

  // History of calculations
  final List<CalculationResult> _history = [];

  MolecularWeightProvider(this._elementProvider);

  // Getters
  String get formula => _formula;
  MolecularFormula? get parsedFormula => _parsedFormula;
  double? get molecularWeight => _molecularWeight;
  String? get error => _error;
  bool get isCalculating => _isCalculating;
  List<CalculationResult> get history => _history;

  // Set and calculate new formula
  Future<void> calculateFormula(String formula) async {
    if (formula.isEmpty) {
      _clearResults();
      return;
    }

    _formula = formula;
    _error = null;
    _isCalculating = true;
    _molecularWeight = null;
    notifyListeners();

    try {
      // Parse the formula
      _parsedFormula = MolecularFormula.parse(formula);

      // Ensure elements are loaded
      if (_elementProvider.elements.isEmpty) {
        await _elementProvider.fetchFlashcardElements();
      }

      // Calculate molecular weight
      _molecularWeight =
          _parsedFormula!.calculateMolecularWeight(_elementProvider.elements);

      // Add to history if calculation was successful
      _addToHistory(formula, _molecularWeight!);
    } catch (e) {
      _error = e.toString();
      _parsedFormula = null;
      _molecularWeight = null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  // Add calculation to history
  void _addToHistory(String formula, double weight) {
    // Don't add duplicates
    if (!_history.any((result) => result.formula == formula)) {
      _history.add(CalculationResult(formula, weight, DateTime.now()));
      // Limit history to most recent 20 items
      if (_history.length > 20) {
        _history.removeAt(0);
      }
    }
  }

  // Clear results
  void _clearResults() {
    _formula = '';
    _parsedFormula = null;
    _molecularWeight = null;
    _error = null;
    notifyListeners();
  }

  // Clear all history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}

class CalculationResult {
  final String formula;
  final double weight;
  final DateTime timestamp;

  CalculationResult(this.formula, this.weight, this.timestamp);
}
