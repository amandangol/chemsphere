import 'package:flutter/material.dart';
import '../../../widgets/molecule_3d_viewer.dart';

/// A fullscreen 3D molecule viewer
/// Used as a standalone screen rather than within the FullscreenMoleculeView component

class Molecule3DFullscreen extends StatelessWidget {
  final int cid;
  final String title;

  const Molecule3DFullscreen({
    Key? key,
    required this.cid,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        // Use leading back button to ensure proper navigation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Molecule3DViewer(
          key: ValueKey('fullscreen_3d_${cid}'),
          cid: cid,
          isFullScreen: true,
        ),
      ),
    );
  }
}
