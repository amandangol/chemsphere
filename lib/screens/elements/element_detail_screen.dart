import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/element_provider.dart';

class ElementDetailScreen extends StatelessWidget {
  const ElementDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Element Details'),
      ),
      body: Consumer<ElementProvider>(
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
                    onPressed: () => provider.fetchElementDetails(
                        provider.selectedElement?.symbol ?? ''),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final element = provider.selectedElement;
          if (element == null) {
            return const Center(child: Text('No element selected'));
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
                          element.symbol,
                          style: const TextStyle(
                            fontSize: 48,
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
                            element.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Atomic Number: ${element.number}'),
                          Text('Atomic Mass: ${element.atomicMass} u'),
                          Text('Group: ${element.category}'),
                          Text('Phase: ${element.phase}'),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Physical Properties
                _buildSectionTitle('Physical Properties'),
                _buildPropertyRow('Appearance', element.appearance),
                _buildPropertyRow('Phase', element.phase),
                _buildPropertyRow('Category', element.category),
                _buildPropertyRow('Density', '${element.density} g/cm³'),
                _buildPropertyRow('Melting Point', '${element.melt} K'),
                _buildPropertyRow('Boiling Point', '${element.boil} K'),
                _buildPropertyRow(
                    'Molar Heat', '${element.molarHeat} J/(mol·K)'),

                const Divider(height: 32),

                // Atomic Properties
                _buildSectionTitle('Atomic Properties'),
                _buildPropertyRow(
                    'Electron Configuration', element.electronConfiguration),
                _buildPropertyRow(
                    'Electron Affinity', '${element.electronAffinity} kJ/mol'),
                _buildPropertyRow('Electronegativity (Pauling)',
                    '${element.electronegativityPauling}'),
                _buildPropertyRow('Ionization Energies',
                    element.ionizationEnergies.join(', ')),
                _buildPropertyRow('Shells', element.shells.join(', ')),

                const Divider(height: 32),

                // Discovery Information
                _buildSectionTitle('Discovery Information'),
                _buildPropertyRow('Discovered By', element.discoveredBy),
                _buildPropertyRow('Named By', element.namedBy),
                _buildPropertyRow('Source', element.source),

                const Divider(height: 32),

                // Summary
                _buildSectionTitle('Summary'),
                Text(element.summary),
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
