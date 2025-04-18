import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../providers/base_pubchem_provider.dart';
import '../../compounds/model/related_compound.dart';

/// Provider for searching compounds by molecular formula.
/// This provider extends BasePubChemProvider to utilize common PubChem API methods.
class FormulaSearchProvider extends BasePubChemProvider {
  List<RelatedCompound> _searchResults = [];
  String _currentFormula = '';

  List<RelatedCompound> get searchResults => _searchResults;
  String get currentFormula => _currentFormula;

  /// Search for compounds by molecular formula.
  /// This method fetches compounds that match the given formula
  /// and returns them as RelatedCompound objects.
  Future<void> searchByFormula(String formula) async {
    if (formula.isEmpty) {
      setError('Please enter a molecular formula');
      return;
    }

    _currentFormula = formula;
    setLoading(true);
    clearError();
    _searchResults = [];
    notifyListeners();

    try {
      // Use the base method to search by formula
      final cids = await searchByMolecularFormula(formula);

      if (cids.isEmpty) {
        setError('No compounds found for the formula: $formula');
        setLoading(false);
        return;
      }

      // Fetch basic properties for the compounds found
      final properties = await fetchBasicProperties(cids, limit: 20);

      // Convert to RelatedCompound objects
      _searchResults = properties.map((prop) {
        final cid = int.parse(prop['CID'].toString());
        return RelatedCompound(
          cid: cid,
          title: prop['Title'] ?? 'Unknown',
          molecularFormula: prop['MolecularFormula'] ?? formula,
          molecularWeight:
              double.tryParse(prop['MolecularWeight']?.toString() ?? '0') ??
                  0.0,
          smiles: prop['CanonicalSMILES'] ?? '',
          similarityScore: 100.0, // Not applicable for formula search
          pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid',
        );
      }).toList();

      setLoading(false);
    } catch (e) {
      setError('Error searching by formula: $e');
      setLoading(false);
    }
  }

  /// Clear search results and the current formula.
  void clearSearchResults() {
    _searchResults = [];
    _currentFormula = '';
    clearError();
    notifyListeners();
  }

  @override
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

  @override
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

  @override
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

  @override
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
        // Limit to maximum 50 synonyms to improve performance
        final allSynonyms = List<String>.from(synonymsList[0]['Synonym'] ?? []);
        return allSynonyms.take(50).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching synonyms: $e');
    }
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<Map<String, dynamic>> fetchClassification(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/classification/JSON');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch classification: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error fetching classification: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPatents(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/xrefs/PatentID/JSON');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch patents: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final patentsList = data['InformationList']?['Information'] ?? [];

      if (patentsList.isNotEmpty) {
        // First element contains the patents array
        final patentsData = patentsList[0]['PatentID'] ?? [];

        // Convert to list of maps with additional information
        return List<Map<String, dynamic>>.from(patentsData.map((patent) => {
              'id': patent,
              'url': 'https://patents.google.com/patent/$patent',
            }));
      }
      return [];
    } catch (e) {
      print('Error fetching patents: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAssaySummary(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/assaysummary/JSON');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch assay summary: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final assays = data['AssaySummaries']?['AssaySummary'] ?? [];

      return List<Map<String, dynamic>>.from(assays);
    } catch (e) {
      print('Error fetching assay summary: $e');
      return [];
    }
  }

  @override
  Future<List<int>> searchByMolecularFormula(String formula) async {
    try {
      if (formula.isEmpty) {
        return [];
      }

      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastformula/$formula/cids/JSON');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to search by formula: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final cids = data['IdentifierList']?['CID'] ?? [];

      return List<int>.from(cids);
    } catch (e) {
      print('Error searching by formula: $e');
      return [];
    }
  }

  @override
  Future<List<int>> fetchSimilarCompounds(int cid, {int threshold = 90}) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsimilarity_2d/cid/$cid/cids/JSON?Threshold=$threshold');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch similar compounds: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final relatedCids = data['IdentifierList']?['CID'] ?? [];

      // Remove the original CID from the results
      return List<int>.from(relatedCids.where((id) => id != cid));
    } catch (e) {
      print('Error fetching similar compounds: $e');
      return [];
    }
  }
}
