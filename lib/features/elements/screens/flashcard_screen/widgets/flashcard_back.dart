import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/periodic_element.dart';
import 'element_flashcard_widgets.dart';
import 'property_widgets.dart';

/// Widget for the back of the element flashcard
class FlashcardBack extends StatelessWidget {
  final PeriodicElement element;
  final Color textColor;

  const FlashcardBack({
    Key? key,
    required this.element,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 14.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details: ${element.name}',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.9),
              ),
            ),
            Divider(
              height: 14,
              thickness: 0.5,
              color: textColor.withOpacity(0.3),
            ),
            _buildPropertyList(),
          ],
        ),
      ),
    );
  }

  /// Build the list of element properties
  Widget _buildPropertyList() {
    return Column(
      children: [
        PropertyItem(
          label: 'Atomic Mass',
          value:
              '${ElementFormatter.formatValue(element.formattedAtomicMass)} u',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Atomic Mass'),
        ),
        PropertyItem(
          label: 'Standard State',
          value: ElementFormatter.formatValue(element.standardState),
          textColor: textColor,
          icon: ElementIcons.getPhaseIcon(
              ElementFormatter.formatValue(element.standardState)),
        ),
        PropertyItem(
          label: 'E. Config',
          value: ElementFormatter.formatValue(element.electronConfiguration),
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('E. Config'),
          allowWrap: true,
        ),
        PropertyItem(
          label: 'Electronegativity',
          value: ElementFormatter.formatValue(element.electronegativity),
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Electronegativity'),
        ),
        PropertyItem(
          label: 'Atomic Radius',
          value: '${ElementFormatter.formatValue(element.atomicRadius)} pm',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Atomic Radius'),
        ),
        PropertyItem(
          label: 'Ionization Energy',
          value: '${ElementFormatter.formatValue(element.ionizationEnergy)} eV',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Ionization Energy'),
        ),
        PropertyItem(
          label: 'Electron Affinity',
          value: '${ElementFormatter.formatValue(element.electronAffinity)} eV',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Electron Affinity'),
        ),
        PropertyItem(
          label: 'Oxidation States',
          value: ElementFormatter.formatValue(element.oxidationStates),
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Oxidation States'),
          allowWrap: true,
        ),
        PropertyItem(
          label: 'Density',
          value:
              '${ElementFormatter.formatValue(element.density)} ${element.standardState.toLowerCase() == "gas" ? "g/L" : "g/cm³"}',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Density'),
        ),
        PropertyItem(
          label: 'Melting Point',
          value: '${ElementFormatter.formatValue(element.meltingPoint)} K',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Melting Point'),
        ),
        PropertyItem(
          label: 'Boiling Point',
          value: '${ElementFormatter.formatValue(element.boilingPoint)} K',
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Boiling Point'),
        ),
        PropertyItem(
          label: 'Year Discovered',
          value: ElementFormatter.formatValue(element.yearDiscovered),
          textColor: textColor,
          icon: ElementIcons.getPropertyIcon('Year Discovered'),
        ),
      ],
    );
  }
}
