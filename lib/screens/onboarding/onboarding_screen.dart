import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../splash_screen.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to ChemVerse',
      description: 'Your ultimate chemistry exploration companion',
      imagePath: 'assets/svgs/welcometochem.svg',
      backgroundColor: const Color(0xFFE3F2FD),
    ),
    OnboardingPage(
      title: 'Explore Elements',
      description:
          'Discover all elements in the periodic table with detailed information',
      imagePath: 'assets/svgs/atoms.svg',
      backgroundColor: const Color(0xFFE8F5E9),
    ),
    OnboardingPage(
      title: 'Learn About Compounds',
      description:
          'Search and view detailed information about chemical compounds',
      imagePath: 'assets/svgs/molecules.svg',
      backgroundColor: const Color(0xFFFFF8E1),
    ),
    OnboardingPage(
      title: 'Track Air Quality',
      description:
          'Search cities or use your location to monitor real-time air quality data and pollutant levels',
      imagePath: 'assets/svgs/air_quality.svg',
      backgroundColor: const Color(0xFFE1F5FE),
    ),
    OnboardingPage(
      title: 'Educational Resources',
      description:
          'Study from flashcards, chemistry guides, and interactive lessons',
      imagePath: 'assets/svgs/education.svg',
      backgroundColor: const Color(0xFFF3E5F5),
    ),
    OnboardingPage(
      title: 'Bookmarks & Formulas',
      description:
          'Save your favorite elements, compounds, and reactions for quick access',
      imagePath: 'assets/svgs/reaction.svg',
      backgroundColor: const Color(0xFFE8EAF6),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            body: Stack(
              children: [
                // Page view
                PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    provider.setPage(index);
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      color: _pages[index].backgroundColor,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // SVG Image
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: SvgPicture.asset(
                                    _pages[index].imagePath,
                                    height: 260,
                                    placeholderBuilder: (context) => Icon(
                                      _getIconForPage(index),
                                      size: 150,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Title
                              Text(
                                _pages[index].title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              // Description
                              Text(
                                _pages[index].description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.black54,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              const Expanded(
                                flex: 2,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Indicator and buttons
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 10,
                            width: provider.currentPage == index ? 30 : 10,
                            decoration: BoxDecoration(
                              color: provider.currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Navigation buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Skip/Back button
                            provider.currentPage > 0
                                ? TextButton(
                                    onPressed: () {
                                      provider.previousPage();
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Text(
                                      'Back',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: () async {
                                      await provider.completeOnboarding();
                                      if (mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SplashScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),

                            // Next/Get Started button
                            ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      if (provider.currentPage <
                                          _pages.length - 1) {
                                        provider.nextPage();
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      } else {
                                        await provider.completeOnboarding();
                                        if (mounted) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SplashScreen(),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: provider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      provider.currentPage < _pages.length - 1
                                          ? 'Next'
                                          : 'Get Started',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.science;
      case 1:
        return Icons.table_chart_rounded;
      case 2:
        return Icons.bubble_chart;
      case 3:
        return Icons.air_rounded;
      case 4:
        return Icons.school_rounded;
      case 5:
        return Icons.bookmark_rounded;
      default:
        return Icons.science;
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}
