class ChemistryElement {
  final String symbol;
  final String name;
  final int atomicNumber;
  final double atomicWeight;
  final String group;
  final String period;
  final String description;
  final String electronConfiguration;
  final String category;
  final double? electronegativity;
  final String imageUrl;
  final Map<String, dynamic>? detailedData; // Raw data from PUG View

  ChemistryElement({
    required this.symbol,
    required this.name,
    required this.atomicNumber,
    required this.atomicWeight,
    required this.group,
    required this.period,
    required this.description,
    required this.electronConfiguration,
    required this.category,
    this.electronegativity,
    required this.imageUrl,
    this.detailedData,
  });

  factory ChemistryElement.fromJson(Map<String, dynamic> json) {
    return ChemistryElement(
      symbol: json['Symbol'] ?? '',
      name: json['Name'] ?? '',
      atomicNumber: json['AtomicNumber'] ?? 0,
      atomicWeight: json['AtomicMass'] != null
          ? double.tryParse(json['AtomicMass'].toString()) ?? 0.0
          : 0.0,
      group: json['Group'] != null ? json['Group'].toString() : '',
      period: json['Period'] != null ? json['Period'].toString() : '',
      description: json['Description'] ?? '',
      electronConfiguration: json['ElectronConfiguration'] ?? '',
      category: json['Element Category'] ?? '',
      electronegativity: json['Electronegativity'] != null
          ? double.tryParse(json['Electronegativity'].toString())
          : null,
      imageUrl: 'https://pubchem.ncbi.nlm.nih.gov/element/${json['Symbol']}',
      detailedData: null, // Added later via PUG View
    );
  }

  // Create a copy of this element with detailed data added
  ChemistryElement copyWithDetailedData(Map<String, dynamic> detailedData) {
    return ChemistryElement(
      symbol: symbol,
      name: name,
      atomicNumber: atomicNumber,
      atomicWeight: atomicWeight,
      group: group,
      period: period,
      description: description,
      electronConfiguration: electronConfiguration,
      category: category,
      electronegativity: electronegativity,
      imageUrl: imageUrl,
      detailedData: detailedData,
    );
  }
}

class ChemicalProperty {
  final String name;
  final String value;
  final String? unit;
  final String? description;
  final String? source; // Source of the property data from PUG View

  ChemicalProperty({
    required this.name,
    required this.value,
    this.unit,
    this.description,
    this.source,
  });

  factory ChemicalProperty.fromJson(Map<String, dynamic> json) {
    return ChemicalProperty(
      name: json['Name'] ?? '',
      value: json['Value']?.toString() ?? '',
      unit: json['Unit'],
      description: json['Description'],
      source: json['Source'],
    );
  }

  // Create a property from PUG View annotation
  factory ChemicalProperty.fromPugViewAnnotation(
      Map<String, dynamic> annotation) {
    String value = '';
    String? unit;

    // Extract value and unit from PUG View format
    if (annotation.containsKey('Value') && annotation['Value'] is Map) {
      final valueMap = annotation['Value'];
      if (valueMap.containsKey('StringWithMarkup') &&
          valueMap['StringWithMarkup'] is List &&
          valueMap['StringWithMarkup'].isNotEmpty) {
        value = valueMap['StringWithMarkup'][0]['String'] ?? '';
      }

      if (valueMap.containsKey('Unit')) {
        unit = valueMap['Unit'];
      }
    }

    // Extract source if available
    String? source;
    if (annotation.containsKey('Reference') &&
        annotation['Reference'] is List &&
        annotation['Reference'].isNotEmpty) {
      final ref = annotation['Reference'][0];
      source = ref['SourceName'] ?? '';
    }

    return ChemicalProperty(
      name: annotation['Name'] ?? '',
      value: value,
      unit: unit,
      description: annotation['Description'],
      source: source,
    );
  }
}

class ChemicalCompound {
  final int cid;
  final String name;
  final String formula;
  final double? molecularWeight;
  final String? inchi;
  final String? inchiKey;
  final String? smiles;
  final List<ChemicalProperty> properties;
  final String description;
  final String imageUrl;
  final Map<String, dynamic>? detailedData; // Raw data from PUG View
  final List<Map<String, dynamic>>?
      literature; // Literature references from PUG View

  ChemicalCompound({
    required this.cid,
    required this.name,
    required this.formula,
    this.molecularWeight,
    this.inchi,
    this.inchiKey,
    this.smiles,
    required this.properties,
    required this.description,
    required this.imageUrl,
    this.detailedData,
    this.literature,
  });

  factory ChemicalCompound.fromJson(Map<String, dynamic> json) {
    final record = json['Record'] ?? {};
    final props = record['Section'] ?? [];
    List<ChemicalProperty> properties = [];

    String? formula;
    double? molWeight;
    String description = '';

    // Extract properties from different sections
    if (props is List) {
      for (final section in props) {
        final sectionName = section['TOCHeading'] ?? '';

        if (sectionName == 'Names and Identifiers') {
          final infos = section['Information'] ?? [];
          if (infos is List) {
            for (final info in infos) {
              final value = info['Value'] ?? {};
              final stringValue =
                  value['StringWithMarkup']?[0]?['String'] ?? '';

              if (info['Name'] == 'Molecular Formula') {
                formula = stringValue;
              }
            }
          }
        } else if (sectionName == 'Chemical and Physical Properties') {
          final infos = section['Information'] ?? [];
          if (infos is List) {
            for (final info in infos) {
              final value = info['Value'] ?? {};
              final stringValue =
                  value['StringWithMarkup']?[0]?['String'] ?? '';

              if (info['Name'] == 'Molecular Weight') {
                molWeight = double.tryParse(stringValue);
              }

              properties.add(ChemicalProperty(
                name: info['Name'] ?? '',
                value: stringValue,
              ));
            }
          }
        } else if (sectionName == 'Description') {
          final infos = section['Information'] ?? [];
          if (infos is List && infos.isNotEmpty) {
            final value = infos[0]['Value'] ?? {};
            description = value['StringWithMarkup']?[0]?['String'] ?? '';
          }
        }
      }
    }

    final name = record['RecordTitle'] ?? 'Unknown Compound';
    final cid = record['RecordNumber'] ?? 0;

    return ChemicalCompound(
      cid: cid,
      name: name,
      formula: formula ?? '',
      molecularWeight: molWeight,
      properties: properties,
      description: description,
      imageUrl:
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/PNG',
    );
  }

  // Create a copy with detailed data
  ChemicalCompound copyWithDetailedData({
    Map<String, dynamic>? detailedData,
    List<Map<String, dynamic>>? literature,
  }) {
    return ChemicalCompound(
      cid: cid,
      name: name,
      formula: formula,
      molecularWeight: molecularWeight,
      inchi: inchi,
      inchiKey: inchiKey,
      smiles: smiles,
      properties: properties,
      description: description,
      imageUrl: imageUrl,
      detailedData: detailedData ?? this.detailedData,
      literature: literature ?? this.literature,
    );
  }
}

class ChemicalReaction {
  final String name;
  final String equation;
  final String description;
  final String reactionType;
  final List<String> reactants;
  final List<String> products;
  final List<ChemicalProperty>?
      conditions; // Reaction conditions like temperature, pressure
  final String? mechanism; // Description of reaction mechanism if available
  final List<Map<String, dynamic>>? references; // Academic references

  ChemicalReaction({
    required this.name,
    required this.equation,
    required this.description,
    required this.reactionType,
    required this.reactants,
    required this.products,
    this.conditions,
    this.mechanism,
    this.references,
  });

  // Factory for creating from PUG View data would be implemented based on actual API response
}

class ChemistryPathway {
  final String id;
  final String source; // e.g., "Reactome"
  final String name;
  final String description;
  final List<int> relatedCompoundCids;
  final String? diagramUrl;
  final String? externalUrl;

  ChemistryPathway({
    required this.id,
    required this.source,
    required this.name,
    required this.description,
    required this.relatedCompoundCids,
    this.diagramUrl,
    this.externalUrl,
  });

  factory ChemistryPathway.fromPugView(Map<String, dynamic> json) {
    // Extract the pathway data from PUG View format
    final record = json['Record'] ?? {};
    final sections = record['Section'] ?? [];

    String name = record['RecordTitle'] ?? '';
    String description = '';
    List<int> compoundCids = [];
    String? diagramUrl;
    String? externalUrl;

    // Parse sections to extract data
    if (sections is List) {
      for (final section in sections) {
        final heading = section['TOCHeading'] ?? '';

        if (heading == 'Description') {
          final infos = section['Information'] ?? [];
          if (infos is List && infos.isNotEmpty) {
            final value = infos[0]['Value'] ?? {};
            description = value['StringWithMarkup']?[0]?['String'] ?? '';
          }
        } else if (heading == 'Compounds') {
          final infos = section['Information'] ?? [];
          if (infos is List) {
            for (final info in infos) {
              if (info.containsKey('URL') && info['URL'] is List) {
                for (final url in info['URL']) {
                  if (url.containsKey('CompoundID')) {
                    compoundCids
                        .add(int.tryParse(url['CompoundID'].toString()) ?? 0);
                  }
                }
              }
            }
          }
        } else if (heading == 'Pathway Diagram') {
          final infos = section['Information'] ?? [];
          if (infos is List &&
              infos.isNotEmpty &&
              infos[0].containsKey('URL')) {
            diagramUrl = infos[0]['URL'];
          }
        } else if (heading == 'External Links') {
          final infos = section['Information'] ?? [];
          if (infos is List &&
              infos.isNotEmpty &&
              infos[0].containsKey('URL')) {
            externalUrl = infos[0]['URL'];
          }
        }
      }
    }

    // Parse ID from record information
    String id = '';
    String source = '';
    if (record.containsKey('RecordAccession') &&
        record['RecordAccession'] is List) {
      for (final accession in record['RecordAccession']) {
        if (accession.containsKey('Source')) {
          source = accession['Source'] ?? '';
          id = accession['ID'] ?? '';
          break;
        }
      }
    }

    return ChemistryPathway(
      id: id,
      source: source,
      name: name,
      description: description,
      relatedCompoundCids: compoundCids,
      diagramUrl: diagramUrl,
      externalUrl: externalUrl,
    );
  }
}

class ChemistryTopicContent {
  final String title;
  final String content;
  final List<String>? imageUrls;
  final List<Map<String, dynamic>>? references;
  final List<ChemicalProperty>? relatedProperties;

  ChemistryTopicContent({
    required this.title,
    required this.content,
    this.imageUrls,
    this.references,
    this.relatedProperties,
  });

  // Factory method to create from PUG View annotation
  factory ChemistryTopicContent.fromPugViewAnnotation(
      Map<String, dynamic> data) {
    final title = data['Name'] ?? 'Unknown Topic';
    String content = '';
    List<String> imageUrls = [];
    List<Map<String, dynamic>> references = [];

    // Extract content from value
    if (data.containsKey('Value') && data['Value'] is Map) {
      final valueMap = data['Value'];
      if (valueMap.containsKey('StringWithMarkup') &&
          valueMap['StringWithMarkup'] is List &&
          valueMap['StringWithMarkup'].isNotEmpty) {
        for (final markup in valueMap['StringWithMarkup']) {
          if (markup.containsKey('String')) {
            content += markup['String'] ?? '';
          }

          // Extract any image URLs that might be in markup
          if (markup.containsKey('Markup') && markup['Markup'] is List) {
            for (final mark in markup['Markup']) {
              if (mark.containsKey('URL') &&
                  mark['URL'].toString().contains('image')) {
                imageUrls.add(mark['URL']);
              }
            }
          }
        }
      }
    }

    // Extract references
    if (data.containsKey('Reference') && data['Reference'] is List) {
      for (final ref in data['Reference']) {
        if (ref is Map) {
          references.add(Map<String, dynamic>.from(ref));
        }
      }
    }

    return ChemistryTopicContent(
      title: title,
      content: content,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
      references: references.isNotEmpty ? references : null,
    );
  }
}

class ChemistryTopic {
  final String id;
  final String title;
  final String description;
  final String content;
  final List<String> relatedCompoundIds;
  final List<String> relatedElementIds;
  final List<String> examples;
  final List<ChemistryTopicContent>? subtopics;
  final String? headingKey; // PUG View heading key for retrieving content
  final String? imageUrl;

  ChemistryTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.relatedCompoundIds = const [],
    this.relatedElementIds = const [],
    this.examples = const [],
    this.subtopics,
    this.headingKey,
    this.imageUrl,
  });

  // Factory to create from PUG View annotation heading
  factory ChemistryTopic.fromHeading(
      String heading, Map<String, dynamic> data) {
    // This would extract topic information from the PUG View annotation
    // Structure would depend on the specific heading type

    String description = '';
    String content = '';
    List<ChemistryTopicContent> subtopics = [];

    // Process annotation content
    if (data.containsKey('Annotation') && data['Annotation'] is Map) {
      final annotation = data['Annotation'];

      // Try to extract content from first annotation if available
      if (annotation.containsKey('Data') &&
          annotation['Data'] is List &&
          annotation['Data'].isNotEmpty) {
        final firstData = annotation['Data'][0];

        if (firstData.containsKey('Description')) {
          description = firstData['Description'] ?? '';
        }

        if (firstData.containsKey('Value') &&
            firstData['Value'] is Map &&
            firstData['Value'].containsKey('StringWithMarkup') &&
            firstData['Value']['StringWithMarkup'] is List &&
            firstData['Value']['StringWithMarkup'].isNotEmpty) {
          content = firstData['Value']['StringWithMarkup'][0]['String'] ?? '';
        }

        // Process subtopics if available
        if (firstData.containsKey('Subsection') &&
            firstData['Subsection'] is List) {
          for (final subsection in firstData['Subsection']) {
            if (subsection is Map) {
              subtopics.add(ChemistryTopicContent.fromPugViewAnnotation(
                  Map<String, dynamic>.from(subsection)));
            }
          }
        }
      }
    }

    return ChemistryTopic(
      id: heading.replaceAll(' ', '_').toLowerCase(),
      title: heading,
      description: description,
      content: content,
      subtopics: subtopics.isNotEmpty ? subtopics : null,
      headingKey: heading,
    );
  }
}
