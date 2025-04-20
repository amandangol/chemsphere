import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'provider/element_provider.dart';
import 'model/periodic_element.dart';
import 'element_detail_screen.dart';
import '../../widgets/chemistry_widgets.dart';

class ModernPeriodicTableScreen extends StatefulWidget {
  const ModernPeriodicTableScreen({Key? key}) : super(key: key);

  @override
  State<ModernPeriodicTableScreen> createState() =>
      _ModernPeriodicTableScreenState();
}

class _ModernPeriodicTableScreenState extends State<ModernPeriodicTableScreen>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  int? _selectedElementId;
  bool _isLoading = false;
  bool _showTableInfo = false;

  // Element cell size and padding
  final double _cellSize = 58.0;
  final double _cellPadding = 1.0;

  // Color scheme for different element categories - using standardized colors
  final Map<String, Color> _categoryColors = {
    'alkali metal': PeriodicElement.getElementColor('alkali metal'),
    'alkaline earth metal':
        PeriodicElement.getElementColor('alkaline earth metal'),
    'transition metal': PeriodicElement.getElementColor('transition metal'),
    'post-transition metal':
        PeriodicElement.getElementColor('post-transition metal'),
    'metalloid': PeriodicElement.getElementColor('metalloid'),
    'nonmetal': PeriodicElement.getElementColor('nonmetal'),
    'halogen': PeriodicElement.getElementColor('halogen'),
    'noble gas': PeriodicElement.getElementColor('noble gas'),
    'lanthanide': PeriodicElement.getElementColor('lanthanide'),
    'actinide': PeriodicElement.getElementColor('actinide'),
  };

  // Mapping to store element positions (periodNumber, groupNumber)
  final Map<int, List<int>> _elementPositions = {
    // Period 1
    1: [1, 1], // H (period, group)
    2: [1, 18], // He

    // Period 2
    3: [2, 1], // Li
    4: [2, 2], // Be
    5: [2, 13], // B
    6: [2, 14], // C
    7: [2, 15], // N
    8: [2, 16], // O
    9: [2, 17], // F
    10: [2, 18], // Ne

    // Period 3
    11: [3, 1], // Na
    12: [3, 2], // Mg
    13: [3, 13], // Al
    14: [3, 14], // Si
    15: [3, 15], // P
    16: [3, 16], // S
    17: [3, 17], // Cl
    18: [3, 18], // Ar

    // Period 4
    19: [4, 1], // K
    20: [4, 2], // Ca
    21: [4, 3], // Sc
    22: [4, 4], // Ti
    23: [4, 5], // V
    24: [4, 6], // Cr
    25: [4, 7], // Mn
    26: [4, 8], // Fe
    27: [4, 9], // Co
    28: [4, 10], // Ni
    29: [4, 11], // Cu
    30: [4, 12], // Zn
    31: [4, 13], // Ga
    32: [4, 14], // Ge
    33: [4, 15], // As
    34: [4, 16], // Se
    35: [4, 17], // Br
    36: [4, 18], // Kr

    // Period 5
    37: [5, 1], // Rb
    38: [5, 2], // Sr
    39: [5, 3], // Y
    40: [5, 4], // Zr
    41: [5, 5], // Nb
    42: [5, 6], // Mo
    43: [5, 7], // Tc
    44: [5, 8], // Ru
    45: [5, 9], // Rh
    46: [5, 10], // Pd
    47: [5, 11], // Ag
    48: [5, 12], // Cd
    49: [5, 13], // In
    50: [5, 14], // Sn
    51: [5, 15], // Sb
    52: [5, 16], // Te
    53: [5, 17], // I
    54: [5, 18], // Xe

    // Period 6
    55: [6, 1], // Cs
    56: [6, 2], // Ba
    57: [6, 3], // La
    72: [6, 4], // Hf
    73: [6, 5], // Ta
    74: [6, 6], // W
    75: [6, 7], // Re
    76: [6, 8], // Os
    77: [6, 9], // Ir
    78: [6, 10], // Pt
    79: [6, 11], // Au
    80: [6, 12], // Hg
    81: [6, 13], // Tl
    82: [6, 14], // Pb
    83: [6, 15], // Bi
    84: [6, 16], // Po
    85: [6, 17], // At
    86: [6, 18], // Rn

    // Period 7
    87: [7, 1], // Fr
    88: [7, 2], // Ra
    89: [7, 3], // Ac
    104: [7, 4], // Rf
    105: [7, 5], // Db
    106: [7, 6], // Sg
    107: [7, 7], // Bh
    108: [7, 8], // Hs
    109: [7, 9], // Mt
    110: [7, 10], // Ds
    111: [7, 11], // Rg
    112: [7, 12], // Cn
    113: [7, 13], // Nh
    114: [7, 14], // Fl
    115: [7, 15], // Mc
    116: [7, 16], // Lv
    117: [7, 17], // Ts
    118: [7, 18], // Og

    // Lanthanides (Period 6, after La)
    58: [8, 4], // Ce
    59: [8, 5], // Pr
    60: [8, 6], // Nd
    61: [8, 7], // Pm
    62: [8, 8], // Sm
    63: [8, 9], // Eu
    64: [8, 10], // Gd
    65: [8, 11], // Tb
    66: [8, 12], // Dy
    67: [8, 13], // Ho
    68: [8, 14], // Er
    69: [8, 15], // Tm
    70: [8, 16], // Yb
    71: [8, 17], // Lu

    // Actinides (Period 7, after Ac)
    90: [9, 4], // Th
    91: [9, 5], // Pa
    92: [9, 6], // U
    93: [9, 7], // Np
    94: [9, 8], // Pu
    95: [9, 9], // Am
    96: [9, 10], // Cm
    97: [9, 11], // Bk
    98: [9, 12], // Cf
    99: [9, 13], // Es
    100: [9, 14], // Fm
    101: [9, 15], // Md
    102: [9, 16], // No
    103: [9, 17], // Lr
  };

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    // Add animation controller
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _animController.forward();

    // Set initial scale and position
    _transformationController.value = Matrix4.identity()..scale(0.8);

    // Fetch elements if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isLoading = true);

      final provider = context.read<ElementProvider>();
      if (provider.elements.isEmpty) {
        provider.fetchFlashcardElements().then((_) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }).catchError((error) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading elements: $error')),
            );
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _selectElement(PeriodicElement element) {
    setState(() {
      _selectedElementId = element.atomicNumber;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ElementDetailScreen(element: element),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedElementId = null;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Interactive Periodic Table',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              setState(() {
                _showTableInfo = !_showTableInfo;
              });
            },
            tooltip: 'Table Information',
          ),
          // Reset view button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _transformationController.value = Matrix4.identity()
                  ..scale(0.8);
                _showTableInfo = false;
              });
            },
            tooltip: 'Reset View',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    // Top legend for element categories
                    AnimationLimiter(
                      child: _buildLegend(),
                    ),

                    // Periodic table info banner (collapsible)
                    if (_showTableInfo) _buildTableInfoBanner(),

                    // Main periodic table with InteractiveViewer
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            constrained: false,
                            minScale: 0.4,
                            maxScale: 2.5,
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Consumer<ElementProvider>(
                                    builder: (context, provider, child) {
                                      if (provider.isLoading) {
                                        return const ChemistryLoadingWidget(
                                          message: 'Loading elements data...',
                                        );
                                      }

                                      if (provider.error != null) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: theme.colorScheme.error,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Error loading elements',
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      theme.colorScheme.error,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                provider.error ??
                                                    'Unknown error',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(),
                                              ),
                                              const SizedBox(height: 24),
                                              ElevatedButton.icon(
                                                onPressed: () => provider
                                                    .fetchFlashcardElements(
                                                        forceRefresh: true),
                                                icon: const Icon(Icons.refresh),
                                                label: const Text('Retry'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Stack(
                                        children: [
                                          _buildPeriodicTable(
                                              provider.elements),
                                          _buildTableDirectionArrows(),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => _buildInfoDialog(),
          );
        },
        tooltip: 'About the Periodic Table',
        child: const Icon(Icons.science_outlined),
      ),
    );
  }

  // Helper method to get period and group from atomic number
  List<int>? _getElementPosition(int atomicNumber) {
    return _elementPositions[atomicNumber];
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Elements are color-coded by category:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Legend items
          AnimationLimiter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 25.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildLegendItem(
                          'Alkali metals', _categoryColors['alkali metal']!),
                      _buildLegendItem('Alkaline earth',
                          _categoryColors['alkaline earth metal']!),
                      _buildLegendItem('Transition metals',
                          _categoryColors['transition metal']!),
                      _buildLegendItem('Post-transition',
                          _categoryColors['post-transition metal']!),
                      _buildLegendItem(
                          'Metalloids', _categoryColors['metalloid']!),
                      _buildLegendItem(
                          'Nonmetals', _categoryColors['nonmetal']!),
                      _buildLegendItem('Halogens', _categoryColors['halogen']!),
                      _buildLegendItem(
                          'Noble gases', _categoryColors['noble gas']!),
                      _buildLegendItem(
                          'Lanthanides', _categoryColors['lanthanide']!),
                      _buildLegendItem(
                          'Actinides', _categoryColors['actinide']!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodicTable(List<PeriodicElement> elements) {
    // Create a grid with 18 columns (for the 18 groups)
    return Stack(
      children: [
        // Background grid pattern
        Container(
          color: Colors.grey.shade50,
        ),

        // Main table
        Table(
          defaultColumnWidth: FixedColumnWidth(_cellSize),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
            verticalInside: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
          ),
          children: _buildTableRows(elements),
        ),
      ],
    );
  }

  List<TableRow> _buildTableRows(List<PeriodicElement> elements) {
    List<TableRow> rows = [];

    // Header row with group numbers (1-18)
    rows.add(
      TableRow(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        children: [
          // Empty top-left cell
          Container(height: 24),
          ...List.generate(
              18,
              (index) => Container(
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  )),
        ],
      ),
    );

    // Build the main 7 periods
    for (int period = 1; period <= 7; period++) {
      List<Widget> rowChildren = [];

      // Period number at the beginning of each row
      rowChildren.add(
        Container(
          height: _cellSize,
          width: 24,
          alignment: Alignment.center,
          color: Colors.grey.shade50,
          child: Text(
            '$period',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );

      // Fill in elements for each group
      for (int group = 1; group <= 18; group++) {
        // Special case for lanthanides and actinides
        if ((period == 6 && group == 3) || (period == 7 && group == 3)) {
          // Period 6, group 3 contains La (57) with asterisk
          // Period 7, group 3 contains Ac (89) with asterisk
          int atomicNumber = period == 6 ? 57 : 89;
          PeriodicElement? element;
          try {
            element =
                elements.firstWhere((e) => e.atomicNumber == atomicNumber);
            rowChildren.add(_buildElementCell(element,
                showAsterisk: true,
                asteriskColor: period == 6
                    ? _categoryColors['lanthanide']!
                    : _categoryColors['actinide']!));
          } catch (e) {
            rowChildren.add(Container(height: _cellSize, color: Colors.white));
          }
          continue;
        }

        // Handle elements in periods 6 and 7 correctly
        if (period == 6 && group >= 4 && group <= 18) {
          // For period 6, we need elements 72-86 in positions 4-18
          int elementNumber = 0;
          if (group >= 4 && group <= 18) {
            elementNumber = 68 +
                group; // Maps group 4 to element 72, group 18 to element 86
          }

          try {
            if (elementNumber > 0) {
              final element =
                  elements.firstWhere((e) => e.atomicNumber == elementNumber);
              rowChildren.add(_buildElementCell(element));
              continue;
            }
          } catch (e) {
            // Element not found, add empty cell below
          }
        } else if (period == 7 && group >= 4 && group <= 18) {
          // For period 7, we need elements 104-118 in positions 4-18
          int elementNumber = 0;
          if (group >= 4 && group <= 18) {
            elementNumber = 100 +
                group; // Maps group 4 to element 104, group 18 to element 118
          }

          try {
            if (elementNumber > 0) {
              final element =
                  elements.firstWhere((e) => e.atomicNumber == elementNumber);
              rowChildren.add(_buildElementCell(element));
              continue;
            }
          } catch (e) {
            // Element not found, add empty cell below
          }
        }

        // Regular elements for all other positions
        PeriodicElement? element = _findElementAt(elements, period, group);
        if (element != null) {
          rowChildren.add(_buildElementCell(element));
        } else {
          // Empty cell
          rowChildren.add(Container(
            height: _cellSize,
            color: Colors.white,
          ));
        }
      }

      rows.add(TableRow(children: rowChildren));
    }

    // Add a spacer row
    rows.add(
      TableRow(
        children: List.generate(
          19,
          (index) => Container(
            height: 12,
            color: Colors.grey.shade50,
          ),
        ),
      ),
    );

    // Add Lanthanide header section
    rows.add(
      TableRow(
        children: [
          // Empty cell in first column
          Container(
            height: 24,
            color: Colors.grey.shade50,
          ),
          // Lanthanide indicator cell
          Container(
            height: 24,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: _categoryColors['lanthanide']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _categoryColors['lanthanide']!.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              'Lanthanides (Period 6)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _categoryColors['lanthanide'],
              ),
            ),
          ),
          // Fill remaining columns
          ...List.generate(
            17,
            (index) => Container(
              height: 24,
              color: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );

    // Add lanthanide row (57-71)
    rows.add(_buildLanthanideActinideRow(elements, true));

    // Spacer row
    rows.add(
      TableRow(
        children: List.generate(
          19,
          (index) => Container(
            height: 8,
            color: Colors.grey.shade50,
          ),
        ),
      ),
    );

    // Add Actinide header section
    rows.add(
      TableRow(
        children: [
          // Empty cell in first column
          Container(
            height: 24,
            color: Colors.grey.shade50,
          ),
          // Actinide indicator cell
          Container(
            height: 24,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: _categoryColors['actinide']!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _categoryColors['actinide']!.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              'Actinides (Period 7)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _categoryColors['actinide'],
              ),
            ),
          ),
          // Fill remaining columns
          ...List.generate(
            17,
            (index) => Container(
              height: 24,
              color: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );

    // Add actinide row (89-103)
    rows.add(_buildLanthanideActinideRow(elements, false));

    return rows;
  }

  // Build a row for lanthanides or actinides
  TableRow _buildLanthanideActinideRow(
      List<PeriodicElement> elements, bool isLanthanide) {
    List<Widget> cells = [];

    // Period marker (empty for cleaner look)
    cells.add(Container(
      height: _cellSize,
      width: 24,
      color: Colors.grey.shade50,
    ));

    // First cell is empty for proper alignment
    cells.add(Container(
      height: _cellSize,
      color: Colors.grey.shade50,
    ));

    // Get the start and end element numbers
    int startNum = isLanthanide ? 58 : 90; // Ce (58) or Th (90)
    int endNum = isLanthanide ? 71 : 103; // Lu (71) or Lr (103)

    // Add cells for each element in the series
    for (int atomicNum = startNum; atomicNum <= endNum; atomicNum++) {
      try {
        final element = elements.firstWhere((e) => e.atomicNumber == atomicNum);
        cells.add(_buildElementCell(element));
      } catch (e) {
        // Element not found
        cells.add(Container(
          height: _cellSize,
          color: Colors.grey.shade100,
          child: Center(
            child: Text(
              '?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ));
      }
    }

    // Fill any remaining cells
    while (cells.length < 19) {
      cells.add(Container(
        height: _cellSize,
        color: Colors.white,
      ));
    }

    return TableRow(children: cells);
  }

  Widget _buildElementCell(PeriodicElement element,
      {bool showAsterisk = false, Color? asteriskColor}) {
    // Use the element's standardized color
    Color elementColor = element.standardColor;
    final bool isSelected = _selectedElementId == element.atomicNumber;

    return Container(
      padding: EdgeInsets.all(_cellPadding),
      height: 68,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to element details page
            _selectElement(element);
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: isSelected ? 1.1 : 1.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Stack(
                  children: [
                    // Element container
                    Positioned.fill(
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              elementColor,
                              elementColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: elementColor
                                  .withOpacity(isSelected ? 0.5 : 0.3),
                              blurRadius: isSelected ? 4 : 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          borderRadius:
                              BorderRadius.circular(isSelected ? 6 : 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Atomic number
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${element.atomicNumber}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Element symbol
                              Text(
                                element.symbol,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Element name
                              Text(
                                element.name,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
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

                    // Asterisk for lanthanide/actinide reference
                    if (showAsterisk && asteriskColor != null)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Text(
                          element.atomicNumber == 57 ? '*' : '**',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PeriodicElement? _findElementAt(
      List<PeriodicElement> elements, int period, int group) {
    try {
      // Reverse lookup - find atomic number for this position
      int? atomicNumber;
      _elementPositions.forEach((number, pos) {
        if (pos[0] == period && pos[1] == group) {
          atomicNumber = number;
        }
      });

      // If we found the atomic number for this position, look for the element
      if (atomicNumber != null) {
        for (var element in elements) {
          if (element.atomicNumber == atomicNumber) {
            return element;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error finding element: $e');
      return null;
    }
  }

  Widget _buildTableDirectionArrows() {
    return Container(
      width: 300,
      height: 400,
      child: Stack(
        // Add fit property to ensure children don't overflow
        fit: StackFit.loose,
        children: [
          // Group (vertical) arrow with description
          Positioned(
            top: 60,
            left: 40,
            child: Column(
              children: [
                Text(
                  'Groups (Columns)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Container(
                  height: 160,
                  width: 100,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          // Make sure this inner Stack has bounds
                          clipBehavior: Clip.none,
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              size: const Size(100, 140),
                              painter: ArrowPainter(
                                start: const Offset(50, 10),
                                end: const Offset(50, 120),
                                color: Colors.blue.shade800,
                                arrowSize: 10,
                              ),
                            ),
                            Positioned(
                              top: 55,
                              left: 60,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.blue.shade200, width: 1),
                                ),
                                child: Text(
                                  'Similar\nProperties',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Elements in same group have similar chemical properties',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            color: Colors.blue.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Period (horizontal) arrow with description
          Positioned(
            top: 260,
            left: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periods (Rows)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                Container(
                  width: 220,
                  height: 100,
                  child: Stack(
                    // Add fit property to this inner Stack too
                    fit: StackFit.loose,
                    children: [
                      CustomPaint(
                        size: const Size(190, 50),
                        painter: ArrowPainter(
                          start: const Offset(10, 25),
                          end: const Offset(170, 25),
                          color: Colors.red.shade800,
                          arrowSize: 10,
                          isHorizontal: true,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.red.shade200, width: 1),
                          ),
                          child: Text(
                            'Increasing Atomic Number',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 10,
                        child: Container(
                          width: 180,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Elements in same period have same number of electron shells',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: Colors.red.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                'Modern Periodic Table',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue.shade900,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _showTableInfo = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The modern periodic table organizes elements by increasing atomic number (number of protons). Elements are arranged in 18 groups (columns) and 7 periods (rows), with lanthanides and actinides placed separately below. This arrangement reveals patterns in electron configurations and chemical properties.',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDialog() {
    return AlertDialog(
      title: Text(
        'Modern vs. Mendeleev\'s Periodic Table',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Historical background section
            Text(
              'Historical Background',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'In 1869, Russian chemist Dmitri Mendeleev created the first widely recognized periodic table. He organized elements by increasing atomic weight and grouped them based on similar properties, leaving gaps for undiscovered elements. His predictions of these missing elements and their properties proved remarkably accurate.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Key Differences section
            Text(
              'Key Differences',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Organizing principle
            _buildComparisonItem(
                'Organizing Principle:',
                'Mendeleev: Arranged by atomic weight (mass)',
                'Modern: Arranged by atomic number (protons)'),
            _buildComparisonItem(
                'Structure:',
                'Mendeleev: 8 groups with some inconsistencies',
                'Modern: 18 groups with systematic arrangement'),
            _buildComparisonItem(
                'Predictive Ability:',
                'Mendeleev: Left gaps for undiscovered elements',
                'Modern: Based on electron configuration theory'),
            _buildComparisonItem(
                'Element Placement:',
                'Mendeleev: Some elements misplaced due to atomic weight',
                'Modern: Resolves inversions (like Te/I, Co/Ni) properly'),
            _buildComparisonItem(
                'Special Elements:',
                'Mendeleev: No specific provisions for lanthanides/actinides',
                'Modern: Separates lanthanides/actinides into dedicated rows'),

            const SizedBox(height: 16),

            // Scientific advancements section
            Text(
              'Scientific Advancements',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The modern periodic table evolved after the discovery of atomic structure and quantum theory. Henry Moseley\'s work in 1913 identified that elements should be arranged by atomic number rather than mass. This reorganization resolved inconsistencies in Mendeleev\'s table and provided a theoretical foundation based on electron configurations.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),

            const SizedBox(height: 16),

            // Benefits of modern table section
            Text(
              'Benefits of the Modern Table',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
                'Accurately predicts physical and chemical properties'),
            _buildBulletPoint('Reflects electronic structure of atoms'),
            _buildBulletPoint(
                'Organizes elements into blocks (s, p, d, f) based on orbitals'),
            _buildBulletPoint(
                'Includes all discovered elements (currently 118)'),
            _buildBulletPoint(
                'Groups elements with similar valence electron configurations'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  // Enhanced comparison item with old vs new format
  Widget _buildComparisonItem(String title, String oldTable, String newTable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 2, right: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  oldTable,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 2, right: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  newTable,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bullet point helper
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 6),
            decoration: BoxDecoration(
              color: Colors.indigo.shade400,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Add a custom arrow painter for direction indicators
class ArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;
  final double arrowSize;
  final bool isHorizontal;

  ArrowPainter({
    required this.start,
    required this.end,
    required this.color,
    this.arrowSize = 10,
    this.isHorizontal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw the line
    canvas.drawLine(start, end, paint);

    // Draw the arrow head
    final path = Path();

    if (isHorizontal) {
      // Arrow pointing right
      path.moveTo(end.dx - arrowSize, end.dy - arrowSize / 2);
      path.lineTo(end.dx, end.dy);
      path.lineTo(end.dx - arrowSize, end.dy + arrowSize / 2);
    } else {
      // Arrow pointing down
      path.moveTo(end.dx - arrowSize / 2, end.dy - arrowSize);
      path.lineTo(end.dx, end.dy);
      path.lineTo(end.dx + arrowSize / 2, end.dy - arrowSize);
    }

    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
