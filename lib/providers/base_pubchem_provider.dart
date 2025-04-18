import 'package:flutter/foundation.dart';

/// Base provider class for PubChem API interactions.
/// This abstract class defines the interface for all PubChem-related providers.
/// Subclasses should implement specific methods for their particular use cases.
abstract class BasePubChemProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch CIDs (Compound IDs) for a given compound name
  Future<List<int>> fetchCids(String name);

  /// Fetch basic properties for a list of compound IDs
  Future<List<Map<String, dynamic>>> fetchBasicProperties(List<int> cids,
      {int limit = 10});

  /// Fetch detailed information for a compound ID
  Future<Map<String, dynamic>> fetchDetailedInfo(int cid);

  /// Fetch synonyms for a compound ID
  Future<List<String>> fetchSynonyms(int cid);

  /// Fetch description for a compound ID
  Future<Map<String, String>> fetchDescription(int cid);

  /// Fetch auto-complete suggestions for a query
  Future<List<String>> fetchAutoCompleteSuggestions(String query,
      {String dictionary = 'compound', int limit = 10});

  /// Fetch 3D structure data for a compound ID
  Future<String> fetch3DStructure(int cid);

  /// Fetch classification data for a compound ID
  Future<Map<String, dynamic>> fetchClassification(int cid);

  /// Fetch patents related to a compound ID
  Future<List<Map<String, dynamic>>> fetchPatents(int cid);

  /// Fetch assay summary for a compound ID
  Future<List<Map<String, dynamic>>> fetchAssaySummary(int cid);

  /// Search compounds by molecular formula
  Future<List<int>> searchByMolecularFormula(String formula);

  /// Find similar compounds based on structure similarity
  Future<List<int>> fetchSimilarCompounds(int cid, {int threshold = 90});

  // Common state management methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
