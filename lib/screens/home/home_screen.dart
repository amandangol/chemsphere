import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../elements/periodic_table_screen.dart';
import '../compounds/compound_searhc_screen.dart';
import '../drugs/drug_search_screen.dart';
import '../reactions/reaction_screen.dart';
import '../chemistryguide/chemistry_guide_screen.dart';

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
    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _chemistryFacts.length;
    });
    Future.delayed(const Duration(seconds: 15), _cycleToNextFact);
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
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.science_rounded,
                                    color: theme.colorScheme.onPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'ChemiVerse',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          Colors.deepPurple,
                                        ],
                                      ).createShader(const Rect.fromLTWH(
                                          0.0, 0.0, 200.0, 70.0)),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    today,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: theme.colorScheme.onBackground
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

          // Animated Lottie Chemistry Animation
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _greetingOpacityAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Atom orbital animation in background
                  Container(
                    height: 200,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

          // Quick Access Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Access',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: AnimationLimiter(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildQuickAccessItem(
                            context,
                            imagePath: 'assets/svgs/periodictable.svg',
                            label: 'Periodic Table',
                            color: theme.colorScheme.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PeriodicTableScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessItem(
                            context,
                            imagePath: 'assets/svgs/molecule.svg',
                            label: 'Compound Explorer',
                            color: theme.colorScheme.secondary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CompoundSearchScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessItem(
                            context,
                            imagePath: 'assets/svgs/drug.svg',
                            label: 'Drug Explorer',
                            color: theme.colorScheme.inverseSurface,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DrugSearchScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessItem(
                            context,
                            imagePath: 'assets/svgs/drug.svg',
                            label: 'Reactions',
                            color: Colors.deepOrange,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReactionScreen(),
                              ),
                            ),
                          ),
                          _buildQuickAccessItem(
                            context,
                            imagePath: 'assets/svgs/chemistry-guide.svg',
                            label: 'Chemistry Guide',
                            color: Colors.amber.shade800,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChemistryGuideScreen(),
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
          ),

          // Daily Chemistry Fact
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: AnimatedBuilder(
                animation: _greetingAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, 30 * (1 - _greetingAnimationController.value)),
                    child: Opacity(
                      opacity: _greetingAnimationController.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.8),
                              theme.colorScheme.tertiary ?? Colors.purple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Did You Know?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                _chemistryFacts[_currentFactIndex],
                                key: ValueKey<int>(_currentFactIndex),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Chemistry Fact #${_currentFactIndex + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: theme.colorScheme.onPrimary
                                        .withOpacity(0.7),
                                  ),
                                ),
                                Icon(
                                  Icons.science,
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

          // Main Features
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Chemistry',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Feature Cards with Animation
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverAnimationBuilder(
              child: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    context,
                    imagePath: 'assets/svgs/periodictable.svg',
                    title: 'Periodic Table',
                    description: 'Explore elements and their properties',
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    iconColor: theme.colorScheme.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PeriodicTableScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    imagePath: 'assets/svgs/molecule.svg',
                    title: 'Compound Explorer',
                    description:
                        'Explore compound compounds and their properties',
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    iconColor: theme.colorScheme.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompoundSearchScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    imagePath: 'assets/svgs/drug.svg',
                    title: 'Pharmaceuticals',
                    description: 'Explore drug compounds and their properties',
                    color:
                        theme.colorScheme.secondaryContainer.withOpacity(0.1),
                    iconColor: Colors.deepOrange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DrugSearchScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    imagePath: 'assets/svgs/reaction.svg',
                    title: 'Chemical Reactions',
                    description: 'Study and explore chemical reactions',
                    color: Colors.teal.withOpacity(0.1),
                    iconColor: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReactionScreen(),
                      ),
                    ),
                  ),
                  _buildFeatureCard(
                    context,
                    imagePath: 'assets/svgs/chemistry-guide.svg',
                    title: 'Chemistry Guide',
                    description: 'Learn basic chemistry concepts',
                    color: Colors.amber.withOpacity(0.1),
                    iconColor: Colors.amber.shade800,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChemistryGuideScreen(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // Spacer at bottom
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context, {
    required String imagePath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        horizontalOffset: 50,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      imagePath,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                imagePath,
                width: 30,
                height: 30,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Add floating element widget for chemistry symbols
  Widget _buildFloatingElement(String symbol, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Helper class for staggered animations
class SliverAnimationBuilder extends StatelessWidget {
  final Widget child;

  const SliverAnimationBuilder({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: child,
    );
  }
}
