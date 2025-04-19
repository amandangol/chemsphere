/// Represents a chemistry topic with content from Wikipedia or other sources
class ChemistryTopic {
  final String id;
  final String title;
  final String description;
  final String content;
  final String headingKey;
  final String? wikipediaUrl;
  final String? thumbnailUrl;
  final List<String> categories;
  final DateTime? lastUpdated;
  final List<TopicSection> sections;
  final List<String> relatedImages;
  final List<TopicExample> examples;
  final bool isFavorite;

  ChemistryTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.headingKey,
    this.wikipediaUrl,
    this.thumbnailUrl,
    this.categories = const [],
    this.lastUpdated,
    this.sections = const [],
    this.relatedImages = const [],
    this.examples = const [],
    this.isFavorite = false,
  });

  /// Creates a topic from JSON data
  factory ChemistryTopic.fromJson(Map<String, dynamic> json) {
    return ChemistryTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      headingKey: json['headingKey'] ?? '',
      wikipediaUrl: json['wikipediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      sections: json['sections'] != null
          ? List<TopicSection>.from(
              json['sections'].map((x) => TopicSection.fromJson(x)))
          : [],
      relatedImages: json['relatedImages'] != null
          ? List<String>.from(json['relatedImages'])
          : [],
      examples: json['examples'] != null
          ? List<TopicExample>.from(
              json['examples'].map((x) => TopicExample.fromJson(x)))
          : [],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// Converts topic to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'headingKey': headingKey,
      'wikipediaUrl': wikipediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'categories': categories,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'sections': sections.map((x) => x.toJson()).toList(),
      'relatedImages': relatedImages,
      'examples': examples.map((x) => x.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  /// Creates a copy of this topic with updated fields
  ChemistryTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? headingKey,
    String? wikipediaUrl,
    String? thumbnailUrl,
    List<String>? categories,
    DateTime? lastUpdated,
    List<TopicSection>? sections,
    List<String>? relatedImages,
    List<TopicExample>? examples,
    bool? isFavorite,
  }) {
    return ChemistryTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      headingKey: headingKey ?? this.headingKey,
      wikipediaUrl: wikipediaUrl ?? this.wikipediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categories: categories ?? this.categories,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sections: sections ?? this.sections,
      relatedImages: relatedImages ?? this.relatedImages,
      examples: examples ?? this.examples,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Represents a section of a chemistry topic with title and content
class TopicSection {
  final String title;
  final int level;
  final List<String> content;

  TopicSection({
    required this.title,
    required this.level,
    required this.content,
  });

  factory TopicSection.fromJson(Map<String, dynamic> json) {
    return TopicSection(
      title: json['title'] ?? '',
      level: json['level'] ?? 2,
      content:
          json['content'] != null ? List<String>.from(json['content']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'level': level,
      'content': content,
    };
  }
}

/// Represents an example related to a chemistry topic
class TopicExample {
  final String title;
  final String description;
  final String type;

  TopicExample({
    required this.title,
    required this.description,
    required this.type,
  });

  factory TopicExample.fromJson(Map<String, dynamic> json) {
    return TopicExample(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
    };
  }
}

/// Represents a chemical pathway or process
class ChemistryPathway {
  final String id;
  final String name;
  final String description;
  final String source;
  final String? diagramUrl;
  final String? externalUrl;
  final List<int> relatedCompoundCids;
  final Map<String, dynamic>? additionalData;

  ChemistryPathway({
    required this.id,
    required this.name,
    required this.description,
    required this.source,
    this.diagramUrl,
    this.externalUrl,
    this.relatedCompoundCids = const [],
    this.additionalData,
  });

  /// Creates a pathway from JSON data
  factory ChemistryPathway.fromJson(Map<String, dynamic> json) {
    return ChemistryPathway(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      diagramUrl: json['diagramUrl'],
      externalUrl: json['externalUrl'],
      relatedCompoundCids: json['relatedCompoundCids'] != null
          ? List<int>.from(json['relatedCompoundCids'])
          : [],
      additionalData: json['additionalData'],
    );
  }

  /// Converts pathway to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'source': source,
      'diagramUrl': diagramUrl,
      'externalUrl': externalUrl,
      'relatedCompoundCids': relatedCompoundCids,
      'additionalData': additionalData,
    };
  }
}

/// Represents a chemistry element with basic properties
class ChemistryElement {
  final int atomicNumber;
  final String symbol;
  final String name;
  final String category;
  final double atomicWeight;
  final String? description;

  ChemistryElement({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.category,
    required this.atomicWeight,
    this.description,
  });

  /// Creates an element from JSON data
  factory ChemistryElement.fromJson(Map<String, dynamic> json) {
    return ChemistryElement(
      atomicNumber: json['AtomicNumber'] ?? 0,
      symbol: json['Symbol'] ?? '',
      name: json['Name'] ?? '',
      category: json['GroupName'] ?? '',
      atomicWeight:
          double.tryParse(json['AtomicWeight']?.toString() ?? '0') ?? 0,
      description: json['Description'],
    );
  }

  /// Converts element to JSON
  Map<String, dynamic> toJson() {
    return {
      'AtomicNumber': atomicNumber,
      'Symbol': symbol,
      'Name': name,
      'GroupName': category,
      'AtomicWeight': atomicWeight,
      'Description': description,
    };
  }
}

/// Loading state for chemistry guide data
enum ChemistryGuideLoadingState {
  initial,
  loading,
  loaded,
  error,
}
