import 'package:flutter/material.dart';
import 'recent_molecule_item.dart';

class RecentMoleculesTab extends StatelessWidget {
  final List<Map<String, dynamic>> recentMolecules;
  final Function(int cid, String name, String formula) onMoleculeSelected;

  const RecentMoleculesTab({
    Key? key,
    required this.recentMolecules,
    required this.onMoleculeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recentMolecules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent molecules',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: recentMolecules.length,
        itemBuilder: (context, index) {
          final molecule = recentMolecules[index];
          return RecentMoleculeItem(
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
    );
  }
}
