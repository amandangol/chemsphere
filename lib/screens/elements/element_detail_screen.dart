import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/element_provider.dart';

class ElementDetailScreen extends StatelessWidget {
  const ElementDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<ElementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading element details...',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchElementDetails(
                        provider.selectedElement?.symbol ?? ''),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final element = provider.selectedElement;
          if (element == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No element selected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          final color = _getElementColor(element.category);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.3),
                  theme.colorScheme.background,
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: color,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      element.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withOpacity(0.8),
                                color,
                              ],
                            ),
                          ),
                        ),
                        // Symbol watermark
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Text(
                            element.symbol,
                            style: TextStyle(
                              fontSize: 150,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                        // Element info
                        Positioned(
                          bottom: 60,
                          left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Atomic Number: ${element.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      element.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      color: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      color: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bookmark feature coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Element Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick facts card
                        _buildSection(
                          context,
                          title: 'Quick Facts',
                          icon: Icons.info_outline,
                          content: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildProperty(
                                  'Atomic Mass', '${element.atomicMass} u'),
                              _buildProperty('Phase', element.phase),
                              _buildProperty(
                                  'Density', '${element.density} g/cm³'),
                              _buildProperty('Period', '${element.period}'),
                              _buildProperty('Group', '${element.group}'),
                              _buildProperty('Atomic Radius',
                                  '${element.atomicRadius} pm'),
                            ],
                          ),
                        ),

                        // Summary section
                        _buildSection(
                          context,
                          title: 'Summary',
                          icon: Icons.description,
                          content: Text(
                            element.summary,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),

                        // Physical Properties
                        _buildSection(
                          context,
                          title: 'Physical Properties',
                          icon: Icons.science,
                          content: Column(
                            children: [
                              _buildPropertyRow(
                                  'Appearance', element.appearance),
                              _buildPropertyRow('Phase', element.phase),
                              _buildPropertyRow(
                                  'Density', '${element.density} g/cm³'),
                              _buildPropertyRow(
                                  'Melting Point', '${element.melt} K'),
                              _buildPropertyRow(
                                  'Boiling Point', '${element.boil} K'),
                              _buildPropertyRow('Molar Heat',
                                  '${element.molarHeat} J/(mol·K)'),
                            ],
                          ),
                        ),

                        // Atomic Properties
                        _buildSection(
                          context,
                          title: 'Atomic Properties',
                          icon: Icons.science,
                          content: Column(
                            children: [
                              _buildPropertyRow('Electron Configuration',
                                  element.electronConfiguration),
                              _buildPropertyRow('Electron Affinity',
                                  '${element.electronAffinity} kJ/mol'),
                              _buildPropertyRow('Electronegativity (Pauling)',
                                  '${element.electronegativityPauling}'),
                              _buildPropertyRow('Ionization Energies',
                                  element.ionizationEnergies.join(', ')),
                              _buildPropertyRow(
                                  'Shells', element.shells.join(', ')),
                            ],
                          ),
                        ),

                        // Discovery Information
                        _buildSection(
                          context,
                          title: 'Discovery Information',
                          icon: Icons.history,
                          content: Column(
                            children: [
                              _buildPropertyRow(
                                  'Discovered By', element.discoveredBy),
                              _buildPropertyRow('Named By', element.namedBy),
                              _buildPropertyRow('Year of Discovery',
                                  '${element.yearDiscovered}'),
                              _buildPropertyRow('Source', element.source),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProperty(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String property, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$property:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String category) {
    switch (category.toLowerCase()) {
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return Colors.green;
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'transition metal':
        return Colors.yellow.shade700;
      case 'metalloid':
        return Colors.purple;
      case 'halogen':
        return Colors.lightBlue;
      case 'noble gas':
        return Colors.blue;
      case 'lanthanide':
        return Colors.pink;
      case 'actinide':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
