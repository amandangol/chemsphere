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
      molecularWeight:
          double.tryParse(json['MolecularWeight']?.toString() ?? '0') ?? 0.0,
      smiles: json['CanonicalSMILES'] ?? '',
      xLogP: double.tryParse(json['XLogP']?.toString() ?? '0') ?? 0.0,
      hBondDonorCount:
          int.tryParse(json['HBondDonorCount']?.toString() ?? '0') ?? 0,
      hBondAcceptorCount:
          int.tryParse(json['HBondAcceptorCount']?.toString() ?? '0') ?? 0,
      rotatableBondCount:
          int.tryParse(json['RotatableBondCount']?.toString() ?? '0') ?? 0,
      complexity: double.tryParse(json['Complexity']?.toString() ?? '0') ?? 0.0,
      indication: json['indication'],
      mechanismOfAction: json['mechanismOfAction'],
      toxicity: json['toxicity'],
      metabolism: json['metabolism'],
      pharmacology: json['pharmacology'],
    );
  }
}
