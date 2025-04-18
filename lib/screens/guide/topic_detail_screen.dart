import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chemistry_guide.dart';

class TopicDetailScreen extends StatelessWidget {
  final ChemistryTopic topic;

  const TopicDetailScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForTopic(topic.title),
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          topic.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Topic content
            if (topic.content.isNotEmpty) ...[
              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topic.content,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Display subtopics if available
            if (topic.subtopics != null && topic.subtopics!.isNotEmpty) ...[
              Text(
                'Related Concepts',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...topic.subtopics!
                  .map((subtopic) => _buildSubtopicCard(context, subtopic)),
            ],

            // If no content or subtopics available
            if (topic.content.isEmpty &&
                (topic.subtopics == null || topic.subtopics!.isEmpty))
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.construction,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'re currently developing detailed content for this topic.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

            // Related elements or compounds
            if (topic.relatedElementIds.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Related Elements',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topic.relatedElementIds.length,
                  itemBuilder: (context, index) {
                    final elementId = topic.relatedElementIds[index];
                    return Card(
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          // Navigate to element details
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                elementId,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'View Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubtopicCard(
      BuildContext context, ChemistryTopicContent subtopic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Show more details about the subtopic
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        subtopic.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        subtopic.content,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                      if (subtopic.imageUrls != null &&
                          subtopic.imageUrls!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Images',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: subtopic.imageUrls!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    subtopic.imageUrls![index],
                                    height: 200,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 200,
                                      width: 200,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (subtopic.references != null &&
                          subtopic.references!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'References',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...subtopic.references!.map((ref) => ListTile(
                              leading: const Icon(Icons.article),
                              title: Text(ref['SourceName'] ?? 'Source'),
                              subtitle: Text(ref['Description'] ?? ''),
                              dense: true,
                            )),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtopic.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtopic.content.length > 120
                    ? '${subtopic.content.substring(0, 120)}...'
                    : subtopic.content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Learn more',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTopic(String topicTitle) {
    // Map topics to appropriate icons
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
      'pH Scale': Icons.show_chart,
      'Neutralization': Icons.balance,
      'Buffers': Icons.shield,
    };

    return topicIcons[topicTitle] ?? Icons.science;
  }
}
