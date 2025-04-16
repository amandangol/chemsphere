import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/element.dart';

class ElementProvider with ChangeNotifier {
  List<Element> _elements = [];
  bool _isLoading = false;
  String? _error;
  Element? _selectedElement;

  List<Element> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Element? get selectedElement => _selectedElement;

  Future<void> fetchElements() async {
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

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch periodic table data. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      print('Parsed data: $data');

      if (data['status'] != 'ok') {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }

      if (data['data'] == null) {
        throw Exception('No data received for periodic table');
      }

      _elements =
          (data['data'] as List).map((e) => Element.fromJson(e)).toList();
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

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch element details. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      print('Parsed data: $data');

      if (data['status'] != 'ok') {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }

      if (data['data'] == null) {
        throw Exception('No data received for element $symbol');
      }

      _selectedElement = Element.fromJson(data['data']);
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
}
