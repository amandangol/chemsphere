import 'package:http/http.dart' as http;
import 'dart:convert';

/// A mixin that provides concrete implementations of the BasePubChemProvider methods.
/// This allows sharing common implementation logic across different providers.
mixin PubChemImplMixin {
  Future<List<int>> fetchCids(String name) async {
    try {
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$name/cids/JSON');
      final cidResponse = await http.get(cidUrl);

      if (cidResponse.statusCode == 404) {
        throw Exception(
            'No compounds found with the name "$name". Please try another search term.');
      } else if (cidResponse.statusCode != 200) {
        switch (cidResponse.statusCode) {
          case 400:
            throw Exception('Invalid request. Please check your search term.');
          case 429:
            throw Exception('Too many requests. Please try again later.');
          case 500:
          case 501:
          case 502:
          case 503:
          case 504:
            throw Exception('PubChem server error. Please try again later.');
          default:
            throw Exception(
                'Failed to fetch compound information. Status: ${cidResponse.statusCode}');
        }
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$name".');
      }

      return cids.map((cid) => cid as int).toList();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching CIDs: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBasicProperties(List<int> cids,
      {int limit = 10}) async {
    try {
      final limitedCids = cids.take(limit).join(',');
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,HeavyAtomCount,AtomStereoCount,BondStereoCount,ExactMass,MonoisotopicMass,TPSA,Charge,IsotopeAtomCount,DefinedAtomStereoCount,UndefinedAtomStereoCount,DefinedBondStereoCount,UndefinedBondStereoCount,CovalentUnitCount,PatentCount,PatentFamilyCount,AnnotationTypes,AnnotationTypeCount,SourceCategories,LiteratureCount,InChI,InChIKey/JSON');

      final propertiesResponse = await http.get(propertiesUrl);

      if (propertiesResponse.statusCode == 404) {
        throw Exception('Properties not found for the selected compounds.');
      } else if (propertiesResponse.statusCode != 200) {
        switch (propertiesResponse.statusCode) {
          case 400:
            throw Exception('Invalid request for properties.');
          case 429:
            throw Exception('Too many requests. Please try again later.');
          case 500:
          case 501:
          case 502:
          case 503:
          case 504:
            throw Exception('PubChem server error. Please try again later.');
          default:
            throw Exception(
                'Failed to fetch properties. Status: ${propertiesResponse.statusCode}');
        }
      }

      final propertiesData = json.decode(propertiesResponse.body);
      return List<Map<String, dynamic>>.from(
          propertiesData['PropertyTable']['Properties']);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching properties: $e');
    }
  }

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

  Future<String> fetch3DStructure(int cid) async {
    try {
      // Fetch 3D structure in SDF format
      final sdfUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/SDF?record_type=3d&response_type=display');

      final response = await http.get(sdfUrl);

      if (response.statusCode == 404) {
        throw Exception('3D structure not available for this compound.');
      } else if (response.statusCode != 200) {
        switch (response.statusCode) {
          case 400:
            throw Exception('Invalid request for 3D structure.');
          case 429:
            throw Exception('Too many requests. Please try again later.');
          case 500:
          case 501:
          case 502:
          case 503:
          case 504:
            throw Exception('PubChem server error. Please try again later.');
          default:
            throw Exception(
                'Failed to fetch 3D structure: ${response.statusCode}');
        }
      }

      return response.body;
    } catch (e) {
      print('Error fetching 3D structure: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching 3D structure: $e');
    }
  }

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
