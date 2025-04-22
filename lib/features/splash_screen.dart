import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // List of chemistry-related elements that will float in the background
  final List<String> chemistryElements = [
    'H',
    'O',
    'C',
    'N',
    'Na',
    'Cl',
    'Fe',
    'Au',
    'H₂O',
    'CO₂'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();

    // Navigate to main app after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background with floating chemistry elements
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E)
                      .withOpacity(0.7), // Deeper blue for chemistry lab feel
                  const Color(0xFF0D47A1).withOpacity(0.5),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Stack(
              children: List.generate(20, (index) {
                final random = math.Random();
                final element =
                    chemistryElements[random.nextInt(chemistryElements.length)];
                final top = random.nextDouble() * size.height;
                final left = random.nextDouble() * size.width;
                final opacity = 0.1 + random.nextDouble() * 0.3;
                final fontSize = 12.0 + random.nextDouble() * 16.0;

                return Positioned(
                  top: top,
                  left: left,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(
                            math.sin(_controller.value * 2 * math.pi + index) *
                                10,
                            math.cos(_controller.value * 2 * math.pi + index) *
                                10,
                          ),
                          child: Text(
                            element,
                            style: GoogleFonts.robotoMono(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Molecular structure animation
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Atom core
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),

                          // Electron orbits
                          ...List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateAnimation.value +
                                      (index * math.pi / 3),
                                  child: Container(
                                    width: 70.0 + (index * 15),
                                    height: 70.0 + (index * 15),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.7),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // Electrons
                          ...List.generate(3, (index) {
                            return AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                final angle = _rotateAnimation.value +
                                    (index * (2 * math.pi / 3));
                                final radius = 35.0 + (index * 15) / 2;
                                return Transform.translate(
                                  offset: Offset(
                                    radius * math.cos(angle),
                                    radius * math.sin(angle),
                                  ),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logo Container with flask icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/chemlogo.png',
                            color: Colors.white,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Chem',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: 'Sphere',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tagline with formula styling
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Explore the ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          TextSpan(
                            text: 'World',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' of ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          TextSpan(
                            text: 'Chemistry',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Loading Indicator as bubbling reaction
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                            strokeWidth: 3,
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity:
                                    math.sin(_controller.value * 6 * math.pi) *
                                            0.5 +
                                        0.5,
                                child: Icon(
                                  Icons.bubble_chart,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.7),
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      '⚗️ • 🧪 • 🔬',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
