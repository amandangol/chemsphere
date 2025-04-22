import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../elements/screens/element_detailscreen/element_detail_screen.dart';
import '../provider/molecular_weight_provider.dart';
import '../../elements/provider/element_provider.dart';
import '../../elements/model/periodic_element.dart';
import '../../../utils/snackbar_util.dart';
import '../model/unit_conversion.dart';
import '../widgets/molecular_weight_cards.dart';

class MolecularWeightHeaderWidget extends StatefulWidget {
  const MolecularWeightHeaderWidget({Key? key}) : super(key: key);

  @override
  State<MolecularWeightHeaderWidget> createState() =>
      _MolecularWeightHeaderWidgetState();
}

class _MolecularWeightHeaderWidgetState
    extends State<MolecularWeightHeaderWidget> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

    // Header animation
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerAnimation.value),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 5),
            child: Text(
              'Calculate the weight of any chemical compound',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MoleculePainter extends CustomPainter {
  final Color color;

  MoleculePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw circles representing electron orbits
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.6, paint);

    // Draw dots representing electrons
    final electronPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Electrons on outer orbit
    for (var i = 0; i < 3; i++) {
      final angle = i * (2 * 3.14159 / 3);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 2, electronPaint);
    }

    // Electrons on inner orbit
    for (var i = 0; i < 2; i++) {
      final angle = i * (2 * 3.14159 / 2) + 0.5;
      final x = center.dx + radius * 0.6 * cos(angle);
      final y = center.dy + radius * 0.6 * sin(angle);
      canvas.drawCircle(Offset(x, y), 1.5, electronPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MolecularWeightScreen extends StatefulWidget {
  const MolecularWeightScreen({Key? key}) : super(key: key);

  @override
  State<MolecularWeightScreen> createState() => _MolecularWeightScreenState();
}

class _MolecularWeightScreenState extends State<MolecularWeightScreen>
    with TickerProviderStateMixin {
  final TextEditingController _formulaController = TextEditingController();
  final FocusNode _formulaFocusNode = FocusNode();
  late TabController _tabController;
  bool _showHistory = false;
  bool _showFormulaParsing = false;
  MassUnit _selectedUnit = MassUnit.gPerMol;
  String _historyFilter = 'All';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();

      final elementProvider =
          Provider.of<ElementProvider>(context, listen: false);
      if (elementProvider.elements.isEmpty) {
        elementProvider.fetchFlashcardElements();
      }
    });
  }

  @override
  void dispose() {
    _formulaController.dispose();
    _formulaFocusNode.dispose();
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.colorScheme.primary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showHistory ? Icons.calculate : Icons.history,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
                _fadeController.reset();
                _slideController.reset();
                _fadeController.forward();
                _slideController.forward();
              });
            },
            tooltip: _showHistory ? 'Calculator' : 'History',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.primaryContainer.withOpacity(0.2),
            ],
          ),
          // Optional pattern overlay
          image: DecorationImage(
            image: const AssetImage('assets/images/chemistry_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: _showHistory
              ? _buildHistoryView(context)
              : _buildCalculatorView(context),
        ),
      ),
    );
  }

  Widget _buildCalculatorView(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MolecularWeightProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the header widget
              const MolecularWeightHeaderWidget(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 600),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        // Title and instructions card
                        InstructionsCard(
                          onExampleTap: (formula) {
                            _formulaController.text = formula;
                            provider.calculateFormula(formula);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Formula input card
                        FormulaInputCard(
                          controller: _formulaController,
                          focusNode: _formulaFocusNode,
                          isCalculating: provider.isCalculating,
                          onInfoPressed: () => _showFormulaTips(context),
                          onClearPressed: () {
                            _formulaController.clear();
                            provider.calculateFormula('');
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              provider.calculateFormula(value);
                            }
                          },
                          onCalculatePressed: () {
                            final formula = _formulaController.text.trim();
                            if (formula.isNotEmpty) {
                              provider.calculateFormula(formula);
                            } else {
                              SnackbarUtil.showCustomSnackBar(
                                context,
                                message: 'Please enter a chemical formula',
                                backgroundColor: theme.colorScheme.error,
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        // Results area
                        if (provider.error != null)
                          ErrorCard(errorMessage: provider.error!),

                        if (provider.molecularWeight != null &&
                            provider.parsedFormula != null)
                          ResultsCard(
                            formula: provider.formula,
                            molecularWeight: provider.molecularWeight!,
                            parsedFormula: provider.parsedFormula!,
                            selectedUnit: _selectedUnit,
                            onElementTap: _showElementInfo,
                            onUnitSelectorTap: _showUnitSelector,
                            onAnalysisTap: _showCompositionAnalysis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryView(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<MolecularWeightProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MolecularWeightHeaderWidget(),
            const SizedBox(height: 8),
            provider.history.isEmpty
                ? Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeController,
                        child: Card(
                          margin: const EdgeInsets.all(24),
                          elevation: 3,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: theme.cardColor.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'No calculation history yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your calculated formulas will appear here',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: FadeTransition(
                            opacity: _fadeController,
                            child: Row(
                              children: [
                                Text(
                                  'Calculation History',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Filter: $_historyFilter',
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.filter_list, size: 16),
                                    ],
                                  ),
                                  onSelected: (value) {
                                    setState(() {
                                      _historyFilter = value;
                                    });
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                        value: 'All', child: Text('All')),
                                    PopupMenuItem(
                                        value: 'Today', child: Text('Today')),
                                    PopupMenuItem(
                                      value: 'This Week',
                                      child: Text('This Week'),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  label: const Text('Clear'),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Clear History'),
                                        content: const Text(
                                            'Are you sure you want to clear all calculation history?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              provider.clearHistory();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Clear'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: AnimationLimiter(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: provider.history.where((result) {
                                if (_historyFilter == 'All') {
                                  return true;
                                } else {
                                  final now = DateTime.now();
                                  final today =
                                      DateTime(now.year, now.month, now.day);
                                  final thisWeekStart = today.subtract(
                                      Duration(days: today.weekday - 1));

                                  if (_historyFilter == 'Today') {
                                    return result.timestamp.year ==
                                            today.year &&
                                        result.timestamp.month == today.month &&
                                        result.timestamp.day == today.day;
                                  } else if (_historyFilter == 'This Week') {
                                    final resultDate = DateTime(
                                        result.timestamp.year,
                                        result.timestamp.month,
                                        result.timestamp.day);
                                    return !resultDate.isBefore(thisWeekStart);
                                  }
                                  return true;
                                }
                              }).length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 8),
                              itemBuilder: (context, index) {
                                // Filter the list first
                                final filteredResults =
                                    provider.history.where((result) {
                                  if (_historyFilter == 'All') {
                                    return true;
                                  } else {
                                    final now = DateTime.now();
                                    final today =
                                        DateTime(now.year, now.month, now.day);
                                    final thisWeekStart = today.subtract(
                                        Duration(days: today.weekday - 1));

                                    if (_historyFilter == 'Today') {
                                      return result.timestamp.year ==
                                              today.year &&
                                          result.timestamp.month ==
                                              today.month &&
                                          result.timestamp.day == today.day;
                                    } else if (_historyFilter == 'This Week') {
                                      final resultDate = DateTime(
                                          result.timestamp.year,
                                          result.timestamp.month,
                                          result.timestamp.day);
                                      return !resultDate
                                          .isBefore(thisWeekStart);
                                    }
                                    return true;
                                  }
                                }).toList();

                                final result = filteredResults[index];

                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 600),
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: HistoryItemCard(
                                        result: result,
                                        onUseAgain: () {
                                          setState(() {
                                            _showHistory = false;
                                          });
                                          _formulaController.text =
                                              result.formula;
                                          provider
                                              .calculateFormula(result.formula);
                                        },
                                        onViewDetails: _showResultDetails,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }

  // Show unit selector dialog
  void _showUnitSelector(BuildContext context, double weight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AnimationLimiter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Unit Conversion',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Convert molecular weight to different units:',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),
                AnimationConfiguration.synchronized(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: MassUnit.values.map((unit) {
                      return SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: RadioListTile<MassUnit>(
                            title: Text(
                              ResultsCard.getUnitText(unit),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              ResultsCard.formatWeight(weight, unit) +
                                  ' ' +
                                  ResultsCard.getUnitText(unit),
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            value: unit,
                            groupValue: _selectedUnit,
                            onChanged: (MassUnit? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedUnit = value;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Note: "u" represents the unified atomic mass unit (Dalton)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show composition analysis dialog
  void _showCompositionAnalysis(
      BuildContext context, MolecularWeightProvider provider) {
    if (provider.parsedFormula == null || provider.molecularWeight == null)
      return;

    // Calculate mass percentage for each element
    final totalWeight = provider.molecularWeight!;
    final elementPercentages = provider.parsedFormula!.elements.map((element) {
      final elementProvider =
          Provider.of<ElementProvider>(context, listen: false);
      final elementData = elementProvider.elements.firstWhere(
        (e) => e.symbol == element.symbol,
        orElse: () => PeriodicElement(
          symbol: element.symbol,
          name: element.symbol,
          atomicNumber: 0,
          atomicMass: 0,
          cpkHexColor: "CCCCCC",
          electronConfiguration: "",
          electronegativity: 0,
          atomicRadius: 0,
          ionizationEnergy: 0,
          electronAffinity: 0,
          oxidationStates: "",
          standardState: "",
          meltingPoint: 0,
          boilingPoint: 0,
          density: 0,
          groupBlock: "",
          yearDiscovered: "",
        ),
      );

      final elementWeight = elementData.atomicMass * element.count;
      final percentage = (elementWeight / totalWeight) * 100;

      return MapEntry(element.symbol, percentage);
    }).toList();

    // Sort by percentage (descending)
    elementPercentages.sort((a, b) => b.value.compareTo(a.value));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return AnimationLimiter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Composition Analysis',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formula: ${provider.formula}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Molecular Weight: ${provider.molecularWeight!.toStringAsFixed(4)} g/mol',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 600),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mass Percentage by Element',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...elementPercentages.map((entry) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: ResultsCard
                                                      .getElementColor(
                                                          entry.key),
                                                  radius: 12,
                                                  child: Text(
                                                    entry.key.length > 2
                                                        ? entry.key
                                                            .substring(0, 1)
                                                        : entry.key,
                                                    style: GoogleFonts
                                                        .sourceCodePro(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  entry.key,
                                                  style:
                                                      GoogleFonts.sourceCodePro(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${entry.value.toStringAsFixed(2)}%',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            LinearProgressIndicator(
                                              value: entry.value / 100,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                ResultsCard.getElementColor(
                                                    entry.key),
                                              ),
                                              minHeight: 8,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Element Details',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Consumer<ElementProvider>(
                                      builder:
                                          (context, elementProvider, child) {
                                        return Column(
                                          children: provider
                                              .parsedFormula!.elements
                                              .map((element) {
                                            final elementData = elementProvider
                                                .elements
                                                .firstWhere(
                                              (e) => e.symbol == element.symbol,
                                              orElse: () => PeriodicElement(
                                                symbol: element.symbol,
                                                name: "Unknown",
                                                atomicNumber: 0,
                                                atomicMass: 0,
                                                cpkHexColor: "CCCCCC",
                                                electronConfiguration: "",
                                                electronegativity: 0,
                                                atomicRadius: 0,
                                                ionizationEnergy: 0,
                                                electronAffinity: 0,
                                                oxidationStates: "",
                                                standardState: "",
                                                meltingPoint: 0,
                                                boilingPoint: 0,
                                                density: 0,
                                                groupBlock: "",
                                                yearDiscovered: "",
                                              ),
                                            );

                                            return Card(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide(
                                                  color: ResultsCard
                                                          .getElementColor(
                                                              element.symbol)
                                                      .withOpacity(0.5),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: ResultsCard
                                                            .getElementColor(
                                                                element.symbol),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        element.symbol,
                                                        style: GoogleFonts
                                                            .sourceCodePro(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            elementData.name,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            'Count: ${element.count}',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          if (elementData
                                                                  .atomicNumber >
                                                              0)
                                                            Text(
                                                              'Atomic Number: ${elementData.atomicNumber}',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          if (elementData
                                                                  .atomicMass >
                                                              0)
                                                            Text(
                                                              'Atomic Weight: ${elementData.atomicMass} u',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Show element information dialog
  void _showElementInfo(BuildContext context, String symbol) {
    final elementProvider =
        Provider.of<ElementProvider>(context, listen: false);
    final elementData = elementProvider.elements.firstWhere(
      (e) => e.symbol == symbol,
      orElse: () => PeriodicElement(
        symbol: symbol,
        name: "Unknown Element",
        atomicNumber: 0,
        atomicMass: 0,
        cpkHexColor: "CCCCCC",
        electronConfiguration: "",
        electronegativity: 0,
        atomicRadius: 0,
        ionizationEnergy: 0,
        electronAffinity: 0,
        oxidationStates: "",
        standardState: "",
        meltingPoint: 0,
        boilingPoint: 0,
        density: 0,
        groupBlock: "",
        yearDiscovered: "",
      ),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: ResultsCard.getElementColor(symbol),
                child: Text(
                  symbol.length > 2 ? symbol.substring(0, 1) : symbol,
                  style: GoogleFonts.sourceCodePro(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  elementData.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: AnimationLimiter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildElementInfoRow('Symbol', symbol),
                  _buildElementInfoRow(
                      'Atomic Number',
                      elementData.atomicNumber > 0
                          ? elementData.atomicNumber.toString()
                          : 'Unknown'),
                  _buildElementInfoRow(
                      'Atomic Weight',
                      elementData.atomicMass > 0
                          ? '${elementData.atomicMass} u'
                          : 'Unknown'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (elementData.atomicNumber > 0)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToElementDetail(elementData);
                },
                child: const Text('More Details'),
              ),
          ],
        );
      },
    );
  }

  void _navigateToElementDetail(PeriodicElement element) {
    context.read<ElementProvider>().setSelectedElement(element.symbol);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            ElementDetailScreen(element: element),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // Show result details dialog
  void _showResultDetails(BuildContext context, CalculationResult result) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Calculation Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultInfoRow('Formula', result.formula),
              _buildResultInfoRow('Molecular Weight',
                  '${result.weight.toStringAsFixed(4)} g/mol'),
              _buildResultInfoRow(
                  'Calculated on',
                  DateFormat('MMM d, y \'at\' h:mm a')
                      .format(result.timestamp)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _showHistory = false;
                });
                _formulaController.text = result.formula;
                Provider.of<MolecularWeightProvider>(context, listen: false)
                    .calculateFormula(result.formula);
              },
              child: const Text('Use Again'),
            ),
          ],
        );
      },
    );
  }

  // Helper widget for element info dialog
  Widget _buildElementInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for result details dialog
  Widget _buildResultInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormulaTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formula Guidelines',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFormulaTip(
                icon: Icons.check_circle_outline,
                title: 'Element Symbols',
                description: 'Use correct element symbols (Na, Cl, C, etc.)',
              ),
              _buildFormulaTip(
                icon: Icons.looks_one_outlined,
                title: 'Numbers',
                description:
                    'Numbers after symbols indicate quantity (H2O = 2 hydrogen, 1 oxygen)',
              ),
              _buildFormulaTip(
                icon: Icons.architecture_outlined,
                title: 'Brackets',
                description: 'Group elements with parentheses: Ca(OH)2',
              ),
              _buildFormulaTip(
                icon: Icons.water_drop_outlined,
                title: 'Hydrates',
                description: 'Use dot notation for hydrates: CuSO4·5H2O',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Got it'),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormulaTip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
