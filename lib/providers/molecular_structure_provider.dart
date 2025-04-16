import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/molecular_structure.dart';

class MolecularStructureProvider with ChangeNotifier {
  List<MolecularStructure>? _structure;
  bool _isLoading = false;
  String? _error;

  List<MolecularStructure>? get structure => _structure;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchByCompoundName(String name) async {
    _isLoading = true;
    _error = null;
    _structure = null;
    notifyListeners();

    try {
      print('Searching for compound: $name');
      // First get the CIDs for the compound name
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$name/cids/JSON');
      print('CID URL: $cidUrl');
      final cidResponse = await http.get(cidUrl);
      print('CID Response status: ${cidResponse.statusCode}');
      print('CID Response body: ${cidResponse.body}');

      if (cidResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch compound information. Status: ${cidResponse.statusCode}');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];
      print('Found CIDs: $cids');

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$name".');
      }

      // Limit to first 10
      final limitedCids = cids.take(10).join(',');
      print('Limited CIDs: $limitedCids');

      // Get molecule properties with focus on structural information
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,HeavyAtomCount,AtomStereoCount,BondStereoCount/JSON');
      print('Properties URL: $propertiesUrl');
      final propertiesResponse = await http.get(propertiesUrl);
      print('Properties Response status: ${propertiesResponse.statusCode}');
      print('Properties Response body: ${propertiesResponse.body}');

      if (propertiesResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch molecular properties. Status: ${propertiesResponse.statusCode}');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      final List<dynamic> moleculeData =
          propertiesData['PropertyTable']['Properties'];
      print('Found molecule data: ${moleculeData.length} items');

      _structure = moleculeData
          .map((data) => MolecularStructure.fromJson(data))
          .toList();
      print('Successfully loaded ${_structure?.length} structures');
    } catch (e) {
      print('Error in searchByCompoundName: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStructures() {
    _structure = null;
    _error = null;
    notifyListeners();
  }
}
