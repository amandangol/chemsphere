import '../model/drug.dart';
import '../../../providers/base_pubchem_provider.dart';
import '../../../providers/pubchem_impl_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:io'; // Import for SocketException
import 'dart:async'; // Import for TimeoutException
import '../../../utils/error_handler.dart'; // Import ErrorHandler

class DrugProvider extends BasePubChemProvider with PubChemImplMixin {
  List<Drug> _drugs = [];
  Drug? _selectedDrug;

  List<Drug> get drugs => _drugs;
  Drug? get selectedDrug => _selectedDrug;

  String _lastQuery = '';
  bool _hasSearched = false;
  String get lastQuery => _lastQuery;
  bool get hasSearched => _hasSearched;

  final Map<int, Drug> _drugCache = {};

  Future<void> searchDrugs(String query) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      // Store the query for potential retry
      _lastQuery = query;
      _hasSearched = true;

      // Use base provider's method to fetch CIDs
      final cids = await fetchCids(query);

      // Use base provider's method to fetch properties
      final properties = await fetchBasicProperties(cids, limit: 5);

      _drugs = properties.map((e) {
        final json = Map<String, dynamic>.from(e);
        return Drug(
          name: json['Title'] ?? '',
          cid: json['CID'] ?? 0,
          title: json['Title'] ?? '',
          molecularFormula: json['MolecularFormula'] ?? '',
          molecularWeight:
              double.tryParse(json['MolecularWeight']?.toString() ?? '0') ??
                  0.0,
          smiles: json['CanonicalSMILES'] ?? '',
          xLogP: double.tryParse(json['XLogP']?.toString() ?? '0') ?? 0.0,
          hBondDonorCount:
              int.tryParse(json['HBondDonorCount']?.toString() ?? '0') ?? 0,
          hBondAcceptorCount:
              int.tryParse(json['HBondAcceptorCount']?.toString() ?? '0') ?? 0,
          rotatableBondCount:
              int.tryParse(json['RotatableBondCount']?.toString() ?? '0') ?? 0,
          heavyAtomCount:
              int.tryParse(json['HeavyAtomCount']?.toString() ?? '0') ?? 0,
          atomStereoCount:
              int.tryParse(json['AtomStereoCount']?.toString() ?? '0') ?? 0,
          bondStereoCount:
              int.tryParse(json['BondStereoCount']?.toString() ?? '0') ?? 0,
          complexity:
              double.tryParse(json['Complexity']?.toString() ?? '0') ?? 0.0,
          iupacName: json['IUPACName'] ?? '',
          description: '',
          descriptionSource: '',
          descriptionUrl: '',
          synonyms: [],
          physicalProperties:
              Map<String, dynamic>.from(json['PhysicalProperties'] ?? {}),
          pubChemUrl:
              'https://pubchem.ncbi.nlm.nih.gov/compound/${json['CID']}',
          indication: '',
          mechanismOfAction: '',
          toxicity: '',
          pharmacology: '',
          metabolism: '',
          absorption: '',
          halfLife: '',
          proteinBinding: '',
          routeOfElimination: '',
          volumeOfDistribution: '',
          clearance: '',
        );
      }).toList();
    } catch (e) {
      print('Error in searchDrugs: $e');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }

      _drugs = []; // Clear any partial results
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // New method to fetch a drug by CID with basic properties - fast initial load
  Future<Drug?> fetchDrugByCid(int cid) async {
    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('Directly fetching drug with CID: $cid');

      // If drug exists in cache, use it
      if (_drugCache.containsKey(cid)) {
        print("Using cached drug data for CID: $cid");
        _selectedDrug = _drugCache[cid];
        notifyListeners();
        setLoading(false);
        return _selectedDrug;
      }

      // Fetch basic properties directly for immediate display
      final properties = await fetchBasicProperties([cid]);
      if (properties.isEmpty) {
        setError('Could not find drug with CID $cid');
        setLoading(false);
        return null;
      }

      // Create a basic drug object
      final json = Map<String, dynamic>.from(properties[0]);
      final drug = Drug(
        name: json['Title'] ?? '',
        cid: json['CID'] ?? 0,
        title: json['Title'] ?? '',
        molecularFormula: json['MolecularFormula'] ?? '',
        molecularWeight:
            double.tryParse(json['MolecularWeight']?.toString() ?? '0') ?? 0.0,
        smiles: json['CanonicalSMILES'] ?? '',
        xLogP: double.tryParse(json['XLogP']?.toString() ?? '0') ?? 0.0,
        hBondDonorCount:
            int.tryParse(json['HBondDonorCount']?.toString() ?? '0') ?? 0,
        hBondAcceptorCount:
            int.tryParse(json['HBondAcceptorCount']?.toString() ?? '0') ?? 0,
        rotatableBondCount:
            int.tryParse(json['RotatableBondCount']?.toString() ?? '0') ?? 0,
        heavyAtomCount:
            int.tryParse(json['HeavyAtomCount']?.toString() ?? '0') ?? 0,
        atomStereoCount:
            int.tryParse(json['AtomStereoCount']?.toString() ?? '0') ?? 0,
        bondStereoCount:
            int.tryParse(json['BondStereoCount']?.toString() ?? '0') ?? 0,
        complexity:
            double.tryParse(json['Complexity']?.toString() ?? '0') ?? 0.0,
        iupacName: json['IUPACName'] ?? '',
        description: '',
        descriptionSource: '',
        descriptionUrl: '',
        synonyms: [],
        physicalProperties:
            Map<String, dynamic>.from(json['PhysicalProperties'] ?? {}),
        pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid',
        indication: '',
        mechanismOfAction: '',
        toxicity: '',
        pharmacology: '',
        metabolism: '',
        absorption: '',
        halfLife: '',
        proteinBinding: '',
        routeOfElimination: '',
        volumeOfDistribution: '',
        clearance: '',
      );

      // Set as selected drug
      _selectedDrug = drug;
      notifyListeners();

      // Fetch complete details in the background
      setLoading(false);
      fetchDrugDetails(cid).then((_) {
        // Update cache with the fully detailed drug
        if (_selectedDrug != null) {
          _drugCache[cid] = _selectedDrug!;
        }
      });

      return drug;
    } catch (e) {
      print('Error fetching drug by CID: $e');
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

  // Method to get a drug, ensuring fresh data, like the compound version
  Future<Drug?> getDrug(int cid) async {
    try {
      // Clear existing drug to avoid showing stale data
      clearSelectedDrug();

      // Set loading state
      setLoading(true);
      notifyListeners();

      // If drug exists in cache and is not stale, use it
      if (_drugCache.containsKey(cid)) {
        print("Using cached drug data for CID: $cid");
        _selectedDrug = _drugCache[cid];
        notifyListeners();

        // Return the cached drug immediately
        return _selectedDrug;
      }

      // First, fetch basic data for immediate display
      final basicDrug = await fetchDrugByCid(cid);
      if (basicDrug == null) {
        return null;
      }

      // Full details will be loaded in the background by fetchDrugByCid
      return basicDrug;
    } catch (e) {
      print('Error in getDrug: $e');
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

  // Optimized fetchDrugDetails to use parallel API requests
  Future<Drug?> fetchDrugDetails(int cid) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      print('\n=== Starting fetchDrugDetails for CID: $cid ===');

      // Parallel API requests for better performance
      final detailedInfoFuture = fetchDetailedInfo(cid);
      final descriptionFuture = http
          .get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/description/XML'),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Network timeout while fetching description');
      });
      final pugViewFuture = fetchPugViewData(cid);
      final propertiesFuture = http
          .get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/property/MeltingPoint,BoilingPoint,FlashPoint,Density,Solubility,LogP,VaporPressure/JSON'),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Network timeout while fetching properties');
      });
      final drugInfoFuture = http
          .get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON'),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException(
            'Network timeout while fetching drug information');
      });
      final synonymsFuture = fetchSynonyms(cid);

      // Wait for all the parallel requests to complete
      final results = await Future.wait([
        detailedInfoFuture,
        descriptionFuture,
        pugViewFuture,
        propertiesFuture,
        drugInfoFuture,
      ], eagerError: true);

      final data = results[0] as Map<String, dynamic>;
      final descriptionResponse = results[1] as http.Response;
      final pugViewData = results[2] as Map<String, dynamic>;
      final propertiesResponse = results[3] as http.Response;
      final drugInfoResponse = results[4] as http.Response;

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

      // Process drug information
      String indication = '';
      String mechanismOfAction = '';
      String toxicity = '';
      String pharmacology = '';
      String metabolism = '';
      String absorption = '';
      String halfLife = '';
      String proteinBinding = '';
      String routeOfElimination = '';
      String volumeOfDistribution = '';
      String clearance = '';

      if (drugInfoResponse.statusCode == 200) {
        final drugInfoData = json.decode(drugInfoResponse.body);
        final record = drugInfoData['Record'];

        if (record != null && record['Section'] != null) {
          final sections = record['Section'];

          // Helper function to extract text from a section
          String extractTextFromSection(
              List<dynamic> sections, List<String> sectionNames) {
            for (var sectionName in sectionNames) {
              for (var section in sections) {
                if (section['TOCHeading'] == sectionName) {
                  final info = section['Information'] ?? [];
                  if (info.isNotEmpty) {
                    final value = info[0]['Value'];
                    if (value != null) {
                      if (value['StringWithMarkup'] != null) {
                        return value['StringWithMarkup'][0]['String'] ?? '';
                      } else if (value['String'] != null) {
                        return value['String'] ?? '';
                      }
                    }
                  }
                }
                // Check subsections
                if (section['Section'] != null) {
                  final result =
                      extractTextFromSection(section['Section'], [sectionName]);
                  if (result.isNotEmpty) return result;
                }
              }
            }
            return '';
          }

          indication = extractTextFromSection(sections, [
            'Therapeutic Uses',
            'Indications and Usage',
            'Indications',
            'Uses',
            'Clinical Use'
          ]);

          mechanismOfAction = extractTextFromSection(sections, [
            'Mechanism of Action',
            'Pharmacodynamics',
            'Mode of Action',
            'Action',
            'Mechanism'
          ]);

          toxicity = extractTextFromSection(sections, [
            'Toxicity',
            'Adverse Effects',
            'Side Effects',
            'Toxicology',
            'Safety',
            'Warnings'
          ]);

          pharmacology = extractTextFromSection(sections, [
            'Pharmacology',
            'Pharmacological Action',
            'Pharmacological Effects',
            'Pharmacological Properties'
          ]);

          metabolism = extractTextFromSection(sections, [
            'Metabolism',
            'Biotransformation',
            'Metabolic Pathway',
            'Metabolic Process'
          ]);

          absorption = extractTextFromSection(sections,
              ['Absorption', 'Bioavailability', 'Absorption and Distribution']);

          halfLife = extractTextFromSection(sections, [
            'Half Life',
            'Elimination Half-Life',
            'Half-Life',
            'Plasma Half-Life'
          ]);

          proteinBinding = extractTextFromSection(sections, [
            'Protein Binding',
            'Plasma Protein Binding',
            'Serum Protein Binding'
          ]);

          routeOfElimination = extractTextFromSection(sections, [
            'Route of Elimination',
            'Excretion',
            'Elimination',
            'Clearance Route'
          ]);

          volumeOfDistribution = extractTextFromSection(sections, [
            'Volume of Distribution',
            'Apparent Volume of Distribution',
            'Vd',
            'Distribution Volume'
          ]);

          clearance = extractTextFromSection(sections, [
            'Clearance',
            'Systemic Clearance',
            'Total Clearance',
            'Plasma Clearance'
          ]);
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

      // Find the existing drug or use defaults
      Drug? existingDrug = _selectedDrug;

      // Create updated drug with additional details
      _selectedDrug = Drug(
        name: existingDrug?.name ?? title,
        cid: cid,
        title: title,
        molecularFormula: properties['MolecularFormula'] ??
            existingDrug?.molecularFormula ??
            '',
        molecularWeight: double.tryParse(
                properties['Molecular Weight']?.toString() ?? '0') ??
            existingDrug?.molecularWeight ??
            0.0,
        smiles: properties['CanonicalSMILES'] ?? existingDrug?.smiles ?? '',
        xLogP: double.tryParse(properties['XLogP']?.toString() ?? '0') ??
            existingDrug?.xLogP ??
            0.0,
        hBondDonorCount:
            int.tryParse(properties['HBondDonorCount']?.toString() ?? '0') ??
                existingDrug?.hBondDonorCount ??
                0,
        hBondAcceptorCount:
            int.tryParse(properties['HBondAcceptorCount']?.toString() ?? '0') ??
                existingDrug?.hBondAcceptorCount ??
                0,
        rotatableBondCount:
            int.tryParse(properties['RotatableBondCount']?.toString() ?? '0') ??
                existingDrug?.rotatableBondCount ??
                0,
        heavyAtomCount:
            int.tryParse(properties['HeavyAtomCount']?.toString() ?? '0') ??
                existingDrug?.heavyAtomCount ??
                0,
        atomStereoCount:
            int.tryParse(properties['AtomStereoCount']?.toString() ?? '0') ??
                existingDrug?.atomStereoCount ??
                0,
        bondStereoCount:
            int.tryParse(properties['BondStereoCount']?.toString() ?? '0') ??
                existingDrug?.bondStereoCount ??
                0,
        complexity:
            double.tryParse(properties['Complexity']?.toString() ?? '0') ??
                existingDrug?.complexity ??
                0.0,
        iupacName: properties['IUPACName'] ?? existingDrug?.iupacName ?? '',
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
        pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid',
        indication: indication,
        mechanismOfAction: mechanismOfAction,
        toxicity: toxicity,
        pharmacology: pharmacology,
        metabolism: metabolism,
        absorption: absorption,
        halfLife: halfLife,
        proteinBinding: proteinBinding,
        routeOfElimination: routeOfElimination,
        volumeOfDistribution: volumeOfDistribution,
        clearance: clearance,
      );

      // Cache the drug for future use
      _drugCache[cid] = _selectedDrug!;

      notifyListeners();
      return _selectedDrug;
    } catch (e) {
      print('Error in fetchDrugDetails: $e');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else if (e is TimeoutException) {
        setError(
            'Network timeout. Please check your connection and try again.');
      } else {
        setError(e.toString());
      }
      return null;
    } finally {
      setLoading(false);
      notifyListeners();
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
          throw TimeoutException(
              'Network timeout while fetching PUG View data');
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch PUG View data: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (e) {
      print('Error fetching PUG View data: $e');

      // Handle SocketException
      if (e is SocketException) {
        throw Exception(ErrorHandler.getErrorMessage(e));
      }
      rethrow;
    }
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
      }
    }

    return properties;
  }

  // Override the fetchSynonyms method to add better error handling
  @override
  Future<List<String>> fetchSynonyms(int cid) async {
    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON');

      // Add timeout to prevent long waits
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Network timeout while fetching synonyms');
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
          print('No synonyms found for drug $cid');
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
      } else if (e is TimeoutException) {
        print('Timeout while fetching synonyms: $e');
      } else {
        print('Error fetching synonyms: $e');
      }

      // Return empty list instead of throwing to prevent entire drug loading from failing
      return [];
    }
  }

  void clearSelectedDrug() {
    _selectedDrug = null;
    notifyListeners();
  }

  void clearDrugs() {
    _drugs = [];
    _lastQuery = '';
    _hasSearched = false;
    clearError();
    notifyListeners();
  }
}
