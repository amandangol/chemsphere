/// Constants for chemistry topics that are reliably available on Wikipedia

class ChemistryTopics {
  // Basic chemistry topics
  static const Map<String, String> basicTopics = {
    'atom': 'Atom',
    'element': 'Element (chemistry)',
    'periodic_table': 'Periodic table',
    'chemical_bond': 'Chemical bond',
    'covalent_bond': 'Covalent bond',
    'ionic_bond': 'Ionic bond',
    'states_of_matter': 'States of matter',
    'solution': 'Solution (chemistry)',
    'concentration': 'Concentration',
    'chemical_reaction': 'Chemical reaction',
    'chemical_equation': 'Chemical equation',
    'acid_base': 'Acid–base reaction',
    'redox': 'Redox',
    'precipitation': 'Precipitation (chemistry)',
    'stoichiometry': 'Stoichiometry',
  };

  // Thermodynamics and kinetics topics
  static const Map<String, String> energyTopics = {
    'thermochemistry': 'Thermochemistry',
    'chemical_thermodynamics': 'Chemical thermodynamics',
    'entropy': 'Entropy',
    'enthalpy': 'Enthalpy',
    'gibbs_free_energy': 'Gibbs free energy',
    'chemical_kinetics': 'Chemical kinetics',
    'catalysis': 'Catalysis',
    'reaction_rate': 'Reaction rate',
    'activation_energy': 'Activation energy',
    'electrochemistry': 'Electrochemistry',
  };

  // Organic chemistry topics
  static const Map<String, String> organicTopics = {
    'organic_chemistry': 'Organic chemistry',
    'organic_compound': 'Organic compound',
    'functional_group': 'Functional group',
    'hydrocarbon': 'Hydrocarbon',
    'alkane': 'Alkane',
    'alkene': 'Alkene',
    'alkyne': 'Alkyne',
    'aromatic_compound': 'Aromatic compound',
    'stereochemistry': 'Stereochemistry',
    'polymer': 'Polymer',
    'carbohydrate': 'Carbohydrate',
    'lipid': 'Lipid',
  };

  // Biochemistry topics
  static const Map<String, String> biochemistryTopics = {
    'biochemistry': 'Biochemistry',
    'protein': 'Protein',
    'enzyme': 'Enzyme',
    'nucleic_acid': 'Nucleic acid',
    'dna': 'DNA',
    'metabolism': 'Metabolism',
    'amino_acid': 'Amino acid',
    'peptide': 'Peptide',
    'protein_structure': 'Protein structure',
  };

  // Analytical chemistry topics
  static const Map<String, String> analyticalTopics = {
    'analytical_chemistry': 'Analytical chemistry',
    'spectroscopy': 'Spectroscopy',
    'chromatography': 'Chromatography',
    'mass_spectrometry': 'Mass spectrometry',
    'titration': 'Titration',
    'ph': 'PH',
    'nuclear_magnetic_resonance': 'Nuclear magnetic resonance',
    'infrared_spectroscopy': 'Infrared spectroscopy',
  };

  // Advanced chemistry topics
  static const Map<String, String> advancedTopics = {
    'nuclear_chemistry': 'Nuclear chemistry',
    'radiochemistry': 'Radiochemistry',
    'quantum_chemistry': 'Quantum chemistry',
    'computational_chemistry': 'Computational chemistry',
    'green_chemistry': 'Green chemistry',
    'medicinal_chemistry': 'Medicinal chemistry',
    'nanochemistry': 'Nanochemistry',
    'photochemistry': 'Photochemistry',
    'coordination_complex': 'Coordination complex',
    'crystal': 'Crystal',
  };

  // Helper method to get the correct Wikipedia topic title
  static String getTopicTitle(String key) {
    if (basicTopics.containsKey(key)) {
      return basicTopics[key]!;
    }
    if (energyTopics.containsKey(key)) {
      return energyTopics[key]!;
    }
    if (organicTopics.containsKey(key)) {
      return organicTopics[key]!;
    }
    if (biochemistryTopics.containsKey(key)) {
      return biochemistryTopics[key]!;
    }
    if (analyticalTopics.containsKey(key)) {
      return analyticalTopics[key]!;
    }
    if (advancedTopics.containsKey(key)) {
      return advancedTopics[key]!;
    }

    // If not found, return the key with first letter capitalized
    return key.isEmpty ? key : key[0].toUpperCase() + key.substring(1);
  }

  // Get related topics based on a primary topic
  static List<String> getRelatedTopics(String topic) {
    final String lowerTopic = topic.toLowerCase();

    if (lowerTopic.contains('atom') || lowerTopic.contains('element')) {
      return [
        'Atom',
        'Element (chemistry)',
        'Periodic table',
        'Atomic theory',
        'Subatomic particle',
      ];
    }

    if (lowerTopic.contains('bond')) {
      return [
        'Chemical bond',
        'Covalent bond',
        'Ionic bond',
        'Hydrogen bond',
        'Molecular orbital theory',
      ];
    }

    if (lowerTopic.contains('reaction')) {
      return [
        'Chemical reaction',
        'Chemical equation',
        'Chemical equilibrium',
        'Redox',
        'Acid–base reaction',
      ];
    }

    if (lowerTopic.contains('organic')) {
      return [
        'Organic chemistry',
        'Organic compound',
        'Functional group',
        'Carbon',
        'Hydrocarbon',
      ];
    }

    // Default related topics for chemistry in general
    return [
      'Chemistry',
      'Chemical compound',
      'Chemical reaction',
      'Periodic table',
      'Chemical element',
    ];
  }
}
