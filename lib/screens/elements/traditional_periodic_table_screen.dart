import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'provider/element_provider.dart';
import 'model/periodic_element.dart';
import 'element_detail_screen.dart';
import '../../widgets/chemistry_widgets.dart';

class TraditionalPeriodicTableScreen extends StatefulWidget {
  const TraditionalPeriodicTableScreen({Key? key}) : super(key: key);

  @override
  State<TraditionalPeriodicTableScreen> createState() =>
      _TraditionalPeriodicTableScreenState();
}

class _TraditionalPeriodicTableScreenState
    extends State<TraditionalPeriodicTableScreen>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  int? _selectedElementId;
  bool _isLoading = false;

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
          'Periodic Table',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Reset view button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _transformationController.value = Matrix4.identity()
                  ..scale(0.8);
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
                            child: Container(
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
                                              color: theme.colorScheme.error,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            provider.error ?? 'Unknown error',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(),
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                provider.fetchFlashcardElements(
                                                    forceRefresh: true),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return _buildPeriodicTable(provider.elements);
                                },
                              ),
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
            builder: (context) => AlertDialog(
              title: Text(
                'About the Periodic Table',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The periodic table organizes all known chemical elements by their atomic number, electron configuration, and recurring chemical properties.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Elements are arranged in rows (periods) and columns (groups) with similar properties.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Use pinch gestures to zoom in and out, and drag to move around the table.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        tooltip: 'About the Periodic Table',
        child: const Icon(Icons.info_outline),
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
        // Find element at this position
        PeriodicElement? element = _findElementAt(elements, period, group);

        if (element != null) {
          rowChildren.add(_buildElementCell(element));
        } else {
          // Empty cell
          rowChildren.add(Container(
            height: _cellSize,
            color: (period == 6 && group >= 4 && group <= 17) ||
                    (period == 7 && group >= 4 && group <= 17)
                ? Colors.grey.shade50 // Highlight lanthanide/actinide positions
                : Colors.white,
          ));
        }
      }

      rows.add(TableRow(children: rowChildren));
    }

    // Add spacer row
    rows.add(
      TableRow(
        children: List.generate(
            19,
            (index) => Container(
                  height: 16,
                  color: Colors.grey.shade50,
                )),
      ),
    );

    // Add lanthanide row (period 8)
    rows.add(_buildSpecialRow(elements, 8, 'lanthanide'));

    // Add actinide row (period 9)
    rows.add(_buildSpecialRow(elements, 9, 'actinide'));

    return rows;
  }

  TableRow _buildSpecialRow(
      List<PeriodicElement> elements, int periodNum, String category) {
    List<Widget> rowChildren = [];

    // Add row number
    rowChildren.add(
      Container(
        height: _cellSize,
        width: 24,
        alignment: Alignment.center,
        color: Colors.grey.shade50,
        child: Text(
          '$periodNum',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );

    // Skip first 2 cells
    rowChildren.add(Container(height: _cellSize, color: Colors.white));
    rowChildren.add(Container(height: _cellSize, color: Colors.white));

    // Get special elements (lanthanides or actinides)
    List<PeriodicElement> specialElements = [];

    if (category == 'lanthanide') {
      specialElements = elements
          .where((e) => e.atomicNumber >= 57 && e.atomicNumber <= 71)
          .toList()
        ..sort((a, b) => a.atomicNumber.compareTo(b.atomicNumber));
    } else {
      // actinide
      specialElements = elements
          .where((e) => e.atomicNumber >= 89 && e.atomicNumber <= 103)
          .toList()
        ..sort((a, b) => a.atomicNumber.compareTo(b.atomicNumber));
    }

    // Add each special element
    for (var element in specialElements) {
      rowChildren.add(_buildElementCell(element));
    }

    // Fill remaining cells
    while (rowChildren.length < 19) {
      rowChildren.add(Container(height: _cellSize, color: Colors.white));
    }

    return TableRow(children: rowChildren);
  }

  PeriodicElement? _findElementAt(
      List<PeriodicElement> elements, int period, int group) {
    try {
      // Skip lanthanide/actinide positions in the main table
      if (period == 6 && group >= 4 && group <= 17 && group != 18) {
        return null; // These spots are empty in period 6 (lanthanides)
      }
      if (period == 7 && group >= 4 && group <= 17 && group != 18) {
        return null; // These spots are empty in period 7 (actinides)
      }

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

  Widget _buildElementCell(PeriodicElement element) {
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
                        color: elementColor.withOpacity(isSelected ? 0.5 : 0.3),
                        blurRadius: isSelected ? 4 : 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(isSelected ? 6 : 2),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double cellSize;
  final Color color;

  GridPainter({required this.cellSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    final int rowCount = (size.height / cellSize).ceil();
    final int colCount = (size.width / cellSize).ceil();

    // Draw horizontal lines
    for (int i = 0; i <= rowCount; i++) {
      final double dy = i * cellSize;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    // Draw vertical lines
    for (int i = 0; i <= colCount; i++) {
      final double dx = i * cellSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
