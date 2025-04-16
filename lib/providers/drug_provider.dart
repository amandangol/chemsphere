import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/drug.dart';

class DrugProvider with ChangeNotifier {
  List<Drug> _drugs = [];
  bool _isLoading = false;
  String? _error;
  Drug? _selectedDrug;

  List<Drug> get drugs => _drugs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Drug? get selectedDrug => _selectedDrug;

  Future<void> searchDrugs(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First get the CIDs for the drug name
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON');
      final cidResponse = await http.get(cidUrl);

      if (cidResponse.statusCode != 200) {
        throw Exception('Failed to fetch drug information');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No drugs found for "$query".');
      }

      // Limit to first 5 for better performance
      final limitedCids = cids.take(5).join(',');

      // Get drug properties
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount/JSON');
      final propertiesResponse = await http.get(propertiesUrl);

      if (propertiesResponse.statusCode != 200) {
        throw Exception('Failed to fetch drug properties');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      final List<dynamic> drugData =
          propertiesData['PropertyTable']['Properties'];

      _drugs = drugData
          .map((e) => Drug.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDrugDetails(int cid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch drug details');
      }

      final data = json.decode(response.body);
      // Update the selected drug with additional details
      final existingDrug = _drugs.firstWhere(
        (d) => d.cid == cid,
        orElse: () => throw Exception('Drug not found'),
      );

      _selectedDrug = existingDrug;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedDrug() {
    _selectedDrug = null;
    notifyListeners();
  }
}
