import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../screens/compounds/provider/compound_provider.dart';
import '../screens/compounds/compound_details_screen.dart';
import 'dart:async';

class Molecule3DViewer extends StatefulWidget {
  final int cid;
  final double height;
  final Function(WebViewController)? onWebViewCreated;
  final bool isFullScreen;

  const Molecule3DViewer({
    Key? key,
    required this.cid,
    this.height = 300,
    this.onWebViewCreated,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  State<Molecule3DViewer> createState() => _Molecule3DViewerState();
}

class _Molecule3DViewerState extends State<Molecule3DViewer> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  String _currentStyle = 'stick';
  bool _isStructureAvailable = true;
  Timer? _rotationTimer;
  bool _autoRotate = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _loadMoleculeData();
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = 'Failed to load 3D viewer: ${error.description}';
                _isStructureAvailable = false;
              });
            }
          },
        ),
      );

    // Platform specific settings
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest(
            (PlatformWebViewPermissionRequest request) {
          request.grant();
        });
    }

    _controller.loadHtmlString(_get3DMolHTML());

    // Notify parent widget about WebView creation
    if (widget.onWebViewCreated != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onWebViewCreated!(_controller);
        }
      });
    }
  }

  Future<void> _loadMoleculeData() async {
    try {
      final provider = Provider.of<CompoundProvider>(context, listen: false);

      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Fetch the SDF data for the compound
      final sdfData = await provider.fetch3DStructure(widget.cid);

      // Check if the structure data is empty or invalid
      if (sdfData.isEmpty || sdfData.contains('Error')) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = '3D structure not available for this compound';
            _isStructureAvailable = false;
          });
        }
        return;
      }

      // Escape any quotes in the SDF data to avoid JavaScript issues
      final escapedSDF = sdfData.replaceAll('"', '\\"').replaceAll('\n', '\\n');

      // Execute JavaScript to load the molecule data into the 3Dmol viewer
      await _controller.runJavaScript('''
        try {
          let viewer = \$3Dmol.viewers.viewer_3dmol;
          viewer.clear();
          viewer.addModel("$escapedSDF", "sdf");
          viewer.setBackgroundColor(0xffffff, 0.0);
          viewer.setStyle({}, {"$_currentStyle": {colorscheme: "rasmol"}});
          viewer.setViewStyle({style: "outline"});
          viewer.zoomTo(${widget.isFullScreen ? '0.5' : '1.0'});
          viewer.render();
          ${widget.isFullScreen ? '' : 'viewer.disableRotation();'}
          // Store SDF data for later use
          window.moleculeSDF = "$escapedSDF";
          true;
        } catch (e) {
          console.error("Error loading molecule data:", e);
          false;
        }
      ''').then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isStructureAvailable = true;

            // Start auto-rotation after the molecule is loaded
            _startAutoRotation();
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Error rendering molecule: $error';
            _isStructureAvailable = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load molecule data: $e';
          _isStructureAvailable = false;
        });
      }
    }
  }

  void _toggleAutoRotation() {
    setState(() {
      _autoRotate = !_autoRotate;
    });

    if (_autoRotate) {
      _startAutoRotation();
    } else {
      _stopAutoRotation();
    }
  }

  void _startAutoRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _isStructureAvailable && !_isLoading) {
        _controller?.runJavaScript('''
          try {
            let viewer = \$3Dmol.viewers.viewer_3dmol;
            viewer.rotate(0.5, {y: 1});
            viewer.render();
          } catch (e) {
            console.error("Error in auto-rotation:", e);
          }
        ''');
      }
    });
  }

  void _stopAutoRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  void changeStyle(String style) {
    if (_currentStyle == style) return;

    setState(() {
      _currentStyle = style;
    });

    _controller.runJavaScript('''
      try {
        let viewer = \$3Dmol.viewers.viewer_3dmol;
        viewer.setStyle({}, {"$style": {colorscheme: "rasmol"}});
        viewer.render();
        true;
      } catch (e) {
        console.error("Error changing style:", e);
        false;
      }
    ''');
  }

  // Generate HTML with embedded 3Dmol.js
  String _get3DMolHTML() {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <title>3D Molecule Viewer</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/3Dmol/2.0.3/3Dmol-min.js"></script>
        <style>
          body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            width: 100%;
            height: 100%;
            background-color: transparent;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            user-select: none;
            touch-action: none;
            overscroll-behavior: none;
          }
          #viewer {
            position: absolute;
            width: 100%;
            height: 100%;
            transform: translateZ(0);
            -webkit-transform: translateZ(0);
            will-change: transform;
            backface-visibility: hidden;
            -webkit-backface-visibility: hidden;
            touch-action: none;
            overscroll-behavior: none;
          }
          #viewer canvas {
            touch-action: none;
            overscroll-behavior: none;
          }
        </style>
      </head>
      <body>
        <div id="viewer"></div>
        <script>
          \$(document).ready(function() {
            let config = {
              backgroundColor: 'transparent',
              antialias: true,
              quality: 'medium',
              defaultcolors: \$3Dmol.rasmolElementColors,
              disableFog: true,
            };
            window.\$3Dmol.viewers.viewer_3dmol = \$3Dmol.createViewer(
              document.getElementById('viewer'), 
              config
            );
            
            // Prevent default touch behaviors
            document.getElementById('viewer').addEventListener('touchmove', function(e) {
              e.preventDefault();
            }, { passive: false });
          });
        </script>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // WebView for 3D rendering
          if (_isStructureAvailable)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3D structure not available',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Error message
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMoleculeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Note about full-screen mode
          if (!widget.isFullScreen)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Tap full screen to interact with the 3D structure',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Color legend
          if (widget.isFullScreen)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColorLegendItem('Carbon (C)', Colors.grey),
                    _buildColorLegendItem('Hydrogen (H)', Colors.white),
                    _buildColorLegendItem('Oxygen (O)', Colors.red),
                    _buildColorLegendItem('Nitrogen (N)', Colors.blue),
                    _buildColorLegendItem('Sulfur (S)', Colors.yellow),
                    _buildColorLegendItem('Phosphorus (P)', Colors.orange),
                    _buildColorLegendItem('Halogens', Colors.green),
                    _buildColorLegendItem('Metals', Colors.purple),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class Molecule3DControls extends StatelessWidget {
  final WebViewController? controller;
  final VoidCallback onReset;
  final Function(String)? onStyleChange;
  final String currentStyle;
  final bool showFullScreenButton;
  final VoidCallback? onFullScreenToggle;
  final bool isFullScreen;

  const Molecule3DControls({
    Key? key,
    this.controller,
    required this.onReset,
    this.onStyleChange,
    this.currentStyle = 'stick',
    this.showFullScreenButton = true,
    this.onFullScreenToggle,
    this.isFullScreen = false,
  }) : super(key: key);

  void _executeRotation(String direction) {
    if (controller == null) return;

    String jsCommand;
    switch (direction) {
      case 'left':
        jsCommand = 'viewer.rotate(2, {y:1});';
        break;
      case 'right':
        jsCommand = 'viewer.rotate(-2, {y:1});';
        break;
      case 'up':
        jsCommand = 'viewer.rotate(2, {x:1});';
        break;
      case 'down':
        jsCommand = 'viewer.rotate(-2, {x:1});';
        break;
      case 'reset':
        jsCommand = 'viewer.zoomTo();';
        break;
      default:
        return;
    }
    controller!.runJavaScript('''
      try {
        let viewer = \$3Dmol.viewers.viewer_3dmol;
        $jsCommand
        viewer.render();
      } catch (e) {
        console.error("Error rotating molecule:", e);
      }
    ''');
  }

  void _applyStyle(String style) {
    if (controller == null || onStyleChange == null) return;

    onStyleChange!(style);
    controller!.runJavaScript('''
      try {
        let viewer = \$3Dmol.viewers.viewer_3dmol;
        viewer.setStyle({}, {"$style": {colorscheme: "rasmol"}});
        viewer.render();
      } catch (e) {
        console.error("Error applying style:", e);
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rotation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.rotate_left),
                onPressed:
                    controller == null ? null : () => _executeRotation('left'),
                tooltip: 'Rotate Left',
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.rotate_right),
                onPressed:
                    controller == null ? null : () => _executeRotation('right'),
                tooltip: 'Rotate Right',
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                onPressed:
                    controller == null ? null : () => _executeRotation('up'),
                tooltip: 'Rotate Up',
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed:
                    controller == null ? null : () => _executeRotation('down'),
                tooltip: 'Rotate Down',
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: controller == null
                    ? null
                    : () {
                        _executeRotation('reset');
                        onReset();
                      },
                tooltip: 'Reset View',
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Style controls and full screen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Style selector
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'stick',
                      label: Text('Stick'),
                      icon: Icon(Icons.linear_scale),
                    ),
                    ButtonSegment(
                      value: 'line',
                      label: Text('Line'),
                      icon: Icon(Icons.line_weight),
                    ),
                    ButtonSegment(
                      value: 'sphere',
                      label: Text('Ball'),
                      icon: Icon(Icons.circle),
                    ),
                  ],
                  selected: {currentStyle},
                  onSelectionChanged: (Set<String> selection) {
                    if (selection.isNotEmpty) {
                      _applyStyle(selection.first);
                    }
                  },
                  style: SegmentedButton.styleFrom(
                    selectedForegroundColor: theme.colorScheme.onPrimary,
                    selectedBackgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (showFullScreenButton && onFullScreenToggle != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                  onPressed: onFullScreenToggle,
                  tooltip: isFullScreen ? 'Exit Full Screen' : 'Full Screen',
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class Complete3DMoleculeViewer extends StatefulWidget {
  final int cid;

  const Complete3DMoleculeViewer({
    Key? key,
    required this.cid,
  }) : super(key: key);

  @override
  State<Complete3DMoleculeViewer> createState() =>
      _Complete3DMoleculeViewerState();
}

class _Complete3DMoleculeViewerState extends State<Complete3DMoleculeViewer> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _isFullScreen = false;
  String _currentStyle = 'stick';
  bool _autoRotate = true;
  Timer? _rotationTimer;

  void _onWebViewCreated(WebViewController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    });
  }

  void _changeStyle(String style) {
    setState(() {
      _currentStyle = style;
    });
  }

  void _resetView() {
    if (_controller != null) {
      _controller!.runJavaScript('''
        try {
          let viewer = \$3Dmol.viewers.viewer_3dmol;
          viewer.zoomTo();
          viewer.render();
        } catch (e) {
          console.error("Error resetting view:", e);
        }
      ''');
    }
  }

  void _toggleAutoRotation() {
    setState(() {
      _autoRotate = !_autoRotate;
    });

    if (_autoRotate) {
      _startAutoRotation();
    } else {
      _stopAutoRotation();
    }
  }

  void _startAutoRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _controller != null) {
        _controller!.runJavaScript('''
          try {
            let viewer = \$3Dmol.viewers.viewer_3dmol;
            viewer.rotate(0.5, {y: 1});
            viewer.render();
          } catch (e) {
            console.error("Error in auto-rotation:", e);
          }
        ''');
      }
    });
  }

  void _stopAutoRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRotation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title:
              const Text('3D Structure', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
              onPressed: _toggleAutoRotation,
              tooltip: _autoRotate ? 'Pause Rotation' : 'Start Rotation',
              color: Colors.white,
            ),
            // IconButton(
            //   icon: const Icon(Icons.fullscreen_exit),
            //   onPressed: _toggleFullScreen,
            //   tooltip: 'Exit Full Screen',
            //   color: Colors.white,
            // ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 3D Viewer
              Molecule3DViewer(
                cid: widget.cid,
                onWebViewCreated: _onWebViewCreated,
                isFullScreen: true,
              ),
              // Controls
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Molecule3DControls(
                  controller: _controller,
                  onReset: _resetView,
                  onStyleChange: _changeStyle,
                  currentStyle: _currentStyle,
                  showFullScreenButton: false,
                  isFullScreen: true,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.view_in_ar,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '3D Structure',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
                  onPressed: _toggleAutoRotation,
                  tooltip: _autoRotate ? 'Pause Rotation' : 'Start Rotation',
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
                // IconButton(
                //   icon: const Icon(Icons.fullscreen),
                //   onPressed: _toggleFullScreen,
                //   tooltip: 'Full Screen',
                //   iconSize: 20,
                //   visualDensity: VisualDensity.compact,
                // ),
              ],
            ),
          ),

          // 3D Viewer
          AspectRatio(
            aspectRatio: 1.5,
            child: Molecule3DViewer(
              cid: widget.cid,
              onWebViewCreated: _onWebViewCreated,
            ),
          ),

          // Controls
          Molecule3DControls(
            controller: _controller,
            onReset: _resetView,
            onStyleChange: _changeStyle,
            currentStyle: _currentStyle,
            showFullScreenButton: false,
          ),

          // Usage hint
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Tip: Drag to rotate, scroll to zoom, double-tap to reset view',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenMoleculeView extends StatefulWidget {
  final int cid;
  final String title;

  const FullScreenMoleculeView({
    Key? key,
    required this.cid,
    required this.title,
  }) : super(key: key);

  @override
  State<FullScreenMoleculeView> createState() => _FullScreenMoleculeViewState();
}

class _FullScreenMoleculeViewState extends State<FullScreenMoleculeView> {
  WebViewController? _controller;
  String _currentStyle = 'stick';
  bool _autoRotate = true;
  Timer? _rotationTimer;

  void _resetView() {
    if (_controller != null) {
      _controller!.runJavaScript('''
        try {
          let viewer = \$3Dmol.viewers.viewer_3dmol;
          viewer.zoomTo(0.5);
          viewer.render();
        } catch (e) {
          console.error("Error resetting view:", e);
        }
      ''');
    }
  }

  void _toggleAutoRotation() {
    setState(() {
      _autoRotate = !_autoRotate;
    });

    if (_autoRotate) {
      _startAutoRotation();
    } else {
      _stopAutoRotation();
    }
  }

  void _startAutoRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && _controller != null) {
        _controller!.runJavaScript('''
          try {
            let viewer = \$3Dmol.viewers.viewer_3dmol;
            viewer.rotate(0.5, {y: 1});
            viewer.render();
          } catch (e) {
            console.error("Error in auto-rotation:", e);
          }
        ''');
      }
    });
  }

  void _stopAutoRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRotation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoRotation,
            tooltip: _autoRotate ? 'Pause Rotation' : 'Start Rotation',
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
              child: Molecule3DViewer(
                cid: widget.cid,
                onWebViewCreated: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
                isFullScreen: true,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Molecule3DControls(
                controller: _controller,
                onReset: _resetView,
                onStyleChange: (style) {
                  setState(() {
                    _currentStyle = style;
                  });
                },
                currentStyle: _currentStyle,
                showFullScreenButton: false,
                isFullScreen: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for the CompoundDetailsScreen
extension Molecule3DViewerExtension on CompoundDetailsScreen {
  void showFullScreenMoleculeViewer(
      BuildContext context, int cid, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMoleculeView(
          cid: cid,
          title: title,
        ),
      ),
    );
  }
}
