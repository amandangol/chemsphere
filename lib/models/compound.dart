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
  final String iupacName;
  final String description;
  final String descriptionSource;
  final String descriptionUrl;
  final List<String> synonyms;
  final Map<String, dynamic> physicalProperties;
  final Map<String, dynamic> safetyData;
  final List<String> classifications;
  final List<String> uses;
  final String pubChemUrl;

  // New properties
  final double exactMass;
  final double monoisotopicMass;
  final double tpsa;
  final int charge;
  final int isotopeAtomCount;
  final int definedAtomStereoCount;
  final int undefinedAtomStereoCount;
  final int definedBondStereoCount;
  final int undefinedBondStereoCount;
  final int covalentUnitCount;
  final int patentCount;
  final int patentFamilyCount;
  final List<String> annotationTypes;
  final int annotationTypeCount;
  final List<String> sourceCategories;
  final int literatureCount;
  final String inchi;
  final String inchiKey;

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
    this.iupacName = '',
    this.description = '',
    this.descriptionSource = '',
    this.descriptionUrl = '',
    this.synonyms = const [],
    this.physicalProperties = const {},
    this.safetyData = const {},
    this.classifications = const [],
    this.uses = const [],
    this.pubChemUrl = '',
    // New properties with defaults
    this.exactMass = 0.0,
    this.monoisotopicMass = 0.0,
    this.tpsa = 0.0,
    this.charge = 0,
    this.isotopeAtomCount = 0,
    this.definedAtomStereoCount = 0,
    this.undefinedAtomStereoCount = 0,
    this.definedBondStereoCount = 0,
    this.undefinedBondStereoCount = 0,
    this.covalentUnitCount = 0,
    this.patentCount = 0,
    this.patentFamilyCount = 0,
    this.annotationTypes = const [],
    this.annotationTypeCount = 0,
    this.sourceCategories = const [],
    this.literatureCount = 0,
    this.inchi = '',
    this.inchiKey = '',
  });

  factory Compound.fromJson(Map<String, dynamic> json) {
    // Handle AnnotationTypes
    dynamic annotationTypes = json['AnnotationTypes'];
    List<String> annotationTypesList = [];
    if (annotationTypes is String) {
      annotationTypesList = annotationTypes.split('|');
    } else if (annotationTypes is List) {
      annotationTypesList = List<String>.from(annotationTypes);
    }

    // Handle SourceCategories
    dynamic sourceCategories = json['SourceCategories'];
    List<String> sourceCategoriesList = [];
    if (sourceCategories is String) {
      sourceCategoriesList = sourceCategories.split('|');
    } else if (sourceCategories is List) {
      sourceCategoriesList = List<String>.from(sourceCategories);
    }

    // Create physical properties map
    Map<String, dynamic> physicalProperties = {
      'Molecular Weight': json['Molecular Weight']?.toString() ?? '0',
      'XLogP': json['XLogP']?.toString() ?? '0',
      'TPSA': json['TPSA']?.toString() ?? '0',
      'Complexity': json['Complexity']?.toString() ?? '0',
      'Exact Mass': json['ExactMass']?.toString() ?? '0',
      'Monoisotopic Mass': json['MonoisotopicMass']?.toString() ?? '0',
      'Charge': json['Charge']?.toString() ?? '0',
      'Heavy Atom Count': json['HeavyAtomCount']?.toString() ?? '0',
      'Isotope Atom Count': json['IsotopeAtomCount']?.toString() ?? '0',
      'SMILES': json['CanonicalSMILES'] ?? '',
      'InChI': json['InChI'] ?? '',
      'InChI Key': json['InChIKey'] ?? '',
      'IUPAC Name': json['IUPACName'] ?? '',
      'Molecular Formula': json['MolecularFormula'] ?? '',
    };

    print('Creating compound from JSON: $json');
    print('Physical properties: $physicalProperties');

    return Compound(
      cid: json['CID'] ?? 0,
      title: json['Title'] ??
          json['IUPACName'] ??
          '', // Use IUPAC name as fallback
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
      physicalProperties: physicalProperties,
      safetyData: {},
      classifications: [],
      uses: [],
      pubChemUrl:
          'https://pubchem.ncbi.nlm.nih.gov/compound/${json['CID'] ?? 0}',
      exactMass: double.tryParse(json['ExactMass']?.toString() ?? '0') ?? 0.0,
      monoisotopicMass:
          double.tryParse(json['MonoisotopicMass']?.toString() ?? '0') ?? 0.0,
      tpsa: double.tryParse(json['TPSA']?.toString() ?? '0') ?? 0.0,
      charge: int.tryParse(json['Charge']?.toString() ?? '0') ?? 0,
      isotopeAtomCount:
          int.tryParse(json['IsotopeAtomCount']?.toString() ?? '0') ?? 0,
      definedAtomStereoCount:
          int.tryParse(json['DefinedAtomStereoCount']?.toString() ?? '0') ?? 0,
      undefinedAtomStereoCount:
          int.tryParse(json['UndefinedAtomStereoCount']?.toString() ?? '0') ??
              0,
      definedBondStereoCount:
          int.tryParse(json['DefinedBondStereoCount']?.toString() ?? '0') ?? 0,
      undefinedBondStereoCount:
          int.tryParse(json['UndefinedBondStereoCount']?.toString() ?? '0') ??
              0,
      covalentUnitCount:
          int.tryParse(json['CovalentUnitCount']?.toString() ?? '0') ?? 0,
      patentCount: int.tryParse(json['PatentCount']?.toString() ?? '0') ?? 0,
      patentFamilyCount:
          int.tryParse(json['PatentFamilyCount']?.toString() ?? '0') ?? 0,
      annotationTypes: annotationTypesList,
      annotationTypeCount:
          int.tryParse(json['AnnotationTypeCount']?.toString() ?? '0') ?? 0,
      sourceCategories: sourceCategoriesList,
      literatureCount:
          int.tryParse(json['LiteratureCount']?.toString() ?? '0') ?? 0,
      inchi: json['InChI'] ?? '',
      inchiKey: json['InChIKey'] ?? '',
    );
  }
}
