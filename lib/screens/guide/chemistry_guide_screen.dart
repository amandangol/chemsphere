import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../chemistryguide/provider/chemistry_guide_provider.dart';
import 'model/chemistry_guide.dart';
import '../chemistryguide/widgets/topic_search_screen.dart';
import '../chemistryguide/widgets/topic_detail_screen.dart';

class ChemistryGuideScreen extends StatefulWidget {
  const ChemistryGuideScreen({Key? key}) : super(key: key);

  @override
  State<ChemistryGuideScreen> createState() => _ChemistryGuideScreenState();
}

class _ChemistryGuideScreenState extends State<ChemistryGuideScreen> {
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
              ElementsTopicScreen(title: 'Atoms and Elements'),
        ),
        GuideTopic(
          title: 'Periodic Table',
          description: 'Organization and trends of elements',
          icon: Icons.grid_on,
          screenBuilder: (context) =>
              ElementsTopicScreen(title: 'Periodic Table'),
        ),
        GuideTopic(
          title: 'Chemical Bonds',
          description: 'How atoms connect to form molecules',
          icon: Icons.link,
          screenBuilder: (context) => TopicDetailScreen(
              topic: ChemistryTopic(
            id: 'chemical_bonds',
            title: 'Chemical Bonds',
            description: 'How atoms connect to form molecules',
            content:
                'Chemical bonds are the forces that hold atoms together to form compounds.',
            headingKey: 'Chemical Bonds',
          )),
        ),
      ],
    ),
    GuideCategory(
      title: 'Matter & Solutions',
      icon: Icons.opacity,
      color: Colors.purple,
      topics: [
        GuideTopic(
          title: 'States of Matter',
          description: 'Solids, liquids, gases, and phase transitions',
          icon: Icons.change_history,
          screenBuilder: (context) => TopicDetailScreen(
              topic: ChemistryTopic(
            id: 'states_of_matter',
            title: 'States of Matter',
            description: 'Solids, liquids, gases, and phase transitions',
            content:
                'Matter exists in different states depending on temperature and pressure.',
            headingKey: 'States of Matter',
          )),
        ),
        GuideTopic(
          title: 'Solutions & Mixtures',
          description: 'How substances dissolve and mix',
          icon: Icons.bubble_chart,
        ),
        GuideTopic(
          title: 'Concentration',
          description: 'Measuring amounts in solutions',
          icon: Icons.science,
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
        ),
        GuideTopic(
          title: 'Reaction Types',
          description: 'Categories of chemical reactions',
          icon: Icons.category,
        ),
        GuideTopic(
          title: 'Equilibrium',
          description: 'When reactions reach balance',
          icon: Icons.balance,
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
        ),
        GuideTopic(
          title: 'Reaction Rates',
          description: 'How fast reactions occur',
          icon: Icons.speed,
        ),
        GuideTopic(
          title: 'Catalysts',
          description: 'Substances that speed up reactions',
          icon: Icons.fast_forward,
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
        ),
        GuideTopic(
          title: 'Functional Groups',
          description: 'Important molecular structures',
          icon: Icons.category,
        ),
        GuideTopic(
          title: 'Organic Reactions',
          description: 'How organic molecules transform',
          icon: Icons.transform,
        ),
      ],
    ),
    GuideCategory(
      title: 'Biochemical Pathways',
      icon: Icons.route,
      color: Colors.amber,
      topics: [
        GuideTopic(
          title: 'Metabolic Pathways',
          description: 'Chemical processes in living organisms',
          icon: Icons.account_tree,
          isPathway: true,
        ),
        GuideTopic(
          title: 'Enzymatic Reactions',
          description: 'Protein catalysts in biochemistry',
          icon: Icons.biotech,
          isPathway: true,
        ),
        GuideTopic(
          title: 'Cell Signaling',
          description: 'Chemical communication within cells',
          icon: Icons.swap_calls,
          isPathway: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chemistry Guide'),
        centerTitle: true,
      ),
      body:
          Consumer<ChemistryGuideProvider>(builder: (context, provider, child) {
        return AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context, provider),
              const SizedBox(height: 24),
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
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, ChemistryGuideProvider provider) {
    final isElementsLoaded =
        provider.elementsState == ChemistryGuideLoadingState.loaded;
    final elementsCount = provider.elements.length;
    final categoriesCount = provider.elementCategories.length;
    final pathwaysCount = provider.pathways.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                size: 32,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Chemistry Guide',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explore fundamental chemistry concepts through our comprehensive guides and tutorials.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                context,
                isElementsLoaded ? elementsCount.toString() : '...',
                'Elements',
                Icons.category,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                isElementsLoaded ? categoriesCount.toString() : '...',
                'Categories',
                Icons.topic,
              ),
              const SizedBox(width: 8),
              _buildStatCard(
                context,
                isElementsLoaded ? pathwaysCount.toString() : '0',
                'Pathways',
                Icons.route,
              ),
            ],
          ),

          // Loading indicator or error message if applicable
          if (provider.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading data from PubChem...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error: ${provider.error}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade300,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, GuideCategory category,
      ChemistryGuideProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
          ...category.topics
              .map((topic) => _buildTopicItem(context, topic, provider)),
        ],
      ),
    );
  }

  Widget _buildTopicItem(
      BuildContext context, GuideTopic topic, ChemistryGuideProvider provider) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Icon(
        topic.icon,
        color: Theme.of(context).colorScheme.primary,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      trailing: topic.isPathway
          ? const Chip(
              label: Text('Pathway'),
              backgroundColor: Colors.amber,
              labelStyle: TextStyle(fontSize: 10, color: Colors.black),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () {
        if (topic.screenBuilder != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => topic.screenBuilder!(context),
            ),
          );
        } else if (topic.isPathway) {
          // If this is a pathway topic
          final availablePathways = provider.pathways;
          if (availablePathways.isNotEmpty) {
            // Just use the first pathway as an example
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PathwayDetailScreen(
                  pathway: availablePathways.first,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Pathway data is still loading. Please try again later.'),
              ),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicDetailScreen(
                  topic: ChemistryTopic(
                id: topic.title.toLowerCase().replaceAll(' ', '_'),
                title: topic.title,
                description: topic.description,
                content: 'Content for ${topic.title} is being developed.',
                headingKey: topic.title,
              )),
            ),
          );
        }
      },
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

class PathwayDetailScreen extends StatelessWidget {
  final ChemistryPathway pathway;

  const PathwayDetailScreen({
    Key? key,
    required this.pathway,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pathway.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pathway header with source
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pathway.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Source: ${pathway.source}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pathway.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pathway diagram if available
            if (pathway.diagramUrl != null) ...[
              Text(
                'Pathway Diagram',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pathway.diagramUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Diagram not available',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Related compounds
            Text(
              'Related Compounds',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            pathway.relatedCompoundCids.isEmpty
                ? Text(
                    'No related compounds found',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pathway.relatedCompoundCids.length,
                    itemBuilder: (context, index) {
                      final cid = pathway.relatedCompoundCids[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Image.network(
                            'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          title: Text('Compound CID: $cid'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to compound details when implemented
                          },
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 24),

            // External link button if available
            if (pathway.externalUrl != null)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: Text('View in ${pathway.source}'),
                  onPressed: () {
                    // Open external URL in browser
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${pathway.externalUrl}'),
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
}
