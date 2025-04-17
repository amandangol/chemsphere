// periodic_table_screen.dart - Enhanced with Modern UI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/element_provider.dart';
import '../../models/element.dart' as element_model;
import 'element_detail_screen.dart';
import 'traditional_periodic_table_screen.dart';

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
  List<element_model.Element> _filteredElements = [];

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
    _searchController.addListener(_onSearchChanged);

    // Fetch elements when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElementProvider>().fetchElements();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _updateFilteredElements(context.read<ElementProvider>().elements);
    });
  }

  void _updateFilteredElements(List<element_model.Element> elements) {
    setState(() {
      _filteredElements = elements.where((element) {
        final matchesCategory = _filterCategory == 'All' ||
            element.category.toLowerCase() == _filterCategory.toLowerCase();
        final matchesSearch = _searchQuery.isEmpty ||
            element.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            element.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            element.number.toString().contains(_searchQuery);

        // Debug atomic mass values
        if (element.atomicMass <= 0) {
          print(
              'Element with zero atomic mass: ${element.name} (${element.symbol})');
        }

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
    _searchController.removeListener(_onSearchChanged);
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.5),
              theme.colorScheme.background,
              theme.colorScheme.tertiaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated App Bar
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: _buildAppBar(theme),
                ),
              ),

              // Info banner for traditional view
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.15),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.secondaryContainer.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Try the Traditional View to explore elements arranged by period and group!',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: theme.colorScheme.secondary,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TraditionalPeriodicTableScreen(),
                              ),
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          tooltip: 'Open Traditional View',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: _buildSearchBar(theme),
                ),
              ),

              // Category filter with animation
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.05),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: _buildCategoryFilter(context),
                ),
              ),

              // Element display (grid or list)
              Expanded(
                child: Consumer<ElementProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return _buildLoadingState(theme);
                    }

                    if (provider.error != null) {
                      return _buildErrorState(provider, theme);
                    }

                    if (_filteredElements.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.science_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No elements found',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
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
              // Show a random element
              final elements = provider.elements;
              if (elements.isNotEmpty) {
                final randomElement =
                    elements[DateTime.now().millisecond % elements.length];
                context
                    .read<ElementProvider>()
                    .fetchElementDetails(randomElement.symbol);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ElementDetailScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              }
            },
            backgroundColor: theme.colorScheme.tertiary,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
            tooltip: 'Random Element',
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periodic Table',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Explore chemical elements',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Traditional view button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.grid_on,
                    color: theme.colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const TraditionalPeriodicTableScreen(),
                      ),
                    );
                  },
                  tooltip: 'Traditional Periodic Table',
                ),
              ),
              const SizedBox(width: 8),
              // Toggle view button with improved design
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                      _animationController.reset();
                      _animationController.forward();
                    });
                  },
                  tooltip: _isGridView ? 'List View' : 'Grid View',
                ),
              ),
              const SizedBox(width: 8),
              // Refresh button with improved design and force refresh option
              PopupMenuButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading:
                          Icon(Icons.refresh, color: theme.colorScheme.primary),
                      title: const Text('Refresh'),
                      subtitle: const Text('Use cached data if available'),
                    ),
                    onTap: () {
                      context.read<ElementProvider>().fetchElements();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Refreshing elements...',
                            style: GoogleFonts.poppins(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading:
                          Icon(Icons.sync, color: theme.colorScheme.secondary),
                      title: const Text('Force Refresh'),
                      subtitle: const Text('Fetch fresh data from server'),
                    ),
                    onTap: () {
                      context
                          .read<ElementProvider>()
                          .fetchElements(forceRefresh: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fetching fresh data...',
                            style: GoogleFonts.poppins(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Remove stored data'),
                    ),
                    onTap: () {
                      context.read<ElementProvider>().clearCache();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cache cleared',
                            style: GoogleFonts.poppins(),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Search elements by name, symbol or number...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        // Filter will be applied by the listener
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final theme = Theme.of(context);
    // Get unique categories with emojis
    final categories = [
      {'name': 'All', 'emoji': '🔍'},
      {'name': 'Alkali Metal', 'emoji': '🔥'},
      {'name': 'Alkaline Earth Metal', 'emoji': '🌍'},
      {'name': 'Transition Metal', 'emoji': '⚙️'},
      {'name': 'Metalloid', 'emoji': '🔋'},
      {'name': 'Polyatomic Nonmetal', 'emoji': '💨'},
      {'name': 'Diatomic Nonmetal', 'emoji': '💫'},
      {'name': 'Noble Gas', 'emoji': '✨'},
      {'name': 'Lanthanide', 'emoji': '🌟'},
      {'name': 'Actinide', 'emoji': '☢️'},
      {'name': 'Halogen', 'emoji': '💎'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _filterCategory == category['name'];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: FilterChip(
                        label: Row(
                          children: [
                            Text(
                              category['emoji']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category['name']!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _filterCategory = category['name']!;
                            // Apply filter immediately when category changes
                            _updateFilteredElements(
                                context.read<ElementProvider>().elements);
                          });
                        },
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                        elevation: isSelected ? 2 : 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.5)
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading elements...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing your periodic adventure',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ElementProvider provider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              provider.error ?? 'Unable to load elements',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.fetchElements(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
      List<element_model.Element> elements, BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.width < 600 ? 4 : 8;

    return AnimationLimiter(
      child: GridView.builder(
        key: const ValueKey('grid_view'),
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: EnhancedElementCard(
                  element: elements[index],
                  index: index,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(
      List<element_model.Element> elements, BuildContext context) {
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: ListView.builder(
        key: const ValueKey('list_view'),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          final element = elements[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getElementColor(element.category).withOpacity(0.1),
                          _getElementColor(element.category).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getElementColor(element.category)
                              .withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context
                              .read<ElementProvider>()
                              .fetchElementDetails(element.symbol);
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ElementDetailScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Element symbol in circle
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getElementColor(element.category),
                                      _getElementColor(element.category)
                                          .withOpacity(0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getElementColor(element.category)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    element.symbol,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Element info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          element.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getElementColor(
                                                    element.category)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '#${element.number}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _getElementColor(
                                                  element.category),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Atomic Mass: ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _formatAtomicMass(element.atomicMass),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      element.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color:
                                            _getElementColor(element.category),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow icon
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Color _getElementColor(String category) {
    switch (category.toLowerCase()) {
      case 'diatomic nonmetal':
        return const Color(0xFF00C853); // Bright green
      case 'polyatomic nonmetal':
        return const Color(0xFF4CAF50); // Green
      case 'alkali metal':
        return const Color(0xFFF44336); // Red
      case 'alkaline earth metal':
        return const Color(0xFFFF9800); // Orange
      case 'transition metal':
        return const Color(0xFFFFD600); // Yellow
      case 'metalloid':
        return const Color(0xFF9C27B0); // Purple
      case 'halogen':
        return const Color(0xFF29B6F6); // Light Blue
      case 'noble gas':
        return const Color(0xFF2196F3); // Blue
      case 'lanthanide':
        return const Color(0xFFE91E63); // Pink
      case 'actinide':
        return const Color(0xFF673AB7); // Deep Purple
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _formatAtomicMass(double mass) {
    if (mass <= 0) {
      return "N/A";
    }
    String formatted = mass.toStringAsFixed(4);
    while (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }
}

class EnhancedElementCard extends StatefulWidget {
  final element_model.Element element;
  final int index;

  const EnhancedElementCard({
    Key? key,
    required this.element,
    required this.index,
  }) : super(key: key);

  @override
  State<EnhancedElementCard> createState() => _EnhancedElementCardState();
}

class _EnhancedElementCardState extends State<EnhancedElementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Add a slight delay based on index for staggered animation
    Future.delayed(Duration(milliseconds: 30 * widget.index % 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getElementColor() {
    switch (widget.element.category.toLowerCase()) {
      case 'diatomic nonmetal':
        return const Color(0xFF00C853); // Bright green
      case 'polyatomic nonmetal':
        return const Color(0xFF4CAF50); // Green
      case 'alkali metal':
        return const Color(0xFFF44336); // Red
      case 'alkaline earth metal':
        return const Color(0xFFFF9800); // Orange
      case 'transition metal':
        return const Color(0xFFFFD600); // Yellow
      case 'metalloid':
        return const Color(0xFF9C27B0); // Purple
      case 'halogen':
        return const Color(0xFF29B6F6); // Light Blue
      case 'noble gas':
        return const Color(0xFF2196F3); // Blue
      case 'lanthanide':
        return const Color(0xFFE91E63); // Pink
      case 'actinide':
        return const Color(0xFF673AB7); // Deep Purple
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _formatAtomicMass(double mass) {
    if (mass <= 0) {
      return "N/A";
    }
    String formatted = mass.toStringAsFixed(2);
    while (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  String _getCategoryEmoji() {
    switch (widget.element.category.toLowerCase()) {
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return '💨';
      case 'alkali metal':
        return '🔥';
      case 'alkaline earth metal':
        return '🌍';
      case 'transition metal':
        return '⚙️';
      case 'metalloid':
        return '🔋';
      case 'halogen':
        return '💎';
      case 'noble gas':
        return '✨';
      case 'lanthanide':
        return '🌟';
      case 'actinide':
        return '☢️';
      default:
        return '⚗️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getElementColor();
    final categoryEmoji = _getCategoryEmoji();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: _isHovered ? 8 : 2,
            shadowColor: color.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: color.withOpacity(_isHovered ? 0.8 : 0.5),
                width: 2,
              ),
            ),
            child: InkWell(
              onTap: () {
                context
                    .read<ElementProvider>()
                    .fetchElementDetails(widget.element.symbol);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ElementDetailScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              splashColor: color.withOpacity(0.2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern for visual interest
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: CustomPaint(
                          painter: AtomPatternPainter(color: color),
                        ),
                      ),
                    ),

                    // Atomic number with better styling
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.element.number}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),

                    // Element data in center
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.element.symbol,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: theme.colorScheme.onSurface,
                                shadows: [
                                  Shadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.element.name,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatAtomicMass(widget.element.atomicMass),
                              style: GoogleFonts.robotoMono(
                                fontSize: 9,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Category indicator with emoji
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Tooltip(
                        message: widget.element.category,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.background.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            categoryEmoji,
                            style: const TextStyle(fontSize: 8),
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
    );
  }
}

// Custom painter to draw atom-like pattern in the background of element cards
class AtomPatternPainter extends CustomPainter {
  final Color color;

  AtomPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw electron orbits
    final center = Offset(size.width / 2, size.height / 2);

    // Orbit 1
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.8,
        height: size.height * 0.5,
      ),
      paint,
    );

    // Orbit 2
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.5,
        height: size.height * 0.8,
      ),
      paint,
    );

    // Nucleus
    final nucleusPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      size.width * 0.05,
      nucleusPaint,
    );

    // Electrons
    final electronPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Electron 1
    canvas.drawCircle(
      Offset(
        center.dx + size.width * 0.4,
        center.dy,
      ),
      size.width * 0.02,
      electronPaint,
    );

    // Electron 2
    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy - size.height * 0.25,
      ),
      size.width * 0.02,
      electronPaint,
    );

    // Electron 3
    canvas.drawCircle(
      Offset(
        center.dx - size.width * 0.25,
        center.dy + size.height * 0.4,
      ),
      size.width * 0.02,
      electronPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
