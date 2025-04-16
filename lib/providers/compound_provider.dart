import 'package:flutter/foundation.dart';
import '../models/compound.dart';
import 'base_pubchem_provider.dart';

class CompoundProvider extends BasePubChemProvider {
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
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchCompoundDetails(int cid) async {
    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('Fetching details for CID: $cid');

      // Use base provider's method to fetch detailed info
      final data = await fetchDetailedInfo(cid);
      print('\n=== Raw API Response ===');
      print('Compound data: ${data['compound']}');
      print('Record data: ${data['record']}');

      // Extract properties from compound data
      final compoundData = data['compound']['PC_Compounds']?[0];
      final propertiesData = compoundData?['props'] ?? [];
      final properties = _extractProperties(propertiesData);
      print('\n=== Extracted Properties ===');
      print('Properties: $properties');

      // Extract title from record data
      String title = '';
      if (data['record'] != null) {
        final sections = data['record']['Record']?['Section'] ?? [];
        for (var section in sections) {
          if (section['TOCHeading'] == 'Names and Identifiers') {
            final subsections = section['Section'] ?? [];
            for (var subsection in subsections) {
              if (subsection['TOCHeading'] == 'Record Title') {
                title = subsection['Information']?[0]['Value']
                        ?['StringWithMarkup']?[0]['String'] ??
                    '';
                break;
              }
            }
            if (title.isNotEmpty) break;
          }
        }
      }

      // If no title found in record, use properties title
      if (title.isEmpty) {
        title = properties['Title'] ?? properties['IUPACName'] ?? '';
      }

      // Use base provider's method to fetch description
      final descriptionData = await fetchDescription(cid);
      print('\n=== Description Data ===');
      print('Description data: $descriptionData');

      // Use base provider's method to fetch synonyms
      final synonyms = await fetchSynonyms(cid);
      print('\n=== Synonyms Data ===');
      print('Synonyms data: $synonyms');

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
        description: descriptionData['description'] ?? '',
        descriptionSource: descriptionData['source'] ?? '',
        descriptionUrl: descriptionData['url'] ?? '',
        synonyms: synonyms,
        physicalProperties: properties,
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

      print('\n=== Created Compound Object ===');
      print('Title: ${_selectedCompound?.title}');
      print('Molecular Formula: ${_selectedCompound?.molecularFormula}');
      print('Molecular Weight: ${_selectedCompound?.molecularWeight}');
      print('Description: ${_selectedCompound?.description}');
      print('Description Source: ${_selectedCompound?.descriptionSource}');
      print('Description URL: ${_selectedCompound?.descriptionUrl}');
      print('Synonyms: ${_selectedCompound?.synonyms}');
    } catch (e) {
      print('Error in fetchCompoundDetails: $e');
      setError(e.toString());
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
}
