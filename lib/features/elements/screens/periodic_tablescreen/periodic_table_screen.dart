import 'package:chem_explore/widgets/chemistry_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../utils/error_handler.dart';
import '../../provider/element_provider.dart';
import '../../model/periodic_element.dart';
import '../element_detailscreen/element_detail_screen.dart';
import '../modern_periodictable/modern_periodic_table_screen.dart';
import 'widgets/periodic_table_widgets.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen>
    with SingleTickerProviderStateMixin {
  bool _isGridView = true;
  String _filterCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<PeriodicElement> _filteredElements = [];
  bool _showInfoCard = true;

  @override
  void initState() {
    super.initState();
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _updateFilteredElements(
            Provider.of<ElementProvider>(context, listen: false).elements);
      });
    });

    // Fetch elements when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElementProvider>().fetchFlashcardElements();
    });
  }

  void _updateFilteredElements(List<PeriodicElement> elements) {
    setState(() {
      _filteredElements = elements.where((element) {
        final matchesCategory = _filterCategory == 'All' ||
            element.groupBlock.toLowerCase() == _filterCategory.toLowerCase();
        final matchesSearch = _searchQuery.isEmpty ||
            element.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            element.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            element.atomicNumber.toString().contains(_searchQuery);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.watch<ElementProvider>();
    if (!provider.isLoading && provider.error == null) {
      _updateFilteredElements(provider.elements);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToModernView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernPeriodicTableScreen(),
      ),
    );
  }

  void _navigateToElementDetail(PeriodicElement element) {
    context.read<ElementProvider>().setSelectedElement(element.symbol);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            ElementDetailScreen(element: element),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.5),
              theme.colorScheme.surface,
              theme.colorScheme.tertiaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated App Bar
              _buildAnimatedWidget(
                offsetY: -0.2,
                child: PeriodicTableHeader(
                  isGridView: _isGridView,
                  onToggleView: () {
                    setState(() {
                      _isGridView = !_isGridView;
                      _animationController.reset();
                      _animationController.forward();
                    });
                  },
                  onModernViewTap: _navigateToModernView,
                  onRefresh: (forceRefresh) {
                    context
                        .read<ElementProvider>()
                        .fetchFlashcardElements(forceRefresh: forceRefresh);
                    _showSnackBar(forceRefresh
                        ? 'Fetching fresh data...'
                        : 'Refreshing elements...');
                  },
                  onClearCache: () {
                    context.read<ElementProvider>().clearCache();
                    _showSnackBar('Cache cleared');
                  },
                ),
              ),

              // Educational Info Card
              _buildAnimatedWidget(
                offsetY: -0.15,
                child: EducationalInfoCard(
                  visible: _showInfoCard,
                  onClose: () {
                    setState(() {
                      _showInfoCard = false;
                    });
                  },
                ),
              ),

              // Info banner for traditional view
              _buildAnimatedWidget(
                offsetY: -0.15,
                child: ModernViewBanner(
                  onTap: _navigateToModernView,
                  onArrowTap: _navigateToModernView,
                ),
              ),

              // Search Bar
              _buildAnimatedWidget(
                offsetY: -0.1,
                child: ElementSearchBar(
                  controller: _searchController,
                  searchQuery: _searchQuery,
                  onClear: () {
                    setState(() {
                      _searchController.clear();
                      // Filter will be applied by the listener
                    });
                  },
                ),
              ),

              // Category filter with animation
              _buildAnimatedWidget(
                offsetY: -0.05,
                child: ElementCategoryFilter(
                  selectedCategory: _filterCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _filterCategory = category;
                      // Apply filter immediately when category changes
                      _updateFilteredElements(
                          Provider.of<ElementProvider>(context, listen: false)
                              .elements);
                    });
                  },
                ),
              ),

              // Element display (grid or list)
              Expanded(
                child: Consumer<ElementProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const ChemistryLoadingWidget(
                          message: 'Loading elements...');
                    }

                    if (provider.error != null) {
                      return ErrorHandler.buildErrorWidget(
                        errorMessage:
                            ErrorHandler.getErrorMessage(provider.error),
                        onRetry: () => provider.fetchFlashcardElements(),
                        iconColor: theme.colorScheme.error,
                      );
                    }

                    if (_filteredElements.isEmpty) {
                      return _buildEmptyState(theme);
                    }

                    return FadeTransition(
                      opacity: _animation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isGridView
                            ? _buildGridView(_filteredElements, context)
                            : _buildListView(_filteredElements, context),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating action button for quick actions
      floatingActionButton: Consumer<ElementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.error != null) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () {
              // Generate a random element
              if (provider.elements.isNotEmpty) {
                final randomIndex = DateTime.now().millisecondsSinceEpoch %
                    provider.elements.length;
                final randomElement = provider.elements[randomIndex];
                _navigateToElementDetail(randomElement);
              }
            },
            backgroundColor: theme.colorScheme.tertiary,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedWidget(
      {required Widget child, required double offsetY}) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, offsetY),
          end: Offset.zero,
        ).animate(_animation),
        child: child,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_chart_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No elements found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your search or filter',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<PeriodicElement> elements, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Adjust crossAxisCount based on screen width to make it more responsive
    final crossAxisCount = width < 360
        ? 3
        : width < 600
            ? 4
            : 8;

    // Adjusted child aspect ratio to better fit the content
    final childAspectRatio = width < 360 ? 0.82 : 0.95;
    final crossAxisSpacing = width < 360 ? 8.0 : 10.0;
    final mainAxisSpacing = width < 360 ? 8.0 : 10.0;
    final padding = width < 360 ? 12.0 : 14.0;

    return AnimationLimiter(
      child: GridView.builder(
        key: const ValueKey('grid_view'),
        padding: EdgeInsets.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: ElementCard(
                  element: elements[index],
                  index: index,
                  onTap: () => _navigateToElementDetail(elements[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<PeriodicElement> elements, BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        key: const ValueKey('list_view'),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ElementListItem(
                  element: elements[index],
                  onTap: () => _navigateToElementDetail(elements[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
