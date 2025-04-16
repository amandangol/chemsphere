import '../models/molecular_structure.dart';
import 'base_pubchem_provider.dart';

class MolecularStructureProvider extends BasePubChemProvider {
  List<MolecularStructure>? _structure;

  List<MolecularStructure>? get structure => _structure;

  Future<void> searchByCompoundName(String name) async {
    setLoading(true);
    clearError();
    _structure = null;
    notifyListeners();

    try {
      print('Searching for compound: $name');

      // Use base provider's method to fetch CIDs
      final cids = await fetchCids(name);
      print('Found CIDs: $cids');

      // Use base provider's method to fetch properties
      final properties = await fetchBasicProperties(cids);
      print('Found molecule data: ${properties.length} items');

      _structure =
          properties.map((data) => MolecularStructure.fromJson(data)).toList();
      print('Successfully loaded ${_structure?.length} structures');
    } catch (e) {
      print('Error in searchByCompoundName: $e');
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearStructures() {
    _structure = null;
    clearError();
    notifyListeners();
  }
}
