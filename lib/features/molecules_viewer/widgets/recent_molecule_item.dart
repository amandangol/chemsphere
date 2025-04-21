import 'package:flutter/material.dart';

class RecentMoleculeItem extends StatelessWidget {
  final String name;
  final int cid;
  final String formula;
  final VoidCallback onTap;

  const RecentMoleculeItem({
    Key? key,
    required this.name,
    required this.cid,
    this.formula = '',
    required this.onTap,
  }) : super(key: key);

  // Generate URL for 2D image of molecule
  String _get2DImageUrl(int cid) {
    return 'https://pubchem.ncbi.nlm.nih.gov/image/imgsrv.fcgi?cid=$cid&t=l';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Hero(
          tag: 'molecule-2d-$cid',
          child: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: NetworkImage(_get2DImageUrl(cid)),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback if image fails to load
              return null;
            },
            child: Icon(
              Icons.view_in_ar,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (formula.isNotEmpty)
              Text(
                formula,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.secondary,
                ),
              ),
            Text(
              'CID: $cid',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        isThreeLine: formula.isNotEmpty,
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
