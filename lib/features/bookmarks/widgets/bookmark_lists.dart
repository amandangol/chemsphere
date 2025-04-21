import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'bookmark_card.dart';
import 'bookmark_empty_states.dart';

/// Widget for displaying a list of bookmarks
class BookmarkList extends StatelessWidget {
  final List<Map<String, dynamic>> bookmarks;
  final void Function(Map<String, dynamic>) onTapBookmark;
  final void Function(Map<String, dynamic>) onRemoveBookmark;
  final bool isLoading;
  final String emptyMessage;

  const BookmarkList({
    Key? key,
    required this.bookmarks,
    required this.onTapBookmark,
    required this.onRemoveBookmark,
    this.isLoading = false,
    this.emptyMessage = 'No bookmarks in this category',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (bookmarks.isEmpty) {
      return EmptyCategoryWidget(message: emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildBookmarkItem(bookmark),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading bookmarks...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(Map<String, dynamic> bookmark) {
    final String type = bookmark['type'] ?? 'unknown';

    // Handle different types of bookmarks
    switch (type) {
      case 'element':
        return _buildElementBookmark(bookmark);
      case 'drug':
        return _buildDrugBookmark(bookmark);
      case 'compound':
        return _buildCompoundBookmark(bookmark);
      default:
        return _buildGenericBookmark(bookmark);
    }
  }

  Widget _buildElementBookmark(Map<String, dynamic> bookmark) {
    final element = bookmark['data'];
    return BookmarkCard(
      title: element['name'] ?? 'Unknown Element',
      subtitle: 'Atomic Number: ${element['atomicNumber'] ?? 'N/A'}',
      imageUrl: '', // Elements don't have external images
      customImage: ElementImageCard(
        symbol: element['symbol'] ?? '?',
        atomicNumber: int.parse(element['atomicNumber']?.toString() ?? '0'),
        groupBlock: element['groupBlock'] ?? 'unknown',
      ),
      onTap: () => onTapBookmark(bookmark),
      onRemove: () => onRemoveBookmark(bookmark),
    );
  }

  Widget _buildCompoundBookmark(Map<String, dynamic> bookmark) {
    final compound = bookmark['data'];
    return BookmarkCard(
      title: compound['name'] ?? 'Unknown Compound',
      subtitle: compound['molecularFormula'] ?? 'Formula unavailable',
      imageUrl: compound['imageUrl'],
      onTap: () => onTapBookmark(bookmark),
      onRemove: () => onRemoveBookmark(bookmark),
    );
  }

  Widget _buildDrugBookmark(Map<String, dynamic> bookmark) {
    final drug = bookmark['data'];
    return BookmarkCard(
      title: drug['name'] ?? 'Unknown Drug',
      subtitle: drug['description'] != null && drug['description'].length > 0
          ? '${drug['description'].substring(0, min(70, drug['description'].length as int))}${drug['description'].length > 70 ? '...' : ''}'
          : 'No description available',
      imageUrl: drug['imageUrl'],
      onTap: () => onTapBookmark(bookmark),
      onRemove: () => onRemoveBookmark(bookmark),
    );
  }

  Widget _buildGenericBookmark(Map<String, dynamic> bookmark) {
    return BookmarkCard(
      title: bookmark['title'] ?? 'Unknown',
      subtitle: bookmark['subtitle'] ?? '',
      imageUrl: bookmark['imageUrl'],
      onTap: () => onTapBookmark(bookmark),
      onRemove: () => onRemoveBookmark(bookmark),
    );
  }
}

/// Widget for displaying a grid of bookmarks
class BookmarkGrid extends StatelessWidget {
  final List<Map<String, dynamic>> bookmarks;
  final void Function(Map<String, dynamic>) onTapBookmark;
  final void Function(Map<String, dynamic>) onRemoveBookmark;
  final bool isLoading;
  final String emptyMessage;

  const BookmarkGrid({
    Key? key,
    required this.bookmarks,
    required this.onTapBookmark,
    required this.onRemoveBookmark,
    this.isLoading = false,
    this.emptyMessage = 'No bookmarks in this category',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading bookmarks...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (bookmarks.isEmpty) {
      return EmptyCategoryWidget(message: emptyMessage);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        // You could create a different grid card widget here
        // For now, we'll just use a simplified version of the list card
        return _buildGridItem(bookmark);
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> bookmark) {
    final String type = bookmark['type'] ?? 'unknown';
    final data = bookmark['data'] ?? {};

    String title = 'Unknown';
    String subtitle = '';
    String? imageUrl;
    Widget? customImage;

    switch (type) {
      case 'element':
        title = data['name'] ?? 'Unknown Element';
        subtitle = data['symbol'] ?? '';
        customImage = ElementImageCard(
          symbol: data['symbol'] ?? '?',
          atomicNumber: int.parse(data['atomicNumber']?.toString() ?? '0'),
          groupBlock: data['groupBlock'] ?? 'unknown',
        );
        break;
      case 'compound':
        title = data['name'] ?? 'Unknown Compound';
        subtitle = data['molecularFormula'] ?? '';
        imageUrl = data['imageUrl'];
        break;
      case 'drug':
        title = data['name'] ?? 'Unknown Drug';
        imageUrl = data['imageUrl'];
        break;
      default:
        title = bookmark['title'] ?? 'Unknown';
        subtitle = bookmark['subtitle'] ?? '';
        imageUrl = bookmark['imageUrl'];
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTapBookmark(bookmark),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customImage != null)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        child: customImage,
                      ),
                    )
                  else if (imageUrl != null && imageUrl.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.science,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => onRemoveBookmark(bookmark),
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
