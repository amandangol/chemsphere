class RelatedCompound {
  final int cid;
  final String title;
  final String molecularFormula;
  final double molecularWeight;
  final String smiles;
  final double similarityScore;
  final String pubChemUrl;

  RelatedCompound({
    required this.cid,
    required this.title,
    required this.molecularFormula,
    required this.molecularWeight,
    required this.smiles,
    required this.similarityScore,
    required this.pubChemUrl,
  });

  factory RelatedCompound.fromJson(Map<String, dynamic> json) {
    return RelatedCompound(
      cid: json['cid'] ?? 0,
      title: json['title'] ?? '',
      molecularFormula: json['molecularFormula'] ?? '',
      molecularWeight: json['molecularWeight'] ?? 0.0,
      smiles: json['smiles'] ?? '',
      similarityScore: json['similarityScore'] ?? 0.0,
      pubChemUrl: json['pubChemUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'title': title,
      'molecularFormula': molecularFormula,
      'molecularWeight': molecularWeight,
      'smiles': smiles,
      'similarityScore': similarityScore,
      'pubChemUrl': pubChemUrl,
    };
  }
}
