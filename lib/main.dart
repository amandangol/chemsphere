import 'package:chem_explore/features/elements/provider/element_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/compounds/provider/chemical_search_provider.dart';
import 'features/compounds/provider/compound_provider.dart';
import 'features/formula/provider/formula_search_provider.dart';
import 'features/drugs/provider/drug_provider.dart';
import 'features/reactions/provider/reaction_provider.dart';
import 'features/bookmarks/provider/bookmark_provider.dart';
import 'features/chemistryguide/provider/chemistry_guide_provider.dart';
import 'features/molecular_weight/provider/molecular_weight_provider.dart';
import 'features/molecular_weight/screens/molecular_weight_screen.dart';
import 'features/main_screen.dart';
import 'features/aqi/provider/aqi_provider.dart';
import 'features/aqi/provider/pollutant_info_provider.dart';
import 'features/splash_screen.dart';
import 'features/onboarding/screen/onboarding_screen.dart';
import 'features/onboarding/provider/onboarding_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check if it's the first time launch using the provider's static method
  final bool isFirstTime = await OnboardingProvider.isFirstTime();

  runApp(ChemistryExplorerApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChemVerse',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChemistryExplorerApp extends StatelessWidget {
  final bool isFirstTime;

  const ChemistryExplorerApp({
    Key? key,
    required this.isFirstTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ElementProvider()),
        ChangeNotifierProvider(create: (_) => CompoundProvider()),
        ChangeNotifierProvider(create: (_) => DrugProvider()),
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ChemistryGuideProvider()),
        ChangeNotifierProvider(create: (_) => FormulaSearchProvider()),
        ChangeNotifierProvider(create: (_) => ChemicalSearchProvider()),
        ChangeNotifierProvider(create: (_) => AqiProvider()),
        ChangeNotifierProvider(create: (_) => PollutantInfoProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        // MolecularWeightProvider depends on ElementProvider
        ChangeNotifierProxyProvider<ElementProvider, MolecularWeightProvider>(
          create: (context) => MolecularWeightProvider(
              Provider.of<ElementProvider>(context, listen: false)),
          update: (context, elementProvider, previous) =>
              previous ?? MolecularWeightProvider(elementProvider),
        ),
      ],
      child: MaterialApp(
        title: 'ChemVerse',
        theme: AppTheme.lightTheme,
        // Show onboarding if it's first time, otherwise show splash screen
        home: isFirstTime ? const OnboardingScreen() : const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/main': (context) => const MainScreen(initialIndex: 0),
          '/city-search': (context) => const MainScreen(initialIndex: 2),
          '/molecular-weight': (context) => const MolecularWeightScreen(),
        },
        //  global back button handling for Android
        builder: (context, child) {
          return WillPopScope(
            onWillPop: () async {
              // Let the app-specific screens handle back button themselves
              return true;
            },
            child: child!,
          );
        },
      ),
    );
  }
}
