import 'package:chem_explore/widgets/chemistry_widgets.dart';
import 'package:flutter/material.dart';
import 'topic_detail_screen.dart';
import '../model/chemistry_guide.dart';
import 'package:provider/provider.dart';
import '../provider/chemistry_guide_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class RecommendedTopicsWidget extends StatefulWidget {
  const RecommendedTopicsWidget({Key? key}) : super(key: key);

  @override
  State<RecommendedTopicsWidget> createState() =>
      _RecommendedTopicsWidgetState();
}

class _RecommendedTopicsWidgetState extends State<RecommendedTopicsWidget>
    with SingleTickerProviderStateMixin {
  // List of recommended chemistry topics that are well-documented on Wikipedia
  static const List<Map<String, String>> _recommendedTopics = [
    {
      'title': 'Molecular Orbital Theory',
      'description': 'How electrons distribute across molecules',
      'icon': 'waves',
      'category': 'fundamentals',
    },
    {
      'title': 'Lanthanides & Actinides',
      'description': 'The fascinating f-block elements',
      'icon': 'science',
      'category': 'fundamentals',
    },
    {
      'title': 'Superconductivity',
      'description': 'Materials with zero electrical resistance',
      'icon': 'bolt',
      'category': 'matter',
    },
    {
      'title': 'Electrochemical Cells',
      'description': 'Converting chemical energy to electricity',
      'icon': 'battery_full',
      'category': 'energy',
    },
    {
      'title': 'Crystallography',
      'description': 'Atomic arrangements in crystalline solids',
      'icon': 'grid_3x3',
      'category': 'matter',
    },
    {
      'title': 'Photochemistry',
      'description': 'Chemical reactions triggered by light',
      'icon': 'wb_sunny',
      'category': 'reactions',
    },
    {
      'title': 'Radiochemistry',
      'description': 'Chemistry of radioactive elements',
      'icon': 'radio_button_checked',
      'category': 'fundamentals',
    },
    {
      'title': 'Coordination Compounds',
      'description': 'Metal complexes with ligands',
      'icon': 'hub',
      'category': 'reactions',
    },
    {
      'title': 'Nanomaterials',
      'description': 'Materials engineered at nanoscale',
      'icon': 'grain',
      'category': 'matter',
    },
    {
      'title': 'Chirality',
      'description': 'Mirror-image molecules that don\'t superimpose',
      'icon': 'flip',
      'category': 'organic',
    },
    {
      'title': 'Enzyme Kinetics',
      'description': 'How biological catalysts accelerate reactions',
      'icon': 'speed',
      'category': 'biochemistry',
    },
    {
      'title': 'Molecular Spectroscopy',
      'description': 'Using light to identify molecular structures',
      'icon': 'graphic_eq',
      'category': 'analytical',
    },
    {
      'title': 'Astrochemistry',
      'description': 'Chemistry of celestial bodies and space',
      'icon': 'star',
      'category': 'environmental',
    },
    {
      'title': 'Supramolecular Chemistry',
      'description': 'Complexes of molecules held by weak forces',
      'icon': 'link',
      'category': 'organic',
    },
    {
      'title': 'Computational Chemistry',
      'description': 'Using computers to solve chemical problems',
      'icon': 'computer',
      'category': 'analytical',
    },
    {
      'title': 'Medicinal Chemistry',
      'description': 'Designing and developing pharmaceutical drugs',
      'icon': 'medication',
      'category': 'industrial',
    },
    {
      'title': 'Chemical Oceanography',
      'description': 'Chemical composition and processes in oceans',
      'icon': 'water',
      'category': 'environmental',
    },
    {
      'title': 'Ionic Liquids',
      'description': 'Salts in liquid state at room temperature',
      'icon': 'opacity',
      'category': 'matter',
    },
    {
      'title': 'Bioinorganic Chemistry',
      'description': 'Metal ions in biological systems',
      'icon': 'biotech',
      'category': 'biochemistry',
    },
    {
      'title': 'Surface Chemistry',
      'description': 'Phenomena occurring at interfaces',
      'icon': 'layers',
      'category': 'fundamentals',
    },
    {
      'title': 'Food Chemistry',
      'description': 'Chemical processes in food preparation',
      'icon': 'restaurant',
      'category': 'biochemistry',
    },
    {
      'title': 'Organometallic Chemistry',
      'description': 'Compounds with metal-carbon bonds',
      'icon': 'category',
      'category': 'organic',
    },
    {
      'title': 'Forensic Chemistry',
      'description': 'Chemical analysis in criminal investigations',
      'icon': 'search',
      'category': 'analytical',
    },
    {
      'title': 'Atmospheric Chemistry',
      'description': 'Chemical compositions and reactions in air',
      'icon': 'air',
      'category': 'environmental',
    },
  ];

  bool _isLoading = false;
  bool _showFavorites = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showFavorites = _tabController.index == 1;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ChemistryGuideProvider>(
      builder: (context, provider, child) {
        final favoriteTopics = provider.favoriteTopics;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 6),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Explore Topics',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Switch between recommended and favorites
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 11,
                    ),
                    tabs: const [
                      Tab(text: "Recommended"),
                      Tab(text: "Favorites"),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showFavorites
                  ? _buildFavoritesCarousel(favoriteTopics, provider)
                  : _buildRecommendedCarousel(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedCarousel() {
    final theme = Theme.of(context);
    return SizedBox(
      height: 220,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          scrollDirection: Axis.horizontal,
          itemCount: _recommendedTopics.length,
          itemBuilder: (context, index) {
            final topic = _recommendedTopics[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildTopicCard(context, topic),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesCarousel(
      List<ChemistryTopic> favoriteTopics, ChemistryGuideProvider provider) {
    final theme = Theme.of(context);
    if (favoriteTopics.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              'No favorite topics yet',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add topics to favorites by tapping the heart icon',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          scrollDirection: Axis.horizontal,
          itemCount: favoriteTopics.length,
          itemBuilder: (context, index) {
            final topic = favoriteTopics[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 30.0,
                child: FadeInAnimation(
                  child: _buildFavoriteTopicCard(context, topic, provider),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, String> topic) {
    final theme = Theme.of(context);
    final IconData icon = _getIconForName(topic['icon'] ?? 'science');
    final Color color = _getThemedColorForCategory(
        context, topic['category'] ?? 'fundamentals');

    return GestureDetector(
      onTap: () => _loadTopicDetail(context, topic['title']!),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        child: Container(
          width: 150,
          height: 200, // Fixed height for consistency
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.2),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Padding(
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 26,
                      color: color,
                    ),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  topic['title']!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: Text(
                  topic['description']!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Expanded pushes the button to the bottom
              const Expanded(child: SizedBox()),

              // View Topic button
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 10,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Topic',
                        style: TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteTopicCard(BuildContext context, ChemistryTopic topic,
      ChemistryGuideProvider provider) {
    final theme = Theme.of(context);
    final Color color =
        _getThemedColorForCategory(context, _getCategoryFromTitle(topic.title));

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicDetailScreen(topic: topic),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.2),
              ],
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image or icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    alignment: Alignment.center,
                    child: topic.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: topic.thumbnailUrl!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: color.withOpacity(0.1),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getIconForTitle(topic.title),
                                  size: 26,
                                  color: color,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getIconForTitle(topic.title),
                              size: 26,
                              color: color,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      topic.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                    child: Text(
                      topic.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Remove from favorites button
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      provider.toggleFavorite(topic.id);
                    },
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 26,
                      minHeight: 26,
                    ),
                    splashRadius: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadTopicDetail(BuildContext context, String title) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const ChemistryLoadingWidget();
      },
    );

    // Get topic content from provider
    final provider =
        Provider.of<ChemistryGuideProvider>(context, listen: false);

    provider.getArticleSummary(title).then((topic) {
      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        if (topic != null) {
          // Navigate to topic detail
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
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        // Dismiss loading dialog
        Navigator.of(context).pop();

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading topic: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  IconData _getIconForName(String name) {
    switch (name) {
      case 'link':
        return Icons.link;
      case 'table_chart':
        return Icons.table_chart;
      case 'science':
        return Icons.science;
      case 'swap_vert':
        return Icons.swap_vert;
      case 'grass':
        return Icons.grass;
      case 'bolt':
        return Icons.bolt;
      case 'thermostat':
        return Icons.thermostat;
      case 'biotech':
        return Icons.biotech;
      case 'balance':
        return Icons.balance;
      case 'opacity':
        return Icons.opacity;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'speed':
        return Icons.speed;
      case 'waves':
        return Icons.waves;
      case 'water_drop':
        return Icons.water_drop;
      case 'timeline':
        return Icons.timeline;
      case 'sync':
        return Icons.sync;
      case 'fast_forward':
        return Icons.fast_forward;
      case 'category':
        return Icons.category;
      case 'threed_rotation':
        return Icons.threed_rotation;
      case 'hub':
        return Icons.hub;
      case 'loop':
        return Icons.loop;
      case 'graphic_eq':
        return Icons.graphic_eq;
      case 'filter_alt':
        return Icons.filter_alt;
      case 'scale':
        return Icons.scale;
      case 'eco':
        return Icons.eco;
      case 'air':
        return Icons.air;
      case 'medication':
        return Icons.medication;
      case 'grain':
        return Icons.grain;
      case 'flip':
        return Icons.flip;
      case 'star':
        return Icons.star;
      case 'computer':
        return Icons.computer;
      case 'water':
        return Icons.water;
      case 'layers':
        return Icons.layers;
      case 'restaurant':
        return Icons.restaurant;
      case 'search':
        return Icons.search;
      case 'grid_3x3':
        return Icons.grid_3x3;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'battery_full':
        return Icons.battery_full;
      default:
        return Icons.science;
    }
  }

  IconData _getIconForTitle(String title) {
    title = title.toLowerCase();
    if (title.contains('bond')) return Icons.link;
    if (title.contains('periodic')) return Icons.table_chart;
    if (title.contains('atom') || title.contains('element'))
      return Icons.science;
    if (title.contains('quantum')) return Icons.waves;
    if (title.contains('acid') || title.contains('base')) return Icons.balance;
    if (title.contains('redox')) return Icons.swap_vert;
    if (title.contains('organic')) return Icons.grass;
    if (title.contains('electro')) return Icons.bolt;
    if (title.contains('thermo')) return Icons.thermostat;
    if (title.contains('biochem') || title.contains('protein'))
      return Icons.biotech;
    if (title.contains('equilibrium')) return Icons.balance;
    if (title.contains('solution') || title.contains('mixture'))
      return Icons.opacity;
    if (title.contains('nuclear')) return Icons.radio_button_checked;
    if (title.contains('kinetic') || title.contains('rate')) return Icons.speed;
    if (title.contains('catalyst')) return Icons.fast_forward;
    if (title.contains('function')) return Icons.category;
    if (title.contains('stereo')) return Icons.threed_rotation;
    if (title.contains('polymer')) return Icons.link;
    if (title.contains('nucleic')) return Icons.hub;
    if (title.contains('metabol')) return Icons.loop;
    if (title.contains('spectro')) return Icons.graphic_eq;
    if (title.contains('chroma')) return Icons.filter_alt;
    if (title.contains('mass')) return Icons.scale;
    if (title.contains('green') || title.contains('environment'))
      return Icons.eco;
    if (title.contains('pollut')) return Icons.air;
    if (title.contains('pharma')) return Icons.medication;
    if (title.contains('phase')) return Icons.timeline;
    return Icons.science;
  }

  Color _getThemedColorForCategory(BuildContext context, String category) {
    final theme = Theme.of(context);

    switch (category) {
      case 'fundamentals':
        return theme.colorScheme.primary;
      case 'reactions':
        return const Color(0xFFE67700); // Themed orange
      case 'organic':
        return const Color(0xFF2E7D32); // Themed green
      case 'energy':
        return const Color(0xFFB82E2E); // Themed red
      case 'matter':
        return theme.colorScheme.secondary;
      case 'biochemistry':
        return const Color(0xFF6200EA); // Deep purple
      case 'analytical':
        return const Color(0xFF0277BD); // Blue
      case 'environmental':
        return const Color(0xFF00695C); // Teal
      case 'industrial':
        return const Color(0xFF4E342E); // Brown
      default:
        return theme.colorScheme.tertiary;
    }
  }

  String _getCategoryFromTitle(String title) {
    title = title.toLowerCase();

    if (title.contains('atom') ||
        title.contains('element') ||
        title.contains('periodic') ||
        title.contains('bond') ||
        title.contains('quantum') ||
        title.contains('molecule')) {
      return 'fundamentals';
    } else if (title.contains('matter') ||
        title.contains('solution') ||
        title.contains('mixture') ||
        title.contains('colligative') ||
        title.contains('phase') ||
        title.contains('concentration')) {
      return 'matter';
    } else if (title.contains('reaction') ||
        title.contains('acid') ||
        title.contains('base') ||
        title.contains('redox') ||
        title.contains('equation') ||
        title.contains('equilibrium')) {
      return 'reactions';
    } else if (title.contains('thermo') ||
        title.contains('energy') ||
        title.contains('rate') ||
        title.contains('catalyst')) {
      return 'energy';
    } else if (title.contains('organic') ||
        title.contains('carbon') ||
        title.contains('functional') ||
        title.contains('stereo') ||
        title.contains('polymer')) {
      return 'organic';
    } else if (title.contains('protein') ||
        title.contains('nucleic') ||
        title.contains('acid') ||
        title.contains('metabolism') ||
        title.contains('bio')) {
      return 'biochemistry';
    } else if (title.contains('spectro') ||
        title.contains('chroma') ||
        title.contains('mass') ||
        title.contains('analysis') ||
        title.contains('analytic')) {
      return 'analytical';
    } else if (title.contains('green') ||
        title.contains('environment') ||
        title.contains('pollution') ||
        title.contains('sustain')) {
      return 'environmental';
    } else if (title.contains('industrial') ||
        title.contains('pharma') ||
        title.contains('synthesis') ||
        title.contains('manufacture')) {
      return 'industrial';
    }

    return 'general';
  }
}
