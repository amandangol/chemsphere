import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/molecular_structure_provider.dart';
import '../../models/molecular_structure.dart';

class MolecularStructureScreen extends StatefulWidget {
  const MolecularStructureScreen({Key? key}) : super(key: key);

  @override
  _MolecularStructureScreenState createState() =>
      _MolecularStructureScreenState();
}

class _MolecularStructureScreenState extends State<MolecularStructureScreen> {
  final _smilesController = TextEditingController();
  final _inchiKeyController = TextEditingController();

  @override
  void dispose() {
    _smilesController.dispose();
    _inchiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Molecular Structure'),
      ),
      body: Consumer<MolecularStructureProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearStructure();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchSection(provider),
                const SizedBox(height: 24),
                if (provider.structure != null)
                  _buildStructureDetails(provider.structure!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(MolecularStructureProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Search by SMILES or InChIKey',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smilesController,
              decoration: const InputDecoration(
                labelText: 'Enter SMILES',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_smilesController.text.isNotEmpty) {
                  provider.searchBySmiles(_smilesController.text);
                }
              },
              child: const Text('Search by SMILES'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _inchiKeyController,
              decoration: const InputDecoration(
                labelText: 'Enter InChIKey',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_inchiKeyController.text.isNotEmpty) {
                  provider.searchByInchiKey(_inchiKeyController.text);
                }
              },
              child: const Text('Search by InChIKey'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureDetails(MolecularStructure structure) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Structure Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPropertyRow('Title', structure.title),
            _buildPropertyRow('Molecular Formula', structure.molecularFormula),
            _buildPropertyRow(
                'Molecular Weight', structure.molecularWeight.toString()),
            _buildPropertyRow('SMILES', structure.smiles),
            _buildPropertyRow('InChI', structure.inchi),
            _buildPropertyRow('InChIKey', structure.inchiKey),
            _buildPropertyRow('IUPAC Name', structure.iupacName),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
