// periodic_table_screen.dart - Enhanced
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/element_provider.dart';
import '../../models/element.dart' as element_model;
import 'element_detail_screen.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({Key? key}) : super(key: key);

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  bool _isGridView = true;
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch elements when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ElementProvider>().fetchElements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.3),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periodic Table',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        // Toggle view button
                        IconButton(
                          icon: Icon(
                            _isGridView ? Icons.list : Icons.grid_view,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                          tooltip: _isGridView ? 'List View' : 'Grid View',
                        ),
                        // Refresh button
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () =>
                              context.read<ElementProvider>().fetchElements(),
                          tooltip: 'Refresh Elements',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Category filter
              _buildCategoryFilter(context),
              // Element display (grid or list)
              Expanded(
                child: Consumer<ElementProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading elements...',
                              style:
                                  TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${provider.error}',
                              style: TextStyle(color: theme.colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => provider.fetchElements(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final elements = _filterCategory == 'All'
                        ? provider.elements
                        : provider.elements
                            .where((e) =>
                                e.category.toLowerCase() ==
                                _filterCategory.toLowerCase())
                            .toList();

                    return _isGridView
                        ? _buildGridView(elements, context)
                        : _buildListView(elements, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final theme = Theme.of(context);
    // Get unique categories
    final categories = [
      'All',
      ...context
          .read<ElementProvider>()
          .elements
          .map((e) => e.category)
          .toSet()
          .toList()
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _filterCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterCategory = category;
                });
              },
              backgroundColor: theme.colorScheme.surfaceVariant,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(
      List<element_model.Element> elements, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 5 : 9,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return ElementCard(element: element);
      },
    );
  }

  Widget _buildListView(
      List<element_model.Element> elements, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getElementColor(element.category).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  element.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(element.name),
            subtitle: Text('Atomic Number: ${element.number}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context
                  .read<ElementProvider>()
                  .fetchElementDetails(element.symbol);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ElementDetailScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getElementColor(String category) {
    switch (category.toLowerCase()) {
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return Colors.green;
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'transition metal':
        return Colors.yellow.shade700;
      case 'metalloid':
        return Colors.purple;
      case 'halogen':
        return Colors.lightBlue;
      case 'noble gas':
        return Colors.blue;
      case 'lanthanide':
        return Colors.pink;
      case 'actinide':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}

class ElementCard extends StatelessWidget {
  final element_model.Element element;

  const ElementCard({Key? key, required this.element}) : super(key: key);

  Color _getElementColor() {
    switch (element.category.toLowerCase()) {
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return Colors.green;
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'transition metal':
        return Colors.yellow.shade700;
      case 'metalloid':
        return Colors.purple;
      case 'halogen':
        return Colors.lightBlue;
      case 'noble gas':
        return Colors.blue;
      case 'lanthanide':
        return Colors.pink;
      case 'actinide':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  String _formatAtomicMass(double mass) {
    String formatted = mass.toStringAsFixed(2);
    while (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getElementColor();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<ElementProvider>().fetchElementDetails(element.symbol);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ElementDetailScreen(),
            ),
          );
        },
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
              // Atomic number
              Positioned(
                top: 4,
                left: 4,
                child: Text(
                  '${element.number}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Element data in center
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      element.symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      element.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatAtomicMass(element.atomicMass),
                      style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Category indicator dot
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
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
