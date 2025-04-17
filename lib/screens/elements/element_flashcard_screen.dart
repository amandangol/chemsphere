import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; // For random shuffling
import 'package:flip_card/flip_card.dart';

import '../../providers/flashcard_provider.dart';
import '../../models/flashcard_element.dart';

class ElementFlashcardScreen extends StatefulWidget {
  const ElementFlashcardScreen({Key? key}) : super(key: key);

  @override
  State<ElementFlashcardScreen> createState() => _ElementFlashcardScreenState();
}

class _ElementFlashcardScreenState extends State<ElementFlashcardScreen> {
  late PageController _pageController;
  List<FlashcardElement> _displayElements =
      []; // Renamed from _shuffledElements
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
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    // Ensure loading state is set if refreshing
    if (forceRefresh) {
      setState(() {
        _initialLoad = true;
        _displayElements = []; // Clear existing while loading
      });
    }
    await provider.fetchFlashcardElements(forceRefresh: forceRefresh);
    if (mounted) {
      _updateDisplayList();
      setState(() {
        _initialLoad = false;
      });
    }
  }

  // Updates the display list based on shuffle state
  void _updateDisplayList() {
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Element Flashcards'),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.5),
        actions: [
          // Toggle Shuffle Button
          IconButton(
            icon:
                Icon(_isShuffled ? Icons.shuffle : Icons.format_list_numbered),
            tooltip: _isShuffled ? 'Order by Number' : 'Shuffle Elements',
            onPressed: _toggleShuffle,
          ),
        ],
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _initialLoad) {
            return const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading flashcards...'),
                  ]),
            );
          }

          if (provider.error != null && _displayElements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.error, size: 60),
                  const SizedBox(height: 16),
                  Text('Error loading flashcards:',
                      style: TextStyle(
                          color: theme.colorScheme.error, fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(provider.error!, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: () => _loadElements(forceRefresh: true),
                  )
                ],
              ),
            );
          }

          if (_displayElements.isEmpty) {
            return const Center(child: Text('No flashcards available.'));
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
                            vertical: 20.0, horizontal: 8.0),
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
              // Page indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '${_currentPage + 1} / ${_displayElements.length}',
                  style: theme.textTheme.bodySmall,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // --- Card Building Widgets ---

  // Helper to get phase icon
  IconData _getPhaseIcon(String phase) {
    switch (phase.toLowerCase()) {
      case 'gas':
        return Icons.cloud_outlined;
      case 'liquid':
        return Icons.water_drop_outlined;
      case 'solid':
      default:
        return Icons.square_foot_outlined;
    }
  }

  // Combined card content builder
  Widget _buildCardContent(FlashcardElement element, {required bool isFront}) {
    final cardColor = element.color;
    // Adjust back card color slightly
    final bgColor = isFront ? cardColor : cardColor.withOpacity(0.95);
    final textColor =
        bgColor.computeLuminance() > 0.45 ? Colors.black : Colors.white;

    return Card(
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
  Widget _buildFrontLayout(FlashcardElement element, Color textColor) {
    return Stack(
      children: [
        // Big Symbol Watermark
        Positioned(
            right: -30,
            bottom: -40,
            child: Text(element.symbol,
                style: GoogleFonts.poppins(
                    fontSize: 200,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.1)))),
        // Main Content Area
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Symbol, Number, Phase
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(element.symbol,
                      style: GoogleFonts.poppins(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 0.95)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('#${element.atomicNumber}',
                            style: GoogleFonts.lato(
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                color: textColor.withOpacity(0.9))),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(_getPhaseIcon(element.standardState),
                                color: textColor.withOpacity(0.8), size: 18),
                            const SizedBox(width: 4),
                            Text(
                                element.standardState.isEmpty
                                    ? 'N/A'
                                    : element.standardState,
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: textColor.withOpacity(0.8))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Middle Section: Details Chips (similar to previous swipe card)
              _buildDetailRow(
                  'E. Config:', element.electronConfiguration, textColor,
                  allowWrap: false, maxLines: 1), // Show only 1 line on front
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildDetailChip(
                          'Radius',
                          '${element.atomicRadius} pm',
                          textColor,
                          Icons.settings_ethernet)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildDetailChip(
                          'EN',
                          '${element.electronegativity}',
                          textColor,
                          Icons.bolt_outlined)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                      child: _buildDetailChip(
                          'Density',
                          '${element.density} ${element.standardState == "Gas" ? "g/L" : "g/cm³"}',
                          textColor,
                          Icons.scale_outlined)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildDetailChip(
                          'Oxidation',
                          element.oxidationStates,
                          textColor,
                          Icons.layers_outlined,
                          maxLines: 1)), // Show only 1 line on front
                ],
              ),
              const Spacer(), // Pushes bottom content down
              // Bottom Section: Name, Group, Mass, Year + Tap Hint
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(element.name,
                      style: GoogleFonts.lato(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(element.groupBlock,
                                style: GoogleFonts.lato(
                                    fontSize: 18,
                                    color: textColor.withOpacity(0.85))),
                            const SizedBox(height: 2),
                            Text('${element.formattedAtomicMass} u',
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: textColor.withOpacity(0.8))),
                          ],
                        ),
                        Text('Discovered: ${element.yearDiscovered}',
                            style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: textColor.withOpacity(0.7))),
                      ]),
                  const SizedBox(height: 10),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Tap for Details",
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: textColor.withOpacity(0.6))),
                          const SizedBox(width: 4),
                          Icon(Icons.touch_app_outlined,
                              color: textColor.withOpacity(0.6), size: 16),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout for the BACK of the card (list view)
  Widget _buildBackLayout(FlashcardElement element, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details: ${element.name}',
              style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.9)),
            ),
            const Divider(height: 16),
            _buildDetailItem('Atomic Mass', '${element.formattedAtomicMass} u',
                textColor, Icons.scale),
            _buildDetailItem('Standard State', element.standardState, textColor,
                _getPhaseIcon(element.standardState)),
            _buildDetailItem('E. Config', element.electronConfiguration,
                textColor, Icons.layers_outlined,
                allowWrap: true),
            _buildDetailItem('Electronegativity',
                '${element.electronegativity}', textColor, Icons.bolt_outlined),
            _buildDetailItem('Atomic Radius', '${element.atomicRadius} pm',
                textColor, Icons.settings_ethernet),
            _buildDetailItem(
                'Ionization Energy',
                '${element.ionizationEnergy} eV',
                textColor,
                Icons.flash_on_outlined),
            _buildDetailItem(
                'Electron Affinity',
                '${element.electronAffinity} eV',
                textColor,
                Icons.electrical_services_outlined),
            _buildDetailItem('Oxidation States', element.oxidationStates,
                textColor, Icons.exposure,
                allowWrap: true),
            _buildDetailItem(
                'Density',
                '${element.density} ${element.standardState == "Gas" ? "g/L" : "g/cm³"}',
                textColor,
                Icons.scale_outlined),
            _buildDetailItem('Melting Point', '${element.meltingPoint} K',
                textColor, Icons.thermostat_outlined),
            _buildDetailItem('Boiling Point', '${element.boilingPoint} K',
                textColor, Icons.thermostat_auto_outlined),
            _buildDetailItem('Year Discovered', element.yearDiscovered,
                textColor, Icons.history_edu_outlined),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: textColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor.withOpacity(0.8)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: GoogleFonts.lato(
                    fontSize: 13,
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
      {bool allowWrap = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0), // Reduced padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.9),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: textColor,
                height: 1.2,
              ),
              textAlign: TextAlign.right,
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
    // This is the helper from the previous flipcard implementation - kept for the back card
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment:
            allowWrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor.withOpacity(0.8)),
          const SizedBox(width: 10),
          Text('$label:',
              style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.9))),
          const Spacer(),
          Expanded(
            flex: 2, // Give value more space
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              softWrap: allowWrap,
              maxLines: allowWrap ? 4 : 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(fontSize: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
