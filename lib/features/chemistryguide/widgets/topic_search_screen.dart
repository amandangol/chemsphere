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
          style: const TextStyle(fontSize: 17),
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
                            hintStyle: const TextStyle(fontSize: 13),
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
                          style: const TextStyle(fontSize: 14),
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
                          minimumSize: const Size(36, 36),
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
          style: const TextStyle(fontSize: 16),
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
                          style: const TextStyle(fontSize: 12),
                        ),
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                        onPressed: () {
                          _searchController.text = suggestion;
                          _search();
                        },
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
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
      'Chemical Equations': const Color(0xFFE67700), // Themed orange
      'Reaction Types': const Color(0xFFE67700), // Themed orange
      'Equilibrium': const Color(0xFFE67700), // Themed orange
      'Thermochemistry': const Color(0xFFB82E2E), // Themed red
      'Reaction Rates': const Color(0xFFB82E2E), // Themed red
      'Catalysts': const Color(0xFFB82E2E), // Themed red
      'Carbon Compounds': const Color(0xFF2E7D32), // Themed green
      'Functional Groups': const Color(0xFF2E7D32), // Themed green
      'Organic Reactions': const Color(0xFF2E7D32), // Themed green
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
    // Fundamentals category
    if (title == 'Atoms and Elements') {
      return 'Atoms are the basic units of matter and the defining structure of elements. An element is a pure substance consisting of atoms with the same number of protons. They are the building blocks for all materials on Earth and throughout the universe.';
    } else if (title == 'Periodic Table') {
      return 'The periodic table is a tabular arrangement of chemical elements, organized by atomic number, electron configuration, and chemical properties. It reflects periodic trends across the elements, providing a framework for understanding chemical behavior.';
    } else if (title == 'Chemical Bonds') {
      return 'Chemical bonds are the forces that hold atoms together to form molecules and compounds. The main types include ionic bonds (electron transfer), covalent bonds (electron sharing), metallic bonds (electron sea), and intermolecular forces like hydrogen bonding.';
    } else if (title == 'Nuclear Chemistry') {
      return 'Nuclear chemistry deals with radioactivity, nuclear processes, and nuclear properties. It includes the study of nuclear reactions, radiation, nuclear energy production, and applications like radiometric dating and medical treatments.';
    } else if (title == 'Quantum Chemistry') {
      return 'Quantum chemistry applies quantum mechanics to explain atomic structure, chemical bonding, and spectroscopic properties. It uses wave functions to describe electron behavior and explains phenomena like orbital hybridization and molecular orbital theory.';
    } else if (title == 'Isotopes') {
      return 'Isotopes are variants of an element that have the same number of protons but different numbers of neutrons. They play crucial roles in radiometric dating, medical diagnostics, cancer therapy, and as tracers in biological and environmental studies.';

      // Matter & Solutions category
    } else if (title == 'States of Matter') {
      return 'Matter exists in various physical states: solid, liquid, gas, and plasma. Each state has unique properties determined by the arrangement and energy of particles. Phase transitions occur when matter changes from one state to another.';
    } else if (title == 'Solutions and Mixtures' ||
        title == 'Solutions & Mixtures') {
      return 'Solutions are homogeneous mixtures where one substance (solute) dissolves in another (solvent). Mixtures contain two or more substances that are physically combined without chemical bonding. They form the basis for many everyday materials and biological systems.';
    } else if (title == 'Chemical Concentration' || title == 'Concentration') {
      return 'Concentration measures the amount of solute dissolved in a specific amount of solution, expressed in various units like molarity, molality, normality, or percent concentration. It determines solution properties and reaction rates in chemical processes.';
    } else if (title == 'Colligative Properties') {
      return 'Colligative properties are solution characteristics that depend on the number of dissolved particles rather than their identity. They include vapor pressure lowering, boiling point elevation, freezing point depression, and osmotic pressure.';
    } else if (title == 'Colloids and Suspensions') {
      return 'Colloids are heterogeneous mixtures with particles ranging from 1 to 1000 nanometers that remain dispersed due to the Tyndall effect and Brownian motion. Suspensions contain larger particles that may eventually settle. Both have important applications in medicine, food science, and industry.';
    } else if (title == 'Phase Diagrams') {
      return 'Phase diagrams are graphical representations showing the relationships between temperature, pressure, and physical states of a substance. They illustrate phase transitions, critical points, triple points, and help predict material behavior under different conditions.';

      // Reactions category
    } else if (title == 'Chemical Equations') {
      return 'Chemical equations are symbolic representations of chemical reactions, showing reactants, products, and their proportions. Balancing requires adjusting coefficients to ensure mass conservation according to the Law of Conservation of Mass.';
    } else if (title == 'Chemical Reaction Types' ||
        title == 'Reaction Types') {
      return 'Chemical reactions are classified into different types based on the reaction mechanism, including synthesis (combination), decomposition, single and double displacement, combustion, acid-base reactions, and redox reactions. Each follows distinct patterns for predicting products.';
    } else if (title == 'Chemical Equilibrium' || title == 'Equilibrium') {
      return 'Chemical equilibrium is the state where the forward and reverse reactions occur at equal rates, resulting in constant concentrations of reactants and products. Le Chatelier\'s Principle explains how systems respond to disturbances to reestablish equilibrium.';
    } else if (title == 'Redox Reactions') {
      return 'Redox (reduction-oxidation) reactions involve the transfer of electrons between reactants. Oxidation is the loss of electrons, while reduction is the gain of electrons. These reactions power batteries, enable cellular respiration, and are fundamental to many industrial processes.';
    } else if (title == 'Acid-Base Reactions') {
      return 'Acid-base reactions involve proton (H+) transfer according to Brønsted-Lowry theory or electron pair sharing according to Lewis theory. They determine pH values, drive buffer systems, and are essential in biochemistry, environmental science, and industry.';
    } else if (title == 'Precipitation Reactions') {
      return 'Precipitation reactions occur when two soluble compounds react to form an insoluble solid (precipitate). They follow solubility rules and are used in water treatment, qualitative analysis, and synthesis of materials.';

      // Energy & Kinetics category
    } else if (title == 'Thermochemistry') {
      return 'Thermochemistry studies the energy and heat associated with chemical reactions and physical changes. It includes concepts like enthalpy, calorimetry, Hess\'s Law, and bond energies that help predict the energy changes in reactions.';
    } else if (title == 'Chemical Reaction Rates' ||
        title == 'Reaction Rates') {
      return 'Reaction rate measures how quickly reactants are consumed or products are formed in a chemical reaction. Factors affecting rates include concentration, temperature, surface area, catalysts, and activation energy as explained by collision theory.';
    } else if (title == 'Chemical Catalysts' || title == 'Catalysts') {
      return 'Catalysts are substances that increase the rate of a chemical reaction without being consumed in the process. They work by providing an alternative reaction pathway with lower activation energy. Examples include enzymes in biological systems and catalytic converters in vehicles.';
    } else if (title == 'Gibbs Free Energy' || title == 'Free Energy') {
      return 'Gibbs free energy (G) determines the spontaneity of chemical reactions. When ΔG is negative, a reaction is spontaneous. This thermodynamic potential combines enthalpy and entropy changes to predict reaction direction and equilibrium positions.';
    } else if (title == 'Entropy in Chemistry' || title == 'Entropy') {
      return 'Entropy (S) measures the disorder or randomness in a system. The Second Law of Thermodynamics states that the total entropy of an isolated system always increases. Entropy changes help explain why many processes are irreversible and proceed in a particular direction.';
    } else if (title == 'Reaction Mechanisms') {
      return 'Reaction mechanisms describe the step-by-step sequence of elementary reactions that occur during a chemical process. They include intermediates, transition states, rate-determining steps, and explain stereochemistry and regioselectivity of reactions.';

      // Organic Chemistry category
    } else if (title == 'Carbon Compounds') {
      return 'Carbon compounds form the basis of organic chemistry due to carbon\'s ability to form four bonds and create long chains and rings. They include hydrocarbons, alcohols, carbonyls, carboxylic acids, and are essential for life and modern materials.';
    } else if (title == 'Functional Groups') {
      return 'Functional groups are specific groups of atoms within molecules that give the molecule characteristic chemical reactions. Examples include hydroxyl (-OH), carbonyl (C=O), carboxyl (-COOH), and amino (-NH₂) groups that determine chemical properties.';
    } else if (title == 'Organic Reactions') {
      return 'Organic reactions are chemical reactions involving organic compounds. Major types include addition, elimination, substitution, rearrangement, and redox reactions. They form the basis for synthesizing pharmaceuticals, polymers, and other valuable compounds.';
    } else if (title == 'Stereochemistry') {
      return 'Stereochemistry studies the three-dimensional arrangement of atoms in molecules and how this affects chemical properties. It includes concepts of chirality, enantiomers, diastereomers, and geometric isomers crucial in pharmaceutical development.';
    } else if (title == 'Aromatic Compounds') {
      return 'Aromatic compounds contain rings with delocalized electrons following Hückel\'s Rule (4n+2 π electrons). Benzene is the simplest example. They undergo electrophilic aromatic substitution rather than addition reactions and are prevalent in pharmaceuticals and materials.';
    } else if (title == 'Polymer Chemistry' || title == 'Polymers') {
      return 'Polymers are large molecules composed of repeating subunits called monomers. They form through addition or condensation polymerization and include natural polymers like proteins and synthetic materials like plastics, rubber, and fibers.';

      // Biochemistry category
    } else if (title == 'Protein Chemistry' || title == 'Proteins') {
      return 'Proteins are large biomolecules composed of amino acid chains. Their structure is hierarchical (primary to quaternary) and determines their function. They act as enzymes, structural components, signaling molecules, and are essential for virtually all cellular processes.';
    } else if (title == 'Carbohydrate Chemistry' || title == 'Carbohydrates') {
      return 'Carbohydrates are organic compounds consisting of carbon, hydrogen, and oxygen atoms, typically with the formula (CH₂O)n. They include simple sugars (monosaccharides), disaccharides, and polysaccharides that serve as energy sources and structural components.';
    } else if (title == 'Lipid Chemistry' || title == 'Lipids') {
      return 'Lipids are hydrophobic biomolecules that include fats, oils, waxes, steroids, and phospholipids. They store energy, form cell membranes, serve as signaling molecules, and play crucial roles in metabolism and cellular structure.';
    } else if (title == 'Nucleic Acids') {
      return 'Nucleic acids (DNA and RNA) are polymers of nucleotides that store and transmit genetic information. DNA contains the genetic blueprint while RNA performs various functions including protein synthesis through transcription and translation processes.';
    } else if (title == 'Enzyme Chemistry' || title == 'Enzymes') {
      return 'Enzymes are biological catalysts that dramatically accelerate chemical reactions in living systems without being consumed. They have specific active sites, exhibit substrate specificity, and are regulated through inhibition, activation, and allosteric effects.';
    } else if (title == 'Metabolic Chemistry' || title == 'Metabolism') {
      return 'Metabolism encompasses all chemical reactions in organisms that maintain life. It includes catabolic pathways that break down molecules to release energy and anabolic pathways that build complex molecules using energy. Key pathways include glycolysis, citric acid cycle, and oxidative phosphorylation.';

      // Analytical Chemistry category
    } else if (title == 'Spectroscopy') {
      return 'Spectroscopy studies the interaction between matter and electromagnetic radiation. Techniques include UV-visible, infrared, NMR, and mass spectroscopy that analyze molecular structure, functional groups, and chemical composition based on absorption, emission, or scattering of radiation.';
    } else if (title == 'Chromatography') {
      return 'Chromatography separates mixtures based on differential partitioning between a mobile and stationary phase. Techniques include thin-layer, column, gas, and high-performance liquid chromatography used for analysis, purification, and isolation of compounds.';
    } else if (title == 'Titration Methods' || title == 'Titration') {
      return 'Titration is a quantitative analytical method where a solution of known concentration is used to determine the concentration of an unknown solution. Types include acid-base, redox, complexometric, and precipitation titrations, each with characteristic indicators and endpoints.';
    } else if (title == 'Mass Spectrometry') {
      return 'Mass spectrometry identifies compounds by measuring the mass-to-charge ratio of ions. It involves ionization, acceleration, deflection, and detection of fragments. The resulting mass spectrum reveals molecular weight and structural information of compounds.';
    } else if (title == 'Electrochemical Analysis') {
      return 'Electrochemical analysis uses electrical properties for chemical analysis. Techniques include potentiometry, voltammetry, and electrochemical impedance spectroscopy to determine concentration, reaction kinetics, and material properties in solutions.';
    } else if (title == 'Chemical Sensors') {
      return 'Chemical sensors detect specific chemicals through physical or chemical responses translated into measurable signals. They utilize principles such as electrochemistry, optics, or chemical reactions and are used in environmental monitoring, diagnostics, and industrial control.';

      // Environmental Chemistry category
    } else if (title == 'Air Pollution Chemistry') {
      return 'Air pollution chemistry studies chemical compositions and reactions of atmospheric pollutants including particulate matter, ozone, nitrogen oxides, sulfur dioxide, and volatile organic compounds. It addresses formation mechanisms, transport, and environmental impacts.';
    } else if (title == 'Water Chemistry') {
      return 'Water chemistry examines the chemical composition and reactions of water in natural and engineered systems. It includes pH, alkalinity, hardness, dissolved oxygen, and contaminants affecting water quality, treatment processes, and aquatic ecosystems.';
    } else if (title == 'Soil Chemistry') {
      return 'Soil chemistry studies the chemical constituents and reactions in soil. It examines mineral composition, organic matter, acidity, cation exchange capacity, and nutrient cycling critical for agriculture, environmental management, and geochemical processes.';
    } else if (title == 'Green Chemistry') {
      return 'Green chemistry focuses on designing chemical products and processes that reduce or eliminate hazardous substances. It follows principles such as atom economy, energy efficiency, renewable feedstocks, and biodegradability to minimize environmental impact.';
    } else if (title == 'Climate Chemistry') {
      return 'Climate chemistry explores chemical processes in Earth\'s atmosphere affecting climate, including greenhouse gas dynamics, aerosol effects, stratospheric ozone depletion, and feedback mechanisms that influence global temperature and precipitation patterns.';
    } else if (title == 'Chemical Toxicology') {
      return 'Chemical toxicology studies harmful effects of chemicals on living organisms. It investigates mechanisms of toxicity, dose-response relationships, bioaccumulation, and risk assessment for industrial chemicals, pharmaceuticals, pesticides, and natural toxins.';

      // Industrial Chemistry category
    } else if (title == 'Chemical Engineering') {
      return 'Chemical engineering applies physics, chemistry, biology, and mathematics to design and operate chemical processes at industrial scale. It encompasses reaction engineering, separation techniques, process control, and plant design for manufacturing chemicals, fuels, and materials.';
    } else if (title == 'Industrial Polymer Production') {
      return 'Industrial polymer production involves large-scale synthesis of polymeric materials through polymerization processes. It includes reactor design, catalysis, process optimization, and product formulation for plastics, fibers, elastomers, and specialty polymers.';
    } else if (title == 'Petroleum Chemistry') {
      return 'Petroleum chemistry focuses on the composition and processing of crude oil and natural gas. It includes refining, catalytic cracking, reforming, and hydroprocessing to produce fuels, lubricants, and feedstocks for the petrochemical industry.';
    } else if (title == 'Pharmaceutical Synthesis') {
      return 'Pharmaceutical synthesis creates medicinal compounds through organic chemistry routes. It employs retrosynthetic analysis, protecting groups, stereoselective synthesis, and green chemistry principles to develop efficient and sustainable drug manufacturing processes.';
    } else if (title == 'Food Chemistry') {
      return 'Food chemistry studies the composition and properties of food materials and changes they undergo during processing, storage, and cooking. It examines proteins, carbohydrates, lipids, additives, and their roles in nutrition, flavor, texture, and preservation.';
    } else if (title == 'Materials Chemistry') {
      return 'Materials chemistry investigates the design, synthesis, and properties of functional materials. It encompasses metals, ceramics, semiconductors, polymers, composites, and nanomaterials used in electronics, energy storage, catalysis, and biomedical applications.';
    }

    // Default description if no specific topic matches
    return 'A fundamental concept in chemistry that helps us understand the composition and behavior of matter through experimental and theoretical approaches.';
  }
}
