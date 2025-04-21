import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ChemistryAnimationWidget extends StatelessWidget {
  final Animation<double> animation;

  const ChemistryAnimationWidget({
    Key? key,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: animation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Atom orbital animation in background
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Lottie.asset(
                'assets/lottie/lottie_home.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Floating chemical symbols
          Positioned(
            top: 30,
            left: size.width * 0.15,
            child: _buildFloatingElement('H', Colors.blue),
          ),
          Positioned(
            bottom: 40,
            right: size.width * 0.2,
            child: _buildFloatingElement('O', Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElement(String symbol, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
