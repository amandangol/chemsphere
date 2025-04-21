import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../model/periodic_element.dart';
import 'element_flashcard_widgets.dart';
import 'property_widgets.dart';

/// Widget for the front of the element flashcard
class FlashcardFront extends StatelessWidget {
  final PeriodicElement element;
  final Color textColor;

  const FlashcardFront({
    Key? key,
    required this.element,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Big Symbol Watermark
        Positioned(
          right: -30,
          bottom: -40,
          child: Text(
            element.symbol,
            style: GoogleFonts.poppins(
              fontSize: 180,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        // Main Content Area
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Symbol, Number, Phase
              _buildTopSection(),
              const SizedBox(height: 18),

              // Element Configuration
              PropertyRow(
                label: 'E. Config:',
                value:
                    ElementFormatter.formatValue(element.electronConfiguration),
                textColor: textColor,
                icon: ElementIcons.getPropertyIcon('E. Config'),
                useChipStyle: true,
              ),
              const SizedBox(height: 8),

              // Element Properties - Row 1
              Row(
                children: [
                  Expanded(
                    child: PropertyChip(
                      label: 'Radius',
                      value:
                          '${ElementFormatter.formatValue(element.atomicRadius)} pm',
                      textColor: textColor,
                      icon: ElementIcons.getPropertyIcon('Atomic Radius'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: PropertyChip(
                      label: 'EN',
                      value: ElementFormatter.formatValue(
                          element.electronegativity),
                      textColor: textColor,
                      icon: ElementIcons.getPropertyIcon('Electronegativity'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),

              // Element Properties - Row 2
              Row(
                children: [
                  Expanded(
                    child: PropertyChip(
                      label: 'Density',
                      value:
                          '${ElementFormatter.formatValue(element.density)} ${element.standardState.toLowerCase() == "gas" ? "g/L" : "g/cm³"}',
                      textColor: textColor,
                      icon: ElementIcons.getPropertyIcon('Density'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: PropertyChip(
                      label: 'Oxidation',
                      value:
                          ElementFormatter.formatValue(element.oxidationStates),
                      textColor: textColor,
                      icon: ElementIcons.getPropertyIcon('Oxidation States'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Tap Hint
              _buildTapHint(),

              const Spacer(),

              // Bottom Section
              _buildBottomSection(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the top section with symbol, atomic number and state
  Widget _buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          element.symbol,
          style: GoogleFonts.poppins(
            fontSize: 65,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 0.95,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#${element.atomicNumber}',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: textColor.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FaIcon(
                    ElementIcons.getPhaseIcon(
                        ElementFormatter.formatValue(element.standardState)),
                    color: textColor.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ElementFormatter.formatValue(element.standardState),
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build tap hint for card flip
  Widget _buildTapHint() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tap for Details",
            style: GoogleFonts.lato(
              fontSize: 11,
              color: textColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 4),
          FaIcon(
            FontAwesomeIcons.handPointUp,
            color: textColor.withOpacity(0.6),
            size: 12,
          ),
        ],
      ),
    );
  }

  /// Build the bottom section with name, group and mass
  Widget _buildBottomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          element.name,
          style: GoogleFonts.lato(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ElementFormatter.formatValue(element.groupBlock),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: textColor.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ElementFormatter.formatValue(element.formattedAtomicMass)} u',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Text(
              'Discovered: ${ElementFormatter.formatValue(element.yearDiscovered)}',
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
