import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChemistryFactWidget extends StatefulWidget {
  final AnimationController animationController;

  const ChemistryFactWidget({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  State<ChemistryFactWidget> createState() => _ChemistryFactWidgetState();
}

class _ChemistryFactWidgetState extends State<ChemistryFactWidget> {
  final List<String> _chemistryFacts = [
    'Water is the only substance that exists naturally in all three states of matter on Earth.',
    'Gold is the most malleable metal and can be hammered into sheets so thin that light can pass through them.',
    'Diamonds are not rare at all—they are actually one of the most common gems found on Earth.',
    'The human body contains enough carbon to fill about 9,000 pencils.',
    'The only letter not appearing on the periodic table is J.',
    'Helium is the only element that was first discovered in space before being found on Earth.',
    'Mercury and bromine are the only elements that are liquid at room temperature.',
    'Astatine is so rare that there is less than 1 gram of it naturally on Earth at any time.',
    'The smell of rain comes from a chemical compound called geosmin.',
    'Bananas are naturally radioactive because they contain potassium-40.'
  ];
  int _currentFactIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cycle through facts
    Future.delayed(const Duration(seconds: 15), _cycleToNextFact);
  }

  void _cycleToNextFact() {
    if (!mounted) return;
    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _chemistryFacts.length;
    });
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _cycleToNextFact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - widget.animationController.value)),
          child: Opacity(
            opacity: widget.animationController.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.tertiary
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Did You Know?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _chemistryFacts[_currentFactIndex],
                      key: ValueKey<int>(_currentFactIndex),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chemistry Fact #${_currentFactIndex + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ),
                      Icon(
                        Icons.science,
                        size: 14,
                        color: theme.colorScheme.onPrimary.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
