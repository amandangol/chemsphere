class Compound {
  final int cid;
  final String title;
  final String molecularFormula;
  final double molecularWeight;
  final String smiles;
  final double xLogP;
  final int hBondDonorCount;
  final int hBondAcceptorCount;
  final int rotatableBondCount;
  final int heavyAtomCount;
  final int atomStereoCount;
  final int bondStereoCount;
  final double complexity;

  Compound({
    required this.cid,
    required this.title,
    required this.molecularFormula,
    required this.molecularWeight,
    required this.smiles,
    required this.xLogP,
    required this.hBondDonorCount,
    required this.hBondAcceptorCount,
    required this.rotatableBondCount,
    required this.heavyAtomCount,
    required this.atomStereoCount,
    required this.bondStereoCount,
    required this.complexity,
  });

  factory Compound.fromJson(Map<String, dynamic> json) {
    return Compound(
      cid: json['CID'] ?? 0,
      title: json['Title'] ?? '',
      molecularFormula: json['MolecularFormula'] ?? '',
      molecularWeight: (json['MolecularWeight'] ?? 0).toDouble(),
      smiles: json['CanonicalSMILES'] ?? '',
      xLogP: (json['XLogP'] ?? 0).toDouble(),
      hBondDonorCount: json['HBondDonorCount'] ?? 0,
      hBondAcceptorCount: json['HBondAcceptorCount'] ?? 0,
      rotatableBondCount: json['RotatableBondCount'] ?? 0,
      heavyAtomCount: json['HeavyAtomCount'] ?? 0,
      atomStereoCount: json['AtomStereoCount'] ?? 0,
      bondStereoCount: json['BondStereoCount'] ?? 0,
      complexity: (json['Complexity'] ?? 0).toDouble(),
    );
  }
}
