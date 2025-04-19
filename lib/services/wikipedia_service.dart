import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const String baseUrl = 'https://en.wikipedia.org/api/rest_v1';

  /// Fetches a summary of a Wikipedia article by title
  /// Returns a Map with title, extract, thumbnail URL, and page URL
  Future<Map<String, dynamic>> getArticleSummary(String title) async {
    // Encode the title to handle spaces and special characters
    final encodedTitle = Uri.encodeComponent(title);
    final url = '$baseUrl/page/summary/$encodedTitle';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Get additional content with separate call to get sections
      final sections = await _getArticleSections(title);

      return {
        'title': data['title'],
        'extract': data['extract'],
        'extractHtml': data['extract_html'],
        'thumbnailUrl': data['thumbnail']?['source'],
        'pageUrl': data['content_urls']?['desktop']?['page'],
        'description': data['description'],
        'categories': _extractCategoriesFromHtml(data['extract_html'] ?? ''),
        'sections': sections,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } else {
      throw Exception(
          'Failed to load Wikipedia article: ${response.statusCode}');
    }
  }

  /// Fetches article sections to get more detailed content
  Future<List<Map<String, dynamic>>> _getArticleSections(String title) async {
    final encodedTitle = Uri.encodeComponent(title);
    final url = '$baseUrl/page/segments/$encodedTitle';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> sections = [];

        // Process segments to extract sections with content
        if (data['segments'] != null && data['segments'] is List) {
          for (var segment in data['segments']) {
            if (segment['type'] == 'heading') {
              sections.add({
                'title': segment['content']?['html'] ?? 'Section',
                'level': segment['content']?['level'] ?? 2,
                'content': [],
              });
            } else if (segment['type'] == 'paragraph' && sections.isNotEmpty) {
              // Add content to the most recent section
              sections.last['content'].add(segment['content']?['html'] ?? '');
            }
          }
        }

        return sections;
      } else {
        // If sections fail, return empty list but don't throw exception
        return [];
      }
    } catch (e) {
      // Silently fail for sections - we'll still have the summary
      return [];
    }
  }

  /// Searches for Wikipedia articles that match the query
  /// Returns a list of article titles, filtered for chemistry-related content
  Future<List<String>> searchArticles(String query,
      {int limit = 15, bool filterChemistry = true}) async {
    // Modify the query to focus on chemistry-related content if filter is enabled
    String searchQuery = query;
    if (filterChemistry && !_containsChemistryTerms(query)) {
      searchQuery = '$query chemistry';
    }

    final url =
        'https://en.wikipedia.org/w/api.php?action=opensearch&search=${Uri.encodeComponent(searchQuery)}&limit=$limit&namespace=0&format=json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The second item in the response contains the titles
      if (data is List && data.length > 1 && data[1] is List) {
        final titles = List<String>.from(data[1]);

        // Filter results for chemistry-related content if needed
        if (filterChemistry) {
          return _filterChemistryResults(titles, query);
        }
        return titles;
      }
      return [];
    } else {
      throw Exception('Failed to search Wikipedia: ${response.statusCode}');
    }
  }

  /// Gets related articles for a given chemistry topic
  Future<List<String>> getRelatedArticles(String topic) async {
    final List<String> chemistryKeywords = _getChemistryKeywords(topic);

    List<String> relatedArticles = [];

    // Try up to 3 related keywords to find related articles
    for (int i = 0; i < chemistryKeywords.length && i < 3; i++) {
      final results = await searchArticles(chemistryKeywords[i], limit: 5);

      // Add unique results to our list
      for (String result in results) {
        if (!relatedArticles.contains(result) && result != topic) {
          relatedArticles.add(result);
        }

        // Stop after collecting enough related articles
        if (relatedArticles.length >= 10) break;
      }

      if (relatedArticles.length >= 10) break;
    }

    return relatedArticles;
  }

  /// Gets images related to a chemistry topic
  Future<List<String>> getTopicImages(String topic) async {
    final encodedTitle = Uri.encodeComponent(topic);
    final url =
        'https://en.wikipedia.org/w/api.php?action=query&titles=$encodedTitle&prop=images&format=json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']?['pages'];
        if (pages != null) {
          final pageId = pages.keys.first;
          final images = pages[pageId]?['images'];

          if (images != null && images is List) {
            List<String> imageUrls = [];

            // Get first 5 images max
            for (int i = 0; i < images.length && i < 5; i++) {
              final imageName = images[i]['title'];
              if (imageName != null) {
                // Filter out non-image files and svg files (which might not display well)
                if (imageName.toLowerCase().contains('.jpg') ||
                    imageName.toLowerCase().contains('.png') ||
                    imageName.toLowerCase().contains('.jpeg')) {
                  // Get actual image URL
                  final imageUrl = await _getImageUrl(imageName);
                  if (imageUrl.isNotEmpty) {
                    imageUrls.add(imageUrl);
                  }
                }
              }
            }

            return imageUrls;
          }
        }
      }
      return [];
    } catch (e) {
      // Silently fail for images
      return [];
    }
  }

  /// Converts image name to actual URL
  Future<String> _getImageUrl(String imageName) async {
    final encodedName = Uri.encodeComponent(imageName.replaceAll('File:', ''));
    final url =
        'https://en.wikipedia.org/w/api.php?action=query&titles=Image:$encodedName&prop=imageinfo&iiprop=url&format=json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']?['pages'];
        if (pages != null) {
          final pageId = pages.keys.first;
          final imageInfo = pages[pageId]?['imageinfo'];

          if (imageInfo != null && imageInfo is List && imageInfo.isNotEmpty) {
            return imageInfo[0]['url'] ?? '';
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Extracts categories from HTML content
  List<String> _extractCategoriesFromHtml(String html) {
    // This is a simple extraction - in a real app you'd use a proper HTML parser
    final categoryPattern = RegExp(
        r'chemistry|chemical|element|compound|reaction|molecule|atom|bond|acid|base|organic|inorganic|gas|liquid|solid|periodic table',
        caseSensitive: false);

    final matches = categoryPattern.allMatches(html);
    final Set<String> categories = {};

    for (final match in matches) {
      categories.add(match.group(0)!.toLowerCase());
    }

    return categories.toList();
  }

  /// Checks if a query already contains chemistry-related terms
  bool _containsChemistryTerms(String query) {
    final chemistryTerms = [
      'chemistry',
      'chemical',
      'element',
      'compound',
      'reaction',
      'molecule',
      'atom',
      'bond',
      'acid',
      'base',
      'periodic',
      'organic',
      'inorganic',
      'gas',
      'liquid',
      'solid'
    ];

    query = query.toLowerCase();
    return chemistryTerms.any((term) => query.contains(term));
  }

  /// Filters search results to prioritize chemistry-related content
  List<String> _filterChemistryResults(
      List<String> titles, String originalQuery) {
    // Chemistry-related keywords for filtering
    final List<String> chemistryKeywords = [
      'chemistry',
      'chemical',
      'element',
      'compound',
      'reaction',
      'molecule',
      'atom',
      'bond',
      'acid',
      'base',
      'periodic table',
      'organic',
      'inorganic',
      'thermodynamics',
      'electrochemistry',
      'biochemistry',
      'analytical',
      'physical chemistry',
      'solution',
      'mixture',
      'concentration',
      'mole',
      'catalyst',
      'equilibrium',
      'redox',
      'isotope',
      'ion',
      'metal',
      'nonmetal'
    ];

    // Check titles for chemistry relevance
    final List<String> chemistryTitles = [];
    final List<String> otherTitles = [];

    for (final title in titles) {
      final String lowerTitle = title.toLowerCase();

      // Check if title contains chemistry keywords
      bool isChemistryRelated = chemistryKeywords.any((keyword) =>
          lowerTitle.contains(keyword) ||
          (lowerTitle.contains(originalQuery.toLowerCase()) &&
              _checkIfLikelyChemistryTopic(title)));

      if (isChemistryRelated) {
        chemistryTitles.add(title);
      } else {
        otherTitles.add(title);
      }
    }

    // Prioritize chemistry-related titles
    return [...chemistryTitles, ...otherTitles];
  }

  /// Determines if a title is likely a chemistry topic
  bool _checkIfLikelyChemistryTopic(String title) {
    // Exclude common non-chemistry categories
    final nonChemistryPatterns = [
      RegExp(
          r'(TV|television|series|movie|film|book|novel|game|show|episode|cartoon|character)',
          caseSensitive: false),
      RegExp(
          r'(band|musician|artist|singer|actor|actress|politician|athlete|band)',
          caseSensitive: false),
      RegExp(r'(company|corporation|business|product|software)',
          caseSensitive: false)
    ];

    for (final pattern in nonChemistryPatterns) {
      if (pattern.hasMatch(title)) {
        return false;
      }
    }

    return true;
  }

  /// Generate related chemistry keywords based on a topic
  List<String> _getChemistryKeywords(String topic) {
    final Map<String, List<String>> relatedKeywords = {
      'atom': ['atomic structure', 'nucleus', 'electron', 'proton', 'neutron'],
      'element': [
        'periodic table',
        'atomic number',
        'chemical element',
        'isotope'
      ],
      'bond': [
        'chemical bond',
        'covalent',
        'ionic',
        'metallic',
        'hydrogen bond'
      ],
      'reaction': [
        'chemical reaction',
        'redox',
        'equilibrium',
        'activation energy'
      ],
      'acid': ['base', 'pH', 'neutralization', 'acid-base reaction', 'buffer'],
      'organic': [
        'carbon compound',
        'hydrocarbon',
        'functional group',
        'organic chemistry'
      ],
      'period': [
        'periodic table',
        'group',
        'chemical properties',
        'atomic radius'
      ],
      'state': ['solid', 'liquid', 'gas', 'plasma', 'phase transition'],
      'solution': [
        'solvent',
        'solute',
        'concentration',
        'solubility',
        'mixture'
      ],
      'compound': ['chemical compound', 'molecule', 'formula', 'nomenclature'],
    };

    List<String> keywords = ['chemistry $topic'];

    // Look for matching keywords
    final lowerTopic = topic.toLowerCase();
    for (final entry in relatedKeywords.entries) {
      if (lowerTopic.contains(entry.key)) {
        keywords.addAll(entry.value);
      }
    }

    // Add default keywords if no specific matches
    if (keywords.length < 2) {
      keywords.addAll([
        'chemistry definition',
        'chemical properties',
        'chemistry reactions',
        'chemistry compounds'
      ]);
    }

    return keywords;
  }

  /// Gets examples related to a chemistry topic
  Future<List<Map<String, String>>> getTopicExamples(String topic) async {
    // First identify what kind of topic this is to find appropriate examples
    final String exampleType = _getExampleType(topic);
    final List<String> searchTerms = _getExampleSearchTerms(topic, exampleType);

    List<Map<String, String>> examples = [];

    // Try to find examples for up to 2 search terms
    for (int i = 0; i < searchTerms.length && i < 2; i++) {
      try {
        final term = searchTerms[i];
        final results = await searchArticles(term, limit: 3);

        for (String result in results) {
          // Get a brief summary for each example
          final summary = await _getBriefSummary(result);
          if (summary.isNotEmpty) {
            examples.add({
              'title': result,
              'description': summary,
              'type': exampleType,
            });
          }

          // Limit to 5 examples total
          if (examples.length >= 5) break;
        }

        if (examples.length >= 3) break; // Stop if we have enough examples
      } catch (e) {
        continue; // Continue with next search term if this one fails
      }
    }

    // If we found no examples with search, use pre-defined examples for common topics
    if (examples.isEmpty) {
      examples = _getPredefinedExamples(topic);
    }

    return examples;
  }

  /// Gets a brief summary (first sentence) for an article
  Future<String> _getBriefSummary(String title) async {
    try {
      final data = await getArticleSummary(title);
      final extract = data['extract'] as String? ?? '';

      // Try to get just the first sentence
      final firstSentenceMatch = RegExp(r'^(.+?\.)\s').firstMatch(extract);
      if (firstSentenceMatch != null) {
        return firstSentenceMatch.group(1) ?? '';
      }

      // If that fails, just return the first 100 characters
      return extract.length > 100 ? '${extract.substring(0, 100)}...' : extract;
    } catch (e) {
      return '';
    }
  }

  /// Determines what kind of examples to look for based on the topic
  String _getExampleType(String topic) {
    final lowerTopic = topic.toLowerCase();

    if (lowerTopic.contains('element') || lowerTopic.contains('periodic')) {
      return 'elements';
    } else if (lowerTopic.contains('bond')) {
      return 'bonds';
    } else if (lowerTopic.contains('reaction') ||
        lowerTopic.contains('synthesis')) {
      return 'reactions';
    } else if (lowerTopic.contains('acid') || lowerTopic.contains('base')) {
      return 'acids_bases';
    } else if (lowerTopic.contains('organic') ||
        lowerTopic.contains('carbon')) {
      return 'organic_compounds';
    } else if (lowerTopic.contains('solution') ||
        lowerTopic.contains('mixture')) {
      return 'solutions';
    } else if (lowerTopic.contains('nuclear') ||
        lowerTopic.contains('isotope')) {
      return 'nuclear';
    }

    return 'general';
  }

  /// Generates search terms to find examples for a topic
  List<String> _getExampleSearchTerms(String topic, String exampleType) {
    switch (exampleType) {
      case 'elements':
        return ['common elements examples', 'important chemical elements'];
      case 'bonds':
        return ['chemical bond examples', 'molecule bond examples'];
      case 'reactions':
        return [
          'common chemical reactions examples',
          'important chemical reactions'
        ];
      case 'acids_bases':
        return ['common acids and bases examples', 'important acids chemistry'];
      case 'organic_compounds':
        return ['common organic compounds', 'important organic molecules'];
      case 'solutions':
        return [
          'common chemical solutions examples',
          'important mixtures chemistry'
        ];
      case 'nuclear':
        return ['nuclear reaction examples', 'common isotopes examples'];
      default:
        return [
          '${topic.toLowerCase()} examples chemistry',
          'common ${topic.toLowerCase()} chemistry'
        ];
    }
  }

  /// Provides predefined examples for common chemistry topics
  List<Map<String, String>> _getPredefinedExamples(String topic) {
    final lowerTopic = topic.toLowerCase();

    // Elements examples
    if (lowerTopic.contains('element') || lowerTopic.contains('periodic')) {
      return [
        {
          'title': 'Hydrogen',
          'description':
              'The lightest element, with atomic number 1. It\'s the most abundant chemical substance in the universe.',
          'type': 'elements'
        },
        {
          'title': 'Oxygen',
          'description':
              'Element with atomic number 8, vital for most living organisms through respiration.',
          'type': 'elements'
        },
        {
          'title': 'Carbon',
          'description':
              'Element with atomic number 6, the chemical basis of all known life.',
          'type': 'elements'
        },
      ];
    }

    // Chemical bonds examples
    if (lowerTopic.contains('bond')) {
      return [
        {
          'title': 'Ionic Bond',
          'description':
              'A type of chemical bond formed through electrostatic attraction, like in sodium chloride (NaCl).',
          'type': 'bonds'
        },
        {
          'title': 'Covalent Bond',
          'description':
              'Bond formed when atoms share electron pairs, as in the oxygen molecule (O₂).',
          'type': 'bonds'
        },
        {
          'title': 'Hydrogen Bond',
          'description':
              'Electrostatic attraction between hydrogen and electronegative atoms, crucial in water and DNA.',
          'type': 'bonds'
        },
      ];
    }

    // Reactions examples
    if (lowerTopic.contains('reaction') || lowerTopic.contains('equation')) {
      return [
        {
          'title': 'Combustion',
          'description':
              'A reaction where a substance reacts with oxygen to produce heat and light, as in burning methane.',
          'type': 'reactions'
        },
        {
          'title': 'Neutralization',
          'description':
              'Reaction between an acid and a base producing salt and water, like HCl + NaOH → NaCl + H₂O.',
          'type': 'reactions'
        },
        {
          'title': 'Fermentation',
          'description':
              'Conversion of sugar to alcohol and carbon dioxide through yeast enzymes in brewing and baking.',
          'type': 'reactions'
        },
      ];
    }

    // Acids and bases examples
    if (lowerTopic.contains('acid') || lowerTopic.contains('base')) {
      return [
        {
          'title': 'Hydrochloric acid',
          'description': 'Strong acid found in gastric acid with formula HCl.',
          'type': 'acids_bases'
        },
        {
          'title': 'Sodium hydroxide',
          'description': 'Strong base used in soap making with formula NaOH.',
          'type': 'acids_bases'
        },
        {
          'title': 'Acetic acid',
          'description':
              'Weak acid that gives vinegar its sour taste, with formula CH₃COOH.',
          'type': 'acids_bases'
        },
      ];
    }

    // Organic chemistry examples
    if (lowerTopic.contains('organic')) {
      return [
        {
          'title': 'Methane',
          'description':
              'Simplest hydrocarbon with formula CH₄, the primary component of natural gas.',
          'type': 'organic_compounds'
        },
        {
          'title': 'Glucose',
          'description':
              'Simple sugar with formula C₆H₁₂O₆, a key energy source for living organisms.',
          'type': 'organic_compounds'
        },
        {
          'title': 'Ethanol',
          'description':
              'Alcohol found in alcoholic beverages with formula C₂H₅OH.',
          'type': 'organic_compounds'
        },
      ];
    }

    // Nuclear chemistry examples
    if (lowerTopic.contains('nuclear')) {
      return [
        {
          'title': 'Carbon-14 dating',
          'description':
              'Method using radioactive decay of carbon-14 to determine the age of organic materials.',
          'type': 'nuclear'
        },
        {
          'title': 'Nuclear fission',
          'description':
              'Process where atomic nucleus splits into lighter nuclei, releasing energy.',
          'type': 'nuclear'
        },
        {
          'title': 'Uranium-235',
          'description':
              'Isotope used in nuclear reactors and weapons due to its fissile properties.',
          'type': 'nuclear'
        },
      ];
    }

    // Default examples for other topics
    return [
      {
        'title': 'Example 1',
        'description':
            'A common application of ${topic.toLowerCase()} in chemistry.',
        'type': 'general'
      },
      {
        'title': 'Example 2',
        'description':
            'Another important example related to ${topic.toLowerCase()}.',
        'type': 'general'
      },
    ];
  }
}
