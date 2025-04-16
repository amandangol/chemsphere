import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/compound_provider.dart';

class CompoundDetailScreen extends StatelessWidget {
  const CompoundDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Details'),
      ),
      body: Consumer<CompoundProvider>(
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
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchCompoundDetails(
                        provider.selectedCompound?.cid ?? 0),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final compound = provider.selectedCompound;
          if (compound == null) {
            return const Center(child: Text('No compound selected'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          compound.molecularFormula,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compound.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('CID: ${compound.cid}'),
                          Text(
                              'Molecular Weight: ${compound.molecularWeight} g/mol'),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Properties
                _buildSectionTitle('Properties'),
                _buildPropertyRow(
                    'Molecular Formula', compound.molecularFormula),
                _buildPropertyRow('SMILES', compound.smiles),
                _buildPropertyRow('XLogP', compound.xLogP.toString()),
                _buildPropertyRow('Complexity', compound.complexity.toString()),
                _buildPropertyRow(
                    'H-Bond Donors', compound.hBondDonorCount.toString()),
                _buildPropertyRow(
                    'H-Bond Acceptors', compound.hBondAcceptorCount.toString()),
                _buildPropertyRow(
                    'Rotatable Bonds', compound.rotatableBondCount.toString()),

                const Divider(height: 32),

                // Structure
                _buildSectionTitle('Structure'),
                Center(
                  child: Image.network(
                    'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 100),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPropertyRow(String property, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$property:',
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
