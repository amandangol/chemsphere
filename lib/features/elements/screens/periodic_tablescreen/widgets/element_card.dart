import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/periodic_element.dart';
import 'element_utils.dart';

class ElementCard extends StatefulWidget {
  final PeriodicElement element;
  final int index;
  final VoidCallback onTap;

  const ElementCard({
    Key? key,
    required this.element,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ElementCard> createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getElementColor() {
    return widget.element.standardColor;
  }

  String _formatValue(dynamic value) {
    return ElementUtils.formatValue(value);
  }

  String _getCategoryEmoji() {
    return ElementUtils.getCategoryEmoji(widget.element.groupBlock);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getElementColor();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360; // Check for smaller screens

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? 6 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Atomic number in top-left
                  Positioned(
                    top: 6,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.element.atomicNumber}',
                        style: GoogleFonts.robotoMono(
                          fontSize: isSmallScreen ? 9 : 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Element symbol
                        Text(
                          widget.element.symbol,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Element name
                        Text(
                          widget.element.name,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Atomic mass
                        Text(
                          _formatValue(widget.element.formattedAtomicMass),
                          style: GoogleFonts.robotoMono(
                            fontSize: isSmallScreen ? 9 : 10,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
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
