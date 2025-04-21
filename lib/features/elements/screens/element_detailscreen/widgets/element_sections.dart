import 'package:flutter/material.dart';
import '../../../model/periodic_element.dart';
import 'detail_widgets.dart';
import 'property_displays.dart';

/// Widget for the description section
class DescriptionSection extends StatelessWidget {
  final String description;

  const DescriptionSection({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElementDetailSection(
      title: 'Description',
      icon: Icons.description,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Widget for the quick facts section
class QuickFactsSection extends StatelessWidget {
  final PeriodicElement element;

  const QuickFactsSection({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = {
      'Atomic Mass':
          '${DetailFormatter.formatValue(element.formattedAtomicMass)} u',
      'Phase': DetailFormatter.formatValue(element.standardState),
      'Density': '${DetailFormatter.formatValue(element.density)} g/cm³',
      'Atomic Radius':
          '${DetailFormatter.formatValue(element.atomicRadius)} pm',
      'Group Block': DetailFormatter.formatValue(element.groupBlock),
      'Year Discovered': DetailFormatter.formatValue(element.yearDiscovered),
    };

    return ElementDetailSection(
      title: 'Quick Facts',
      icon: Icons.info_outline,
      content: QuickFactsGrid(properties: properties),
    );
  }
}

/// Widget for the discovery information section
class DiscoverySection extends StatelessWidget {
  final PeriodicElement element;
  final Map<String, String> discoveryInfo;

  const DiscoverySection({
    Key? key,
    required this.element,
    required this.discoveryInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = {
      'Discovered By': discoveryInfo['discoveredBy']!,
      'Named By': discoveryInfo['namedBy']!,
      'Year': DetailFormatter.formatValue(element.yearDiscovered),
    };

    return ElementDetailSection(
      title: 'Discovery Information',
      icon: Icons.history_edu,
      content: PropertyList(properties: properties),
    );
  }
}

/// Widget for the electronic properties section
class ElectronicPropertiesSection extends StatelessWidget {
  final PeriodicElement element;

  const ElectronicPropertiesSection({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final properties = {
      'Electron Configuration':
          DetailFormatter.formatValue(element.electronConfiguration),
      'Electronegativity':
          DetailFormatter.formatValue(element.electronegativity),
      'Electron Affinity':
          '${DetailFormatter.formatValue(element.electronAffinity)} eV',
      'Ionization Energy':
          '${DetailFormatter.formatValue(element.ionizationEnergy)} eV',
      'Oxidation States': DetailFormatter.formatValue(element.oxidationStates),
    };

    return ElementDetailSection(
      title: 'Electronic Properties',
      icon: Icons.bolt,
      content: PropertyList(properties: properties),
    );
  }
}

/// Widget for the physical properties section
class PhysicalPropertiesSection extends StatelessWidget {
  final PeriodicElement element;

  const PhysicalPropertiesSection({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateUnit =
        element.standardState.toLowerCase() == "gas" ? "g/L" : "g/cm³";

    final properties = {
      'Standard State': DetailFormatter.formatValue(element.standardState),
      'Density': '${DetailFormatter.formatValue(element.density)} $stateUnit',
      'Melting Point': '${DetailFormatter.formatValue(element.meltingPoint)} K',
      'Boiling Point': '${DetailFormatter.formatValue(element.boilingPoint)} K',
    };

    return ElementDetailSection(
      title: 'Physical Properties',
      icon: Icons.science,
      content: PropertyList(properties: properties),
    );
  }
}
