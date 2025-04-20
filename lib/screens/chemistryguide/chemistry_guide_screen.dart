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
import '../elements/element_flashcard_screen.dart';

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
      // Only initialize if not already initialized to prevent duplicate loading
      if (!provider.isInitialized) {
        provider.initialize();
      }
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

    // Show loading indicator if we don't have cached results
    bool showLoading = true;

    try {
      // First check if we might have results without showing the dialog
      if (provider.searchResults.isNotEmpty &&
          provider.searchResults.any(
              (result) => result.toLowerCase().contains(query.toLowerCase()))) {
        showLoading = false;
      }

      if (showLoading) {
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
      }

      await provider.searchWikipediaArticles(query);

      if (showLoading && mounted) {
        // Dismiss loading dialog if we showed it
        Navigator.pop(context);
      }

      if (provider.searchResults.isNotEmpty && mounted) {
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
      if (showLoading && mounted) {
        // Dismiss loading dialog if we showed it
        Navigator.pop(context);
      }

      if (mounted) {
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
    final theme = Theme.of(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              centerTitle: false,
              title: innerBoxIsScrolled
                  ? Text(
                      'Chemistry Guide',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
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
                      fontSize: 16,
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
                                theme.colorScheme.primary.withOpacity(0.5),
                                theme.colorScheme.primary.withOpacity(0.7),
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
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.wifi_off,
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.3),
                                  size: 36,
                                ),
                              ),
                            );
                          }

                          // For other errors, show a simple gradient background
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.7),
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
                              theme.colorScheme.primary.withOpacity(0.4),
                              theme.colorScheme.primary.withOpacity(0.8),
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
                      preferredSize: const Size.fromHeight(60),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        color: theme.colorScheme.surface,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search Wikipedia for chemistry topics...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send, size: 18),
                              onPressed: _searchWikipedia,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                          ),
                          onSubmitted: (_) => _searchWikipedia(),
                          autofocus: true,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: Consumer<ChemistryGuideProvider>(
          builder: (context, provider, child) {
            // Show loading indicator only during initial load
            if (provider.loadingState == ChemistryGuideLoadingState.loading &&
                !provider.isInitialized) {
              return const Center(
                child: ChemistryLoadingWidget(),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 40,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Error: ${provider.error}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.initialize();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // Welcome message
                  Card(
                    margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    elevation: 1,
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
                                Icons.science,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Welcome to Chemistry Explorer',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Discover the fascinating world of chemistry through interactive guides, detailed topics, and Wikipedia integration.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color:
                                    theme.colorScheme.primary.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Browse categories below or use search to find specific topics',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurface
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

                  // Flashcard Navigation Widget
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ElementFlashcardScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.tertiary.withOpacity(0.8),
                              theme.colorScheme.primary.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Decorative elements
                            Positioned(
                              top: -15,
                              right: -10,
                              child: Icon(
                                Icons.science,
                                size: 80,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            // Animated element
                            Positioned(
                              bottom: -5,
                              left: 20,
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(seconds: 2),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: value * 0.1 * 3.14,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.school,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Flashcard icon with animation
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Front of card
                                        TweenAnimationBuilder(
                                          tween:
                                              Tween<double>(begin: 0, end: 1),
                                          duration: const Duration(seconds: 3),
                                          curve: Curves.easeInOutBack,
                                          builder: (context, value, child) {
                                            return Transform(
                                              alignment: Alignment.center,
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.001)
                                                ..rotateY(value * 6.28),
                                              child: const Icon(
                                                Icons.flip,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Text content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Study with Flashcards',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Master elements the fun way!',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Arrow indicator
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recommended topics carousel
                  const RecommendedTopicsWidget(),

                  // Categories header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Browse by Category',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Categories
                  ...List.generate(
                    _categories.length,
                    (index) => AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: _buildCategoryCard(
                              context, _categories[index], provider),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Update the category colors based on the theme
  Color _getCategoryColor(BuildContext context, GuideCategory category) {
    final theme = Theme.of(context);

    // Map existing colors to theme-based colors
    switch (category.title) {
      case 'Fundamentals':
        return theme.colorScheme.primary;
      case 'Matter & Solutions':
        return theme.colorScheme.secondary;
      case 'Reactions':
        return const Color(0xFFE67700); // Muted orange
      case 'Energy & Kinetics':
        return const Color(0xFFB82E2E); // Muted red
      case 'Organic Chemistry':
        return const Color(0xFF2E7D32); // Muted green
      default:
        return theme.colorScheme.tertiary;
    }
  }

  Widget _buildCategoryCard(BuildContext context, GuideCategory category,
      ChemistryGuideProvider provider) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(context, category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: categoryColor.withOpacity(0.05),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon,
                color: categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
        children: [
          ...category.topics.map((topic) =>
              _buildTopicItem(context, topic, provider, categoryColor)),
        ],
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, GuideTopic topic,
      ChemistryGuideProvider provider, Color categoryColor) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.5,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: CircleAvatar(
          backgroundColor: categoryColor.withOpacity(0.1),
          radius: 18,
          child: Icon(
            topic.icon,
            color: categoryColor,
            size: 16,
          ),
        ),
        title: Text(
          topic.title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          topic.description,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Results for "$query"',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0.5,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
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
                color: theme.colorScheme.primary,
              ),
              onTap: () async {
                final provider =
                    Provider.of<ChemistryGuideProvider>(context, listen: false);

                // Only show loading dialog if topic is not cached
                bool showLoading = !provider.isTopicCached(result);

                if (showLoading) {
                  // Show loading indicator only if not cached
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: ChemistryLoadingWidget()),
                  );
                }

                try {
                  final topic = await provider.getArticleSummary(result);

                  if (showLoading && context.mounted) {
                    // Dismiss loading dialog if we showed it
                    Navigator.pop(context);
                  }

                  if (topic != null && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopicDetailScreen(
                          topic: topic,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (showLoading && context.mounted) {
                    // Dismiss loading dialog if we showed it
                    Navigator.pop(context);
                  }

                  if (context.mounted) {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error loading article: $e',
                          style: const TextStyle(fontSize: 13),
                        ),
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
