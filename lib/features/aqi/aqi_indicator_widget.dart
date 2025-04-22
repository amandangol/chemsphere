import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'provider/aqi_provider.dart';
import 'aqi_info_screen.dart';

class AqiIndicatorWidget extends StatefulWidget {
  const AqiIndicatorWidget({Key? key}) : super(key: key);

  @override
  State<AqiIndicatorWidget> createState() => _AqiIndicatorWidgetState();
}

class _AqiIndicatorWidgetState extends State<AqiIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<AqiProvider>(context, listen: false);
      if (provider.aqiData == null && !provider.isLoading) {
        provider.fetchAqiData();
      }
    });

    // Setup pulse animation for molecules
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getChemicalFormula(String pollutantCode) {
    switch (pollutantCode.toLowerCase()) {
      case 'pm25':
      case 'pm10':
        return 'PM';
      case 'o3':
        return 'O₃';
      case 'no2':
        return 'NO₂';
      case 'so2':
        return 'SO₂';
      case 'co':
        return 'CO';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AqiProvider>(
      builder: (context, provider, child) {
        // Determine colors based on AQI value
        Color primaryColor =
            provider.aqiData != null && provider.aqiData!.aqi > 0
                ? provider.getAqiColor(provider.aqiData!.aqi)
                : theme.colorScheme.primary;

        // Calculate a darker shade for text contrast if needed
        Color textColor =
            _isColorBright(primaryColor) ? Colors.black87 : Colors.white;

        // Calculate container background color
        Color containerBgColor = _isColorBright(primaryColor)
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.2);

        String dominantPollutant = provider.aqiData != null &&
                provider.aqiData!.dominantPollutant.isNotEmpty
            ? provider.aqiData!.dominantPollutant
            : '';

        String chemFormula = _getChemicalFormula(dominantPollutant);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AqiInfoScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.85),
                          primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Molecular pattern background with better visibility
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MolecularPatternPainter(
                        // Slightly improved opacity for better visibility
                        color: _isColorBright(primaryColor)
                            ? Colors.black.withOpacity(0.15)
                            : Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title and location
                            Expanded(
                              child: Row(
                                children: [
                                  // Custom flask icon with AQI color
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: containerBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.science_outlined,
                                          color: textColor,
                                          size: 24,
                                        ),
                                        if (provider.isLoading)
                                          SizedBox(
                                            width: 42,
                                            height: 42,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      textColor),
                                              strokeWidth: 2,
                                              backgroundColor:
                                                  textColor.withOpacity(0.1),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Atmospheric Chemistry',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            shadows: [
                                              // Add shadow for better text readability
                                              Shadow(
                                                color:
                                                    _isColorBright(primaryColor)
                                                        ? Colors.black38
                                                        : Colors.black54,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (provider.aqiData != null &&
                                            provider.aqiData!.name.isNotEmpty)
                                          Text(
                                            '${provider.aqiData!.name}, ${provider.aqiData!.country.name}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // AQI Value display
                            if (provider.aqiData != null &&
                                provider.aqiData!.aqi > 0)
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                primaryColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${provider.aqiData!.aqi}',
                                                style:
                                                    GoogleFonts.jetBrainsMono(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              Text(
                                                'AQI',
                                                style:
                                                    GoogleFonts.jetBrainsMono(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Air quality status and chemical info
                        if (provider.error != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Could not load atmospheric data. Tap to retry.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else if (provider.aqiData != null &&
                            provider.aqiData!.aqi > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // AQI Category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        provider.getAqiCategory(
                                            provider.aqiData!.aqi),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (dominantPollutant.isNotEmpty)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(
                                          'Dominant: ${dominantPollutant.toUpperCase()}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Chemical formula visualization
                              if (chemFormula.isNotEmpty)
                                _buildMoleculeWidget(chemFormula, primaryColor),
                            ],
                          )
                        else if (provider.aqiData != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Location identified. No measurement data available.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else if (!provider.isLoading)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Tap to analyze atmospheric composition',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Bottom indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'View Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to check if a color is bright (to determine text color)
  bool _isColorBright(Color color) {
    // Calculate luminance (perceived brightness)
    // Values closer to 1 are brighter
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.7; // Threshold for considering a color bright
  }

  Widget _buildMoleculeWidget(String formula, Color color) {
    // Use a darker background for better visibility
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          ...formula.split('').map((char) {
            // Is it a digit? If yes, show as subscript
            if (RegExp(r'[₀-₉]').hasMatch(char)) {
              return Text(
                char,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return Text(
                char,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              );
            }
          }).toList(),
        ],
      ),
    );
  }
}

// Custom painter to create a molecular pattern background
class MolecularPatternPainter extends CustomPainter {
  final Color color;

  MolecularPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw some hexagons and connections to represent molecular structures
    _drawMolecularPattern(canvas, size, paint);
  }

  void _drawMolecularPattern(Canvas canvas, Size size, Paint paint) {
    // Draw hexagon-like molecular structures
    final centerX = size.width * 0.8;
    final centerY = size.height * 0.5;
    final radius = size.height * 0.25;

    // Draw a hexagon
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw some bonds
    canvas.drawLine(Offset(centerX - radius * 0.5, centerY - radius * 0.8),
        Offset(centerX - radius * 1.2, centerY), paint);

    canvas.drawLine(Offset(centerX + radius * 0.5, centerY - radius * 0.8),
        Offset(centerX + radius * 1.2, centerY - radius * 0.3), paint);

    // Draw a small circle as an atom
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX - radius * 1.2, centerY), 4, circlePaint);
    canvas.drawCircle(
        Offset(centerX + radius * 1.2, centerY - radius * 0.3), 4, circlePaint);
  }

  @override
  bool shouldRepaint(MolecularPatternPainter oldDelegate) => false;
}
