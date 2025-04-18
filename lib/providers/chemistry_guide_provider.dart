import 'package:flutter/material.dart';
import '../models/chemistry_guide.dart';
import '../services/chemistry_api_service.dart';

enum ChemistryGuideLoadingState {
  idle,
  loading,
  loaded,
  error,
}

class ChemistryGuideProvider with ChangeNotifier {
  final ChemistryApiService _apiService = ChemistryApiService();

  // Data storage
  List<ChemistryElement> _elements = [];
  Map<String, List<ChemistryElement>> _elementCategories = {};
  List<ChemicalCompound> _commonCompounds = [];
  List<ChemistryPathway> _pathways = [];
  List<ChemistryTopic> _topics = [];
  ChemistryElement? _selectedElement;
  ChemicalCompound? _selectedCompound;

  // State tracking
  ChemistryGuideLoadingState _elementsState = ChemistryGuideLoadingState.idle;
  ChemistryGuideLoadingState _compoundsState = ChemistryGuideLoadingState.idle;
  ChemistryGuideLoadingState _pathwaysState = ChemistryGuideLoadingState.idle;
  String? _error;

  // Getters
  List<ChemistryElement> get elements => _elements;
  Map<String, List<ChemistryElement>> get elementCategories =>
      _elementCategories;
  List<ChemicalCompound> get commonCompounds => _commonCompounds;
  List<ChemistryPathway> get pathways => _pathways;
  List<ChemistryTopic> get topics => _topics;
  ChemistryElement? get selectedElement => _selectedElement;
  ChemicalCompound? get selectedCompound => _selectedCompound;
  ChemistryGuideLoadingState get elementsState => _elementsState;
  ChemistryGuideLoadingState get compoundsState => _compoundsState;
  ChemistryGuideLoadingState get pathwaysState => _pathwaysState;
  String? get error => _error;
  bool get isLoading =>
      _elementsState == ChemistryGuideLoadingState.loading ||
      _compoundsState == ChemistryGuideLoadingState.loading ||
      _pathwaysState == ChemistryGuideLoadingState.loading;

  // Initialize data
  Future<void> initialize() async {
    await loadElements();
    await loadCommonCompounds();
    await loadPathways();
  }

  // Load all elements from the periodic table
  Future<void> loadElements() async {
    if (_elementsState == ChemistryGuideLoadingState.loading) return;

    _elementsState = ChemistryGuideLoadingState.loading;
    _error = null;
    notifyListeners();

    try {
      _elements = await _apiService.getAllElements();
      _elementCategories = await _apiService.getElementCategories();
      _elementsState = ChemistryGuideLoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _elementsState = ChemistryGuideLoadingState.error;
    }

    notifyListeners();
  }

  // Load common chemical compounds
  Future<void> loadCommonCompounds() async {
    if (_compoundsState == ChemistryGuideLoadingState.loading) return;

    _compoundsState = ChemistryGuideLoadingState.loading;
    notifyListeners();

    try {
      _commonCompounds = await _apiService.getCommonCompounds();
      _compoundsState = ChemistryGuideLoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _compoundsState = ChemistryGuideLoadingState.error;
    }

    notifyListeners();
  }

  // Load biochemical pathways
  Future<void> loadPathways() async {
    if (_pathwaysState == ChemistryGuideLoadingState.loading) return;

    _pathwaysState = ChemistryGuideLoadingState.loading;
    notifyListeners();

    try {
      // Example pathway data - in a real app, this would come from the API
      // The API would need to be extended to fetch pathway data from PubChem
      _pathways = [
        ChemistryPathway(
          id: 'glycolysis',
          source: 'Reactome',
          name: 'Glycolysis',
          description:
              'The metabolic pathway that converts glucose into pyruvate, releasing energy in the form of ATP.',
          relatedCompoundCids: [5793, 5589, 5950],
          diagramUrl:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Glycolysis.svg/500px-Glycolysis.svg.png',
          externalUrl: 'https://reactome.org/content/detail/R-HSA-70171',
        ),
        ChemistryPathway(
          id: 'citric_acid_cycle',
          source: 'KEGG',
          name: 'Citric Acid Cycle',
          description:
              'Also known as the TCA cycle or Krebs cycle, it is a series of chemical reactions used by all aerobic organisms to release energy.',
          relatedCompoundCids: [767, 311, 6228],
          externalUrl: 'https://www.genome.jp/kegg/pathway/map/map00020.html',
        ),
      ];
      _pathwaysState = ChemistryGuideLoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _pathwaysState = ChemistryGuideLoadingState.error;
    }

    notifyListeners();
  }

  // Select an element for detailed view
  Future<void> selectElement(String symbol) async {
    try {
      _selectedElement = await _apiService.getElementBySymbol(symbol);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Select a compound for detailed view
  Future<void> selectCompound(int cid) async {
    try {
      _selectedCompound = await _apiService.getCompoundByCid(cid);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Search for compounds by name
  Future<List<ChemicalCompound>> searchCompounds(String query) async {
    if (query.isEmpty) return [];

    try {
      return await _apiService.searchCompoundsByName(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get elements by category
  List<ChemistryElement> getElementsByCategory(String category) {
    return _elementCategories[category] ?? [];
  }

  // Clear selection
  void clearSelection() {
    _selectedElement = null;
    _selectedCompound = null;
    notifyListeners();
  }

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
