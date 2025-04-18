import '../../../providers/base_pubchem_provider.dart';
import '../model/assay_summary.dart';
import '../model/patent_info.dart';
import '../model/related_compound.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Provider for searching related compounds, patents, and assays.
/// This provider extends BasePubChemProvider to utilize common PubChem API methods.
class ChemicalSearchProvider extends BasePubChemProvider {
  List<RelatedCompound> _relatedCompounds = [];
  List<PatentInfo> _patents = [];
  List<AssaySummary> _assays = [];

  List<RelatedCompound> get relatedCompounds => _relatedCompounds;
  List<PatentInfo> get patents => _patents;
  List<AssaySummary> get assays => _assays;

  /// Find compounds similar to the one with the given CID.
  /// The threshold parameter (0-100) determines how similar the compounds should be.
  Future<void> findSimilarCompounds(int cid, {int threshold = 90}) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      print('Finding similar compounds for CID: $cid');

      // Use the base provider's method to fetch similar compound CIDs
      final similarCids =
          await fetchSimilarCompounds(cid, threshold: threshold);
      print('Found ${similarCids.length} similar compounds');

      if (similarCids.isEmpty) {
        _relatedCompounds = [];
        setLoading(false);
        notifyListeners();
        return;
      }

      // Limit to 10 compounds for performance reasons
      final limitedCids = similarCids.take(10).toList();

      // Fetch detailed properties for these compounds
      final properties = await fetchBasicProperties(limitedCids);

      // Create RelatedCompound objects with similarity data
      _relatedCompounds = properties.map((prop) {
        // Add estimated similarity score based on position in results
        final index = properties.indexOf(prop);
        final similarityScore = 100.0 - (index * (10.0 / properties.length));

        return RelatedCompound(
          cid: prop['CID'] ?? 0,
          title: prop['Title'] ?? '',
          molecularFormula: prop['MolecularFormula'] ?? '',
          molecularWeight:
              double.tryParse(prop['MolecularWeight']?.toString() ?? '0') ??
                  0.0,
          smiles: prop['CanonicalSMILES'] ?? '',
          similarityScore: similarityScore,
          pubChemUrl:
              'https://pubchem.ncbi.nlm.nih.gov/compound/${prop['CID']}',
        );
      }).toList();
    } catch (e) {
      print('Error finding similar compounds: $e');
      setError(e.toString());
      _relatedCompounds = [];
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Fetch patents related to the compound with the given CID.
  Future<void> fetchCompoundPatents(int cid) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      print('Fetching patents for CID: $cid');

      // Try a different approach to get patents since xrefs might not work for all compounds
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON?heading=Patent+Information');

      final response = await http.get(url);
      print('Patent API response status: ${response.statusCode}');

      List<Map<String, dynamic>> patentsData = [];

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> sections = data['Record']?['Section'] ?? [];

        // Look for Patent Information section
        for (var section in sections) {
          if (section['TOCHeading'] == 'Patent Information') {
            final sectionData = section['Section'] ?? [];
            for (var subSection in sectionData) {
              final information = subSection['Information'] ?? [];
              for (var info in information) {
                if (info['ReferenceNumber'] != null) {
                  patentsData.add({
                    'id': info['ReferenceNumber'],
                    'url':
                        'https://patents.google.com/patent/${info['ReferenceNumber']}',
                  });
                }
              }
            }
          }
        }

        print('Found ${patentsData.length} patents from PUG View');
      }

      // If no patents found in PUG View, fall back to xrefs method
      if (patentsData.isEmpty) {
        patentsData = await fetchPatents(cid);
        print('Found ${patentsData.length} patents from xrefs');
      }

      // Convert to PatentInfo objects
      _patents =
          patentsData.map((patent) => PatentInfo.fromJson(patent)).toList();
    } catch (e) {
      print('Error fetching patents: $e');
      setError(e.toString());
      _patents = [];
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  /// Fetch assay data for the compound with the given CID.
  Future<void> fetchCompoundAssays(int cid) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      print('Fetching assays for CID: $cid');

      // Use the base provider's method to fetch assay summaries
      final assayData = await fetchAssaySummary(cid);

      // Convert to AssaySummary objects
      _assays = assayData.map((assay) => AssaySummary.fromJson(assay)).toList();
    } catch (e) {
      print('Error fetching assays: $e');
      setError(e.toString());
      _assays = [];
    } finally {
      setLoading(false);
      notifyListeners();
    }
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
