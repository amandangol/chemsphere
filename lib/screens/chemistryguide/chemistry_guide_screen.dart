import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io'; // Import for SocketException
import '../../utils/error_handler.dart';
import '../../widgets/chemistry_widgets.dart';
import 'provider/chemistry_guide_provider.dart';
import 'model/chemistry_guide.dart';
import 'widgets/topic_search_screen.dart';
import 'widgets/topic_detail_screen.dart';
import 'widgets/recommended_topics_widget.dart';

class ChemistryGuideScreen extends StatefulWidget {
  const ChemistryGuideScreen({Key? key}) : super(key: key);

  @override
  State<ChemistryGuideScreen> createState() => _ChemistryGuideScreenState();
}

class _ChemistryGuideScreenState extends State<ChemistryGuideScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<GuideCategory> _categories = [
    GuideCategory(
      title: 'Fundamentals',
      icon: Icons.school,
      color: Colors.blue,
      topics: [
        GuideTopic(
          title: 'Atoms and Elements',
          description: 'The basic building blocks of matter',
          icon: Icons.circle_outlined,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Atoms and Elements'),
        ),
        GuideTopic(
          title: 'Periodic Table',
          description: 'Organization and trends of elements',
          icon: Icons.grid_on,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Periodic Table'),
        ),
        GuideTopic(
          title: 'Chemical Bonds',
          description: 'How atoms connect to form molecules',
          icon: Icons.link,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Bonds'),
        ),
        GuideTopic(
          title: 'Nuclear Chemistry',
          description: 'Study of radioactive decay and nuclear processes',
          icon: Icons.radio_button_checked,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Nuclear Chemistry'),
        ),
      ],
    ),
    GuideCategory(
      title: 'Matter & Solutions',
      icon: Icons.opacity,
      color: Colors.teal,
      topics: [
        GuideTopic(
          title: 'States of Matter',
          description: 'Solids, liquids, gases, and phase transitions',
          icon: Icons.change_history,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'States of Matter'),
        ),
        GuideTopic(
          title: 'Solutions & Mixtures',
          description: 'How substances dissolve and mix',
          icon: Icons.bubble_chart,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Solutions and Mixtures'),
        ),
        GuideTopic(
          title: 'Concentration',
          description: 'Measuring amounts in solutions',
          icon: Icons.science,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Concentration'),
        ),
      ],
    ),
    GuideCategory(
      title: 'Reactions',
      icon: Icons.flash_on,
      color: Colors.orange,
      topics: [
        GuideTopic(
          title: 'Chemical Equations',
          description: 'Balancing and interpreting reactions',
          icon: Icons.sync_alt,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Equations'),
        ),
        GuideTopic(
          title: 'Reaction Types',
          description: 'Categories of chemical reactions',
          icon: Icons.category,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Reaction Types'),
        ),
        GuideTopic(
          title: 'Equilibrium',
          description: 'When reactions reach balance',
          icon: Icons.balance,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Equilibrium'),
        ),
      ],
    ),
    GuideCategory(
      title: 'Energy & Kinetics',
      icon: Icons.bolt,
      color: Colors.red,
      topics: [
        GuideTopic(
          title: 'Thermochemistry',
          description: 'Heat energy in chemical reactions',
          icon: Icons.whatshot,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Thermochemistry'),
        ),
        GuideTopic(
          title: 'Reaction Rates',
          description: 'How fast reactions occur',
          icon: Icons.speed,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Reaction Rates'),
        ),
        GuideTopic(
          title: 'Catalysts',
          description: 'Substances that speed up reactions',
          icon: Icons.fast_forward,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Chemical Catalysts'),
        ),
      ],
    ),
    GuideCategory(
      title: 'Organic Chemistry',
      icon: Icons.spa,
      color: Colors.green,
      topics: [
        GuideTopic(
          title: 'Carbon Compounds',
          description: 'The foundation of organic chemistry',
          icon: Icons.hexagon,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Carbon Compounds'),
        ),
        GuideTopic(
          title: 'Functional Groups',
          description: 'Important molecular structures',
          icon: Icons.category,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Functional Groups'),
        ),
        GuideTopic(
          title: 'Organic Reactions',
          description: 'How organic molecules transform',
          icon: Icons.transform,
          screenBuilder: (context) =>
              const TopicSearchScreen(title: 'Organic Reactions'),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ChemistryGuideProvider>(context, listen: false);
      provider.initialize();
    });
  }

  Future<void> _searchWikipedia() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearchExpanded = false;
    });

    final provider =
        Provider.of<ChemistryGuideProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching Wikipedia...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      await provider.searchWikipediaArticles(query);

      if (provider.searchResults.isNotEmpty && mounted) {
        // Dismiss loading dialog
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _SearchResultsScreen(
              query: query,
              results: provider.searchResults,
            ),
          ),
        );
      } else {
        if (mounted) {
          // Dismiss loading dialog
          Navigator.pop(context);

          // Show no results message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No results found for "$query"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Dismiss loading dialog
        Navigator.pop(context);

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              centerTitle: true,
              title: innerBoxIsScrolled
                  ? Text(
                      'Chemistry Guide',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'Chemistry Guide',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                centerTitle: false,
                background: Stack(
                  children: [
                    // Background molecular pattern with CachedNetworkImage
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://cdn.vectorstock.com/i/2000v/25/34/alchemy-cartoon-vector-36742534.avif',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) {
                          // Improved error handling for background image
                          print('Error loading background image: $error');
                          if (error is SocketException ||
                              ErrorHandler.isNetworkError(error)) {
                            // For network errors, use a gradient background instead
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.wifi_off,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withOpacity(0.3),
                                  size: 40,
                                ),
                              ),
                            );
                          }

                          // For other errors, show a simple gradient background
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          );
                        },
                        fadeInDuration: const Duration(milliseconds: 300),
                        useOldImageOnUrlChange: true,
                      ),
                    ),
                    // Gradient overlay for better readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4),
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = !_isSearchExpanded;
                      if (!_isSearchExpanded) {
                        _searchController.clear();
                      }
                    });
                  },
                ),
              ],
              bottom: _isSearchExpanded
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(70),
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        color: Theme.of(context).colorScheme.surface,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search Wikipedia for chemistry topics...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _searchWikipedia,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          onSubmitted: (_) => _searchWikipedia(),
                          autofocus: true,
                        ),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: Consumer<ChemistryGuideProvider>(
          builder: (context, provider, child) {
            return AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // Welcome message
                  Card(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    elevation: 2,
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
                                Icons.science,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Welcome to Chemistry Explorer',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover the fascinating world of chemistry through interactive guides, detailed topics, and Wikipedia integration.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Browse categories below or use search to find specific topics',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recommended topics carousel
                  const RecommendedTopicsWidget(),

                  // Categories header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Browse by Category',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Categories
                  ...List.generate(
                    _categories.length,
                    (index) => AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildCategoryCard(
                              context, _categories[index], provider),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PrimaryScrollController.of(context).animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(Icons.arrow_upward),
        tooltip: 'Scroll to top',
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, GuideCategory category,
      ChemistryGuideProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: category.color.withOpacity(0.05),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              category.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          ...category.topics.map((topic) =>
              _buildTopicItem(context, topic, provider, category.color)),
        ],
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, GuideTopic topic,
      ChemistryGuideProvider provider, Color categoryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: CircleAvatar(
          backgroundColor: categoryColor.withOpacity(0.1),
          child: Icon(
            topic.icon,
            color: categoryColor,
          ),
        ),
        title: Text(
          topic.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          topic.description,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: categoryColor,
        ),
        onTap: () {
          if (topic.screenBuilder != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => topic.screenBuilder!(context),
              ),
            );
          }
        },
      ),
    );
  }
}

// Search results screen as a private class within the file
class _SearchResultsScreen extends StatelessWidget {
  final String query;
  final List<String> results;

  const _SearchResultsScreen({
    Key? key,
    required this.query,
    required this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$query"'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                result,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: ChemistryLoadingWidget()),
                );

                try {
                  final provider = Provider.of<ChemistryGuideProvider>(context,
                      listen: false);
                  final topic = await provider.getArticleSummary(result);

                  if (context.mounted) {
                    // Dismiss loading dialog
                    Navigator.pop(context);

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
                  if (context.mounted) {
                    // Dismiss loading dialog
                    Navigator.pop(context);

                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading article: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class GuideCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<GuideTopic> topics;

  GuideCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.topics,
  });
}

class GuideTopic {
  final String title;
  final String description;
  final IconData icon;
  final Widget Function(BuildContext)? screenBuilder;
  final bool isPathway;

  GuideTopic({
    required this.title,
    required this.description,
    required this.icon,
    this.screenBuilder,
    this.isPathway = false,
  });
}
