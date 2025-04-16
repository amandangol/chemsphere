import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/molecular_structure_provider.dart';
import '../../models/molecular_structure.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cube/flutter_cube.dart';

class MolecularStructureScreen extends StatefulWidget {
  const MolecularStructureScreen({Key? key}) : super(key: key);

  @override
  _MolecularStructureScreenState createState() =>
      _MolecularStructureScreenState();
}

class _MolecularStructureScreenState extends State<MolecularStructureScreen> {
  final _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Molecular Structures',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<MolecularStructureProvider>().clearStructures();
                _clearSearch();
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.3),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and subtitle
              if (!_isSearching) ...[
                const Text(
                  'Explore Molecules',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search for compounds to view their molecular structures and properties',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Search field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        'Enter compound name (e.g., "glucose", "benzene")',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.category,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      context
                          .read<MolecularStructureProvider>()
                          .searchByCompoundName(query);
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Search button
              if (_isSearching)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<MolecularStructureProvider>()
                          .searchByCompoundName(_controller.text);
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Results area
              Expanded(
                child: Consumer<MolecularStructureProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Searching compounds...',
                              style:
                                  TextStyle(color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.error != null) {
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
                              'Error: ${provider.error}',
                              style: TextStyle(color: theme.colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                provider.clearStructures();
                                _clearSearch();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.structure == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.science,
                              size: 64,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start your search',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter a compound name to see its structure',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Results list
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Found ${provider.structure?.length ?? 0} compounds',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.structure?.length ?? 0,
                            itemBuilder: (context, index) {
                              final structure = provider.structure?[index];
                              return MoleculeCard(structure: structure!);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoleculeCard extends StatelessWidget {
  final MolecularStructure structure;

  const MoleculeCard({required this.structure});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Image and basic info
          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(8),
                child: Hero(
                  tag: 'molecule_${structure.cid}',
                  child: Image.network(
                    'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${structure.cid}/PNG',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        structure.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        structure.molecularFormula,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MW: ${structure.molecularWeight.toStringAsFixed(2)} g/mol',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Divider
          const Divider(height: 1),

          // Structural properties
          ExpansionTile(
            title: const Text('Structural Properties'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStructuralPropertyRow('Heavy Atoms',
                        structure.heavyAtomCount?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('H-Bond Donors',
                        structure.hBondDonorCount?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('H-Bond Acceptors',
                        structure.hBondAcceptorCount?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Rotatable Bonds',
                        structure.rotatableBondCount?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Stereogenic Atoms',
                        structure.atomStereoCount?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Stereogenic Bonds',
                        structure.bondStereoCount?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow('Complexity',
                        structure.complexity?.toString() ?? 'N/A'),
                    _buildStructuralPropertyRow(
                        'XLogP', structure.xLogP?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),

          // SMILES notation
          ExpansionTile(
            title: const Text('SMILES Notation'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Canonical SMILES:'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        structure.smiles,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // View 3D button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MoleculeVisualizationPage(cid: structure.cid),
                  ),
                );
              },
              icon: const Icon(Icons.view_in_ar),
              label: const Text('View 3D Structure'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuralPropertyRow(String property, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            property,
            style: const TextStyle(fontWeight: FontWeight.w500),
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
  String _viewType = '3D';
  Object? _molecule;

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Molecule Visualization'),
        actions: [
          ToggleButtons(
            children: const [
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
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text('Error: $_error',
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Compound name
                      if (_data != null)
                        Text(
                          _data!['Record']['RecordTitle'] ??
                              'Molecule Structure',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 24),

                      // Structure view
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _viewType == '3D'
                            ? Cube(
                                onSceneCreated: (Scene scene) {
                                  scene.world.add(Object(
                                    fileName:
                                        'assets/molecules/${widget.cid}.obj',
                                    scale: Vector3(1, 1, 1),
                                    position: Vector3(0, 0, 0),
                                    rotation: Vector3(0, 0, 0),
                                  ));
                                },
                              )
                            : Center(
                                child: Image.network(
                                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${widget.cid}/PNG?image_size=500x500',
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image,
                                            size: 50,
                                            color: theme.colorScheme.error),
                                        const SizedBox(height: 8),
                                        Text('Could not load image',
                                            style: TextStyle(
                                                color:
                                                    theme.colorScheme.error)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 16),

                      // 3D Controls
                      if (_viewType == '3D')
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3D Controls',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildControlButton(
                                      context,
                                      icon: Icons.rotate_left,
                                      onPressed: () {
                                        setState(() {
                                          if (_molecule != null) {
                                            (_molecule as Object).rotation.y -=
                                                30;
                                          }
                                        });
                                      },
                                      label: 'Rotate Left',
                                    ),
                                    _buildControlButton(
                                      context,
                                      icon: Icons.rotate_right,
                                      onPressed: () {
                                        setState(() {
                                          if (_molecule != null) {
                                            (_molecule as Object).rotation.y +=
                                                30;
                                          }
                                        });
                                      },
                                      label: 'Rotate Right',
                                    ),
                                    _buildControlButton(
                                      context,
                                      icon: Icons.zoom_in,
                                      onPressed: () {
                                        setState(() {
                                          if (_molecule != null) {
                                            final scale =
                                                (_molecule as Object).scale;
                                            scale.setValues(scale.x * 1.2,
                                                scale.y * 1.2, scale.z * 1.2);
                                            (_molecule as Object)
                                                .updateTransform(); // update the object’s transform
                                          }
                                        });
                                      },
                                      label: 'Zoom In',
                                    ),
                                    _buildControlButton(
                                      context,
                                      icon: Icons.zoom_out,
                                      onPressed: () {
                                        setState(() {
                                          if (_molecule != null) {
                                            final scale =
                                                (_molecule as Object).scale;
                                            scale.setValues(scale.x * 0.8,
                                                scale.y * 0.8, scale.z * 0.8);
                                            (_molecule as Object)
                                                .updateTransform(); // update the object’s transform
                                          }
                                        });
                                      },
                                      label: 'Zoom Out',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Note about 3D view
                      if (_viewType == '3D')
                        Card(
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Interactive 3D Structure',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Use the controls above to rotate and zoom the molecule. You can also use touch gestures:\n• Drag to rotate\n• Pinch to zoom\n• Two-finger drag to pan',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Structure explanation
                      Text(
                        'Structure Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atoms and Bonds',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Different colors represent different atoms:\n• Black: Carbon\n• White: Hydrogen\n• Red: Oxygen\n• Blue: Nitrogen\n• Yellow: Sulf\n• Green: Halogens (Cl, Br, I, F)',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bond Types',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Single bonds: One line\n• Double bonds: Two lines\n• Triple bonds: Three lines\n• Aromatic bonds: Dashed lines or circles in aromatic systems',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Download buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Download feature would be implemented here'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Save 2D Structure'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Download feature would be implemented here'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Save 3D Structure'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          tooltip: label,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
