import 'package:chem_explore/widgets/chemistry_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'provider/element_provider.dart';
import 'model/periodic_element.dart';
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
    _searchController.dispose();
    _animationController.dispose();
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
              theme.colorScheme.surface,
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

              // Educational Info Card
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.15),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: _buildEducationalInfoCard(),
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TraditionalPeriodicTableScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer
                            .withOpacity(0.7),
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
                          ),
                        ],
                      ),
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
              // Generate a random element
              if (provider.elements.isNotEmpty) {
                final randomIndex = DateTime.now().millisecondsSinceEpoch %
                    provider.elements.length;
                final randomElement = provider.elements[randomIndex];

                // Navigate to element details
                provider.setSelectedElement(randomElement.symbol);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ElementDetailScreen(element: randomElement),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            backgroundColor: theme.colorScheme.tertiary,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
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
                  color: theme.colorScheme.surfaceContainerHighest,
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
                ),
              ),
              const SizedBox(width: 8),
              // Toggle view button with improved design
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
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
                ),
              ),
              const SizedBox(width: 8),

              PopupMenuButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
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
                      context.read<ElementProvider>().fetchFlashcardElements();
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
                          .fetchFlashcardElements(forceRefresh: true);
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

  Widget _buildEducationalInfoCard() {
    if (!_showInfoCard) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiaryContainer.withOpacity(0.8),
            theme.colorScheme.tertiaryContainer.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          "Understanding the Periodic Table",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        leading: Icon(
          Icons.school,
          color: theme.colorScheme.onTertiaryContainer,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.expand_more,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.7),
              size: 20,
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showInfoCard = false;
                });
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The periodic table organizes chemical elements according to their atomic number, electron configuration, and recurring chemical properties. Elements are arranged in rows (periods) and columns (groups).",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color:
                        theme.colorScheme.onTertiaryContainer.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                _buildElementCategoryLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementCategoryLegend() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Element Categories:",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip("Metals", const Color(0xFFF44336)),
            _buildCategoryChip("Nonmetals", const Color(0xFF4CAF50)),
            _buildCategoryChip("Metalloids", const Color(0xFF9C27B0)),
            _buildCategoryChip("Noble Gases", const Color(0xFF2196F3)),
            _buildCategoryChip("Halogens", const Color(0xFF29B6F6)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
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
          color: theme.colorScheme.surfaceContainerHighest,
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
                                Provider.of<ElementProvider>(context,
                                        listen: false)
                                    .elements);
                          });
                        },
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
    return const ChemistryLoadingWidget(message: 'Loading elements...');
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
              onPressed: () => provider.fetchFlashcardElements(),
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

  Widget _buildGridView(List<PeriodicElement> elements, BuildContext context) {
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
                child: ElementCard(
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

  Widget _buildListView(List<PeriodicElement> elements, BuildContext context) {
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
                          _getElementColor(element.groupBlock).withOpacity(0.1),
                          _getElementColor(element.groupBlock)
                              .withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _getElementColor(element.groupBlock)
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
                              .setSelectedElement(element.symbol);
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ElementDetailScreen(element: element),
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
                                      _getElementColor(element.groupBlock),
                                      _getElementColor(element.groupBlock)
                                          .withOpacity(0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _getElementColor(element.groupBlock)
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
                                                    element.groupBlock)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '#${element.atomicNumber}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: _getElementColor(
                                                  element.groupBlock),
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
                                          _formatValue(
                                              element.formattedAtomicMass),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          element.groupBlock,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _getElementColor(
                                                element.groupBlock),
                                          ),
                                        ),
                                        Text(
                                          'State: ${_formatValue(element.standardState)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
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

  String _formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    // For numeric values, check if they're zero
    if (value is num || value is String && double.tryParse(value) != null) {
      double? numValue;
      if (value is num) {
        numValue = value.toDouble();
      } else {
        numValue = double.tryParse(value.toString());
      }

      if (numValue != null && numValue == 0) {
        return 'N/A';
      }
    }

    return value.toString();
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

class ElementCard extends StatefulWidget {
  final PeriodicElement element;
  final int index;

  const ElementCard({
    Key? key,
    required this.element,
    required this.index,
  }) : super(key: key);

  @override
  State<ElementCard> createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getElementColor() {
    switch (widget.element.groupBlock.toLowerCase()) {
      case 'nonmetal':
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return const Color(0xFF00C853); // Bright green
      case 'noble gas':
        return const Color(0xFF2962FF); // Bright blue
      case 'alkali metal':
        return const Color(0xFFD50000); // Bright red
      case 'alkaline earth metal':
        return const Color(0xFFFF6D00); // Bright orange
      case 'metalloid':
        return const Color(0xFF6200EA); // Bright purple
      case 'halogen':
        return const Color(0xFF00B8D4); // Cyan
      case 'transition metal':
        return const Color(0xFFFFAB00); // Amber
      case 'post-transition metal':
        return const Color(0xFF1565C0); // Blue
      case 'lanthanide':
        return const Color(0xFFC51162); // Pink
      case 'actinide':
        return const Color(0xFF4A148C); // Deep purple
      default:
        return Colors.grey;
    }
  }

  String _formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    // For numeric values, check if they're zero
    if (value is num || value is String && double.tryParse(value) != null) {
      double? numValue;
      if (value is num) {
        numValue = value.toDouble();
      } else {
        numValue = double.tryParse(value.toString());
      }

      if (numValue != null && numValue == 0) {
        return 'N/A';
      }
    }

    return value.toString();
  }

  String _getCategoryEmoji() {
    switch (widget.element.groupBlock.toLowerCase()) {
      case 'nonmetal':
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return '🌿'; // Plant for nonmetal
      case 'noble gas':
        return '💨'; // Wind for noble gas
      case 'alkali metal':
        return '🔥'; // Fire for alkali metal
      case 'alkaline earth metal':
        return '🌋'; // Volcano for alkaline earth metal
      case 'metalloid':
        return '🔮'; // Crystal ball for metalloid
      case 'halogen':
        return '🧪'; // Test tube for halogen
      case 'transition metal':
        return '⚙️'; // Gear for transition metal
      case 'post-transition metal':
        return '🔧'; // Wrench for post-transition metal
      case 'lanthanide':
        return '✨'; // Sparkles for lanthanide
      case 'actinide':
        return '☢️'; // Radioactive for actinide
      default:
        return '🔍'; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getElementColor();
    final emoji = _getCategoryEmoji();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Set selected element and navigate to details
              Provider.of<ElementProvider>(context, listen: false)
                  .setSelectedElement(widget.element.symbol);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ElementDetailScreen(element: widget.element),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Atomic number in top-left
                  Positioned(
                    top: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.element.atomicNumber}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Element symbol
                        Text(
                          widget.element.symbol,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Element name
                        Text(
                          widget.element.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Atomic mass
                        Text(
                          _formatValue(widget.element.formattedAtomicMass),
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
