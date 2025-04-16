import 'package:shared_preferences/shared_preferences.dart';

enum SearchType {
  compound,
  drug,
  molecularStructure,
  reaction,
}

class SearchHistoryService {
  static const int _maxHistoryItems = 10;

  String _getKey(SearchType type) {
    switch (type) {
      case SearchType.compound:
        return 'compound_search_history';
      case SearchType.drug:
        return 'drug_search_history';
      case SearchType.molecularStructure:
        return 'molecular_structure_search_history';
      case SearchType.reaction:
        return 'reaction_search_history';
    }
  }

  Future<List<String>> getSearchHistory(SearchType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_getKey(type)) ?? [];
  }

  Future<void> addToSearchHistory(String query, SearchType type) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getSearchHistory(type);

    // Remove if already exists
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only last _maxHistoryItems
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }

    await prefs.setStringList(_getKey(type), history);
  }

  Future<void> clearSearchHistory(SearchType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(type));
  }
}
