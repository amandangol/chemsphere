class Element {
  final int number;
  final String symbol;
  final String name;
  final double atomicMass;
  final String category;
  final String phase;
  final String appearance;
  final double density;
  final double melt;
  final double boil;
  final double molarHeat;
  final String electronConfiguration;
  final double electronAffinity;
  final double electronegativityPauling;
  final List<double> ionizationEnergies;
  final List<int> shells;
  final String discoveredBy;
  final String namedBy;
  final String source;
  final String summary;

  Element({
    required this.number,
    required this.symbol,
    required this.name,
    required this.atomicMass,
    required this.category,
    required this.phase,
    required this.appearance,
    required this.density,
    required this.melt,
    required this.boil,
    required this.molarHeat,
    required this.electronConfiguration,
    required this.electronAffinity,
    required this.electronegativityPauling,
    required this.ionizationEnergies,
    required this.shells,
    required this.discoveredBy,
    required this.namedBy,
    required this.source,
    required this.summary,
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      number: json['number'] ?? 0,
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      atomicMass: (json['atomic_mass'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      phase: json['phase'] ?? '',
      appearance: json['appearance'] ?? '',
      density: (json['density'] ?? 0).toDouble(),
      melt: (json['melt'] ?? 0).toDouble(),
      boil: (json['boil'] ?? 0).toDouble(),
      molarHeat: (json['molar_heat'] ?? 0).toDouble(),
      electronConfiguration: json['electron_configuration'] ?? '',
      electronAffinity: (json['electron_affinity'] ?? 0).toDouble(),
      electronegativityPauling:
          (json['electronegativity_pauling'] ?? 0).toDouble(),
      ionizationEnergies: (json['ionization_energies'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      shells:
          (json['shells'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [],
      discoveredBy: json['discovered_by'] ?? '',
      namedBy: json['named_by'] ?? '',
      source: json['source'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}
