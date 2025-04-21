import 'package:flutter/material.dart';
import '../../elements/model/periodic_element.dart';

/// Main export file for all bookmark widgets
export 'bookmark_card.dart';
export 'bookmark_lists.dart';
export 'bookmark_empty_states.dart';
export 'fullscreen_image_view.dart';

/// Helper class for getting colors for element categories
class CategoryColorHelper {
  static Color getCategoryColor(BuildContext context, String category) {
    return PeriodicElement.getElementColor(category);
  }
}

/// Custom painter for molecule background pattern
class MoleculeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create some random points for molecule nodes
    final points = <Offset>[];
    for (int i = 0; i < 20; i++) {
      points.add(Offset(
        _pseudoRandom(i * 3, size.width),
        _pseudoRandom(i * 7, size.height),
      ));
    }

    // Draw connections between some points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        // Only connect some points based on distance
        final distance = (points[i] - points[j]).distance;
        if (distance < size.width / 4) {
          canvas.drawLine(points[i], points[j], paintLine);
        }
      }

      // Draw the node
      canvas.drawCircle(points[i], 4 + _pseudoRandom(i, 4), paintDot);
    }
  }

  // Deterministic "random" function to get consistent results
  double _pseudoRandom(int seed, double max) {
    return ((seed * 9301 + 49297) % 233280) / 233280 * max;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom tab indicator for bookmark tabs
class BookmarkTabIndicator extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const BookmarkTabIndicator({
    Key? key,
    required this.controller,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      controller: controller,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: Colors.white,
      indicatorColor: theme.colorScheme.primary,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      tabs: tabs,
    );
  }
}
