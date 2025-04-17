import 'package:chem_explore/providers/flashcard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/compound_provider.dart';
import 'providers/drug_provider.dart';
import 'providers/element_provider.dart';
import 'providers/reaction_provider.dart';
import 'providers/bookmark_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
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
  const ChemistryExplorerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ElementProvider()),
        ChangeNotifierProvider(create: (_) => CompoundProvider()),
        ChangeNotifierProvider(create: (_) => DrugProvider()),
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
      ],
      child: MaterialApp(
        title: 'ChemVerse',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
