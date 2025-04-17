import '../models/drug.dart';
import 'base_pubchem_provider.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';

class DrugProvider extends BasePubChemProvider {
  List<Drug> _drugs = [];
  Drug? _selectedDrug;

  List<Drug> get drugs => _drugs;
  Drug? get selectedDrug => _selectedDrug;

  Future<void> searchDrugs(String query) async {
    setLoading(true);
    clearError();
    notifyListeners();

    try {
      // Use base provider's method to fetch CIDs
      final cids = await fetchCids(query);

      // Use base provider's method to fetch properties
      final properties = await fetchBasicProperties(cids, limit: 5);

      _drugs = properties.map((e) {
        final json = Map<String, dynamic>.from(e);
        return Drug(
          name: json['Name'] ?? '',
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
      setError(e.toString());
    } finally {
      setLoading(false);
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

      // Find the existing drug
      final existingDrug = _drugs.firstWhere(
        (d) => d.cid == cid,
        orElse: () => throw Exception('Drug not found'),
      );

      // Create updated drug with additional details
      _selectedDrug = Drug(
        name: existingDrug.name,
        cid: existingDrug.cid,
        title: existingDrug.title,
        molecularFormula: existingDrug.molecularFormula,
        molecularWeight: existingDrug.molecularWeight,
        smiles: existingDrug.smiles,
        xLogP: existingDrug.xLogP,
        hBondDonorCount: existingDrug.hBondDonorCount,
        hBondAcceptorCount: existingDrug.hBondAcceptorCount,
        rotatableBondCount: existingDrug.rotatableBondCount,
        heavyAtomCount: existingDrug.heavyAtomCount,
        atomStereoCount: existingDrug.atomStereoCount,
        bondStereoCount: existingDrug.bondStereoCount,
        complexity: existingDrug.complexity,
        iupacName: existingDrug.iupacName,
        description: description,
        descriptionSource: descriptionSource,
        descriptionUrl: descriptionUrl,
        synonyms: existingDrug.synonyms,
        physicalProperties: existingDrug.physicalProperties,
        pubChemUrl: existingDrug.pubChemUrl,
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
      print('Description: ${_selectedDrug?.description}');
      print('Description Source: ${_selectedDrug?.descriptionSource}');
      print('Description URL: ${_selectedDrug?.descriptionUrl}');
      print('Synonyms: ${_selectedDrug?.synonyms}');
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
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearSelectedDrug() {
    _selectedDrug = null;
    notifyListeners();
  }

  void clearDrugs() {
    _drugs = [];
    notifyListeners();
  }
}
