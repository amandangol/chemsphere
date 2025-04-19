import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/chemistry_guide.dart';
import '../provider/chemistry_guide_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicDetailScreen extends StatefulWidget {
  final ChemistryTopic topic;

  const TopicDetailScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  bool _isLoading = false;
  bool _fetchedContent = false;
  double _textScaleFactor = 1.0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // If content is empty or we don't have Wikipedia URL, fetch it
    if (widget.topic.content.isEmpty || widget.topic.wikipediaUrl == null) {
      _fetchArticleSummary();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchArticleSummary() async {
    if (_fetchedContent) return;

    setState(() {
      _isLoading = true;
    });

    final provider =
        Provider.of<ChemistryGuideProvider>(context, listen: false);
    await provider.getArticleSummary(widget.topic.title);

    setState(() {
      _isLoading = false;
      _fetchedContent = true;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChemistryGuideProvider>(
        builder: (context, provider, child) {
          // Use selectedTopic from provider if available (contains full data),
          // otherwise use the widget topic
          final topic = provider.selectedTopic?.title == widget.topic.title
              ? provider.selectedTopic!
              : widget.topic;

          if (_isLoading || provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading content...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fetchArticleSummary,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return _buildContent(topic, provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "related_topics",
        onPressed: _showRelatedTopics,
        child: const Icon(Icons.explore),
        tooltip: 'Explore related topics',
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Text Size'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sample text',
                style: GoogleFonts.poppins(
                  fontSize: 16 * _textScaleFactor,
                ),
              ),
              const SizedBox(height: 20),
              Slider(
                value: _textScaleFactor,
                min: 0.8,
                max: 1.6,
                divisions: 4,
                label: '${(_textScaleFactor * 100).toInt()}%',
                onChanged: (value) {
                  setState(() {
                    _textScaleFactor = value;
                  });
                  this.setState(() {});
                },
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

  void _showRelatedTopics() {
    final provider =
        Provider.of<ChemistryGuideProvider>(context, listen: false);
    final relatedTopics = _getRelatedTopics(widget.topic.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        minChildSize: 0.2,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Related Topics',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: relatedTopics.length,
                itemBuilder: (context, index) {
                  final topic = relatedTopics[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(topic),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        Navigator.of(context).pop();

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Loading related topic...'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        try {
                          final relatedTopic =
                              await provider.getArticleSummary(topic);

                          if (mounted) {
                            Navigator.of(context)
                                .pop(); // Dismiss loading dialog

                            if (relatedTopic != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopicDetailScreen(
                                    topic: relatedTopic,
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(context)
                                .pop(); // Dismiss loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error loading related topic: $e')),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getRelatedTopics(String title) {
    // Map titles to related topics
    final Map<String, List<String>> relatedTopicMap = {
      'Atom': [
        'Element',
        'Subatomic particle',
        'Quantum mechanics',
        'Atomic nucleus',
        'Electron'
      ],
      'Chemical bond': [
        'Covalent bond',
        'Ionic bond',
        'Hydrogen bond',
        'Metallic bond',
        'Lewis structure'
      ],
      'Periodic Table': [
        'Element',
        'Chemical element',
        'Dmitri Mendeleev',
        'Atomic number',
        'Group (periodic table)'
      ],
      'States of matter': [
        'Solid',
        'Liquid',
        'Gas',
        'Plasma (physics)',
        'Phase transition'
      ],
      'Chemical reaction': [
        'Chemical equation',
        'Reaction rate',
        'Catalyst',
        'Equilibrium',
        'Enthalpy'
      ],
      'Organic chemistry': [
        'Carbon',
        'Functional group',
        'Hydrocarbon',
        'Organic compound',
        'Chemical synthesis'
      ],
      'Nuclear chemistry': [
        'Radioactive decay',
        'Nuclear fission',
        'Nuclear fusion',
        'Isotope',
        'Radioactive dating'
      ],
    };

    // Generic related topics by category
    String category = _getCategoryFromTitle(title);
    List<String> topics = [];

    // Try to find exact matches first
    if (relatedTopicMap.containsKey(title)) {
      topics = relatedTopicMap[title]!;
    }
    // Otherwise use category-based suggestions
    else if (category == 'fundamentals') {
      topics = [
        'Atom',
        'Element',
        'Molecule',
        'Chemical bond',
        'Periodic table'
      ];
    } else if (category == 'matter') {
      topics = [
        'States of matter',
        'Solution (chemistry)',
        'Mixture',
        'Colloid',
        'Suspension'
      ];
    } else if (category == 'reactions') {
      topics = [
        'Chemical reaction',
        'Redox',
        'Acid-base reaction',
        'Precipitation (chemistry)',
        'Combustion'
      ];
    } else if (category == 'energy') {
      topics = [
        'Thermodynamics',
        'Enthalpy',
        'Entropy',
        'Gibbs free energy',
        'Endothermic process'
      ];
    } else if (category == 'organic') {
      topics = [
        'Organic chemistry',
        'Functional group',
        'Hydrocarbon',
        'Polymer',
        'Biochemistry'
      ];
    } else {
      // Default related topics
      topics = [
        'Chemistry',
        'Chemical compound',
        'Chemical element',
        'Molecule',
        'Chemical reaction'
      ];
    }

    return topics;
  }

  String _getCategoryFromTitle(String title) {
    title = title.toLowerCase();

    if (title.contains('atom') ||
        title.contains('element') ||
        title.contains('periodic') ||
        title.contains('bond') ||
        title.contains('molecule')) {
      return 'fundamentals';
    } else if (title.contains('matter') ||
        title.contains('solution') ||
        title.contains('mixture') ||
        title.contains('concentration')) {
      return 'matter';
    } else if (title.contains('reaction') ||
        title.contains('equation') ||
        title.contains('equilibrium')) {
      return 'reactions';
    } else if (title.contains('thermo') ||
        title.contains('energy') ||
        title.contains('rate') ||
        title.contains('catalyst') ||
        title.contains('nuclear')) {
      return 'energy';
    } else if (title.contains('organic') ||
        title.contains('carbon') ||
        title.contains('functional')) {
      return 'organic';
    }

    return 'general';
  }

  Widget _buildContent(ChemistryTopic topic, ChemistryGuideProvider provider) {
    // If content is still empty and not already loading, try to fetch it again
    if (topic.content.isEmpty && !_isLoading && !_fetchedContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchArticleSummary();
      });

      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading content...'),
          ],
        ),
      );
    }

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildTopicHeader(topic, provider),
            ),
            actions: [
              // Favorite button
              IconButton(
                icon: Icon(
                  topic.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: topic.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  provider.toggleFavorite(topic.id);
                },
                tooltip: topic.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),

              // Text size control
              IconButton(
                icon: const Icon(Icons.text_fields),
                onPressed: _showTextSizeDialog,
                tooltip: 'Adjust text size',
              ),

              // Wikipedia link
              if (topic.wikipediaUrl != null)
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () => _launchURL(topic.wikipediaUrl!),
                  tooltip: 'Open in Wikipedia',
                ),
            ],
          ),
        ];
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content summary
            if (topic.content.isNotEmpty) ...[
              // Content section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: _getColorForTopic(topic.title),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getColorForTopic(topic.title),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        _cleanHtmlContent(topic.content),
                        style: GoogleFonts.poppins(
                          fontSize: 16 * _textScaleFactor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Examples section if available
              if (topic.examples.isNotEmpty) ...[
                _buildExamplesSection(topic),
                const SizedBox(height: 20),
              ],

              // Detailed sections if available
              if (topic.sections.isNotEmpty) ...[
                Text(
                  'Detailed Information',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getColorForTopic(topic.title),
                  ),
                ),
                const SizedBox(height: 12),
                ...topic.sections
                    .map((section) => _buildSection(section, topic)),
                const SizedBox(height: 20),
              ],

              // Images gallery if available
              if (topic.relatedImages.isNotEmpty) ...[
                _buildImagesGallery(topic),
                const SizedBox(height: 20),
              ],

              // "Did you know" section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Did you know?',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDidYouKnowFact(topic.title),
                        style: GoogleFonts.poppins(
                          fontSize: 14 * _textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No content available for this topic',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Wikipedia attribution
            const SizedBox(height: 32),
            if (topic.wikipediaUrl != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              child: Image(
                                image: NetworkImage(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/Wikipedia_svg_logo.svg/103px-Wikipedia_svg_logo.svg.png'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Content from Wikipedia',
                            style: GoogleFonts.poppins(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Read more on Wikipedia'),
                        onPressed: () => _launchURL(topic.wikipediaUrl!),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicHeader(
      ChemistryTopic topic, ChemistryGuideProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getColorForTopic(topic.title),
            _getColorForTopic(topic.title).withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
        child: Row(
          children: [
            // Image or icon
            if (topic.thumbnailUrl != null) ...[
              GestureDetector(
                onTap: () => _showFullScreenImage(topic.thumbnailUrl!),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: topic.thumbnailUrl!,
                      fit: BoxFit.contain,
                      errorWidget: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ] else ...[
              // Placeholder icon if no image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getIconForTopic(topic.title),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            // Title
            Expanded(
              child: Text(
                topic.title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple helper to clean HTML content
  String _cleanHtmlContent(String content) {
    if (content.startsWith('<')) {
      // Very basic HTML cleanup - remove tags
      return content
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('\n\n', '\n');
    }
    return content;
  }

  String _getDidYouKnowFact(String title) {
    final Map<String, String> facts = {
      'Atom':
          'If an atom were the size of a football stadium, the nucleus would be the size of a pea at the center.',
      'Element':
          'There are 94 naturally occurring elements on Earth. All elements beyond uranium (element 92) are either synthetic or only found in trace amounts due to radioactive decay.',
      'Periodic Table':
          'Dmitri Mendeleev left gaps in his periodic table for undiscovered elements and successfully predicted their properties before they were discovered.',
      'Chemical bond':
          'The strongest type of chemical bond is the covalent triple bond found in nitrogen molecules (N₂), which is why nitrogen gas is very stable.',
      'States of matter':
          'There are actually more than three states of matter. In addition to solid, liquid, and gas, there are also plasma, Bose-Einstein condensates, and several others.',
      'Solution':
          'The worlds oceans are a complex solution containing over 70 different elements.',
      'Chemical reaction':
          'Bioluminescent reactions in fireflies and deep-sea creatures convert chemical energy directly into light with nearly 100% efficiency.',
      'Catalyst':
          'Enzymes can increase reaction rates by up to 10¹⁷ times, making them some of the most efficient catalysts known.',
      'Organic chemistry':
          'Carbon can form more compounds than all other elements combined, with over 10 million known organic compounds.',
      'Nuclear chemistry':
          'Nuclear reactions release about a million times more energy per atom than chemical reactions.'
    };

    // Find the most relevant fact by checking if any key is contained in the title
    for (var key in facts.keys) {
      if (title.toLowerCase().contains(key.toLowerCase())) {
        return facts[key]!;
      }
    }

    // Default facts by category
    String category = _getCategoryFromTitle(title);

    if (category == 'fundamentals') {
      return 'The lightest element, hydrogen, accounts for about 75% of all the mass in the universe, while helium accounts for about 24%.';
    } else if (category == 'matter') {
      return 'Water is one of the few substances that expands when it freezes, which is why ice floats.';
    } else if (category == 'reactions') {
      return 'The rusting of iron is actually a slow combustion reaction, releasing heat just like a fire, but at a much slower rate.';
    } else if (category == 'energy') {
      return 'The human body performs thousands of chemical reactions every second, all operating at body temperature (about 37°C) thanks to enzymes.';
    } else if (category == 'organic') {
      return 'DNA, the molecule that carries genetic information, can be up to 2 meters long when stretched out, but fits inside a cell nucleus just 10 micrometers wide.';
    }

    // Generic fact
    return 'Chemistry was originally practiced as alchemy, which included elements of magic and spirituality alongside early scientific principles.';
  }

  IconData _getIconForTopic(String topicTitle) {
    final Map<String, IconData> topicIcons = {
      'Atom': Icons.circle_outlined,
      'Element': Icons.category,
      'Periodic Table': Icons.grid_on,
      'Chemical bond': Icons.link,
      'States of matter': Icons.change_history,
      'Solution': Icons.opacity,
      'Mixture': Icons.bubble_chart,
      'Concentration': Icons.science,
      'Chemical equation': Icons.sync_alt,
      'Chemical reaction': Icons.sync,
      'Equilibrium': Icons.balance,
      'Thermochemistry': Icons.whatshot,
      'Reaction rate': Icons.speed,
      'Catalyst': Icons.fast_forward,
      'Organic chemistry': Icons.spa,
      'Carbon': Icons.hexagon,
      'Functional group': Icons.category,
      'Nuclear chemistry': Icons.radio_button_checked,
    };

    for (var key in topicIcons.keys) {
      if (topicTitle.toLowerCase().contains(key.toLowerCase())) {
        return topicIcons[key]!;
      }
    }

    return Icons.science;
  }

  Color _getColorForTopic(String topicTitle) {
    // Determine category
    String category = _getCategoryFromTitle(topicTitle);

    // Return color based on category
    if (category == 'fundamentals') {
      return Colors.blue;
    } else if (category == 'matter') {
      return Colors.teal;
    } else if (category == 'reactions') {
      return Colors.orange;
    } else if (category == 'energy') {
      return Colors.red;
    } else if (category == 'organic') {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.primary;
  }

  Widget _buildExamplesSection(ChemistryTopic topic) {
    final color = _getColorForTopic(topic.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.science, color: color),
            const SizedBox(width: 8),
            Text(
              'Examples',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topic.examples.map((example) => _buildExampleCard(example, color)),
      ],
    );
  }

  Widget _buildExampleCard(TopicExample example, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              example.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              example.description,
              style: GoogleFonts.poppins(
                fontSize: 14 * _textScaleFactor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGallery(ChemistryTopic topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image,
              color: _getColorForTopic(topic.title),
            ),
            const SizedBox(width: 8),
            Text(
              'Gallery',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getColorForTopic(topic.title),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topic.relatedImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(topic.relatedImages[index]),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Image.network(
                      topic.relatedImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey.shade400,
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
      ],
    );
  }

  Widget _buildSection(TopicSection section, ChemistryTopic topic) {
    final color = _getColorForTopic(topic.title);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: section.level == 1 ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: GoogleFonts.poppins(
                fontSize: section.level == 1 ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...section.content.map((content) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 15 * _textScaleFactor,
                      height: 1.5,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
