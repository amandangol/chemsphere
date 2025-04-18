class AssaySummary {
  final String aid;
  final String name;
  final String description;
  final String url;
  final double? score;
  final String outcome;

  AssaySummary({
    required this.aid,
    required this.name,
    required this.description,
    required this.url,
    this.score,
    required this.outcome,
  });

  factory AssaySummary.fromJson(Map<String, dynamic> json) {
    return AssaySummary(
      aid: json['aid'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      score: json['score'] != null
          ? double.tryParse(json['score'].toString())
          : null,
      outcome: json['outcome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aid': aid,
      'name': name,
      'description': description,
      'url': url,
      'score': score,
      'outcome': outcome,
    };
  }
}
