import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class BasePubChemProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Common method to fetch CIDs for a given name
  Future<List<int>> fetchCids(String name) async {
    try {
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$name/cids/JSON');
      final cidResponse = await http.get(cidUrl);

      if (cidResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch compound information. Status: ${cidResponse.statusCode}');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$name".');
      }

      return cids.map((cid) => cid as int).toList();
    } catch (e) {
      throw Exception('Error fetching CIDs: $e');
    }
  }

  // Common method to fetch basic properties
  Future<List<Map<String, dynamic>>> fetchBasicProperties(List<int> cids,
      {int limit = 10}) async {
    try {
      final limitedCids = cids.take(limit).join(',');
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,HeavyAtomCount,AtomStereoCount,BondStereoCount,ExactMass,MonoisotopicMass,TPSA,Charge,IsotopeAtomCount,DefinedAtomStereoCount,UndefinedAtomStereoCount,DefinedBondStereoCount,UndefinedBondStereoCount,CovalentUnitCount,PatentCount,PatentFamilyCount,AnnotationTypes,AnnotationTypeCount,SourceCategories,LiteratureCount,InChI,InChIKey/JSON');

      final propertiesResponse = await http.get(propertiesUrl);

      if (propertiesResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch properties. Status: ${propertiesResponse.statusCode}');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      return List<Map<String, dynamic>>.from(
          propertiesData['PropertyTable']['Properties']);
    } catch (e) {
      throw Exception('Error fetching properties: $e');
    }
  }

  // Common method to fetch detailed information
  Future<Map<String, dynamic>> fetchDetailedInfo(int cid) async {
    try {
      // First fetch the basic compound data
      final compoundUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/JSON');
      final compoundResponse = await http.get(compoundUrl);

      if (compoundResponse.statusCode != 200) {
        throw Exception('Failed to fetch compound data');
      }

      final compoundData = json.decode(compoundResponse.body);

      // Then fetch the record data
      final recordUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON');
      final recordResponse = await http.get(recordUrl);

      if (recordResponse.statusCode != 200) {
        throw Exception('Failed to fetch record data');
      }

      final recordData = json.decode(recordResponse.body);

      // Combine both responses
      return {
        'compound': compoundData,
        'record': recordData,
      };
    } catch (e) {
      throw Exception('Error fetching detailed information: $e');
    }
  }

  // Common method to fetch synonyms
  Future<List<String>> fetchSynonyms(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch synonyms');
      }

      final data = json.decode(response.body);
      final synonymsList = data['InformationList']?['Information'] ?? [];
      if (synonymsList.isNotEmpty) {
        return List<String>.from(synonymsList[0]['Synonym'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching synonyms: $e');
    }
  }

  // Common method to fetch description
  Future<Map<String, String>> fetchDescription(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/description/JSON');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch description');
      }

      final data = json.decode(response.body);
      final descriptions = data['InformationList']?['Information'] ?? [];

      if (descriptions.isNotEmpty) {
        final info = (descriptions as List).firstWhere(
          (item) => item is Map && item.containsKey('Description'),
          orElse: () => {},
        );

        if (info.isNotEmpty) {
          return {
            'description': info['Description'] ?? '',
            'source': info['DescriptionSourceName'] ?? '',
            'url': info['DescriptionURL'] ?? '',
          };
        }
      }
      return {'description': '', 'source': '', 'url': ''};
    } catch (e) {
      throw Exception('Error fetching description: $e');
    }
  }

  // Common method to fetch auto-complete suggestions
  Future<List<String>> fetchAutoCompleteSuggestions(String query,
      {String dictionary = 'compound', int limit = 10}) async {
    try {
      if (query.length < 3) {
        return [];
      }

      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/autocomplete/$dictionary/$query/json?limit=$limit');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch auto-complete suggestions: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final terms = data['dictionary_terms']?[dictionary] ?? [];

      return List<String>.from(terms);
    } catch (e) {
      print('Error fetching auto-complete suggestions: $e');
      return [];
    }
  }

  // Common method to fetch 3D structure data
  Future<String> fetch3DStructure(int cid) async {
    try {
      // Fetch 3D structure in SDF format
      final sdfUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/SDF?record_type=3d&response_type=display');

      final response = await http.get(sdfUrl);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch 3D structure: ${response.statusCode}');
      }

      return response.body;
    } catch (e) {
      print('Error fetching 3D structure: $e');
      throw Exception('Error fetching 3D structure: $e');
    }
  }

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
