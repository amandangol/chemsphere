class MolecularStructure {
  final int cid;
  final String title;
  final String molecularFormula;
  final double molecularWeight;
  final String smiles;
  final String inchi;
  final String inchiKey;
  final String iupacName;
  final double? xLogP;
  final double? complexity;
  final int? hBondDonorCount;
  final int? hBondAcceptorCount;
  final int? rotatableBondCount;
  final int? heavyAtomCount;
  final int? atomStereoCount;
  final int? bondStereoCount;

  MolecularStructure({
    required this.cid,
    required this.title,
    required this.molecularFormula,
    required this.molecularWeight,
    required this.smiles,
    required this.inchi,
    required this.inchiKey,
    required this.iupacName,
    this.xLogP,
    this.complexity,
    this.hBondDonorCount,
    this.hBondAcceptorCount,
    this.rotatableBondCount,
    this.heavyAtomCount,
    this.atomStereoCount,
    this.bondStereoCount,
  });

  factory MolecularStructure.fromJson(Map<String, dynamic> json) {
    return MolecularStructure(
      cid: json['CID'] ?? 0,
      title: json['Title'] ?? '',
      molecularFormula: json['MolecularFormula'] ?? '',
      molecularWeight:
          double.tryParse(json['MolecularWeight']?.toString() ?? '0') ?? 0.0,
      smiles: json['CanonicalSMILES'] ?? '',
      inchi: json['InChI'] ?? '',
      inchiKey: json['InChIKey'] ?? '',
      iupacName: json['IUPACName'] ?? '',
      xLogP: json['XLogP']?.toDouble(),
      complexity: json['Complexity']?.toDouble(),
      hBondDonorCount: json['HBondDonorCount'],
      hBondAcceptorCount: json['HBondAcceptorCount'],
      rotatableBondCount: json['RotatableBondCount'],
      heavyAtomCount: json['HeavyAtomCount'],
      atomStereoCount: json['AtomStereoCount'],
      bondStereoCount: json['BondStereoCount'],
    );
  }
}
