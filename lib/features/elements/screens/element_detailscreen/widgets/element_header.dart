import 'package:flutter/material.dart';
import '../../../model/periodic_element.dart';

/// Widget for displaying the element header in the sliver app bar
class ElementHeader extends StatelessWidget {
  final PeriodicElement element;
  final bool isBookmarked;
  final VoidCallback onSharePressed;
  final VoidCallback onBookmarkPressed;

  const ElementHeader({
    Key? key,
    required this.element,
    required this.isBookmarked,
    required this.onSharePressed,
    required this.onBookmarkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use standardized color
    final color = element.standardColor;

    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: color,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          element.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withOpacity(0.8),
                    color,
                  ],
                ),
              ),
            ),
            // Symbol watermark
            Positioned(
              right: -20,
              bottom: -20,
              child: Text(
                element.symbol,
                style: TextStyle(
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            // Element info
            Positioned(
              bottom: 60,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoChip('Atomic Number: ${element.atomicNumber}'),
                      const SizedBox(width: 8),
                      _buildInfoChip(element.groupBlock),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          color: Colors.white,
          onPressed: onSharePressed,
        ),
        IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          ),
          color: Colors.white,
          onPressed: onBookmarkPressed,
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
