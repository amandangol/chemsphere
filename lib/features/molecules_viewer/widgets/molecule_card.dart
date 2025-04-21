import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoleculeCard extends StatelessWidget {
  final String name;
  final int cid;
  final String formula;
  final VoidCallback onTap;

  const MoleculeCard({
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Molecule 2D preview
            Hero(
              tag: 'molecule-preview-$cid',
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      _get2DImageUrl(cid),
                    ),
                    fit: BoxFit.contain,
                    onError: (exception, stackTrace) {
                      // Just log the error and let the fallback happen
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (formula.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.secondary,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            Text(
              'CID: $cid',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
