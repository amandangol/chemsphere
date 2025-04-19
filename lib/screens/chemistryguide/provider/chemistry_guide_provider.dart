import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/chemistry_guide.dart';
import '../../../services/wikipedia_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChemistryGuideProvider with ChangeNotifier {
  final WikipediaService _wikipediaService = WikipediaService();

  // Topics and search state
  List<ChemistryTopic> _topics = [];
  List<ChemistryTopic> get topics => _topics;

  // Favorite topics
  List<ChemistryTopic> get favoriteTopics =>
      _topics.where((topic) => topic.isFavorite).toList();

  // Element categories and pathways
  List<String> _elementCategories = [];
  List<String> get elementCategories => _elementCategories;

  List<ChemistryPathway> _pathways = [];
  List<ChemistryPathway> get pathways => _pathways;

  // Elements data
  List<ChemistryElement> _elements = [];
  List<ChemistryElement> get elements => _elements;

  // Search results
  List<String> _searchResults = [];
  List<String> get searchResults => _searchResults;

  // Topic cache to avoid redundant fetches
  final Map<String, ChemistryTopic> _topicCache = {};

  ChemistryTopic? _selectedTopic;
  ChemistryTopic? get selectedTopic => _selectedTopic;

  // Loading state
  ChemistryGuideLoadingState _loadingState = ChemistryGuideLoadingState.initial;
  ChemistryGuideLoadingState get loadingState => _loadingState;

  bool get isLoading => _loadingState == ChemistryGuideLoadingState.loading;
  String? _error;
  String? get error => _error;

  // Initialize with persistent cache
  Future<void> initialize() async {
    _setLoading();

    // Load cached data if available
    await _loadCachedData();

    // Set default data if nothing was cached
    if (_elementCategories.isEmpty) {
      _elementCategories = [
        'Metals',
        'Nonmetals',
        'Metalloids',
        'Noble Gases',
        'Halogens',
        'Transition Metals'
      ];
    }

    // Add sample pathways if none were cached
    if (_pathways.isEmpty) {
      _pathways = [
        ChemistryPathway(
          id: 'photosynthesis',
          name: 'Photosynthesis',
          description:
              'The process used by plants to convert light energy into chemical energy.',
          source: 'Wikipedia',
          relatedCompoundCids: [5460162, 5462222], // CO2, O2
        ),
        ChemistryPathway(
          id: 'krebs_cycle',
          name: 'Krebs Cycle',
          description:
              'A series of chemical reactions used by aerobic organisms to release energy.',
          source: 'Wikipedia',
          relatedCompoundCids: [643757, 439153], // ATP, Acetyl-CoA
        ),
      ];
    }

    _setLoaded();
  }

  // Load cached data from SharedPreferences
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cached topics
      final cachedTopicsJson = prefs.getString('cached_topics');
      if (cachedTopicsJson != null) {
        final List<dynamic> topicsData = jsonDecode(cachedTopicsJson);
        _topics =
            topicsData.map((json) => ChemistryTopic.fromJson(json)).toList();

        // Also rebuild the cache map
        for (final topic in _topics) {
          _topicCache[topic.id.toLowerCase()] = topic;
        }
      }

      // Load cached pathways
      final cachedPathwaysJson = prefs.getString('cached_pathways');
      if (cachedPathwaysJson != null) {
        final List<dynamic> pathwaysData = jsonDecode(cachedPathwaysJson);
        _pathways = pathwaysData
            .map((json) => ChemistryPathway.fromJson(json))
            .toList();
      }

      // Load cached element categories
      final cachedCategories = prefs.getStringList('element_categories');
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        _elementCategories = cachedCategories;
      }

      // Load favorite topics
      final favorites = prefs.getStringList('favorite_topics');
      if (favorites != null && favorites.isNotEmpty) {
        // Update favorite status in cached topics
        for (var topicId in favorites) {
          final topicIndex = _topics.indexWhere((t) => t.id == topicId);
          if (topicIndex >= 0) {
            _topics[topicIndex] =
                _topics[topicIndex].copyWith(isFavorite: true);
            // Update cache
            _topicCache[_topics[topicIndex].id.toLowerCase()] =
                _topics[topicIndex];
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
      // Continue with default data if cache loading fails
    }
  }

  // Save data to cache
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cache topics
      if (_topics.isNotEmpty) {
        final topicsJson = jsonEncode(_topics.map((t) => t.toJson()).toList());
        await prefs.setString('cached_topics', topicsJson);
      }

      // Cache pathways
      if (_pathways.isNotEmpty) {
        final pathwaysJson =
            jsonEncode(_pathways.map((p) => p.toJson()).toList());
        await prefs.setString('cached_pathways', pathwaysJson);
      }

      // Cache element categories
      if (_elementCategories.isNotEmpty) {
        await prefs.setStringList('element_categories', _elementCategories);
      }

      // Cache favorite topics
      final favorites =
          _topics.where((t) => t.isFavorite).map((t) => t.id).toList();
      await prefs.setStringList('favorite_topics', favorites);
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  // Method to search Wikipedia articles
  Future<void> searchWikipediaArticles(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _setLoading();
      _searchResults = await _wikipediaService.searchArticles(query);
      _setLoaded();
    } catch (e) {
      _setError('Failed to search Wikipedia: $e');
    }
  }

  // Method to get a detailed article summary
  Future<ChemistryTopic?> getArticleSummary(String title) async {
    // Check if we already have this topic cached
    final cacheKey = title.toLowerCase();
    final bool wasCached = _topicCache.containsKey(cacheKey);
    final bool wasFavorite =
        wasCached ? _topicCache[cacheKey]!.isFavorite : false;

    try {
      _setLoading();

      // Get basic article summary
      final data = await _wikipediaService.getArticleSummary(title);

      // Also fetch related images
      List<String> relatedImages =
          await _wikipediaService.getTopicImages(title);

      // Get examples related to this topic
      final examplesData = await _wikipediaService.getTopicExamples(title);
      final List<TopicExample> examples = examplesData
          .map((e) => TopicExample(
                title: e['title'] ?? '',
                description: e['description'] ?? '',
                type: e['type'] ?? 'general',
              ))
          .toList();

      // Convert sections from API to our model
      List<TopicSection> sections = [];
      if (data['sections'] != null && data['sections'] is List) {
        for (var sectionData in data['sections']) {
          sections.add(TopicSection(
            title: _cleanHtmlContent(sectionData['title'] ?? ''),
            level: sectionData['level'] ?? 2,
            content: (sectionData['content'] as List<dynamic>)
                .map((c) => _cleanHtmlContent(c.toString()))
                .toList(),
          ));
        }
      }

      final topic = ChemistryTopic(
        id: title.toLowerCase().replaceAll(' ', '_'),
        title: data['title'] ?? title,
        description: data['extract'] ?? '',
        content: data['extractHtml'] ?? data['extract'] ?? '',
        headingKey: title,
        wikipediaUrl: data['pageUrl'],
        thumbnailUrl: data['thumbnailUrl'],
        categories: data['categories'] ?? [],
        lastUpdated: DateTime.now(),
        sections: sections,
        relatedImages: relatedImages,
        examples: examples,
        // Preserve favorite status if this topic was already cached
        isFavorite: wasFavorite,
      );

      // Cache the topic for future use
      _topicCache[cacheKey] = topic;
      _selectedTopic = topic;

      // Add to topics list if not already there
      if (!_topics.any((t) => t.id == topic.id)) {
        _topics.add(topic);
      } else {
        // Update the existing topic in the list
        final existingIndex = _topics.indexWhere((t) => t.id == topic.id);
        if (existingIndex >= 0) {
          _topics[existingIndex] = topic;
        }
      }

      // Save to persistent cache whenever we update a topic
      _saveToCache();

      _setLoaded();
      return topic;
    } catch (e) {
      _setError('Failed to load article: $e');
      return null;
    }
  }

  // Toggle favorite status for a topic
  Future<void> toggleFavorite(String topicId) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index >= 0) {
      // Use original topic data to ensure we don't lose any fields
      final originalTopic = _topics[index];

      // Create a copy with just the favorite status updated
      final updatedTopic = originalTopic.copyWith(
        isFavorite: !originalTopic.isFavorite,
      );

      // Update the topic in the list
      _topics[index] = updatedTopic;

      // Update the cache
      _topicCache[updatedTopic.id.toLowerCase()] = updatedTopic;

      // If this is the selected topic, update that too
      if (_selectedTopic?.id == topicId) {
        _selectedTopic = updatedTopic;
      }

      // Save changes to persistent storage
      _saveToCache();

      notifyListeners();
    }
  }

  // Get related topics for a given topic
  Future<List<String>> getRelatedTopics(String topicName) async {
    try {
      _setLoading();
      final relatedTopics =
          await _wikipediaService.getRelatedArticles(topicName);
      _setLoaded();
      return relatedTopics;
    } catch (e) {
      _setError('Failed to load related topics: $e');
      return [];
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clean HTML content
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

  // Set state to loading
  void _setLoading() {
    _loadingState = ChemistryGuideLoadingState.loading;
    _error = null;
    notifyListeners();
  }

  // Set state to loaded
  void _setLoaded() {
    _loadingState = ChemistryGuideLoadingState.loaded;
    notifyListeners();
  }

  // Set error state with message
  void _setError(String errorMessage) {
    _loadingState = ChemistryGuideLoadingState.error;
    _error = errorMessage;
    debugPrint('Chemistry Guide Error: $errorMessage');
    notifyListeners();
  }
}
