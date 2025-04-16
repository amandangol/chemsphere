import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/molecular_structure.dart';

class MolecularStructureProvider with ChangeNotifier {
  MolecularStructure? _structure;
  bool _isLoading = false;
  String? _error;
  String? _smiles;

  MolecularStructure? get structure => _structure;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get smiles => _smiles;

  Future<void> searchBySmiles(String smiles) async {
    _isLoading = true;
    _error = null;
    _smiles = smiles;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/smiles/$smiles/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,InChI,InChIKey,IUPACName/JSON');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch molecular structure');
      }

      final data = json.decode(response.body);
      final List<dynamic> properties = data['PropertyTable']['Properties'];

      if (properties.isEmpty) {
        throw Exception('No structure found for the given SMILES');
      }

      _structure = MolecularStructure.fromJson(properties.first);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchByInchiKey(String inchiKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/inchikey/$inchiKey/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,InChI,InChIKey,IUPACName/JSON');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch molecular structure');
      }

      final data = json.decode(response.body);
      final List<dynamic> properties = data['PropertyTable']['Properties'];

      if (properties.isEmpty) {
        throw Exception('No structure found for the given InChIKey');
      }

      _structure = MolecularStructure.fromJson(properties.first);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearStructure() {
    _structure = null;
    _smiles = null;
    notifyListeners();
  }
}
