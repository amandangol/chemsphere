import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/chemistry_widgets.dart';
import '../provider/chemistry_guide_provider.dart';
import 'topic_detail_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TopicSearchScreen extends StatefulWidget {
  final String title;

  const TopicSearchScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<TopicSearchScreen> createState() => _TopicSearchScreenState();
}

class _TopicSearchScreenState extends State<TopicSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;
  bool _initialSearchDone = false;

  @override
  void initState() {
    super.initState();
    // Initialize search with the topic title
    _searchController.text = widget.title;
    // Perform initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search(isInitial: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search({bool isInitial = false}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
    });

    final provider =
        Provider.of<ChemistryGuideProvider>(context, listen: false);
    provider.clearError(); // Clear any previous errors
    await provider.searchWikipediaArticles(query);

    setState(() {
      _searching = false;
      if (isInitial) {
        _initialSearchDone = true;
      }
    });
  }

  void _viewArticle(String title) async {
    final provider =
        Provider.of<ChemistryGuideProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const ChemistryLoadingWidget();
        });

    try {
      final topic = await provider.getArticleSummary(title);

      if (mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        if (topic != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicDetailScreen(
                topic: topic,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading article: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _showInfoDialog(),
            tooltip: 'About this topic',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search area
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getThemedColorForTopic(context, widget.title)
                      .withOpacity(0.8),
                  _getThemedColorForTopic(context, widget.title)
                      .withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Search for ${widget.title} on Wikipedia',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Enter a search term...',
                            hintStyle: TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: TextStyle(fontSize: 14),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton.filled(
                        onPressed: _search,
                        icon: const Icon(Icons.search, size: 18),
                        tooltip: 'Search',
                        style: IconButton.styleFrom(
                          minimumSize: Size(36, 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search results or initial content
          Expanded(
            child: Consumer<ChemistryGuideProvider>(
              builder: (context, provider, child) {
                if ((provider.isLoading || _searching) && !_initialSearchDone) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2.5),
                        const SizedBox(height: 14),
                        Text(
                          'Searching Wikipedia...',
                          style: GoogleFonts.poppins(fontSize: 14),
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
                        Icon(Icons.error_outline,
                            size: 40, color: theme.colorScheme.error),
                        const SizedBox(height: 14),
                        Text(
                          'Error: ${provider.error}',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _search,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final searchResults = provider.searchResults;
                if (searchResults.isEmpty && _initialSearchDone) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No results found for "${_searchController.text}"',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _searchController.text = widget.title;
                            _search();
                          },
                          child: const Text('Reset Search'),
                        ),
                      ],
                    ),
                  );
                }

                // Show results if we have them
                if (searchResults.isNotEmpty) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        child: Row(
                          children: [
                            Text(
                              'Results for "${_searchController.text}"',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getThemedColorForTopic(
                                        context, widget.title)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${searchResults.length} found',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _getThemedColorForTopic(
                                      context, widget.title),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final result = searchResults[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              _getThemedColorForTopic(
                                                      context, widget.title)
                                                  .withOpacity(0.1),
                                          radius: 18,
                                          child: Icon(
                                            Icons.article,
                                            size: 16,
                                            color: _getThemedColorForTopic(
                                                context, widget.title),
                                          ),
                                        ),
                                        title: Text(
                                          result,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: _getThemedColorForTopic(
                                              context, widget.title),
                                        ),
                                        onTap: () => _viewArticle(result),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // If we get here, show the initial content with suggestions
                return _buildInitialContent();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About ${widget.title}',
          style: TextStyle(fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getTopicDescription(widget.title),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 14),
              const Text(
                'This screen helps you explore Wikipedia articles related to this topic. Use the search box to find specific information.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent() {
    final theme = Theme.of(context);
    final topicColor = _getThemedColorForTopic(context, widget.title);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 30.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        topicColor,
                        topicColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: topicColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconForTopic(widget.title),
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Learn about ${widget.title}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: topicColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: topicColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 6),
                      Text(
                        _getTopicDescription(widget.title),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Popular Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Tap on any suggestion to search Wikipedia',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              _buildSuggestedSearches(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedSearches() {
    final theme = Theme.of(context);
    final topicColor = _getThemedColorForTopic(context, widget.title);

    // Get suggestions list...
    List<String> suggestions = _getSuggestionsForTopic(widget.title);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 10,
              children: suggestions
                  .map((suggestion) => ActionChip(
                        avatar: Icon(
                          Icons.search,
                          size: 14,
                          color: topicColor,
                        ),
                        label: Text(
                          suggestion,
                          style: TextStyle(fontSize: 12),
                        ),
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                        onPressed: () {
                          _searchController.text = suggestion;
                          _search();
                        },
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Colors adapted to use theme colors
  Color _getThemedColorForTopic(BuildContext context, String topicTitle) {
    final theme = Theme.of(context);

    final Map<String, Color> topicColors = {
      'Atoms and Elements': theme.colorScheme.primary,
      'Periodic Table': theme.colorScheme.tertiary,
      'Chemical Bonds': theme.colorScheme.secondary,
      'States of Matter': theme.colorScheme.secondary,
      'Solutions & Mixtures': theme.colorScheme.tertiary,
      'Concentration': theme.colorScheme.tertiary,
      'Chemical Equations': Color(0xFFE67700), // Themed orange
      'Reaction Types': Color(0xFFE67700), // Themed orange
      'Equilibrium': Color(0xFFE67700), // Themed orange
      'Thermochemistry': Color(0xFFB82E2E), // Themed red
      'Reaction Rates': Color(0xFFB82E2E), // Themed red
      'Catalysts': Color(0xFFB82E2E), // Themed red
      'Carbon Compounds': Color(0xFF2E7D32), // Themed green
      'Functional Groups': Color(0xFF2E7D32), // Themed green
      'Organic Reactions': Color(0xFF2E7D32), // Themed green
    };

    return topicColors[topicTitle] ?? theme.colorScheme.primary;
  }

  // Helper to get suggestions based on topic
  List<String> _getSuggestionsForTopic(String title) {
    // Existing code to get suggestions based on topic...
    if (title == 'Atoms and Elements') {
      return [
        'Atom',
        'Element',
        'Proton',
        'Neutron',
        'Electron',
        'Atomic Number',
        'Atomic Mass',
        'Isotope',
        'Subatomic particle',
        'Quantum model',
      ];
    }
    // ... other topic checks

    // Default suggestions if no specific category matches
    return [
      title,
      'Chemistry',
      'Chemical compound',
      'Molecule',
      'Scientific method',
      'Chemical property',
      'Physical property',
      'Experiment',
      'Laboratory technique',
      'Chemical analysis',
    ];
  }

  IconData _getIconForTopic(String topicTitle) {
    final Map<String, IconData> topicIcons = {
      'Atoms and Elements': Icons.circle_outlined,
      'Periodic Table': Icons.grid_on,
      'Chemical Bonds': Icons.link,
      'States of Matter': Icons.change_history,
      'Solutions & Mixtures': Icons.bubble_chart,
      'Concentration': Icons.science,
      'Chemical Equations': Icons.sync_alt,
      'Reaction Types': Icons.category,
      'Equilibrium': Icons.balance,
      'Thermochemistry': Icons.whatshot,
      'Reaction Rates': Icons.speed,
      'Catalysts': Icons.fast_forward,
      'Carbon Compounds': Icons.hexagon,
      'Functional Groups': Icons.category,
      'Organic Reactions': Icons.transform,
    };

    return topicIcons[topicTitle] ?? Icons.science;
  }

  String _getTopicDescription(String title) {
    final Map<String, String> descriptions = {
      'Atoms and Elements':
          'Atoms are the basic units of matter and the defining structure of elements. An element is a pure substance consisting of atoms with the same number of protons.',
      'Periodic Table':
          'The periodic table is a tabular arrangement of chemical elements, organized by atomic number, electron configuration, and chemical properties.',
      'Chemical Bonds':
          'Chemical bonds are the forces that hold atoms together to form molecules and compounds. The main types include ionic, covalent, and metallic bonds.',
      'States of Matter':
          'Matter exists in various physical states: solid, liquid, gas, and plasma. Each state has unique properties and behaviors.',
      'Solutions & Mixtures':
          'Solutions are homogeneous mixtures where one substance dissolves in another. Mixtures contain two or more substances that are physically combined.',
      'Concentration':
          'Concentration measures the amount of solute dissolved in a specific amount of solution, expressed in various units like molarity or percent.',
      'Chemical Equations':
          'Chemical equations are symbolic representations of chemical reactions, showing reactants, products, and their proportions.',
      'Reaction Types':
          'Chemical reactions are classified into different types based on the reaction mechanism, including synthesis, decomposition, displacement, and redox reactions.',
      'Equilibrium':
          'Chemical equilibrium is the state where the forward and reverse reactions occur at equal rates, resulting in constant concentrations of reactants and products.',
      'Thermochemistry':
          'Thermochemistry studies the energy and heat associated with chemical reactions and physical changes.',
      'Reaction Rates':
          'Reaction rate measures how quickly reactants are consumed or products are formed in a chemical reaction.',
      'Catalysts':
          'Catalysts are substances that increase the rate of a chemical reaction without being consumed in the process.',
      'Carbon Compounds':
          'Carbon compounds are chemical substances containing carbon atoms, forming the basis of organic chemistry.',
      'Functional Groups':
          'Functional groups are specific groups of atoms within molecules that give the molecule characteristic chemical reactions.',
      'Organic Reactions':
          'Organic reactions are chemical reactions involving organic compounds, typically featuring carbon-based molecules.',
    };

    return descriptions[title] ??
        'A fundamental concept in chemistry that helps us understand the composition and behavior of matter.';
  }
}
