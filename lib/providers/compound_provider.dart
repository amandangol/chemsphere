import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/compound.dart';

class CompoundProvider with ChangeNotifier {
  List<Compound> _compounds = [];
  bool _isLoading = false;
  String? _error;
  Compound? _selectedCompound;

  List<Compound> get compounds => _compounds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Compound? get selectedCompound => _selectedCompound;

  Future<void> searchCompounds(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Starting compound search for query: $query');

      // Step 1: Get CIDs using synonym search
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON');
      print('Fetching CIDs from: $cidUrl');

      final cidResponse = await http.get(cidUrl);
      print('CID response status: ${cidResponse.statusCode}');

      if (cidResponse.statusCode != 200) {
        throw Exception('Failed to fetch compounds');
      }

      final cidData = json.decode(cidResponse.body);
      print('CID data received: $cidData');

      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];
      print('Found ${cids.length} CIDs: $cids');

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$query".');
      }

      // Limit to first 10
      final limitedCids = cids.take(10).join(',');
      print('Limited to first 10 CIDs: $limitedCids');

      // Step 2: Fetch properties for the CIDs
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,HeavyAtomCount,AtomStereoCount,BondStereoCount,ExactMass,MonoisotopicMass,TPSA,Charge,IsotopeAtomCount,DefinedAtomStereoCount,UndefinedAtomStereoCount,DefinedBondStereoCount,UndefinedBondStereoCount,CovalentUnitCount,PatentCount,PatentFamilyCount,AnnotationTypes,AnnotationTypeCount,SourceCategories,LiteratureCount,InChI,InChIKey/JSON');
      print('Fetching properties from: $propertiesUrl');

      final propertiesResponse = await http.get(propertiesUrl);
      print('Properties response status: ${propertiesResponse.statusCode}');

      if (propertiesResponse.statusCode != 200) {
        throw Exception('Failed to fetch compound properties');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      print('Properties data received: $propertiesData');

      final List<dynamic> compoundData =
          propertiesData['PropertyTable']?['Properties'] ?? [];
      print('Found ${compoundData.length} compounds with properties');

      _compounds = compoundData.map((e) {
        print('Processing compound data: $e');
        return Compound.fromJson(e);
      }).toList();

      print('Successfully created ${_compounds.length} compounds');
    } catch (e, stackTrace) {
      print('Error during compound search: $e');
      print('Stack trace: $stackTrace');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompoundDetails(int cid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Fetching details for CID: $cid');

      // First fetch the detailed information
      final response = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/JSON'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('\n=== Raw API Response ===');
        print('Compound data: $data');

        final compoundData = data['PC_Compounds']?[0];
        final propertiesData = compoundData?['props'] ?? [];
        final properties = _extractProperties(propertiesData);
        print('\n=== Extracted Properties ===');
        print('Properties: $properties');

        // Then fetch the description
        final descriptionResponse = await http.get(
          Uri.parse(
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/description/JSON'),
        );

        String description = '';
        String descriptionSource = '';
        String descriptionUrl = '';

        if (descriptionResponse.statusCode == 200) {
          final descriptionData = json.decode(descriptionResponse.body);
          print('\n=== Description Data ===');
          print('Description data: $descriptionData');

          final descriptions =
              descriptionData['InformationList']?['Information'] ?? [];
          if (descriptions.isNotEmpty) {
            final info = descriptions[0];
            description = info['Description'] ?? '';
            descriptionSource = info['DescriptionSourceName'] ?? '';
            descriptionUrl = info['DescriptionURL'] ?? '';
          }
        }

        // Fetch synonyms
        final synonymsResponse = await http.get(
          Uri.parse(
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON'),
        );

        List<String> synonyms = [];
        if (synonymsResponse.statusCode == 200) {
          final synonymsData = json.decode(synonymsResponse.body);
          print('\n=== Synonyms Data ===');
          print('Synonyms data: $synonymsData');

          final synonymsList =
              synonymsData['InformationList']?['Information'] ?? [];
          if (synonymsList.isNotEmpty) {
            synonyms = List<String>.from(synonymsList[0]['Synonym'] ?? []);
          }
        }

        // Create the compound object
        _selectedCompound = Compound(
          cid: cid,
          title: properties['Title'] ?? properties['IUPACName'] ?? '',
          molecularFormula: properties['MolecularFormula'] ?? '',
          molecularWeight: double.tryParse(
                  properties['Molecular Weight']?.toString() ?? '0') ??
              0.0,
          smiles: properties['CanonicalSMILES'] ?? '',
          xLogP: double.tryParse(properties['XLogP']?.toString() ?? '0') ?? 0.0,
          hBondDonorCount:
              int.tryParse(properties['HBondDonorCount']?.toString() ?? '0') ??
                  0,
          hBondAcceptorCount: int.tryParse(
                  properties['HBondAcceptorCount']?.toString() ?? '0') ??
              0,
          rotatableBondCount: int.tryParse(
                  properties['RotatableBondCount']?.toString() ?? '0') ??
              0,
          heavyAtomCount:
              int.tryParse(properties['HeavyAtomCount']?.toString() ?? '0') ??
                  0,
          atomStereoCount:
              int.tryParse(properties['AtomStereoCount']?.toString() ?? '0') ??
                  0,
          bondStereoCount:
              int.tryParse(properties['BondStereoCount']?.toString() ?? '0') ??
                  0,
          complexity:
              double.tryParse(properties['Complexity']?.toString() ?? '0') ??
                  0.0,
          iupacName: properties['IUPACName'] ?? '',
          description: description,
          descriptionSource: descriptionSource,
          descriptionUrl: descriptionUrl,
          synonyms: synonyms,
          physicalProperties: properties,
          safetyData: {},
          classifications: [],
          uses: [],
          pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/$cid',
          exactMass:
              double.tryParse(properties['ExactMass']?.toString() ?? '0') ??
                  0.0,
          monoisotopicMass: double.tryParse(
                  properties['MonoisotopicMass']?.toString() ?? '0') ??
              0.0,
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
          covalentUnitCount: int.tryParse(
                  properties['CovalentUnitCount']?.toString() ?? '0') ??
              0,
          patentCount:
              int.tryParse(properties['PatentCount']?.toString() ?? '0') ?? 0,
          patentFamilyCount: int.tryParse(
                  properties['PatentFamilyCount']?.toString() ?? '0') ??
              0,
          annotationTypes:
              List<String>.from(properties['AnnotationTypes'] ?? []),
          annotationTypeCount: int.tryParse(
                  properties['AnnotationTypeCount']?.toString() ?? '0') ??
              0,
          sourceCategories:
              List<String>.from(properties['SourceCategories'] ?? []),
          literatureCount:
              int.tryParse(properties['LiteratureCount']?.toString() ?? '0') ??
                  0,
          inchi: properties['InChI'] ?? '',
          inchiKey: properties['InChIKey'] ?? '',
        );

        print('\n=== Created Compound Object ===');
        print('Title: ${_selectedCompound?.title}');
        print('Molecular Formula: ${_selectedCompound?.molecularFormula}');
        print('Molecular Weight: ${_selectedCompound?.molecularWeight}');
        print('Description: ${_selectedCompound?.description}');
        print('Description Source: ${_selectedCompound?.descriptionSource}');
        print('Description URL: ${_selectedCompound?.descriptionUrl}');
        print('Synonyms: ${_selectedCompound?.synonyms}');
      } else {
        throw Exception('Failed to load compound details');
      }
    } catch (e) {
      print('Error in fetchCompoundDetails: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
        properties['Title'] =
            value['sval']; // Use IUPAC name as title if available
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
      }
    }

    print('Extracted properties: $properties');
    return properties;
  }
}
