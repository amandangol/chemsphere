import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

/// A chemistry-themed loading widget with animated elements
class ChemistryLoadingWidget extends StatelessWidget {
  final String message;

  const ChemistryLoadingWidget({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Atom loading animation
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Use Lottie animation if available, otherwise fallback to CircularProgressIndicator
                Lottie.asset(
                  'assets/lottie/atom_loading.json',
                  fit: BoxFit.contain,
                  frameRate: FrameRate.max,
                  errorBuilder: (context, error, stackTrace) =>
                      CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 4,
                  ),
                ),
                // Nucleus dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Loading text with chemistry-themed style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.science,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A chemistry-themed card background with molecule decorations
class ChemistryCardBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool showMolecules;

  const ChemistryCardBackground({
    super.key,
    required this.child,
    this.backgroundColor,
    this.showMolecules = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Molecule decoration elements (conditionally shown)
          if (showMolecules) ...[
            Positioned(
              top: 10,
              right: 10,
              child: _buildMoleculeElement(
                  12, theme.colorScheme.primary.withOpacity(0.1)),
            ),
            Positioned(
              bottom: 20,
              left: 15,
              child: _buildMoleculeElement(
                  8, theme.colorScheme.secondary.withOpacity(0.1)),
            ),
          ],
          // Actual content
          child,
        ],
      ),
    );
  }

  Widget _buildMoleculeElement(double size, Color color) {
    return SizedBox(
      width: size * 4,
      height: size * 3,
      child: CustomPaint(
        painter: MoleculePainter(color: color),
      ),
    );
  }
}

/// Custom painter for drawing simple molecule structures
class MoleculePainter extends CustomPainter {
  final Color color;

  MoleculePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw molecule structure - some circles connected by lines
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 8;

    // Draw atoms
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
        Offset(center.dx - size.width / 3, center.dy), radius * 0.8, paint);
    canvas.drawCircle(
        Offset(center.dx + size.width / 3, center.dy), radius * 0.8, paint);
    canvas.drawCircle(
        Offset(center.dx, center.dy - size.height / 3), radius * 0.6, paint);

    // Draw bonds
    canvas.drawLine(
        center, Offset(center.dx - size.width / 3, center.dy), linePaint);
    canvas.drawLine(
        center, Offset(center.dx + size.width / 3, center.dy), linePaint);
    canvas.drawLine(
        center, Offset(center.dx, center.dy - size.height / 3), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A chemistry-themed detail screen appbar/header with molecule decorations
class ChemistryDetailHeader extends StatelessWidget {
  final String title;
  final int cid;
  final Widget? trailing;
  final VoidCallback onImageTap;

  const ChemistryDetailHeader({
    super.key,
    required this.title,
    required this.cid,
    this.trailing,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primaryContainer,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: GestureDetector(
          onTap: onImageTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main Image
              Hero(
                tag: 'structure_$cid',
                child: CachedNetworkImage(
                  imageUrl:
                      'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.colorScheme.surface.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              // Floating molecular structures
              Positioned(
                top: 50,
                left: 20,
                child: Opacity(
                  opacity: 0.2,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CustomPaint(
                      painter: MoleculePainter(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 70,
                right: 30,
                child: Opacity(
                  opacity: 0.2,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CustomPaint(
                      painter: MoleculePainter(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A chemistry-themed fullscreen image view for molecular structures
class ChemistryFullScreenView extends StatelessWidget {
  final String title;
  final int cid;

  const ChemistryFullScreenView({
    super.key,
    required this.title,
    required this.cid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background pattern with molecules
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.indigo.shade900.withOpacity(0.7),
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _MolecularNetworkPainter(),
              ),
            ),
          ),

          // Main image content
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: 'structure_$cid',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load structure',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Formula display at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.science,
                      color: Colors.white.withOpacity(0.9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Molecular Structure',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery (coming soon)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Colors.blue.withOpacity(0.7),
        elevation: 4,
        child: const Icon(Icons.download, color: Colors.white),
      ),
    );
  }
}

/// A painter for molecular network background
class _MolecularNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw a network of molecules
    final random = Random(42); // Fixed seed for consistent pattern

    // Create some random points for molecule nodes
    final points = <Offset>[];
    for (int i = 0; i < 20; i++) {
      points.add(Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
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
      canvas.drawCircle(points[i], 4 + random.nextDouble() * 4, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
