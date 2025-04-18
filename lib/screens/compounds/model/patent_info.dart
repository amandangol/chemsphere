class PatentInfo {
  final String id;
  final String url;

  PatentInfo({
    required this.id,
    required this.url,
  });

  factory PatentInfo.fromJson(Map<String, dynamic> json) {
    return PatentInfo(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}
