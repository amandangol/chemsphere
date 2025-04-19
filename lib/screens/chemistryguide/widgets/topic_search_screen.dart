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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'About this topic',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorForTopic(widget.title).withOpacity(0.8),
                  _getColorForTopic(widget.title).withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Enter a search term...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton.filled(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
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
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Searching Wikipedia...',
                          style: GoogleFonts.poppins(),
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
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${provider.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
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
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found for "${_searchController.text}"',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Results for "${_searchController.text}"',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getColorForTopic(widget.title)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${searchResults.length} found',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _getColorForTopic(widget.title),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final result = searchResults[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              _getColorForTopic(widget.title)
                                                  .withOpacity(0.1),
                                          child: Icon(
                                            Icons.article,
                                            color:
                                                _getColorForTopic(widget.title),
                                          ),
                                        ),
                                        title: Text(
                                          result,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color:
                                              _getColorForTopic(widget.title),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About ${widget.title}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getTopicDescription(widget.title),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'This screen helps you explore Wikipedia articles related to this topic. Use the search box to find specific information.',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getColorForTopic(widget.title),
                        _getColorForTopic(widget.title).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: _getColorForTopic(widget.title).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconForTopic(widget.title),
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Learn about ${widget.title}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getColorForTopic(widget.title),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getColorForTopic(widget.title),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        _getTopicDescription(widget.title),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Popular Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap on any suggestion to search Wikipedia',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              _buildSuggestedSearches(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedSearches() {
    List<String> suggestions = [];

    // Set suggestions based on topic
    if (widget.title == 'Atoms and Elements') {
      suggestions = [
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
    } else if (widget.title == 'Periodic Table') {
      suggestions = [
        'Periodic Table',
        'Periodic Law',
        'Mendeleev',
        'Group (periodic table)',
        'Period (periodic table)',
        'Alkali Metals',
        'Noble Gases',
        'Halogens',
        'Transition Metals',
        'Metalloids',
      ];
    } else if (widget.title == 'Chemical Bonds') {
      suggestions = [
        'Chemical bond',
        'Covalent bond',
        'Ionic bond',
        'Hydrogen bond',
        'Metallic bond',
        'Bond energy',
        'Bond length',
        'Polar bond',
        'Lewis structure',
        'Molecular orbital theory',
      ];
    } else if (widget.title == 'States of Matter') {
      suggestions = [
        'States of matter',
        'Phase transition',
        'Solid',
        'Liquid',
        'Gas',
        'Plasma (physics)',
        'Melting',
        'Freezing',
        'Boiling',
        'Condensation',
      ];
    } else if (widget.title.contains('Solutions')) {
      suggestions = [
        'Solution (chemistry)',
        'Solvent',
        'Solute',
        'Solubility',
        'Mixture',
        'Colloid',
        'Suspension',
        'Miscibility',
        'Saturated solution',
        'Concentration',
      ];
    } else if (widget.title == 'Concentration') {
      suggestions = [
        'Concentration',
        'Molarity',
        'Molality',
        'Parts per million',
        'Weight percentage',
        'Volume percentage',
        'Dilution',
        'Titration',
        'Standard solution',
        'Equivalence point',
      ];
    } else if (widget.title.contains('Equation')) {
      suggestions = [
        'Chemical equation',
        'Balancing equations',
        'Stoichiometry',
        'Limiting reagent',
        'Excess reagent',
        'Theoretical yield',
        'Actual yield',
        'Percent yield',
        'Complete combustion',
        'Chemical formula',
      ];
    } else if (widget.title.contains('Reaction Types')) {
      suggestions = [
        'Chemical reaction',
        'Redox',
        'Acid–base reaction',
        'Precipitation (chemistry)',
        'Combustion',
        'Synthesis reaction',
        'Decomposition reaction',
        'Single displacement',
        'Double displacement',
        'Neutralization',
      ];
    } else if (widget.title == 'Equilibrium') {
      suggestions = [
        'Chemical equilibrium',
        'Dynamic equilibrium',
        'Equilibrium constant',
        'Le Chatelier\'s principle',
        'Reaction quotient',
        'Solubility product',
        'Common-ion effect',
        'Buffer solution',
        'pH',
        'Acid dissociation constant',
      ];
    } else if (widget.title == 'Thermochemistry') {
      suggestions = [
        'Thermochemistry',
        'Enthalpy',
        'Entropy',
        'Gibbs free energy',
        'Heat of reaction',
        'Heat of formation',
        'Calorimetry',
        'Hess\'s law',
        'Endothermic reaction',
        'Exothermic reaction',
      ];
    } else if (widget.title.contains('Reaction Rates')) {
      suggestions = [
        'Reaction rate',
        'Rate law',
        'Rate constant',
        'Reaction order',
        'Activation energy',
        'Arrhenius equation',
        'Collision theory',
        'Transition state theory',
        'Half-life',
        'Reaction mechanism',
      ];
    } else if (widget.title.contains('Catalyst')) {
      suggestions = [
        'Catalyst',
        'Catalysis',
        'Heterogeneous catalysis',
        'Homogeneous catalysis',
        'Enzyme',
        'Inhibitor',
        'Active site',
        'Substrate (chemistry)',
        'Biocatalyst',
        'Zeolite',
        'Platinum catalyst',
      ];
    } else if (widget.title.contains('Carbon')) {
      suggestions = [
        'Organic chemistry',
        'Carbon',
        'Hydrocarbon',
        'Alkane',
        'Alkene',
        'Alkyne',
        'Aromatic compound',
        'Carbon cycle',
        'Allotropes of carbon',
        'Carbon compounds',
      ];
    } else if (widget.title.contains('Functional')) {
      suggestions = [
        'Functional group',
        'Alcohol (chemistry)',
        'Aldehyde',
        'Ketone',
        'Carboxylic acid',
        'Ester',
        'Amine',
        'Amide',
        'Ether',
        'Phenol',
        'Thiol',
      ];
    } else if (widget.title.contains('Organic Reactions')) {
      suggestions = [
        'Organic reaction',
        'Substitution reaction',
        'Addition reaction',
        'Elimination reaction',
        'Oxidation',
        'Reduction',
        'Hydrolysis',
        'Polymerization',
        'Condensation reaction',
        'Fermentation',
      ];
    } else {
      // Default suggestions if no specific category matches
      suggestions = [
        widget.title,
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

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: suggestions
                  .map((suggestion) => ActionChip(
                        avatar: Icon(
                          Icons.search,
                          size: 16,
                          color: _getColorForTopic(widget.title),
                        ),
                        label: Text(suggestion),
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                        onPressed: () {
                          _searchController.text = suggestion;
                          _search();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
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

  Color _getColorForTopic(String topicTitle) {
    final Map<String, Color> topicColors = {
      'Atoms and Elements': Colors.blue,
      'Periodic Table': Colors.purple,
      'Chemical Bonds': Colors.indigo,
      'States of Matter': Colors.teal,
      'Solutions & Mixtures': Colors.purple,
      'Concentration': Colors.deepPurple,
      'Chemical Equations': Colors.orange,
      'Reaction Types': Colors.amber,
      'Equilibrium': Colors.orange.shade700,
      'Thermochemistry': Colors.red,
      'Reaction Rates': Colors.deepOrange,
      'Catalysts': Colors.pink,
      'Carbon Compounds': Colors.green,
      'Functional Groups': Colors.lightGreen,
      'Organic Reactions': Colors.lime.shade800,
    };

    return topicColors[topicTitle] ?? Theme.of(context).colorScheme.primary;
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
