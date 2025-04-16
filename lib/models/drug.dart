class Drug {
  final int cid;
  final String title;
  final String molecularFormula;
  final double molecularWeight;
  final String smiles;
  final double xLogP;
  final int hBondDonorCount;
  final int hBondAcceptorCount;
  final int rotatableBondCount;
  final double complexity;
  final String? indication;
  final String? mechanismOfAction;
  final String? toxicity;
  final String? metabolism;
  final String? pharmacology;

  Drug({
    required this.cid,
    required this.title,
    required this.molecularFormula,
    required this.molecularWeight,
    required this.smiles,
    required this.xLogP,
    required this.hBondDonorCount,
    required this.hBondAcceptorCount,
    required this.rotatableBondCount,
    required this.complexity,
    this.indication,
    this.mechanismOfAction,
    this.toxicity,
    this.metabolism,
    this.pharmacology,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      cid: json['CID'] ?? 0,
      title: json['Title'] ?? '',
      molecularFormula: json['MolecularFormula'] ?? '',
      molecularWeight: (json['MolecularWeight'] ?? 0).toDouble(),
      smiles: json['CanonicalSMILES'] ?? '',
      xLogP: (json['XLogP'] ?? 0).toDouble(),
      hBondDonorCount: json['HBondDonorCount'] ?? 0,
      hBondAcceptorCount: json['HBondAcceptorCount'] ?? 0,
      rotatableBondCount: json['RotatableBondCount'] ?? 0,
      complexity: (json['Complexity'] ?? 0).toDouble(),
      indication: json['indication'],
      mechanismOfAction: json['mechanismOfAction'],
      toxicity: json['toxicity'],
      metabolism: json['metabolism'],
      pharmacology: json['pharmacology'],
    );
  }
}
