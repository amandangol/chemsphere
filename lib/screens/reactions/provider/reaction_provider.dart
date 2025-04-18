import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/reaction.dart';

class ReactionProvider with ChangeNotifier {
  List<ChemicalReaction> _reactions = [];
  bool _isLoading = false;
  String? _error;
  ChemicalReaction? _selectedReaction;

  List<ChemicalReaction> get reactions => _reactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChemicalReaction? get selectedReaction => _selectedReaction;

  Future<void> searchReactions(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, search for compounds related to the reaction type
      final searchResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/JSON'),
      );

      if (searchResponse.statusCode != 200) {
        throw Exception(
            'Failed to search compounds. Status code: ${searchResponse.statusCode}');
      }

      final searchData = json.decode(searchResponse.body);
      final compoundList = searchData['PC_Compounds'] as List<dynamic>;

      // For each compound, fetch its reactions
      _reactions = [];
      for (var compound in compoundList) {
        final cid = compound['id']['id']['cid'];

        // Fetch compound details including reactions
        final detailsResponse = await http.get(
          Uri.parse(
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON'),
        );

        if (detailsResponse.statusCode == 200) {
          final detailsData = json.decode(detailsResponse.body);
          final record = detailsData['Record'];

          // Extract reaction information from the record
          if (record != null) {
            final sections = record['Section'] as List<dynamic>;
            for (var section in sections) {
              if (section['TOCHeading'] == 'Reactions') {
                final reactions = section['Information'] as List<dynamic>;
                for (var reaction in reactions) {
                  final name = reaction['Name'] ?? 'Unnamed Reaction';
                  final description = reaction['Description'] ?? '';

                  _reactions.add(ChemicalReaction(
                    name: name,
                    type: query,
                    reactants: _extractReactants(description),
                    products: _extractProducts(description),
                    conditions: _extractConditions(description),
                    mechanism: description,
                  ));
                }
              }
            }
          }
        }
      }

      if (_reactions.isEmpty) {
        // If no specific reactions found, create a general reaction based on the query
        _reactions.add(ChemicalReaction(
          name: '$query Reaction',
          type: query,
          reactants: 'Reactants vary based on specific $query conditions',
          products: 'Products vary based on specific $query conditions',
          conditions: 'Conditions vary based on specific $query type',
          mechanism:
              'The mechanism of $query involves the breaking and forming of chemical bonds under specific conditions.',
        ));
      }
    } catch (e) {
      print('Error in searchReactions: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _extractReactants(String description) {
    // Simple extraction logic - can be enhanced based on specific needs
    if (description.toLowerCase().contains('reactants')) {
      final start = description.toLowerCase().indexOf('reactants');
      final end = description.toLowerCase().indexOf('products');
      if (end > start) {
        return description.substring(start, end).trim();
      }
    }
    return 'Reactants not specified';
  }

  String _extractProducts(String description) {
    // Simple extraction logic - can be enhanced based on specific needs
    if (description.toLowerCase().contains('products')) {
      final start = description.toLowerCase().indexOf('products');
      final end = description.toLowerCase().indexOf('conditions');
      if (end > start) {
        return description.substring(start, end).trim();
      }
    }
    return 'Products not specified';
  }

  String _extractConditions(String description) {
    // Simple extraction logic - can be enhanced based on specific needs
    if (description.toLowerCase().contains('conditions')) {
      final start = description.toLowerCase().indexOf('conditions');
      return description.substring(start).trim();
    }
    return 'Conditions not specified';
  }

  Future<void> fetchReactionDetails(String reactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Since we're using PubChem, we'll search for the compound again
      await searchReactions(reactionId);
      if (_reactions.isNotEmpty) {
        _selectedReaction = _reactions.first;
      }
    } catch (e) {
      print('Error in fetchReactionDetails: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedReaction() {
    _selectedReaction = null;
    notifyListeners();
  }
}
