import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'provider/bookmark_provider.dart';
import '../drugs/model/drug.dart';
import '../compounds/model/compound.dart';
import '../drugs/drug_detail_screen.dart';
import '../compounds/compound_details_screen.dart';
import '../../widgets/chemistry_widgets.dart'; // Import custom chemistry widgets
import 'dart:math';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarkedDrugs = bookmarkProvider.bookmarkedDrugs;
    final bookmarkedCompounds = bookmarkProvider.bookmarkedCompounds;
    final hasError = bookmarkProvider.lastError != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload bookmarks',
            onPressed: () async {
              await bookmarkProvider.reloadBookmarks();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmarks reloaded'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Chemistry-themed background
          image: DecorationImage(
            image: const AssetImage('assets/images/chemistry_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.95),
              BlendMode.luminosity,
            ),
          ),
        ),
        child: hasError
            ? _buildErrorView(context, bookmarkProvider)
            : (bookmarkedDrugs.isEmpty && bookmarkedCompounds.isEmpty)
                ? _buildEmptyView(context)
                : _buildBookmarksView(context, bookmarkProvider,
                    bookmarkedDrugs, bookmarkedCompounds),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, BookmarkProvider provider) {
    return Center(
      child: ChemistryCardBackground(
        backgroundColor: Colors.white.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading bookmarks',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Text(
                  provider.lastError ?? 'Unknown error',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: () => provider.reloadBookmarks(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ChemistryCardBackground(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chemistry-themed empty state icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 44,
                        color: theme.colorScheme.primary,
                      ),
                      Positioned(
                        top: 18,
                        right: 18,
                        child: Icon(
                          Icons.science,
                          size: 16,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No bookmarks yet',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save your favorite compounds and drugs to access them quickly',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksView(
      BuildContext context,
      BookmarkProvider bookmarkProvider,
      List<Drug> bookmarkedDrugs,
      List<Compound> bookmarkedCompounds) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bookmarkedDrugs.isNotEmpty) ...[
            _buildSectionHeader(context, 'Drugs'),
            _buildDrugList(context, bookmarkProvider, bookmarkedDrugs),
          ],
          if (bookmarkedCompounds.isNotEmpty) ...[
            _buildSectionHeader(context, 'Compounds'),
            _buildCompoundList(context, bookmarkProvider, bookmarkedCompounds),
          ],
          // Add some space at the bottom
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              title == 'Drugs' ? Icons.medication : Icons.science,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugList(
      BuildContext context, BookmarkProvider provider, List<Drug> drugs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: drugs.length,
      itemBuilder: (context, index) {
        final drug = drugs[index];
        return _buildBookmarkCard(
          context,
          title: drug.title,
          subtitle: drug.molecularFormula,
          imageUrl:
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug.cid}/PNG',
          onTap: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrugDetailScreen(selectedDrug: drug),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error viewing drug details: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onRemove: () async {
            final success =
                await provider.removeBookmark(drug, BookmarkType.drug);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? '${drug.title} removed from bookmarks'
                      : 'Error removing bookmark'),
                  behavior: SnackBarBehavior.floating,
                  action: success
                      ? null
                      : SnackBarAction(
                          label: 'Retry',
                          onPressed: () =>
                              provider.removeBookmark(drug, BookmarkType.drug),
                        ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCompoundList(BuildContext context, BookmarkProvider provider,
      List<Compound> compounds) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: compounds.length,
      itemBuilder: (context, index) {
        final compound = compounds[index];
        return _buildBookmarkCard(
          context,
          title: compound.title,
          subtitle: compound.molecularFormula,
          imageUrl:
              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${compound.cid}/PNG',
          onTap: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CompoundDetailsScreen(selectedCompound: compound),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Error viewing compound details: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onRemove: () async {
            final success =
                await provider.removeBookmark(compound, BookmarkType.compound);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? '${compound.title} removed from bookmarks'
                      : 'Error removing bookmark'),
                  behavior: SnackBarBehavior.floating,
                  action: success
                      ? null
                      : SnackBarAction(
                          label: 'Retry',
                          onPressed: () => provider.removeBookmark(
                              compound, BookmarkType.compound),
                        ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    // Create separate widgets to completely isolate touch events
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ChemistryCardBackground(
        backgroundColor: Colors.white.withOpacity(0.95),
        showMolecules: false, // Keep card clean for content focus
        child: SizedBox(
          height: 144, // Fixed height for the card
          child: Stack(
            children: [
              // The main card content with the title, subtitle and chevron
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      children: [
                        // Spacer for the image area
                        const SizedBox(width: 144),

                        // Content area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Chevron icon
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Image - in its own layer to prevent event propagation
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 144,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => _FullScreenImageView(
                            imageUrl: imageUrl,
                            title: title,
                          ),
                        ),
                      );
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            // Add a subtle gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.1),
                                      Colors.purple.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Image with hero animation
                            Hero(
                              tag: "image_$imageUrl",
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, error, stackTrace) =>
                                    Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Remove button - on its own layer
              Positioned(
                right: 0,
                top: -10,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_remove),
                      color: Theme.of(context).colorScheme.error,
                      iconSize: 20,
                      tooltip: 'Remove bookmark',
                      onPressed: onRemove,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.title,
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
              // Show a snackbar indicating the image would be shared
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
                painter: MoleculeBackgroundPainter(),
              ),
            ),
          ),

          // Main image content
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: "image_$imageUrl", // Match the unique tag from card view
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
                    imageUrl: imageUrl,
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
                          'Failed to load image',
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

          // Chemical formula display at bottom
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
                      'Chemical Structure',
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
          // Show a snackbar indicating the image would be saved
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
