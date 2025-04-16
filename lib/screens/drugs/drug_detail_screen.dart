import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/drug_provider.dart';

class DrugDetailScreen extends StatelessWidget {
  const DrugDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Details'),
      ),
      body: Consumer<DrugProvider>(
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
                    onPressed: () => provider
                        .fetchDrugDetails(provider.selectedDrug?.cid ?? 0),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final drug = provider.selectedDrug;
          if (drug == null) {
            return const Center(child: Text('No drug selected'));
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
                          drug.molecularFormula,
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
                            drug.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('CID: ${drug.cid}'),
                          Text(
                              'Molecular Weight: ${drug.molecularWeight} g/mol'),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Properties
                _buildSectionTitle('Properties'),
                _buildPropertyRow('Molecular Formula', drug.molecularFormula),
                _buildPropertyRow('SMILES', drug.smiles),
                _buildPropertyRow('XLogP', drug.xLogP.toString()),
                _buildPropertyRow('Complexity', drug.complexity.toString()),
                _buildPropertyRow(
                    'H-Bond Donors', drug.hBondDonorCount.toString()),
                _buildPropertyRow(
                    'H-Bond Acceptors', drug.hBondAcceptorCount.toString()),
                _buildPropertyRow(
                    'Rotatable Bonds', drug.rotatableBondCount.toString()),

                const Divider(height: 32),

                // Drug Information
                _buildSectionTitle('Drug Information'),
                if (drug.indication != null)
                  _buildPropertyRow('Indication', drug.indication!),
                if (drug.mechanismOfAction != null)
                  _buildPropertyRow(
                      'Mechanism of Action', drug.mechanismOfAction!),
                if (drug.toxicity != null)
                  _buildPropertyRow('Toxicity', drug.toxicity!),
                if (drug.metabolism != null)
                  _buildPropertyRow('Metabolism', drug.metabolism!),
                if (drug.pharmacology != null)
                  _buildPropertyRow('Pharmacology', drug.pharmacology!),

                const Divider(height: 32),

                // Structure
                _buildSectionTitle('Structure'),
                Center(
                  child: Image.network(
                    'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
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
