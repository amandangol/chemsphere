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
      heavyAtomCount:
          int.tryParse(json['HeavyAtomCount']?.toString() ?? '0') ?? 0,
      atomStereoCount:
          int.tryParse(json['AtomStereoCount']?.toString() ?? '0') ?? 0,
      bondStereoCount:
          int.tryParse(json['BondStereoCount']?.toString() ?? '0') ?? 0,
      complexity: double.tryParse(json['Complexity']?.toString() ?? '0') ?? 0.0,
    );
  }
}
