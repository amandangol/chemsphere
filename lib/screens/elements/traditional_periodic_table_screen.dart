import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/element_provider.dart';
import '../../models/element.dart' as element_model;
import 'element_detail_screen.dart';
import 'dart:math';
import '../../widgets/chemistry_widgets.dart';

// Map of atomic numbers to their proper positions in the periodic table
class PeriodicTablePosition {
  final int period;
  final int group;
  PeriodicTablePosition(this.period, this.group);
}

class TraditionalPeriodicTableScreen extends StatefulWidget {
  const TraditionalPeriodicTableScreen({Key? key}) : super(key: key);

  @override
  State<TraditionalPeriodicTableScreen> createState() =>
      _TraditionalPeriodicTableScreenState();
}

class _TraditionalPeriodicTableScreenState
    extends State<TraditionalPeriodicTableScreen> {
  // Zoom and pan controllers
  late TransformationController _transformationController;
  double _initialScale = 1.0;
  bool _showInfoPanel = false; // Control the educational panel visibility

  // Define the grid dimensions for the periodic table
  final int _maxPeriod = 7; // Standard table has 7 periods
  final int _maxGroup = 18; // Standard table has 18 groups

  // Layout constants
  final double _elementSize = 70.0;
  final double _cellPadding = 2.0;

  // Periodic table element positions mapped by atomic number
  final Map<int, PeriodicTablePosition> _elementPositions = {
    // Period 1
    1: PeriodicTablePosition(1, 1), // H
    2: PeriodicTablePosition(1, 18), // He

    // Period 2
    3: PeriodicTablePosition(2, 1), // Li
    4: PeriodicTablePosition(2, 2), // Be
    5: PeriodicTablePosition(2, 13), // B
    6: PeriodicTablePosition(2, 14), // C
    7: PeriodicTablePosition(2, 15), // N
    8: PeriodicTablePosition(2, 16), // O
    9: PeriodicTablePosition(2, 17), // F
    10: PeriodicTablePosition(2, 18), // Ne

    // Period 3
    11: PeriodicTablePosition(3, 1), // Na
    12: PeriodicTablePosition(3, 2), // Mg
    13: PeriodicTablePosition(3, 13), // Al
    14: PeriodicTablePosition(3, 14), // Si
    15: PeriodicTablePosition(3, 15), // P
    16: PeriodicTablePosition(3, 16), // S
    17: PeriodicTablePosition(3, 17), // Cl
    18: PeriodicTablePosition(3, 18), // Ar

    // Period 4
    19: PeriodicTablePosition(4, 1), // K
    20: PeriodicTablePosition(4, 2), // Ca
    21: PeriodicTablePosition(4, 3), // Sc
    22: PeriodicTablePosition(4, 4), // Ti
    23: PeriodicTablePosition(4, 5), // V
    24: PeriodicTablePosition(4, 6), // Cr
    25: PeriodicTablePosition(4, 7), // Mn
    26: PeriodicTablePosition(4, 8), // Fe
    27: PeriodicTablePosition(4, 9), // Co
    28: PeriodicTablePosition(4, 10), // Ni
    29: PeriodicTablePosition(4, 11), // Cu
    30: PeriodicTablePosition(4, 12), // Zn
    31: PeriodicTablePosition(4, 13), // Ga
    32: PeriodicTablePosition(4, 14), // Ge
    33: PeriodicTablePosition(4, 15), // As
    34: PeriodicTablePosition(4, 16), // Se
    35: PeriodicTablePosition(4, 17), // Br
    36: PeriodicTablePosition(4, 18), // Kr

    // Period 5
    37: PeriodicTablePosition(5, 1), // Rb
    38: PeriodicTablePosition(5, 2), // Sr
    39: PeriodicTablePosition(5, 3), // Y
    40: PeriodicTablePosition(5, 4), // Zr
    41: PeriodicTablePosition(5, 5), // Nb
    42: PeriodicTablePosition(5, 6), // Mo
    43: PeriodicTablePosition(5, 7), // Tc
    44: PeriodicTablePosition(5, 8), // Ru
    45: PeriodicTablePosition(5, 9), // Rh
    46: PeriodicTablePosition(5, 10), // Pd
    47: PeriodicTablePosition(5, 11), // Ag
    48: PeriodicTablePosition(5, 12), // Cd
    49: PeriodicTablePosition(5, 13), // In
    50: PeriodicTablePosition(5, 14), // Sn
    51: PeriodicTablePosition(5, 15), // Sb
    52: PeriodicTablePosition(5, 16), // Te
    53: PeriodicTablePosition(5, 17), // I
    54: PeriodicTablePosition(5, 18), // Xe

    // Period 6
    55: PeriodicTablePosition(6, 1), // Cs
    56: PeriodicTablePosition(6, 2), // Ba
    57: PeriodicTablePosition(6, 3), // La (also in lanthanide series)
    72: PeriodicTablePosition(6, 4), // Hf
    73: PeriodicTablePosition(6, 5), // Ta
    74: PeriodicTablePosition(6, 6), // W
    75: PeriodicTablePosition(6, 7), // Re
    76: PeriodicTablePosition(6, 8), // Os
    77: PeriodicTablePosition(6, 9), // Ir
    78: PeriodicTablePosition(6, 10), // Pt
    79: PeriodicTablePosition(6, 11), // Au
    80: PeriodicTablePosition(6, 12), // Hg
    81: PeriodicTablePosition(6, 13), // Tl
    82: PeriodicTablePosition(6, 14), // Pb
    83: PeriodicTablePosition(6, 15), // Bi
    84: PeriodicTablePosition(6, 16), // Po
    85: PeriodicTablePosition(6, 17), // At
    86: PeriodicTablePosition(6, 18), // Rn

    // Period 7
    87: PeriodicTablePosition(7, 1), // Fr
    88: PeriodicTablePosition(7, 2), // Ra
    89: PeriodicTablePosition(7, 3), // Ac (also in actinide series)
    104: PeriodicTablePosition(7, 4), // Rf
    105: PeriodicTablePosition(7, 5), // Db
    106: PeriodicTablePosition(7, 6), // Sg
    107: PeriodicTablePosition(7, 7), // Bh
    108: PeriodicTablePosition(7, 8), // Hs
    109: PeriodicTablePosition(7, 9), // Mt
    110: PeriodicTablePosition(7, 10), // Ds
    111: PeriodicTablePosition(7, 11), // Rg
    112: PeriodicTablePosition(7, 12), // Cn
    113: PeriodicTablePosition(7, 13), // Nh
    114: PeriodicTablePosition(7, 14), // Fl
    115: PeriodicTablePosition(7, 15), // Mc
    116: PeriodicTablePosition(7, 16), // Lv
    117: PeriodicTablePosition(7, 17), // Ts
    118: PeriodicTablePosition(7, 18), // Og

    // Lanthanides (Period 6, special row)
    58: PeriodicTablePosition(8, 4), // Ce
    59: PeriodicTablePosition(8, 5), // Pr
    60: PeriodicTablePosition(8, 6), // Nd
    61: PeriodicTablePosition(8, 7), // Pm
    62: PeriodicTablePosition(8, 8), // Sm
    63: PeriodicTablePosition(8, 9), // Eu
    64: PeriodicTablePosition(8, 10), // Gd
    65: PeriodicTablePosition(8, 11), // Tb
    66: PeriodicTablePosition(8, 12), // Dy
    67: PeriodicTablePosition(8, 13), // Ho
    68: PeriodicTablePosition(8, 14), // Er
    69: PeriodicTablePosition(8, 15), // Tm
    70: PeriodicTablePosition(8, 16), // Yb
    71: PeriodicTablePosition(8, 17), // Lu

    // Actinides (Period 7, special row)
    90: PeriodicTablePosition(9, 4), // Th
    91: PeriodicTablePosition(9, 5), // Pa
    92: PeriodicTablePosition(9, 6), // U
    93: PeriodicTablePosition(9, 7), // Np
    94: PeriodicTablePosition(9, 8), // Pu
    95: PeriodicTablePosition(9, 9), // Am
    96: PeriodicTablePosition(9, 10), // Cm
    97: PeriodicTablePosition(9, 11), // Bk
    98: PeriodicTablePosition(9, 12), // Cf
    99: PeriodicTablePosition(9, 13), // Es
    100: PeriodicTablePosition(9, 14), // Fm
    101: PeriodicTablePosition(9, 15), // Md
    102: PeriodicTablePosition(9, 16), // No
    103: PeriodicTablePosition(9, 17), // Lr
  };

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    // Fetch elements if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ElementProvider>();
      if (provider.elements.isEmpty) {
        provider.fetchElements();
      }

      // Initialize the table position after first frame
      _resetTablePosition();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // Get correct period and group for an element
  PeriodicTablePosition? getElementPosition(element_model.Element element) {
    return _elementPositions[element.number];
  }

  // Function to reset and center the table view
  void _resetTablePosition() {
    final screenSize = MediaQuery.of(context).size;

    // Calculate a scale that fits all elements
    _initialScale = min(
        (screenSize.width /
                ((_maxGroup + 1) * (_elementSize + _cellPadding * 2))) *
            0.8,
        (screenSize.height /
                ((_maxPeriod + 4) * (_elementSize + _cellPadding * 2))) *
            0.8);

    // Cap the scale to reasonable values
    if (_initialScale > 1.0) _initialScale = 1.0;
    if (_initialScale < 0.12) _initialScale = 0.12;

    // Calculate offset to center the table
    final double centerX = (screenSize.width -
            ((_maxGroup + 1) *
                (_elementSize + _cellPadding * 2) *
                _initialScale)) /
        2;
    final double centerY = (screenSize.height -
            ((_maxPeriod + 4) *
                (_elementSize + _cellPadding * 2) *
                _initialScale)) /
        2;

    // Create a transformation matrix that combines scaling and translation
    final Matrix4 matrix = Matrix4.identity()
      ..scale(_initialScale)
      ..translate(centerX / _initialScale, centerY / _initialScale);

    setState(() {
      _transformationController.value = matrix;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Adjust initial scale based on screen size to ensure the table fits completely
    _initialScale = (screenSize.width /
            ((_maxGroup + 1) * (_elementSize + _cellPadding * 2))) *
        0.8;

    // Cap the scale to reasonable values
    if (_initialScale > 1.0) _initialScale = 1.0;
    if (_initialScale < 0.15) _initialScale = 0.15;

    // Set transformation matrix with initial scale
    if (_transformationController.value.getMaxScaleOnAxis() == 1.0) {
      _transformationController.value = Matrix4.identity()
        ..scale(_initialScale);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Traditional Periodic Table',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // Toggle educational panel
          IconButton(
            icon: Icon(_showInfoPanel ? Icons.info : Icons.info_outline,
                color: theme.colorScheme.onPrimary),
            tooltip: 'Toggle Info Panel',
            onPressed: () {
              setState(() {
                _showInfoPanel = !_showInfoPanel;
              });
            },
          ),
          // Show legend button
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Element Categories',
            onPressed: () {
              _showLegend(context);
            },
          ),
          // Show help
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Table Guide',
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      // Body with info panel and periodic table
      body: Column(
        children: [
          // Educational Info Panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showInfoPanel ? null : 0,
            child: _showInfoPanel
                ? _buildInfoPanel(theme)
                : const SizedBox.shrink(),
          ),

          // Main periodic table view
          Expanded(
            child: Stack(
              children: [
                Consumer<ElementProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const ChemistryLoadingWidget(
                        message: 'Loading elements data...',
                      );
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${provider.error}',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                provider.fetchElements(forceRefresh: true);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.elements.isEmpty) {
                      return const Center(child: Text('No elements found'));
                    }

                    // Build the periodic table
                    return _buildPeriodicTable(provider.elements);
                  },
                ),
                // Educational overlay in top-right with improved design
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.tertiaryContainer.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Groups →',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Periods ↓',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_downward,
                              size: 14,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating mini-legend at the bottom
      bottomNavigationBar: Container(
        color: theme.colorScheme.background,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMiniLegendItem(const Color(0xFFF44336), 'Metals'),
            _buildMiniLegendItem(const Color(0xFF9C27B0), 'Metalloids'),
            _buildMiniLegendItem(const Color(0xFF4CAF50), 'Nonmetals'),
            _buildMiniLegendItem(const Color(0xFF2196F3), 'Noble Gases'),
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: _resetTablePosition,
              tooltip: 'Reset View',
            ),
          ],
        ),
      ),
    );
  }

  // New widget for the educational info panel
  Widget _buildInfoPanel(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Understanding the Traditional Periodic Table',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The periodic table arranges elements by atomic number (number of protons) and groups elements with similar properties in columns.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInfoCard(
                    'Atomic Number', 'Number of protons in the nucleus'),
                _buildInfoCard(
                    'Symbol', 'Chemical abbreviation of the element'),
                _buildInfoCard('Element Name', 'Full name of the element'),
                _buildInfoCard('Atomic Mass', 'Average mass of all isotopes'),
                _buildInfoCard('Group', 'Vertical column; similar properties'),
                _buildInfoCard('Period', 'Horizontal row; same electron shell'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small info cards for key terminology
  Widget _buildInfoCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 150,
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini legend items for the bottom bar
  Widget _buildMiniLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Improved periodic table widget
  Widget _buildPeriodicTable(List<element_model.Element> elements) {
    // Total grid size with extra space for better visibility
    final double tableWidth =
        (_maxGroup + 2) * (_elementSize + _cellPadding * 2);
    final double tableHeight =
        (_maxPeriod + 4) * (_elementSize + _cellPadding * 2);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade50, // Lighter background
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin:
                const EdgeInsets.all(500), // Larger boundary for better panning
            minScale: 0.1,
            maxScale: 3.0,
            constrained:
                false, // Allow the content to be larger than the viewport
            child: Center(
              child: Container(
                width: tableWidth,
                height: tableHeight,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // Place each element in its correct position using our position mapping
                    ...elements.map((element) {
                      final position = getElementPosition(element);
                      if (position != null) {
                        // Don't place lanthanides and actinides in main table if they're in special rows
                        if ((element.number >= 58 && element.number <= 71) ||
                            (element.number >= 90 && element.number <= 103)) {
                          // These will be placed in special rows below
                          return const SizedBox.shrink();
                        }
                        return _buildElementCell(element,
                            fixedPeriod: position.period,
                            fixedGroup: position.group);
                      } else {
                        return const SizedBox.shrink();
                      }
                    }).toList(),

                    // Special handling for lanthanides (period 8, groups 3-16)
                    Positioned(
                      left: 3 * (_elementSize + _cellPadding * 2),
                      top: 8 * (_elementSize + _cellPadding * 2),
                      child: Container(
                        width: (_elementSize + _cellPadding * 2),
                        height: (_elementSize + _cellPadding * 2) / 2,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.lightBlue, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'Lanthanides',
                            style: TextStyle(
                                fontSize: 8, color: Colors.blue.shade800),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // Special handling for actinides (period 9, groups 3-16)
                    Positioned(
                      left: 3 * (_elementSize + _cellPadding * 2),
                      top: 9 * (_elementSize + _cellPadding * 2),
                      child: Container(
                        width: (_elementSize + _cellPadding * 2),
                        height: (_elementSize + _cellPadding * 2) / 2,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'Actinides',
                            style: TextStyle(
                                fontSize: 8, color: Colors.purple.shade800),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    // Place lanthanum in its position and in special row
                    ...elements.where((e) => e.number == 57).map((e) => Stack(
                          children: [
                            _buildElementCell(e, fixedPeriod: 6, fixedGroup: 3),
                            _buildElementCell(e, fixedPeriod: 8, fixedGroup: 3),
                          ],
                        )),

                    // Place actinium in its position and in special row
                    ...elements.where((e) => e.number == 89).map((e) => Stack(
                          children: [
                            _buildElementCell(e, fixedPeriod: 7, fixedGroup: 3),
                            _buildElementCell(e, fixedPeriod: 9, fixedGroup: 3),
                          ],
                        )),

                    // Place lanthanides in the special row
                    ...elements
                        .where((e) => e.number >= 58 && e.number <= 71)
                        .map((e) {
                      final position = getElementPosition(e);
                      if (position != null) {
                        return _buildElementCell(e,
                            fixedPeriod: position.period,
                            fixedGroup: position.group);
                      }
                      return const SizedBox.shrink();
                    }),

                    // Place actinides in the special row
                    ...elements
                        .where((e) => e.number >= 90 && e.number <= 103)
                        .map((e) {
                      final position = getElementPosition(e);
                      if (position != null) {
                        return _buildElementCell(e,
                            fixedPeriod: position.period,
                            fixedGroup: position.group);
                      }
                      return const SizedBox.shrink();
                    }),

                    // Add period labels (1-7)
                    ...List.generate(7, (index) {
                      return Positioned(
                        left: 0,
                        top: (index + 1) * (_elementSize + _cellPadding * 2),
                        child: Container(
                          width: _elementSize / 2,
                          height: _elementSize,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Add group labels (1-18)
                    ...List.generate(18, (index) {
                      return Positioned(
                        left: (index + 1) * (_elementSize + _cellPadding * 2),
                        top: 0,
                        child: Container(
                          width: _elementSize,
                          height: _elementSize / 2,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Improved zoom controls with better visual design
        Positioned(
          bottom: 70,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomInBtn",
                  onPressed: () {
                    final Matrix4 matrix =
                        _transformationController.value.clone();
                    matrix.scale(1.2); // Zoom in by 20%
                    _transformationController.value = matrix;
                  },
                  tooltip: 'Zoom In',
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  width: 20,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(height: 4),
                FloatingActionButton.small(
                  heroTag: "zoomOutBtn",
                  onPressed: () {
                    final Matrix4 matrix =
                        _transformationController.value.clone();
                    matrix.scale(0.8); // Zoom out by 20%
                    _transformationController.value = matrix;
                  },
                  tooltip: 'Zoom Out',
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Improved element cell design
  Widget _buildElementCell(element_model.Element element,
      {int? specialRow,
      int? specialColumn,
      int? fixedPeriod,
      int? fixedGroup}) {
    // Calculate position
    double left;
    double top;

    // Handle special positioning for lanthanides and actinides
    if (specialRow != null && specialColumn != null) {
      left = specialColumn * (_elementSize + _cellPadding * 2);
      top = specialRow * (_elementSize + _cellPadding * 2);
    }
    // Handle fixed positioning based on provided period and group
    else if (fixedPeriod != null && fixedGroup != null) {
      left = fixedGroup * (_elementSize + _cellPadding * 2);
      top = fixedPeriod * (_elementSize + _cellPadding * 2);
    }
    // Fallback to element's own period and group (if available)
    else {
      left = element.group * (_elementSize + _cellPadding * 2);
      top = element.period * (_elementSize + _cellPadding * 2);
    }

    // Get color based on element category
    Color elementColor = _getColorForCategory(element.category);

    return Positioned(
      left: left,
      top: top,
      child: Padding(
        padding: EdgeInsets.all(_cellPadding),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to element details
              context
                  .read<ElementProvider>()
                  .fetchElementDetails(element.symbol);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ElementDetailScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    elementColor.withOpacity(0.2),
                    elementColor.withOpacity(0.1),
                  ],
                ),
                border: Border.all(color: elementColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: elementColor.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              width: _elementSize,
              height: _elementSize,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Atomic number
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '${element.number}',
                        style: TextStyle(
                          fontSize: 10,
                          color: elementColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Symbol and name (center)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          element.symbol,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          element.name,
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Atomic mass
                    Text(
                      _formatAtomicMass(element.atomicMass),
                      style: GoogleFonts.robotoMono(
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAtomicMass(double mass) {
    if (mass <= 0) {
      return "N/A";
    }
    String formatted = mass.toStringAsFixed(2);
    while (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return formatted;
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'diatomic nonmetal':
        return const Color(0xFF00C853); // Bright green
      case 'polyatomic nonmetal':
        return const Color(0xFF4CAF50); // Green
      case 'alkali metal':
        return const Color(0xFFF44336); // Red
      case 'alkaline earth metal':
        return const Color(0xFFFF9800); // Orange
      case 'transition metal':
        return const Color(0xFFFFD600); // Yellow
      case 'metalloid':
        return const Color(0xFF9C27B0); // Purple
      case 'halogen':
        return const Color(0xFF29B6F6); // Light Blue
      case 'noble gas':
        return const Color(0xFF2196F3); // Blue
      case 'lanthanide':
        return const Color(0xFFE91E63); // Pink
      case 'actinide':
        return const Color(0xFF673AB7); // Deep Purple
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Helper method to show legend
  void _showLegend(BuildContext context) {
    final theme = Theme.of(context);

    // Define categories with colors and descriptions
    final categories = [
      {
        'name': 'Alkali Metal',
        'color': const Color(0xFFF44336),
        'description': 'Highly reactive metals in Group 1',
      },
      {
        'name': 'Alkaline Earth Metal',
        'color': const Color(0xFFFF9800),
        'description': 'Reactive metals in Group 2',
      },
      {
        'name': 'Transition Metal',
        'color': const Color(0xFFFFD600),
        'description': 'Metals in the middle of the periodic table',
      },
      {
        'name': 'Metalloid',
        'color': const Color(0xFF9C27B0),
        'description': 'Elements with properties of both metals and nonmetals',
      },
      {
        'name': 'Polyatomic Nonmetal',
        'color': const Color(0xFF4CAF50),
        'description': 'Nonmetals that form molecules with multiple atoms',
      },
      {
        'name': 'Diatomic Nonmetal',
        'color': const Color(0xFF00C853),
        'description': 'Nonmetals that form diatomic molecules',
      },
      {
        'name': 'Noble Gas',
        'color': const Color(0xFF2196F3),
        'description': 'Unreactive gases in Group 18',
      },
      {
        'name': 'Halogen',
        'color': const Color(0xFF29B6F6),
        'description': 'Highly reactive nonmetals in Group 17',
      },
      {
        'name': 'Lanthanide',
        'color': const Color(0xFFE91E63),
        'description': 'Rare earth elements (Period 6)',
      },
      {
        'name': 'Actinide',
        'color': const Color(0xFF673AB7),
        'description': 'Radioactive elements (Period 7)',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Element Categories',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: category['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'] as String,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            category['description'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to show info dialog
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.science,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'About the Periodic Table',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The periodic table is organized by:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Periods (rows): Elements in the same period have the same number of electron shells',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '• Groups (columns): Elements in the same group have similar chemical properties',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'How to use this view:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Pinch to zoom in/out\n• Drag to pan around\n• Tap on any element to see detailed information\n• Use the legend to identify element categories',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'The lanthanides and actinides are displayed separately at the bottom of the table for better visibility.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}
