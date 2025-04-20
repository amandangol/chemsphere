import '../model/drug.dart';
import '../../../providers/base_pubchem_provider.dart';
import '../../../providers/pubchem_impl_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:io'; // Import for SocketException
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

  Future<void> fetchDrugDetails(int cid) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      print('\n=== Starting fetchDrugDetails for CID: $cid ===');

      // Fetch basic drug data
      print('Fetching detailed info...');
      final data = await fetchDetailedInfo(cid);
      print('Detailed info response: ${data.toString().substring(0, 200)}...');

      // Fetch description data from XML endpoint
      print('Fetching description data...');
      final descriptionResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/description/XML'),
      );

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

        print('Description: $description');
        print('Description Source: $descriptionSource');
        print('Description URL: $descriptionUrl');
      }

      // Fetch additional data from PUG View
      print('Fetching PUG View data...');
      final pugViewData = await fetchPugViewData(cid);
      print(
          'PUG View response: ${pugViewData.toString().substring(0, 200)}...');

      // Fetch chemical properties
      print('Fetching chemical properties...');
      final propertiesResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/property/MeltingPoint,BoilingPoint,FlashPoint,Density,Solubility,LogP,VaporPressure/JSON'),
      );

      Map<String, dynamic> chemicalProperties = {};
      if (propertiesResponse.statusCode == 200) {
        final propertiesData = json.decode(propertiesResponse.body);
        if (propertiesData['PropertyTable']?['Properties'] != null) {
          chemicalProperties = propertiesData['PropertyTable']['Properties'][0];
        }
      }

      // Fetch drug information from PubChem
      print('Fetching drug information...');
      final drugInfoResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON'),
      );

      print('\n=== Drug Information Response ===');
      print('Status Code: ${drugInfoResponse.statusCode}');
      print('Response: ${drugInfoResponse.body.substring(0, 200)}...');

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

        if (record != null && record['Section'] != null) {
          final sections = record['Section'];
          print('\n=== Extracting Drug Information ===');

          indication = extractTextFromSection(sections, [
            'Therapeutic Uses',
            'Indications and Usage',
            'Indications',
            'Uses',
            'Clinical Use'
          ]);
          print('Indication: $indication');

          mechanismOfAction = extractTextFromSection(sections, [
            'Mechanism of Action',
            'Pharmacodynamics',
            'Mode of Action',
            'Action',
            'Mechanism'
          ]);
          print('Mechanism of Action: $mechanismOfAction');

          toxicity = extractTextFromSection(sections, [
            'Toxicity',
            'Adverse Effects',
            'Side Effects',
            'Toxicology',
            'Safety',
            'Warnings'
          ]);
          print('Toxicity: $toxicity');

          pharmacology = extractTextFromSection(sections, [
            'Pharmacology',
            'Pharmacological Action',
            'Pharmacological Effects',
            'Pharmacological Properties'
          ]);
          print('Pharmacology: $pharmacology');

          metabolism = extractTextFromSection(sections, [
            'Metabolism',
            'Biotransformation',
            'Metabolic Pathway',
            'Metabolic Process'
          ]);
          print('Metabolism: $metabolism');

          absorption = extractTextFromSection(sections,
              ['Absorption', 'Bioavailability', 'Absorption and Distribution']);
          print('Absorption: $absorption');

          halfLife = extractTextFromSection(sections, [
            'Half Life',
            'Elimination Half-Life',
            'Half-Life',
            'Plasma Half-Life'
          ]);
          print('Half Life: $halfLife');

          proteinBinding = extractTextFromSection(sections, [
            'Protein Binding',
            'Plasma Protein Binding',
            'Serum Protein Binding'
          ]);
          print('Protein Binding: $proteinBinding');

          routeOfElimination = extractTextFromSection(sections, [
            'Route of Elimination',
            'Excretion',
            'Elimination',
            'Clearance Route'
          ]);
          print('Route of Elimination: $routeOfElimination');

          volumeOfDistribution = extractTextFromSection(sections, [
            'Volume of Distribution',
            'Apparent Volume of Distribution',
            'Vd',
            'Distribution Volume'
          ]);
          print('Volume of Distribution: $volumeOfDistribution');

          clearance = extractTextFromSection(sections, [
            'Clearance',
            'Systemic Clearance',
            'Total Clearance',
            'Plasma Clearance'
          ]);
          print('Clearance: $clearance');
        }
      }

      // Extract properties from compound data
      final compoundData = data['compound']['PC_Compounds']?[0];
      final propertiesData = compoundData?['props'] ?? [];
      print('Properties data length: ${propertiesData.length}');
      final properties = _extractProperties(propertiesData);
      print(
          'Extracted properties: ${properties.toString().substring(0, 200)}...');

      // Extract title from PUG View data
      String title = pugViewData['Record']?['RecordTitle'] ?? '';
      print('Title from PUG View: $title');

      // If no title found in PUG View, use properties title
      if (title.isEmpty) {
        title = properties['Title'] ?? properties['IUPACName'] ?? '';
        print('Title from properties: $title');
      }

      // Use base provider's method to fetch synonyms
      print('Fetching synonyms...');
      final synonyms = await fetchSynonyms(cid);
      print('Synonyms fetched: ${synonyms.length}');

      // Find the existing drug or use defaults
      Drug? existingDrug;
      try {
        existingDrug = _drugs.firstWhere(
          (d) => d.cid == cid,
        );
      } catch (e) {
        // Drug not found, will use defaults
        existingDrug = null;
      }

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

      print('\n=== Created Drug Object ===');
      print('Title: ${_selectedDrug?.title}');
      print('Molecular Formula: ${_selectedDrug?.molecularFormula}');
      print('Molecular Weight: ${_selectedDrug?.molecularWeight}');
      print('Description: ${_selectedDrug?.description}');
      print('Description Source: ${_selectedDrug?.descriptionSource}');
      print('Description URL: ${_selectedDrug?.descriptionUrl}');
      print('Synonyms: ${_selectedDrug?.synonyms}');
      print('Chemical Properties: ${_selectedDrug?.physicalProperties}');
      print('Indication: ${_selectedDrug?.indication}');
      print('Mechanism of Action: ${_selectedDrug?.mechanismOfAction}');
      print('Toxicity: ${_selectedDrug?.toxicity}');
      print('Pharmacology: ${_selectedDrug?.pharmacology}');
      print('Metabolism: ${_selectedDrug?.metabolism}');
      print('Absorption: ${_selectedDrug?.absorption}');
      print('Half Life: ${_selectedDrug?.halfLife}');
      print('Protein Binding: ${_selectedDrug?.proteinBinding}');
      print('Route of Elimination: ${_selectedDrug?.routeOfElimination}');
      print('Volume of Distribution: ${_selectedDrug?.volumeOfDistribution}');
      print('Clearance: ${_selectedDrug?.clearance}');
    } catch (e) {
      print('Error in fetchDrugDetails: $e');

      // Use ErrorHandler to get a user-friendly error message
      if (e is SocketException) {
        setError(ErrorHandler.getErrorMessage(e));
      } else {
        setError(e.toString());
      }
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

      final response = await http.get(url);

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

    print('Extracted properties: $properties');
    return properties;
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
