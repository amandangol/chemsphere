import 'package:flutter/material.dart';
import 'molecule_card.dart';

class FeaturedMoleculesTab extends StatelessWidget {
  final List<Map<String, dynamic>> featuredMolecules;
  final Function(int cid, String name, String formula) onMoleculeSelected;

  const FeaturedMoleculesTab({
    Key? key,
    required this.featuredMolecules,
    required this.onMoleculeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get unique categories
    final categories =
        featuredMolecules.map((m) => m['category'] as String).toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search guidance
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap any molecule to view its 2D/3D structure. You can also search for specific molecules by name above.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories and molecules
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final category in categories) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: featuredMolecules
                          .where((m) => m['category'] == category)
                          .length,
                      itemBuilder: (context, index) {
                        final molecule = featuredMolecules
                            .where((m) => m['category'] == category)
                            .toList()[index];
                        return MoleculeCard(
                          name: molecule['name'],
                          cid: molecule['cid'],
                          formula: molecule['formula'] ?? '',
                          onTap: () => onMoleculeSelected(
                            molecule['cid'],
                            molecule['name'],
                            molecule['formula'] ?? '',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
