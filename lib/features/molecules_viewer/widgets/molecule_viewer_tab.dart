import 'package:flutter/material.dart';
import '../../../widgets/chemistry_widgets.dart';
import '../../../widgets/molecule_3d_viewer.dart';
import 'molecule_2d_viewer.dart';

class MoleculeViewerTab extends StatelessWidget {
  final int? currentCid;
  final String currentMoleculeName;
  final String currentFormula;
  final bool isLoading;
  final String? error;
  final bool is2DView;
  final VoidCallback onToggleView;
  final VoidCallback onFullScreenToggle;
  final VoidCallback onRetry;
  final VoidCallback onViewPubChem;

  const MoleculeViewerTab({
    Key? key,
    required this.currentCid,
    required this.currentMoleculeName,
    required this.currentFormula,
    required this.isLoading,
    this.error,
    required this.is2DView,
    required this.onToggleView,
    required this.onFullScreenToggle,
    required this.onRetry,
    required this.onViewPubChem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (currentCid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a molecule or select one from\nFeatured or Recent tabs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: ChemistryLoadingWidget(
          message: 'Loading molecule data...',
        ),
      );
    }

    if (error != null) {
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
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Molecule name with view toggle
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                currentMoleculeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              if (currentFormula.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    currentFormula,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.secondary,
                      fontFamily: 'JetBrainsMono',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),

        // View type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            is2DView ? '2D Structure' : '3D Structure',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Molecule viewer (2D or 3D based on toggle)
        Expanded(
          child: is2DView
              ? Molecule2DViewer(
                  key: ValueKey('2d_viewer_$currentCid'),
                  cid: currentCid!,
                )
              : Complete3DMoleculeViewer(
                  key: ValueKey('3d_viewer_$currentCid'),
                  cid: currentCid!,
                ),
        ),

        // Action buttons at the bottom
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: Icon(Icons.swap_horiz),
                label: Text(is2DView ? 'View 3D' : 'View 2D'),
                onPressed: onToggleView,
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.info_outline),
                label: Text('PubChem'),
                onPressed: onViewPubChem,
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.fullscreen),
                label: Text('Full Screen'),
                onPressed: onFullScreenToggle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
