import 'package:chem_explore/screens/elements/modern_periodic_table_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/chemistry_widgets.dart';
import '../aqi/aqi_indicator_widget.dart';
import '../elements/periodic_table_screen.dart';
import '../compounds/compound_searhc_screen.dart';
import '../drugs/drug_search_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../reactions/reaction_screen.dart';
import '../chemistryguide/chemistry_guide_screen.dart';
import '../formula/formula_search_screen.dart';
import '../elements/element_flashcard_screen.dart';
import '../aqi/city_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _greetingAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _greetingOpacityAnimation;
  String _username = '';
  bool _loadingUsername = true;
  final List<String> _chemistryFacts = [
    'Water is the only substance that exists naturally in all three states of matter on Earth.',
    'Gold is the most malleable metal and can be hammered into sheets so thin that light can pass through them.',
    'Diamonds are not rare at all—they are actually one of the most common gems found on Earth.',
    'The human body contains enough carbon to fill about 9,000 pencils.',
    'The only letter not appearing on the periodic table is J.',
  ];
  int _currentFactIndex = 0;

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

    // Cycle through facts
    Future.delayed(const Duration(seconds: 15), _cycleToNextFact);
  }

  void _cycleToNextFact() {
    if (!mounted) return;
    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _chemistryFacts.length;
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        _cycleToNextFact();
      }
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Use the chemistry background image
          image: DecorationImage(
            image: const AssetImage('assets/images/chemistry_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.luminosity,
            ),
          ),
        ),
        child: _buildHomeContent(context),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final greeting = _getGreeting();
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Wave Animation and Molecular Design
          SliverToBoxAdapter(
            child: AnimatedBuilder(
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
                                      'ChemiVerse',
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
                                            const Rect.fromLTWH(
                                                0.0, 0.0, 200.0, 70.0),
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
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.7),
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
                                    theme.colorScheme.secondary
                                        .withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
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
                                        builder: (context) =>
                                            const OnboardingScreen(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.science_outlined,
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
                                    (_username.isNotEmpty
                                        ? ', $_username'
                                        : '!'),
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
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
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
            ),
          ),

          // AQI Widget - Enhanced air quality indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AqiIndicatorWidget(),
            ),
          ),

          // Daily Chemistry Fact - Moved up for better visibility
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AnimatedBuilder(
                animation: _greetingAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, 30 * (1 - _greetingAnimationController.value)),
                    child: Opacity(
                      opacity: _greetingAnimationController.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.8),
                              theme.colorScheme.tertiary ?? Colors.purple,
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
                                    color: theme.colorScheme.onPrimary
                                        .withOpacity(0.7),
                                  ),
                                ),
                                Icon(
                                  Icons.science,
                                  size: 14,
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Feature Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Explore Chemistry',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Top Feature Categories - Main actions in a 2x2 grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildListDelegate([
                // Elements/Periodic Table
                _buildMainFeatureCard(
                  context,
                  title: 'Periodic Table',
                  description: 'Explore chemical elements',
                  icon: Icons.table_chart_rounded,
                  color: Colors.indigo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PeriodicTableScreen(),
                    ),
                  ),
                ),

                // Compounds
                _buildMainFeatureCard(
                  context,
                  title: 'Compounds',
                  description: 'Search chemical compounds',
                  icon: Icons.science_rounded,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompoundSearchScreen(),
                    ),
                  ),
                ),

                // Learn
                _buildMainFeatureCard(
                  context,
                  title: 'Learn',
                  description: 'Flashcards & tutorials',
                  icon: Icons.school_rounded,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChemistryGuideScreen(),
                    ),
                  ),
                ),

                // Air Quality
                _buildMainFeatureCard(
                  context,
                  title: 'Air Quality',
                  description: 'Check pollutants & AQI',
                  icon: Icons.air_rounded,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CitySearchScreen(),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // Additional Features Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'More Features',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Additional Features in a horizontal scrollable row
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSecondaryFeatureCard(
                    context,
                    title: 'Drug Explorer',
                    icon: Icons.medical_services_rounded,
                    color: Colors.pink,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrugSearchScreen(),
                      ),
                    ),
                  ),
                  // _buildSecondaryFeatureCard(
                  //   context,
                  //   title: 'Chemical Reactions',
                  //   icon: Icons.bolt_rounded,
                  //   color: Colors.deepOrange,
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const ReactionScreen(),
                  //     ),
                  //   ),
                  // ),
                  _buildSecondaryFeatureCard(
                    context,
                    title: 'Formula Search',
                    icon: Icons.format_shapes_rounded,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FormulaSearchScreen(),
                      ),
                    ),
                  ),

                  _buildSecondaryFeatureCard(
                    context,
                    title: 'Periodic Table',
                    icon: Icons.book_rounded,
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModernPeriodicTableScreen(),
                      ),
                    ),
                  ),

                  _buildSecondaryFeatureCard(
                    context,
                    title: 'Chemical Reactions',
                    icon: Icons.bolt_rounded,
                    color: Colors.deepOrange,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Lottie Chemistry Animation - moved to bottom
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _greetingOpacityAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Atom orbital animation in background
                  Container(
                    height: 120, // Smaller height
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
            ),
          ),

          // Bottom spacer
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  // Main feature cards for the 2x2 grid
  Widget _buildMainFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: color, size: 12),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Secondary feature cards for horizontal scrolling
  Widget _buildSecondaryFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep the existing floating element widget method
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

// Keep existing MoleculePainter class
