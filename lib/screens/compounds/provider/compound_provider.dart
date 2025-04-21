import 'dart:async';

import '../model/compound.dart';
import '../../../providers/base_pubchem_provider.dart';
import '../../../providers/pubchem_impl_mixin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml/xml.dart';
import 'dart:io'; // Import for SocketException
import '../../../utils/error_handler.dart'; // Import ErrorHandler

class CompoundProvider extends BasePubChemProvider with PubChemImplMixin {
  List<Compound> _compounds = [];
  Compound? _selectedCompound;

  List<Compound> get compounds => _compounds;
  Compound? get selectedCompound => _selectedCompound;

  Future<void> searchCompounds(String query) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      print('Starting compound search for query: $query');

      // Use base provider's method to fetch CIDs
      final cids = await fetchCids(query);
      print('Found ${cids.length} CIDs: $cids');

      // Use base provider's method to fetch properties
      final properties = await fetchBasicProperties(cids);
      print('Found ${properties.length} compounds with properties');

      _compounds = properties.map((e) {
        print('Processing compound data: $e');
        return Compound.fromJson(e);
      }).toList();

      print('Successfully created ${_compounds.length} compounds');
    } catch (e, stackTrace) {
      print('Error during compound search: $e');
      print('Stack trace: $stackTrace');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }
    } finally {
      setLoading(false);
    }
  }

  Future<Compound?> fetchCompoundByCid(int cid) async {
    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('Directly fetching compound with CID: $cid');

      // Fetch basic properties directly
      final properties = await fetchBasicProperties([cid]);
      if (properties.isEmpty) {
        setError('Could not find compound with CID $cid');
        return null;
      }

      // Create a basic compound object
      Compound compound = Compound.fromJson(properties[0]);

      // Set as selected compound
      _selectedCompound = compound;
      notifyListeners();

      // Fetch complete details in the background
      fetchCompoundDetails(cid).then((_) {
        // Update cache with the fully detailed compound
        if (_selectedCompound != null) {
          _compoundCache[cid] = _selectedCompound!;
        }
      });

      return compound;
    } catch (e, stackTrace) {
      print('Error fetching compound by CID: $e');
      print('Stack trace: $stackTrace');

      // Use ErrorHandler for a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>> fetchPugViewData(int cid,
      {String? heading}) async {
    try {
      final url = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON${heading != null ? '?heading=$heading' : ''}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch PUG View data: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      print('Error fetching PUG View data: $e');
      rethrow;
    }
  }

  Future<Compound?> fetchCompoundDetails(int cid) async {
    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('\n=== Starting fetchCompoundDetails for CID: $cid ===');

      // Parallel API requests for better performance
      final detailedInfoFuture = fetchDetailedInfo(cid);
      final descriptionFuture = http.get(Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/description/XML'));
      final pugViewFuture = fetchPugViewData(cid);
      final propertiesFuture = http.get(Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/property/MeltingPoint,BoilingPoint,FlashPoint,Density,Solubility,LogP,VaporPressure/JSON'));
      final synonymsFuture = fetchSynonyms(cid);

      // Wait for all the parallel requests to complete
      final results = await Future.wait([
        detailedInfoFuture,
        descriptionFuture,
        pugViewFuture,
        propertiesFuture,
      ]);

      final data = results[0] as Map<String, dynamic>;
      final descriptionResponse = results[1] as http.Response;
      final pugViewData = results[2] as Map<String, dynamic>;
      final propertiesResponse = results[3] as http.Response;

      // Process description data
      String description = '';
      String descriptionSource = '';
      String descriptionUrl = '';

      if (descriptionResponse.statusCode == 200) {
        final document = XmlDocument.parse(descriptionResponse.body);
        final descriptionElement =
            document.findAllElements('Description').firstOrNull;
        final sourceElement =
            document.findAllElements('DescriptionSourceName').firstOrNull;
        final urlElement =
            document.findAllElements('DescriptionURL').firstOrNull;

        description = descriptionElement?.text ?? '';
        descriptionSource = sourceElement?.text ?? '';
        descriptionUrl = urlElement?.text ?? '';
      }

      // Process properties data
      Map<String, dynamic> chemicalProperties = {};
      if (propertiesResponse.statusCode == 200) {
        final propertiesData = json.decode(propertiesResponse.body);
        if (propertiesData['PropertyTable']?['Properties'] != null) {
          chemicalProperties = propertiesData['PropertyTable']['Properties'][0];
        }
      }

      // Extract properties from compound data
      final compoundData = data['compound']['PC_Compounds']?[0];
      final propertiesData = compoundData?['props'] ?? [];
      final properties = _extractProperties(propertiesData);

      // Extract title from PUG View data
      String title = pugViewData['Record']?['RecordTitle'] ?? '';

      // If no title found in PUG View, use properties title
      if (title.isEmpty) {
        title = properties['Title'] ?? properties['IUPACName'] ?? '';
      }

      // Get synonyms with error handling (using the future we started earlier)
      List<String> synonyms = [];
      try {
        synonyms = await synonymsFuture;
      } catch (e) {
        // Log error but continue processing - synonyms aren't critical
        print('Warning: Error fetching synonyms: $e');
        synonyms = [];
      }

      // Create the compound object
      _selectedCompound = Compound(
        cid: cid,
        title: title,
        molecularFormula: properties['MolecularFormula'] ?? '',
        molecularWeight: double.tryParse(
                properties['Molecular Weight']?.toString() ?? '0') ??
            0.0,
        smiles: properties['CanonicalSMILES'] ?? '',
        xLogP: double.tryParse(properties['XLogP']?.toString() ?? '0') ?? 0.0,
        hBondDonorCount:
            int.tryParse(properties['HBondDonorCount']?.toString() ?? '0') ?? 0,
        hBondAcceptorCount:
            int.tryParse(properties['HBondAcceptorCount']?.toString() ?? '0') ??
                0,
        rotatableBondCount:
            int.tryParse(properties['RotatableBondCount']?.toString() ?? '0') ??
                0,
        heavyAtomCount:
            int.tryParse(properties['HeavyAtomCount']?.toString() ?? '0') ?? 0,
        atomStereoCount:
            int.tryParse(properties['AtomStereoCount']?.toString() ?? '0') ?? 0,
        bondStereoCount:
            int.tryParse(properties['BondStereoCount']?.toString() ?? '0') ?? 0,
        complexity:
            double.tryParse(properties['Complexity']?.toString() ?? '0') ?? 0.0,
        iupacName: properties['IUPACName'] ?? '',
        description: description,
        descriptionSource: descriptionSource,
        descriptionUrl: descriptionUrl,
        synonyms: synonyms,
        physicalProperties: {
          ...properties,
          'MeltingPoint': chemicalProperties['MeltingPoint'],
          'BoilingPoint': chemicalProperties['BoilingPoint'],
          'FlashPoint': chemicalProperties['FlashPoint'],
          'Density': chemicalProperties['Density'],
          'Solubility': chemicalProperties['Solubility'],
          'LogP': chemicalProperties['LogP'],
          'VaporPressure': chemicalProperties['VaporPressure'],
        },
        safetyData: {}, // Empty safety data
        biologicalData: {}, // Empty biological data
        pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid',
        monoisotopicMass:
            double.tryParse(properties['Weight']?.toString() ?? '0') ?? 0.0,
        tpsa: double.tryParse(properties['TPSA']?.toString() ?? '0') ?? 0.0,
        charge: int.tryParse(properties['Charge']?.toString() ?? '0') ?? 0,
        isotopeAtomCount:
            int.tryParse(properties['IsotopeAtomCount']?.toString() ?? '0') ??
                0,
        definedAtomStereoCount: int.tryParse(
                properties['DefinedAtomStereoCount']?.toString() ?? '0') ??
            0,
        undefinedAtomStereoCount: int.tryParse(
                properties['UndefinedAtomStereoCount']?.toString() ?? '0') ??
            0,
        definedBondStereoCount: int.tryParse(
                properties['DefinedBondStereoCount']?.toString() ?? '0') ??
            0,
        undefinedBondStereoCount: int.tryParse(
                properties['UndefinedBondStereoCount']?.toString() ?? '0') ??
            0,
        covalentUnitCount:
            int.tryParse(properties['CovalentUnitCount']?.toString() ?? '0') ??
                0,
        patentCount:
            int.tryParse(properties['PatentCount']?.toString() ?? '0') ?? 0,
        patentFamilyCount:
            int.tryParse(properties['PatentFamilyCount']?.toString() ?? '0') ??
                0,
        annotationTypes: List<String>.from(properties['AnnotationTypes'] ?? []),
        annotationTypeCount: int.tryParse(
                properties['AnnotationTypeCount']?.toString() ?? '0') ??
            0,
        sourceCategories:
            List<String>.from(properties['SourceCategories'] ?? []),
        literatureCount:
            int.tryParse(properties['LiteratureCount']?.toString() ?? '0') ?? 0,
        inchi: properties['InChI'] ?? '',
        inchiKey: properties['InChIKey'] ?? '',
      );

      // Cache the compound for future use
      _compoundCache[cid] = _selectedCompound!;

      notifyListeners();
      return _selectedCompound;
    } catch (e) {
      print('Error in fetchCompoundDetails: $e');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Add a caching mechanism for compound CIDs
  final Map<int, Compound> _compoundCache = {};

  // Improved method to get a compound, ensuring fresh data
  Future<Compound?> getCompound(int cid) async {
    try {
      // Clear existing compound to avoid showing stale data
      clearSelectedCompound();

      // Set loading state
      setLoading(true);
      notifyListeners();

      // If compound exists in cache and is not stale, use it
      if (_compoundCache.containsKey(cid)) {
        print("Using cached compound data for CID: $cid");
        _selectedCompound = _compoundCache[cid];
        notifyListeners();

        // Return the cached compound immediately
        return _selectedCompound;
      }

      // Otherwise fetch full details directly
      return await fetchCompoundDetails(cid);
    } catch (e) {
      print('Error in getCompound: $e');
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  void clearSelectedCompound() {
    _selectedCompound = null;
    notifyListeners();
  }

  void clearCompounds() {
    _compounds = [];
    notifyListeners();
  }

  Map<String, dynamic> _extractProperties(List<dynamic> props) {
    final properties = <String, dynamic>{};

    for (var prop in props) {
      final label = prop['urn']?['label']?.toString() ?? '';
      final name = prop['urn']?['name']?.toString() ?? '';
      final value = prop['value'];

      if (value == null) continue;

      // Handle different value types
      if (value['sval'] != null) {
        properties[label] = value['sval'];
      } else if (value['ival'] != null) {
        properties[label] = value['ival'];
      } else if (value['fval'] != null) {
        properties[label] = value['fval'];
      } else if (value['binary'] != null) {
        properties[label] = value['binary'];
      } else if (value['slist'] != null) {
        properties[label] = List<String>.from(value['slist']);
      }

      // Map specific properties to their correct names
      if (label == 'Count' && name == 'Hydrogen Bond Donor') {
        properties['HBondDonorCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Hydrogen Bond Acceptor') {
        properties['HBondAcceptorCount'] = value['ival'];
      } else if (label == 'Log P') {
        properties['XLogP'] = value['fval'];
      } else if (label == 'Mass') {
        properties['MolecularWeight'] = value['fval'];
        properties['ExactMass'] = value['fval'];
        properties['MonoisotopicWeight'] = value['fval'];
      } else if (label == 'Topological') {
        properties['TPSA'] = value['fval'];
      } else if (label == 'IUPAC Name') {
        properties['IUPACName'] = value['sval'];
        properties['Title'] = value['sval'];
      } else if (label == 'Molecular Formula') {
        properties['MolecularFormula'] = value['sval'];
      } else if (label == 'SMILES') {
        properties['CanonicalSMILES'] = value['sval'];
      } else if (label == 'Compound Complexity') {
        properties['Complexity'] = value['fval'];
      } else if (label == 'Charge') {
        properties['Charge'] = value['ival'];
      } else if (label == 'Count' && name == 'Rotatable Bond') {
        properties['RotatableBondCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Heavy Atom') {
        properties['HeavyAtomCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Atom Stereo') {
        properties['AtomStereoCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Bond Stereo') {
        properties['BondStereoCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Defined Atom Stereo') {
        properties['DefinedAtomStereoCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Undefined Atom Stereo') {
        properties['UndefinedAtomStereoCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Defined Bond Stereo') {
        properties['DefinedBondStereoCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Undefined Bond Stereo') {
        properties['UndefinedBondStereoCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Covalent Unit') {
        properties['CovalentUnitCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Isotope Atom') {
        properties['IsotopeAtomCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Patent') {
        properties['PatentCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Patent Family') {
        properties['PatentFamilyCount'] = value['ival'];
      } else if (label == 'Count' && name == 'Literature') {
        properties['LiteratureCount'] = value['ival'];
      } else if (label == 'Annotation Type') {
        properties['AnnotationTypes'] = value['slist'];
        properties['AnnotationTypeCount'] = value['slist']?.length ?? 0;
      } else if (label == 'Source Category') {
        properties['SourceCategories'] = value['slist'];
      }
    }

    print('Extracted properties: $properties');
    return properties;
  }

  Future<List<Compound>> fetchCompoundsByCriteria({
    String? heading,
    String? value,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('Fetching compounds by criteria: $heading = $value');

      final url = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/annotations/heading/$heading/JSON?page=$page&heading_type=Compound${value != null ? '&value=$value' : ''}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch compounds: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final annotations = data['Annotations'] ?? [];

      // Extract CIDs from annotations
      final cids = annotations
          .map<String>((annotation) {
            return annotation['CID']?.toString() ?? '';
          })
          .where((cid) => cid.isNotEmpty)
          .toList();

      // Fetch details for each compound
      final compounds = <Compound>[];
      for (final cid in cids.take(limit)) {
        try {
          final compoundData = await fetchDetailedInfo(int.parse(cid));
          final properties = _extractProperties(
              compoundData['compound']['PC_Compounds']?[0]['props'] ?? []);

          compounds.add(Compound.fromJson({
            ...properties,
            'CID': int.parse(cid),
          }));
        } catch (e) {
          print('Error fetching compound $cid: $e');
          // Continue with next compound
        }
      }

      _compounds = compounds;
      notifyListeners();
      return compounds;
    } catch (e) {
      print('Error in fetchCompoundsByCriteria: $e');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }
      return [];
    } finally {
      setLoading(false);
    }
  }

  // Add a method to get available headings
  Future<List<String>> getAvailableHeadings() async {
    try {
      final url = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/annotations/headings/JSON',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch headings: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<dynamic> headings =
          data['InformationList']?['Information'] ?? [];

      return headings
          .map((heading) => heading['Name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      print('Error getting headings: $e');
      return [];
    }
  }

  // Override the fetchSynonyms method in the base class to add better error handling
  @override
  Future<List<String>> fetchSynonyms(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON');

      // Add timeout to prevent long waits
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Network timeout while fetching synonyms');
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch synonyms: HTTP Status ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        print('Warning: Empty response body when fetching synonyms');
        return [];
      }

      try {
        final data = json.decode(response.body);
        final synonymsList = data['InformationList']?['Information'] ?? [];

        if (synonymsList.isEmpty) {
          print('No synonyms found for compound $cid');
          return [];
        }

        if (synonymsList.isNotEmpty && synonymsList[0]['Synonym'] != null) {
          // Limit to maximum 50 synonyms to improve performance
          final allSynonyms = List<String>.from(synonymsList[0]['Synonym']);
          return allSynonyms.take(50).toList();
        }

        return [];
      } catch (e) {
        print('Error parsing synonym data: $e');
        return [];
      }
    } catch (e) {
      // If it's a network error, provide a clearer message but don't throw
      if (e is SocketException) {
        print(
            'Network error while fetching synonyms: ${ErrorHandler.getErrorMessage(e)}');
      } else if (e.toString().contains('timeout')) {
        print('Timeout while fetching synonyms: $e');
      } else {
        print('Error fetching synonyms: $e');
      }

      // Return empty list instead of throwing to prevent entire compound loading from failing
      return [];
    }
  }
}
