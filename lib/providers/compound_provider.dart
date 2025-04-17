import 'package:flutter/foundation.dart';
import '../models/compound.dart';
import 'base_pubchem_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml/xml.dart';

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

  Future<void> fetchCompoundDetails(int cid) async {
    try {
      setLoading(true);
      clearError();
      notifyListeners();

      print('\n=== Starting fetchCompoundDetails for CID: $cid ===');

      // Fetch basic compound data
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

      // Fetch synonyms (limited to 50)
      print('Fetching synonyms...');
      final synonymsResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/synonyms/JSON'),
      );

      List<String> synonyms = [];
      if (synonymsResponse.statusCode == 200) {
        final synonymsData = json.decode(synonymsResponse.body);
        final synonymsList =
            synonymsData['InformationList']['Information'][0]['Synonym'];
        synonyms =
            (synonymsList as List).take(50).map((s) => s.toString()).toList();
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

      // Fetch safety and hazards data
      print('Fetching safety data...');
      final safetyResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON?heading=Chemical%20Safety'),
      );

      Map<String, dynamic> safetyData = {};
      if (safetyResponse.statusCode == 200) {
        final safetyJson = json.decode(safetyResponse.body);
        if (safetyJson['Record']?['Section'] != null) {
          for (var section in safetyJson['Record']['Section']) {
            if (section['TOCHeading'] == 'Chemical Safety') {
              // Extract GHS information
              List<Map<String, dynamic>> ghsInfo = [];
              if (section['Section'] != null) {
                for (var subSection in section['Section']) {
                  if (subSection['TOCHeading'] == 'GHS Classification') {
                    if (subSection['Information'] != null) {
                      for (var info in subSection['Information']) {
                        ghsInfo.add({
                          'Name': info['Name'],
                          'Value': info['StringValue'],
                        });
                      }
                    }
                  }
                }
              }

              // Extract hazard statements
              List<Map<String, dynamic>> hazardStatements = [];
              if (section['Section'] != null) {
                for (var subSection in section['Section']) {
                  if (subSection['TOCHeading'] == 'Hazard Statements') {
                    if (subSection['Information'] != null) {
                      for (var info in subSection['Information']) {
                        hazardStatements.add({
                          'Code': info['Name'],
                          'Statement': info['StringValue'],
                        });
                      }
                    }
                  }
                }
              }

              // Extract precautionary statements
              List<Map<String, dynamic>> precautionaryStatements = [];
              if (section['Section'] != null) {
                for (var subSection in section['Section']) {
                  if (subSection['TOCHeading'] == 'Precautionary Statements') {
                    if (subSection['Information'] != null) {
                      for (var info in subSection['Information']) {
                        precautionaryStatements.add({
                          'Code': info['Name'],
                          'Statement': info['StringValue'],
                        });
                      }
                    }
                  }
                }
              }

              // Extract safety data sheets
              List<Map<String, dynamic>> safetyDataSheets = [];
              if (section['Section'] != null) {
                for (var subSection in section['Section']) {
                  if (subSection['TOCHeading'] == 'Safety Data Sheets') {
                    if (subSection['Information'] != null) {
                      for (var info in subSection['Information']) {
                        safetyDataSheets.add({
                          'Source': info['Name'],
                          'URL': info['URL'],
                        });
                      }
                    }
                  }
                }
              }

              safetyData = {
                'GHSClassification': ghsInfo,
                'HazardStatements': hazardStatements,
                'PrecautionaryStatements': precautionaryStatements,
                'SafetyDataSheets': safetyDataSheets,
              };
              break;
            }
          }
        }
      }

      // Fetch biological properties
      print('Fetching biological properties...');
      final bioResponse = await http.get(
        Uri.parse(
            'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON?heading=Biological%20Properties'),
      );

      Map<String, dynamic> biologicalData = {};
      if (bioResponse.statusCode == 200) {
        final bioJson = json.decode(bioResponse.body);
        if (bioJson['Record']?['Section'] != null) {
          for (var section in bioJson['Record']['Section']) {
            if (section['TOCHeading'] == 'Biological Properties') {
              biologicalData = section;
              break;
            }
          }
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
        safetyData: safetyData,
        biologicalData: biologicalData,
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
      print('Chemical Properties: ${_selectedCompound?.physicalProperties}');
      print('Safety Data: ${_selectedCompound?.safetyData}');
      print('Biological Data: ${_selectedCompound?.biologicalData}');
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

      return compounds;
    } catch (e) {
      print('Error in fetchCompoundsByCriteria: $e');
      setError(e.toString());
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
}
