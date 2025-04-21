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
  final int heavyAtomCount;
  final int atomStereoCount;
  final int bondStereoCount;
  final double complexity;
  final String iupacName;
  final String description;
  final String descriptionSource;
  final String descriptionUrl;
  final List<String> synonyms;
  final Map<String, dynamic> physicalProperties;
  final String pubChemUrl;
  final String indication;
  final String mechanismOfAction;
  final String toxicity;
  final String pharmacology;
  final String metabolism;
  final String absorption;
  final String halfLife;
  final String proteinBinding;
  final String routeOfElimination;
  final String volumeOfDistribution;
  final String clearance;
  final String name;

  const Drug({
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
    required this.iupacName,
    required this.description,
    required this.descriptionSource,
    required this.descriptionUrl,
    required this.synonyms,
    required this.physicalProperties,
    required this.pubChemUrl,
    required this.indication,
    required this.mechanismOfAction,
    required this.toxicity,
    required this.pharmacology,
    required this.metabolism,
    required this.absorption,
    required this.halfLife,
    required this.proteinBinding,
    required this.routeOfElimination,
    required this.volumeOfDistribution,
    required this.clearance,
    required this.name,
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
      heavyAtomCount:
          int.tryParse(json['HeavyAtomCount']?.toString() ?? '0') ?? 0,
      atomStereoCount:
          int.tryParse(json['AtomStereoCount']?.toString() ?? '0') ?? 0,
      bondStereoCount:
          int.tryParse(json['BondStereoCount']?.toString() ?? '0') ?? 0,
      complexity: double.tryParse(json['Complexity']?.toString() ?? '0') ?? 0.0,
      iupacName: json['IUPACName'] ?? '',
      description: json['Description'] ?? '',
      descriptionSource: json['DescriptionSource'] ?? '',
      descriptionUrl: json['DescriptionUrl'] ?? '',
      synonyms: List<String>.from(json['Synonyms'] ?? []),
      physicalProperties:
          Map<String, dynamic>.from(json['PhysicalProperties'] ?? {}),
      pubChemUrl: 'https://pubchem.ncbi.nlm.nih.gov/compound/${json['CID']}',
      indication: json['Indication'] ?? '',
      mechanismOfAction: json['MechanismOfAction'] ?? '',
      toxicity: json['Toxicity'] ?? '',
      pharmacology: json['Pharmacology'] ?? '',
      metabolism: json['Metabolism'] ?? '',
      absorption: json['Absorption'] ?? '',
      halfLife: json['HalfLife'] ?? '',
      proteinBinding: json['ProteinBinding'] ?? '',
      routeOfElimination: json['RouteOfElimination'] ?? '',
      volumeOfDistribution: json['VolumeOfDistribution'] ?? '',
      clearance: json['Clearance'] ?? '',
      name: json['Name'] ?? '',
    );
  }
}
