import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/element_provider.dart';
import '../../widgets/chemistry_widgets.dart';
import 'model/periodic_element.dart';
import 'model/element_description_data.dart';

class ElementDetailScreen extends StatelessWidget {
  final PeriodicElement? element;

  const ElementDetailScreen({Key? key, this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use passed element or get it from provider
    final currentElement =
        element ?? Provider.of<ElementProvider>(context).selectedElement;

    if (currentElement == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Element Details'),
        ),
        body: Center(
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
        ),
      );
    }

    final color = _getElementColor(currentElement.groupBlock);

    // Get discovery information and description from static data
    final discoveryInfo =
        ElementDescriptionData.getDiscoveryInfo(currentElement.symbol);
    final description =
        ElementDescriptionData.getDescription(currentElement.symbol);

    return Scaffold(
      body: Container(
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
                  currentElement.name,
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
                        currentElement.symbol,
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
                                  'Atomic Number: ${currentElement.atomicNumber}',
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
                                  currentElement.groupBlock,
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
                    // Element Description Card
                    _buildSection(
                      context,
                      title: 'Description',
                      icon: Icons.description,
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),

                    // Quick facts card
                    _buildSection(
                      context,
                      title: 'Quick Facts',
                      icon: Icons.info_outline,
                      content: GridView.count(
                        padding: const EdgeInsets.all(0),
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildProperty('Atomic Mass',
                              '${_formatValue(currentElement.formattedAtomicMass)} u'),
                          _buildProperty('Phase',
                              _formatValue(currentElement.standardState)),
                          _buildProperty('Density',
                              '${_formatValue(currentElement.density)} g/cm³'),
                          _buildProperty('Atomic Radius',
                              '${_formatValue(currentElement.atomicRadius)} pm'),
                          _buildProperty('Group Block',
                              _formatValue(currentElement.groupBlock)),
                          _buildProperty('Year Discovered',
                              _formatValue(currentElement.yearDiscovered)),
                        ],
                      ),
                    ),

                    // Discovery Information
                    _buildSection(
                      context,
                      title: 'Discovery Information',
                      icon: Icons.history_edu,
                      content: Column(
                        children: [
                          _buildPropertyRow(
                              'Discovered By', discoveryInfo['discoveredBy']!),
                          _buildPropertyRow(
                              'Named By', discoveryInfo['namedBy']!),
                          _buildPropertyRow('Year',
                              _formatValue(currentElement.yearDiscovered)),
                        ],
                      ),
                    ),

                    // Electronic Properties
                    _buildSection(
                      context,
                      title: 'Electronic Properties',
                      icon: Icons.bolt,
                      content: Column(
                        children: [
                          _buildPropertyRow(
                              'Electron Configuration',
                              _formatValue(
                                  currentElement.electronConfiguration)),
                          _buildPropertyRow('Electronegativity',
                              _formatValue(currentElement.electronegativity)),
                          _buildPropertyRow('Electron Affinity',
                              '${_formatValue(currentElement.electronAffinity)} eV'),
                          _buildPropertyRow('Ionization Energy',
                              '${_formatValue(currentElement.ionizationEnergy)} eV'),
                          _buildPropertyRow('Oxidation States',
                              _formatValue(currentElement.oxidationStates)),
                        ],
                      ),
                    ),

                    // Physical Properties
                    _buildSection(
                      context,
                      title: 'Physical Properties',
                      icon: Icons.science,
                      content: Column(
                        children: [
                          _buildPropertyRow('Standard State',
                              _formatValue(currentElement.standardState)),
                          _buildPropertyRow('Density',
                              '${_formatValue(currentElement.density)} ${currentElement.standardState.toLowerCase() == "gas" ? "g/L" : "g/cm³"}'),
                          _buildPropertyRow('Melting Point',
                              '${_formatValue(currentElement.meltingPoint)} K'),
                          _buildPropertyRow('Boiling Point',
                              '${_formatValue(currentElement.boilingPoint)} K'),
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
      ),
    );
  }

  // Helper to format values - display N/A for 0 or empty values
  String _formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    // For numeric values, check if they're zero
    if (value is num || value is String && double.tryParse(value) != null) {
      double? numValue;
      if (value is num) {
        numValue = value.toDouble();
      } else {
        numValue = double.tryParse(value.toString());
      }

      if (numValue != null && numValue == 0) {
        return 'N/A';
      }
    }

    return value.toString();
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            value.isEmpty ? 'N/A' : value,
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
      case 'nonmetal':
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
