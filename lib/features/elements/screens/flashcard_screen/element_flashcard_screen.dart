import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flip_card/flip_card.dart';

import '../../provider/element_provider.dart';
import '../../../../utils/error_handler.dart';
import '../../../../widgets/chemistry_widgets.dart';
import '../../model/periodic_element.dart';
import 'widgets/element_flashcard_widgets.dart';

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
  bool _isShuffled = true;

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

  //  just resets view to page 0, order depends on _isShuffled state
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
              return const Center(
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
                          child: _buildFlashcard(element),
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

  /// Build a flipable flashcard
  Widget _buildFlashcard(PeriodicElement element) {
    return FlipCard(
      fill: Fill.fillBack,
      direction: FlipDirection.HORIZONTAL,
      front: _buildCardFront(element),
      back: _buildCardBack(element),
    );
  }

  /// Build the front of the card
  Widget _buildCardFront(PeriodicElement element) {
    final cardColor =
        ElementFlashcard.getThemeAdjustedColor(context, element.color);
    final bgColor = cardColor;
    final textColor =
        bgColor.computeLuminance() > 0.45 ? Colors.black : Colors.white;

    return ElementFlashcard(
      element: element,
      isFront: true,
      child: FlashcardFront(
        element: element,
        textColor: textColor,
      ),
    );
  }

  /// Build the back of the card
  Widget _buildCardBack(PeriodicElement element) {
    final cardColor =
        ElementFlashcard.getThemeAdjustedColor(context, element.color);
    final bgColor = cardColor.withOpacity(0.95);
    final textColor =
        bgColor.computeLuminance() > 0.45 ? Colors.black : Colors.white;

    return ElementFlashcard(
      element: element,
      isFront: false,
      child: FlashcardBack(
        element: element,
        textColor: textColor,
      ),
    );
  }
}
