import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// For random shuffling
import 'package:flip_card/flip_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import FontAwesome

import 'provider/element_provider.dart';
import '../../utils/error_handler.dart';
import '../../widgets/chemistry_widgets.dart'; // Import custom chemistry widgets
import 'model/periodic_element.dart'; // Import PeriodicElement model

class ElementFlashcardScreen extends StatefulWidget {
  const ElementFlashcardScreen({Key? key}) : super(key: key);

  @override
  State<ElementFlashcardScreen> createState() => _ElementFlashcardScreenState();
}

class _ElementFlashcardScreenState extends State<ElementFlashcardScreen> {
  late PageController _pageController;
  List<PeriodicElement> _displayElements =
      []; // Changed from Element to PeriodicElement
  bool _initialLoad = true;
  int _currentPage = 0;
  bool _isShuffled = true; // State for shuffle toggle

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElements();
    });
  }

  Future<void> _loadElements({bool forceRefresh = false}) async {
    final provider = Provider.of<ElementProvider>(context, listen: false);
    // Ensure loading state is set if refreshing
    if (forceRefresh) {
      setState(() {
        _initialLoad = true;
        _displayElements = []; // Clear existing while loading
      });
    }

    try {
      await provider.fetchFlashcardElements(forceRefresh: forceRefresh);
      if (mounted) {
        _updateDisplayList();
        setState(() {
          _initialLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
            context, ErrorHandler.getErrorMessage(e));
        setState(() {
          _initialLoad = false;
        });
      }
    }
  }

  // Updates the display list based on shuffle state
  void _updateDisplayList() {
    final provider = Provider.of<ElementProvider>(context, listen: false);
    if (provider.elements.isEmpty) {
      _displayElements = [];
      return;
    }
    if (_isShuffled) {
      _displayElements = List.from(provider.elements)..shuffle();
    } else {
      _displayElements = List.from(provider.elements)
        ..sort((a, b) => a.atomicNumber.compareTo(b.atomicNumber));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Now just resets view to page 0, order depends on _isShuffled state
  void _resetView() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Toggles shuffle state and updates list
  void _toggleShuffle() {
    setState(() {
      _isShuffled = !_isShuffled;
      _updateDisplayList(); // Update order
      _resetView(); // Go to first card in new order
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_isShuffled
              ? 'Elements shuffled!'
              : 'Elements ordered by number.'),
          duration: const Duration(seconds: 1)),
    );
  }

  // Helper to format values - display N/A for 0 or empty values
  String _formatValue(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'N/A';
    }

    // For numeric values, check if they're zero
    if (value is num || value is String && double.tryParse(value) != null) {
      double? numValue;
      if (value is num) {
        numValue = value.toDouble();
      } else {
        numValue = double.tryParse(value.toString());
      }

      if (numValue != null && numValue == 0) {
        return 'N/A';
      }
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Element Flashcards',
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
        actions: [
          // Toggle Shuffle Button
          IconButton(
            icon: Icon(_isShuffled ? Icons.shuffle : Icons.format_list_numbered,
                size: 20),
            tooltip: _isShuffled ? 'Order by Number' : 'Shuffle Elements',
            onPressed: _toggleShuffle,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Chemistry-themed background
          image: DecorationImage(
            image: const AssetImage('assets/images/chemistry_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.95),
              BlendMode.luminosity,
            ),
          ),
        ),
        child: Consumer<ElementProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && _initialLoad) {
              return const ChemistryLoadingWidget(
                  message: 'Loading flashcards...');
            }

            if (provider.error != null && _displayElements.isEmpty) {
              return ErrorHandler.buildErrorWidget(
                errorMessage: ErrorHandler.getErrorMessage(provider.error),
                onRetry: () => _loadElements(forceRefresh: true),
                iconColor: theme.colorScheme.error,
              );
            }

            if (_displayElements.isEmpty) {
              return Center(
                child: Text(
                  'No flashcards available.',
                  style: TextStyle(fontSize: 14),
                ),
              );
            }

            // Main content: PageView with FlipCards
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _displayElements.length,
                    itemBuilder: (context, index) {
                      final element = _displayElements[index];
                      double scale = 1.0;
                      if (_pageController.position.haveDimensions) {
                        scale = (1 -
                                ((_pageController.page ?? 0.0) - index).abs() *
                                    0.15)
                            .clamp(0.85, 1.0);
                      }
                      return Transform.scale(
                        scale: scale,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: FlipCard(
                            fill: Fill.fillBack,
                            direction: FlipDirection.HORIZONTAL,
                            // Pass helpers to avoid repeating code
                            front: _buildCardContent(element, isFront: true),
                            back: _buildCardContent(element, isFront: false),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Page indicator with chemistry styling
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.science,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentPage + 1} / ${_displayElements.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Icon Mapping ---
  IconData _getPropertyIcon(String propertyLabel) {
    switch (propertyLabel.toLowerCase()) {
      case 'phase':
      case 'standard state':
        // Handled by _getPhaseIcon directly based on value
        return FontAwesomeIcons.question; // Fallback
      case 'atomic mass':
        return FontAwesomeIcons.weightHanging;
      case 'e. config':
        return FontAwesomeIcons.atom;
      case 'electronegativity':
        return FontAwesomeIcons.bolt;
      case 'atomic radius':
        return FontAwesomeIcons.arrowsLeftRightToLine;
      case 'ionization energy':
        return FontAwesomeIcons.arrowUpRightDots;
      case 'electron affinity':
        return FontAwesomeIcons.handHoldingDollar;
      case 'oxidation states':
        return FontAwesomeIcons.layerGroup;
      case 'density':
        return FontAwesomeIcons.compress;
      case 'melting point':
        return FontAwesomeIcons.icicles;
      case 'boiling point':
        return FontAwesomeIcons.fire;
      case 'year discovered':
        return FontAwesomeIcons.calendarDays;
      default:
        return FontAwesomeIcons.flask; // Generic fallback
    }
  }

  IconData _getPhaseIcon(String phase) {
    switch (phase.toLowerCase()) {
      case 'gas':
        return FontAwesomeIcons.smog;
      case 'liquid':
        return FontAwesomeIcons.droplet;
      case 'solid':
      default:
        return FontAwesomeIcons.square;
    }
  }

  // --- Card Building Widgets ---

  // Combined card content builder
  Widget _buildCardContent(PeriodicElement element, {required bool isFront}) {
    final theme = Theme.of(context);
    final cardColor = _getThemeAdjustedColor(element.color);
    // Adjust back card color slightly
    final bgColor = isFront ? cardColor : cardColor.withOpacity(0.95);
    final textColor =
        bgColor.computeLuminance() > 0.45 ? Colors.black : Colors.white;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          // Use gradient only for front
          gradient: isFront
              ? LinearGradient(
                  colors: [bgColor.withOpacity(0.6), bgColor.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isFront ? bgColor : null, // Solid color for back
        ),
        child: isFront
            ? _buildFrontLayout(element, textColor)
            : _buildBackLayout(element, textColor),
      ),
    );
  }

  // Layout for the FRONT of the card (restored rich view)
  Widget _buildFrontLayout(PeriodicElement element, Color textColor) {
    return Stack(
      children: [
        // Big Symbol Watermark
        Positioned(
            right: -30,
            bottom: -40,
            child: Text(element.symbol,
                style: GoogleFonts.poppins(
                    fontSize: 180,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.1)))),
        // Main Content Area
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Symbol, Number, Phase
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(element.symbol,
                      style: GoogleFonts.poppins(
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 0.95)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('#${element.atomicNumber}',
                            style: GoogleFonts.lato(
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                color: textColor.withOpacity(0.9))),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FaIcon(
                                _getPhaseIcon(
                                    _formatValue(element.standardState)),
                                color: textColor.withOpacity(0.8),
                                size: 14),
                            const SizedBox(width: 6),
                            Text(_formatValue(element.standardState),
                                style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.8))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Middle Section: Details Chips (similar to previous swipe card)
              _buildDetailRow('E. Config:',
                  _formatValue(element.electronConfiguration), textColor,
                  allowWrap: false,
                  maxLines: 1,
                  icon: _getPropertyIcon('E. Config'),
                  useChipStyle: true),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildDetailChip(
                          'Radius',
                          '${_formatValue(element.atomicRadius)} pm',
                          textColor,
                          _getPropertyIcon('Atomic Radius'))),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildDetailChip(
                        'EN',
                        _formatValue(element.electronegativity),
                        textColor,
                        _getPropertyIcon('Electronegativity')),
                  )
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                      child: _buildDetailChip(
                          'Density',
                          '${_formatValue(element.density)} ${element.standardState.toLowerCase() == "gas" ? "g/L" : "g/cm³"}',
                          textColor,
                          _getPropertyIcon('Density'))),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _buildDetailChip(
                          'Oxidation',
                          _formatValue(element.oxidationStates),
                          textColor,
                          _getPropertyIcon('Oxidation States'),
                          maxLines: 1)), // Show only 1 line on front
                ],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tap for Details",
                        style: GoogleFonts.lato(
                            fontSize: 11, color: textColor.withOpacity(0.6))),
                    const SizedBox(width: 4),
                    FaIcon(FontAwesomeIcons.handPointUp,
                        color: textColor.withOpacity(0.6), size: 12),
                  ],
                ),
              ),
              const Spacer(), // Pushes bottom content down
              // Bottom Section: Name, Group, Mass, Year + Tap Hint
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(element.name,
                      style: GoogleFonts.lato(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatValue(element.groupBlock),
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: textColor.withOpacity(0.85))),
                            const SizedBox(height: 2),
                            Text(
                                '${_formatValue(element.formattedAtomicMass)} u',
                                style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: textColor.withOpacity(0.8))),
                          ],
                        ),
                        Text(
                            'Discovered: ${_formatValue(element.yearDiscovered)}',
                            style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.7))),
                      ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout for the BACK of the card (list view)
  Widget _buildBackLayout(PeriodicElement element, Color textColor) {
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
                  color: textColor.withOpacity(0.9)),
            ),
            Divider(
                height: 14, thickness: 0.5, color: textColor.withOpacity(0.3)),
            _buildDetailItem(
                'Atomic Mass',
                '${_formatValue(element.formattedAtomicMass)} u',
                textColor,
                _getPropertyIcon('Atomic Mass')),
            _buildDetailItem(
                'Standard State',
                _formatValue(element.standardState),
                textColor,
                _getPhaseIcon(_formatValue(element.standardState))),
            _buildDetailItem(
                'E. Config',
                _formatValue(element.electronConfiguration),
                textColor,
                _getPropertyIcon('E. Config'),
                allowWrap: true),
            _buildDetailItem(
                'Electronegativity',
                _formatValue(element.electronegativity),
                textColor,
                _getPropertyIcon('Electronegativity')),
            _buildDetailItem(
                'Atomic Radius',
                '${_formatValue(element.atomicRadius)} pm',
                textColor,
                _getPropertyIcon('Atomic Radius')),
            _buildDetailItem(
                'Ionization Energy',
                '${_formatValue(element.ionizationEnergy)} eV',
                textColor,
                _getPropertyIcon('Ionization Energy')),
            _buildDetailItem(
                'Electron Affinity',
                '${_formatValue(element.electronAffinity)} eV',
                textColor,
                _getPropertyIcon('Electron Affinity')),
            _buildDetailItem(
                'Oxidation States',
                _formatValue(element.oxidationStates),
                textColor,
                _getPropertyIcon('Oxidation States'),
                allowWrap: true),
            _buildDetailItem(
                'Density',
                '${_formatValue(element.density)} ${element.standardState.toLowerCase() == "gas" ? "g/L" : "g/cm³"}',
                textColor,
                _getPropertyIcon('Density')),
            _buildDetailItem(
                'Melting Point',
                '${_formatValue(element.meltingPoint)} K',
                textColor,
                _getPropertyIcon('Melting Point')),
            _buildDetailItem(
                'Boiling Point',
                '${_formatValue(element.boilingPoint)} K',
                textColor,
                _getPropertyIcon('Boiling Point')),
            _buildDetailItem(
                'Year Discovered',
                _formatValue(element.yearDiscovered),
                textColor,
                _getPropertyIcon('Year Discovered')),
          ],
        ),
      ),
    );
  }

  // Helper for detail CHIPS on the FRONT card
  Widget _buildDetailChip(
      String label, String value, Color textColor, IconData icon,
      {int maxLines = 1}) {
    return Tooltip(
      message: '$label: $value', // Tooltip always useful
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: textColor.withOpacity(0.8)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: GoogleFonts.lato(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for detail ROWS on the FRONT card (e.g., E. Config)
  Widget _buildDetailRow(String label, String value, Color textColor,
      {bool allowWrap = false,
      int maxLines = 1,
      required IconData icon,
      bool useChipStyle = false}) {
    if (useChipStyle) {
      return _buildDetailChip(label, value, textColor, icon,
          maxLines: maxLines);
    }
    // Fallback to previous row style if needed, but chip is preferred now
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 14, color: textColor.withOpacity(0.9)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style:
                  GoogleFonts.lato(fontSize: 13, color: textColor, height: 1.2),
              textAlign: TextAlign.left,
              softWrap: allowWrap,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for detail ITEMS on the BACK card
  Widget _buildDetailItem(
      String label, String value, Color textColor, IconData icon,
      {bool allowWrap = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment:
            allowWrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 14,
            color: textColor.withOpacity(0.8),
          ),
          const SizedBox(width: 10),
          Text('$label:',
              style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.9))),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              softWrap: allowWrap,
              maxLines: allowWrap ? 4 : 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to adjust colors to be more theme-aligned
  Color _getThemeAdjustedColor(Color originalColor) {
    final theme = Theme.of(context);

    // If it's a standard element group color, use a more theme-appropriate version
    if (originalColor == Colors.green ||
        originalColor.value == Color(0xFF4CAF50).value) {
      return Color(0xFF2E7D32); // Themed green
    } else if (originalColor == Colors.red ||
        originalColor.value == Color(0xFFF44336).value) {
      return Color(0xFFB82E2E); // Themed red
    } else if (originalColor == Colors.blue ||
        originalColor.value == Color(0xFF2196F3).value) {
      return theme.colorScheme.primary; // App primary
    } else if (originalColor == Colors.deepPurple ||
        originalColor.value == Color(0xFF673AB7).value) {
      return theme.colorScheme.tertiary; // App tertiary
    } else if (originalColor == Colors.orange ||
        originalColor.value == Color(0xFFFF9800).value) {
      return Color(0xFFE67700); // Themed orange
    } else if (originalColor == Colors.teal ||
        originalColor.value == Color(0xFF009688).value) {
      return theme.colorScheme.secondary; // App secondary
    }

    // For other colors, just return the original
    return originalColor;
  }
}
