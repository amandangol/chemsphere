import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/chemistry_widgets.dart';
import '../../elements/model/periodic_element.dart';
import '../../../features/elements/model/periodic_element.dart';
import 'bookmark_widgets.dart';

/// Widget for a bookmark card that can be used for any type of bookmarked item
class BookmarkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Widget? customImage;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const BookmarkCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.customImage,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _buildMainContent(context, theme),

              // Image - in its own layer to prevent event propagation
              _buildImageSection(context),

              // Remove button - on its own layer
              _buildRemoveButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme) {
    return Positioned.fill(
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
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: theme.colorScheme.primary.withOpacity(0.8),
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
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
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
                  builder: (context) => FullScreenImageView(
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
              child: customImage ?? _buildNetworkImage(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(ThemeData theme) {
    return Stack(
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
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, error, stackTrace) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(ThemeData theme) {
    return Positioned(
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
    );
  }
}

/// Element image for bookmark card
class ElementImageCard extends StatelessWidget {
  final String symbol;
  final int atomicNumber;
  final String groupBlock;

  const ElementImageCard({
    Key? key,
    required this.symbol,
    required this.atomicNumber,
    required this.groupBlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PeriodicElement.getElementColor(groupBlock),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              atomicNumber.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
