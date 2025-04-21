import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/element_provider.dart';
import '../../model/periodic_element.dart';
import '../../model/element_description_data.dart';
import '../../../bookmarks/provider/bookmark_provider.dart';
import 'widgets/detail_widgets.dart';

class ElementDetailScreen extends StatelessWidget {
  final PeriodicElement? element;

  const ElementDetailScreen({Key? key, this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    // Use passed element or get it from provider
    final currentElement =
        element ?? Provider.of<ElementProvider>(context).selectedElement;

    if (currentElement == null) {
      return _buildEmptyState(context);
    }

    // Use standardized color from PeriodicElement class
    final color = currentElement.standardColor;
    final isBookmarked =
        bookmarkProvider.isBookmarked(currentElement, BookmarkType.element);

    // Get discovery information and description from static data
    final discoveryInfo =
        ElementDescriptionData.getDiscoveryInfo(currentElement.symbol);
    final description =
        ElementDescriptionData.getDescription(currentElement.symbol);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // App Bar
            ElementHeader(
              element: currentElement,
              isBookmarked: isBookmarked,
              onSharePressed: () => _handleShare(context),
              onBookmarkPressed: () => _handleBookmark(
                  context, currentElement, bookmarkProvider, isBookmarked),
            ),

            // Element Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Element Description Card
                    DescriptionSection(description: description),

                    // Quick facts card
                    QuickFactsSection(element: currentElement),

                    // Discovery Information
                    DiscoverySection(
                      element: currentElement,
                      discoveryInfo: discoveryInfo,
                    ),

                    // Electronic Properties
                    ElectronicPropertiesSection(element: currentElement),

                    // Physical Properties
                    PhysicalPropertiesSection(element: currentElement),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle share button press
  void _handleShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Handle bookmark toggle
  Future<void> _handleBookmark(
    BuildContext context,
    PeriodicElement element,
    BookmarkProvider bookmarkProvider,
    bool isBookmarked,
  ) async {
    if (isBookmarked) {
      await bookmarkProvider.removeBookmark(element, BookmarkType.element);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${element.name} removed from bookmarks'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await bookmarkProvider.addBookmark(element, BookmarkType.element);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${element.name} added to bookmarks'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Build empty state when no element is selected
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Element Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No element selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
