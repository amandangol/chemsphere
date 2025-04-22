import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class WikipediaService {
  /// Searches for Wikipedia articles that match the query
  /// Returns a list of article titles, filtered for chemistry-related content
  Future<List<String>> searchArticles(String query,
      {int limit = 15, bool filterChemistry = true}) async {
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

  /// Returns a Map with title, extract, thumbnail URL, and page URL
  Future<Map<String, dynamic>> getArticleSummary(String title) async {
    // Encode the title to handle spaces and special characters
    final encodedTitle = Uri.encodeComponent(title);
    final url = '${ApiConfig.wikipediaApiUrl}/page/summary/$encodedTitle';

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

  /// Gets the sections of an article
  Future<List<Map<String, dynamic>>> _getArticleSections(String title) async {
    final encodedTitle = Uri.encodeComponent(title);
    final url =
        '${ApiConfig.wikipediaApiUrl}/page/mobile-sections/$encodedTitle';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> sections = [];

        // Extract sections from the remaining content (after lead)
        if (data['remaining']?['sections'] != null) {
          for (var section in data['remaining']['sections']) {
            // Only include sections up to level 3 for readability
            if ((section['toclevel'] ?? 0) <= 3) {
              sections.add({
                'title': section['line'] ?? '',
                'level': section['toclevel'] ?? 2,
                'content': _extractSectionText(section),
              });
            }
          }
        }

        return sections;
      }
      return [];
    } catch (e) {
      print('Error getting article sections: $e');
      return [];
    }
  }

  /// Extract text from a section and its subsections
  List<String> _extractSectionText(Map<String, dynamic> section) {
    List<String> content = [];

    if (section['text'] != null) {
      content.add(_cleanHtml(section['text']));
    }

    // Process subsections recursively
    if (section['subsections'] != null) {
      for (var subsection in section['subsections']) {
        if (subsection['text'] != null) {
          content.add(_cleanHtml(subsection['text']));
        }
      }
    }

    return content;
  }

  /// Gets related articles for a given chemistry topic
  Future<List<String>> getRelatedArticles(String topic) async {
    final encodedTitle = Uri.encodeComponent(topic);
    final url = '${ApiConfig.wikipediaApiUrl}/page/related/$encodedTitle';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['pages'] != null) {
          // Extract titles from related pages
          return List<String>.from(
              data['pages'].map((page) => page['title'] as String));
        }
      }

      // If the above fails, fall back to keyword-based approach
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
    } catch (e) {
      print('Error getting related articles: $e');
      return [];
    }
  }

  /// Gets images related to a chemistry topic
  Future<List<String>> getTopicImages(String topic) async {
    final encodedTitle = Uri.encodeComponent(topic);
    final url = '${ApiConfig.wikipediaApiUrl}/page/media-list/$encodedTitle';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          // Filter for image types - make sure the test function returns a boolean
          final List<dynamic> allItems = data['items'];
          final List<dynamic> images = allItems.where((dynamic item) {
            final mime = item['mime'] ?? '';
            return mime.toString().startsWith('image/');
          }).toList();

          // Extract image URLs
          final List<String> imageUrls = [];
          for (var item in images) {
            if (item['srcset'] != null && (item['srcset'] as List).isNotEmpty) {
              // Get the smallest image from srcset for thumbnails
              imageUrls.add(item['srcset'][0]['src']);
            } else if (item['src'] != null) {
              imageUrls.add(item['src']);
            }
          }

          return imageUrls;
        }
      }

      // Fall back to older API if the above fails
      return await _getImagesLegacy(topic);
    } catch (e) {
      print('Error getting topic images: $e');
      return [];
    }
  }

  /// Legacy method to get images using the old API
  Future<List<String>> _getImagesLegacy(String topic) async {
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

  /// Gets examples related to a chemistry topic
  Future<List<Map<String, dynamic>>> getTopicExamples(String topic) async {
    // Identify what kind of topic this is to find appropriate examples
    final String exampleType = _getExampleType(topic);

    // For some topics, we can provide curated examples
    if (_hasPredefinedExamples(exampleType)) {
      return _getPredefinedExamples(topic);
    }

    // Otherwise, search for relevant examples
    final List<String> searchTerms = _getExampleSearchTerms(topic, exampleType);
    List<Map<String, dynamic>> examples = [];

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

    return examples;
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

  /// Check if the topic has predefined examples
  bool _hasPredefinedExamples(String exampleType) {
    return [
      'elements',
      'bonds',
      'reactions',
      'acids_bases',
      'organic_compounds',
      'nuclear'
    ].contains(exampleType);
  }

  /// Extract categories from HTML content
  List<String> _extractCategoriesFromHtml(String html) {
    // Simple extraction based on common category formats
    final categoryRegex = RegExp(r'Category:([A-Za-z0-9_\s]+)');
    final matches = categoryRegex.allMatches(html);

    return matches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((cat) => cat.isNotEmpty)
        .toList();
  }

  /// Clean HTML content
  String _cleanHtml(String html) {
    // Remove HTML tags
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  /// Check if a query contains chemistry terms
  bool _containsChemistryTerms(String query) {
    final chemistryTerms = [
      'element',
      'compound',
      'acid',
      'base',
      'metal',
      'reaction',
      'molecule',
      'isotope',
      'bond',
      'electron',
      'proton',
      'neutron',
      'atom',
      'periodic',
      'chemical',
      'formula',
      'organic',
      'inorganic',
      'solution',
      'gas',
      'liquid',
      'solid'
    ];

    final lowerQuery = query.toLowerCase();
    return chemistryTerms.any((term) => lowerQuery.contains(term));
  }

  /// Filter results to prioritize chemistry-related content
  List<String> _filterChemistryResults(List<String> titles, String query) {
    final lowerQuery = query.toLowerCase();
    final priorityTerms = [
      'chemistry',
      'element',
      'compound',
      'acid',
      'base',
      'reaction',
      'metal',
      'molecule'
    ];

    // Check if query already has a chemistry context
    bool hasChemistryContext =
        priorityTerms.any((term) => lowerQuery.contains(term));

    if (hasChemistryContext) {
      // If query has chemistry context, return results as is (up to 10)
      return titles.take(10).toList();
    } else {
      // Otherwise, prioritize results with chemistry keywords
      var prioritized = titles.where((title) {
        final lowerTitle = title.toLowerCase();
        return priorityTerms.any((term) => lowerTitle.contains(term));
      }).toList();

      // If we don't have enough chemistry-related results, add others
      if (prioritized.length < 5 && titles.isNotEmpty) {
        final remaining =
            titles.where((title) => !prioritized.contains(title)).toList();
        prioritized.addAll(remaining.take(10 - prioritized.length));
      }

      return prioritized.take(10).toList();
    }
  }

  /// Get related chemistry keywords based on a topic
  List<String> _getChemistryKeywords(String topic) {
    final lowerTopic = topic.toLowerCase();
    List<String> keywords = [];

    // Add the topic itself
    keywords.add(topic);

    // Add related keywords based on what type of topic it is
    if (lowerTopic.contains('element') || lowerTopic.contains('atom')) {
      keywords.addAll([
        'periodic table elements',
        'chemical elements',
        'element properties'
      ]);
    } else if (lowerTopic.contains('acid') || lowerTopic.contains('base')) {
      keywords.addAll(['acids and bases', 'pH scale', 'acid base reactions']);
    } else if (lowerTopic.contains('bond')) {
      keywords.addAll(['chemical bonding', 'molecular bonds', 'ionic bonds']);
    } else if (lowerTopic.contains('react')) {
      keywords.addAll(
          ['chemical reactions', 'reaction types', 'reaction mechanisms']);
    } else if (lowerTopic.contains('organic')) {
      keywords.addAll(
          ['organic chemistry', 'organic compounds', 'carbon compounds']);
    } else if (lowerTopic.contains('solution')) {
      keywords
          .addAll(['chemical solutions', 'solubility', 'solvent properties']);
    } else {
      // Generic chemistry keywords
      keywords.addAll([
        'chemistry $topic',
        '$topic chemical properties',
        '$topic chemistry'
      ]);
    }

    return keywords;
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
  List<Map<String, dynamic>> _getPredefinedExamples(String topic) {
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
