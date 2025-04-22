import 'package:chem_explore/features/elements/screens/modern_periodictable/modern_periodic_table_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../aqi/aqi_indicator_widget.dart';
import '../elements/screens/periodic_tablescreen/periodic_table_screen.dart';
import '../compounds/compound_searhc_screen.dart';
import '../drugs/drug_search_screen.dart';
import '../chemistryguide/chemistry_guide_screen.dart';
import '../formula/screen/formula_search_screen.dart';
import '../aqi/city_search_screen.dart';
import '../molecules_viewer/screen/molecule_viewer_screen.dart';
import '../molecular_weight/screens/molecular_weight_screen.dart';

// Import the widgets
import 'widgets/home_header_widget.dart';
import 'widgets/chemistry_fact_widget.dart';
import 'widgets/feature_cards.dart';
import 'widgets/chemistry_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _greetingAnimationController;

  @override
  void initState() {
    super.initState();

    // Greeting animation
    _greetingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _greetingAnimationController.forward();
    });
  }

  @override
  void dispose() {
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

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Wave Animation and Molecular Design
          SliverToBoxAdapter(
            child: HomeHeaderWidget(),
          ),

          // AQI Widget - Enhanced air quality indicator
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AqiIndicatorWidget(),
            ),
          ),

          // Daily Chemistry Fact - Moved up for better visibility
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ChemistryFactWidget(
                animationController: _greetingAnimationController,
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
                MainFeatureCard(
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
                MainFeatureCard(
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

                // Modern Periodic Table - Moved from "More Features" to "Explore Chemistry" for better categorization
                MainFeatureCard(
                  title: 'Modern Periodic Table',
                  description: 'Interactive periodic table',
                  icon: Icons.auto_awesome_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModernPeriodicTableScreen(),
                    ),
                  ),
                ),

                // Learning Resources
                MainFeatureCard(
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
              ]),
            ),
          ),

          // Chemistry Tools Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Chemistry Tools',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Chemistry Tools in a horizontal scrollable row
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Molecular Weight Calculator
                  SecondaryFeatureCard(
                    title: 'Molecular Weight',
                    icon: Icons.calculate_rounded,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MolecularWeightScreen(),
                      ),
                    ),
                  ),
                  // Formula Search
                  SecondaryFeatureCard(
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
                  // 3D Molecule Viewer
                  SecondaryFeatureCard(
                    title: '3D Molecule Viewer',
                    icon: Icons.view_in_ar_rounded,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoleculeViewerScreen(),
                      ),
                    ),
                  ),
                  // Chemical Reactions
                  SecondaryFeatureCard(
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

          // Health & Environment Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Health & Environment',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Health & Environment Features
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Air Quality
                  SecondaryFeatureCard(
                    title: 'Air Quality',
                    icon: Icons.air_rounded,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CitySearchScreen(),
                      ),
                    ),
                  ),
                  // Drug Explorer
                  SecondaryFeatureCard(
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
                ],
              ),
            ),
          ),

          // Animated Lottie Chemistry Animation
          SliverToBoxAdapter(
            child: ChemistryAnimationWidget(
              animation: _greetingAnimationController,
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
}
