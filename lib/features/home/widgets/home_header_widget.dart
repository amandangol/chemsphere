import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../bookmarks/bookmark_screen.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({Key? key}) : super(key: key);

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _greetingAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _greetingOpacityAnimation;
  String _username = '';
  bool _loadingUsername = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();

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

    // Greeting animation
    _greetingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _greetingOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _greetingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _greetingAnimationController.forward();
    });
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      setState(() {
        _username = username;
        _loadingUsername = false;
      });
    } catch (e) {
      setState(() {
        _loadingUsername = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _greetingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerAnimation.value),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Logo with molecular structure background
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated molecular background (optional)
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CustomPaint(
                                painter: MoleculePainter(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                ),
                              ),
                            ),
                            // Logo container with scientific look
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/chemlogo.png',
                                width: 38,
                                height: 38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        // App name with chemistry-inspired style
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ChemSphere',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      Colors.deepPurple,
                                      theme.colorScheme.secondary,
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                  ),
                              ),
                            ),
                            // Scientific formula-like subtitle
                            Text(
                              'H₂O • CO₂ • C₆H₁₂O₆',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                                color:
                                    theme.colorScheme.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Chemistry flask icon button
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.7),
                            theme.colorScheme.secondary.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarkScreen(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.bookmark_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _greetingOpacityAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting +
                            (_username.isNotEmpty ? ', $_username' : '!'),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            today,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
