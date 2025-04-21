import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:io'; // Import for SocketException
import '../utils/error_handler.dart';

class CustomSearchScreen extends StatefulWidget {
  final String title;
  final String hintText;
  final IconData searchIcon;
  final List<String> quickSearchItems;
  final List<String> historyItems;
  final bool isLoading;
  final String? error;
  final List<dynamic> items;
  final Function(String) onSearch;
  final Function() onClear;
  final Function(dynamic) onItemTap;
  final Function(dynamic)? onQuickSearchTap;
  final Function(String) onAutoComplete;
  final Widget Function(dynamic) itemBuilder;
  final String emptyMessage;
  final String emptySubMessage;
  final IconData emptyIcon;
  final int itemCount;
  final String? imageUrl;
  final List<Widget>? actions;
  final Widget? customHeader;
  final bool showSearchResults;

  const CustomSearchScreen({
    Key? key,
    required this.title,
    required this.hintText,
    required this.searchIcon,
    required this.quickSearchItems,
    this.historyItems = const [],
    required this.isLoading,
    required this.error,
    required this.items,
    required this.onSearch,
    required this.onClear,
    required this.onItemTap,
    this.onQuickSearchTap,
    required this.onAutoComplete,
    required this.itemBuilder,
    required this.emptyMessage,
    required this.emptySubMessage,
    required this.emptyIcon,
    this.itemCount = 6,
    this.imageUrl,
    this.actions,
    this.customHeader,
    this.showSearchResults = true,
  }) : super(key: key);

  @override
  State<CustomSearchScreen> createState() => _CustomSearchScreenState();
}

class _CustomSearchScreenState extends State<CustomSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    if (_suggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      _searchController.text = _suggestions[index];
                      widget.onSearch(_suggestions[index]);
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _updateSuggestions(String query) async {
    if (query.length < 3 || widget.onAutoComplete == null) {
      setState(() {
        _suggestions = [];
      });
      _removeOverlay();
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final suggestions = await widget.onAutoComplete!(query);
      setState(() {
        _suggestions = suggestions;
      });
      _showSuggestionsOverlay();
    } catch (e) {
      print('Error fetching suggestions: $e');
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onClear();
    setState(() {
      _isSearching = false;
      _suggestions = [];
    });
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with animated background
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                background: Stack(
                  children: [
                    // Background molecular patterns
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.7,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrl ??
                              'https://i.pinimg.com/736x/52/5d/a0/525da07405f9bd105c0263a319ddcee0.jpg',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.primaryContainer,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) {
                            // Improved error handling for background image
                            print('Error loading background image: $error');
                            if (error is SocketException ||
                                ErrorHandler.isNetworkError(error)) {
                              // For network errors, use a gradient background instead
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary
                                          .withOpacity(0.9),
                                      theme.colorScheme.primaryContainer,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.wifi_off,
                                    color: theme.colorScheme.onPrimary
                                        .withOpacity(0.3),
                                    size: 32,
                                  ),
                                ),
                              );
                            }

                            // For other errors, show a simple colored background
                            return Container(
                              color: theme.colorScheme.primaryContainer,
                            );
                          },
                          // Add better error handling for the background image
                          fadeInDuration: const Duration(milliseconds: 300),
                          useOldImageOnUrlChange: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main content area
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.primaryContainer.withOpacity(0.1),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field with animated container
                    Hero(
                      tag: 'search_field',
                      child: CompositedTransformTarget(
                        link: _layerLink,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.15),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: widget.hintText,
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    widget.searchIcon,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                suffixIcon: _isLoadingSuggestions
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear,
                                                size: 20),
                                            onPressed: _clearSearch,
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              Icons.search,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                            onPressed: () => widget.onSearch(
                                                _searchController.text),
                                          ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _isSearching = value.isNotEmpty;
                                });
                                _updateSuggestions(value);
                              },
                              onSubmitted: widget.onSearch,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Custom Header for educational content
                    if (widget.customHeader != null) ...[
                      widget.customHeader!,
                      const SizedBox(height: 16),
                    ],

                    // Quick search section with animated cards
                    if (!_isSearching && _searchController.text.isEmpty) ...[
                      if (widget.historyItems.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Recent Searches',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        AnimationLimiter(
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 3,
                            ),
                            itemCount:
                                widget.historyItems.length > widget.itemCount
                                    ? widget.itemCount
                                    : widget.historyItems.length,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: InkWell(
                                      onTap: () {
                                        _searchController.text =
                                            widget.historyItems[index];
                                        widget.onSearch(
                                            widget.historyItems[index]);
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: theme.colorScheme
                                              .surfaceContainerHighest,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.shadowColor
                                                  .withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.history,
                                                size: 14,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  widget.historyItems[index],
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Search',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimationLimiter(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: widget.quickSearchItems.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 400),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.onQuickSearchTap != null) {
                                        widget.onQuickSearchTap!(
                                            widget.quickSearchItems[index]);
                                      } else {
                                        _searchController.text =
                                            widget.quickSearchItems[index];
                                        widget.onSearch(
                                            widget.quickSearchItems[index]);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: index % 3 == 0
                                            ? theme.colorScheme.primaryContainer
                                            : index % 3 == 1
                                                ? theme.colorScheme
                                                    .secondaryContainer
                                                : theme.colorScheme
                                                    .tertiaryContainer,
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.shadowColor
                                                .withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                          child: Text(
                                            widget.quickSearchItems[index],
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                              color: index % 3 == 0
                                                  ? theme.colorScheme
                                                      .onPrimaryContainer
                                                  : index % 3 == 1
                                                      ? theme.colorScheme
                                                          .onSecondaryContainer
                                                      : theme.colorScheme
                                                          .onTertiaryContainer,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Results area
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (widget.isLoading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Searching...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.error != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline,
                            size: 36,
                            color: theme.colorScheme.inversePrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Occurred',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.error!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              widget.onSearch(_searchController.text),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(
                            'Retry',
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.items.isEmpty && _isSearching)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off,
                            size: 36,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Try different keywords or check the spelling',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.items.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.emptyIcon,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.emptyMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            widget.emptySubMessage,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.searchIcon,
                                size: 12,
                                color: theme.colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.items.length} results',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(
                    widget.items.length,
                    (index) => AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: widget.itemBuilder(widget.items[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
