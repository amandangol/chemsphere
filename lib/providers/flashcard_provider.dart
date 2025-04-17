import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/flashcard_element.dart';

class FlashcardProvider with ChangeNotifier {
  List<FlashcardElement> _elements = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(hours: 24); // Cache for 24 hours
  static const _cacheKeyElements = 'cached_flashcard_elements';
  static const _cacheKeyTime = 'last_flashcard_fetch_time';

  List<FlashcardElement> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isCacheValid =>
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < cacheDuration;

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final elementsJson =
          _elements.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(_cacheKeyElements, elementsJson);
      await prefs.setString(_cacheKeyTime, DateTime.now().toIso8601String());
      print('Saved ${_elements.length} flashcard elements to cache');
    } catch (e) {
      print('Error saving flashcard elements to cache: $e');
    }
  }

  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimeStr = prefs.getString(_cacheKeyTime);
      if (lastFetchTimeStr != null) {
        _lastFetchTime = DateTime.parse(lastFetchTimeStr);
      }

      if (!isCacheValid) {
        print('Flashcard cache is invalid or expired');
        return false;
      }

      final elementsJson = prefs.getStringList(_cacheKeyElements);
      if (elementsJson == null || elementsJson.isEmpty) {
        print('No cached flashcard elements found');
        return false;
      }

      // Use FlashcardElement.fromJsonMap to load from cache
      _elements = elementsJson
          .map((e) => FlashcardElement.fromJsonMap(json.decode(e)))
          .toList();

      print('Loaded ${_elements.length} flashcard elements from cache');
      // No notifyListeners here, let fetchElements handle it after loading
      return true;
    } catch (e) {
      print('Error loading flashcard elements from cache: $e');
      return false;
    }
  }

  Future<void> fetchFlashcardElements({bool forceRefresh = false}) async {
    // If not forcing refresh and elements are already loaded, return
    if (!forceRefresh && _elements.isNotEmpty) {
      print('Using existing flashcard elements in memory');
      return;
    }

    // Try loading from cache if not forcing refresh
    if (!forceRefresh && await _loadFromCache()) {
      print('Using cached flashcard elements');
      // Notify listeners now that cache loading is complete (if successful)
      notifyListeners();
      return;
    }

    // Proceed with fetching from network
    _isLoading = true;
    _error = null;
    // Notify loading state immediately before network call
    notifyListeners();

    try {
      print('Fetching periodic table data for flashcards from PubChem...');
      final response = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/periodictable/JSON'),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch flashcard data from PubChem. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final table = data['Table'];

      if (table == null || table['Row'] == null) {
        throw Exception(
            'Invalid data structure received from PubChem API for flashcards');
      }

      final List<dynamic> rows = table['Row'];

      // Parse elements using FlashcardElement.fromJson
      final List<FlashcardElement> parsedElements = [];
      for (var rowData in rows) {
        final List<dynamic> cellData = rowData['Cell'];
        try {
          parsedElements.add(FlashcardElement.fromJson(cellData));
        } catch (e) {
          print(
              "Error parsing flashcard element data: $e. Row data: $cellData");
          // Optionally skip problematic rows or handle differently
        }
      }

      if (parsedElements.isEmpty && rows.isNotEmpty) {
        throw Exception(
            'Failed to parse any flashcard elements from the received data.');
      }

      _elements = parsedElements;

      _lastFetchTime = DateTime.now();
      await _saveToCache();
      print(
          'Successfully loaded ${_elements.length} flashcard elements from PubChem');
    } catch (e) {
      print('Error in fetchFlashcardElements: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Notify final state (loaded or error)
      notifyListeners();
    }
  }

  void clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyElements);
    await prefs.remove(_cacheKeyTime);
    _lastFetchTime = null;
    _elements.clear(); // Clear in-memory list
    notifyListeners();
    print('Cleared flashcard element cache');
  }
}
