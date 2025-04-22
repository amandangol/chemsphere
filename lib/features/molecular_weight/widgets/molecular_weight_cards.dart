import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../model/molecular_formula.dart';
import '../provider/molecular_weight_provider.dart';
import '../../elements/model/periodic_element.dart';
import '../../elements/provider/element_provider.dart';
import '../../../utils/snackbar_util.dart';
import '../model/unit_conversion.dart';

/// Instruction card with example formulas
class InstructionsCard extends StatelessWidget {
  final Function(String) onExampleTap;

  const InstructionsCard({
    Key? key,
    required this.onExampleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.cardColor.withOpacity(0.9),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.science,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter a chemical formula',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Calculate the molecular weight of any chemical compound by entering its formula.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Examples: H2O, NaCl, C6H12O6, CH3COOH',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildExampleChip(context, 'H2O'),
                _buildExampleChip(context, 'NaCl'),
                _buildExampleChip(context, 'C6H12O6'),
                _buildExampleChip(context, 'KMnO4'),
                _buildExampleChip(context, 'Ca(OH)2'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(BuildContext context, String formula) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(formula, style: GoogleFonts.sourceCodePro()),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
      onPressed: () => onExampleTap(formula),
    );
  }
}

/// Formula input card with text field
class FormulaInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onInfoPressed;
  final VoidCallback onClearPressed;
  final Function(String) onSubmitted;
  final VoidCallback onCalculatePressed;
  final bool isCalculating;

  const FormulaInputCard({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onInfoPressed,
    required this.onClearPressed,
    required this.onSubmitted,
    required this.onCalculatePressed,
    required this.isCalculating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      shadowColor: Colors.black26,
      color: theme.cardColor.withOpacity(0.9),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              theme.colorScheme.surface.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Chemical Formula',
                hintText: 'Enter formula (e.g., H2O)',
                prefixIcon: const Icon(Icons.functions),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: onInfoPressed,
                      tooltip: 'Formula guidelines',
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClearPressed,
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.sourceCodePro(
                fontSize: 18,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isCalculating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: Text(
                  isCalculating ? 'Calculating...' : 'Calculate',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isCalculating ? null : onCalculatePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error card shown when formula parsing fails
class ErrorCard extends StatelessWidget {
  final String errorMessage;

  const ErrorCard({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            color: theme.colorScheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Error',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Results card showing molecular weight and composition
class ResultsCard extends StatelessWidget {
  final String formula;
  final double molecularWeight;
  final MolecularFormula parsedFormula;
  final MassUnit selectedUnit;
  final Function(BuildContext, String) onElementTap;
  final Function(BuildContext, double) onUnitSelectorTap;
  final Function(BuildContext, MolecularWeightProvider) onAnalysisTap;

  const ResultsCard({
    Key? key,
    required this.formula,
    required this.molecularWeight,
    required this.parsedFormula,
    required this.selectedUnit,
    required this.onElementTap,
    required this.onUnitSelectorTap,
    required this.onAnalysisTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider =
        Provider.of<MolecularWeightProvider>(context, listen: false);

    return AnimationConfiguration.synchronized(
      duration: const Duration(milliseconds: 800),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Molecular Weight',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () =>
                            onUnitSelectorTap(context, molecularWeight),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.swap_vert,
                                size: 16,
                                color: theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                              Text(
                                'Convert',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatWeight(molecularWeight, selectedUnit),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getUnitText(selectedUnit),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Formula: $formula',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  if (parsedFormula.elements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Text(
                      'Composition:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: parsedFormula.elements.map((element) {
                        return _buildElementChip(context, element);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: Text(
                        'Show Detailed Analysis',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        side: BorderSide(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => onAnalysisTap(context, provider),
                    ),
                    const SizedBox(height: 16),
                    ActionChip(
                      avatar: const Icon(
                        Icons.save_alt,
                        size: 18,
                        color: Colors.white70,
                      ),
                      label: Text(
                        'Save to History',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.black26,
                      onPressed: () {
                        // Recalculate to save to history
                        provider.calculateFormula(formula);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saved to history'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementChip(BuildContext context, FormulaElement element) {
    return AnimationConfiguration.staggeredGrid(
      position: 0,
      columnCount: 3,
      duration: const Duration(milliseconds: 400),
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: InkWell(
            onTap: () => onElementTap(context, element.symbol),
            child: Chip(
              label: Text(
                '${element.symbol} × ${element.count}',
                style: GoogleFonts.sourceCodePro(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: _getElementColor(element.symbol),
                radius: 10,
                child: Text(
                  element.symbol.length > 2
                      ? element.symbol.substring(0, 1)
                      : element.symbol,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor:
                  _getElementColor(element.symbol).withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
        ),
      ),
    );
  }

  // Format molecular weight according to selected unit
  static String formatWeight(double weight, MassUnit unit) {
    switch (unit) {
      case MassUnit.gPerMol:
        return weight.toStringAsFixed(4);
      case MassUnit.kgPerMol:
        return (weight / 1000).toStringAsFixed(6);
      case MassUnit.lbPerMol:
        return (weight * 0.0022046226).toStringAsFixed(6);
      case MassUnit.uPerMolecule:
        return weight.toStringAsFixed(4);
    }
  }

  // Instance method that calls the static method (for internal use)
  String _formatWeight(double weight, MassUnit unit) {
    return formatWeight(weight, unit);
  }

  // Get unit text based on selected unit
  static String getUnitText(MassUnit unit) {
    switch (unit) {
      case MassUnit.gPerMol:
        return 'g/mol';
      case MassUnit.kgPerMol:
        return 'kg/mol';
      case MassUnit.lbPerMol:
        return 'lb/mol';
      case MassUnit.uPerMolecule:
        return 'u';
    }
  }

  // Instance method that calls the static method (for internal use)
  String _getUnitText(MassUnit unit) {
    return getUnitText(unit);
  }

  // Get color for element chips
  static Color getElementColor(String symbol) {
    final Map<String, Color> elementColors = {
      'H': Colors.blue,
      'O': Colors.red,
      'C': Colors.brown,
      'N': Colors.green,
      'Na': Colors.purple,
      'Cl': Colors.teal,
      'Ca': Colors.orange,
      'Fe': Colors.red.shade800,
      'S': Colors.amber.shade700,
      'K': Colors.deepPurple,
      'Mn': Colors.pink.shade700,
    };

    // Return color from map or a default color based on first letter
    if (elementColors.containsKey(symbol)) {
      return elementColors[symbol]!;
    } else {
      // Generate a consistent color based on the first letter
      final int charCode = symbol.codeUnitAt(0);
      final List<Color> defaultColors = [
        Colors.blue.shade700,
        Colors.red.shade700,
        Colors.green.shade700,
        Colors.purple.shade700,
        Colors.teal.shade700,
        Colors.orange.shade700,
        Colors.indigo.shade700,
        Colors.pink.shade700,
      ];

      return defaultColors[charCode % defaultColors.length];
    }
  }

  // Instance method that calls the static method (for internal use)
  Color _getElementColor(String symbol) {
    return getElementColor(symbol);
  }
}

/// History item card for the calculation history list
class HistoryItemCard extends StatelessWidget {
  final CalculationResult result;
  final VoidCallback onUseAgain;
  final Function(BuildContext, CalculationResult) onViewDetails;

  const HistoryItemCard({
    Key? key,
    required this.result,
    required this.onUseAgain,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.formula,
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.weight.toStringAsFixed(4)} g/mol',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(result.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  tooltip: 'View details',
                  onPressed: () => onViewDetails(context, result),
                ),
                IconButton(
                  icon: const Icon(Icons.replay_outlined, size: 20),
                  tooltip: 'Use this formula again',
                  onPressed: onUseAgain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format time only (hours:minutes)
  static String formatTime(DateTime timestamp) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.year == today.year &&
        timestamp.month == today.month &&
        timestamp.day == today.day) {
      return 'Today at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day) {
      return 'Yesterday at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  // Instance method that calls the static method (for internal use)
  String _formatTime(DateTime timestamp) {
    return formatTime(timestamp);
  }
}
