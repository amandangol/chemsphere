import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/molecular_structure.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_cube/flutter_cube.dart';

class MolecularStructureScreen extends StatefulWidget {
  final MolecularStructure structure;

  const MolecularStructureScreen({
    Key? key,
    required this.structure,
  }) : super(key: key);

  @override
  _MolecularStructureScreenState createState() =>
      _MolecularStructureScreenState();
}

class _MolecularStructureScreenState extends State<MolecularStructureScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;
  String _viewType = '3D';
  Object? _molecule;
  bool _showLabels = true;
  bool _showBonds = true;
  bool _showAtoms = true;
  String _currentView = 'ball-and-stick';

  @override
  void initState() {
    super.initState();
    _fetchMoleculeData();
  }

  Future<void> _fetchMoleculeData() async {
    try {
      final url =
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/${widget.structure.cid}/JSON';
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
        title: Text(
          'Molecular Structure',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
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
                  child: Text(
                    'Error: $_error',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                )
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
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
                                        'assets/molecules/${widget.structure.cid}.obj',
                                    scale: Vector3(1, 1, 1),
                                    position: Vector3(0, 0, 0),
                                    rotation: Vector3(0, 0, 0),
                                  ));
                                },
                              )
                            : Center(
                                child: Image.network(
                                  'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${widget.structure.cid}/PNG?image_size=500x500',
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
                                        Text(
                                          'Could not load image',
                                          style: GoogleFonts.poppins(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
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
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
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
                                                .updateTransform();
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
                                                .updateTransform();
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
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Use the controls above to rotate and zoom the molecule. You can also use touch gestures:\n• Drag to rotate\n• Pinch to zoom\n• Two-finger drag to pan',
                                  style: GoogleFonts.poppins(
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
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
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
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Different colors represent different atoms:\n• Black: Carbon\n• White: Hydrogen\n• Red: Oxygen\n• Blue: Nitrogen\n• Yellow: Sulf\n• Green: Halogens (Cl, Br, I, F)',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bond Types',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Single bonds: One line\n• Double bonds: Two lines\n• Triple bonds: Three lines\n• Aromatic bonds: Dashed lines or circles in aromatic systems',
                                style: GoogleFonts.poppins(
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
                                  SnackBar(
                                    content: Text(
                                      'Download feature would be implemented here',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: Text(
                                'Save 2D Structure',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Download feature would be implemented here',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: Text(
                                'Save 3D Structure',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _buildVisualizationControls(),
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
    bool isActive = true,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color:
            isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceVariant,
      ),
    );
  }

  Widget _buildVisualizationControls() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visualization Controls',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildControlButton(
                  context,
                  icon: Icons.label,
                  onPressed: () {
                    setState(() {
                      _showLabels = !_showLabels;
                    });
                  },
                  label: 'Labels',
                  isActive: _showLabels,
                ),
                _buildControlButton(
                  context,
                  icon: Icons.link,
                  onPressed: () {
                    setState(() {
                      _showBonds = !_showBonds;
                    });
                  },
                  label: 'Bonds',
                  isActive: _showBonds,
                ),
                _buildControlButton(
                  context,
                  icon: Icons.circle,
                  onPressed: () {
                    setState(() {
                      _showAtoms = !_showAtoms;
                    });
                  },
                  label: 'Atoms',
                  isActive: _showAtoms,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'View Mode',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                _currentView == 'ball-and-stick',
                _currentView == 'space-filling',
                _currentView == 'wireframe',
              ],
              onPressed: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      _currentView = 'ball-and-stick';
                      break;
                    case 1:
                      _currentView = 'space-filling';
                      break;
                    case 2:
                      _currentView = 'wireframe';
                      break;
                  }
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Ball & Stick'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Space Filling'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Wireframe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
