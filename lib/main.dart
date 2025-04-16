import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'providers/compound_provider.dart';
import 'providers/drug_provider.dart';
import 'providers/element_provider.dart';
import 'providers/molecular_structure_provider.dart';
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
        home: const MainScreen(),
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
    const PeriodicTableScreen(),
    CompoundSearchPage(), // Compounds screen
    DrugSearchPage(), // Drugs screen
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chemistry Explorer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            FeatureCard(
              title: 'Compounds Search',
              icon: Icons.science,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CompoundSearchPage()),
              ),
            ),
            FeatureCard(
              title: 'Periodic Table',
              icon: Icons.grid_on,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PeriodicTablePage()),
              ),
            ),
            FeatureCard(
              title: 'Drug Information',
              icon: Icons.medication,
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DrugSearchPage()),
              ),
            ),
            FeatureCard(
              title: 'Molecular Structures',
              icon: Icons.category,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MolecularStructurePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// COMPOUND SEARCH PAGE
class CompoundSearchPage extends StatefulWidget {
  @override
  _CompoundSearchPageState createState() => _CompoundSearchPageState();
}

class _CompoundSearchPageState extends State<CompoundSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _compoundList = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchCompoundList(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _compoundList.clear();
    });

    try {
      // Step 1: Get CIDs using synonym search
      final cidUrl =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON';
      final cidResponse = await http.get(Uri.parse(cidUrl));

      if (cidResponse.statusCode != 200) {
        throw Exception('Failed to fetch compounds');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$query".');
      }

      // Limit to first 10
      final limitedCids = cids.take(10).join(',');

      // Step 2: Fetch properties for the CIDs
      final propertiesUrl =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,HBondDonorCount,HBondAcceptorCount,RotatableBondCount/JSON';
      final propertiesResponse = await http.get(Uri.parse(propertiesUrl));

      if (propertiesResponse.statusCode != 200) {
        throw Exception('Failed to fetch compound properties');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      final List<dynamic> compoundData =
          propertiesData['PropertyTable']['Properties'];

      setState(() {
        _compoundList =
            compoundData.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compound Search'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter compound name (e.g., "aspirin", "caffeine")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: _fetchCompoundList,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchCompoundList(_controller.text.trim()),
              icon: Icon(Icons.science),
              label: Text("Search Compound"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            else if (_compoundList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _compoundList.length,
                  itemBuilder: (context, index) {
                    final compound = _compoundList[index];
                    return CompoundCard(compound: compound);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CompoundCard extends StatelessWidget {
  final Map<String, dynamic> compound;

  const CompoundCard({required this.compound});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          compound['Title'] ?? 'Compound #${compound['CID']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(compound['MolecularFormula'] ?? 'No formula available'),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            (compound['Title'] ?? 'X').substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.blue.shade800),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow(
                    'Molecular Weight', '${compound['MolecularWeight']} g/mol'),
                _buildPropertyRow('SMILES', compound['CanonicalSMILES']),
                _buildPropertyRow('XLogP', '${compound['XLogP']}'),
                _buildPropertyRow(
                    'H-Bond Donors', '${compound['HBondDonorCount']}'),
                _buildPropertyRow(
                    'H-Bond Acceptors', '${compound['HBondAcceptorCount']}'),
                _buildPropertyRow(
                    'Rotatable Bonds', '${compound['RotatableBondCount']}'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompoundDetailsPage(cid: compound['CID']),
                      ),
                    );
                  },
                  child: Text('View More Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class CompoundDetailsPage extends StatefulWidget {
  final int cid;

  const CompoundDetailsPage({required this.cid});

  @override
  _CompoundDetailsPageState createState() => _CompoundDetailsPageState();
}

class _CompoundDetailsPageState extends State<CompoundDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _compoundData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCompoundDetails();
  }

  Future<void> _fetchCompoundDetails() async {
    try {
      // Fetch detailed information
      final url =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/${widget.cid}/JSON';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch compound details');
      }

      final data = json.decode(response.body);

      setState(() {
        _compoundData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String? _extractSection(String sectionName) {
    if (_compoundData == null) return null;

    try {
      final sections = _compoundData!['Record']['Section'] as List;
      for (var section in sections) {
        if (section['TOCHeading'] == sectionName &&
            section['Information'] != null) {
          final info = section['Information'] as List;
          if (info.isNotEmpty && info[0]['Value'] != null) {
            if (info[0]['Value'] is Map &&
                info[0]['Value']['StringWithMarkup'] != null) {
              final stringWithMarkup =
                  info[0]['Value']['StringWithMarkup'] as List;
              if (stringWithMarkup.isNotEmpty &&
                  stringWithMarkup[0]['String'] != null) {
                return stringWithMarkup[0]['String'];
              }
            } else if (info[0]['Value'] is String) {
              return info[0]['Value'];
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting section $sectionName: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compound Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCompoundDetails,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _compoundData == null
                  ? Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image section
                          Center(
                            child: Image.network(
                              'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${widget.cid}/PNG',
                              width: 200,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported, size: 100),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            _compoundData!['Record']['RecordTitle'] ??
                                'Compound Details',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Divider(),

                          // Description
                          _buildInfoSection(
                              'Description',
                              _extractSection(
                                  'Chemical and Physical Properties')),

                          // Pharmacology
                          _buildInfoSection('Pharmacology',
                              _extractSection('Pharmacology and Biochemistry')),

                          // Uses
                          _buildInfoSection(
                              'Uses', _extractSection('Use and Manufacturing')),

                          // Safety
                          _buildInfoSection(
                              'Safety', _extractSection('Safety and Hazards')),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoSection(String title, String? content) {
    if (content == null || content.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(content),
        Divider(),
      ],
    );
  }
}

class PeriodicTablePage extends StatefulWidget {
  @override
  _PeriodicTablePageState createState() => _PeriodicTablePageState();
}

class _PeriodicTablePageState extends State<PeriodicTablePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _elements = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPeriodicTableData();
  }

  Future<void> _fetchPeriodicTableData() async {
    try {
      print('Fetching periodic table data...');
      final response = await http.get(
        Uri.parse('https://api.apiverve.com/v1/periodictable?list=all'),
        headers: {
          'x-api-key': 'e1618d6d-e3bd-4e26-bfc3-aff9421eb640',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch periodic table data. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      print('Parsed data: $data');

      if (data['status'] != 'ok') {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }

      if (data['data'] == null) {
        throw Exception('No data received for periodic table');
      }

      setState(() {
        _elements = List<Map<String, dynamic>>.from(data['data'] ?? []);
        _isLoading = false;
      });
      print('Successfully loaded ${_elements.length} elements');
    } catch (e) {
      print('Error in _fetchPeriodicTableData: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Periodic Table'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPeriodicTableData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPeriodicTableData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width < 600
                                    ? 6 // For smaller screens (like mobile)
                                    : 10, // For larger screens (like tablets)
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                          ),
                          itemCount: _elements.length,
                          itemBuilder: (context, index) {
                            final element = _elements[index];
                            return ElementCard(element: element);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class ElementCard extends StatelessWidget {
  final Map<String, dynamic> element;

  const ElementCard({required this.element});

  Color _getElementColor() {
    String category = element['category'] ?? '';
    switch (category.toLowerCase()) {
      case 'diatomic nonmetal':
      case 'polyatomic nonmetal':
        return Colors.green;
      case 'alkali metal':
        return Colors.red;
      case 'alkaline earth metal':
        return Colors.orange;
      case 'transition metal':
        return Colors.yellow.shade700;
      case 'metalloid':
        return Colors.purple;
      case 'halogen':
        return Colors.lightBlue;
      case 'noble gas':
        return Colors.blue;
      case 'lanthanide':
        return Colors.pink;
      case 'actinide':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  String _formatAtomicMass(dynamic mass) {
    if (mass == null) return '?';

    if (mass is num) {
      String formatted = mass.toStringAsFixed(2);
      while (formatted.endsWith('0')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
      return formatted;
    }

    return mass.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getElementColor().withOpacity(0.3),
      elevation: 3,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ElementDetailsPage(element: element),
            ),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              padding: EdgeInsets.all(1),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  width: 50,
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${element['number']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        element['symbol'] ?? '?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        element['name'] ?? 'Unknown',
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatAtomicMass(element['atomic_mass']),
                        style: TextStyle(fontSize: 8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ElementDetailsPage extends StatefulWidget {
  final Map<String, dynamic> element;

  const ElementDetailsPage({required this.element});

  @override
  _ElementDetailsPageState createState() => _ElementDetailsPageState();
}

class _ElementDetailsPageState extends State<ElementDetailsPage> {
  Map<String, dynamic>? _detailedElement;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetailedElement();
  }

  Future<void> _fetchDetailedElement() async {
    try {
      final elementSymbol = widget.element['symbol'];
      print('Fetching details for element symbol: $elementSymbol');

      final response = await http.get(
        Uri.parse(
            'https://api.apiverve.com/v1/periodictable?symbol=$elementSymbol'),
        headers: {
          'x-api-key': 'e1618d6d-e3bd-4e26-bfc3-aff9421eb640',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch element details. Status code: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      print('Parsed data: $data');

      if (data['status'] != 'ok') {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }

      if (data['data'] == null) {
        throw Exception('No data received for element $elementSymbol');
      }

      setState(() {
        _detailedElement = data['data'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _fetchDetailedElement: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final element = _detailedElement ?? widget.element;

    return Scaffold(
      appBar: AppBar(
        title: Text('Element: ${element['name']}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDetailedElement,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                element['symbol'] ?? '?',
                                style: TextStyle(
                                    fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  element['name'] ?? 'Unknown',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text('Atomic Number: ${element['number']}'),
                                Text(
                                    'Atomic Mass: ${element['atomic_mass']} u'),
                                Text('Group: ${element['group'] ?? 'N/A'}'),
                                Text('Period: ${element['period'] ?? 'N/A'}'),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(height: 32),

                      // Physical Properties
                      _buildSectionTitle('Physical Properties'),
                      _buildPropertyRow(
                          'Appearance', element['appearance'] ?? 'Unknown'),
                      _buildPropertyRow('Phase', element['phase'] ?? 'Unknown'),
                      _buildPropertyRow(
                          'Category', element['category'] ?? 'Unknown'),
                      _buildPropertyRow('Density',
                          '${element['density'] ?? 'Unknown'} g/cm³'),
                      _buildPropertyRow(
                          'Melting Point', '${element['melt'] ?? 'Unknown'} K'),
                      _buildPropertyRow(
                          'Boiling Point', '${element['boil'] ?? 'Unknown'} K'),
                      _buildPropertyRow('Molar Heat',
                          '${element['molar_heat'] ?? 'Unknown'} J/(mol·K)'),

                      Divider(height: 32),

                      // Atomic Properties
                      _buildSectionTitle('Atomic Properties'),
                      _buildPropertyRow('Electron Configuration',
                          element['electron_configuration'] ?? 'Unknown'),
                      _buildPropertyRow('Electron Affinity',
                          '${element['electron_affinity'] ?? 'Unknown'} kJ/mol'),
                      _buildPropertyRow('Electronegativity (Pauling)',
                          '${element['electronegativity_pauling'] ?? 'Unknown'}'),
                      _buildPropertyRow(
                          'Ionization Energies',
                          element['ionization_energies']?.join(', ') ??
                              'Unknown'),
                      _buildPropertyRow(
                          'Shells', element['shells']?.join(', ') ?? 'Unknown'),

                      Divider(height: 32),

                      // Discovery Information
                      _buildSectionTitle('Discovery Information'),
                      _buildPropertyRow('Discovered By',
                          element['discovered_by'] ?? 'Unknown'),
                      _buildPropertyRow(
                          'Named By', element['named_by'] ?? 'Unknown'),
                      _buildPropertyRow(
                          'Source', element['source'] ?? 'Unknown'),

                      Divider(height: 32),

                      // Summary
                      _buildSectionTitle('Summary'),
                      Text(element['summary'] ?? 'No summary available.'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPropertyRow(String property, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$property:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// DRUG SEARCH PAGE
class DrugSearchPage extends StatefulWidget {
  @override
  _DrugSearchPageState createState() => _DrugSearchPageState();
}

class _DrugSearchPageState extends State<DrugSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _drugList = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchDrugList(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _drugList.clear();
    });

    try {
      // First get the CIDs for the drug name
      final cidUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON');
      final cidResponse = await http.get(cidUrl);

      if (cidResponse.statusCode != 200) {
        throw Exception('Failed to fetch drug information');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No drugs found for "$query".');
      }

      // Limit to first 5 for better performance
      final limitedCids = cids.take(5).join(',');

      // Get drug properties
      final propertiesUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,ComplexityScore,HBondDonorCount,HBondAcceptorCount,RotatableBondCount/JSON');
      final propertiesResponse = await http.get(propertiesUrl);

      if (propertiesResponse.statusCode != 200) {
        throw Exception('Failed to fetch drug properties');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      final List<dynamic> drugData =
          propertiesData['PropertyTable']['Properties'];

      setState(() {
        _drugList = drugData.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drug Information'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _fetchDrugList(_controller.text.trim()),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter drug name (e.g., "aspirin", "ibuprofen")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.medication),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _drugList.clear();
                    });
                  },
                ),
              ),
              onSubmitted: _fetchDrugList,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchDrugList(_controller.text.trim()),
              icon: Icon(Icons.search),
              label: Text("Search Drug"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _fetchDrugList(_controller.text.trim()),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_drugList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _drugList.length,
                  itemBuilder: (context, index) {
                    final drug = _drugList[index];
                    return DrugCard(drug: drug);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DrugCard extends StatelessWidget {
  final Map<String, dynamic> drug;

  const DrugCard({required this.drug});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              drug['Title'] ?? 'Unknown Drug',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(drug['MolecularFormula'] ?? 'Formula unavailable'),
            leading: Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${drug['CID']}/PNG',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.medication, size: 40),
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrugDetailsPage(cid: drug['CID']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Molecular Weight', '${drug['MolecularWeight']} g/mol'),
                _buildInfoRow('XLogP', '${drug['XLogP']}'),
                _buildInfoRow('Complexity', '${drug['ComplexityScore']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}

class DrugDetailsPage extends StatefulWidget {
  final int cid;

  const DrugDetailsPage({required this.cid});

  @override
  _DrugDetailsPageState createState() => _DrugDetailsPageState();
}

class _DrugDetailsPageState extends State<DrugDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _drugData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDrugDetails();
  }

  Future<void> _fetchDrugDetails() async {
    try {
      // Fetch detailed drug information
      final url =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/${widget.cid}/JSON';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch drug details');
      }

      final data = json.decode(response.body);

      setState(() {
        _drugData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String? _extractSection(String sectionName) {
    if (_drugData == null) return null;

    try {
      final sections = _drugData!['Record']['Section'] as List;
      for (var section in sections) {
        if (section['TOCHeading'] == sectionName &&
            section['Information'] != null) {
          final info = section['Information'] as List;
          if (info.isNotEmpty && info[0]['Value'] != null) {
            if (info[0]['Value'] is Map &&
                info[0]['Value']['StringWithMarkup'] != null) {
              final stringWithMarkup =
                  info[0]['Value']['StringWithMarkup'] as List;
              if (stringWithMarkup.isNotEmpty &&
                  stringWithMarkup[0]['String'] != null) {
                return stringWithMarkup[0]['String'];
              }
            } else if (info[0]['Value'] is String) {
              return info[0]['Value'];
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting section $sectionName: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drug Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style: TextStyle(color: Colors.red)))
              : _drugData == null
                  ? Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drug image and title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${widget.cid}/PNG',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported,
                                            size: 60),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _drugData!['Record']['RecordTitle'] ??
                                          'Drug Details',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'CID: ${widget.cid}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Divider(height: 32),

                          // Drug information sections
                          _buildInfoSection(
                              'Drug Indication',
                              _extractSection(
                                  'Drug and Medication Information')),
                          _buildInfoSection('Pharmacology',
                              _extractSection('Pharmacology and Biochemistry')),
                          _buildInfoSection('Clinical Use',
                              _extractSection('Clinical Trials and Use')),
                          _buildInfoSection(
                              'Toxicity', _extractSection('Toxicity')),
                          _buildInfoSection('Safety Information',
                              _extractSection('Safety and Hazards')),
                          _buildInfoSection(
                              'Metabolism',
                              _extractSection(
                                  'Absorption, Distribution and Metabolism')),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoSection(String title, String? content) {
    if (content == null || content.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}

// MOLECULAR STRUCTURE PAGE
class MolecularStructurePage extends StatefulWidget {
  @override
  _MolecularStructurePageState createState() => _MolecularStructurePageState();
}

class _MolecularStructurePageState extends State<MolecularStructurePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _moleculeList = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchMolecularStructures(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _moleculeList.clear();
    });

    try {
      // First get the CIDs for the compound name
      final cidUrl =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON';
      final cidResponse = await http.get(Uri.parse(cidUrl));

      if (cidResponse.statusCode != 200) {
        throw Exception('Failed to fetch compound information');
      }

      final cidData = json.decode(cidResponse.body);
      final List<dynamic> cids = cidData['IdentifierList']?['CID'] ?? [];

      if (cids.isEmpty) {
        throw Exception('No compounds found for "$query".');
      }

      // Limit to first 10
      final limitedCids = cids.take(10).join(',');

      // Get molecule properties with focus on structural information
      final propertiesUrl =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$limitedCids/property/Title,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP,Complexity,HBondDonorCount,HBondAcceptorCount,RotatableBondCount,HeavyAtomCount,AtomStereoCount,BondStereoCount/JSON';
      final propertiesResponse = await http.get(Uri.parse(propertiesUrl));

      if (propertiesResponse.statusCode != 200) {
        throw Exception('Failed to fetch molecular properties');
      }

      final propertiesData = json.decode(propertiesResponse.body);
      final List<dynamic> moleculeData =
          propertiesData['PropertyTable']['Properties'];

      setState(() {
        _moleculeList =
            moleculeData.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Molecular Structures'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter compound name (e.g., "glucose", "benzene")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.category),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: _fetchMolecularStructures,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _fetchMolecularStructures(_controller.text.trim()),
              icon: Icon(Icons.search),
              label: Text("Search Structures"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            else if (_moleculeList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _moleculeList.length,
                  itemBuilder: (context, index) {
                    final molecule = _moleculeList[index];
                    return MoleculeCard(molecule: molecule);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MoleculeCard extends StatelessWidget {
  final Map<String, dynamic> molecule;

  const MoleculeCard({required this.molecule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Image and basic info
          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: EdgeInsets.all(8),
                child: Image.network(
                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${molecule['CID']}/PNG',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.category, size: 60),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        molecule['Title'] ?? 'Unknown Compound',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        molecule['MolecularFormula'] ?? 'Formula unavailable',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 4),
                      Text(
                          'Molecular Weight: ${molecule['MolecularWeight']} g/mol'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Divider
          Divider(height: 1),

          // Structural properties
          ExpansionTile(
            title: Text('Structural Properties'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStructuralPropertyRow('Heavy Atoms',
                        molecule['HeavyAtomCount']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('H-Bond Donors',
                        molecule['HBondDonorCount']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('H-Bond Acceptors',
                        molecule['HBondAcceptorCount']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Rotatable Bonds',
                        molecule['RotatableBondCount']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Stereogenic Atoms',
                        molecule['AtomStereoCount']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Stereogenic Bonds',
                        molecule['BondStereoCount']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Complexity',
                        molecule['Complexity']?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow(
                        'XLogP', molecule['XLogP']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),

          // SMILES notation
          ExpansionTile(
            title: Text('SMILES Notation'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Canonical SMILES:'),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        molecule['CanonicalSMILES'] ?? 'Not available',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // View 3D button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MoleculeVisualizationPage(cid: molecule['CID']),
                  ),
                );
              },
              icon: Icon(Icons.view_in_ar),
              label: Text('View 3D Structure'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuralPropertyRow(String property, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            property,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class MoleculeVisualizationPage extends StatefulWidget {
  final int cid;

  const MoleculeVisualizationPage({required this.cid});

  @override
  _MoleculeVisualizationPageState createState() =>
      _MoleculeVisualizationPageState();
}

class _MoleculeVisualizationPageState extends State<MoleculeVisualizationPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;
  String _viewType = '3D'; // or '2D'

  @override
  void initState() {
    super.initState();
    _fetchMoleculeData();
  }

  Future<void> _fetchMoleculeData() async {
    try {
      final url =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/${widget.cid}/JSON';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch molecule details');
      }

      final data = json.decode(response.body);

      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Molecule Visualization'),
        actions: [
          ToggleButtons(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('2D'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('3D'),
              ),
            ],
            isSelected: [_viewType == '2D', _viewType == '3D'],
            onPressed: (index) {
              setState(() {
                _viewType = index == 0 ? '2D' : '3D';
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Compound name
                      if (_data != null)
                        Text(
                          _data!['Record']['RecordTitle'] ??
                              'Molecule Structure',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 24),

                      // Structure view
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.network(
                            _viewType == '3D'
                                ? 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${widget.cid}/PNG?image_size=500x500&image_type=3d'
                                : 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${widget.cid}/PNG?image_size=500x500',
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 50),
                                  Text('Could not load image'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Note about 3D view
                      if (_viewType == '3D')
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About 3D Structure',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                    'This is a static 3D representation. In a full implementation, this could be replaced with an interactive 3D model using a Flutter package for molecular visualization.'),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 24),

                      // Structure explanation
                      Text(
                        'Structure Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atoms and Bonds',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Different colors represent different atoms:\n• Black: Carbon\n• White: Hydrogen\n• Red: Oxygen\n• Blue: Nitrogen\n• Yellow: Sulfur\n• Green: Halogens (Cl, Br, I, F)',
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Bond Types',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Single bonds: One line\n• Double bonds: Two lines\n• Triple bonds: Three lines\n• Aromatic bonds: Dashed lines or circles in aromatic systems',
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Download buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // In a real app, this would download the 2D image
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Download feature would be implemented here')),
                                );
                              },
                              icon: Icon(Icons.download),
                              label: Text('Save 2D Structure'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // In a real app, this would download the 3D model
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Download feature would be implemented here')),
                                );
                              },
                              icon: Icon(Icons.download),
                              label: Text('Save 3D Structure'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
