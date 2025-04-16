import 'package:chem_explore/screens/compounds/compound_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/compound_provider.dart';
import 'providers/drug_provider.dart';
import 'providers/element_provider.dart';
import 'providers/molecular_structure_provider.dart';
import 'screens/drugs/drug_search_screen.dart';
import 'screens/elements/periodic_table_homescreen.dart';
import 'screens/elements/periodic_table_screen.dart';
import 'screens/compounds/molecular_structure_screen.dart';

void main() {
  runApp(const ChemistryExplorerApp());
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
        ChangeNotifierProvider(create: (_) => MolecularStructureProvider()),
      ],
      child: MaterialApp(
        title: 'Chemistry Explorer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PeriodicTableHomeScreen(),
    const CompoundSearchScreen(), // Compounds screen
    const DrugSearchScreen(), // Drugs screen
    const MolecularStructureScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.science),
            label: 'Elements',
          ),
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Compounds',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication),
            label: 'Drugs',
          ),
          NavigationDestination(
            icon: Icon(Icons.science),
            label: 'Molecular Structures',
          ),
        ],
      ),
    );
  }
}
