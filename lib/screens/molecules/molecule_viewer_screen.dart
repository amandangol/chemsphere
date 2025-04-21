import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/chemistry_widgets.dart';
import '../../widgets/molecule_3d_viewer.dart';
import '../compounds/provider/compound_provider.dart';
import '../../utils/error_handler.dart';

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

    if (widget.initialCid != null) {
      _loadMolecule(widget.initialCid!);
    }

    // Load recent molecules from shared preferences or other storage
    _loadRecentMolecules();
  }

  Future<void> _loadRecentMolecules() async {
    // This would be implemented to load from storage
    // For now, we'll use a placeholder with a single example
    setState(() {
      _recentMolecules = [
        {'name': 'Water', 'cid': 962, 'formula': 'H₂O'},
      ];
    });
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
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _addToRecentMolecules(query, cids.first);
        }
      });
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
      } else {
        setState(() {
          _currentMoleculeName = 'Molecule $cid';
          _currentFormula = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentMoleculeName = 'Molecule $cid';
        _currentFormula = '';
        _isLoading = false;
      });
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

  // Generate URL for 2D image of molecule
  String _get2DImageUrl(int cid) {
    return 'https://pubchem.ncbi.nlm.nih.gov/image/imgsrv.fcgi?cid=$cid&t=l';
  }

  Future<void> _launchPubChemUrl(int cid) async {
    final url = Uri.parse('https://pubchem.ncbi.nlm.nih.gov/compound/$cid');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open URL: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addToRecentMolecules(String name, int cid, {String formula = ''}) {
    // Remove if already exists
    _recentMolecules.removeWhere((molecule) => molecule['cid'] == cid);

    // Add to the beginning
    _recentMolecules.insert(0, {
      'name': name,
      'cid': cid,
      'formula': formula.isNotEmpty ? formula : _currentFormula,
    });

    // Limit to 10 recent molecules
    if (_recentMolecules.length > 10) {
      _recentMolecules = _recentMolecules.sublist(0, 10);
    }

    // Save to storage (would be implemented)
    _saveRecentMolecules();
  }

  void _saveRecentMolecules() {
    // Would save to SharedPreferences or other storage
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
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Full screen viewer based on current view mode
            SizedBox.expand(
              child: _is2DView
                  ? _build2DFullScreenView(theme)
                  : FullScreenMoleculeView(
                      cid: _currentCid!,
                      title: "Molecule Viewer",
                    ),
            ),

            // Controls overlay for full screen mode
            Positioned(
              top: 40,
              right: 16,
              child: Row(
                children: [
                  // 2D/3D toggle button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    margin: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: Icon(
                        _is2DView ? Icons.view_in_ar : Icons.image,
                        color: Colors.white,
                      ),
                      tooltip:
                          _is2DView ? 'Switch to 3D View' : 'Switch to 2D View',
                      onPressed: _toggle2D3DView,
                    ),
                  ),

                  // Exit full screen button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Tooltip(
                      message: 'Exit Full Screen',
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen_exit,
                            color: Colors.white),
                        onPressed: _toggleFullScreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Molecule name and formula overlay at the top
            _buildFullscreenTitleOverlay(),
          ],
        ),
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
                _buildViewerTab(theme),

                // Featured molecules tab
                _buildFeaturedTab(theme),

                // Recent molecules tab
                _buildRecentTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerTab(ThemeData theme) {
    if (_currentCid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a molecule or select one from\nFeatured or Recent tabs',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: ChemistryLoadingWidget(
          message: 'Loading molecule data...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_currentCid != null) {
                  _loadMolecule(_currentCid!);
                }
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Molecule name with view toggle
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _currentMoleculeName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              if (_currentFormula.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _currentFormula,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.secondary,
                      fontFamily: 'JetBrainsMono',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),

        // View type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _is2DView ? '2D Structure' : '3D Structure',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Molecule viewer (2D or 3D based on toggle)
        Expanded(
          child: _is2DView
              ? _build2DView(theme)
              : Complete3DMoleculeViewer(
                  cid: _currentCid!,
                ),
        ),

        // Action buttons at the bottom
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: Icon(Icons.swap_horiz),
                label: Text(_is2DView ? 'View 3D' : 'View 2D'),
                onPressed: _toggle2D3DView,
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.info_outline),
                label: Text('PubChem'),
                onPressed: () {
                  _launchPubChemUrl(_currentCid!);
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.fullscreen),
                label: Text('Full Screen'),
                onPressed: _toggleFullScreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Build the 2D view of the molecule
  Widget _build2DView(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 2D image from PubChem
              CachedNetworkImage(
                imageUrl: _get2DImageUrl(_currentCid!),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: theme.colorScheme.error),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load 2D structure',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
                fit: BoxFit.contain,
              ),

              // Zoom instructions overlay
              Positioned(
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pinch to zoom',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
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
    );
  }

  // Build the full screen 2D view
  Widget _build2DFullScreenView(ThemeData theme) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(50),
      minScale: 0.5,
      maxScale: 8.0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: _get2DImageUrl(_currentCid!),
            placeholder: (context, url) =>
                CircularProgressIndicator(color: Colors.white),
            errorWidget: (context, url, error) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Failed to load 2D structure',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTab(ThemeData theme) {
    // Get unique categories
    final categories =
        _featuredMolecules.map((m) => m['category'] as String).toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search guidance
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap any molecule to view its 2D/3D structure. You can also search for specific molecules by name above.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories and molecules
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final category in categories) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: _featuredMolecules
                          .where((m) => m['category'] == category)
                          .length,
                      itemBuilder: (context, index) {
                        final molecule = _featuredMolecules
                            .where((m) => m['category'] == category)
                            .toList()[index];
                        return _buildMoleculeCard(
                          theme,
                          name: molecule['name'],
                          cid: molecule['cid'],
                          formula: molecule['formula'] ?? '',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTab(ThemeData theme) {
    if (_recentMolecules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent molecules',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: _recentMolecules.length,
        itemBuilder: (context, index) {
          final molecule = _recentMolecules[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Hero(
                tag: 'molecule-2d-${molecule['cid']}',
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      NetworkImage(_get2DImageUrl(molecule['cid'])),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback if image fails to load
                    return null;
                  },
                  child: Icon(
                    Icons.view_in_ar,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              title: Text(molecule['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (molecule['formula'] != null &&
                      molecule['formula'].isNotEmpty)
                    Text(
                      molecule['formula'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  Text(
                    'CID: ${molecule['cid']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              isThreeLine:
                  molecule['formula'] != null && molecule['formula'].isNotEmpty,
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                _loadMolecule(
                  molecule['cid'],
                  name: molecule['name'],
                  formula: molecule['formula'] ?? '',
                );
                _tabController.animateTo(0); // Switch to viewer tab
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoleculeCard(ThemeData theme,
      {required String name, required int cid, String formula = ''}) {
    return InkWell(
      onTap: () {
        _loadMolecule(cid, name: name, formula: formula);
        _tabController.animateTo(0); // Switch to viewer tab
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Molecule 2D preview
            Hero(
              tag: 'molecule-preview-$cid',
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(_get2DImageUrl(cid)),
                    fit: BoxFit.contain,
                    onError: (exception, stackTrace) {
                      // Just log the error and let the fallback happen
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (formula.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.secondary,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            Text(
              'CID: $cid',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Full screen overlay for molecule name
  Widget _buildFullscreenTitleOverlay() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentMoleculeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentFormula.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _currentFormula,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
