import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../utils/url_launcher_util.dart';
import '../../compounds/provider/compound_provider.dart';
import '../../../utils/error_handler.dart';

// Import the newly created widget components
import '../widgets/molecule_viewer_tab.dart';
import '../widgets/featured_molecules_tab.dart';
import '../widgets/recent_molecules_tab.dart';
import '../widgets/fullscreen_molecule_view.dart';

class MoleculeViewerScreen extends StatefulWidget {
  final int? initialCid;

  const MoleculeViewerScreen({
    Key? key,
    this.initialCid,
  }) : super(key: key);

  @override
  State<MoleculeViewerScreen> createState() => _MoleculeViewerScreenState();
}

class _MoleculeViewerScreenState extends State<MoleculeViewerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  int? _currentCid;
  String _currentMoleculeName = '';
  bool _isLoading = false;
  String? _error;
  bool _isFullScreen = false;
  bool _is2DView = false; // Toggle between 2D and 3D view
  String _currentFormula = ''; // Store molecular formula
  List<Map<String, dynamic>> _recentMolecules = [];

  // Organized featured molecules by category
  final List<Map<String, dynamic>> _featuredMolecules = [
    // Common molecules
    {'name': 'Water', 'cid': 962, 'category': 'Common', 'formula': 'H₂O'},
    {
      'name': 'Carbon Dioxide',
      'cid': 280,
      'category': 'Common',
      'formula': 'CO₂'
    },
    {'name': 'Oxygen', 'cid': 977, 'category': 'Common', 'formula': 'O₂'},
    {'name': 'Methane', 'cid': 297, 'category': 'Common', 'formula': 'CH₄'},
    {'name': 'Ammonia', 'cid': 222, 'category': 'Common', 'formula': 'NH₃'},
    {
      'name': 'Sodium Chloride',
      'cid': 5234,
      'category': 'Common',
      'formula': 'NaCl'
    },

    // Organic compounds
    {
      'name': 'Glucose',
      'cid': 5793,
      'category': 'Organic',
      'formula': 'C₆H₁₂O₆'
    },
    {'name': 'Ethanol', 'cid': 702, 'category': 'Organic', 'formula': 'C₂H₅OH'},
    {
      'name': 'Acetic Acid',
      'cid': 176,
      'category': 'Organic',
      'formula': 'CH₃COOH'
    },
    {'name': 'Benzene', 'cid': 241, 'category': 'Organic', 'formula': 'C₆H₆'},
    {'name': 'Acetone', 'cid': 180, 'category': 'Organic', 'formula': 'C₃H₆O'},
    {
      'name': 'Citric Acid',
      'cid': 311,
      'category': 'Organic',
      'formula': 'C₆H₈O₇'
    },

    // Biochemicals
    {
      'name': 'Ascorbic Acid (Vitamin C)',
      'cid': 54670067,
      'category': 'Biochemical',
      'formula': 'C₆H₈O₆'
    },
    {
      'name': 'Cholesterol',
      'cid': 5997,
      'category': 'Biochemical',
      'formula': 'C₂₇H₄₆O'
    },
    {
      'name': 'Adenosine Triphosphate (ATP)',
      'cid': 5957,
      'category': 'Biochemical',
      'formula': 'C₁₀H₁₆N₅O₁₃P₃'
    },
    {
      'name': 'Adrenaline (Epinephrine)',
      'cid': 5816,
      'category': 'Biochemical',
      'formula': 'C₉H₁₃NO₃'
    },

    // Drugs and pharmaceuticals
    {'name': 'Aspirin', 'cid': 2244, 'category': 'Drug', 'formula': 'C₉H₈O₄'},
    {
      'name': 'Caffeine',
      'cid': 2519,
      'category': 'Drug',
      'formula': 'C₈H₁₀N₄O₂'
    },
    {
      'name': 'Paracetamol',
      'cid': 1983,
      'category': 'Drug',
      'formula': 'C₈H₉NO₂'
    },
    {
      'name': 'Ibuprofen',
      'cid': 3672,
      'category': 'Drug',
      'formula': 'C₁₃H₁₈O₂'
    },
    {
      'name': 'Penicillin G',
      'cid': 5904,
      'category': 'Drug',
      'formula': 'C₁₆H₁₈N₂O₄S'
    },

    // Complex structures
    {
      'name': 'Hemoglobin',
      'cid': 3425436,
      'category': 'Complex',
      'formula': 'C₂₉₅₂H₄₆₆₄N₈₁₂O₈₃₂S₈Fe₄'
    },
    {
      'name': 'Insulin',
      'cid': 16132389,
      'category': 'Complex',
      'formula': 'C₂₅₇H₃₈₃N₆₅O₇₇S₆'
    },
    {
      'name': 'DNA Nucleotide (Adenine)',
      'cid': 190,
      'category': 'Complex',
      'formula': 'C₅H₅N₅'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load recent molecules first
    _loadRecentMolecules().then((_) {
      // If initialCid is provided, load that molecule
      if (widget.initialCid != null) {
        _loadMolecule(widget.initialCid!);
      }
    });
  }

  Future<void> _loadRecentMolecules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentMoleculesJson = prefs.getString('recent_molecules');

      if (recentMoleculesJson != null) {
        final List<dynamic> decodedList = jsonDecode(recentMoleculesJson);
        setState(() {
          _recentMolecules = List<Map<String, dynamic>>.from(
              decodedList.map((item) => Map<String, dynamic>.from(item)));
        });
      }
    } catch (e) {
      debugPrint('Error loading recent molecules: $e');
      // If there's an error, initialize with an empty list
      setState(() {
        _recentMolecules = [];
      });
    }
  }

  Future<void> _searchMolecule(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Switch to viewer tab as soon as search begins
    _tabController.animateTo(0);

    try {
      final provider = Provider.of<CompoundProvider>(context, listen: false);
      final cids = await provider.fetchCids(query);

      if (cids.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'No molecules found for "$query"';
        });
        return;
      }

      // Load the first result
      _loadMolecule(cids.first, name: query);

      // The formula will be fetched by _loadMolecule and then will be available
      // We'll add to recent molecules after formula is fetched
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = ErrorHandler.getErrorMessage(e);
      });
    }
  }

  Future<void> _fetchMoleculeDetails(int cid) async {
    try {
      final provider = Provider.of<CompoundProvider>(context, listen: false);
      final info = await provider.fetchBasicProperties([cid], limit: 1);

      if (info.isNotEmpty) {
        setState(() {
          _currentMoleculeName = info.first['title'] ?? 'Molecule $cid';
          _currentFormula = info.first['molecular_formula'] ?? '';
          _isLoading = false;
        });

        // Add to recent molecules after fetching details
        _addToRecentMolecules(_currentMoleculeName, cid,
            formula: _currentFormula);
      } else {
        setState(() {
          _currentMoleculeName = 'Molecule $cid';
          _currentFormula = '';
          _isLoading = false;
        });

        // Still add to recents even with limited info
        _addToRecentMolecules(_currentMoleculeName, cid);
      }
    } catch (e) {
      setState(() {
        _currentMoleculeName = 'Molecule $cid';
        _currentFormula = '';
        _isLoading = false;
      });

      // Still add to recents even with limited info
      _addToRecentMolecules(_currentMoleculeName, cid);
    }
  }

  void _loadMolecule(int cid, {String? name, String? formula}) {
    setState(() {
      _currentCid = cid;
      _isLoading = true;
      _error = null;
      if (name != null) {
        _currentMoleculeName = name;
      }
      if (formula != null) {
        _currentFormula = formula;
      } else {
        _currentFormula = '';
      }
    });

    // Fetch molecule details if not provided
    if (name == null || formula == null) {
      _fetchMoleculeDetails(cid);
    } else {
      setState(() {
        _isLoading = false;
      });

      // Add to recent molecules if both name and formula are provided
      _addToRecentMolecules(name, cid, formula: formula);
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      // Enter full screen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      // Exit full screen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggle2D3DView() {
    setState(() {
      _is2DView = !_is2DView;
    });
  }

  void _addToRecentMolecules(String name, int cid, {String formula = ''}) {
    // Create new list to trigger state rebuild
    List<Map<String, dynamic>> updatedList = List.from(_recentMolecules);

    // Remove if already exists
    updatedList.removeWhere((molecule) => molecule['cid'] == cid);

    // Add to the beginning
    updatedList.insert(0, {
      'name': name,
      'cid': cid,
      'formula': formula.isNotEmpty ? formula : _currentFormula,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });

    // Limit to 10 recent molecules
    if (updatedList.length > 10) {
      updatedList = updatedList.sublist(0, 10);
    }

    // Update state and save to storage
    setState(() {
      _recentMolecules = updatedList;
    });

    // Save to storage
    _saveRecentMolecules();
  }

  Future<void> _saveRecentMolecules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentMoleculesJson = jsonEncode(_recentMolecules);
      await prefs.setString('recent_molecules', recentMoleculesJson);
    } catch (e) {
      debugPrint('Error saving recent molecules: $e');
    }
  }

  // Add methods for clearing history items

  Future<void> _clearAllRecentMolecules() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all molecule viewing history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _recentMolecules = [];
              });
              await _saveRecentMolecules();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeRecentMolecule(int cid) async {
    setState(() {
      _recentMolecules.removeWhere((molecule) => molecule['cid'] == cid);
    });
    await _saveRecentMolecules();
  }

  @override
  void dispose() {
    // Ensure we exit full screen mode when leaving the screen
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Full screen mode layout
    if (_isFullScreen && _currentCid != null) {
      return FullscreenMoleculeView(
        cid: _currentCid!,
        moleculeName: _currentMoleculeName,
        formula: _currentFormula,
        is2DView: _is2DView,
        onToggleView: _toggle2D3DView,
        onExitFullscreen: _toggleFullScreen,
      );
    }

    // Regular screen layout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Molecule Viewer'),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
        actions: [
          if (_currentCid != null)
            IconButton(
              icon: Icon(_is2DView ? Icons.view_in_ar : Icons.image),
              tooltip: _is2DView ? 'Switch to 3D View' : 'Switch to 2D View',
              onPressed: _toggle2D3DView,
            ),
          if (_currentCid != null)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: 'Full Screen Mode',
              onPressed: _toggleFullScreen,
            ),
          if (_currentCid != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Molecule',
              onPressed: () {
                Share.share(
                  'Check out this molecule: $_currentMoleculeName on PubChem https://pubchem.ncbi.nlm.nih.gov/compound/$_currentCid',
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search molecules by name...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onSubmitted: (value) {
                _searchMolecule(value);
              },
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Viewer'),
              Tab(text: 'Featured'),
              Tab(text: 'Recent'),
            ],
            labelColor: theme.colorScheme.primary,
            indicatorColor: theme.colorScheme.primary,
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Viewer tab
                MoleculeViewerTab(
                  currentCid: _currentCid,
                  currentMoleculeName: _currentMoleculeName,
                  currentFormula: _currentFormula,
                  isLoading: _isLoading,
                  error: _error,
                  is2DView: _is2DView,
                  onToggleView: _toggle2D3DView,
                  onFullScreenToggle: _toggleFullScreen,
                  onRetry: () {
                    if (_currentCid != null) {
                      _loadMolecule(_currentCid!);
                    }
                  },
                  onViewPubChem: () {
                    if (_currentCid != null) {
                      UrlLauncherUtil.launchURL(
                        context,
                        'https://pubchem.ncbi.nlm.nih.gov/compound/$_currentCid',
                      );
                    }
                  },
                ),

                // Featured molecules tab
                FeaturedMoleculesTab(
                  featuredMolecules: _featuredMolecules,
                  onMoleculeSelected: (cid, name, formula) {
                    _loadMolecule(cid, name: name, formula: formula);
                    _tabController.animateTo(0); // Switch to viewer tab
                  },
                ),

                // Recent molecules tab
                RecentMoleculesTab(
                  recentMolecules: _recentMolecules,
                  onMoleculeSelected: (cid, name, formula) {
                    _loadMolecule(cid, name: name, formula: formula);
                    _tabController.animateTo(0); // Switch to viewer tab
                  },
                  onClearAll: _clearAllRecentMolecules,
                  onRemoveItem: _removeRecentMolecule,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
