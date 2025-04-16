class MolecularStructure {
  final int cid;
  final String title;
  final String molecularFormula;
  final double molecularWeight;
  final String smiles;
  final String inchi;
  final String inchiKey;
  final String iupacName;
  final Map<String, dynamic>? properties;

  MolecularStructure({
    required this.cid,
    required this.title,
    required this.molecularFormula,
    required this.molecularWeight,
    required this.smiles,
    required this.inchi,
    required this.inchiKey,
    required this.iupacName,
    this.properties,
  });

  factory MolecularStructure.fromJson(Map<String, dynamic> json) {
    return MolecularStructure(
      cid: json['CID'] ?? 0,
      title: json['Title'] ?? '',
      molecularFormula: json['MolecularFormula'] ?? '',
      molecularWeight: (json['MolecularWeight'] ?? 0).toDouble(),
      smiles: json['CanonicalSMILES'] ?? '',
      inchi: json['InChI'] ?? '',
      inchiKey: json['InChIKey'] ?? '',
      iupacName: json['IUPACName'] ?? '',
      properties: json['Properties'] != null
          ? Map<String, dynamic>.from(json['Properties'])
          : null,
    );
  }
}
