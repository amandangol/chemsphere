import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/chemistry_guide.dart';
import '../../providers/chemistry_guide_provider.dart';

class ElementsTopicScreen extends StatefulWidget {
  final String title;

  const ElementsTopicScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<ElementsTopicScreen> createState() => _ElementsTopicScreenState();
}

class _ElementsTopicScreenState extends State<ElementsTopicScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ChemistryGuideProvider>(context, listen: false);
      provider.loadElements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Consumer<ChemistryGuideProvider>(
        builder: (context, provider, child) {
          if (provider.elementsState == ChemistryGuideLoadingState.loading) {
            return _buildLoadingView();
          } else if (provider.elementsState ==
              ChemistryGuideLoadingState.error) {
            return _buildErrorView(provider.error ?? 'Unknown error');
          } else if (provider.elements.isEmpty) {
            return _buildEmptyView();
          } else {
            return _buildElementsView(provider);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading elements data...',
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading elements',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed: () {
              final provider =
                  Provider.of<ChemistryGuideProvider>(context, listen: false);
              provider.loadElements();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No elements found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementsView(ChemistryGuideProvider provider) {
    final categories = provider.elementCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction card
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Periodic Table',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The periodic table is a tabular arrangement of chemical elements, organized by their atomic number, electron configuration, and recurring chemical properties.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildElementStat(
                        context,
                        provider.elements.length.toString(),
                        'Elements',
                        Icons.science,
                      ),
                      _buildElementStat(
                        context,
                        categories.length.toString(),
                        'Categories',
                        Icons.category,
                      ),
                      _buildElementStat(
                        context,
                        '118',
                        'Known',
                        Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Element categories
          ...categories.entries.map((entry) {
            final categoryName = entry.key;
            final elements = entry.value;

            return _buildCategorySection(context, categoryName, elements);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildElementStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, String categoryName,
      List<ChemistryElement> elements) {
    // Skip empty categories
    if (elements.isEmpty) return const SizedBox.shrink();

    // Get a color based on the category
    Color categoryColor;
    switch (categoryName) {
      case 'Metal':
        categoryColor = Colors.blue;
        break;
      case 'Nonmetal':
        categoryColor = Colors.green;
        break;
      case 'Noble Gas':
        categoryColor = Colors.purple;
        break;
      case 'Alkali Metal':
        categoryColor = Colors.red;
        break;
      case 'Alkaline Earth Metal':
        categoryColor = Colors.orange;
        break;
      case 'Metalloid':
        categoryColor = Colors.teal;
        break;
      case 'Halogen':
        categoryColor = Colors.pink;
        break;
      case 'Transition Metal':
        categoryColor = Colors.indigo;
        break;
      default:
        categoryColor = Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category,
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
            ],
          ),
        ),

        // Elements grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount:
              elements.length.clamp(0, 6), // Show max 6 elements per category
          itemBuilder: (context, index) {
            final element = elements[index];
            return _buildElementCard(context, element, categoryColor);
          },
        ),

        // Show more button if needed
        if (elements.length > 6)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text('View ${elements.length - 6} more'),
                onPressed: () {
                  // Show all elements in this category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ElementCategoryScreen(
                        categoryName: categoryName,
                        elements: elements,
                        categoryColor: categoryColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildElementCard(
      BuildContext context, ChemistryElement element, Color categoryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ElementDetailScreen(element: element),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${element.atomicNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  Text(
                    element.atomicWeight.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                element.symbol,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              Text(
                element.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Additional screen to view all elements in a category
class ElementCategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<ChemistryElement> elements;
  final Color categoryColor;

  const ElementCategoryScreen({
    Key? key,
    required this.categoryName,
    required this.elements,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Elements'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: elements.length,
        itemBuilder: (context, index) {
          final element = elements[index];
          return _buildElementCard(context, element);
        },
      ),
    );
  }

  Widget _buildElementCard(BuildContext context, ChemistryElement element) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ElementDetailScreen(element: element),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${element.atomicNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  Text(
                    element.atomicWeight.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                element.symbol,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              Text(
                element.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen to view element details
class ElementDetailScreen extends StatelessWidget {
  final ChemistryElement element;

  const ElementDetailScreen({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(element.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Element header card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Element symbol and atomic number
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            element.symbol,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                element.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Atomic Number: ${element.atomicNumber}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Element basic properties
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPropertyItem('Atomic Weight',
                            '${element.atomicWeight}', Icons.scale),
                        _buildPropertyItem(
                            'Period', element.period, Icons.view_week),
                        _buildPropertyItem(
                            'Group', element.group, Icons.view_column),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Element description
            if (element.description.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        element.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Element properties
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Properties',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Category', element.category),
                    const Divider(),
                    _buildDetailRow('Electron Configuration',
                        element.electronConfiguration),
                    const Divider(),
                    if (element.electronegativity != null)
                      _buildDetailRow('Electronegativity',
                          element.electronegativity.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }
}
