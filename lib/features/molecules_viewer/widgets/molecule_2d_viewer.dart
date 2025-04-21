import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Molecule2DViewer extends StatelessWidget {
  final int cid;
  final bool isFullScreen;

  const Molecule2DViewer({
    Key? key,
    required this.cid,
    this.isFullScreen = false,
  }) : super(key: key);

  // Generate URL for 2D image of molecule
  String _get2DImageUrl(int cid) {
    return 'https://pubchem.ncbi.nlm.nih.gov/image/imgsrv.fcgi?cid=$cid&t=l';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isFullScreen) {
      return _buildFullScreenView(theme);
    } else {
      return _buildNormalView(theme);
    }
  }

  // Build the normal 2D view of the molecule
  Widget _buildNormalView(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 2D image from PubChem
              CachedNetworkImage(
                imageUrl: _get2DImageUrl(cid),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: theme.colorScheme.error),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load 2D structure',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
                fit: BoxFit.contain,
              ),

              // Zoom instructions overlay
              Positioned(
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pinch to zoom',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the full screen 2D view
  Widget _buildFullScreenView(ThemeData theme) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(50),
      minScale: 0.5,
      maxScale: 8.0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: _get2DImageUrl(cid),
            placeholder: (context, url) =>
                const CircularProgressIndicator(color: Colors.white),
            errorWidget: (context, url, error) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Failed to load 2D structure',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
