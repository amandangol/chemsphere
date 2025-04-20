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

  // Cache for compound details to avoid redundant API calls
  final Map<int, Compound> _compoundCache = {};

  // Track whether a fetch operation is in progress for a given CID
  final Map<int, bool> _fetchInProgress = {};

  // Add a debug flag to log API responses
  final bool _debugApiResponses = true;

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

  Future<Map<String, dynamic>> fetchPugViewData(int cid,
      {String? heading}) async {
    try {
      final url = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON${heading != null ? '?heading=$heading' : ''}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('PUG View data request timed out');
        },
      );

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

  Future<void> fetchCompoundDetails(int cid) async {
    // If a fetch is already in progress for this CID, wait for it to complete
    if (_fetchInProgress[cid] == true) {
      print('Fetch already in progress for CID: $cid - waiting for completion');
      // Wait a bit and check the cache
      await Future.delayed(const Duration(milliseconds: 500));
      if (_compoundCache.containsKey(cid)) {
        _selectedCompound = _compoundCache[cid];
        notifyListeners();
        return;
      }
      return;
    }

    // Check if we already have the compound cached
    if (_compoundCache.containsKey(cid)) {
      print('Using cached compound data for CID: $cid');
      _selectedCompound = _compoundCache[cid];
      notifyListeners();
      return;
    }

    _fetchInProgress[cid] = true;

    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('\n=== Starting fetchCompoundDetails for CID: $cid ===');

      // Fetch basic compound data
      print('Fetching detailed info...');
      Map<String, dynamic> data;
      try {
        data = await fetchDetailedInfo(cid);
        print('Detailed info response received successfully');
      } catch (e) {
        print('Error fetching detailed info: $e');
        // Create a minimal valid structure
        data = {
          'compound': {
            'PC_Compounds': [
              {'props': []}
            ]
          }
        };
      }

      // Fetch description data from XML endpoint
      print('Fetching description data...');
      String description = '';
      String descriptionSource = '';
      String descriptionUrl = '';

      try {
        final descriptionResponse = await http
            .get(
              Uri.parse(
                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/description/XML'),
            )
            .timeout(const Duration(seconds: 10));

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

          print('Description: $description');
          print('Description Source: $descriptionSource');
          print('Description URL: $descriptionUrl');
        }
      } catch (e) {
        print('Non-critical error fetching description: $e');
        // We'll continue with an empty description
      }

      // Use default descriptions when PubChem data is not available
      if (description.isEmpty) {
        description = _getDefaultDescription(cid);
        descriptionSource = 'Generated Description';
      }

      // Fetch additional data from PUG View
      Map<String, dynamic> pugViewData = {};
      try {
        print('Fetching PUG View data...');
        pugViewData = await fetchPugViewData(cid);
        print('PUG View response received');
      } catch (e) {
        print('Non-critical error fetching PUG View data: $e');
        // Continue without PUG View data
        pugViewData = {};
      }

      // Fetch chemical properties
      Map<String, dynamic> chemicalProperties = {};
      try {
        print('Fetching chemical properties...');
        final propertiesResponse = await http
            .get(
              Uri.parse(
                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/property/MeltingPoint,BoilingPoint,FlashPoint,Density,Solubility,LogP,VaporPressure/JSON'),
            )
            .timeout(const Duration(seconds: 10));

        if (propertiesResponse.statusCode == 200) {
          final propertiesData = json.decode(propertiesResponse.body);
          if (propertiesData['PropertyTable']?['Properties'] != null) {
            chemicalProperties =
                propertiesData['PropertyTable']['Properties'][0];
          }
        }
      } catch (e) {
        print('Non-critical error fetching chemical properties: $e');
        // Continue without these properties
      }

      // Extract properties from compound data
      final compoundData = data['compound']['PC_Compounds']?[0];
      final propertiesData = compoundData?['props'] ?? [];
      print('Properties data length: ${propertiesData.length}');
      final properties = _extractProperties(propertiesData);

      // Extract title from PUG View data
      String title = pugViewData['Record']?['RecordTitle'] ?? '';
      print('Title from PUG View: $title');

      // If no title found in PUG View, use properties title
      if (title.isEmpty) {
        title = properties['Title'] ?? properties['IUPACName'] ?? '';
        print('Title from properties: $title');
      }

      // If title is still empty, use a default based on CID
      if (title.isEmpty) {
        title = 'Compound $cid';
        print('Using default title: $title');
      }

      // Use base provider's method to fetch synonyms with proper error handling
      List<String> synonyms = [];
      try {
        print('Fetching synonyms...');
        synonyms = await fetchSynonyms(cid);
        print('Synonyms fetched: ${synonyms.length}');
      } catch (e) {
        // Log error but continue processing - synonyms aren't critical
        print('Warning: Error fetching synonyms: $e');
        // Don't throw the error, just use an empty list
        synonyms = [];
      }

      // Add fallback data for common pollutants
      _addFallbackData(cid, properties, chemicalProperties);

      // Create the compound object with empty safety and biological data
      final compound = Compound(
        cid: cid,
        title: title,
        molecularFormula: properties['MolecularFormula'] ?? '',
        molecularWeight: properties['Molecular Weight'] is num
            ? properties['Molecular Weight']
            : double.tryParse(
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

      // Save to cache and update selected compound
      _compoundCache[cid] = compound;
      _selectedCompound = compound;

      print('\n=== Created Compound Object ===');
      print('Title: ${_selectedCompound?.title}');
      print('Molecular Formula: ${_selectedCompound?.molecularFormula}');
      print('Molecular Weight: ${_selectedCompound?.molecularWeight}');
    } catch (e) {
      print('Error in fetchCompoundDetails: $e');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else if (e is TimeoutException) {
        setError(
            'Request timed out. Please check your internet connection and try again.');
      } else {
        setError(e.toString());
      }

      // Create a minimal compound with fallback data
      _createFallbackCompound(cid);
    } finally {
      setLoading(false);
      _fetchInProgress[cid] = false; // Mark fetch as completed
    }
  }

  // Create a fallback compound if the normal fetch fails
  void _createFallbackCompound(int cid) {
    // Create a minimal compound with fallback data to avoid UI errors
    final properties = <String, dynamic>{};
    _addFallbackData(cid, properties, {});

    final compound = Compound(
      cid: cid,
      title: 'Compound $cid',
      molecularFormula: properties['MolecularFormula'] ?? '',
      molecularWeight: 0.0,
      description: _getDefaultDescription(cid),
      descriptionSource: 'Generated Description',
      physicalProperties: properties,
      synonyms: [],
      safetyData: {},
      biologicalData: {},
      pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid',
      // Default values for all other properties
      smiles: '',
      xLogP: 0.0,
      hBondDonorCount: 0,
      hBondAcceptorCount: 0,
      rotatableBondCount: 0,
      heavyAtomCount: 0,
      atomStereoCount: 0,
      bondStereoCount: 0,
      complexity: 0.0,
      iupacName: '',
      descriptionUrl: '',
      monoisotopicMass: 0.0,
      tpsa: 0.0,
      charge: 0,
      isotopeAtomCount: 0,
      definedAtomStereoCount: 0,
      undefinedAtomStereoCount: 0,
      definedBondStereoCount: 0,
      undefinedBondStereoCount: 0,
      covalentUnitCount: 0,
      patentCount: 0,
      patentFamilyCount: 0,
      annotationTypes: [],
      annotationTypeCount: 0,
      sourceCategories: [],
      literatureCount: 0,
      inchi: '',
      inchiKey: '',
    );

    // Save to cache and update selected compound
    _compoundCache[cid] = compound;
    _selectedCompound = compound;
  }

  void clearSelectedCompound() {
    _selectedCompound = null;
    notifyListeners();
  }

  void clearCompounds() {
    _compounds = [];
    notifyListeners();
  }

  void clearCache() {
    _compoundCache.clear();
    _fetchInProgress.clear();
    notifyListeners();
  }

  bool isCompoundCached(int cid) {
    return _compoundCache.containsKey(cid);
  }

  // Utility function to get min of two numbers
  int min(int a, int b) {
    return a < b ? a : b;
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

  // Add fallback data for common pollutants when API data is incomplete
  void _addFallbackData(int cid, Map<String, dynamic> properties,
      Map<String, dynamic> chemicalProperties) {
    switch (cid) {
      case 44778645: // PM2.5
        if (properties['MolecularFormula'] == null ||
            properties['MolecularFormula'].isEmpty) {
          properties['MolecularFormula'] = 'Various';
        }
        if (properties['Molecular Weight'] == null ||
            properties['Molecular Weight'] == 0) {
          properties['Molecular Weight'] = 'Varies';
        }
        break;
      case 518232: // PM10
        if (properties['MolecularFormula'] == null ||
            properties['MolecularFormula'].isEmpty) {
          properties['MolecularFormula'] = 'Various';
        }
        if (properties['Molecular Weight'] == null ||
            properties['Molecular Weight'] == 0) {
          properties['Molecular Weight'] = 'Varies';
        }
        break;
      case 24823: // O3 (Ozone)
        if (properties['MolecularFormula'] == null ||
            properties['MolecularFormula'].isEmpty) {
          properties['MolecularFormula'] = 'O₃';
        }
        if (properties['Molecular Weight'] == null ||
            properties['Molecular Weight'] == 0) {
          properties['Molecular Weight'] = 48.00;
        }
        break;
      case 3032552: // NO2
        if (properties['MolecularFormula'] == null ||
            properties['MolecularFormula'].isEmpty) {
          properties['MolecularFormula'] = 'NO₂';
        }
        if (properties['Molecular Weight'] == null ||
            properties['Molecular Weight'] == 0) {
          properties['Molecular Weight'] = 46.01;
        }
        break;
      case 1119: // SO2
        if (properties['MolecularFormula'] == null ||
            properties['MolecularFormula'].isEmpty) {
          properties['MolecularFormula'] = 'SO₂';
        }
        if (properties['Molecular Weight'] == null ||
            properties['Molecular Weight'] == 0) {
          properties['Molecular Weight'] = 64.07;
        }
        break;
      case 281: // CO
        if (properties['MolecularFormula'] == null ||
            properties['MolecularFormula'].isEmpty) {
          properties['MolecularFormula'] = 'CO';
        }
        if (properties['Molecular Weight'] == null ||
            properties['Molecular Weight'] == 0) {
          properties['Molecular Weight'] = 28.01;
        }
        break;
    }
  }

  // Get default description for common pollutants when PubChem description is unavailable
  String _getDefaultDescription(int cid) {
    switch (cid) {
      case 44778645: // PM2.5
        return 'Fine particulate matter (PM2.5) refers to tiny particles or droplets in the air that are 2.5 micrometers or less in width. They are primarily produced from combustion processes and can penetrate deep into the lungs and even enter the bloodstream, causing respiratory and cardiovascular health issues.';
      case 518232: // PM10
        return 'Particulate matter 10 (PM10) refers to inhalable particles with diameters that are generally 10 micrometers and smaller. These particles come from sources such as dust, pollen, mold, and various combustion processes. PM10 can enter the lungs and potentially cause health problems.';
      case 24823: // O3 (Ozone)
        return 'Ozone (O₃) is a gas composed of three oxygen atoms. At ground level, ozone is created by chemical reactions between oxides of nitrogen and volatile organic compounds in the presence of sunlight. Breathing ozone can trigger health problems including chest pain, coughing, throat irritation, and congestion.';
      case 3032552: // NO2
        return 'Nitrogen dioxide (NO₂) is a gaseous air pollutant composed of nitrogen and oxygen. It forms when fossil fuels such as coal, oil, gas, or diesel are burned at high temperatures. NO₂ can cause respiratory problems and contribute to the formation of other pollutants including ground-level ozone and particulate matter.';
      case 1119: // SO2
        return 'Sulfur dioxide (SO₂) is a colorless, reactive gas with a strong odor. It is produced from burning fuels containing sulfur, such as coal and oil, and during metal extraction from ore. SO₂ can harm the human respiratory system and make breathing difficult, particularly for people with asthma.';
      case 281: // CO
        return 'Carbon monoxide (CO) is a colorless, odorless gas that is formed when carbon in fuel is not burned completely. It is a poisonous gas that can cause sudden illness and death. CO interferes with the delivery of oxygen throughout the body, and exposure to high levels can cause headache, dizziness, confusion, unconsciousness, and death.';
      default:
        return '';
    }
  }

  Future<Map<String, dynamic>> fetchDetailedInfo(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/record/JSON?record_type=2d');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('PubChem detailed info request timed out');
        },
      );

      if (response.statusCode != 200) {
        if (_debugApiResponses) {
          print('Error response from PubChem API: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        throw Exception(
            'Failed to fetch compound details: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (_debugApiResponses) {
        print('Received detailed info response for CID: $cid');
        print(
            'PC_Compounds present: ${data['compound']?['PC_Compounds'] != null}');
        print(
            'PC_Compounds length: ${data['compound']?['PC_Compounds']?.length ?? 0}');
      }

      // Check if the response has the expected structure
      if (data['compound'] == null ||
          data['compound']['PC_Compounds'] == null ||
          data['compound']['PC_Compounds'].isEmpty) {
        print(
            'Invalid response format from PubChem - missing compound data for CID: $cid');
        // Return a minimal valid structure to avoid crashes
        return {
          'compound': {
            'PC_Compounds': [
              {'props': []}
            ]
          }
        };
      }

      return data;
    } catch (e) {
      print('Error in fetchDetailedInfo for CID $cid: $e');
      // Return a minimal valid structure to avoid crashes
      return {
        'compound': {
          'PC_Compounds': [
            {'props': []}
          ]
        }
      };
    }
  }
}
