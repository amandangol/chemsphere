import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../drugs/provider/drug_provider.dart';
import 'provider/bookmark_provider.dart';
import '../drugs/model/drug.dart';
import '../compounds/model/compound.dart';
import '../elements/model/periodic_element.dart'; // Import PeriodicElement
import '../drugs/drug_detail_screen.dart';
import '../compounds/compound_details_screen.dart';
import '../compounds/provider/compound_provider.dart';
import '../elements/element_detail_screen.dart'; // Import ElementDetailScreen
import '../../widgets/chemistry_widgets.dart'; // Import custom chemistry widgets
import 'dart:math';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarkedDrugs = bookmarkProvider.bookmarkedDrugs;
    final bookmarkedCompounds = bookmarkProvider.bookmarkedCompounds;
    final bookmarkedElements = bookmarkProvider.bookmarkedElements;
    final hasError = bookmarkProvider.lastError != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarks',
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
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
        bottom: (bookmarkedDrugs.isEmpty &&
                    bookmarkedCompounds.isEmpty &&
                    bookmarkedElements.isEmpty) ||
                hasError
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.white,
                indicatorColor: theme.colorScheme.primary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.medication, size: 20),
                    text: 'Drugs (${bookmarkedDrugs.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.science, size: 20),
                    text: 'Compounds (${bookmarkedCompounds.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.api, size: 20),
                    text: 'Elements (${bookmarkedElements.length})',
                  ),
                ],
              ),
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
            : (bookmarkedDrugs.isEmpty &&
                    bookmarkedCompounds.isEmpty &&
                    bookmarkedElements.isEmpty)
                ? _buildEmptyView(context)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Drugs Tab
                      bookmarkedDrugs.isEmpty
                          ? _buildEmptyCategoryView(
                              context, 'No drugs bookmarked')
                          : _buildDrugList(
                              context, bookmarkProvider, bookmarkedDrugs),

                      // Compounds Tab
                      bookmarkedCompounds.isEmpty
                          ? _buildEmptyCategoryView(
                              context, 'No compounds bookmarked')
                          : _buildCompoundList(
                              context, bookmarkProvider, bookmarkedCompounds),

                      // Elements Tab
                      bookmarkedElements.isEmpty
                          ? _buildEmptyCategoryView(
                              context, 'No elements bookmarked')
                          : _buildElementList(
                              context, bookmarkProvider, bookmarkedElements),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, BookmarkProvider provider) {
    final theme = Theme.of(context);
    return Center(
      child: ChemistryCardBackground(
        backgroundColor: Colors.white.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 14),
              Text(
                'Error loading bookmarks',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: theme.colorScheme.error,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                child: Text(
                  provider.lastError ?? 'Unknown error',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chemistry-themed empty state icon
              Container(
                width: 70,
                height: 70,
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
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Icon(
                          Icons.science,
                          size: 14,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No bookmarks yet',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save your favorite compounds and drugs to access them quickly',
                style: GoogleFonts.poppins(
                  fontSize: 13,
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

  Widget _buildEmptyCategoryView(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: ChemistryCardBackground(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.bookmark_border,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugList(
      BuildContext context, BookmarkProvider provider, List<Drug> drugs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      shrinkWrap: true,
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
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: ChemistryLoadingWidget(
                    message: 'Loading drug details...',
                  ),
                ),
              );

              // Get the drug provider to fetch the full details
              final drugProvider =
                  Provider.of<DrugProvider>(context, listen: false);
              drugProvider.clearSelectedDrug();

              // Fetch fresh data for the drug
              drugProvider.getDrug(drug.cid).then((updatedDrug) {
                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (context.mounted && drugProvider.error == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DrugDetailScreen(),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          drugProvider.error ?? 'Failed to load drug details'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }).catchError((e) {
                // Close loading dialog on error
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading details: ${e.toString()}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
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
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: ChemistryLoadingWidget(
                    message: 'Loading compound details...',
                  ),
                ),
              );

              // Get the compound provider to fetch the full details
              final compoundProvider =
                  Provider.of<CompoundProvider>(context, listen: false);
              compoundProvider.clearSelectedCompound();

              // Fetch fresh data for the compound
              compoundProvider
                  .getCompound(compound.cid)
                  .then((updatedCompound) {
                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);
                }

                if (context.mounted && compoundProvider.error == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompoundDetailsScreen(),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(compoundProvider.error ??
                          'Failed to load compound details'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }).catchError((e) {
                // Close loading dialog on error
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading details: ${e.toString()}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
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

  Widget _buildElementList(BuildContext context, BookmarkProvider provider,
      List<PeriodicElement> elements) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return _buildBookmarkCard(
          context,
          title: element.name,
          subtitle: '${element.symbol} · ${element.groupBlock}',
          imageUrl: '', // Elements don't have images
          customImage: Container(
            decoration: BoxDecoration(
              color: _getCategoryColor(element.groupBlock),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    element.symbol,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    element.atomicNumber.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ElementDetailScreen(element: element),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Error viewing element details: ${e.toString()}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onRemove: () async {
            final success =
                await provider.removeBookmark(element, BookmarkType.element);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? '${element.name} removed from bookmarks'
                      : 'Error removing bookmark'),
                  behavior: SnackBarBehavior.floating,
                  action: success
                      ? null
                      : SnackBarAction(
                          label: 'Retry',
                          onPressed: () => provider.removeBookmark(
                              element, BookmarkType.element),
                        ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    final theme = Theme.of(context);

    switch (category.toLowerCase()) {
      case 'nonmetal':
        return const Color(0xFF2E7D32);
      case 'alkali metal':
        return const Color(0xFFB82E2E);
      case 'alkaline earth metal':
        return const Color(0xFFE67700);
      case 'transition metal':
        return const Color(0xFFE67700).withOpacity(0.8);
      case 'metalloid':
        return theme.colorScheme.tertiary;
      case 'halogen':
        return theme.colorScheme.primary;
      case 'noble gas':
        return theme.colorScheme.primary;
      case 'lanthanide':
        return theme.colorScheme.tertiary;
      case 'actinide':
        return theme.colorScheme.tertiary;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBookmarkCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    Widget? customImage,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final theme = Theme.of(context);
    // Create separate widgets to completely isolate touch events
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ChemistryCardBackground(
        backgroundColor: Colors.white.withOpacity(0.95),
        showMolecules: false, // Keep card clean for content focus
        child: SizedBox(
          height: 130, // Fixed height for the card
          child: Stack(
            children: [
              // The main card content with the title, subtitle and chevron
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      children: [
                        // Spacer for the image area
                        const SizedBox(width: 130),

                        // Content area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    subtitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: theme.colorScheme.primary
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.primary,
                              size: 18,
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
                width: 130,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (customImage != null) {
                        // For elements we just navigate to details instead of fullscreen view
                        onTap();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => _FullScreenImageView(
                              imageUrl: imageUrl,
                              title: title,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: customImage ??
                            Stack(
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
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (context, error, stackTrace) =>
                                        Container(
                                      color: theme
                                          .colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
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
                top: -8,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_remove, size: 18),
                      color: theme.colorScheme.error,
                      iconSize: 18,
                      tooltip: 'Remove bookmark',
                      onPressed: onRemove,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
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
        backgroundColor: Colors.black.withOpacity(0.7),
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
