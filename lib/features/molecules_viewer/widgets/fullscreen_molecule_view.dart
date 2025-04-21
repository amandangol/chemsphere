import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'molecule_2d_viewer.dart';
import 'fullscreen_title_overlay.dart';
import 'fullscreen_controls.dart';
import '../../../widgets/molecule_3d_viewer.dart';

class FullscreenMoleculeView extends StatelessWidget {
  final int cid;
  final String moleculeName;
  final String formula;
  final bool is2DView;
  final VoidCallback onToggleView;
  final VoidCallback onExitFullscreen;

  const FullscreenMoleculeView({
    Key? key,
    required this.cid,
    required this.moleculeName,
    this.formula = '',
    required this.is2DView,
    required this.onToggleView,
    required this.onExitFullscreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set system UI to immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return WillPopScope(
      // Handle back button presses
      onWillPop: () async {
        // Restore system UI when exiting
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        onExitFullscreen();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Full screen viewer based on current view mode
            SizedBox.expand(
              child: is2DView
                  ? Molecule2DViewer(
                      key: ValueKey('fullscreen_2d_$cid'),
                      cid: cid,
                      isFullScreen: true,
                    )
                  : Complete3DMoleculeViewer(
                      key: ValueKey('fullscreen_3d_$cid'),
                      cid: cid,
                      isFullScreen: true,
                    ),
            ),

            // Controls overlay for full screen mode
            FullscreenControls(
              is2DView: is2DView,
              onToggleView: onToggleView,
              onExitFullscreen: () {
                // Restore system UI when exiting
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                onExitFullscreen();
              },
            ),

            // Molecule name and formula overlay at the top
            FullscreenTitleOverlay(
              moleculeName: moleculeName,
              formula: formula,
            ),
          ],
        ),
      ),
    );
  }
}
