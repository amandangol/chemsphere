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
      // Step 1: Get CIDs using synonym search
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON');
      final cidResponse = await http.get(cidUrl);

      if (cidResponse.statusCode != 200) {
        throw Exception('Failed to fetch compounds');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$query".');
      }

      // Limit to first 10
      final limitedCids = cids.take(10).join(',');

      // Step 2: Fetch properties for the CIDs
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,HeavyAtomCount,AtomStereoCount,BondStereoCount/JSON');
      final propertiesResponse = await http.get(propertiesUrl);

      if (propertiesResponse.statusCode != 200) {
        throw Exception('Failed to fetch compound properties');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      final List<dynamic> compoundData =
          propertiesData['PropertyTable']['Properties'];

      _compounds = compoundData
          .map((e) => Compound.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompoundDetails(int cid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch compound details');
      }

      final data = json.decode(response.body);
      // Update the selected compound with additional details
      final existingCompound = _compounds.firstWhere(
        (c) => c.cid == cid,
        orElse: () => throw Exception('Compound not found'),
      );

      _selectedCompound = existingCompound;
    } catch (e) {
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
}
