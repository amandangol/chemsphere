import '../utils/element_data.dart';

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
  final int period;
  final int group;
  final String atomicRadius;
  final String electronegativity;
  final String ionizationEnergy;
  final String yearDiscovered;

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
    required this.period,
    required this.group,
    required this.atomicRadius,
    required this.electronegativity,
    required this.ionizationEnergy,
    required this.yearDiscovered,
  });

  factory Element.fromJson(Map<String, dynamic> json) {
    // Handle atomic mass conversion
    double parseAtomicMass(dynamic value, String symbol) {
      if (value == null) {
        // Use default value from our data
        return defaultAtomicMasses[symbol] ?? 0.0;
      }

      // Handle numeric values directly
      if (value is num) {
        final apiValue = value.toDouble();
        return getAtomicMass(symbol, apiValue);
      }

      // Handle string values with special formatting
      if (value is String) {
        try {
          // Try to parse the value
          final apiValue = double.tryParse(value) ??
              double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0;

          // Use the utility function to get the best atomic mass
          return getAtomicMass(symbol, apiValue);
        } catch (e) {
          print('Error parsing atomic mass: $e');
          return defaultAtomicMasses[symbol] ?? 0.0;
        }
      }

      return defaultAtomicMasses[symbol] ?? 0.0;
    }

    // Get the symbol first
    final symbol = json['symbol'] as String? ?? '';

    return Element(
      number: json['number'] ?? 0,
      symbol: symbol,
      name: json['name'] ?? '',
      atomicMass: parseAtomicMass(json['atomic_mass'], symbol),
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
      period: json['period'] ?? 0,
      group: json['group'] ?? 0,
      atomicRadius: json['atomic_radius'] ?? '',
      electronegativity: json['electronegativity'] ?? '',
      ionizationEnergy: json['ionization_energy'] ?? '',
      yearDiscovered: json['year_discovered'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'symbol': symbol,
      'name': name,
      'atomic_mass': atomicMass,
      'category': category,
      'phase': phase,
      'appearance': appearance,
      'density': density,
      'melt': melt,
      'boil': boil,
      'molar_heat': molarHeat,
      'electron_configuration': electronConfiguration,
      'electron_affinity': electronAffinity,
      'electronegativity_pauling': electronegativityPauling,
      'ionization_energies': ionizationEnergies,
      'shells': shells,
      'discovered_by': discoveredBy,
      'named_by': namedBy,
      'source': source,
      'summary': summary,
      'period': period,
      'group': group,
      'atomic_radius': atomicRadius,
      'electronegativity': electronegativity,
      'ionization_energy': ionizationEnergy,
      'year_discovered': yearDiscovered,
    };
  }
}
