import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/element.dart';
import '../utils/element_data.dart';

class ElementProvider with ChangeNotifier {
  List<Element> _elements = [];
  bool _isLoading = false;
  String? _error;
  Element? _selectedElement;
  Map<String, Element> _elementDetailsCache = {};
  DateTime? _lastFetchTime;
  static const cacheDuration = Duration(hours: 24); // Cache for 24 hours

  List<Element> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Element? get selectedElement => _selectedElement;

  // Check if cache is valid
  bool get isCacheValid =>
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < cacheDuration;

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final elementsJson =
          _elements.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList('cached_elements', elementsJson);
      await prefs.setString(
          'last_fetch_time', DateTime.now().toIso8601String());
      print('Saved ${elementsJson.length} elements to cache');
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimeStr = prefs.getString('last_fetch_time');
      if (lastFetchTimeStr != null) {
        _lastFetchTime = DateTime.parse(lastFetchTimeStr);
      }

      if (!isCacheValid) {
        print('Cache is invalid or expired');
        return false;
      }

      final elementsJson = prefs.getStringList('cached_elements');
      if (elementsJson == null || elementsJson.isEmpty) {
        print('No cached elements found');
        return false;
      }

      _elements =
          elementsJson.map((e) => Element.fromJson(json.decode(e))).toList();
      print('Loaded ${_elements.length} elements from cache');
      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading from cache: $e');
      return false;
    }
  }

  Future<void> fetchElements({bool forceRefresh = false}) async {
    if (!forceRefresh && _elements.isNotEmpty) {
      print('Using existing elements in memory');
      return;
    }

    if (!forceRefresh && await _loadFromCache()) {
      print('Using cached elements');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching periodic table data...');
      final response = await http.get(
        Uri.parse('https://api.apiverve.com/v1/periodictable?list=all'),
        headers: {
          'x-api-key': 'e1618d6d-e3bd-4e26-bfc3-aff9421eb640',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch periodic table data. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['status'] != 'ok') {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }

      if (data['data'] == null) {
        throw Exception('No data received for periodic table');
      }

      _elements =
          (data['data'] as List).map((e) => Element.fromJson(e)).toList();

      // Debug any elements with zero atomic mass after applying fallback values
      final zeroMassElements =
          _elements.where((e) => e.atomicMass <= 0).toList();
      if (zeroMassElements.isNotEmpty) {
        print(
            'Found ${zeroMassElements.length} elements still with zero/invalid atomic mass after applying fallbacks:');
        for (final element in zeroMassElements) {
          print(
              '- ${element.name} (${element.symbol}): ${element.atomicMass} - Default value in map: ${defaultAtomicMasses[element.symbol]}');
        }
      }

      _lastFetchTime = DateTime.now();
      await _saveToCache();
      print('Successfully loaded ${_elements.length} elements');
    } catch (e) {
      print('Error in fetchElements: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchElementDetails(String symbol) async {
    // Check if element details are already in memory cache
    if (_elementDetailsCache.containsKey(symbol)) {
      print('Using cached details for $symbol');
      _selectedElement = _elementDetailsCache[symbol];

      // Ensure atomic mass is valid
      if (_selectedElement!.atomicMass <= 0) {
        print(
            'Warning: Cached element $symbol has invalid atomic mass: ${_selectedElement!.atomicMass}. Using fallback value: ${defaultAtomicMasses[symbol]}');
      }

      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching details for element symbol: $symbol');
      final response = await http.get(
        Uri.parse('https://api.apiverve.com/v1/periodictable?symbol=$symbol'),
        headers: {
          'x-api-key': 'e1618d6d-e3bd-4e26-bfc3-aff9421eb640',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch element details. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['status'] != 'ok') {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }

      if (data['data'] == null) {
        throw Exception('No data received for element $symbol');
      }

      _selectedElement = Element.fromJson(data['data']);

      // Check atomic mass for the fetched element
      if (_selectedElement!.atomicMass <= 0) {
        print(
            'Warning: Fetched element $symbol has invalid atomic mass: ${_selectedElement!.atomicMass}. Using fallback value: ${defaultAtomicMasses[symbol]}');
        print('Raw API data: ${data['data']['atomic_mass']}');
      }

      // Cache the element details
      _elementDetailsCache[symbol] = _selectedElement!;
      print('Successfully cached details for $symbol');
    } catch (e) {
      print('Error in fetchElementDetails: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedElement() {
    _selectedElement = null;
    notifyListeners();
  }

  void clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_elements');
    await prefs.remove('last_fetch_time');
    _elementDetailsCache.clear();
    _lastFetchTime = null;
    _elements.clear();
    notifyListeners();
  }
}
