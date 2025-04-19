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
      'title': 'Chemical bond',
      'description': 'Explore different types of chemical bonds',
      'icon': 'link',
      'category': 'fundamentals',
    },
    {
      'title': 'Periodic table',
      'description': 'History and organization of the periodic table',
      'icon': 'table_chart',
      'category': 'fundamentals',
    },
    {
      'title': 'Acid-base reaction',
      'description': 'Understand acid-base reactions and their applications',
      'icon': 'science',
      'category': 'reactions',
    },
    {
      'title': 'Redox',
      'description': 'Reduction-oxidation reactions in chemistry',
      'icon': 'swap_vert',
      'category': 'reactions',
    },
    {
      'title': 'Organic chemistry',
      'description': 'Study of carbon-based compounds',
      'icon': 'grass',
      'category': 'organic',
    },
    {
      'title': 'Electrochemistry',
      'description': 'Chemical reactions involving electricity',
      'icon': 'bolt',
      'category': 'energy',
    },
    {
      'title': 'Thermochemistry',
      'description': 'Energy changes in chemical reactions',
      'icon': 'thermostat',
      'category': 'energy',
    },
    {
      'title': 'Biochemistry',
      'description': 'Chemical processes in living organisms',
      'icon': 'biotech',
      'category': 'organic',
    },
    {
      'title': 'Chemical equilibrium',
      'description': 'Balanced state of opposing reactions',
      'icon': 'balance',
      'category': 'reactions',
    },
    {
      'title': 'Solutions',
      'description': 'Homogeneous mixtures of substances',
      'icon': 'opacity',
      'category': 'matter',
    },
    {
      'title': 'Nuclear chemistry',
      'description': 'Study of radioactivity and nuclear processes',
      'icon': 'radio_button_checked',
      'category': 'energy',
    },
    {
      'title': 'Chemical kinetics',
      'description': 'Rates and mechanisms of chemical reactions',
      'icon': 'speed',
      'category': 'reactions',
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
    return Consumer<ChemistryGuideProvider>(
      builder: (context, provider, child) {
        final favoriteTopics = provider.favoriteTopics;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Explore Topics',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
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
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 12,
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
    return SizedBox(
      height: 250,
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
                horizontalOffset: 50.0,
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
    if (favoriteTopics.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite topics yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add topics to favorites by tapping the heart icon',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
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
                horizontalOffset: 50.0,
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
    final IconData icon = _getIconForName(topic['icon'] ?? 'science');
    final Color color =
        _getColorForCategory(topic['category'] ?? 'fundamentals');

    return GestureDetector(
      onTap: () => _loadTopicDetail(context, topic['title']!),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Container(
          width: 160,
          height: 220, // Fixed height for consistency
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
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: color,
                    ),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  topic['title']!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Text(
                  topic['description']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Expanded pushes the button to the bottom
              const Expanded(child: SizedBox()),

              // View Topic button
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 12,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'View Topic',
                        style: TextStyle(
                          fontSize: 10,
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
    final Color color =
        _getColorForCategory(_getCategoryFromTitle(topic.title));

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TopicDetailScreen(topic: topic),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Container(
          width: 160,
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
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: topic.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: topic.thumbnailUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: color.withOpacity(0.1),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconForTitle(topic.title),
                                  size: 32,
                                  color: color,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getIconForTitle(topic.title),
                              size: 32,
                              color: color,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      topic.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Text(
                      topic.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Remove from favorites button
              Positioned(
                top: 8,
                right: 8,
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
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    splashRadius: 20,
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
      default:
        return Icons.science;
    }
  }

  IconData _getIconForTitle(String title) {
    title = title.toLowerCase();
    if (title.contains('bond')) return Icons.link;
    if (title.contains('periodic')) return Icons.table_chart;
    if (title.contains('acid') || title.contains('base')) return Icons.science;
    if (title.contains('redox')) return Icons.swap_vert;
    if (title.contains('organic')) return Icons.grass;
    if (title.contains('electro')) return Icons.bolt;
    if (title.contains('thermo')) return Icons.thermostat;
    if (title.contains('biochem')) return Icons.biotech;
    if (title.contains('equilibrium')) return Icons.balance;
    if (title.contains('solution')) return Icons.opacity;
    if (title.contains('nuclear')) return Icons.radio_button_checked;
    if (title.contains('kinetic') || title.contains('rate')) return Icons.speed;
    return Icons.science;
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'fundamentals':
        return Colors.blue;
      case 'reactions':
        return Colors.orange;
      case 'organic':
        return Colors.green;
      case 'energy':
        return Colors.red;
      case 'matter':
        return Colors.teal;
      default:
        return Colors.purple;
    }
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
        title.contains('catalyst')) {
      return 'energy';
    } else if (title.contains('organic') ||
        title.contains('carbon') ||
        title.contains('functional')) {
      return 'organic';
    }

    return 'general';
  }
}
