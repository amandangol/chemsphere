import 'package:flutter/material.dart';

class FullscreenControls extends StatelessWidget {
  final bool is2DView;
  final VoidCallback onToggleView;
  final VoidCallback onExitFullscreen;

  const FullscreenControls({
    Key? key,
    required this.is2DView,
    required this.onToggleView,
    required this.onExitFullscreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2D/3D toggle button
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                is2DView ? Icons.view_in_ar : Icons.image,
                color: Colors.white,
              ),
              tooltip: is2DView ? 'Switch to 3D View' : 'Switch to 2D View',
              onPressed: onToggleView,
            ),
          ),

          // Exit full screen button
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Tooltip(
              message: 'Exit Full Screen',
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: onExitFullscreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
