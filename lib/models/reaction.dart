class ChemicalReaction {
  final String name;
  final String type;
  final String reactants;
  final String products;
  final String conditions;
  final String mechanism;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? examples;
  final Map<String, dynamic>? properties;

  ChemicalReaction({
    required this.name,
    required this.type,
    required this.reactants,
    required this.products,
    required this.conditions,
    required this.mechanism,
    this.imageUrl,
    this.videoUrl,
    this.examples,
    this.properties,
  });

  factory ChemicalReaction.fromJson(Map<String, dynamic> json) {
    return ChemicalReaction(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      reactants: json['reactants'] ?? '',
      products: json['products'] ?? '',
      conditions: json['conditions'] ?? '',
      mechanism: json['mechanism'] ?? '',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      examples: (json['examples'] as List<dynamic>?)?.cast<String>(),
      properties: json['properties'],
    );
  }
}
